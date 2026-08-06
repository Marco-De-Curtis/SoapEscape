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
| `APP_STORE_CONNECT_KEY_ID` | 10 characters | Shown next to the key you created |
| `APP_STORE_CONNECT_ISSUER_ID` | a UUID | Top of the Integrations > App Store Connect API page |
| `APP_STORE_CONNECT_PRIVATE_KEY` | full contents of the `.p8` | The file you downloaded once |

For `APP_STORE_CONNECT_PRIVATE_KEY`, paste the whole file including the
`-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines.

### The integration name must match

`codemagic.yaml` names the App Store Connect integration literally:

```yaml
integrations:
  app_store_connect: Soapy Escape API Key
```

Codemagic will not accept the file without that block when publishing uses
`auth: integration`, and the string has to match what you called the
integration under Teams > Integrations > Apple Developer Portal, character for
character. It cannot be an environment variable. Rename one side or the other
until they agree.

### Adding them in Codemagic

Codemagic UI > your app > Settings > Environment variables. Create a group
called `appstore`, add each variable, and tick **Secure** on every one. Secure
variables are write-only afterwards and are masked in build logs.

Codemagic can also manage the API key natively under Teams > Integrations >
Apple Developer Portal, which is simpler than passing the three App Store
Connect values by hand. Either approach works.

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
