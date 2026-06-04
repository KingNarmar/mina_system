# Mina System Release Metadata

Issue: #22 — Prepare product branding, app versioning, and release metadata

Last updated: 2026-06-04

## Current Scope

This document captures the release metadata decisions for Mina System before moving to platform-specific release checklists.

Current target product positioning:

- Windows Desktop: administration, reporting, and settings.
- Android: mobile warehouse operations, signatures, and photos.
- iOS: preparation only for now through bundle identifier/configuration; real builds require macOS/Xcode later.

## Product Identity

| Item | Decision | Status |
| --- | --- | --- |
| Product name | Mina System | Confirmed |
| Meaning | Materials Inventory Navigation Assistant | Confirmed |
| Dart package name | mina_system | Confirmed |
| Android application ID | com.minasystem.app | Confirmed |
| Android namespace | com.minasystem.app | Confirmed |
| iOS bundle identifier | com.minasystem.app | Confirmed |
| iOS test bundle identifier | com.minasystem.app.RunnerTests | Confirmed |
| Windows display/product name | Mina System | Confirmed |
| Windows executable filename | mina_system.exe | Confirmed for now |
| Temporary support email | megamarkter@gmail.com | Confirmed temporarily |
| Final support email | Pending business domain decision, recommended: support@minasystem.app | Pending |
| Logo direction | Approved generated Mina System logo concept | Confirmed |
| App icon implementation | Generate platform-specific icons from approved logo direction | Pending implementation |

## Logo Direction

Approved direction:

- Modern B2B software logo.
- Dark navy / blue / teal palette.
- Stylized `M` mark.
- Inventory/tool/accountability/navigation symbolism.
- Full logo includes `Mina System` and the subtitle `Materials Inventory Navigation Assistant`.

Implementation still required:

- Prepare clean full logo asset for documentation/marketing.
- Prepare square app icon mark without long subtitle text.
- Generate Android launcher icons.
- Generate Windows `.ico` asset.
- Prepare iOS app icon assets later when iOS build setup continues.

## Versioning Strategy

Mina System uses Flutter's standard version format:

```text
MAJOR.MINOR.PATCH+BUILD
```

Examples:

```text
1.0.0+1
1.0.1+2
1.1.0+3
2.0.0+4
```

Rules:

- `MAJOR`: major release or breaking product/business change.
- `MINOR`: new user-facing feature or important workflow expansion.
- `PATCH`: bug fix, UI improvement, stability fix, or small enhancement.
- `BUILD`: increases with every distributed release build.

Current version:

```text
1.0.0+1
```

This is acceptable as the first internal/product identity validation build. Before Google Play or production distribution, the build number must be increased if another APK/AAB has already been distributed with the same version code.

## Build Number Strategy

The build number must increase monotonically for Android release builds.

Recommended examples:

```text
1.0.0+1  first internal build
1.0.0+2  second internal build
1.0.1+3  bug-fix build
1.1.0+4  feature build
```

Notes:

- Android uses the part after `+` as `versionCode`.
- Google Play does not accept a lower or repeated `versionCode` for the same app.
- The human-readable version before `+` should only change when the release meaning changes.

## Release Notes Format

Recommended format:

```markdown
## Mina System v1.0.0+1

### Added
- Added cross-platform product identity for Windows, Android, and iOS preparation.
- Added Android application ID: com.minasystem.app.
- Added iOS bundle identifier preparation: com.minasystem.app.

### Improved
- Improved mobile signed PDF save flow.
- Improved mobile signature dialog layout.

### Fixed
- Fixed mobile signed PDF save flow causing duplicate GlobalKey errors.
- Fixed mobile signature action button layout.

### Notes
- Android release signing is not configured yet.
- Google Play release checklist will continue under Issue #12.
```

## Changelog Structure

Recommended file to add later:

```text
CHANGELOG.md
```

Recommended structure:

```markdown
# Changelog

## [1.0.0+1] - 2026-06-04

### Added
- Initial Mina System product branding.
- Android package ID configured as com.minasystem.app.
- iOS bundle identifier configured as com.minasystem.app.

### Improved
- Mobile signed PDF flow.

### Fixed
- Signature dialog layout on compact screens.
- Duplicate GlobalKey issue during mobile signed PDF save.
```

## Screenshot Style

Recommended screenshots for Google Play / marketing preparation:

1. Login / welcome screen.
2. Dashboard.
3. Workers management.
4. Tools management.
5. Transactions flow.
6. Worker custody report.
7. Signature capture.
8. Signed PDF confirmation/report.

Style rules:

- Use clean business screenshots.
- Use demo data only.
- Do not show real personal, company, or customer data.
- Use a demo company name.
- Use demo workers, tools, and transactions.
- Show real workflows, not empty screens.
- Use Android phone frames for Google Play screenshots.
- Use desktop screenshots later for website/Windows release material.

## Store Short Description

Draft:

```text
Manage tools, inventory custody, workers, transactions, and signed reports.
```

## Store Full Description

Draft:

```text
Mina System is a cross-platform materials inventory and custody management solution designed for warehouses, workshops, maintenance teams, and industrial operations.

The system helps companies manage workers, tools, custody transactions, returns, signed PDF reports, and accountability records from one organized platform.

Key features:
- Manage workers, departments, and job titles.
- Manage tools and units.
- Issue and return tools with clear transaction history.
- Capture worker signatures on mobile devices.
- Generate signed PDF custody reports.
- Track accountability and open custody balances.
- Support warehouse and operations teams with organized reporting.

Mina System is designed for businesses that need a practical, professional, and auditable way to manage tool custody and material accountability across teams.
```

## Legal / Support Metadata

Confirmed temporary item:

- Temporary support email: `megamarkter@gmail.com`.

Pending items before final production/store release:

- Replace temporary support email with a final business/domain email when available.
- Prepare final app icon assets across Android, Windows, and future iOS.
- Confirm whether a public website/domain will exist before store submission.
- Confirm whether a privacy policy URL will be prepared under Issue #12 or a separate legal/compliance issue.

## Current Decision

Issue #22 should remain open until the pending app icon implementation and final support/domain decisions are finalized.

The next recommended step after this document update:

1. Add a progress comment to Issue #22.
2. Keep Issue #22 open.
3. Continue with platform-specific app icon implementation from the approved logo direction.
4. Move to Issue #12 only after deciding whether #22 is complete enough to close or should remain blocked by final business/domain decisions.
