# Shipping Soapy Escape to iOS without owning a Mac

## The short answer

You cannot avoid macOS. You can avoid buying a Mac.

Building an iOS app requires `xcodebuild` and the iOS SDK, which run only on
macOS on Apple hardware. There is no cross-compiler, no Linux toolchain, and no
supported Windows path. Godot's iOS export does not produce a finished app: it
produces an Xcode project that still has to be compiled and signed on macOS.

What you can do is rent that macOS machine by the minute, and never touch it
directly. Everything on the account side (enrolment, certificates, App Store
Connect, metadata, screenshots review) is done through a browser and works fine
from any operating system.

A note on the obvious shortcut: running macOS in a VM on non-Apple hardware
violates the macOS software licence agreement, and Apple's build and notarisation
tooling is increasingly hostile to it. It is not a route worth building a release
process on.

---

## The options, ranked for this project

### 1. Codemagic (recommended starting point)

A CI service with first-class Godot support and macOS build machines. You push to
GitHub, it exports the project with Godot, compiles the Xcode project, signs it,
and uploads straight to TestFlight. You never see a Mac.

- Free tier covers a meaningful number of macOS build minutes per month, which is
  plenty for a game you ship a few times a year. Check current limits, they move.
- Handles code signing for you if you give it an App Store Connect API key.
- Godot is a documented, supported workflow rather than something you assemble.

Best fit here because the alternative is you learning `xcodebuild` flags for a
one-person game project.

### 2. GitHub Actions with a `macos` runner

Same idea, more assembly required, and you keep everything in the repo.

- Public repositories get macOS runner minutes free. Private repositories bill
  macOS minutes at roughly ten times the Linux rate, which eats a free-tier
  allowance quickly.
- You write the workflow: install Godot and the export templates, run a headless
  export, then `xcodebuild archive` and `xcodebuild -exportArchive`, then upload
  with fastlane.
- Signing is handled by importing a certificate and provisioning profile from
  repository secrets, or by letting fastlane `match` manage them.

Worth it if you want the pipeline version-controlled and are willing to spend an
evening on the first green build. CI pipelines for iOS signing famously do not
work first try.

### 3. Rent a cloud Mac by the hour or month

Services like MacStadium, MacinCloud, Scaleway and AWS EC2 Mac give you a real
macOS desktop over screen sharing. Pricing ranges from a few euros for a short
session to roughly $25 to $60 a month for a persistent managed machine. AWS and
Scaleway impose a 24 hour minimum allocation on Mac instances, which makes them
poor for a quick ten minute job.

Use this when you need macOS interactively rather than in a script: capturing
simulator screenshots, debugging a signing problem, or looking at a crash log in
Xcode. It is the escape hatch, not the daily driver.

### 4. Borrow a Mac for an afternoon

Genuinely worth considering for the first submission. Getting build one through
the pipeline is much easier with a real Xcode window in front of you, and after
that CI handles every subsequent build. A friend's laptop, a library, or an Apple
Store demo machine all work for the initial setup.

---

## What you can do right now, with no Mac at all

Do not wait on hardware for any of this:

1. **Enrol in the Apple Developer Program.** Browser only, $99/year. This is the
   long pole if you enrol as a company, so start it today.
2. **Register the Bundle ID** at developer.apple.com under Certificates,
   Identifiers & Profiles. Browser only.
3. **Create an App Store Connect API key**: Users and Access > Integrations >
   App Store Connect API. Download the `.p8` file, and record the Key ID and
   Issuer ID. This single key is what lets CI sign and upload without a Mac in
   your hands. You can only download the `.p8` once, so store it somewhere safe.
4. **Create the app record** in App Store Connect and fill in everything from
   `store/metadata.md`.
5. **Host the support and privacy pages** (see `store/README.md`).
6. **Fix the repo-side blockers**: bundle identifier, app icons, encryption plist
   key, launch screen colour.

That is genuinely most of the submission. The only step that needs macOS is
turning the repo into a signed binary.

---

## One thing you will still need

**A physical iPhone.** Not to build, but to test. This game is entirely
touch-driven: the whole control scheme is `_input` handling in `scripts/Soap.gd`
that splits the screen down the middle and tracks touch indices. It has almost
certainly only ever been exercised with the `A` and `D` keyboard fallbacks.

Ship it untested on a real device and you risk the control feel being wrong, or
multitouch behaving unexpectedly, in a way no reviewer will catch for you but
every one-star review will.

TestFlight makes this easy once the first build is uploaded: install on your own
phone, play all ten levels, then submit.

---

## Suggested sequence

1. Enrol in the Developer Program (starts the clock on approval)
2. Fix the repo blockers and get the store text and pages live
3. Set up Codemagic against this repository, target TestFlight
4. Iterate until a build lands in TestFlight
5. Play all ten levels on a real iPhone
6. Capture screenshots on device
7. Submit for review

Steps 1, 2 and part of 3 need no Mac and no phone. Start there.
