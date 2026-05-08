# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Last Verified GitHub State

Latest verified pushed commit:

`353b9ef4e3f2e2a9fe2f8aed66ff6a61da52f2e9`

Commit message:

`Block offline mutations for company settings`

This roadmap is the single source of truth for the Mina System project.

It is based on the real GitHub repository, not the README.

---

# Project Vision

Mina System is a Flutter + Supabase inventory and custody management system built as a real multi-company SaaS/product.

The system manages:

- Companies
- Users and roles
- Workers
- Tools
- Lookups
- Transactions
- Tool custody balances
- Lost/Damaged approval workflow
- Settlements
- Dashboard summaries
- Company settings
- PDF reports
- Supabase Storage uploads
- Storage/image optimization
- Responsive layouts
- Offline/network-aware behavior
- Future subscriptions, plans, usage limits, and storage limits

Every company must have isolated data using `company_id` and the active `currentCompanyId`.

The product should eventually support:

- Free download from stores
- Free plan / trial plan
- Paid monthly packages
- B2B company subscriptions
- Web landing page
- Desktop installer download
- Google Play release
- App Store release
- Production Supabase environment separate from development/testing
- Safe storage usage through image compression and storage limits
- Clear behavior when the user is offline or the internet connection is unstable
- Mobile/tablet camera capture for faster proof/document upload workflows
- File upload fallback from device storage

---

# Core Rules

## Development Rules

- Work step by step.
- Do not make large changes in one step.
- Do not change a working UI unless needed.
- Always review the real GitHub repo before continuing a new step.
- Do not rely only on README because it may be outdated.
- If a file becomes too large, refactor it into smaller focused files without changing working behavior.
- Keep `PROJECT_ROADMAP.md` as the single source of truth.
- Update this roadmap after each completed feature or phase.
- Do not create multiple roadmap files.

After each completed feature:

1. Test manually.
2. Run `dart format lib`.
3. Run `flutter analyze`.
4. Commit.
5. Push.
6. Review repo again.

## Testing Rules

Every new feature should be tested on:

- Windows
- Mobile portrait
- Mobile landscape
- Tablet portrait
- Tablet landscape

## Architecture Rules

Follow this pattern where applicable:

1. Model
2. Repository / Service
3. Cubit / State
4. UI
5. SQL Grants if needed
6. RLS Policies if needed
7. Manual test
8. `dart format lib`
9. `flutter analyze`
10. Commit / Push

## Supabase Rules

- Every business table must be connected to `company_id`.
- Every query must be filtered by `currentCompanyId`.
- Never expose or use service role keys in Flutter.
- Admin Auth methods must not be called directly from Flutter.
- User invitations must be handled through a secure backend / Supabase Edge Function.
- Before using any Supabase table:
  - Check real columns first.
  - Add correct grants.
  - Add safe RLS policies.
- Company users must access company data only through active company membership.
- RLS must enforce role permissions at database level, not UI only.
- Plan limits must be enforced at database/RPC level, not UI only.
- Subscription access must be checked securely using company subscription records.
- Transactions should not be deleted from the system.
- Transaction editing should not be exposed as a normal UI action.
- Transaction corrections should be handled by corrective transactions, approval workflow, settlement workflow, or future void workflow.
- Lost/Damaged transactions should not reduce worker custody balance while pending approval.
- Lost/Damaged transactions should not reduce worker custody balance after approval only.
- Lost/Damaged transactions should reduce worker custody balance only after final settlement/deduction is completed.

## UI / Theme Rules

- Colors should be centralized inside `AppColors`.
- Do not use direct widget-level colors like `Colors.green` or `Colors.orange` unless they are first added to `AppColors`.
- Reusable user messages should use `AppMessage`.
- Errors inside Bottom Sheets or Dialogs should appear inside the form/dialog when SnackBars would be hidden behind the overlay.
- Success/error/warning/info messages should be clear, professional, and user-friendly.
- Do not show raw technical errors to end users.

## Responsive / Adaptive Rules

- Do not assume mobile is always portrait.
- Do not assume tablet is always landscape.
- Do not lock orientation unless there is a clear business reason.
- Prefer adaptive layout based on available space.
- Use:
  - `MediaQuery.sizeOf(context)`
  - `LayoutBuilder`
  - `SafeArea`
  - `SingleChildScrollView`
  - `Flexible`
  - `Expanded`
  - `Wrap`
  - `ResponsiveLayout`
  - `AppBreakpoints`
- Use `OrientationBuilder` only for small widget-level orientation changes when needed.
- Every long form must be scrollable in landscape.
- Dialogs must respect available screen height.
- Tables must remain horizontally scrollable where needed.
- Action buttons must wrap instead of overflowing.
- Mobile landscape must remain a mobile experience unless there is a strong reason to switch.
- Android/iOS tablets should remain TabletShell even when screen width is large.
- DesktopShell should be used for desktop platforms, not for large simulated Android/iOS tablets.

## Storage / Image Optimization Rules

- Storage files must be saved in Supabase Storage.
- Database should store cloud storage paths only.
- Local file paths must not be saved in Supabase tables.
- Never upload large original images without compression unless there is a clear business reason.
- Transaction proof images must be compressed before upload.
- Approval document images should be compressed before upload when they are image files.
- PDF files should not be image-compressed.
- Company logos should be resized/compressed carefully without destroying quality.
- Company logos should be resized to a practical maximum dimension before upload.
- Use clear storage paths under company folders:
  - `{companyId}/transactions/...`
  - `{companyId}/logo/...`
  - `{companyId}/documents/...`
- Image compression should work across Windows, Android, iOS, tablets, and future supported platforms.
- Prefer cross-platform image processing where possible to avoid platform-specific upload failures.
- Future storage usage must be tracked per company for plan limits.
- Mobile/tablet users should be able to capture photos directly from camera for proof/document workflows.
- Camera capture should remain optional.
- File upload from device storage should remain supported as a fallback.

## Offline / Network Rules

- The app must not fail silently when there is no internet connection.
- The user must see a clear offline message when connection is unavailable.
- Offline mode must not bypass RLS, subscription limits, or business rules.
- Save/update/delete mutations should be blocked while offline until full offline sync is implemented.
- Supabase Storage uploads should be blocked while offline.
- Cloud-only Storage file viewing should be blocked while offline unless a future cache system is implemented.
- Reports may generate offline from already-loaded in-memory data.
- Online assets inside reports, such as company logo, may be unavailable offline.
- Critical loading screens should provide Retry actions.
- Network errors must be user-friendly and separated from validation/auth/business-rule errors where possible.
- Offline drafts and background sync are future features.

## Commercial / SaaS Rules

- The same app should support Free and Paid plans.
- Do not create separate apps for free and paid versions.
- A company subscription should determine enabled features and limits.
- Free plan limits must be simple, strict, and useful for demo/testing.
- Paid packages must be company-based.
- User access must depend on active company membership and company subscription status.
- App Store / Google Play builds should be free download/login-based.
- Do not add direct payment buttons inside mobile apps until store billing rules are reviewed.
- B2B subscription payment should preferably be handled outside the mobile app through website, invoice, or customer portal.
- The app should show a safe message like:
  - `Contact your company admin to manage subscription.`
- A production release must include:
  - Privacy Policy
  - Terms of Service
  - Support contact
  - Demo/review account if required by stores
  - Production Supabase project
  - Clear environment configuration

---

# Current Project Status Summary

## Completed Core Foundation

- Auth flow is working.
- Current Context flow is working.
- Create Company flow is working.
- Company Settings core features are working.
- Lookups are Supabase-backed.
- Workers are Supabase-backed.
- Tools are Supabase-backed.
- Transactions / custody core is Supabase-backed.
- Dashboard reads real Supabase data.
- Reports / PDF core reports are working.
- Lost/Damaged approval and settlement workflow core flow is working.
- Android signed approval document opening is working.
- Large file refactor checkpoint is mostly done.
- Flutter SDK upgrade checkpoint is done.
- Responsive and orientation hardening audit is completed.
- Cross-platform image compression foundation is implemented.
- Transaction proof images are compressed before upload.
- Approval document images are compressed before upload when the selected file is an image.
- PDF approval documents are uploaded without image compression.
- Company logos are resized/compressed before upload.
- Reports card responsive regression fix is completed.
- Offline/network handling foundation is implemented.

## Current Active Phase

**Phase N — Offline & Network Handling**

Status:

**In Progress**

Completed so far:

- Network status service created.
- Network status Cubit created.
- Global offline banner implemented.
- Offline screen added for Current Context loading failure.
- Retry added to critical context loading screen.
- AppMessage system added for unified success/error/warning/info messages.
- Transactions save is blocked while offline.
- Signed approval document upload is blocked while offline.
- Transaction proof image upload is blocked while offline.
- Company logo upload is blocked while offline.
- Cloud proof image viewing is blocked while offline.
- Cloud signed document viewing is blocked while offline.
- Workers add/update/delete are blocked while offline.
- Tools add/update/delete are blocked while offline.
- Lookups add/delete are blocked while offline.
- Company Settings mutations are blocked while offline:
  - Company Profile update
  - Report Settings update
  - Document Template update
  - Company Logo upload
- Settings screen no longer converts action failures into full screen failure.
- Reports can still generate offline from already-loaded in-memory data.

Next required step:

- Add Friendly Network Error Mapper.
- Convert Supabase/Socket/Storage technical errors into user-friendly messages.
- Apply the mapper gradually to Cubits and services.

---

# Auth

## Status: Done

Implemented:

- Login is working.
- Register is working.
- Email confirmation is working.
- Auth redirect between Login / Register / Dashboard is working.

Current flow:

Register → Confirm Email → Login → Create Company if no company exists → Dashboard

Required future flow after Company Users / Invitations:

Register/Login  
→ Check pending invitations by email  
→ Check active company memberships  
→ If invited: Accept Invitation / Join Company  
→ If already member: Select Company or Dashboard  
→ If no membership and no invitation: Create Company

Required future flow after Subscriptions:

Register/Login  
→ Load Current Context  
→ Load Current Company Subscription  
→ If subscription is active/free/trial: continue  
→ If subscription expired: show Subscription Required screen  
→ If company has no plan: assign Free plan by default

Future improvements:

- Invitation acceptance flow.
- Company membership selection.
- Subscription check after company selection.
- Expired subscription / limited access screen.
- Role-based auth redirect behavior.

---

# Current Context

## Status: Done / Offline-Aware

Current Context is responsible for loading:

- Current profile
- Current user companies
- Current company
- Current role

Implemented:

- `CurrentContextCubit`
- `CurrentContextRepo`
- `CurrentContextGate`
- `current_context_extensions.dart`

Important helpers:

- `context.currentCompanyId`
- `context.currentProfileId`
- `context.currentUserRole`
- `context.requireCurrentCompanyId()`
- `context.requireCurrentProfileId()`
- `context.requireCurrentUserRole()`

Current behavior:

- No company → Create Company screen
- One company → Dashboard
- Multiple companies → Select Company placeholder
- No internet during initial context loading → Offline screen with Retry

Future improvements:

- Pending invitation screen.
- Select Company screen for multiple companies.
- Cached read-only company context for future offline mode.
- Subscription/plan check after current company is loaded.

---

# Create Company Flow

## Status: Done

Implemented:

- Create Company screen.
- RPC call to `create_company_with_defaults`.
- Company created with defaults.
- Dashboard opens after creation.
- Company name appears in TopBar.

Future improvements:

- Add stronger confirmation before creating a new company.
- Add “I am creating a new company as the owner” checkbox.
- Add “I already have an invitation” option.
- Add “Join company with invite” option.
- Prevent accidental company creation as much as possible.
- Add accidental company cleanup/archive flow.
- Assign Free plan automatically after company creation.
- Create default subscription record after company creation.
- Initialize usage counters/limits after company creation.
- Prevent creating unlimited companies from one account if abused.
- Add company onboarding checklist after creation.

---

# Company Settings

## Status: Done / Offline-Aware

Implemented:

- Read company profile from `companies`.
- Update company profile.
- Update TopBar company name without reloading dashboard.
- Company profile is used inside PDF report headers.
- Upload company logo to Supabase Storage bucket `company-assets`.
- Save `logo_path` in `companies`.
- Delete old logo after successful new upload.
- Company logo image compression/resizing before upload.
- Company logo is used inside generated PDF reports.
- PDF logo refresh works without restarting the app after changing the logo.
- Read `company_report_settings`.
- Update report settings.
- Report settings are used inside PDF reports.
- Applied `dateFormat` to PDF dates.
- Fixed PDF date format normalization.
- Read `company_document_templates`.
- Update document template fields.
- Document templates are used inside PDF Document Control section.
- Robust PDF template matching added.
- Document template signature labels are used inside PDF Signature Section.
- Offline blocking for:
  - Company Profile update
  - Report Settings update
  - Document Template update
  - Company Logo upload
- Settings action errors remain inside loaded Settings state.
- Settings screen does not turn into full failure screen for action errors.
- Settings messages use `AppMessage`.

Company Profile fields:

- Company Name
- Trade Name
- Legal Name
- Trade License No.
- Tax Registration No.
- Address Line 1
- Address Line 2
- City
- Country
- Phone
- Email
- Website
- Logo Path

Company Logo storage path format:

`{companyId}/logo/company-logo-{timestamp}.{extension}`

Allowed image types:

- PNG
- JPG
- JPEG
- WEBP

Current logo optimization behavior:

- Logo images are resized/compressed before upload.
- Logo max dimension is centralized in `ImageCompressionService`.
- Current company logo max dimension: `800 px`.
- Current company logo quality: `90`.
- PDF files are not allowed for company logo upload.

Future improvements:

- Preserve transparency when possible for PNG/WebP logos.
- Add max upload size validation before compression.
- Add friendly error if logo file is too large or invalid.
- Track logo storage usage under company storage quota.
- Add optional visual preview/crop flow before uploading logo.
- Fine-tune PDF logo box size if needed.
- Apply `timeFormat` to PDF timestamps.
- Apply `defaultTimezone` to report generation dates/times.
- Add subscription section inside Company Settings for owners/admins.
- Show current plan name.
- Show plan status.
- Show usage summary.
- Show upgrade/contact message without direct mobile payment link.
- Add storage usage summary after storage tracking is implemented.

---

# Phase B — Lookups Supabase Integration

## Status: Done / Offline-Aware

Goal:

Replace local/static lookups with Supabase-backed lookups.

Implemented:

- Real Supabase-backed lookup tables:
  - `departments`
  - `job_titles`
  - `tool_units`
  - `tool_categories`
- SQL grants and RLS policies.
- Models and repository.
- Read lookups by `company_id`.
- Load lookups after `CurrentContextLoaded`.
- Loading state and error handling.
- Add/Delete flows.
- Duplicate prevention inside the same company.
- Strong lookup name normalization.
- Delete protection for dependent data where applicable.
- Offline blocking for add/delete mutations.
- User-friendly messages using `AppMessage`.
- `flutter analyze` has no errors after implementation.

Rules applied:

- Used `currentCompanyId`.
- Added grants and RLS policies before testing.
- Kept existing UI as much as possible.

Future improvements:

- Add plan-based lookup limits if needed.
- Add import defaults from industry templates later.
- Optional edit/rename lookup flow if needed.

---

# Phase C — Workers Supabase Integration

## Status: Done / Offline-Aware

Goal:

Replace local workers state with Supabase data.

Implemented:

- Checked real Supabase columns for `workers`.
- Checked workers RLS / grants / constraints.
- Updated `WorkerModel`.
- Created `WorkersRepo`.
- Read workers by `company_id`.
- Added worker.
- Updated worker.
- Deleted worker.
- Generated `worker_code` automatically.
- Prevented duplicate `hr_code` inside the same company.
- Used real Department and Job Title IDs from Lookups.
- Loaded workers after `CurrentContextLoaded`.
- Added loading/submitting/error state.
- Connected Add / Update / Delete Worker actions to Supabase.
- Search workers by existing search logic.
- Offline blocking for add/update/delete mutations.
- Worker form shows action errors inside form when opened in Bottom Sheet/Dialog.
- `flutter analyze` has no errors after implementation.

Database rules confirmed:

- `workers.company_id` references `companies(id)`.
- `workers.department_id` references `departments`.
- `workers.job_title_id` is constrained to match the selected department.
- `hr_code` is unique inside the same company.
- `worker_code` is unique inside the same company.
- Department and Job Title deletion is protected by foreign key rules when workers depend on them.

Future improvements:

- Enforce plan limit before adding a worker.
- Add friendly upgrade message when worker limit is reached.
- Add database/RPC-level worker limit enforcement.
- Add stronger open-custody protection before worker deletion if needed.
- Advanced worker profile fields if needed.

---

# Phase D — Tools Supabase Integration

## Status: Done / Offline-Aware

Goal:

Replace local tools state with Supabase data.

Implemented:

- Checked real Supabase columns for `tools`, `tool_units`, and `tool_categories`.
- Checked tools RLS / grants / constraints / indexes / enum values.
- Updated `ToolModel`.
- Created `ToolsRepo`.
- Read tools by `company_id`.
- Read related Unit and Category names through Supabase relationships.
- Added tool.
- Updated tool.
- Deleted tool.
- Generated `tool_code` automatically.
- Prevented duplicate `tool_name` inside the same company.
- Prevented duplicate `tool_code` inside the same company.
- Used real Tool Unit and Tool Category IDs from Lookups.
- Loaded tools after `CurrentContextLoaded`.
- Added loading/submitting/error state.
- Connected Add / Update / Delete Tool actions to Supabase.
- Search tools by existing search logic.
- Offline blocking for add/update/delete mutations.
- Tool form shows action errors inside form when opened in Bottom Sheet/Dialog.
- `flutter analyze` has no errors after implementation.

Database rules confirmed:

- `tools.company_id` references `companies(id)`.
- `tools.unit_id` is constrained to match a valid `tool_units` record for the same company.
- `tools.category_id` is constrained to match a valid `tool_categories` record for the same company.
- `tool_code` is unique inside the same company.
- `tool_name` has a normalized unique index inside the same company.
- Tool Unit and Tool Category deletion is protected by foreign key constraints when tools depend on them.

Future improvements:

- Enforce plan limit before adding a tool.
- Add friendly upgrade message when tool limit is reached.
- Add database/RPC-level tool limit enforcement.
- Add stronger database-level open-custody delete protection if needed.
- Tool status history if needed.

---

# Phase E — Transactions / Custody Core Supabase Integration

## Status: Done / Offline-Aware

Goal:

Replace local transactions state with Supabase-backed transaction records and build the real custody movement flow.

Transaction types:

- Issue
- Return
- Lost
- Damaged

Implemented:

- Checked real Supabase columns for transaction/custody-related tables.
- Checked enum values.
- Checked transactions RLS / grants / constraints.
- Fixed transactions grants for authenticated SELECT / INSERT / UPDATE.
- No DELETE grant was added for transactions.
- Updated `TransactionModel`.
- Created `TransactionsRepo`.
- Read transactions by `company_id`.
- Add transaction to Supabase.
- Update transaction capability exists at repo/cubit level for future controlled flows.
- Auto-generate transaction code from Supabase records.
- Upload proof images to Supabase Storage bucket `transaction-proofs`.
- Transaction proof images are compressed before upload.
- Store only cloud storage paths in `transactions.proof_image_path`.
- Added `TransactionsState` loading/submitting/error fields.
- Refactored `TransactionsCubit` to use Supabase.
- Loaded transactions after `CurrentContextLoaded`.
- Connected Add Transaction form to Supabase.
- Added loading overlay.
- Search/filter transactions works.
- Custody Balance is calculated from real Supabase transactions.
- Tool Summary is calculated from real Supabase transactions.
- Closed Today count is calculated from real Supabase transactions.
- Signed approval document images are compressed before upload when they are image files.
- Signed approval document PDF files are uploaded without image compression.
- Offline blocking for transaction save.
- Offline blocking for proof image upload.
- Offline blocking for signed approval document upload.
- Offline blocking for cloud proof image viewing.
- Offline blocking for cloud signed document viewing.
- Transaction form shows errors inside form when opened in Bottom Sheet/Dialog.
- Fixed transaction proof image display in details dialog.
- Fixed transaction proof thumbnail display in desktop table.
- Fullscreen proof image preview uses resolved signed URL.
- `flutter analyze` has no errors after implementation.

Business rules confirmed:

- Transactions should not be deleted.
- Normal edit/delete buttons should not be shown for transactions.
- Corrections should be done by corrective transactions or future controlled approval/void workflow.
- Issue and Return are normal custody movement records.
- Lost and Damaged enter pending approval flow.
- Images must be stored in Supabase Storage, not as local file paths.

Custody balance rule:

- Pending Lost/Damaged transactions do not reduce worker custody balance.
- Rejected Lost/Damaged transactions do not reduce worker custody balance.
- Return transactions reduce custody balance immediately.
- Lost/Damaged transactions reduce worker custody balance only after final settlement/deduction is completed.

Future improvements:

- Add Void/Correction workflow if needed.
- Generate custody acknowledgement PDFs from real transactions.
- Use `custody_acknowledgements` and `custody_acknowledgement_items` in reports/signature flow.
- Add database-level open-custody protection for deleting tools/workers if needed.
- Track proof image storage usage per company.
- Enforce monthly transaction limits by plan.
- Add friendly upgrade message when transaction limit is reached.
- Add database/RPC-level transaction limit enforcement.
- Add camera capture support on mobile/tablet for transaction proof images.
- Add camera capture support on mobile/tablet for signed approval document images when the document is captured as a photo.
- Keep file upload from device storage available as fallback.
- Add offline transaction drafts and sync later.

---

# Phase F — Dashboard Supabase Data

## Status: Done

Goal:

Replace static/dummy Dashboard data with real Supabase-backed company data.

Implemented:

- Created `DashboardSummaryModel`.
- Created `DashboardRepo`.
- Created `DashboardState`.
- Created `DashboardCubit`.
- Added `DashboardCubit` to `AppShell`.
- Loaded dashboard summary after `CurrentContextLoaded`.
- Dashboard summary reads real data by `company_id`.
- Total Workers comes from Supabase `workers`.
- Total Tools comes from Supabase `tools`.
- Open Custodies comes from real transactions.
- Closed Today comes from real closing transactions.
- Fixed Closed Today timezone handling.
- Dashboard Closed Today logic updated after settlement workflow.
- Recent Transactions comes from real Supabase transactions.
- Dashboard Stats Grid accepts real values.
- Recent Transactions Card accepts real transaction data.
- Dashboard refreshes after adding transactions, approving/rejecting/settling, adding workers, and adding tools.
- Dashboard Quick Actions are working:
  - Issue Tool
  - Return Tool
  - Add Worker
  - Add Tool
- Added centralized colors for Dashboard stat cards.
- Desktop Dashboard tested.
- Tablet Dashboard tested.
- Mobile Dashboard tested.
- `flutter analyze` has no errors.

Future improvements:

- Add Dashboard loading skeletons or shimmer if needed.
- Add Dashboard empty states with better visual design if needed.
- Add trends/percentages later.
- Add role-based Dashboard cards later.
- Add dashboard date filters later if needed.
- Add dashboard cards for:
  - Pending Invitations
  - Pending Approvals
  - Pending Settlements
  - Recent Critical Activities
- Add subscription/plan card for owners/admins.
- Add storage usage card.
- Add stronger dashboard behavior for unstable network requests if needed.

---

# Phase G — Reports / PDF

## Status: Core Reports Implemented

Goal:

Generate professional PDF reports using real data and company settings.

Reports available / planned:

- Worker Custody Report
- Tool History Report
- Transactions Report
- Lost & Damaged Report
- Tool Summary Report
- Lost/Damaged Approval Report
- Worker Acknowledgment Report
- Future signed settlement report if needed

PDF uses:

- Company Profile
- Company Logo
- Report Settings
- Document Templates
- Worker data
- Tool data
- Transactions data
- Transaction snapshots
- Supabase Storage assets

Implemented:

- Added PDF dependencies:
  - `pdf`
  - `printing`
- Added `url_launcher` dependency to open signed approval documents.
- Created `ReportPdfService`.
- Refactored PDF generation into smaller files under:
  - `lib/features/reports/presentation/services/pdf/`
- Created `show_report_pdf_preview.dart`.
- Connected Reports UI to PDF preview.
- Added `PdfPreview` with print/share support.
- Hidden PDF preview debug toggle.
- Made `CompanySettingsCubit` global inside `AppShell`.
- Passed company profile, report settings, and document templates to PDF generation.
- Loaded company logo bytes from Supabase Storage bucket `company-assets`.
- Added company header to PDF reports.
- Added report title and generated date.
- Added Document Control section.
- Added Filters section.
- Added real data tables.
- Added Approval column to transaction-based PDF tables.
- Added Responsibility Statement section.
- Added Signature Section.
- Added page numbers to every PDF page.
- Applied `dateFormat` to PDF dates.
- Added Approval Status Filter in Reports UI.
- Added Lost/Damaged Approval Report.
- Fixed long PDF layout issues.
- Tested PDF Preview on Windows, mobile, and tablet.
- Company logo appears in PDF report header.
- Reports responsive regression fix completed.
- Reports can generate offline using already-loaded in-memory data.
- If online assets such as company logo are unavailable offline, reports can still generate without crashing.
- `flutter analyze` has no errors.

Current PDF section order:

1. Company Header
2. Report Title / Generated Date
3. Document Control
4. Filters
5. Report Data / Approval Form
6. Responsibility Statement
7. Signature Section
8. Footer Text
9. Page X of Y

Future improvements:

- Add PDF Approval Status Summary section.
- Add better PDF table layouts for long reports if needed.
- Add Worker Acknowledgment Report using `custody_acknowledgements` and `custody_acknowledgement_items`.
- Add optional settlement/deduction report if needed.
- Add export/download history flow if needed beyond `PdfPreview` printing/sharing.
- Improve time formatting based on `company_report_settings.timeFormat`.
- Improve timezone handling based on `company_report_settings.defaultTimezone`.
- Consider server-side PDF optimization later if large PDFs become a real issue.
- Do not image-compress PDF files.

---

# Phase H — Lost/Damaged Approval & Settlement Workflow

## Status: Core Workflow Implemented / Offline-Aware

Goal:

Build a controlled workflow for Lost/Damaged transactions so that tools remain in worker custody until the correct business process is completed.

Correct business flow:

1. Warehouse creates Lost or Damaged transaction.
2. Transaction status becomes Pending Approval.
3. Tool remains in worker custody.
4. Warehouse prints Lost/Damaged Approval Report.
5. Worker signs the report.
6. Manager reviews and signs Approve or Reject.
7. Signed document is uploaded to the system.
8. If rejected:
   - Transaction becomes Rejected.
   - Tool remains in worker custody.
9. If approved:
   - Transaction becomes Approved.
   - Tool still remains in worker custody until financial/administrative settlement is completed.
10. After salary deduction or final settlement:
   - Settlement becomes Settled.
   - Tool is removed from worker custody balance.

Implemented:

- Pending Lost/Damaged transactions remain in worker custody.
- Approved Lost/Damaged transactions pending settlement remain in worker custody.
- Settled Lost/Damaged transactions are removed from worker custody.
- Lost/Damaged Approval Report is working.
- Upload Signed Approval Document is working.
- Signed approval document images are compressed before upload when the file is an image.
- Signed approval document PDF files are uploaded without image compression.
- View Signed Document works online.
- View Signed Document is blocked offline with clear dialog message.
- Dashboard Open Custodies / Closed Today logic updated to respect settlement rules.
- Pending Approvals UI refactored into smaller widgets.
- Dashboard refreshes after Approve / Reject / Settle.

Future improvements:

- Add optional signed settlement/deduction report.
- Add audit trail entries for approval/settlement actions.
- Add stronger role-based permissions for who can approve/reject/settle.
- Add optional notification flow for pending approvals and settlements.
- Add mobile/tablet camera capture for signed approval document photos.

---

# Phase I — Android Signed Document Opening

## Status: Done

Implemented:

- Added Android handling for opening signed approval document URLs.
- Confirmed View Signed Document works on Android Emulator when online.
- Signed document viewing is now blocked offline with a clear user message.

Future improvements:

- Add better in-app document preview if needed.
- Add cached document preview later if secure offline cache is implemented.

---

# Phase J — Large File Refactor Checkpoint

## Status: Mostly Done

Goal:

Keep the codebase readable, modular, and maintainable as the app grows.

Implemented:

- Several large feature files were split into focused widgets/services.
- Pending Approvals UI was refactored into smaller widgets.
- PDF generation was split into smaller files.
- Reports services were organized under PDF-specific service folders.
- Transaction Cubit was split into part files for load/search, CRUD, approval workflow, and calculations.
- UI behavior was preserved during refactors.

Future improvements:

- Continue refactoring any file that becomes too large.
- Keep business logic out of UI widgets where possible.
- Continue moving repeated widgets/helpers into core or feature-specific folders.

---

# Phase K — Flutter SDK Upgrade Checkpoint

## Status: Done

Implemented:

- Flutter SDK upgrade checkpoint completed.
- New warnings and compatibility issues were handled where needed.
- Responsive behavior was tested after upgrade.
- Existing feature flows continued working after upgrade.

Future improvements:

- Re-test platform builds after future Flutter upgrades.
- Watch for package compatibility changes, especially:
  - Supabase
  - file_picker
  - printing/pdf
  - image
  - url_launcher
  - connectivity_plus

---

# Phase L — Responsive & Orientation Hardening

## Status: Done

Goal:

Harden the app layout across mobile and tablet orientations and prevent UI overflows when rotating between portrait and landscape.

Completed:

- Ran full rotation audit on:
  - Mobile Portrait
  - Mobile Landscape
  - Tablet Portrait
  - Tablet Landscape
- Tested all main screens:
  - Dashboard
  - Workers
  - Tools
  - Transactions
  - Reports
  - Lookups
  - Company Settings
- Fixed mobile landscape shell behavior:
  - Mobile landscape no longer switches to TabletShell.
- Fixed tablet landscape shell behavior:
  - Tablet landscape remains TabletShell.
- Fixed large simulated Android/iOS tablet behavior:
  - Large mobile/tablet simulations do not switch to DesktopShell.
- Workers layout selection was hardened.
- Tools layout selection was hardened.
- Transactions layout selection was hardened.
- Reports responsive regression fix completed.
- Compact landscape search behavior improved.
- Long forms remain scrollable.
- Dialogs and bottom sheets respect available height.
- `flutter analyze` has no errors after implementation.

Future improvements:

- Continue testing each new screen on all layouts.
- Add additional responsive refinements only when needed.
- Re-test all layouts before production release.

---

# Phase M — Storage & Image Optimization

## Status: Done

Goal:

Reduce storage usage, improve upload performance, and prevent large original images from being uploaded directly to Supabase Storage.

The image optimization strategy must work across:

- Windows Desktop
- Android phones
- Android tablets
- iOS devices later
- Future supported platforms where possible

Completed:

- Added cross-platform image compression service:
  - `lib/core/services/image_compression_service.dart`
- Used the Dart `image` package for cross-platform compression/resizing.
- Removed dependency on platform-specific image compression after Windows support issue.
- Implemented compression from local `File`.
- Implemented compression from `Uint8List` bytes.
- Added validation for:
  - Empty image bytes
  - Invalid quality range
  - Invalid max dimension
  - Unsupported file extensions
  - PDF files being passed to image compression
- Supported image types:
  - JPG
  - JPEG
  - PNG
  - WEBP
- PDF files are not image-compressed.
- Transaction proof images are compressed before upload.
- Signed approval document images are compressed before upload when the selected file is an image.
- Signed approval document PDF files are uploaded as-is without image compression.
- Company logo images are resized/compressed before upload.
- Company logo max dimension is centralized in `ImageCompressionService`.
- Company logo quality is centralized in `ImageCompressionService`.
- Storage upload still saves only cloud storage paths in database records.
- Transaction proof storage path remains under:
  - `{companyId}/transactions/{transactionCode}/...`
- Company logo storage path remains under:
  - `{companyId}/logo/...`
- Tested image upload on Windows after fixing platform compression issue.
- Tested signed approval image upload after compression.
- Tested signed approval PDF upload without image compression.
- Tested company logo upload after compression/resizing.
- Tested PDF reports after logo compression.
- `flutter analyze` has no errors after implementation.

Files updated during Phase M:

- `pubspec.yaml`
- `pubspec.lock`
- `lib/core/services/image_compression_service.dart`
- `lib/features/transactions/data/services/transaction_storage_service.dart`
- `lib/features/company_settings/data/repo/company_settings_repo.dart`

Current behavior:

- Transaction proof image upload:
  - Compress image.
  - Resize only if needed.
  - Upload compressed bytes.
  - Store uploaded cloud path.
- Approval document upload:
  - If PDF: upload original PDF bytes.
  - If image: compress image before upload.
  - Store uploaded cloud path.
- Company logo upload:
  - Compress/resize image.
  - Upload compressed bytes.
  - Update `companies.logo_path`.
  - Delete old logo after successful upload.
- PDF report logo:
  - Loads company logo from Supabase Storage.
  - Displays logo in PDF report header.

Future improvements:

- Add max upload size validation before compression.
- Add friendly error messages for very large or invalid files.
- Add camera capture support for mobile/tablet transaction proof images.
- Add camera capture support for mobile/tablet signed approval document images.
- Keep existing file upload flow as a fallback.
- Add image preview before upload if needed.
- Add optional image crop/rotate before upload if needed.
- Preserve PNG/WebP transparency where possible for company logos.
- Track storage usage per company.
- Enforce storage limits based on company subscription plan.
- Add storage usage card in Dashboard or Company Settings.
- Add storage cleanup/history flow if needed.
- Consider server-side PDF optimization later if large PDFs become a real issue.
- Do not image-compress PDF files.

---

# Phase N — Offline & Network Handling

## Status: In Progress

Goal:

Provide clear, safe, and professional behavior when the user is offline or the internet connection is unstable.

Completed:

- `NetworkStatusService`.
- `NetworkStatusCubit`.
- `NetworkStatusState`.
- `GlobalOfflineBanner`.
- App shell integrated with network watcher.
- Offline banner appears when app context is loaded and network is offline.
- Offline screen appears when Current Context cannot load due to no connection.
- Retry action added for Current Context failure/offline screen.
- AppMessage system added:
  - Success
  - Error
  - Warning
  - Info
- Transaction save blocked offline.
- Transaction proof upload blocked offline.
- Signed approval document upload blocked offline.
- Company logo upload blocked offline.
- Cloud proof image viewing blocked offline.
- Cloud signed document viewing blocked offline.
- Workers add/update/delete blocked offline.
- Tools add/update/delete blocked offline.
- Lookups add/delete blocked offline.
- Company Settings mutations blocked offline:
  - Company Profile update
  - Report Settings update
  - Document Template update
  - Company Logo upload
- Settings action failures remain inside loaded Settings screen.
- Messages inside Bottom Sheets/Dialogs were adjusted where SnackBars would be hidden.

Current behavior:

- Offline does not allow new writes/mutations.
- Offline does not allow Storage uploads.
- Offline does not allow cloud-only Storage file viewing.
- Reports can still generate from already-loaded data.
- No full offline sync is implemented yet.

Next implementation step:

**Friendly Network Error Mapper**

Purpose:

Convert technical errors like:

- `SocketException`
- `Failed host lookup`
- `ClientException`
- `StorageException`
- `PostgrestException` where appropriate

Into user-friendly messages.

Pending in Phase N:

- Add centralized `AppErrorMessage`.
- Apply it gradually to:
  - TransactionsCubit
  - WorkersCubit
  - ToolsCubit
  - LookupsCubit
  - CompanySettingsCubit
  - CurrentContextCubit
  - DashboardCubit if needed
  - Report asset loading if needed
- Improve handling for unstable connections where connectivity exists but Supabase calls fail.
- Keep validation/business-rule errors separate from network errors.

Future offline features, not part of first-stage Phase N:

- Local offline transaction drafts.
- Pending sync queue.
- Offline cache for proof images/documents.
- Offline cache for company context.
- Conflict resolution after reconnect.
- Secure cached documents if sensitive.

---

# Commercial / SaaS Backlog

## Status: Not Started

Required future features:

- Company subscription table/model.
- Free plan default assignment.
- Paid plan records.
- Plan status checks.
- Usage counters.
- Worker limits.
- Tool limits.
- Transaction limits.
- Storage limits.
- Feature gating.
- Subscription required / expired screen.
- Owner/admin subscription page.
- “Contact your company admin to manage subscription” message.
- Production billing approach decision:
  - Website
  - Invoice
  - Customer portal
  - Store billing review if mobile payments are ever added

Future packaging/distribution:

- Free mobile app download.
- Login-based access.
- Company subscription managed outside mobile app where appropriate.
- Desktop installer for Windows.
- Web landing page for marketing and subscription information.

---

# Users / Roles / Invitations Backlog

## Status: Not Started

Required future features:

- Secure invitation system.
- Supabase Edge Function for invite flow.
- Company user management screen.
- Role assignment.
- Role-based UI permissions.
- Database-level role permission enforcement.
- Pending invitations screen.
- Accept invitation flow.
- Select company flow for users with multiple memberships.
- Audit logs for role and membership changes.

Potential roles:

- Owner
- Admin
- Warehouse Manager
- Storekeeper
- Viewer / Auditor

---

# Storage Limits / Usage Backlog

## Status: Not Started

Required future features:

- Track storage usage per company.
- Track transaction proof storage.
- Track approval document storage.
- Track company logo storage.
- Enforce storage quota per subscription plan.
- Add storage usage card in Dashboard or Company Settings.
- Add cleanup/history view if needed.
- Prevent uploads when storage limit is reached.
- Show friendly upgrade message when storage limit is reached.

---

# Camera Capture Backlog

## Status: Not Started

Required future features:

- Mobile/tablet camera capture for transaction proof images.
- Mobile/tablet camera capture for signed approval document images.
- Camera capture should remain optional.
- File picker upload should remain supported as fallback.
- Captured images must be compressed before upload.
- Captured image paths must not be stored in Supabase.
- Only uploaded cloud paths should be stored in database.
- Add preview/retake flow if needed.

---

# Reports Backlog

## Status: Partially Started

Future reports/features:

- Worker Acknowledgment Report.
- Settlement/Deduction Report if needed.
- PDF Approval Status Summary.
- Export/download history.
- Report generation history table if required.
- Better large PDF performance handling.
- Server-side PDF generation if client-side generation becomes too slow.
- Role-based report access.
- Plan-based report limits if needed.

---

# Production Release Backlog

## Status: Not Started

Required future checklist:

- Production Supabase project.
- Environment configuration.
- Privacy Policy.
- Terms of Service.
- Support contact.
- Demo/review account for app stores if required.
- Android release build.
- iOS release build.
- Desktop installer.
- Landing page.
- Backup/restore strategy.
- Monitoring/logging strategy.
- Final security/RLS review.
- Final responsive/device testing.
- Final offline/network testing.
- Final storage limit testing.
- Final subscription/plan testing.

---

# Current Next Action

Continue Phase N.

Next implementation step:

**Friendly Network Error Mapper**

Suggested commit after next step:

`Add friendly network error mapper`

After the mapper is applied and tested, update this roadmap again and commit:

`Update roadmap after offline network handling`