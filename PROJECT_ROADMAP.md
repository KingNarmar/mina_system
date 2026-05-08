# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Project Vision

Mina System is a Flutter + Supabase application for managing tool custody, warehouse workers, tools, transactions, dashboard data, company settings, approvals, settlements, PDF reports, responsive layouts, users, roles, subscriptions, usage limits, storage limits, offline-aware behavior, and production-ready distribution.

The system is being built as a real multi-company SaaS/product, not a local demo.

Every company must have isolated data using `currentCompanyId`.

The product must support:

- Free download from stores.
- Free plan / trial plan.
- Paid monthly packages.
- B2B company subscriptions.
- Web landing page.
- Desktop installer download.
- Mobile app distribution through Google Play and App Store.
- Production Supabase environment separate from development/testing.
- Safe storage usage through image compression and storage limits.
- Clear behavior when the user is offline or the internet connection is unstable.
- Mobile/tablet camera capture for faster proof/document upload workflows.
- File upload fallback from device storage.

---

# Core Rules

## Development Rules

- Work step by step.
- Do not make large changes in one step.
- Do not change a working UI unless needed.
- Always review the real GitHub repo before continuing a new step.
- Do not rely only on README because it may be outdated.
- If a file becomes too large, refactor it into smaller focused files without changing working behavior.
- Every new feature must be tested on:
  - Windows
  - Mobile portrait
  - Mobile landscape
  - Tablet portrait
  - Tablet landscape
- After each completed feature:
  - Test
  - Run `dart format lib`
  - Run `flutter analyze`
  - Commit
  - Push
  - Review repo again.

## Architecture Rules

Follow this pattern for each feature:

1. Model
2. Repository / Service
3. Cubit / State when needed
4. UI
5. SQL Grants when needed
6. RLS Policies when needed
7. Test
8. Commit / Push

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
- Storage files must be saved in Supabase Storage.
- Database should store file paths only, not local file paths.
- Transactions should not be deleted from the system.
- Transaction editing should not be exposed as a normal UI action.
- Transaction corrections should be handled by corrective transactions, approval workflow, settlement workflow, or future void workflow.
- Lost/Damaged transactions should not reduce worker custody balance while pending approval.
- Lost/Damaged transactions should not reduce worker custody balance after approval only.
- Lost/Damaged transactions should reduce worker custody balance only after final settlement/deduction is completed.
- Company users must access company data only through active company membership.
- RLS must enforce role permissions at database level, not UI only.
- Plan limits must be enforced at database/RPC level, not UI only.
- Subscription access must be checked securely using company subscription records.
- Colors should be centralized inside `AppColors`.
- Do not use direct widget-level colors like `Colors.green` or `Colors.orange` unless they are first added to `AppColors`.

## Responsive / Adaptive Rules

- Do not assume mobile is always portrait.
- Do not assume tablet is always landscape.
- Do not lock orientation as a shortcut unless there is a clear business reason.
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
- Android/iOS tablets should remain TabletShell even when the screen width is large.
- DesktopShell should be used for desktop platforms, not for large simulated Android/iOS tablets.

## Storage / Image Optimization Rules

- Never upload large original images without compression unless there is a business reason.
- Transaction proof images must be compressed before upload.
- Approval document images should be compressed before upload when they are image files.
- PDF files should not be image-compressed.
- Company logos should be resized/compressed carefully without destroying quality.
- Company logos should be resized to a practical maximum dimension before upload.
- Store only the compressed/uploaded cloud path in the database.
- Keep the original local file path out of Supabase tables.
- Use clear storage paths under company folders:
  - `{companyId}/transactions/...`
  - `{companyId}/logo/...`
  - `{companyId}/documents/...`
- Image compression should work across Windows, Android, iOS, tablets, and future supported platforms.
- Prefer cross-platform image processing where possible to avoid platform-specific upload failures.
- Future storage usage must be tracked per company for plan limits.
- Mobile and tablet users should be able to capture photos directly from the camera for transaction proof images and approval document images, not only upload existing files from device storage.
- Camera capture should make the workflow faster:
  - Open camera directly from the transaction/proof upload action.
  - Capture the item/tool/document immediately.
  - Compress the captured image before upload.
  - Store only the uploaded cloud path in the database.
- Camera capture should remain optional.
- File upload from device storage should remain supported as a fallback.

## Offline / Network Rules

- The app must not fail silently when there is no internet connection.
- The user must see a clear offline message when connection is unavailable.
- Saving new transactions while offline should be blocked at first until full offline sync is implemented.
- Later, offline transaction drafts and pending sync can be added safely.
- Network errors must be user-friendly and separated from validation/auth errors where possible.
- Retry actions should be available on critical loading screens.
- Offline mode must never bypass RLS, subscription limits, or business rules.

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

## Current Main Gap

The next priority is offline/network handling because the roadmap requires clear behavior when the user is offline or the internet connection is unstable.

---

# Auth Status

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

---

# Current Context Status

## Status: Done

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

No company → Create Company screen

One company → Dashboard

Multiple companies → Select Company placeholder

Required future behavior:

Pending invitation exists → Accept Invitation screen

Active membership exists → Select Company / Dashboard

No invitation and no membership → Create or Join Company screen

Required future behavior after subscriptions:

Current company loaded
→ Check subscription/plan
→ Check plan status
→ Check usage limits
→ Continue or show limited/expired state

Required future behavior after offline handling:

No internet while loading context
→ Show offline/network error screen
→ Retry when internet returns
→ Later: load last cached read-only company context if offline cache is implemented

---

# Create Company Flow Status

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

## Company Profile Status

### Status: Done

Implemented:

- Read company profile from `companies`.
- Update company profile.
- Update TopBar company name without reloading the dashboard.
- Company profile is used inside PDF report headers.

Fields:

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

Future improvements:

- Add subscription section inside Company Settings for owners/admins.
- Show current plan name.
- Show plan status.
- Show usage summary.
- Show upgrade/contact message without direct mobile payment link.
- Add billing/contact email fields if needed later.
- Add storage usage summary after storage tracking is implemented.

## Company Logo Upload Status

### Status: Done

Implemented:

- Pick image using `file_picker`.
- Upload image to Supabase Storage bucket: `company-assets`.
- Save `logo_path` in `companies`.
- Delete old logo after successful new upload.
- Show success SnackBar.
- Company logo is used inside generated PDF reports.
- PDF logo refresh works without restarting the app after changing the logo.
- Company logo image compression/resizing is implemented before upload.
- Company logo max dimension is handled through `ImageCompressionService`.
- Company logo upload uses compressed bytes instead of uploading the original selected image.
- Company logo is displayed inside PDF report headers.

Storage path format:

`{companyId}/logo/company-logo-{timestamp}.{extension}`

Allowed image types:

- PNG
- JPG
- JPEG
- WEBP

Current image optimization behavior:

- Logo images are resized/compressed before upload.
- Logo max dimension is currently centralized in `ImageCompressionService`.
- Current company logo max dimension: `800 px`.
- Current company logo quality: `90`.
- PDF files are not allowed for company logo upload.

Pending / Future Enhancements:

- Preserve transparency when possible for PNG/WebP logos.
- Add max upload size validation before compression.
- Add friendly error if logo file is too large or invalid.
- Track logo storage usage under company storage quota.
- Add optional visual preview/crop flow before uploading logo if needed.
- Fine-tune PDF logo box size if future real company logos require different layout.

## Report Settings Status

### Status: Done

Implemented:

- Read `company_report_settings`.
- Update report settings.
- Show success SnackBar.
- Report settings are used inside PDF reports.
- Applied `dateFormat` to PDF dates.
- Fixed PDF date format normalization.

Pending / Future Enhancements:

- Apply `timeFormat` to PDF timestamps.
- Apply `defaultTimezone` to report generation dates/times.
- Add plan-based report watermark if company is on Free plan if needed.
- Add report export history if required later.

## Document Templates Status

### Status: Done

Implemented:

- `CompanyDocumentTemplateModel`
- `documentTemplates` added to `CompanySettingsState`
- `getCompanyDocumentTemplates` added to `CompanySettingsRepo`
- `updateCompanyDocumentTemplate` added to `CompanySettingsRepo`
- `updateCompanyDocumentTemplate` added to `CompanySettingsCubit`
- SQL grants and RLS policies for `company_document_templates`
- Document Templates UI inside Company Settings
- Read document templates by company
- Update document template fields
- Document templates are used inside PDF Document Control section.
- Robust PDF template matching added.
- Document template signature labels are used inside PDF Signature Section.

Pending / Future Enhancements:

- Add plan-based access to advanced template customization if needed.
- Keep basic templates available for Free plan.
- Keep advanced customization for paid plans if used commercially.

---

# Phase B — Lookups Supabase Integration

## Status: Done

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
- Loading state and error banner.
- Add/Delete flows.
- Duplicate prevention inside the same company.
- Strong lookup name normalization.
- Delete protection for dependent data where applicable.
- `flutter analyze` has no errors.

Rules applied:

- Used `currentCompanyId`.
- Added grants and RLS policies before testing.
- Kept existing UI as much as possible.

Future improvements:

- Add plan-based lookup limits if needed.
- Add import defaults from industry templates later.
- Add offline-friendly error message if lookups fail due to no internet.

---

# Phase C — Workers Supabase Integration

## Status: Done

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
- Added loading state and error banner.
- Connected Add / Update / Delete Worker actions to Supabase.
- Search workers by existing search logic.
- `flutter analyze` has no errors.

Database rules confirmed:

- `workers.company_id` references `companies(id)`.
- `workers.department_id` references `departments`.
- `workers.job_title_id` is constrained to match the selected department.
- `hr_code` is unique inside the same company.
- `worker_code` is unique inside the same company.
- Department and Job Title deletion is protected by foreign key rules when workers depend on them.

Pending / Future Enhancements:

- Enforce plan limit before adding a worker.
- Add friendly upgrade message when worker limit is reached.
- Add database/RPC-level worker limit enforcement.
- Add offline-friendly message if worker add/update/delete fails due to no internet.

---

# Phase D — Tools Supabase Integration

## Status: Done

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
- Added loading/submitting state and error banner.
- Connected Add / Update / Delete Tool actions to Supabase.
- Search tools by existing search logic.
- `flutter analyze` has no errors.

Database rules confirmed:

- `tools.company_id` references `companies(id)`.
- `tools.unit_id` is constrained to match a valid `tool_units` record for the same company.
- `tools.category_id` is constrained to match a valid `tool_categories` record for the same company.
- `tool_code` is unique inside the same company.
- `tool_name` has a normalized unique index inside the same company.
- Tool Unit and Tool Category deletion is protected by foreign key constraints when tools depend on them.

Pending / Future Enhancements:

- Enforce plan limit before adding a tool.
- Add friendly upgrade message when tool limit is reached.
- Add database/RPC-level tool limit enforcement.
- Add offline-friendly message if tool add/update/delete fails due to no internet.
- Add stronger database-level open-custody delete protection if needed.

---

# Phase E — Transactions / Custody Core Supabase Integration

## Status: Done

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
- Added loading overlay and error banner.
- Fixed transaction proof image display in details dialog.
- Fixed transaction proof thumbnail display in desktop table.
- Fullscreen proof image preview now uses resolved signed URL.
- Search/filter transactions works.
- Custody Balance is calculated from real Supabase transactions.
- Tool Summary is calculated from real Supabase transactions.
- Closed Today count is calculated from real Supabase transactions.
- Signed approval document images are compressed before upload when they are image files.
- Signed approval document PDF files are uploaded without image compression.
- `flutter analyze` has no errors.

Business rules confirmed:

- Transactions should not be deleted.
- Normal edit/delete buttons should not be shown for transactions.
- Corrections should be done by corrective transactions or a future controlled approval/void workflow.
- Issue and Return are normal custody movement records.
- Lost and Damaged enter pending approval flow.
- Images must be stored in Supabase Storage, not as local file paths.

Latest custody balance rule:

- Pending Lost/Damaged transactions do not reduce worker custody balance.
- Rejected Lost/Damaged transactions do not reduce worker custody balance.
- Return transactions reduce custody balance immediately.
- Lost/Damaged transactions reduce worker custody balance only after final settlement/deduction is completed.

Pending / Future Enhancements:

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
- Keep file upload from device storage available as a fallback option.
- Add clear offline behavior:
  - First stage: block transaction submission while offline.
  - Later stage: save transaction draft locally and sync later.

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

Pending / Future Enhancements:

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
- Add offline banner at dashboard level when connection is unavailable.

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

Pending / Future Enhancements:

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

## Status: Core Workflow Implemented

Goal:

Build a controlled workflow for Lost/Damaged transactions so that tools remain in the worker custody until the correct business process is completed.

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
- View Signed Document works on Windows.
- View Signed Document works on Android Emulator after Android signed URL fix.
- Dashboard Open Custodies / Closed Today logic updated to respect settlement rules.
- Pending Approvals UI refactored into smaller widgets.
- Dashboard refreshes after Approve / Reject / Settle.

Pending / Future Enhancements:

- Add optional signed settlement/deduction report.
- Add audit trail entries for approval/settlement actions.
- Add stronger role-based permissions for who can approve/reject/settle.
- Add optional notification flow for pending approvals and settlements.
- Add mobile/tablet camera capture for signed approval document photos.

---

# Phase M — Storage & Image Optimization

## Status: Step M.1 Completed / Cross-Platform Image Compression Implemented

Goal:

Reduce storage usage, improve upload performance, and prevent large original images from being uploaded directly to Supabase Storage.

The image optimization strategy must work across:

- Windows Desktop
- Android phones
- Android tablets
- iOS devices later
- Future supported platforms where possible

Completed in Step M.1:

- Added cross-platform image compression service:
  - `lib/core/services/image_compression_service.dart`
- Used the Dart `image` package for cross-platform compression/resizing.
- Removed dependency on platform-specific image compression after Windows support issue.
- Implemented compression from local `File`.
- Implemented compression from `Uint8List` bytes.
- Added validation for:
  - Empty image bytes.
  - Invalid quality range.
  - Invalid max dimension.
  - Unsupported file extensions.
  - PDF files being passed to image compression.
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

Files updated during Phase M Step M.1:

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
  - Delete old logo after successful new upload.
- PDF report logo:
  - Loads company logo from Supabase Storage.
  - Displays logo in PDF report header.

Pending / Future Enhancements:

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

# Phase L — Responsive & Orientation Hardening

## Status: Step L.1 Completed / Rotation Audit Passed

Goal:

Harden the app layout across mobile and tablet orientations and prevent UI overflows when rotating between portrait and landscape.

Completed in Step L.1:

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
  - 13-inch tablet landscape no longer switches to DesktopShell.
  - Tablet layout remains TabletShell on Android/iOS simulated tablets.
- Made `ResponsiveLayout` DevicePreview-aware.
- Fixed internal layout selection for:
  - Workers
  - Tools
  - Transactions
- Mobile landscape now keeps mobile card-based layouts instead of switching to desktop tables.
- Fixed Reports card overflow on tablet.
- Fixed Reports mobile RenderBox layout crash.
- Fixed searchable selection bottom sheet behavior in compact landscape.
- Fixed transaction search visibility while keyboard is open in mobile landscape.
- Fixed custody balance search visibility while keyboard is open in mobile landscape.
- Fixed tool summary search visibility while keyboard is open in mobile landscape.
- Fixed Lookups input visibility while keyboard is open in mobile landscape.
- Tested PDF preview on mobile and tablet.
- Ran:
  - `dart format lib`
  - `flutter analyze`
- Result:
  - No issues found.

Files updated during Phase L Step L.1:

- `lib/core/responsive/responsive_layout.dart`
- `lib/core/widgets/custom_text_form_field.dart`
- `lib/core/widgets/searchable_selection_field.dart`
- `lib/features/dashboard/presentation/widgets/quick_action_card.dart`
- `lib/features/workers/presentation/screens/workers_screen.dart`
- `lib/features/tools/presentation/screens/tools_screen.dart`
- `lib/features/transactions/presentation/screens/transactions_screen.dart`
- `lib/features/transactions/presentation/widgets/layouts/transactions_mobile_layout.dart`
- `lib/features/transactions/presentation/widgets/transaction_search_field.dart`
- `lib/features/transactions/presentation/widgets/custody_balance/custody_balance_search_field.dart`
- `lib/features/transactions/presentation/widgets/custody_balance/layouts/custody_balance_mobile_layout.dart`
- `lib/features/transactions/presentation/widgets/tool_custody_summary/tool_custody_summary_search_field.dart`
- `lib/features/transactions/presentation/widgets/tool_custody_summary/layouts/tool_custody_summary_mobile_layout.dart`
- `lib/features/reports/presentation/screens/reports_screen.dart`
- `lib/features/reports/presentation/widgets/report_option_card.dart`
- `lib/features/lookups/presentation/screens/lookups_screen.dart`
- `lib/features/lookups/presentation/widgets/lookup_add_row.dart`
- `lib/features/lookups/presentation/widgets/departments_tab.dart`
- `lib/features/lookups/presentation/widgets/job_titles_tab.dart`
- `lib/features/lookups/presentation/widgets/tool_units_tab.dart`
- `lib/features/lookups/presentation/widgets/tool_categories_tab.dart`

Testing result:

Tablet Portrait / Tablet Landscape:

- Dashboard: Passed
- Workers: Passed
- Tools: Passed
- Transactions: Passed
- Reports: Passed
- Lookups: Passed
- Company Settings: Passed

Mobile Portrait / Mobile Landscape:

- Dashboard: Passed
- Workers: Passed
- Tools: Passed
- Transactions: Passed
- Reports: Passed
- Lookups: Passed
- Company Settings: Passed

## Phase L Regression Fix During Phase M

Status: Done

Reason:

During company logo and PDF testing, Reports card overflow appeared again in a specific tablet layout, and a follow-up fix briefly caused a mobile list layout issue.

Implemented:

- Reports card layout adjusted to support both:
  - Tablet/Desktop grid with finite card height.
  - Mobile list with natural card height.
- Fixed card overflow on tablet.
- Fixed mobile `RenderBox was not laid out` issue after the first regression fix attempt.

Related files updated:

- `lib/features/reports/presentation/screens/reports_screen.dart`
- `lib/features/reports/presentation/widgets/report_option_card.dart`

Pending / Future Enhancements:

- Re-test on real physical Android tablet if available.
- Re-test on real physical Android phone if available.
- Re-test on iOS simulator/device later before App Store release.
- Consider extracting shared compact landscape keyboard behavior into a reusable helper/widget if the same pattern repeats in future screens.

---

# Maintenance Checkpoint — Flutter SDK Upgrade

## Status: Done

Goal:

Upgrade Flutter SDK safely after the project reached a stable checkpoint.

Completed:

- Upgraded Flutter SDK.
- Flutter after upgrade: `3.41.9`.
- Channel: `stable`.
- Ran `flutter doctor`.
- Result: `No issues found`.
- Ran `flutter pub get`.
- Ran `dart format lib`.
- Ran `flutter analyze`.
- Result: `No issues found`.
- Ran the app on Windows.
- Tested:
  - Login
  - Dashboard
  - Workers
  - Tools
  - Transactions
  - Company Settings
- Flutter upgrade was committed separately.
- Changes pushed to GitHub.

Commit message:

`Upgrade Flutter SDK and verify project`

---

# Maintenance Checkpoint — Large File Refactor

## Status: Mostly Done / One Deferred Model

Goal:

Reduce large Dart files into smaller, more maintainable modules without changing working behavior.

Completed:

- Refactored Pending Approvals UI into smaller widgets.
- Refactored Report PDF table sections into smaller report-specific files.
- Refactored Transaction Details dialog into smaller detail widgets.
- Refactored LookupsCubit using Dart part files.
- Refactored TransactionsCubit using Dart part files.
- Refactored TransactionsRepo into a facade delegating to specialized services:
  - `TransactionStorageService`
  - `TransactionApprovalService`
  - `TransactionCodeService`
- Ran `dart format lib`.
- Ran `flutter analyze`.
- Result: no issues.
- Changes committed and pushed.

Files intentionally deferred:

- `lib/features/transactions/data/models/transaction_model.dart`

Reason:

- It is a central model used by transactions, dashboard, reports, and approval workflow.
- It is only slightly above 300 lines.
- Refactor can be done later using safe part files:
  - `transaction_model_json.dart`
  - `transaction_model_copy_with.dart`
  - `transaction_model_parsers.dart`

Rule:

- Do not refactor this model during feature work.
- Refactor it later as a small isolated maintenance commit.

Future maintenance additions:

- Add dedicated network status service/cubit:
  - `lib/core/network/network_cubit.dart`
  - `lib/core/network/network_state.dart`
- Add plan/limits service:
  - `lib/features/subscriptions/...`
- Keep commercial logic out of widgets where possible.
- Keep image compression logic centralized inside:
  - `lib/core/services/image_compression_service.dart`
- Do not duplicate image compression logic inside repositories or widgets.

---

# Maintenance Checkpoint — Android Signed Document Opening

## Status: Done

Goal:

Fix opening signed approval documents on Android emulator / Android devices.

Problem:

- `View Signed Document` worked on Windows.
- On Android emulator, `url_launcher` could not open signed Supabase URLs correctly.
- Android logs showed messages like:
  - `component name for https://... is null`

Implemented:

- Added Android package visibility queries for:
  - `https`
  - `http`
- Preserved Flutter engine `PROCESS_TEXT` query.
- Updated signed document button to use `launchUrl` directly instead of relying on `canLaunchUrl`.

Files touched:

- `android/app/src/main/AndroidManifest.xml`
- `lib/features/transactions/presentation/widgets/details/transaction_signed_document_button.dart`

Testing:

- Tested `View Signed Document` on Android emulator.
- Signed Supabase approval document URL opens successfully.
- `flutter analyze` has no errors.

---

# Next Recommended Phase — Offline / Network Handling

## Suggested Phase Name

# Phase N — Offline & Network Handling

## Status: Not Started

Goal:

Prevent silent failures when the app has no internet connection or unstable network access.

Why this is next:

- The roadmap requires clear offline/network behavior.
- Transactions should not be submitted while offline until full offline sync exists.
- Current Supabase-backed flows depend on internet access.
- Users need friendly retry/error messages instead of unclear failures.

Suggested Step N.1:

Add a dedicated network status foundation:

- Add dependency if needed:
  - `connectivity_plus`
- Add:
  - `lib/core/network/network_state.dart`
  - `lib/core/network/network_cubit.dart`
  - `lib/core/network/network_status_service.dart` if needed
- Detect:
  - Online
  - Offline
  - Unknown/checking
- Show a simple app-level offline banner or screen where appropriate.
- Do not implement offline sync yet.
- Do not allow offline transaction submission yet.

Suggested Step N.2:

Block transaction submission while offline:

- If offline:
  - Do not upload proof image.
  - Do not create transaction.
  - Show clear message:
    - `You are offline. Please reconnect before submitting this transaction.`
- Keep current online flow unchanged.

Suggested Step N.3:

Add retry behavior for critical loading screens:

- Current Context loading.
- Dashboard loading.
- Transactions loading.
- Reports data loading if needed.

Future Offline Enhancements:

- Local read-only cache for selected data.
- Offline transaction drafts.
- Pending sync queue.
- Conflict handling.
- Secure sync after reconnect.
- Never bypass RLS, subscriptions, or company isolation.

---

# Future Commercial / SaaS Roadmap

## Subscriptions / Plans

Status: Not Started

Goal:

Support Free and Paid company-based plans without creating separate apps.

Future requirements:

- Add subscription tables.
- Add company subscription records.
- Assign Free plan by default after company creation.
- Check subscription during Current Context loading.
- Show subscription status in Company Settings.
- Show plan card in Dashboard for owners/admins.
- Enforce limits at database/RPC level, not UI only.
- Keep mobile app payment behavior safe:
  - No direct payment buttons inside mobile apps until store billing rules are reviewed.
  - Prefer website, invoice, or customer portal for B2B payments.

Possible plan limits:

- Workers count.
- Tools count.
- Monthly transactions.
- Storage usage.
- Advanced document template customization.
- Advanced reports.
- Export history.

## Company Users / Invitations

Status: Not Started

Goal:

Allow company owners/admins to invite users safely.

Future requirements:

- Do not call Supabase Admin Auth directly from Flutter.
- Use secure backend / Supabase Edge Function for invitations.
- Pending invitation flow by email.
- Accept invitation flow.
- Join existing company flow.
- Role-based permissions:
  - Owner
  - Admin
  - Warehouse User
  - Viewer
- RLS must enforce permissions at database level.
- UI should only reflect permissions, not be the only enforcement.

## Roles & Permissions

Status: Not Started

Goal:

Control who can view, create, approve, reject, settle, or configure data.

Future requirements:

- Stronger role-based permissions for:
  - Workers
  - Tools
  - Transactions
  - Reports
  - Company Settings
  - Lost/Damaged approvals
  - Settlements
- RLS policies must enforce role permissions.
- Approval and settlement actions should be restricted to authorized roles.

## Storage Usage Tracking

Status: Not Started

Goal:

Track storage usage per company and enforce plan limits.

Future requirements:

- Track uploaded file sizes.
- Track company storage usage.
- Track storage per bucket/category:
  - Transaction proofs
  - Approval documents
  - Company logos
  - Future documents
- Add storage usage summary in Dashboard or Company Settings.
- Enforce storage limits based on subscription plan.
- Add cleanup/history flow if needed.

## Production Release Readiness

Status: Not Started

Goal:

Prepare the app for real production deployment.

Future requirements:

- Production Supabase project.
- Separate development/testing environment.
- Environment configuration.
- Privacy Policy.
- Terms of Service.
- Support contact.
- Demo/review account for app stores if required.
- App icons.
- App signing.
- Google Play release checklist.
- App Store release checklist.
- Desktop installer packaging.
- Web landing page.
- Desktop installer download page.

---

# Current Next Action

After this roadmap update is committed and pushed, continue with:

## Phase N — Offline & Network Handling

Recommended first step:

`Step N.1 — Add network status foundation`

Small step only:

- Add network dependency if needed.
- Create network state/cubit/service.
- Do not change transaction submission yet.
- Run:
  - `dart format lib`
  - `flutter analyze`
- Test on Windows first.
- Then test mobile/tablet behavior.