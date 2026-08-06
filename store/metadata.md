# App Store Connect metadata — Soap Escape v1.0

Copy each block straight into the matching App Store Connect field. Character
limits are Apple's; the counts in brackets are what the text below actually uses,
so you have room to edit without going over.

Placeholders to replace before submitting are written in `ALL_CAPS_UNDERSCORED`.

---

## App Information (set once, hard to change later)

| Field | Value |
|---|---|
| Bundle ID | `com.YOUR_COMPANY.soapescape` (must match `export_presets.cfg`) |
| SKU | `SOAPESCAPE001` (internal only, never shown to users) |
| Primary language | English (U.S.) |
| Primary category | Games > Arcade |
| Secondary category | Games > Casual |
| Copyright | `2026 YOUR_LEGAL_NAME` |
| Age rating | 4+ (see questionnaire below) |
| Price | Free |

---

## Name [11 / 30]

```
Soap Escape
```

If you want the keyword weight, App Store search indexes the name field heavily.
An alternative that stays readable:

```
Soap Escape: Slide & Dodge
```
[26 / 30]

---

## Subtitle [25 / 30]

```
Slide, dodge, don't melt!
```

Alternatives:
- `Don't melt before the drain` [27]
- `A soapy one-thumb arcade run` [28]

---

## Promotional text [148 / 170]

Editable any time without a new review, so use it for seasonal hooks later.

```
Ten levels of slippery panic. Steer your soap past drains, ducks and combs, and reach the finish line before the wet zones melt you into nothing.
```

---

## Description [1187 / 4000]

```
You are a bar of soap. You have slipped out of someone's hand, and the drain channel ahead is long, wet, and full of things that want to wear you down.

Tap the left or right side of the screen to lean. That is the whole control scheme. Getting good at it is the rest of the game.

MELT OR MAKE IT
Every wet zone you slide through shrinks you. Every duck, drain grate, sponge and comb you clip takes a bite out of you. Cross the finish line too small and you do not qualify. Hit zero and you are gone entirely, swirling away like last week's lather.

WATCH YOUR FACE
Your soap tells you how it is going before the meter does. Calm lavender turns to worried yellow, then panicked orange, then a red bar of soap that is one puddle away from the end.

TEN HAND-TUNED LEVELS
The channel narrows, the current speeds up, and the qualifying size creeps higher every level. Light Rain is gentle. Drain's Edge is not. Three stars needs almost all of you intact.

GRAB WHAT YOU CAN
Soap slivers top you back up. Bubble shields eat one hit for free. Both are placed where you have to choose between the safe line and the greedy one.

NO STRINGS
No ads. No in-app purchases. No account. No internet needed. No data collected, ever. Just a small game about a soft, doomed, extremely determined bar of soap.
```

---

## Keywords [91 / 100]

Comma separated, no spaces. Do not repeat words already in the name or subtitle,
Apple indexes those separately.

```
kawaii,cute,arcade,runner,dodge,reflex,onehand,casual,bubble,tilt,stars,offline,indie,skill
```

---

## What's New in This Version

For a first release Apple accepts a short line, or you can leave the field to
default. If you fill it:

```
First release. Ten levels, three stars each, one very anxious bar of soap.
```

---

## URLs (both required, both must resolve before you submit)

| Field | Value |
|---|---|
| Support URL | `https://YOUR_GITHUB_USERNAME.github.io/soapescape/support.html` |
| Marketing URL | Optional, leave blank |
| Privacy Policy URL | `https://YOUR_GITHUB_USERNAME.github.io/soapescape/privacy-policy.html` |

`store/support.html` and `store/privacy-policy.html` in this repo are ready to
host. See `store/README.md` for the GitHub Pages steps.

---

## App Privacy questionnaire

Answer: **Data Not Collected.**

That is accurate and worth protecting. The justification, if Apple ever queries it:

- The only persistence is `user://save.cfg`, written by `autoloads/SaveData.gd`.
  It stores star counts, level completion flags, and two boolean UI flags. It
  never leaves the device.
- There is no networking code anywhere in the project.
- No analytics, no crash reporting, no advertising SDK, no third-party SDK of any
  kind is linked.
- No account, no login, no user identifier is generated.

If you later add ads, analytics or an IAP, this answer must change before that
build ships.

---

## Age rating questionnaire

Answer **None** or **No** to every question. The result is **4+**.

The only judgement call is the fail state, where the soap dissolves. It is not
violence, gore, or horror, it is a bar of soap getting smaller. Answer None to
"Realistic Violence", "Cartoon or Fantasy Violence" and "Horror/Fear Themes".

Other answers:
- Unrestricted web access: No
- Gambling: No
- Contests: No
- User generated content: No
- Messaging or social features: No

---

## Export compliance

The game uses no encryption. To stop App Store Connect asking on every upload,
add this to `application/additional_plist_content` in the iOS export preset:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Then the answer in App Store Connect is **No** to "Does your app use encryption?".

---

## Notes for the App Review team

Paste into "Notes" in the submission form. Reviewers reject games they cannot
figure out how to play, so state the controls plainly.

```
No account, login or internet connection is required. The game is playable
immediately from the home screen.

CONTROLS: tap and hold the left half of the screen to lean left, the right half
to lean right. Release to straighten. The soap moves forward on its own. An
in-game tutorial appears automatically on the first three levels.

OBJECTIVE: reach the checkered finish line with your soap above the minimum size
shown in the bottom meter. Blue "wet zone" areas shrink the soap continuously.
Contact with obstacles removes a chunk of it.

Levels 2 through 10 unlock in sequence as each previous level is completed.

There are no ads, no in-app purchases, and no data collection of any kind.
```

---

## Attachments checklist

- [ ] App icon 1024x1024, sRGB PNG, no alpha channel, no rounded corners.
      Source file is `SoapEscape_AppIcon_1024.png` in the repo root.
- [ ] iPhone 6.9" screenshots, 1320 x 2868. See `store/screenshots.md`.
- [ ] App preview video: optional, skip for v1.0.
