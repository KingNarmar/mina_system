# M.I.N.A System — Windows Release Readiness

Issue: #58 — Windows Release Readiness master document

Parent epic: #11 — Windows Release Readiness

Last updated: 2026-07-18

Document status: Active release-readiness record

## 1. Purpose

This document is the canonical checklist and evidence record for preparing M.I.N.A System for a reliable Windows release.

It separates:

- checks already supported by recorded evidence;
- functional tests that still require real Windows execution;
- items blocked by Microsoft Store certification or public availability;
- known limitations that must remain visible in release notes and support content.

This document does not authorize a Microsoft Store submission change, Production release, public download activation, or merge to `main`.

## 2. Release governance

The following rules apply throughout Windows release-readiness work:

- Do not change or replace the current Microsoft Store submission while it is in certification unless a certification failure requires a reviewed fix.
- Do not publish a Production release without explicit approval.
- Do not activate a public Store link without an official Microsoft URL and explicit approval.
- Do not mark a runtime test as passed unless it was actually executed on Windows and evidence was recorded.
- Windows App Certification Kit results do not replace functional testing on a real Windows installation.
- GitHub Actions results do not replace clean-machine, Standard User, file picker, printing, High-DPI, offline, upgrade, or uninstall testing.
- Keep production keys, service-role keys, certificates, signing passwords, `.env` files, and private customer data out of Git.
- Every implementation task uses its own branch and pull request.
- Application and website changes remain in separate repositories and pull requests.
- Do not use fake Microsoft Store, Google Play, or App Store links.

## 3. Current confirmed release state

| Item | Current state | Evidence / source |
| --- | --- | --- |
| Microsoft Partner Center status | `In certification` | Developer-provided Partner Center status on 2026-07-18 |
| Flutter application version on `main` | `1.0.0+3` | `pubspec.yaml` |
| Microsoft Store MSIX package version | `1.0.0.0` | `msix_config` added in PR #57 |
| Store package identity | `KingNarmar.M.I.N.ASystem` | PR #57 |
| Publisher display name | `King Narmar` | PR #57 |
| Architecture | Windows x64 | PR #57 |
| Current application baseline | `03ca10374f8103750fd9530752796eee17b3d4a1` | Merge commit for PR #57 |
| Public Microsoft Store URL | Not available | Website Windows button must remain disabled |
| Website status | Microsoft Store certification | Live `/mina-system` page |
| Production/public release authorized | No | Explicit approval required |

### Version mapping

The Flutter application version and Microsoft Store package version are separate values:

- Flutter source/application version: `1.0.0+3`.
- Microsoft Store four-part package version: `1.0.0.0`.

They must not be presented as the same versioning field.

## 4. Status definitions

Only the following result values should be used:

| Status | Meaning |
| --- | --- |
| `Passed — manually verified` | Executed on Windows with evidence recorded. |
| `Passed — automated/static evidence` | Build, static, package, or automated evidence exists, but it does not prove broader runtime behavior. |
| `Failed` | Executed and the expected result was not met. |
| `Blocked` | Cannot currently be executed because a required approval, URL, account, environment, package, or dependency is unavailable. |
| `Not tested` | Not yet executed or verified in the required environment. |

Never change `Not tested` or `Blocked` to `Passed` without actual evidence.

## 5. Existing verified evidence

The following evidence was recorded in PR #57. It was not re-run as part of Issue #58.

| Check | Status | Scope limit |
| --- | --- | --- |
| `flutter pub get` | `Passed — automated/static evidence` | Dependency resolution only |
| `flutter analyze` | `Passed — automated/static evidence` | Static analysis only |
| Windows x64 Production release build | `Passed — automated/static evidence` | Buildability only |
| Windows application launch smoke test | `Passed — manually verified` | Limited launch check only |
| MSIX package creation | `Passed — automated/static evidence` | Package generation only |
| MSIX manifest identity validation | `Passed — automated/static evidence` | Manifest and identity only |
| Windows App Certification Kit | `Passed — automated/static evidence` | WACK exit code `0`; not functional coverage |

No other functional item in this document is considered passed from that evidence alone.

## 6. Pre-approval checklist

Complete these items while the Microsoft Store submission remains in certification.

| Item | Status | Tracking / notes |
| --- | --- | --- |
| Preserve current Partner Center submission | `Passed — manually verified` | No submission change in Issue #58 |
| Keep website Windows button disabled | `Passed — automated/static evidence` | Current website implementation |
| Create canonical readiness document | `Passed — automated/static evidence` | This file |
| Align release metadata and version mapping | `Not tested` | Issue #59 |
| Prepare Windows release notes | `Not tested` | Issue #60 |
| Prepare Windows Support / FAQ | `Not tested` | Issue #61 |
| Run targeted security and release static checks | `Not tested` | Issue #62 |
| Review functional test coverage | `Not tested` | Issue #63 |
| Add approved targeted automated tests | `Not tested` | Issue #64, depends on #63 |
| Execute manual Windows validation matrix | `Not tested` | Issue #65 |
| Evaluate Windows GitHub Actions validation | `Not tested` | Issue #66 |
| Localize release-relevant account/legal UI | `Not tested` | Issue #67 |
| Prepare controlled test users and data | `Not tested` | No real customer data |
| Prepare Standard User environment | `Not tested` | Required for #65 |
| Prepare Arabic/non-ASCII test files and paths | `Not tested` | Required for #65 |
| Prepare image/PDF fixtures | `Not tested` | Non-sensitive files only |
| Prepare printer or valid print target | `Not tested` | Required for printing checks |
| Confirm no fake Store URLs or placeholders | `Not tested` | Issue #62 |
| Record verified limitations before public availability | `Not tested` | Update after #62–#65 |

## 7. Post-approval checklist

Do not begin public-link activation until Microsoft certification succeeds and an official listing URL exists.

| Item | Status | Tracking / notes |
| --- | --- | --- |
| Record certification approval date | `Blocked` | Certification is still in progress |
| Confirm approved Store package version | `Blocked` | Confirm after approval |
| Copy official public Store URL | `Blocked` | No public URL yet |
| Verify public listing identity, icon, publisher, description, and version | `Blocked` | Requires approved listing |
| Install from Microsoft Store on clean Windows | `Blocked` | Requires approved distribution |
| Execute full manual Windows matrix | `Not tested` | Issue #65 |
| Record every reproducible failure as a focused issue | `Not tested` | Required before release completion |
| Update release notes with verified limitations | `Not tested` | Issue #60 |
| Update Support / FAQ with verified guidance | `Not tested` | Issue #61 |
| Verify upgrade using a later package | `Blocked` | Requires a newer package version |
| Approve website Store-link change | `Blocked` | Explicit approval required |
| Implement website link in separate repo/PR | `Blocked` | `KingNarmar/king-narmar-website#25` |
| Test official Store link before website merge | `Blocked` | Official URL required |
| Approve Production website deployment | `Blocked` | Explicit approval required |

## 8. Microsoft Store public-link activation checklist

The Windows website button must remain disabled until every gate below is satisfied.

- [ ] Microsoft certification is approved.
- [ ] The official listing is visible to the intended audience.
- [ ] The URL is copied directly from Partner Center or the official listing.
- [ ] The URL opens the correct M.I.N.A System listing.
- [ ] The listing shows publisher `King Narmar`.
- [ ] The listing shows the expected identity and approved version.
- [ ] No redirect leads to an unrelated, draft, or unavailable product.
- [ ] Explicit approval is given to activate the public link.
- [ ] A new website branch is created from latest `main`.
- [ ] The disabled button becomes an accessible external link.
- [ ] Status changes from `In certification` to `Available on Microsoft Store`.
- [ ] Android and iOS statuses remain unchanged unless separately verified.
- [ ] `npm ci`, lint, Production build, local preview, accessibility, and broken-link checks pass.
- [ ] Website PR is reviewed before merge.
- [ ] Production deployment is explicitly approved.

Related website issue: `KingNarmar/king-narmar-website#25`.

## 9. Windows environment record template

Create one environment record for each meaningful test run.

| Field | Value |
| --- | --- |
| Environment ID | `WIN-ENV-___` |
| Date | `YYYY-MM-DD` |
| Tester |  |
| Device / virtual machine |  |
| Windows edition and build |  |
| Architecture | x64 |
| Account type | Standard User / Administrator |
| Resolution |  |
| Display scaling | 100% / 125% / 150% / other |
| Installation source | Microsoft Store / controlled MSIX / approved alternative |
| Flutter version |  |
| MSIX version |  |
| Mode | Demo / Live |
| Network state | Online / offline / intermittent |
| Printer / print target |  |
| Notes |  |

Do not record passwords, tokens, production keys, or private customer data.

## 10. Manual Windows functional matrix

### 10.1 Installation and package lifecycle

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-INSTALL-001 | Clean Microsoft Store installation | Installs without missing dependencies or manual file copying | `Blocked` |
| WIN-INSTALL-002 | First launch after clean install | App opens without crash or runtime error | `Not tested` |
| WIN-INSTALL-003 | Start Menu and Apps list metadata | Correct name, icon, publisher, and version | `Not tested` |
| WIN-INSTALL-004 | Standard User installation | Follows supported Store behavior without unsupported elevation | `Blocked` |
| WIN-INSTALL-005 | Reinstall same version | Reinstall succeeds or is correctly handled by package rules | `Not tested` |
| WIN-INSTALL-006 | Upgrade from earlier version | Expected user/session/data behavior is preserved | `Blocked` |
| WIN-INSTALL-007 | Uninstall | Package is removed through normal Windows flow | `Not tested` |
| WIN-INSTALL-008 | Reinstall after uninstall | App installs and launches from the actual resulting state | `Not tested` |
| WIN-INSTALL-009 | Installed package identity | Identity matches `KingNarmar.M.I.N.ASystem` | `Not tested` |

### 10.2 Launch and desktop behavior

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-LAUNCH-001 | Normal launch | Main entry flow appears without crash | `Passed — manually verified` |
| WIN-LAUNCH-002 | Repeated open/close | No progressive crash or duplicate-process issue | `Not tested` |
| WIN-LAUNCH-003 | Launch after Windows restart | Opens normally | `Not tested` |
| WIN-LAUNCH-004 | Resize window | Responsive/adaptive layout remains usable | `Not tested` |
| WIN-LAUNCH-005 | Minimize and restore | State remains usable | `Not tested` |
| WIN-LAUNCH-006 | Lock/sleep and resume | No crash; refresh behavior remains correct | `Not tested` |
| WIN-LAUNCH-007 | Keyboard navigation | Primary controls are reachable in logical order | `Not tested` |
| WIN-LAUNCH-008 | Mouse interaction | Menus, dialogs, forms, signature, and file pickers work | `Not tested` |

The `WIN-LAUNCH-001` status is limited to the launch smoke test recorded in PR #57.

### 10.3 Login, logout, session, and password reset

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-AUTH-001 | Valid login | Authorized company flow opens | `Not tested` |
| WIN-AUTH-002 | Invalid login | Clear localized error; no session created | `Not tested` |
| WIN-AUTH-003 | Logout | Session ends and correct auth/welcome flow appears | `Not tested` |
| WIN-AUTH-004 | Close/reopen while authenticated | Intended session persistence works securely | `Not tested` |
| WIN-AUTH-005 | Session refresh/expiry | Refresh succeeds or user is safely returned to login | `Not tested` |
| WIN-AUTH-006 | Password reset request | Recovery email is sent through configured flow | `Not tested` |
| WIN-AUTH-007 | Open reset link on Windows | Hosted recovery page opens correctly | `Not tested` |
| WIN-AUTH-008 | Complete password reset | New password works; old password is rejected | `Not tested` |
| WIN-AUTH-009 | Invalid/expired reset link | Clear safe error appears | `Not tested` |
| WIN-AUTH-010 | Protected route while logged out | Access is denied and auth flow appears | `Not tested` |

### 10.4 Company access, tenant isolation, and roles

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-TENANT-001 | User with one company | Correct workspace loads | `Not tested` |
| WIN-TENANT-002 | User with multiple companies | Selection/switching works without mixed data | `Not tested` |
| WIN-TENANT-003 | User without company access | Current access-required/support flow appears | `Not tested` |
| WIN-TENANT-004 | Inactive member | Company operational data is inaccessible | `Not tested` |
| WIN-TENANT-005 | Cross-company access attempt | Access is denied | `Not tested` |
| WIN-TENANT-006 | Viewer | Read-only behavior is preserved | `Not tested` |
| WIN-TENANT-007 | Warehouse User | Operational permissions and restrictions are correct | `Not tested` |
| WIN-TENANT-008 | Manager/Admin/Owner | Role hierarchy and management actions are correct | `Not tested` |

Any tenant-isolation failure is release-critical.

### 10.5 Demo Mode

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-DEMO-001 | Enter Demo Mode | Opens without live authentication | `Not tested` |
| WIN-DEMO-002 | Initial seed data | Realistic local workers, tools, transactions, and dashboard data appear | `Not tested` |
| WIN-DEMO-003 | Restart persistence | Supported demo changes persist after restart | `Not tested` |
| WIN-DEMO-004 | Add/edit worker | Stored locally and shown correctly | `Not tested` |
| WIN-DEMO-005 | Add/edit tool | Stored locally and shown correctly | `Not tested` |
| WIN-DEMO-006 | Issue transaction | Demo workers/tools load and custody increases | `Not tested` |
| WIN-DEMO-007 | Return transaction | Return respects custody and reduces balance | `Not tested` |
| WIN-DEMO-008 | Lost/damaged approval | Approval and settlement states behave as designed | `Not tested` |
| WIN-DEMO-009 | Demo limits | Limits are enforced with a clear message | `Not tested` |
| WIN-DEMO-010 | Demo report/signature | Preview and saved signed report flow work | `Not tested` |
| WIN-DEMO-011 | Exit Demo | Returns to welcome flow without live session | `Not tested` |
| WIN-DEMO-012 | Offline Demo Mode | Supported local operations remain usable | `Not tested` |

`WIN-DEMO-006` is the manual regression target for PR #53.

### 10.6 Workers

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-WORKER-001 | Load/search/filter workers | Correct company-scoped records appear | `Not tested` |
| WIN-WORKER-002 | Add valid worker | Created through approved flow | `Not tested` |
| WIN-WORKER-003 | Required fields | Invalid submission is blocked clearly | `Not tested` |
| WIN-WORKER-004 | Duplicate identifiers | Duplicate is handled safely | `Not tested` |
| WIN-WORKER-005 | Edit worker | Allowed fields update correctly | `Not tested` |
| WIN-WORKER-006 | Deactivate/reactivate | Lifecycle changes correctly | `Not tested` |
| WIN-WORKER-007 | Worker custody view | Open custody remains accurate | `Not tested` |
| WIN-WORKER-008 | Unauthorized mutation | UI and backend deny the action | `Not tested` |

### 10.7 Tools

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-TOOL-001 | Load/search/filter tools | Correct company-scoped records appear | `Not tested` |
| WIN-TOOL-002 | Add valid tool | Created through approved flow | `Not tested` |
| WIN-TOOL-003 | Required fields | Invalid submission is blocked clearly | `Not tested` |
| WIN-TOOL-004 | Duplicate identifiers | Duplicate is handled safely | `Not tested` |
| WIN-TOOL-005 | Edit tool | Allowed fields update correctly | `Not tested` |
| WIN-TOOL-006 | Deactivate/reactivate | Lifecycle changes correctly | `Not tested` |
| WIN-TOOL-007 | Availability/custody view | Values remain accurate | `Not tested` |
| WIN-TOOL-008 | Unauthorized mutation | UI and backend deny the action | `Not tested` |

### 10.8 Transactions, types, approvals, search, and filters

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-TRX-001 | Load/search/filter transactions | Correct company-scoped records and filter results | `Not tested` |
| WIN-TRX-002 | Issue transaction | Custody increases correctly | `Not tested` |
| WIN-TRX-003 | Return transaction | Cannot exceed custody; balance decreases correctly | `Not tested` |
| WIN-TRX-004 | Invalid/zero/negative quantity | Submission is blocked clearly | `Not tested` |
| WIN-TRX-005 | Lost transaction | Approval-required workflow is created correctly | `Not tested` |
| WIN-TRX-006 | Damaged transaction | Approval-required workflow is created correctly | `Not tested` |
| WIN-TRX-007 | Upload approval document | Authorized user can attach supported document | `Not tested` |
| WIN-TRX-008 | Approve | Authorized decision updates workflow correctly | `Not tested` |
| WIN-TRX-009 | Reject | Authorized decision updates workflow correctly | `Not tested` |
| WIN-TRX-010 | Settle approved loss/damage | Settlement/accountability update correctly | `Not tested` |
| WIN-TRX-011 | Unauthorized approval | UI and backend deny the action | `Not tested` |
| WIN-TRX-012 | Custody balance views | Balances match completed history | `Not tested` |
| WIN-TRX-013 | Restart after transaction | Transaction and balances remain available | `Not tested` |
| WIN-TRX-014 | Live update from another device | Data appears after realtime/resume refresh | `Not tested` |

### 10.9 Photos, files, PDF/image attachments

Use only safe, non-sensitive fixtures.

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-FILE-001 | Select supported image | Picker opens and image can be attached | `Not tested` |
| WIN-FILE-002 | Select supported PDF | Picker opens and PDF can be attached where supported | `Not tested` |
| WIN-FILE-003 | Cancel picker | Returns safely without stale attachment | `Not tested` |
| WIN-FILE-004 | Unsupported file type | Clear rejection without crash | `Not tested` |
| WIN-FILE-005 | Missing/deleted local file | Failure handled safely | `Not tested` |
| WIN-FILE-006 | Representative large file | Stable processing; actual size recorded | `Not tested` |
| WIN-FILE-007 | Network loss during upload | No false success; recoverable failure | `Not tested` |
| WIN-FILE-008 | Retry after reconnect | Retry succeeds safely | `Not tested` |
| WIN-FILE-009 | Company-scoped storage path | Object remains in authorized company scope | `Not tested` |
| WIN-FILE-010 | Unauthorized file access | Cross-company/inactive access is denied | `Not tested` |

### 10.10 Arabic filenames and non-ASCII paths

Suggested fixtures:

- `تقرير عهدة.pdf`
- `صورة أداة.png`
- `اختبار رقم ١.jpg`
- A Windows directory or user-profile path containing non-ASCII characters.

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-I18N-001 | Select Arabic PDF | Filename displays correctly | `Not tested` |
| WIN-I18N-002 | Select Arabic image | Filename displays correctly | `Not tested` |
| WIN-I18N-003 | Upload Arabic attachment | Succeeds or fails with a clear recoverable error | `Not tested` |
| WIN-I18N-004 | Save PDF to Arabic directory | Saves and reopens correctly | `Not tested` |
| WIN-I18N-005 | Non-ASCII Windows path | Launch and file operations remain stable | `Not tested` |
| WIN-I18N-006 | Print Arabic content | Arabic renders correctly in output | `Not tested` |

### 10.11 Mouse signature

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-SIGN-001 | Draw with mouse | Smooth, correctly aligned strokes | `Not tested` |
| WIN-SIGN-002 | Clear signature | Canvas resets fully | `Not tested` |
| WIN-SIGN-003 | Empty signature validation | Required signature cannot be submitted empty | `Not tested` |
| WIN-SIGN-004 | Save in report | Signature appears correctly in generated document | `Not tested` |
| WIN-SIGN-005 | Resize/scaling | Canvas remains usable and state is preserved | `Not tested` |
| WIN-SIGN-006 | High-DPI pointer alignment | Pointer and stroke remain aligned | `Not tested` |

### 10.12 PDF preview, save, and print

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-PDF-001 | Open Report Builder | Controls and selectors are usable | `Not tested` |
| WIN-PDF-002 | Worker report | Preview matches selected worker and current data | `Not tested` |
| WIN-PDF-003 | Tool report | Preview matches selected tool and current data | `Not tested` |
| WIN-PDF-004 | Transaction/custody report | Preview matches selected scope | `Not tested` |
| WIN-PDF-005 | PDF preview | No blank or corrupted pages | `Not tested` |
| WIN-PDF-006 | Save PDF | File writes to selected path | `Not tested` |
| WIN-PDF-007 | Reopen saved PDF | Opens in Windows viewer | `Not tested` |
| WIN-PDF-008 | Print | Print dialog opens and output is correct | `Not tested` |
| WIN-PDF-009 | Cancel save/print | Returns safely without false success | `Not tested` |
| WIN-PDF-010 | Signed PDF | Signature and required metadata appear | `Not tested` |
| WIN-PDF-011 | Arabic PDF content | Direction, shaping, names, and filenames render correctly | `Not tested` |
| WIN-PDF-012 | Representative large report | Generation remains stable; data size recorded | `Not tested` |

### 10.13 Offline and reconnect

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-NET-001 | Launch Live Mode offline | Clear offline/retry state; no crash | `Not tested` |
| WIN-NET-002 | Lose network while viewing | Existing UI remains stable and connection state is clear | `Not tested` |
| WIN-NET-003 | Lose network during submit | No false success | `Not tested` |
| WIN-NET-004 | Reconnect | Data refreshes without app restart | `Not tested` |
| WIN-NET-005 | Resume after another-device change | Current company data refreshes | `Not tested` |
| WIN-NET-006 | Repeated disconnect/reconnect | No crash or duplicate realtime behavior | `Not tested` |
| WIN-NET-007 | Demo Mode offline | Supported local operations continue | `Not tested` |
| WIN-NET-008 | Expired session after reconnect | Refreshes or returns safely to login | `Not tested` |

### 10.14 High-DPI, resolution, and accessibility

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-DPI-001 | 100% scaling | Core layouts/dialogs usable | `Not tested` |
| WIN-DPI-002 | 125% scaling | No clipped actions or unreadable text | `Not tested` |
| WIN-DPI-003 | 150% scaling | No clipped actions or unreadable text | `Not tested` |
| WIN-DPI-004 | Small desktop window | Content adapts/scrolls; controls remain reachable | `Not tested` |
| WIN-DPI-005 | Large/high-resolution display | Layout remains balanced | `Not tested` |
| WIN-DPI-006 | English UI | Text/forms/dialogs usable | `Not tested` |
| WIN-DPI-007 | Arabic UI | RTL, wrapping, forms, and dialogs usable | `Not tested` |
| WIN-DPI-008 | Keyboard focus | Visible, logical focus state | `Not tested` |

### 10.15 Standard Windows user

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-STD-001 | Approved installation path | Works according to Store policy | `Blocked` |
| WIN-STD-002 | Launch/login | Core app opens and authenticates | `Not tested` |
| WIN-STD-003 | Demo persistence | Local demo data stores/reloads | `Not tested` |
| WIN-STD-004 | File picker | User-accessible files can be selected | `Not tested` |
| WIN-STD-005 | Save to Documents | PDF saves in permitted user directory | `Not tested` |
| WIN-STD-006 | Restricted save path | Windows denial handled without crash/false success | `Not tested` |
| WIN-STD-007 | Printing | Permitted print targets are accessible | `Not tested` |
| WIN-STD-008 | Uninstall | Normal Windows/Store removal works | `Not tested` |

### 10.16 Reinstall, upgrade, uninstall, and data behavior

| ID | Test | Expected result | Initial status |
| --- | --- | --- | --- |
| WIN-LIFE-001 | Reinstall same version | Installs and launches | `Not tested` |
| WIN-LIFE-002 | Upgrade to newer version | Supported state is preserved | `Blocked` |
| WIN-LIFE-003 | Live data after reinstall | Authorized server data returns after login | `Not tested` |
| WIN-LIFE-004 | Session after upgrade | Actual expected behavior is recorded | `Blocked` |
| WIN-LIFE-005 | Demo data after upgrade | Actual migration/persistence behavior is recorded | `Blocked` |
| WIN-LIFE-006 | Uninstall | Package is removed | `Not tested` |
| WIN-LIFE-007 | Local data after uninstall | Actual retained/removed behavior is recorded | `Not tested` |
| WIN-LIFE-008 | Reinstall after uninstall | Starts from actual resulting state | `Not tested` |

## 11. Known limitations and unresolved risks

Current limitations remain active until replaced by verified evidence:

1. Microsoft Store certification is still in progress.
2. No official public Microsoft Store URL exists.
3. Clean Microsoft Store installation has not been tested.
4. The full Windows functional matrix has not been executed.
5. WACK success does not prove authentication, storage, reporting, printing, file picker, High-DPI, offline, or tenant-isolation behavior.
6. The repository did not contain an established Flutter `test/` directory at the time of PR #57; test review is tracked in #63 and implementation in #64.
7. Arabic filenames and non-ASCII Windows paths have not been verified.
8. Mouse signature behavior has not been verified on Windows.
9. PDF preview, save, and printing have not been verified on Windows.
10. Standard Windows user behavior has not been verified.
11. Upgrade behavior cannot be verified until a later package exists.
12. No automatic in-app updater has been verified.
13. No claim is made that a separately distributed EXE or portable ZIP is Production-signed or publicly supported.
14. Release-relevant Account/Profile and legal strings require the EN/AR work tracked in #67.
15. Any failed release check requires its own focused issue and PR.

Update this list after each related readiness issue and manual test group.

## 12. Update method

The current Windows release path is Microsoft Store distribution.

Until a later decision is approved:

- Do not claim an automatic in-app updater.
- Do not add a custom update service inside the app.
- Users obtain updates through Microsoft Store mechanisms available on their Windows device.
- A later Store package is required to verify actual upgrade behavior.
- Any direct installer or portable ZIP requires a separate approved release plan, signing decision, checksums, installation testing, and public-link review.

## 13. Code signing and SmartScreen

- Do not commit signing certificates, private keys, passwords, or exported certificate bundles.
- Do not claim a non-Store installer or portable package is Production-signed unless its signature is actually verified.
- Do not present self-signed certificates as suitable for public Production distribution.
- Any future direct-distribution EXE requires a separate code-signing plan and certificate decision.
- Any future direct-download binary requires SmartScreen testing on clean Windows.
- SmartScreen behavior must be recorded from actual testing; it must not be assumed.
- Microsoft Store validation does not validate future external installer or portable ZIP paths.
- A paid certificate purchase requires explicit approval.

## 14. Security and privacy release gates

These checks are executed in detail under Issue #62:

- [ ] No service-role key exists in Flutter or public web code.
- [ ] No production secret is tracked in Git.
- [ ] No certificate or signing password is tracked in Git.
- [ ] No sensitive token or private user data is written to Production logs.
- [ ] Production URLs use HTTPS.
- [ ] Privacy Policy URL is valid.
- [ ] Account Deletion URL is valid.
- [ ] No fake Store URL exists.
- [ ] No `href="#"` placeholder exists in public release pages.
- [ ] File and storage paths remain company-scoped.
- [ ] Directly relevant RLS evidence remains consistent with tenant isolation.
- [ ] Controlled cross-company and inactive-member tests pass before Production readiness is declared.

Do not paste secret values into documents, issues, PR descriptions, logs, or screenshots.

## 15. Evidence record template

Create one record for each executed test group.

### `WIN-EVIDENCE-___`

- Date:
- Tester:
- Related test IDs:
- Environment ID:
- Branch/commit/package version:
- Execution steps:
- Actual result:
- Status: `Passed — manually verified` / `Passed — automated/static evidence` / `Failed` / `Blocked` / `Not tested`
- Screenshot, log, or artifact reference:
- Sensitive data redacted: Yes / No
- Follow-up issue, if failed:
- Notes:

Evidence describes what was actually tested, not what was expected to work.

## 16. Failure handling

When a reproducible failure is found:

1. Stop marking the affected release area as ready.
2. Record the failed test ID and environment.
3. Preserve safe evidence without exposing private data.
4. Create a dedicated GitHub issue with actual behavior, expected behavior, reproduction steps, environment, release risk, related files, and verification steps.
5. Use a dedicated branch and PR for the fix.
6. Run targeted checks and repeat the affected Windows test.
7. Do not close the defect until the fix is merged and the actual test passes.
8. Do not replace the Store submission during certification without reviewed necessity and explicit approval.

## 17. Completion criteria

Issue #58 is complete when this document is reviewed and merged.

The parent epic #11 is complete only when:

- documentation issues #58–#61 are merged;
- static release/security checks in #62 are recorded;
- localization issue #67 is resolved;
- test coverage is reviewed in #63;
- approved tests in #64 are added and passing;
- the CI decision in #66 is recorded and any approved workflow is validated;
- the manual matrix in #65 is executed with explicit results;
- release-blocking failures are resolved or explicitly accepted as documented limitations;
- Microsoft Store certification is approved;
- the official Store URL is verified;
- website issue `KingNarmar/king-narmar-website#25` is implemented and merged only after explicit approval.

## 18. Related tracking

- #11 — Epic: Windows Release Readiness.
- #58 — This readiness document.
- #59 — Release metadata and version mapping.
- #60 — Windows release notes.
- #61 — Windows Support / FAQ.
- #62 — Security and release static checks.
- #63 — Functional test coverage review.
- #64 — Targeted automated tests.
- #65 — Manual Windows validation execution.
- #66 — Windows GitHub Actions evaluation.
- #67 — Account/legal UI localization.
- #17 — Automated testing foundation.
- #44 — Password recovery.
- #45 — Production auth emails and hosted auth pages.
- #48 — Realtime refresh and reconnect on app resume.
- PR #57 — Microsoft Store MSIX configuration and recorded verification.
- `KingNarmar/king-narmar-website#25` — Post-certification Store-link activation.
