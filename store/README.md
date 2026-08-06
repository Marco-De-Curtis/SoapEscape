# App Store submission kit — Soap Escape

Everything needed for the App Store Connect listing lives in this folder. None of
it is packaged into the game: the iOS export preset's `exclude_filter` drops
`_*.gd`, and the rest are Markdown and HTML that Godot does not import.

| File | What it is |
|---|---|
| `metadata.md` | Every App Store Connect text field, ready to paste |
| `screenshots.md` | Size spec, shot list, and three ways to capture them |
| `privacy-policy.html` | Hostable privacy policy page (URL is mandatory) |
| `support.html` | Hostable support page (URL is mandatory) |
| `_screenshot_helper.gd` | Dev tool for capturing full-resolution frames |
| `BUILD_WITHOUT_A_MAC.md` | How to build and ship iOS without owning a Mac |

---

## Placeholders to replace

Search this folder for these before submitting. All of them are decisions only
you can make.

| Placeholder | Where | Notes |
|---|---|---|
| `YOUR_COMPANY` | `metadata.md`, `export_presets.cfg` | The reverse-DNS bundle identifier. **Permanent once used.** Lowercase, no spaces |
| `YOUR_LEGAL_NAME` | `metadata.md`, both HTML pages, `LICENSE` | Name shown as copyright holder |
| `YOUR_SUPPORT_EMAIL` | both HTML pages | Consider a dedicated address rather than a personal one, it goes on a public page |
| `YOUR_GITHUB_USERNAME` | `metadata.md` | Only if hosting the pages on GitHub Pages |

---

## Hosting the two required pages

Apple will not accept a submission without a working Support URL and Privacy
Policy URL. Both must resolve publicly before you submit. The cheapest route:

1. Create a public repository, for example `soapescape-site`.
2. Copy `privacy-policy.html` and `support.html` into it.
3. Settings > Pages > Source: `main`, folder `/ (root)`. Save.
4. Wait a minute, then confirm both URLs load:
   - `https://YOUR_GITHUB_USERNAME.github.io/soapescape-site/support.html`
   - `https://YOUR_GITHUB_USERNAME.github.io/soapescape-site/privacy-policy.html`
5. Paste those URLs into App Store Connect.

The pages are self-contained. No build step, no dependencies, no external
requests.

---

## Still outstanding in the repo

The listing material is done. These code and config items are not, and each will
stop a submission:

- [ ] Real bundle identifier in `export_presets.cfg:41` (currently
      `com.yourcompany.soapescape`)
- [ ] `application/app_store_team_id` is empty
- [x] ~~Icon slots empty~~ done: wired to `SoapEscape_AppIcon_1024.png`
- [x] ~~`ITSAppUsesNonExemptEncryption` not set~~ done
- [x] ~~Launch screen was dark teal~~ done: now `#fdf2f8`, matching the app
- [x] ~~No LICENSE file or asset attribution~~ done: `LICENSE` and
      `THIRD_PARTY_NOTICES.md` added at the repo root

---

## Submission checklist

**Account and setup**
- [ ] Apple Developer Program membership active
- [ ] Bundle ID registered at developer.apple.com
- [ ] App Store Connect API key created and the `.p8` stored safely
- [ ] App record created in App Store Connect

**Build**
- [ ] Repo blockers above resolved
- [ ] Built with Xcode 26 or later against the iOS 26 SDK (mandatory since
      28 April 2026)
- [ ] Build uploaded and processed in TestFlight
- [ ] All ten levels played through on a real iPhone

**Listing**
- [ ] Name, subtitle, description, keywords, promo text from `metadata.md`
- [ ] Support and Privacy URLs live and loading
- [ ] Icon 1024x1024, no alpha
- [ ] At least three 6.9" screenshots at exactly 1320 x 2868
- [ ] Categories set: Arcade primary, Casual secondary
- [ ] Age rating questionnaire completed (result should be 4+)
- [ ] App Privacy set to Data Not Collected
- [ ] Export compliance answered
- [ ] Review notes pasted, including the control explanation

**Submit**
- [ ] Pricing set to Free
- [ ] Availability set (all territories, or a subset)
- [ ] Release option chosen: manual release is safer for a first launch
- [ ] Submit for review
