# Signing secrets and where they live

**This repository is public.** Everything committed here is world-readable.
None of the values below are in version control, and none of them should be.

---

## What is actually secret

Not everything Apple gives you is a credential. Treating them the same way
leads to either sloppiness or paranoia, so the distinction is worth keeping
straight.

| Value | Secret? | Why |
|---|---|---|
| **App Store Connect API key (`.p8`)** | **Yes, critical** | Anyone holding it can upload builds and manage your app. Downloadable exactly once, and revoking it means reissuing everything that depends on it |
| **Signing certificate / `.p12`** | **Yes, critical** | Contains a private key. A leak lets someone sign code as you |
| **Key ID / Issuer ID** | Mildly | Useless alone, but they pair with the `.p8`. No reason to publish them |
| **Team ID** | No, but keep it private anyway | Ships inside every provisioning profile and can be read out of any released IPA. It is an identifier, not a credential. Keeping it off a public repo is tidiness, not a security control |
| **Bundle identifier** | No | Publicly visible on your App Store listing |

The `.gitignore` blocks `*.p8`, `*.p12`, `*.cer`, `*.mobileprovision`, `*.pem`
and `*.key` so the critical ones cannot be committed by accident.

---

## How the build gets them

`export_presets.cfg` is committed with the Team ID empty and a placeholder
bundle identifier. CI fills them in immediately before the export step:

```bash
export APPLE_TEAM_ID=XXXXXXXXXX
export IOS_BUNDLE_ID=com.example.soapescape
python3 tools/configure_ios_build.py
godot --headless --export-release "iOS" build/SoapEscape.xcodeproj
```

`tools/configure_ios_build.py` patches the file in place and validates both
values. It never echoes the Team ID into the build log. The checkout is
disposable, so the modified file is simply discarded after the build.

To build locally, set the same two variables. `git checkout export_presets.cfg`
reverts the change afterwards.

---

## Environment variables to configure

Set these five in whichever CI you use. Names are what the build scripts expect.

| Variable | Value | Where you got it |
|---|---|---|
| `APPLE_TEAM_ID` | 10 characters, uppercase | developer.apple.com > Membership details |
| `IOS_BUNDLE_ID` | e.g. `com.example.soapescape` | The identifier you registered |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | 10 characters | Shown next to the key you created. Note the name: Codemagic's CLI reads `KEY_IDENTIFIER`, not `KEY_ID` |
| `APP_STORE_CONNECT_ISSUER_ID` | a UUID | Top of the Integrations > App Store Connect API page |
| `APP_STORE_CONNECT_PRIVATE_KEY` | full contents of the `.p8` | The file you downloaded once |

For `APP_STORE_CONNECT_PRIVATE_KEY`, paste the whole file including the
`-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines.

### Why no Codemagic "integration"

Codemagic can store the `.p8` as a named integration and have the workflow
reference it with `auth: integration`. That path is **team-only**: the
Teams > Integrations menu does not exist on a personal account, and a config
using it fails validation with

```
auth -> "integration" requires workflow -> integrations -> app_store_connect
```

So `codemagic.yaml` passes the three API key values as environment variables
instead. Same outcome, no team required. `app-store-connect fetch-signing-files`
reads them from the environment and creates the distribution certificate and
provisioning profile on the fly, which also removes any need to manage those
by hand.

### Adding them in Codemagic

App settings > **Environment variables**. For each row: type the name, paste
the value, type `appstore` as the group, leave **Secret** ticked, click Add.
Secret variables are write-only afterwards and masked in build logs.

The group name must be exactly `appstore`, since that is what the workflow
imports.

`APP_STORE_CONNECT_PRIVATE_KEY` is multi-line. Paste the entire `.p8`
contents, including the `-----BEGIN PRIVATE KEY-----` and
`-----END PRIVATE KEY-----` lines. The value box accepts newlines.

### Adding them as GitHub Actions secrets

Repository > Settings > Secrets and variables > Actions > **New repository
secret**. Add one per row above.

Once stored, GitHub will not display a secret again, only let you overwrite it.
Values are masked in workflow logs, though anything a workflow deliberately
prints can still leak, so never `echo` them.

---

## If something leaks

1. **`.p8` key**: App Store Connect > Users and Access > Integrations > revoke
   the key, then generate a new one. Update the CI variables.
2. **Certificate or `.p12`**: developer.apple.com > Certificates > revoke, then
   issue a new one and regenerate any provisioning profiles built on it.
3. **Committed by accident**: revoking is the fix. Rewriting git history does
   not help, because anything pushed to a public repository should be treated
   as already copied.
