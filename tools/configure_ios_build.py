#!/usr/bin/env python3
"""Inject signing identifiers into export_presets.cfg at build time.

This repository is public, so the Apple Team ID and bundle identifier are kept
out of version control and supplied by the CI environment instead. Run this
immediately before the Godot export step:

    export APPLE_TEAM_ID=XXXXXXXXXX
    export IOS_BUNDLE_ID=com.example.soapescape
    python3 tools/configure_ios_build.py
    godot --headless --export-release "iOS" build/SoapEscape.xcodeproj

The file is modified in place. CI checkouts are disposable so that is fine;
locally, remember the change is uncommitted and `git checkout export_presets.cfg`
reverts it.

A Team ID is an identifier rather than a credential: it ships inside every
provisioning profile and can be read out of any released IPA. Keeping it out of
a public repo is tidiness, not a security control. The things that ARE secret
are the App Store Connect .p8 key, signing certificates and .p12 exports. Those
must never be committed anywhere, public or private. See .gitignore.
"""

import os
import re
import sys

PRESETS = "export_presets.cfg"
PROJECT = "project.godot"

# Settings whose committed value looks right in English but means something
# else to the engine. Both of these shipped a broken build before the guard
# existed, and neither produced any error at export time — the first bad
# build was iPad-only, the second was locked to landscape.
#
#   orientation: Godot 3 took the string "portrait" here; Godot 4 takes the
#   ScreenOrientation enum. A leftover string converts to 0, which is
#   SCREEN_LANDSCAPE, so the setting means the opposite of what it reads.
#
#   targeted_device_family: NOT the raw UIDeviceFamily numbering it resembles.
#   Godot's own enum is 0=iPhone, 1=iPad, 2=iPhone & iPad, so the value that
#   looks like "iPhone" is the one that builds iPad-only.
REQUIRED = [
    (PROJECT, "window/handheld/orientation", "1",
     "1 is SCREEN_PORTRAIT. A quoted \"portrait\" converts to 0, "
     "which is SCREEN_LANDSCAPE."),
    (PRESETS, "application/targeted_device_family", "0",
     "0 is iPhone in Godot's enum. 1 is iPad and 2 is both."),
]


def verify_enums():
    """Fail the build on a silently-wrong enum rather than after the upload."""
    for path, key, want, why in REQUIRED:
        with open(path) as f:
            text = f.read()
        m = re.search(r"^%s=(.*)$" % re.escape(key), text, re.MULTILINE)
        if not m:
            sys.exit("error: %s is missing %s.\n       %s" % (path, key, why))
        got = m.group(1).strip()
        if got != want:
            sys.exit("error: %s has %s=%s, expected %s.\n"
                     "       %s" % (path, key, got, want, why))
        print("verified %s=%s in %s" % (key, want, path))


def patch(text, key, value):
    """Replace `key="..."` in the iOS preset section only."""
    pattern = re.compile(r'^(%s=)"[^"]*"$' % re.escape(key), re.MULTILINE)
    if not pattern.search(text):
        sys.exit("error: key %r not found in %s" % (key, PRESETS))
    return pattern.sub(lambda m: '%s"%s"' % (m.group(1), value), text, count=1)


def main():
    verify_enums()

    team = os.environ.get("APPLE_TEAM_ID", "").strip()
    bundle = os.environ.get("IOS_BUNDLE_ID", "").strip()

    if not team:
        sys.exit("error: APPLE_TEAM_ID is not set.\n"
                 "Set it as a CI secret (Codemagic environment variable, or a\n"
                 "GitHub Actions repository secret) and expose it to this step.")

    if not re.fullmatch(r"[A-Z0-9]{10}", team):
        sys.exit("error: APPLE_TEAM_ID %r does not look like a Team ID.\n"
                 "Expected 10 uppercase alphanumeric characters." % team)

    with open(PRESETS) as f:
        text = f.read()

    text = patch(text, "application/app_store_team_id", team)
    print("set application/app_store_team_id (%d chars, value not logged)" % len(team))

    if bundle:
        if not re.fullmatch(r"[A-Za-z0-9.-]+", bundle) or bundle.count(".") < 2:
            sys.exit("error: IOS_BUNDLE_ID %r is not a valid reverse-DNS identifier." % bundle)
        text = patch(text, "application/bundle_identifier", bundle)
        print("set application/bundle_identifier")
    else:
        print("IOS_BUNDLE_ID not set, leaving the committed bundle identifier alone")

    with open(PRESETS, "w") as f:
        f.write(text)

    print("%s configured. Do not commit the result." % PRESETS)


if __name__ == "__main__":
    main()
