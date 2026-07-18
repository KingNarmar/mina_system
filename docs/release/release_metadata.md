# M.I.N.A System — Release Metadata

Issue: #59 — Align release metadata and version mapping

Parent epic: #11 — Windows Release Readiness

Last updated: 2026-07-18

## 1. Purpose

This document is the canonical source for confirmed M.I.N.A System product identity, public release metadata, platform version mapping, legal links, and support contacts.

It does not authorize a Production release, Microsoft Store submission change, Google Play rollout, public download activation, or website deployment.

## 2. Product identity

| Item | Confirmed value | Notes |
| --- | --- | --- |
| Public product name | M.I.N.A System | Use this form in public release and support material |
| Full name | Materials Inventory Navigation Assistant | Confirmed product expansion |
| Dart package name | `mina_system` | Internal source package identifier |
| Android application ID | `com.minasystem.app` | Existing Android identity |
| Android namespace | `com.minasystem.app` | Existing Android namespace |
| iOS bundle identifier | `com.minasystem.app` | iOS release remains future work |
| Windows executable | `mina_system.exe` | Generated Flutter Windows executable |
| Windows display name | `M.I.N.A System` | Current MSIX configuration |
| Microsoft Store identity | `KingNarmar.M.I.N.ASystem` | Assigned Partner Center identity |
| Microsoft publisher | `CN=E9CE55B8-AEDA-43A1-9E0C-43ADE997A176` | Assigned Store publisher value; not a private signing secret |
| Publisher display name | `King Narmar` | Current Store display metadata |
| Windows architecture | x64 | Current configured Store architecture |
| Windows package output name | `MINA-System-Windows-x64` | Current MSIX output name |

Public-facing material should not alternate between `Mina System` and `M.I.N.A System`. The approved public form is `M.I.N.A System`.

## 3. Current platform status

| Platform | Current confirmed status | Public-link rule |
| --- | --- | --- |
| Android | Google Play Closed Testing | Do not invent or publish a Store URL that has not been confirmed |
| Windows | Microsoft Store submission `In certification` | Keep the website button disabled until an official public listing URL exists and activation is explicitly approved |
| iOS | Coming Soon | Do not publish a placeholder App Store URL |

The source version in `pubspec.yaml` does not by itself prove which Android build is currently available in Google Play. Uploaded-track status must be confirmed separately from Play Console.

## 4. Current source and package versions

| Version field | Current value | Source / meaning |
| --- | --- | --- |
| Flutter application version | `1.0.0+3` | Current `pubspec.yaml` value on `main` |
| Flutter version name | `1.0.0` | Human-readable application version |
| Flutter build number | `3` | Android `versionCode` when used for an Android build |
| Microsoft Store MSIX version | `1.0.0.0` | Current `msix_config.msix_version` submitted for certification |

Current repository baseline at this update:

```text
e4f6d05a3850e153a117a511b0f514eb31a4101d
```

This is the squash merge commit for PR #68, which added the Windows release-readiness document.

## 5. Version mapping rules

M.I.N.A System currently uses two different version formats.

### Flutter and Android

Flutter uses:

```text
MAJOR.MINOR.PATCH+BUILD
```

Current value:

```text
1.0.0+3
```

For Android builds:

- `1.0.0` is the user-facing version name.
- `3` is the build number / Android version code.
- Every newly uploaded Android release must use a version code higher than any previously uploaded code for the same application ID.
- Changing `pubspec.yaml` does not confirm that the build was uploaded or promoted in Google Play.

### Microsoft Store MSIX

Microsoft Store packages use a four-part numeric version:

```text
MAJOR.MINOR.BUILD.REVISION
```

Current submitted value:

```text
1.0.0.0
```

Rules:

- The MSIX version is independent from the Flutter `+BUILD` value.
- `1.0.0+3` and `1.0.0.0` must not be presented as the same version field.
- Do not reuse, reduce, or replace the submitted Microsoft Store package version without confirming Partner Center requirements and reviewing the release impact.
- Do not change the current package while certification is active unless Microsoft reports a failure that requires a reviewed fix.

## 6. Windows package configuration

The current confirmed `msix_config` values are:

```yaml
display_name: M.I.N.A System
publisher_display_name: King Narmar
identity_name: KingNarmar.M.I.N.ASystem
publisher: CN=E9CE55B8-AEDA-43A1-9E0C-43ADE997A176
msix_version: 1.0.0.0
store: true
architecture: x64
build_windows: false
output_name: MINA-System-Windows-x64
```

PR #57 documented successful:

- dependency resolution;
- Flutter static analysis;
- Windows x64 Production build;
- limited application launch smoke test;
- MSIX package creation;
- package-manifest identity validation;
- Windows App Certification Kit run with exit code `0`.

These recorded checks do not replace the manual Windows functional matrix in Issue #65.

## 7. Public legal URLs

| Page | Confirmed URL |
| --- | --- |
| Privacy Policy | `https://kingnarmar.com/mina-system/privacy-policy` |
| Account Deletion | `https://kingnarmar.com/mina-system/account-deletion` |

Rules:

- Production legal URLs must use HTTPS.
- Do not replace these URLs with `href="#"`, fake Store links, or unverified placeholder pages.
- Legacy URLs may remain only where required for backward-compatible redirects; they are not the preferred public release links.

## 8. Public support contacts

| Purpose | Confirmed email |
| --- | --- |
| Product support | `support.mina-system@kingnarmar.com` |
| Privacy requests | `privacy.mina-system@kingnarmar.com` |
| Account deletion | `deletion.mina-system@kingnarmar.com` |
| General King Narmar contact | `contact@kingnarmar.com` |

Do not publish passwords, tokens, production keys, customer data, certificate passwords, or signing material through support documents or public issue evidence.

## 9. Store-description baseline

### Short description

```text
Manage workers, tools, custody transactions, approvals, attachments, and signed reports.
```

### Product description baseline

M.I.N.A System is a multi-company materials inventory and custody management solution for warehouses, workshops, maintenance teams, and industrial operations.

Confirmed product areas include:

- workers and organization records;
- tools and material records;
- issue, return, lost, and damaged transaction workflows;
- custody balances and transaction history;
- approvals and supporting documents;
- photo, image, and PDF attachments;
- worker signatures;
- reports and signed PDF output;
- Demo Mode and Live Mode separation;
- responsive mobile, tablet, and desktop layouts.

Public descriptions must remain limited to features supported by current code and recorded evidence. Do not invent pricing, subscriptions, service-level guarantees, automatic in-app updates, or platform availability.

## 10. Screenshot and marketing-data rules

- Use demo data only.
- Do not expose real worker, company, customer, authentication, or operational data.
- Show populated real workflows rather than misleading empty-state mockups.
- Use platform-appropriate device frames.
- Keep Android, Windows, and iOS status text accurate at the time the material is published.

## 11. Related release documents

- `WINDOWS_RELEASE_READINESS.md` — canonical Windows checklist and evidence model.
- Issue #60 — Microsoft Store release notes.
- Issue #61 — Windows Support / FAQ.
- Issue #62 — targeted security and release static checks.
- Issue #65 — manual Windows validation matrix execution.
- `KingNarmar/king-narmar-website#25` — official Store-link activation after certification approval.

## 12. Release controls

- No direct push to `main`.
- Every release task uses a dedicated branch and PR.
- No Production release or public Store-link activation without explicit approval.
- Application and website changes remain in separate repositories and PRs.
- Do not commit `.env` files, production secrets, service-role keys, certificates, keystores, or signing passwords.
- Do not claim a runtime test passed unless it was actually executed and recorded.

## 13. Current decision

The current confirmed Windows state is:

- Flutter source version: `1.0.0+3`.
- Microsoft Store package version: `1.0.0.0`.
- Microsoft Store status: `In certification`.
- Public Microsoft Store URL: not available.
- Website Windows button: must remain disabled.

Any later certification result, approved package update, official Store URL, or platform release status must be recorded through a new reviewed change rather than silently editing historical evidence.
