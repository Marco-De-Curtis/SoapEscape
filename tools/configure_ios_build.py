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


def patch(text, key, value):
    """Replace `key="..."` in the iOS preset section only."""
    pattern = re.compile(r'^(%s=)"[^"]*"$' % re.escape(key), re.MULTILINE)
    if not pattern.search(text):
        sys.exit("error: key %r not found in %s" % (key, PRESETS))
    return pattern.sub(lambda m: '%s"%s"' % (m.group(1), value), text, count=1)


def main():
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
