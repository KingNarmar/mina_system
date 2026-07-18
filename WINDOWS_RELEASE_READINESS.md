# M.I.N.A System — Windows Release Readiness

Issue: #58 — Windows Release Readiness master document  
Parent epic: #11 — Windows Release Readiness  
Last updated: 2026-07-18  
Document status: Active release-readiness record

## 1. Purpose

This document is the canonical checklist and evidence record for preparing M.I.N.A System for a reliable Windows release.

It separates:

- work that has been verified through recorded build or static evidence;
- work that still requires manual Windows execution;
- work blocked by Microsoft Store certification or public availability;
- known limitations that must remain visible in release notes and support content.

This document does not authorize a Microsoft Store submission change, Production release, public download activation, or merge to `main`.

## 2. Release governance

The following rules apply throughout Windows release-readiness work:

- Do not change or replace the current Microsoft Store submission while it is in certification unless a certification failure requires a reviewed fix.
- Do not publish a Production release without explicit approval.
- Do not activate a public Store link without an official Microsoft URL and explicit approval.
- Do not mark a runtime test as passed unless it was actually executed on Windows and evidence was recorded.
- Windows App Certification Kit results do not replace functional testing on a real Windows installation.
- GitHub Actions results do not replace clean-machine, Standard User, file picker, printing, High-DPI, offline, or upgrade testing.
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
| Current application repository baseline | `03ca10374f8103750fd9530752796eee17b3d4a1` | Merge commit for PR #57 |
| Public Microsoft Store URL | Not available | Windows website button must remain disabled |
| Website status | Microsoft Store certification | Live `/mina-system` page |
| Production/public release authorized | No | Requires explicit approval |

### Version mapping note

The Flutter application version and Microsoft Store package version are separate values:

- Flutter source/application version: `1.0.0+3`.
- Microsoft Store four-part package version: `1.0.0.0`.

They must not be presented as the same versioning field. Any future package version change must follow Microsoft Store version rules and must not reuse or reduce an already submitted package version.

## 4. Status definitions

Only the following result values should be used in this document:

| Status | Meaning |
| --- | --- |
| `Passed — manually verified` | The behavior was executed on Windows and evidence was recorded. |
| `Passed — automated/static evidence` | A build, static check, package check, or automated test passed, but this does not prove broader runtime behavior. |
| `Failed` | The test was executed and did not meet the expected result. |
| `Blocked` | The test cannot currently be executed because a required approval, URL, account, environment, package, or dependency is unavailable. |
| `Not tested` | The behavior has not yet been executed or verified in the required environment. |

A test must never be upgraded from `Not tested` or `Blocked` to `Passed` without actual evidence.

## 5. Confirmed evidence already available

The following evidence was recorded in PR #57. It has not been re-run as part of Issue #58.

| Check | Status | Evidence | Scope limit |
| --- | --- | --- | --- |
| `flutter pub get` | `Passed — automated/static evidence` | PR #57 verification | Dependency resolution only |
| `flutter analyze` | `Passed — automated/static evidence` | PR #57 verification | Static analysis only |
| Windows x64 Production release build | `Passed — automated/static evidence` | PR #57 verification | Buildability only |
| Windows application launch smoke test | `Passed — manually verified` | PR #57 verification | Launch only; not full functional coverage |
| MSIX package creation | `Passed — automated/static evidence` | PR #57 verification | Package generation only |
| MSIX manifest identity validation | `Passed — automated/static evidence` | PR #57 verification | Identity and manifest only |
| Windows App Certification Kit | `Passed — automated/static evidence` | PR #57, exit code `0` | Certification-kit checks only |

No other functional test in this document should be considered passed based only on the evidence above.

## 6. Pre-approval checklist

Complete these items while the Microsoft Store submission remains in certification.

| Item | Status | Evidence / notes |
| --- | --- | --- |
| Preserve the current Partner Center submission without replacement | `Passed — manually verified` | Submission remains `In certification`; no change made in this issue |
| Keep the website Windows button disabled | `Passed — automated/static evidence` | Current website implementation uses a disabled button |
| Confirm no fake Microsoft Store URL exists | `Not tested` | Tracked under Issue #62 |
| Create this canonical readiness document | `Passed — automated/static evidence` | `WINDOWS_RELEASE_READINESS.md` |
| Align release metadata and version mapping | `Not tested` | Issue #59 |
| Prepare Windows release notes | `Not tested` | Issue #60 |
| Prepare Windows Support / FAQ content | `Not tested` | Issue #61 |
| Run targeted security and release static checks | `Not tested` | Issue #62 |
| Review functional test coverage and gaps | `Not tested` | Issue #63 |
| Add approved targeted automated tests | `Not tested` | Issue #64, depends on #63 |
| Localize release-relevant account/legal UI strings | `Not tested` | Issue #67 |
| Decide whether Windows GitHub Actions adds value | `Not tested` | Issue #66, normally after #63 and #64 |
| Prepare manual Windows test data and controlled accounts | `Not tested` | Must not use real customer data |
| Prepare a Standard Windows user test account | `Not tested` | Required for Issue #65 |
| Prepare Arabic filenames and non-ASCII path fixtures | `Not tested` | Required for Issue #65 |
| Prepare image and PDF attachment fixtures | `Not tested` | Use safe non-sensitive files |
| Prepare a printer or valid Windows print target | `Not tested` | Required for print validation |
| Record known limitations before public availability | `Not tested` | Update after Issues #62–#65 |

## 7. Post-approval checklist

Do not begin public-link activation until Microsoft certification succeeds and an official listing URL exists.

| Item | Status | Evidence / notes |
| --- | --- | --- |
| Record Microsoft certification approval date | `Blocked` | Certification is still in progress |
| Record the approved Store package version | `Blocked` | Confirm after approval |
| Copy the official public Store URL from Partner Center/listing | `Blocked` | No public URL yet |
| Verify the public Store listing title, publisher, icon, description, and version | `Blocked` | Requires approved public listing |
| Install the app from the Microsoft Store on a clean Windows environment | `Blocked` | Requires public/private approved distribution path |
| Execute the complete manual Windows validation matrix | `Not tested` | Issue #65 |
| Record all failures as separate focused issues | `Not tested` | Required before release completion |
| Update release notes with verified limitations | `Not tested` | Issue #60 and test results |
| Update Support / FAQ with verified installation guidance | `Not tested` | Issue #61 and test results |
| Verify Store update behavior using a later approved package when available | `Blocked` | Requires a newer test/release package |
| Approve the website Store-link change | `Blocked` | Explicit approval required |
| Implement website Store-link activation in its own branch and PR | `Blocked` | `KingNarmar/king-narmar-website#25` |
| Test the official Store link before website merge | `Blocked` | Official URL required |
| Approve Production website deployment | `Blocked` | Explicit approval required |

## 8. Microsoft Store public-link activation checklist

The website Windows button must remain disabled until every required gate below is satisfied.

- [ ] Microsoft certification is approved.
- [ ] The official listing is visible to the intended public audience.
- [ ] The Microsoft Store URL is copied directly from the official listing or Partner Center.
- [ ] The URL opens the correct M.I.N.A System listing.
- [ ] The listing shows publisher `King Narmar`.
- [ ] The listing shows the expected product identity and approved package version.
- [ ] No redirect leads to an unrelated product, unavailable draft, or private-only page.
- [ ] Explicit approval is given to activate the public link.
- [ ] A new branch is created in `KingNarmar/king-narmar-website`.
- [ ] The disabled Windows button is replaced with an accessible external link.
- [ ] Status text changes from `In certification` to `Available on Microsoft Store`.
- [ ] Android and iOS statuses remain unchanged unless separately verified.
- [ ] `npm ci`, lint, Production build, local preview, accessibility checks, and broken-link checks pass.
- [ ] The website PR is reviewed before merge.
- [ ] Production deployment is explicitly approved.

Related website issue: `KingNarmar/king-narmar-website#25`.

## 9. Windows test environment record

Create one record for each meaningful Windows environment used.

| Field | Value |
| --- | --- |
| Test record ID | `WIN-ENV-___` |
| Date | `YYYY-MM-DD` |
| Tester |  |
| Device / virtual machine |  |
| Windows edition |  |
| Windows version / build |  |
| Architecture | x64 |
| Account type | Standard User / Administrator |
| Display resolution |  |
| Display scaling | 100% / 125% / 150% / other |
| Installation source | Microsoft Store / controlled MSIX / other approved method |
| Flutter app version |  |
| MSIX package version |  |
| Demo Mode or Live Mode |  |
| Network state | Online / offline / intermittent |
| Printer / print target |  |
| Notes |  |

Do not include passwords, tokens, production keys, or private customer data in the record.

## 10. Clean Windows installation and package lifecycle

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-INSTALL-001 | Install from Microsoft Store on a clean Windows environment | Installation completes without manual file copying or missing dependencies | `Blocked` | Requires approved Store distribution |
| WIN-INSTALL-002 | Launch immediately after clean installation | App opens without a crash or missing-runtime error | `Not tested` | PR #57 launch smoke does not prove clean Store installation |
| WIN-INSTALL-003 | Start Menu entry | M.I.N.A System appears with correct name and icon | `Not tested` |  |
| WIN-INSTALL-004 | Windows Apps list entry | Product name, publisher, and version are correct | `Not tested` |  |
| WIN-INSTALL-005 | Install as Standard User | Installation follows Store behavior without requiring unsupported elevation | `Blocked` | Requires approved Store installation path |
| WIN-INSTALL-006 | Reinstall the same approved version | Reinstall completes or is correctly prevented by Store/package rules | `Not tested` |  |
| WIN-INSTALL-007 | Upgrade from an older installed version | User data and expected session behavior remain valid | `Blocked` | Requires a later package version |
| WIN-INSTALL-008 | Uninstall | App is removed cleanly from Windows | `Not tested` |  |
| WIN-INSTALL-009 | Reinstall after uninstall | App installs and launches successfully | `Not tested` | Record whether local/demo data persists or resets |
| WIN-INSTALL-010 | Package identity after installation | Installed identity matches `KingNarmar.M.I.N.ASystem` | `Not tested` |  |

## 11. Launch and general desktop behavior

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-LAUNCH-001 | Normal app launch | Main entry flow appears without crash | `Passed — manually verified` | Limited launch smoke recorded in PR #57 |
| WIN-LAUNCH-002 | Repeated launch and close | No progressive crash or duplicate-process issue | `Not tested` |  |
| WIN-LAUNCH-003 | Launch after Windows restart | App starts normally when opened by the user | `Not tested` |  |
| WIN-LAUNCH-004 | Window resize | Layout remains responsive and usable | `Not tested` | Test compact and large desktop sizes |
| WIN-LAUNCH-005 | Minimize and restore | State remains usable after restore | `Not tested` |  |
| WIN-LAUNCH-006 | Lock/sleep and resume | App resumes without crash and refreshes when appropriate | `Not tested` |  |
| WIN-LAUNCH-007 | Keyboard navigation | Primary controls are reachable in a logical order | `Not tested` |  |
| WIN-LAUNCH-008 | Mouse interaction | Menus, dialogs, forms, signature, and file pickers work with mouse | `Not tested` |  |
| WIN-LAUNCH-009 | Close during a non-submitting state | App closes cleanly | `Not tested` |  |
| WIN-LAUNCH-010 | Production configuration validation | Missing/invalid required Production values fail safely during build/startup validation | `Not tested` | Do not expose actual values |

## 12. Authentication, logout, and session persistence

Use controlled test accounts only.

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-AUTH-001 | Login with valid credentials | User enters the authorized company flow | `Not tested` |  |
| WIN-AUTH-002 | Login with invalid credentials | Clear localized error; no session created | `Not tested` |  |
| WIN-AUTH-003 | Logout | Session ends and user returns to the correct auth/welcome flow | `Not tested` |  |
| WIN-AUTH-004 | Close and reopen while authenticated | Intended session persistence works without exposing credentials | `Not tested` |  |
| WIN-AUTH-005 | Expired/refreshing session | Session refresh succeeds or user receives a safe login prompt | `Not tested` |  |
| WIN-AUTH-006 | Password reset request | Reset email is sent through the configured production flow | `Not tested` | Requires controlled email account |
| WIN-AUTH-007 | Open password reset link on Windows | Hosted recovery page opens correctly | `Not tested` |  |
| WIN-AUTH-008 | Complete password reset | New password works and old password is rejected | `Not tested` |  |
| WIN-AUTH-009 | Invalid/expired reset link | Clear safe error is shown | `Not tested` |  |
| WIN-AUTH-010 | Authenticated user opens auth route | User is redirected according to the current routing rules | `Not tested` |  |
| WIN-AUTH-011 | Unauthenticated user opens protected route | Access is blocked and auth flow appears | `Not tested` |  |

## 13. Company access, tenancy, and roles

This section verifies release-relevant behavior without repeating the full Security/RLS audit.

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-TENANT-001 | Approved user with one active company | Correct company workspace loads | `Not tested` |  |
| WIN-TENANT-002 | Approved user with multiple companies | Company selection/switching works | `Not tested` |  |
| WIN-TENANT-003 | Authenticated user without company access | Current access-required/request-support flow appears | `Not tested` | Public self-service company creation must not be invented |
| WIN-TENANT-004 | Inactive member | Company operational data is inaccessible | `Not tested` | Use controlled account |
| WIN-TENANT-005 | User from Company A attempts Company B access | Access is denied | `Not tested` | Use approved controlled test data only |
| WIN-TENANT-006 | Viewer role | Read-only behavior is preserved | `Not tested` |  |
| WIN-TENANT-007 | Warehouse User role | Operational permissions and restrictions are correct | `Not tested` |  |
| WIN-TENANT-008 | Warehouse Manager/Admin/Owner roles | Management actions respect current hierarchy | `Not tested` |  |
| WIN-TENANT-009 | Company switch during active session | Data refreshes to the selected company without mixed tenant data | `Not tested` |  |

Any tenancy or role failure is release-critical and must receive a dedicated issue before release.

## 14. Demo Mode

Demo Mode must remain clearly separated from Live Mode and must not write to Production customer data.

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-DEMO-001 | Enter Demo Mode | Demo workspace opens without live authentication | `Not tested` |  |
| WIN-DEMO-002 | Initial seed data | Realistic local sample workers, tools, transactions, and dashboard data appear | `Not tested` |  |
| WIN-DEMO-003 | Restart persistence | Supported demo changes persist after close/reopen | `Not tested` |  |
| WIN-DEMO-004 | Add worker | Worker is stored locally and appears in Demo lists | `Not tested` |  |
| WIN-DEMO-005 | Add tool | Tool is stored locally and appears in Demo lists | `Not tested` |  |
| WIN-DEMO-006 | Add Issue transaction | Active Demo workers/tools load and transaction succeeds | `Not tested` | Regression target for PR #53 |
| WIN-DEMO-007 | Add Return transaction | Custody balance is reduced correctly | `Not tested` |  |
| WIN-DEMO-008 | Lost/Damaged workflow | Approval and settlement states behave as designed | `Not tested` |  |
| WIN-DEMO-009 | Demo limits | Configured local limits are enforced with a clear message | `Not tested` |  |
| WIN-DEMO-010 | Demo reports | Report preview and saved signed report flow work | `Not tested` |  |
| WIN-DEMO-011 | Exit Demo | User returns to welcome flow without creating a live session | `Not tested` |  |
| WIN-DEMO-012 | Network disconnected | Demo Mode remains usable for supported local operations | `Not tested` |  |

## 15. Workers

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-WORKER-001 | Load worker list | Company-scoped workers load correctly | `Not tested` |  |
| WIN-WORKER-002 | Search workers | Results match the entered query | `Not tested` |  |
| WIN-WORKER-003 | Filter active/inactive workers | Filter produces the correct records | `Not tested` |  |
| WIN-WORKER-004 | Add worker with valid data | Worker is created through the approved flow | `Not tested` |  |
| WIN-WORKER-005 | Required-field validation | Invalid submission is blocked with clear messages | `Not tested` |  |
| WIN-WORKER-006 | Duplicate code validation | Duplicate worker identifiers are handled safely | `Not tested` |  |
| WIN-WORKER-007 | Edit worker | Allowed fields update correctly | `Not tested` |  |
| WIN-WORKER-008 | Deactivate/reactivate worker | Lifecycle state changes correctly | `Not tested` |  |
| WIN-WORKER-009 | Worker with open custody | Relevant custody information remains accurate | `Not tested` |  |
| WIN-WORKER-010 | Unauthorized role attempts mutation | UI and backend deny the action | `Not tested` |  |

## 16. Tools

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-TOOL-001 | Load tool list | Company-scoped tools load correctly | `Not tested` |  |
| WIN-TOOL-002 | Search tools | Results match the entered query | `Not tested` |  |
| WIN-TOOL-003 | Filter active/inactive tools | Filter produces the correct records | `Not tested` |  |
| WIN-TOOL-004 | Add tool with valid data | Tool is created through the approved flow | `Not tested` |  |
| WIN-TOOL-005 | Required-field validation | Invalid submission is blocked with clear messages | `Not tested` |  |
| WIN-TOOL-006 | Duplicate code validation | Duplicate tool identifiers are handled safely | `Not tested` |  |
| WIN-TOOL-007 | Edit tool | Allowed fields update correctly | `Not tested` |  |
| WIN-TOOL-008 | Deactivate/reactivate tool | Lifecycle state changes correctly | `Not tested` |  |
| WIN-TOOL-009 | Tool with open custody | Relevant availability/custody information remains accurate | `Not tested` |  |
| WIN-TOOL-010 | Unauthorized role attempts mutation | UI and backend deny the action | `Not tested` |  |

## 17. Transactions, search, filters, and custody

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-TRX-001 | Load transaction list | Company-scoped transactions load correctly | `Not tested` |  |
| WIN-TRX-002 | Search transactions | Search returns relevant records | `Not tested` |  |
| WIN-TRX-003 | Date/status/type filters | Filters produce correct records and can be cleared | `Not tested` |  |
| WIN-TRX-004 | Create Issue transaction | Quantity is issued and custody balance increases correctly | `Not tested` |  |
| WIN-TRX-005 | Create Return transaction | Return cannot exceed current custody; balance decreases correctly | `Not tested` |  |
| WIN-TRX-006 | Zero/negative/invalid quantity | Submission is blocked with clear validation | `Not tested` |  |
| WIN-TRX-007 | Lost transaction | Required approval workflow is created correctly | `Not tested` |  |
| WIN-TRX-008 | Damaged transaction | Required approval workflow is created correctly | `Not tested` |  |
| WIN-TRX-009 | Approval document upload | Allowed user can attach the supported document | `Not tested` |  |
| WIN-TRX-010 | Approve lost/damaged | Authorized decision updates the workflow correctly | `Not tested` |  |
| WIN-TRX-011 | Reject lost/damaged | Authorized decision updates the workflow correctly | `Not tested` |  |
| WIN-TRX-012 | Settle approved lost/damaged | Settlement state and accountability update correctly | `Not tested` |  |
| WIN-TRX-013 | Unauthorized approval attempt | UI and backend deny the action | `Not tested` |  |
| WIN-TRX-014 | Custody balance view | Worker/tool balances match completed transaction history | `Not tested` |  |
| WIN-TRX-015 | App restart after transaction | New transaction and balances remain available | `Not tested` |  |
| WIN-TRX-016 | Two-device/live update | A transaction from another device appears after realtime/resume refresh | `Not tested` |  |

## 18. Photo and file selection

Use non-sensitive test files only.

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-FILE-001 | Select a supported image | File picker opens and the image can be attached | `Not tested` |  |
| WIN-FILE-002 | Select a supported PDF | File picker opens and the PDF can be attached where supported | `Not tested` |  |
| WIN-FILE-003 | Cancel file picker | User returns safely without an error or stale attachment | `Not tested` |  |
| WIN-FILE-004 | Unsupported file type | File is rejected with a clear message | `Not tested` |  |
| WIN-FILE-005 | Missing/deleted local file | App handles the failure without crash | `Not tested` |  |
| WIN-FILE-006 | Large attachment within supported limits | Upload/processing behavior is clear and stable | `Not tested` | Record actual tested size |
| WIN-FILE-007 | Network loss during upload | Failure is recoverable and does not create a misleading completed state | `Not tested` |  |
| WIN-FILE-008 | Retry after reconnect | Attachment can be retried safely | `Not tested` |  |
| WIN-FILE-009 | Company-scoped storage path | Uploaded object remains in the authorized company scope | `Not tested` | Release-relevant RLS check |
| WIN-FILE-010 | Unauthorized file access | Another company/inactive user cannot access the file | `Not tested` | Controlled test only |

## 19. Arabic filenames and non-ASCII paths

Test both Arabic and other non-ASCII characters in filenames and Windows user directories.

Suggested safe fixtures:

- `تقرير عهدة.pdf`
- `صورة أداة.png`
- `اختبار رقم ١.jpg`
- A Windows user/profile or directory path containing non-ASCII characters.

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-I18N-FILE-001 | Select Arabic-named PDF | File is selected and displayed without corrupted characters | `Not tested` |  |
| WIN-I18N-FILE-002 | Select Arabic-named image | File is selected and displayed without corrupted characters | `Not tested` |  |
| WIN-I18N-FILE-003 | Upload Arabic-named attachment | Upload succeeds or fails with a clear recoverable error | `Not tested` |  |
| WIN-I18N-FILE-004 | Save PDF to Arabic directory | File saves successfully and can be reopened | `Not tested` |  |
| WIN-I18N-FILE-005 | Run from non-ASCII Windows user path | App launch and file operations remain stable | `Not tested` |  |
| WIN-I18N-FILE-006 | Print document with Arabic content | Arabic text renders correctly in print output | `Not tested` |  |

## 20. Mouse signature

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-SIGN-001 | Draw signature with mouse | Strokes follow pointer input smoothly | `Not tested` |  |
| WIN-SIGN-002 | Clear signature | Canvas resets completely | `Not tested` |  |
| WIN-SIGN-003 | Empty signature validation | Required signature cannot be submitted empty | `Not tested` | Where signature is required |
| WIN-SIGN-004 | Save signature in report flow | Signature appears in the generated document | `Not tested` |  |
| WIN-SIGN-005 | Resize/window scaling during signature flow | Signature state and canvas remain usable | `Not tested` |  |
| WIN-SIGN-006 | High-DPI pointer accuracy | Pointer and rendered stroke remain aligned | `Not tested` | Test at 125% and 150% where available |

## 21. Reports and PDF behavior

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-PDF-001 | Open Report Builder | Required controls and selectors are usable | `Not tested` |  |
| WIN-PDF-002 | Generate worker report | Preview reflects the selected worker and current data | `Not tested` |  |
| WIN-PDF-003 | Generate tool report | Preview reflects the selected tool and current data | `Not tested` |  |
| WIN-PDF-004 | Generate transaction/custody report | Preview matches the selected transaction/data scope | `Not tested` |  |
| WIN-PDF-005 | Preview PDF | Preview opens without blank or corrupted pages | `Not tested` |  |
| WIN-PDF-006 | Save PDF | User selects a path and the file is written successfully | `Not tested` |  |
| WIN-PDF-007 | Reopen saved PDF | Saved file opens in a Windows PDF viewer | `Not tested` |  |
| WIN-PDF-008 | Print PDF | Windows print dialog opens and output is correct | `Not tested` |  |
| WIN-PDF-009 | Cancel save/print dialog | App returns safely without false success | `Not tested` |  |
| WIN-PDF-010 | Signed PDF | Signature and required report metadata appear correctly | `Not tested` |  |
| WIN-PDF-011 | Arabic report content | Arabic direction, shaping, names, and filenames render correctly | `Not tested` |  |
| WIN-PDF-012 | High-page-count/large-data report | Generation remains stable with representative data | `Not tested` | Record data size |
| WIN-PDF-013 | Offline report generation | Local generation works where no network request is required | `Not tested` | Separate from fetching live data |

## 22. Offline, reconnect, and session recovery

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-NET-001 | Launch Live Mode while offline | App shows a clear offline/retry state without crash | `Not tested` |  |
| WIN-NET-002 | Lose network while viewing data | Existing UI remains stable and indicates connection state | `Not tested` |  |
| WIN-NET-003 | Lose network during submission | Operation does not show false success | `Not tested` |  |
| WIN-NET-004 | Reconnect after temporary outage | Data can refresh without restarting the app | `Not tested` |  |
| WIN-NET-005 | Resume after lock while another device changed data | Current company data refreshes as designed | `Not tested` | Related completed Issue #48 |
| WIN-NET-006 | Repeated disconnect/reconnect | No duplicate realtime behavior or crash | `Not tested` |  |
| WIN-NET-007 | Demo Mode while offline | Supported local Demo operations continue | `Not tested` |  |
| WIN-NET-008 | Expired session after reconnect | Session refreshes or user is safely returned to login | `Not tested` |  |

## 23. High-DPI, resolution, and accessibility checks

Test at available Windows scaling levels without claiming unsupported universal coverage.

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-DPI-001 | 100% display scaling | Core layouts and dialogs are usable | `Not tested` |  |
| WIN-DPI-002 | 125% display scaling | No clipped actions or unreadable text | `Not tested` |  |
| WIN-DPI-003 | 150% display scaling | No clipped actions or unreadable text | `Not tested` |  |
| WIN-DPI-004 | Small supported desktop window | Content scrolls or adapts without inaccessible controls | `Not tested` |  |
| WIN-DPI-005 | Large/high-resolution display | Layout uses space correctly without broken alignment | `Not tested` |  |
| WIN-DPI-006 | English UI | Text, forms, and dialogs are usable | `Not tested` |  |
| WIN-DPI-007 | Arabic UI | RTL layout, text wrapping, forms, and dialogs are usable | `Not tested` | Account/legal localization tracked in #67 |
| WIN-DPI-008 | Visible keyboard focus | Interactive controls show a usable focus state | `Not tested` |  |
| WIN-DPI-009 | Text scaling/system accessibility settings | App remains usable at the tested setting | `Not tested` | Record actual setting |

## 24. Standard Windows user validation

Run these checks without administrator privileges unless Windows or Store behavior explicitly requires elevation.

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-STD-001 | Install through approved Store path as Standard User | Installation follows expected Store policy | `Blocked` | Requires approved Store distribution |
| WIN-STD-002 | Launch and login | Core app opens and authenticates | `Not tested` |  |
| WIN-STD-003 | Demo persistence | Local Demo data can be stored and reloaded | `Not tested` |  |
| WIN-STD-004 | File picker | User-accessible files can be selected | `Not tested` |  |
| WIN-STD-005 | Save PDF to Documents | File can be saved to a permitted user directory | `Not tested` |  |
| WIN-STD-006 | Attempt save to restricted directory | App handles Windows denial without crash or false success | `Not tested` | Do not bypass permissions |
| WIN-STD-007 | Printing | User can access permitted Windows print targets | `Not tested` |  |
| WIN-STD-008 | Uninstall | App can be removed through normal Windows/Store flow | `Not tested` |  |

## 25. Reinstall, upgrade, uninstall, and data behavior

Before testing, identify which data is expected to be local versus server-backed.

| ID | Test | Expected result | Initial status | Evidence / notes |
| --- | --- | --- | --- | --- |
| WIN-LIFE-001 | Reinstall same version | App remains installable and launches | `Not tested` |  |
| WIN-LIFE-002 | Upgrade to newer approved version | App upgrades without losing supported state | `Blocked` | Requires later version |
| WIN-LIFE-003 | Live data after reinstall | Authorized server data remains available after login | `Not tested` |  |
| WIN-LIFE-004 | Session after upgrade | Expected session behavior is preserved or clearly reset | `Blocked` | Requires later version |
| WIN-LIFE-005 | Demo data after upgrade | Expected Demo migration/persistence behavior is recorded | `Blocked` | Requires later version |
| WIN-LIFE-006 | Uninstall | Application package is removed | `Not tested` |  |
| WIN-LIFE-007 | Local application data after uninstall | Actual retained/removed behavior is recorded | `Not tested` | Do not claim automatic deletion without evidence |
| WIN-LIFE-008 | Reinstall after uninstall | App starts from the actual resulting state | `Not tested` |  |

## 26. Known limitations and unresolved release risks

Current known limitations must remain visible until replaced by verified evidence:

1. Microsoft Store certification is still in progress.
2. No official public Microsoft Store URL exists.
3. Clean Microsoft Store installation has not been tested.
4. The full Windows functional matrix has not been executed.
5. Windows App Certification Kit success does not prove authentication, storage, reporting, printing, file picker, High-DPI, offline, or tenant-isolation behavior.
6. The repository did not contain an established Flutter `test/` directory at the time of PR #57; test coverage review is tracked in #63 and targeted tests in #64.
7. Arabic filenames and non-ASCII Windows paths have not been verified.
8. Mouse signature behavior has not been verified on Windows.
9. PDF preview, save, and printing have not been verified on Windows.
10. Standard Windows user behavior has not been verified.
11. Upgrade behavior cannot be verified until a later package version exists.
12. No automatic in-app updater has been verified. The first public Windows release should rely on the Microsoft Store update path and user-controlled Store update behavior.
13. No claim is made that a separately distributed EXE or portable ZIP is Production-signed or publicly supported.
14. Release-relevant Account/Profile and legal UI strings require the scoped EN/AR localization work tracked in #67.
15. Any failure discovered during security/static checks or Windows runtime testing requires its own focused issue and PR.

Update this list after every release-readiness issue and manual test group.

## 27. Update method

### Current first-release plan

The current Windows release path is Microsoft Store distribution.

Until a later product decision is approved:

- Do not claim an automatic in-app updater.
- Do not add a custom update service inside the app.
- Users should obtain updates through Microsoft Store mechanisms available on their Windows device.
- Support documentation may explain how to open Microsoft Store, locate M.I.N.A System, and select an available update after the listing becomes public.
- A later Store package version is required to verify actual upgrade behavior.
- Any direct-distribution installer or portable ZIP requires a separate approved release plan, signing decision, checksums, installation testing, and public-link review.

## 28. Code signing and SmartScreen notes

The current submission is a Microsoft Store MSIX package.

Release-readiness rules:

- Do not commit signing certificates, private keys, passwords, or exported certificate bundles.
- Do not claim a non-Store installer or portable archive is Production-signed unless its Authenticode signature is actually verified.
- Do not present a self-signed certificate as suitable for public Production distribution.
- Any future direct-distribution EXE requires a separate code-signing plan and certificate decision.
- Any future direct-download binary requires SmartScreen testing on a clean Windows environment.
- SmartScreen reputation and warning behavior must be recorded from actual testing; it must not be assumed.
- Microsoft Store package validation does not automatically validate future external installer or portable ZIP distribution paths.
- A paid certificate purchase requires explicit approval before commitment.

## 29. Security and privacy release gates

These items are executed in detail under Issue #62, but failures block readiness:

- [ ] No service-role key exists in Flutter or public web code.
- [ ] No production secret is tracked in Git.
- [ ] No certificate or signing password is tracked in Git.
- [ ] No sensitive authentication token or private user data is written to Production logs.
- [ ] Production URLs use HTTPS.
- [ ] Privacy Policy URL is valid.
- [ ] Account Deletion URL is valid.
- [ ] No fake Store URL exists.
- [ ] No `href="#"` placeholder exists in public release pages.
- [ ] File and storage paths remain company-scoped.
- [ ] Directly relevant RLS evidence remains consistent with tenant isolation.
- [ ] Controlled cross-company and inactive-member tests pass before Production readiness is declared.

Do not paste secret values into this document, issue comments, PR descriptions, or screenshots.

## 30. Evidence log template

Add one entry for each executed test group.

### Evidence record `WIN-EVIDENCE-___`

- Date:
- Tester:
- Related test IDs:
- Environment record ID:
- Branch/commit/package version:
- Execution steps:
- Actual result:
- Status: `Passed — manually verified` / `Passed — automated/static evidence` / `Failed` / `Blocked` / `Not tested`
- Screenshot, log, or artifact reference:
- Sensitive data redacted: Yes / No
- Follow-up issue, if failed:
- Notes:

Evidence should describe what was actually tested, not what was expected to work.

## 31. Failure handling

When a reproducible failure is found:

1. Stop marking the affected release area as ready.
2. Record the failed test ID and environment.
3. Preserve safe evidence without exposing private data.
4. Create a dedicated GitHub issue containing:
   - actual behavior;
   - expected behavior;
   - reproduction steps;
   - affected Windows environment;
   - release risk;
   - directly related files or components;
   - proposed verification steps.
5. Use a dedicated branch and PR for the fix.
6. Run targeted checks and the affected manual Windows test again.
7. Do not close the defect until the fix is merged and the actual test passes.
8. Do not replace the Store submission during certification without reviewed necessity and explicit approval.

## 32. Completion criteria

Issue #58 is complete when this canonical document is reviewed and merged.

The parent Windows Release Readiness epic #11 is complete only when:

- documentation issues #58–#61 are merged;
- static release/security checks in #62 are recorded;
- release-relevant localization gap #67 is resolved;
- test coverage is reviewed in #63;
- approved targeted tests in #64 are added and passing;
- the Windows CI decision in #66 is recorded and any approved workflow is validated;
- the manual Windows matrix in #65 is executed with explicit results;
- all release-blocking failures are resolved or explicitly accepted as documented limitations;
- Microsoft Store certification is approved;
- the official Store URL is verified;
- website issue `KingNarmar/king-narmar-website#25` is implemented and merged only after explicit approval.

## 33. Related tracking

- #11 — Epic: Windows Release Readiness.
- #58 — This canonical readiness document.
- #59 — Release metadata and version mapping.
- #60 — Windows release notes.
- #61 — Windows Support / FAQ.
- #62 — Security and release static checks.
- #63 — Functional test coverage review.
- #64 — Targeted automated tests.
- #65 — Manual Windows validation matrix execution.
- #66 — Windows GitHub Actions evaluation.
- #67 — Account/legal UI localization.
- #17 — Automated testing foundation.
- #44 — Password recovery.
- #45 — Production auth emails and hosted auth pages.
- #48 — Realtime refresh and reconnect on app resume.
- PR #57 — Microsoft Store MSIX configuration and recorded package verification.
- `KingNarmar/king-narmar-website#25` — Post-certification Store-link activation.
