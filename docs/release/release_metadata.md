# Mina System Release Metadata

Issue: #22 — Prepare product branding, app versioning, and release metadata  
Related release checklist: Issue #12 — Prepare Google Play release checklist  
Last updated: 2026-06-06

## Current Scope

This document captures the release metadata decisions for Mina System before and during platform-specific release checklist work.

Current target product positioning:

- Windows Desktop: administration, reporting, and settings.
- Android: mobile warehouse operations, signatures, photos, and warehouse execution workflows.
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
| Public support email | support.mina-system@kingnarmar.com | Confirmed for Mina System release docs |
| Privacy email | privacy.mina-system@kingnarmar.com | Confirmed for Mina System release docs |
| Account deletion email | deletion.mina-system@kingnarmar.com | Confirmed for Mina System release docs |
| King Narmar general contact | contact@kingnarmar.com | Confirmed for brand/business contact |
| Logo direction | Approved generated Mina System logo concept | Confirmed |
| App icon implementation | Android launcher icons prepared; final cross-platform asset pass may continue | Partially complete |

## Public Legal URLs

| Page | URL | Status |
| --- | --- | --- |
| Privacy Policy | https://kingnarmar.com/mina-system/privacy-policy | Prepared on King Narmar domain |
| Account Deletion | https://kingnarmar.com/mina-system/account-deletion | Prepared on King Narmar domain |

Legacy GitHub Pages legal URLs should not be used as the final Google Play URLs. They may remain temporarily as moved/redirect pages for backward compatibility with older app builds or previously shared links.

## Logo Direction

Approved direction:

- Modern B2B software logo.
- Dark navy / blue / teal palette.
- Stylized `M` mark.
- Inventory/tool/accountability/navigation symbolism.
- Full logo includes `Mina System` and the subtitle `Materials Inventory Navigation Assistant`.

Implementation still required / follow-up:

- Prepare clean full logo asset for documentation/marketing.
- Keep square app icon mark without long subtitle text.
- Prepare Windows `.ico` asset if not already finalized.
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
- Added Android product identity for Google Play release preparation.
- Added legal/account actions in the in-app Account/Profile Panel.
- Added Privacy Policy and Account Deletion links on the King Narmar domain.

### Improved
- Improved mobile account access through Account Panel.
- Improved release legal/contact metadata.

### Fixed
- Fixed offline banner visibility for users with multiple companies.
- Fixed legacy logout redirect from company selection.

### Notes
- No Ads, AdMob, Analytics, or Crashlytics are included in the current scope.
- Google Play release checklist continues under Issue #12.
```

## Changelog Structure

Recommended file to add later:

```text
CHANGELOG.md
```

Recommended structure:

```markdown
# Changelog

## [1.0.0+1] - 2026-06-06

### Added
- Initial Mina System Android release metadata.
- Android package ID configured as com.minasystem.app.
- In-app Account/Profile Panel legal entry points.
- King Narmar domain legal pages.

### Improved
- Mobile release checklist documentation.

### Fixed
- Offline banner visibility for multiple-company users.
- Legacy logout redirect from company selection.
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
9. Account/Profile Panel showing Privacy Policy and Request Account Deletion actions.

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

Confirmed public Mina System contacts:

- Support email: `support.mina-system@kingnarmar.com`
- Privacy email: `privacy.mina-system@kingnarmar.com`
- Account deletion email: `deletion.mina-system@kingnarmar.com`
- General King Narmar contact: `contact@kingnarmar.com`

Confirmed public legal pages:

- Privacy Policy: `https://kingnarmar.com/mina-system/privacy-policy`
- Account Deletion: `https://kingnarmar.com/mina-system/account-deletion`

Pending items before final production/store release:

- Rebuild final signed Android AAB after release checklist changes.
- Re-run final APK/AAB permission review.
- Prepare final screenshots using demo data only.
- Prepare or confirm Google Play demo/review account.
- Finalize Play Console Data Safety answers.
- Finalize production Supabase readiness and storage bucket policies.

## Current Decision

Issue #22 can remain open only for broader product branding/icon/domain follow-ups if needed.

Issue #12 is now the active release checklist source for Android Google Play preparation and final submission readiness.
