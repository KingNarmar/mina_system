# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Project Vision

Mina System is a Flutter + Supabase application for managing tool custody, warehouse workers, tools, transactions, dashboard data, company settings, users, roles, invitations, approvals, settlements, audit logs, responsive layouts, and professional PDF reports for companies and warehouses.

The system is being built as a real multi-company SaaS/product, not a local demo.

Every company must have isolated data using `currentCompanyId`.

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

---

# Current Project Status

## Auth Status: Done

Implemented:

- Login is working.
- Register is working.
- Email confirmation is working.
- Auth redirect between Login / Register / Dashboard is working.

Current flow:

```text
Register → Confirm Email → Login → Create Company if no company exists → Dashboard
```

Required future flow after Company Users / Invitations:

```text
Register/Login
→ Check pending invitations by email
→ Check active company memberships
→ If invited: Accept Invitation / Join Company
→ If already member: Select Company or Dashboard
→ If no membership and no invitation: Create Company
```

---

## Current Context Status: Done

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

```dart
context.currentCompanyId
context.currentProfileId
context.currentUserRole
context.requireCurrentCompanyId()
context.requireCurrentProfileId()
context.requireCurrentUserRole()
```

Current behavior:

```text
No company → Create Company screen
One company → Dashboard
Multiple companies → Select Company placeholder
```

Required future behavior:

```text
Pending invitation exists → Accept Invitation screen
Active membership exists → Select Company / Dashboard
No invitation and no membership → Create or Join Company screen
```

---

## Create Company Flow Status: Done

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

---

# Company Settings

## Company Profile Status: Done

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

---

## Company Logo Upload Status: Done

Implemented:

- Pick image using `file_picker`.
- Upload image to Supabase Storage bucket: `company-assets`.
- Save `logo_path` in `companies`.
- Delete old logo after successful new upload.
- Show success SnackBar.
- Company logo is used inside generated PDF reports.
- PDF logo refresh works without restarting the app after changing the logo.

Storage path format:

```text
{companyId}/logo/company-logo-{timestamp}.{extension}
```

Allowed image types:

- PNG
- JPG
- JPEG
- WEBP

---

## Report Settings Status: Done

Implemented:

- Read `company_report_settings`.
- Update report settings.
- Show success SnackBar.
- Report settings are used inside PDF reports.

Fields:

- Default Timezone
- Date Format
- Time Format
- Show Company Logo
- Show Company Details
- Show Document Control
- Show Generated By
- Report Footer Text
- Custody Responsibility Statement
- Loss / Damage Responsibility Statement

PDF behavior connected:

- `showCompanyLogo`
- `showCompanyDetails`
- `showGeneratedBy`
- `showDocumentControl`
- `reportFooterText`
- `custodyResponsibilityStatement`
- `lossDamageResponsibilityStatement`
- `dateFormat`

Completed:

- Applied `dateFormat` to PDF dates.
- Fixed PDF date format normalization to support formats like:
  - `yyyy-MM-dd`
  - `dd/MM/yyyy`
  - `MM/dd/yyyy`
  - `dd-MM-yyyy`
  - `yyyy/MM/dd`

Pending / Future Enhancements:

- Apply `timeFormat` to PDF timestamps.
- Apply `defaultTimezone` to report generation dates/times.

---

## Document Templates Status: Done

Implemented:

- `CompanyDocumentTemplateModel`
- `documentTemplates` added to `CompanySettingsState`
- `getCompanyDocumentTemplates` added to `CompanySettingsRepo`
- `updateCompanyDocumentTemplate` added to `CompanySettingsRepo`
- `updateCompanyDocumentTemplate` added to `CompanySettingsCubit`
- SQL grants and RLS policies for `company_document_templates`
- Document Templates UI inside Company Settings
- Replaced Document Templates placeholder with real UI
- Read document templates by company
- Update document template fields
- Show success SnackBar after update
- Document templates are used inside PDF Document Control section.
- Robust PDF template matching added to handle values like:
  - `worker_custody`
  - `worker_custody_report`
  - `Worker Custody Report`
  - matching document titles
- Document template signature labels are used inside PDF Signature Section.

Fields supported:

- Report Type
- Document Title
- Document Code
- Issue No
- Revision No
- Effective Date
- Prepared By Title
- Checked By Title
- Approved By Title
- Worker Signature Label
- Manager Signature Label
- Storekeeper Signature Label
- Is Active

PDF behavior connected:

- Document Code
- Document Title
- Issue No.
- Revision
- Effective Date
- Report Type
- Prepared By
- Approved By
- Worker Signature Label
- Manager Signature Label
- Storekeeper Signature Label

---

# Phase B — Lookups Supabase Integration

## Lookups Status: Done

Goal:

Replace local/static lookups with Supabase-backed lookups.

Implemented:

- Real Supabase-backed lookup tables:
  - `departments`
  - `job_titles`
  - `tool_units`
  - `tool_categories`
- SQL grants and RLS policies for:
  - SELECT
  - INSERT
  - UPDATE
  - DELETE
- `DepartmentModel`
- `JobTitleModel`
- `ToolUnitModel`
- `ToolCategoryModel`
- `LookupsRepo`
- Read lookups by `company_id`
- Load lookups after `CurrentContextLoaded`
- Loading state in Lookups screen
- Error banner in Lookups screen
- Add Department
- Delete Department
- Prevent deleting Department when it has Job Titles
- Add Job Title
- Delete Job Title
- Add Tool Unit
- Delete Tool Unit
- Add Tool Category
- Delete Tool Category
- Duplicate prevention inside the same company
- Strong lookup name normalization:
  - ignores case
  - ignores spaces
  - ignores symbols like `-` and `_`
- Tested Add/Delete/Duplicate prevention for:
  - Departments
  - Job Titles
  - Tool Units
  - Tool Categories
- `flutter analyze` has no errors.
- Changes committed and pushed to GitHub.

Rules applied:

- Used `currentCompanyId`.
- Added grants and RLS policies before testing.
- Kept existing UI as much as possible.

---

# Phase C — Workers Supabase Integration

## Workers Status: Done

Goal:

Replace local workers state with Supabase data.

Implemented:

- Checked real Supabase columns for `workers`.
- Checked workers RLS / grants / constraints.
- Added DELETE grant and DELETE RLS policy for `workers`.
- Updated `WorkerModel` to support Supabase columns:
  - `id`
  - `company_id`
  - `worker_code`
  - `hr_code`
  - `full_name`
  - `department_id`
  - `job_title_id`
  - `phone`
  - `email`
  - `status`
  - `notes`
  - `created_by_profile_id`
  - `created_at`
  - `updated_at`
- Kept UI-friendly fields:
  - `name`
  - `hrCode`
  - `department`
  - `jobTitle`
- Created `WorkersRepo`.
- Read workers by `company_id`.
- Added worker.
- Updated worker.
- Deleted worker.
- Generated `worker_code` automatically.
- Prevented duplicate `hr_code` inside the same company.
- Used real Department and Job Title IDs from Lookups.
- Loaded workers after `CurrentContextLoaded`.
- Added loading state in Workers screen.
- Added error banner in Workers screen.
- Connected Add Worker form to Supabase.
- Connected Update Worker form to Supabase.
- Connected Delete Worker action to Supabase.
- Search workers by existing search logic.
- Tested reading workers from Supabase.
- Tested Add Worker.
- Tested duplicate HR Code prevention.
- Tested Search Worker.
- Tested Update Worker.
- Tested Delete Worker.
- `flutter analyze` has no errors.
- Changes committed and pushed to GitHub.

Database rules confirmed:

- `workers.company_id` references `companies(id)`.
- `workers.department_id` references `departments`.
- `workers.job_title_id` is constrained to match the selected department.
- `hr_code` is unique inside the same company.
- `worker_code` is unique inside the same company.
- Department and Job Title deletion is protected by `ON DELETE RESTRICT` when workers depend on them.

Rules applied:

- Used real Supabase data.
- Used `currentCompanyId`.
- Used `currentProfileId` for `created_by_profile_id`.
- Used lookup models/data for Department and Job Title.
- Added loading and error states.
- Kept existing Workers UI as much as possible.

---

# Phase D — Tools Supabase Integration

## Tools Status: Done

Goal:

Replace local tools state with Supabase data.

Implemented:

- Checked real Supabase columns for `tools`, `tool_units`, and `tool_categories`.
- Checked tools RLS / grants / constraints / indexes / enum values.
- Confirmed `tool_status` enum values:
  - `active`
  - `inactive`
  - `discontinued`
- Fixed `tools` table grants for authenticated CRUD access.
- Removed unsafe/unneeded `anon` access from `tools`.
- Added DELETE RLS policy for `tools`.
- Confirmed tools RLS policies for:
  - SELECT
  - INSERT
  - UPDATE
  - DELETE
- Updated `ToolModel` to support Supabase columns:
  - `id`
  - `company_id`
  - `tool_code`
  - `tool_name`
  - `unit_id`
  - `category_id`
  - `description`
  - `status`
  - `created_by_profile_id`
  - `created_at`
  - `updated_at`
- Kept UI-friendly fields:
  - `toolName`
  - `unit`
  - `category`
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
- Added loading state in Tools screen.
- Added submitting state in Tools screen.
- Added error banner in Tools screen.
- Connected Add Tool form to Supabase.
- Connected Update Tool form to Supabase.
- Connected Delete Tool action to Supabase and waits for success before showing success message.
- Search tools by existing search logic.
- Kept existing desktop/mobile Tools UI as much as possible.
- Tested reading tools from Supabase.
- Tested Add Tool.
- Tested duplicate Tool Name prevention.
- Tested Update Tool.
- Tested Delete Tool.
- Ran `flutter analyze` successfully with no issues.
- Changes committed and pushed to GitHub.

Database rules confirmed:

- `tools.company_id` references `companies(id)`.
- `tools.unit_id` is constrained to match a valid `tool_units` record for the same company.
- `tools.category_id` is constrained to match a valid `tool_categories` record for the same company.
- `tool_code` is unique inside the same company.
- `tool_name` has a normalized unique index inside the same company.
- Tool Unit and Tool Category deletion is protected by foreign key constraints when tools depend on them.

Note:

- Tool deletion protection now depends on loaded transaction state.
- A stronger database-level open-custody delete protection can be added later if required.

---

# Phase E — Transactions / Custody Core Supabase Integration

## Transactions Core Status: Done

Goal:

Replace local transactions state with Supabase-backed transaction records and build the real custody movement flow.

Transaction types:

- Issue
- Return
- Lost
- Damaged

Implemented:

- Checked real Supabase columns for transaction/custody-related tables:
  - `transactions`
  - `custody_acknowledgements`
  - `custody_acknowledgement_items`
- Confirmed transaction table columns:
  - `id`
  - `company_id`
  - `transaction_code`
  - `transaction_type`
  - `worker_id`
  - `worker_hr_code_snapshot`
  - `worker_name_snapshot`
  - `worker_department_snapshot`
  - `worker_job_title_snapshot`
  - `tool_id`
  - `tool_code_snapshot`
  - `tool_name_snapshot`
  - `tool_unit_snapshot`
  - `tool_category_snapshot`
  - `quantity`
  - `proof_image_path`
  - `note`
  - `approval_required`
  - `approval_status`
  - `created_by_profile_id`
  - `created_at`
  - `updated_at`
- Checked enum values:
  - `transaction_kind`: `issue`, `return`, `lost`, `damaged`
  - `approval_status`: `not_required`, `pending`, `approved`, `rejected`
  - `report_status`: `signed`, `voided`
- Checked transactions RLS / grants / constraints.
- Fixed `transactions` grants for authenticated:
  - SELECT
  - INSERT
  - UPDATE
- No DELETE grant was added for transactions.
- Confirmed RLS policies:
  - Members can read transactions.
  - Owner/admin/warehouse users can insert transactions.
  - Owner/admin/warehouse users can update only `not_required` or `pending` transactions.
- Confirmed database constraints:
  - Quantity must be greater than zero.
  - Issue requires proof image.
  - Damaged requires proof image.
  - Lost requires note.
  - Damaged requires note.
  - Lost/Damaged require approval flow.
  - `proof_image_path` must not be a local path.
  - `proof_image_path` must start with `{companyId}/`.
- Confirmed Storage bucket:
  - `transaction-proofs`
- Confirmed Storage policies:
  - Company members can read transaction proofs.
  - Owner/admin/warehouse users can upload transaction proofs.
- Updated `TransactionModel` to support Supabase columns.
- Created `TransactionsRepo`.
- Read transactions by `company_id`.
- Add transaction to Supabase.
- Update transaction capability exists at repo/cubit level for future controlled flows.
- Auto-generate transaction code from Supabase records.
- Upload proof images to Supabase Storage bucket `transaction-proofs`.
- Store only cloud storage paths in `transactions.proof_image_path`.
- Added `TransactionsState` loading/submitting/error fields.
- Refactored `TransactionsCubit` to use Supabase.
- Loaded transactions after `CurrentContextLoaded`.
- Connected Add Transaction form to Supabase.
- Added loading overlay in Transactions screen.
- Added error banner in Transactions screen.
- Fixed transaction proof image display in details dialog.
- Fixed transaction proof thumbnail display in desktop table.
- Fullscreen proof image preview now uses resolved signed URL.
- Search/filter transactions works.
- Custody Balance is calculated from real Supabase transactions.
- Tool Summary is calculated from real Supabase transactions.
- Closed Today count is calculated from real Supabase transactions.
- Tested Issue transaction.
- Tested proof image upload.
- Tested proof image display in details.
- Tested proof image thumbnail in table.
- Tested Return transaction.
- Tested Return quantity cannot exceed balance.
- Tested Lost without note validation.
- Tested Lost with note:
  - `approval_required = true`
  - `approval_status = pending`
- Tested Damaged without image validation.
- Tested Damaged with image and note:
  - `approval_required = true`
  - `approval_status = pending`
- `flutter analyze` completed successfully with no issues.
- Changes committed and pushed to GitHub.

Business rules confirmed:

- Transactions should not be deleted.
- Normal edit/delete buttons should not be shown for transactions.
- Corrections should be done by corrective transactions or a future controlled approval/void workflow.
- Issue and Return are normal custody movement records.
- Lost and Damaged enter pending approval flow.
- Images must be stored in Supabase Storage, not as local file paths.

Latest custody balance rule update:

- Pending Lost/Damaged transactions no longer reduce worker custody balance.
- Rejected Lost/Damaged transactions do not reduce worker custody balance.
- Return transactions reduce custody balance immediately.
- Lost/Damaged transactions reduce worker custody balance only after final settlement/deduction is completed.

Pending / Future Enhancements:

- Add Void/Correction workflow if needed.
- Generate custody acknowledgement PDFs from real transactions.
- Use `custody_acknowledgements` and `custody_acknowledgement_items` in reports/signature flow.
- Add database-level open-custody protection for deleting tools/workers if needed.

---

# Phase F — Dashboard Supabase Data

## Dashboard Status: Done

Goal:

Replace static/dummy Dashboard data with real Supabase-backed company data.

Implemented:

- Created `DashboardSummaryModel`.
- Created `DashboardRepo`.
- Created `DashboardState`.
- Created `DashboardCubit`.
- Added `DashboardCubit` to `AppShell`.
- Fixed `AppShell` provider scope by moving the `BlocListener` into `_AppShellView`.
- Loaded dashboard summary after `CurrentContextLoaded`.
- Dashboard summary reads real data by `company_id`.
- Total Workers comes from Supabase `workers`.
- Total Tools comes from Supabase `tools`.
- Open Custodies comes from real transactions.
- Closed Today comes from real closing transactions.
- Fixed Closed Today timezone handling by converting transaction dates to local time before comparison.
- Dashboard Closed Today logic updated after settlement workflow:
  - Return counts as closed immediately.
  - Lost/Damaged counts as closed only after settlement.
  - Pending approval is not closed.
  - Approved but pending settlement is not closed.
  - Rejected is not closed.
- Recent Transactions comes from real Supabase transactions.
- Dashboard Stats Grid accepts real values.
- Dashboard Stats Grid is self-connected to `DashboardCubit`.
- Recent Transactions Card accepts real transaction data.
- Recent Transactions Card is self-connected to `DashboardCubit`.
- Dashboard refreshes after adding any new transaction.
- Dashboard refreshes after Approve / Reject / Settle.
- Dashboard refreshes after Add Worker / Add Tool.
- Dashboard Quick Actions are working:
  - Issue Tool
  - Return Tool
  - Add Worker
  - Add Tool
- Added `AppColors.success`.
- Added `AppColors.warning`.
- Removed direct widget-level colors for Dashboard stat cards.
- Kept the existing Dashboard UI as much as possible.
- Desktop Dashboard tested.
- Tablet Dashboard tested.
- Mobile Dashboard tested.
- Recent Transactions displays correctly across desktop/tablet/mobile.
- Closed Today updates after Return and Settlement.
- Open Custodies updates after Issue/Return/Settlement.
- `flutter analyze` completed successfully with no issues.
- Dashboard screenshots were intentionally updated and pushed.
- Changes committed and pushed to GitHub.

Dashboard real stats:

- Total Workers
- Total Tools
- Open Custodies
- Closed Today
- Recent Transactions

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

---

# Maintenance Checkpoint — Flutter SDK Upgrade

## Flutter Upgrade Status: Done

Goal:

Upgrade Flutter SDK safely after the project reached a stable checkpoint.

Completed:

- Confirmed current Flutter version and channel.
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
- No upgrade warnings/errors needed fixing.
- Flutter upgrade was committed separately.
- Changes pushed to GitHub.

Commit message:

```text
Upgrade Flutter SDK and verify project
```

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

```text
lib/features/transactions/data/models/transaction_model.dart
```

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
- Signed approval documents now open correctly on Android.

Files touched:

```text
android/app/src/main/AndroidManifest.xml
lib/features/transactions/presentation/widgets/details/transaction_signed_document_button.dart
```

Testing:

- Tested `View Signed Document` on Android emulator.
- Signed Supabase approval document URL opens successfully.
- `flutter analyze` has no errors.

---

# Phase G — Reports / PDF

## Reports / PDF Status: In Progress / Core Reports Implemented

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

PDF must use:

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
- Added `url_launcher` dependency to open signed approval documents using temporary signed URLs.
- Generated platform plugin registrant updates for PDF/printing related dependencies.
- Created `ReportPdfService`.
- Refactored PDF generation into smaller files under:

```text
lib/features/reports/presentation/services/pdf/
```

- Created `show_report_pdf_preview.dart`.
- Connected Reports UI button from `PDF Coming Soon` to `Preview PDF`.
- Added `PdfPreview` with print/share support.
- Hidden PDF preview debug toggle using `canDebug: false`.
- Tested PDF Preview on Windows.
- Made `CompanySettingsCubit` global inside `AppShell`.
- Removed duplicated local `CompanySettingsCubit` provider from `CompanySettingsScreen`.
- Fixed company logo refresh issue without app restart.
- Passed company profile, report settings, and document templates to PDF generation.
- Loaded company logo bytes from Supabase Storage bucket `company-assets`.
- Added company header to PDF reports:
  - Company logo
  - Company trade/name
  - Legal name
  - Address
  - Phone
  - Email
  - Website
- Added report title and generated date.
- Added Document Control section controlled by `showDocumentControl`.
- Added Filters section.
- Added real data tables for:
  - Worker Custody Report
  - Tool Summary Report
  - Tool History / Transactions / Lost & Damaged reports using transaction list table
- Added Approval column to transaction-based PDF tables.
- Added footer text from `reportFooterText`.
- Added Responsibility Statement section:
  - Worker Custody Report uses `custodyResponsibilityStatement`
  - Lost & Damaged Report uses `lossDamageResponsibilityStatement`
  - Lost/Damaged Approval Report uses `lossDamageResponsibilityStatement`
- Added Signature Section after Responsibility Statement and before Footer Text.
- Signature Section uses document template labels:
  - `workerSignatureLabel`
  - `managerSignatureLabel`
  - `storekeeperSignatureLabel`
- Added safe fallback labels:
  - Worker Signature
  - Manager Signature
  - Storekeeper Signature
- Added page numbers to every PDF page:
  - `Page X of Y`
- Applied `dateFormat` to PDF dates.
- Fixed PDF date format normalization.
- Improved Document Template matching for PDF reports.
- Added Approval Status Filter in Reports UI.
- Connected Approval Status Filter to preview and PDF filtering.
- Added Approval Status to PDF Filters section.
- Added `lostDamagedApproval` report type.
- Added Lost/Damaged Approval Report to Reports Center.
- Added Lost/Damaged Approval Report PDF preview support.
- Added Lost/Damaged Approval Report file name support.
- Added Lost/Damaged Approval Report filter/preview/PDF support.
- Added polished approval form layout for Lost/Damaged Approval Report.
- Fixed initial `TooManyPagesException` by making the PDF layout lighter and split into smaller PDF widgets.
- Tested long PDFs with page numbering.
- Tested Date Format change in PDF.
- Tested Approval column in transaction PDF table.
- Tested Approval Status filter.
- Tested Lost/Damaged Approval Report PDF preview.
- `flutter analyze` has no errors after report changes.
- Report PDF changes were committed and pushed in multiple small commits.

Current PDF section order:

```text
Company Header
Report Title / Generated Date
Document Control
Filters
Report Data / Approval Form
Responsibility Statement
Signature Section
Footer Text
Page X of Y
```

Important files:

```text
lib/features/reports/data/models/report_option_model.dart
lib/features/reports/presentation/widgets/report_builder_panel.dart
lib/features/reports/presentation/functions/show_report_pdf_preview.dart
lib/features/reports/presentation/services/report_pdf_service.dart
lib/features/reports/presentation/services/pdf/
lib/features/reports/presentation/widgets/report_filter_section.dart
lib/features/reports/presentation/widgets/filters/
lib/features/reports/presentation/widgets/report_preview_section.dart
lib/features/reports/presentation/functions/report_filter_helpers.dart
lib/features/company_settings/presentation/cubit/company_settings_cubit.dart
lib/features/company_settings/presentation/cubit/company_settings_state.dart
lib/features/company_settings/data/models/company_profile_model.dart
lib/features/company_settings/data/models/company_report_settings_model.dart
lib/features/company_settings/data/models/company_document_template_model.dart
```

Pending / Future Enhancements:

- Add PDF Approval Status Summary section:
  - Total Transactions
  - Pending
  - Approved
  - Rejected
  - Not Required
- Add better PDF table layouts for long reports if needed.
- Add Worker Acknowledgment Report using `custody_acknowledgements` and `custody_acknowledgement_items`.
- Add optional settlement/deduction report if needed.
- Add export/download history flow if needed beyond `PdfPreview` printing/sharing.
- Improve time formatting based on `company_report_settings.timeFormat`.
- Improve timezone handling based on `company_report_settings.defaultTimezone`.

---

# Phase H — Lost/Damaged Approval & Settlement Workflow

## Status: Core Workflow Implemented

Goal:

Build a controlled workflow for Lost/Damaged transactions so that tools remain in the worker custody until the correct business process is completed.

Business problem:

When a worker loses or damages a tool, the warehouse should not immediately remove the item from the worker custody just because a Lost/Damaged transaction was created.

The correct business flow is:

```text
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
```

## Implemented Database / Storage

Added fields to `transactions`:

```text
approval_document_path
approval_decision_note
approval_decided_by_profile_id
approval_decided_at

settlement_status
settlement_note
settled_by_profile_id
settled_at
```

Added enum:

```text
transaction_settlement_status
```

Enum values:

```text
not_required
pending_settlement
settled
```

Created private Supabase Storage bucket:

```text
transaction-approval-documents
```

Signed approval document storage path format:

```text
{companyId}/transactions/{transactionCode}/approval-document-{timestamp}.{extension}
```

Rules:

- `approval_document_path` stores only the Supabase Storage path.
- Signed approval documents are opened using temporary signed URLs.
- Local file paths must not be stored in the database.
- Approval document uploads are restricted by RLS/storage policies.
- Company members can read approval documents through safe storage policies.
- Owner/Admin/Warehouse users can upload signed approval documents when allowed.

## Implemented Model Updates

Updated `TransactionModel` with:

```text
approvalDocumentPath
approvalDecisionNote
approvalDecidedByProfileId
approvalDecidedAt

settlementStatus
settlementNote
settledByProfileId
settledAt
```

Added helper getters:

```text
isLostOrDamaged
isApprovalPending
isApprovalApproved
isApprovalRejected
isSettlementNotRequired
isPendingSettlement
isSettled
```

## Implemented Repository Methods

Added controlled methods in `TransactionsRepo`:

```dart
uploadApprovalDocument(...)
createApprovalDocumentSignedUrl(...)
approveLostDamagedTransaction(...)
rejectLostDamagedTransaction(...)
settleApprovedLostDamagedTransaction(...)
```

Rules:

- Normal transaction editing is not exposed as a general UI action.
- Approval/Reject/Settlement are handled through controlled repo methods.
- Signed document viewing uses `createSignedUrl` from the private `transaction-approval-documents` bucket.

## Implemented Cubit Methods

Added controlled methods in `TransactionsCubit`:

```dart
uploadApprovalDocument(...)
approveTransaction(...)
rejectTransaction(...)
settleTransaction(...)
```

Validation rules:

```text
Approve/Reject:
- Only allowed for Lost/Damaged transactions.
- Only allowed when approval_status = pending.
- Signed approval document must be uploaded before approval/rejection.

Settle:
- Only allowed for Lost/Damaged transactions.
- Only allowed when approval_status = approved.
- Only allowed when settlement_status = pending_settlement.
```

## Implemented UI

Added:

```text
Transactions → Pending Approvals
```

Pending Approvals supports:

```text
View
Upload Signed / Replace Signed
Approve
Reject
Settle
```

Pending Approvals fields:

```text
Transaction Code
Worker
Tool
Type
Quantity
Approval Status
Settlement Status
Actions
```

Transaction Details now shows:

```text
Approval Status
Settlement Status
Signed Document status
View Signed Document button
Approval Decision Note
Approval Decided At
Settlement Note
Settled At
```

Signed document behavior:

- The file is stored in Supabase Storage.
- The user can open it later from Transaction Details.
- The app generates a temporary signed URL.
- The signed URL opens externally using `url_launcher`.
- Android link opening is fixed through AndroidManifest `http/https` queries and direct `launchUrl`.

## Implemented PDF

Added:

```text
Lost/Damaged Approval Report
```

Added:

- `lostDamagedApproval` in `ReportType`
- Reports Center card
- Preview support
- PDF generation support
- PDF title support
- PDF file name support
- Filter support
- Approval Status filter support
- Responsibility Statement support
- Signature Section support

Lost/Damaged Approval Report includes:

```text
Company Header
Document Control
Filters
Transaction Summary
Worker Information
Tool Information
Incident Reason / Note
Evidence & Documents
Approval Decision box
Responsibility Statement
Signature Section
Footer
Page numbers
```

PDF fixes:

- Initial layout was too heavy and caused `TooManyPagesException`.
- The layout was fixed by making the approval form lighter and split into smaller PDF widgets.
- Final preview tested successfully.

## Implemented Custody Balance Rules

```text
Issue:
- Adds to custody balance.

Return:
- Reduces custody balance immediately.

Lost/Damaged Pending Approval:
- Does not reduce custody balance.

Lost/Damaged Rejected:
- Does not reduce custody balance.

Lost/Damaged Approved but Pending Settlement:
- Does not reduce custody balance.

Lost/Damaged Approved and Settled:
- Reduces custody balance.
```

Updated:

```text
custody_balance_calculator.dart
dashboard_repo.dart
```

Now Lost/Damaged reduces custody balance only when:

```text
approval_status = approved
settlement_status = settled
```

This also affects:

- Worker custody balance
- Tool summary open custody quantity
- Dashboard Open Custodies
- Dashboard Closed Today
- Any dependent custody calculations

## Tested End-to-End

Tested:

- Create Lost/Damaged transaction.
- Transaction appears as Pending Approval.
- Tool remains in worker custody.
- Upload signed approval document.
- View signed approval document from Transaction Details.
- Approve transaction.
- Tool remains in custody while Pending Settlement.
- Settle transaction.
- Tool is removed from custody balance only after settlement.
- Reject transaction keeps tool in custody.
- Lost/Damaged Approval PDF preview works.
- PDF layout issue was fixed.
- Dashboard updates after settlement.
- Android signed document link opens correctly.
- `flutter analyze` has no errors.
- Changes were committed and pushed.

## Completed Implementation Steps

```text
Step H.1 — Add approval/settlement database fields and policies. ✅
Step H.2 — Update TransactionModel with approval document and settlement fields. ✅
Step H.3 — Update TransactionsRepo select/update methods. ✅
Step H.4 — Add upload signed approval document logic. ✅
Step H.5 — Add approve/reject/settle methods in TransactionsCubit. ✅
Step H.6 — Add Pending Approvals UI. ✅
Step H.7 — Add Lost/Damaged Approval PDF report. ✅
Step H.8 — Update custody balance logic to reduce only after settlement. ✅
Step H.9 — Update Dashboard Closed Today logic after settlement rules. ✅
Step H.10 — Test complete flow end-to-end. ✅
Step H.11 — Fix signed document link opening on Android. ✅
```

## Pending / Future Enhancements

- Add optional settlement/deduction report if needed.
- Add role-based UI visibility for approval/settlement actions.
- Add stronger audit/history if needed.
- Improve signed document preview/download UX if needed.
- Add database-level audit trail if needed.
- Add role-based restrictions in UI:
  - Warehouse user can create Lost/Damaged and upload signed documents.
  - Owner/Admin can approve/reject/settle.
- Add better settlement note input if needed.
- Add dashboard counters for:
  - Pending Approvals
  - Pending Settlements
  - Settled Lost/Damaged
- Add notification flow later if needed.

---

# Phase I — Multi-Company Improvements

Current status:

```text
Multiple companies → Placeholder
```

Needed:

- Select Company screen.
- Save selected company locally/session state.
- Allow switching company from TopBar later.
- Make all screens reload based on selected company.
- Ensure role changes with selected company.
- Add better UX for companies list.
- Add current company switching confirmation if there is unsaved work.
- Support user being a member in more than one company.
- Support accepted invitations creating company memberships.
- Avoid forcing Create Company when a pending invitation exists.

---

# Phase J — Roles & Permissions

Current roles expected:

- owner
- admin
- warehouse_manager
- warehouse_user
- data_entry
- viewer

Current database enum may still contain:

- owner
- admin
- warehouse_user

Required future role expansion:

```text
owner
admin
warehouse_manager
warehouse_user
data_entry
viewer
```

## Owner

Can manage:

- Everything
- Company settings
- Users
- Invitations
- Roles
- Lookups
- Workers
- Tools
- Transactions
- Reports
- Approvals
- Settlements
- Audit logs

## Admin

Can manage:

- Company settings
- Users except owner removal
- Invitations
- Roles except owner role
- Lookups
- Workers
- Tools
- Transactions
- Reports
- Approvals
- Settlements
- Audit logs

## Warehouse Manager

Can manage:

- Workers
- Tools
- Transactions
- Custody operations
- Generate reports
- Upload proof images
- Upload signed approval documents
- Approve / Reject / Settle if company policy allows

## Warehouse User

Can manage:

- Transactions
- Custody operations
- Upload proof images
- Upload signed approval documents if company policy allows
- View workers/tools/reports

Should not manage:

- Company settings
- Users
- Roles
- Financial settlement unless allowed

## Data Entry

Can manage:

- Workers
- Tools
- Lookups if allowed
- Basic master data

Should not manage:

- Approval
- Settlement
- Company settings
- Users
- Roles

## Viewer

Can view:

- Dashboard
- Reports
- Transactions
- Custody status

Should not manage:

- Company settings
- Lookups
- Tools
- Workers
- Transactions
- Approvals
- Settlements
- Users
- Roles

Pending:

- Add role-based UI visibility.
- Add role-based route protection.
- Add stronger RLS role checks for approval/settlement actions.
- Confirm owner/admin-only approval settlement policies.
- Hide approval/reject/settle actions from unauthorized users.
- Hide Company Settings from non-owner/admin users.
- Add user invitation flow.
- Add company members management UI.

---

# Phase K — Future Product Enhancements

Planned:

- Worker Acknowledgment Reports.
- Signed report storage.
- Void/Correction workflow.
- Database-level open-custody protection for deleting tools/workers.
- Better dashboard insights.
- Better PDF table layout for long reports.
- Export history.
- Notifications.
- Multi-company selection.
- Company switching.
- User invitation flow.
- Role management UI.
- Audit logs.
- Transaction correction flow.
- Settlement/deduction report if business needs it.
- Better signed document preview/download UI.
- Mobile/tablet UI polish.
- Better empty states.
- Dashboard trends.
- Search and filter improvements.
- Bulk import workers/tools if needed.
- Better reporting filters.
- Report templates versioning.
- Optional attachment history per transaction.
- Optional storage cleanup strategy for replaced files.
- Optional archived/inactive workers and tools improvements.
- Optional company subscription/licensing flow.
- Optional SaaS billing/tenant management flow.
- Optional offline-first support if needed later.
- Optional barcode/QR support for tools.
- Optional QR-based worker/tool selection.
- Optional approval notifications.
- Optional email export/share flow.

---

# Phase L — Responsive & Orientation Hardening

## Status: Planned / Immediate Next Step

Goal:

Fix mobile and tablet layout issues when the user rotates the device between portrait and landscape.

Current problem:

Some mobile/tablet screens break, overflow, or become hard to use after rotation.

The app already supports responsive layouts, but rotation testing must become a formal requirement before production release.

## Required Behavior

The app must work correctly in:

```text
Mobile Portrait
Mobile Landscape
Tablet Portrait
Tablet Landscape
Desktop
```

Rotation must not break:

```text
Dashboard
Workers
Tools
Transactions
Pending Approvals
Reports
Company Settings
PDF Preview dialogs
Transaction forms
Worker forms
Tool forms
Lookup forms
Document Templates
```

## Technical Rules

Use adaptive/responsive layout rules based on available width and constraints.

Preferred tools:

```text
MediaQuery.sizeOf(context)
LayoutBuilder
SafeArea
SingleChildScrollView where needed
Flexible / Expanded where needed
Wrap instead of overflowing Row where needed
ResponsiveLayout / AppBreakpoints
```

Use `OrientationBuilder` only for small widget-level layout changes when needed.

Avoid:

```text
Hard-coded heights that break in landscape.
Rows that overflow on narrow landscape layouts.
Dialogs taller than the available screen height.
Forms without scroll support.
Assuming tablet is always landscape.
Assuming mobile is always portrait.
Locking orientation as a shortcut unless there is a clear business reason.
```

## Required Fix Areas

Audit these screens first:

```text
Dashboard screen
Workers desktop/tablet/mobile layouts
Tools desktop/tablet/mobile layouts
Transactions screen
Pending Approvals layout
Add Transaction form
Add Worker form
Add/Edit Tool form
Reports builder / preview screen
Company Settings screen
Document Templates form
Lookups screen
PDF Preview modal/dialog
```

## Required Improvements

- Ensure every long form is scrollable in landscape.
- Ensure dialogs respect screen height.
- Ensure cards/grids reflow correctly when height becomes small.
- Ensure side navigation / rail does not cause content overflow.
- Ensure tables remain horizontally scrollable where needed.
- Ensure action buttons wrap instead of overflowing.
- Ensure tablet portrait and tablet landscape are both tested.
- Ensure mobile landscape does not cut off form fields or buttons.
- Add responsive constraints for large dialogs.
- Add `SafeArea` where content can be blocked by system UI.
- Keep UI design unchanged as much as possible.

## Manual Test Checklist

Test every screen in:

```text
Mobile Portrait
Mobile Landscape
Tablet Portrait
Tablet Landscape
```

Manual checks:

```text
Dashboard:
- Stats cards do not overflow.
- Recent transactions remain readable.
- Quick Actions remain clickable.

Workers:
- Table/card layout does not overflow.
- Add/Edit Worker form is scrollable.
- Search/filter remains usable.

Tools:
- Table/card layout does not overflow.
- Add/Edit Tool form is scrollable.
- Buttons remain visible.

Transactions:
- Add Transaction form is scrollable.
- Worker/tool autocomplete fields remain usable.
- Proof image picker does not break layout.
- Transaction table/card layout remains readable.

Pending Approvals:
- Action buttons wrap correctly.
- Upload / Approve / Reject / Settle remain visible.
- View Signed Document remains usable.

Reports:
- Report filters do not overflow.
- PDF Preview opens correctly.
- Preview dialog fits available space.

Company Settings:
- Company Profile form scrolls correctly.
- Report Settings form scrolls correctly.
- Document Templates form scrolls correctly.

Lookups:
- Add/Delete lookup forms remain usable.
```

## Implementation Steps

```text
Step L.1 — Run full mobile/tablet rotation audit.
Step L.2 — List broken screens with screenshots.
Step L.3 — Fix Dashboard rotation layout.
Step L.4 — Fix Workers/Tools rotation layout.
Step L.5 — Fix Transactions/Add Transaction rotation layout.
Step L.6 — Fix Pending Approvals rotation layout.
Step L.7 — Fix Reports/PDF Preview rotation layout.
Step L.8 — Fix Company Settings/Document Templates rotation layout.
Step L.9 — Fix Lookups rotation layout.
Step L.10 — Run full manual rotation test.
Step L.11 — Run dart format lib.
Step L.12 — Run flutter analyze.
Step L.13 — Commit and push.
```

---

# Phase M — Company Users, Invitations & Role Management

## Status: Planned / High Priority After Orientation Hardening

Goal:

Allow a company owner/admin to invite other users to the same company and assign each user a controlled role.

This phase is required before a production-ready Audit Trail because the system must reliably know:

```text
Who did the action?
Which company were they acting under?
What role did they have?
Were they allowed to perform that action?
```

## Business Problem

The first customer can register and create a company as Owner.

However, other employees should not create separate companies.

Correct flow:

```text
Owner/Admin → Invite User → User accepts invitation → User joins same company → User gets assigned role
```

Incorrect flow to prevent:

```text
Employee registers normally → Creates new company accidentally → Data becomes isolated in wrong tenant
```

## Required Database Tables

### company_members

Purpose:

Store active users inside a company.

Suggested fields:

```text
id
company_id
profile_id
role
status
invited_by_profile_id
joined_at
disabled_at
removed_at
created_at
updated_at
```

Suggested status values:

```text
active
disabled
removed
```

Suggested role values:

```text
owner
admin
warehouse_manager
warehouse_user
data_entry
viewer
```

Rules:

- A user can belong to multiple companies.
- A user can have different roles in different companies.
- A company must always have at least one owner.
- Owner cannot accidentally remove himself if he is the last owner.
- Disabled users cannot access company data.
- Removed users should not see the company anymore.

### company_invitations

Purpose:

Store pending, accepted, expired, or cancelled invitations.

Suggested fields:

```text
id
company_id
email
role
status
token_hash
invited_by_profile_id
accepted_by_profile_id
accepted_at
expires_at
cancelled_at
created_at
updated_at
```

Suggested status values:

```text
pending
accepted
expired
cancelled
```

Rules:

- Invitations are company-scoped.
- Invitation email must be normalized.
- Pending invitation should be unique per company/email.
- Invitation must expire after a configured period.
- Accepted invitation should create or activate `company_members`.
- Cancelled invitation cannot be accepted.
- Expired invitation cannot be accepted.
- Invitation acceptance must be handled safely.

## Required Backend / Edge Function

Do not call Supabase admin auth methods directly from Flutter.

Create secure Edge Functions or backend endpoints:

```text
invite_company_user
accept_company_invitation
cancel_company_invitation
resend_company_invitation
change_company_member_role
disable_company_member
reactivate_company_member
remove_company_member
archive_empty_company
```

Reason:

- Flutter must never contain service role keys.
- Admin invite requires protected server-side logic.
- RLS must still protect database access.

## Required UI

Add a new Company Settings section:

```text
Company Users
```

Tabs:

```text
Members
Invitations
Roles / Permissions
```

### Members Tab

Show:

```text
Name
Email
Role
Status
Joined At
Actions
```

Actions:

```text
Change Role
Disable User
Reactivate User
Remove User
```

Rules:

- Only Owner/Admin can manage users.
- Owner role changes are restricted.
- Last owner cannot be removed or downgraded.

### Invitations Tab

Show:

```text
Email
Role
Status
Invited By
Invited At
Expires At
Actions
```

Actions:

```text
Invite User
Resend Invite
Cancel Invite
Copy Invite Link if allowed
```

### Invite User Dialog

Fields:

```text
Email
Role
Optional message later
```

Validation:

```text
Email required
Valid email format
Role required
Cannot invite duplicate active member
Cannot invite duplicate pending invitation for same company
```

### Accept Invitation Screen

Shown when:

```text
User opens invite link
or
User logs in and has pending invitation by email
```

Must show:

```text
Company name
Invited role
Invited by
Accept invitation
Decline invitation
```

After accept:

```text
Create/Update profile
Create company_members row
Mark invitation as accepted
Set current company to invited company
Open dashboard
```

## User Safety UX for Accidental Company Creation

This is required for less experienced users.

### Before Create Company

When user has no active company membership, show Create Company screen with two clear choices:

```text
Create a New Company
Join an Existing Company
```

Create New Company must include warning:

```text
Create a new company only if you are the owner/admin setting up a new organization.
If your company already uses Mina System, ask your manager to invite you.
```

Add required confirmation checkbox:

```text
I confirm that I am authorized to create a new company account.
```

Add secondary action:

```text
I have an invitation / Join existing company
```

### CurrentContext Decision Order

Update CurrentContext loading order:

```text
1. Load current profile.
2. Check active company memberships.
3. Check pending invitations matching the authenticated email.
4. If pending invitations exist and no active company selected:
   show Accept Invitation / Join Company screen.
5. If active memberships exist:
   open dashboard or company selector.
6. If no active memberships and no pending invitations:
   show Create or Join Company screen.
```

### If User Creates a Company by Mistake

Add a safe cleanup strategy.

Do not immediately hard delete unless it is safe.

Possible handling:

```text
If company is empty:
- user can archive/delete accidental company from UI.
- only if:
  - company has exactly one member
  - member is owner
  - no real workers
  - no real tools
  - no transactions
  - no uploaded business documents
  - no other active members
```

Because default lookups/settings may exist, define “empty company” carefully:

```text
Empty company = no business records beyond system-generated defaults.
```

Business records that block deletion:

```text
workers
tools
transactions
custody_acknowledgements
uploaded approval documents
uploaded transaction proofs
additional company members
```

If company has business data:

```text
Archive only, do not hard delete.
```

Suggested company status:

```text
active
archived
deleted_pending
```

Archive behavior:

```text
Archived company disappears from normal selector.
Owner can restore it if needed.
Data remains protected by RLS.
No accidental data loss.
```

When user later accepts invitation to another company:

```text
Set current company to invited company.
Keep accidental company archived or allow safe deletion if empty.
Do not mix data between companies.
Never move business data automatically without explicit admin action.
```

Future optional admin/support tool:

```text
Find orphan/empty companies
Archive empty accidental companies
Permanently delete archived empty companies after retention period
```

## Required RLS Policies

RLS must protect:

```text
company_members
company_invitations
companies
all company-scoped business tables
```

Rules:

```text
Owner/Admin can invite users.
Owner/Admin can view members and invitations.
Members can view their own company membership.
Disabled/removed members cannot access company data.
Users can accept invitation only for their own email.
Only Owner/Admin can change roles.
Last owner cannot be removed/downgraded.
```

## Required App Behavior

After login:

```text
If user is active member of one company:
  open dashboard.

If user is active member of multiple companies:
  open company selector.

If user has pending invitation:
  show Accept Invitation screen.

If user has no membership and no invitation:
  show Create or Join Company screen.
```

## Implementation Steps

```text
Step M.1 — Inspect current profiles / companies / company_members schema.
Step M.2 — Design company_members and company_invitations schema.
Step M.3 — Add SQL migration for invitations and member statuses.
Step M.4 — Add/Update RLS policies for company member access.
Step M.5 — Add secure Edge Function for inviting users.
Step M.6 — Add secure Edge Function for accepting invitations.
Step M.7 — Add Company Users models.
Step M.8 — Add Company Users repo/service.
Step M.9 — Add Company Users Cubit/State.
Step M.10 — Add Company Users UI in Company Settings.
Step M.11 — Add Invite User dialog.
Step M.12 — Add Invitations tab.
Step M.13 — Add Accept Invitation screen.
Step M.14 — Update CurrentContextGate decision flow.
Step M.15 — Add Create or Join Company screen.
Step M.16 — Add accidental empty company archive/delete flow.
Step M.17 — Add role-based UI visibility.
Step M.18 — Add manual tests.
Step M.19 — Run dart format lib.
Step M.20 — Run flutter analyze.
Step M.21 — Commit and push.
```

## Manual Tests

Test:

```text
New owner registers and creates company.
Owner invites warehouse user.
Invited user accepts invitation.
Invited user opens same company.
Invited user cannot see other companies.
Warehouse user cannot open company settings if not allowed.
Owner can change user role.
Owner can disable user.
Disabled user cannot access company data.
User with pending invitation does not accidentally create company first.
User can still create company if truly starting a new organization.
Accidental empty company can be archived/deleted safely.
Company with transactions cannot be hard deleted.
Multiple company user sees company selector.
```

---

# Phase N — Audit Trail & Activity Logs

## Status: Planned / High Priority After Phase M

Goal:

Track who did what, when, and under which company.

This phase should come after Company Users / Invitations because audit logs depend on reliable user membership and roles.

Required audit coverage:

```text
Create Worker
Update Worker
Delete/Deactivate Worker
Create Tool
Update Tool
Delete/Deactivate Tool
Create Transaction
Upload Proof Image
Upload Signed Approval Document
Approve Transaction
Reject Transaction
Settle Transaction
Update Company Profile
Update Company Logo
Update Report Settings
Update Document Templates
Add Lookup
Delete Lookup
Invite User
Accept Invitation
Change Role
Disable User
Reactivate User
Remove User
Archive Company
```

Suggested table:

```text
audit_logs
```

Suggested fields:

```text
id
company_id
profile_id
user_email
user_role
action
entity_type
entity_id
entity_code
entity_name
old_values
new_values
metadata
created_at
```

Suggested action values:

```text
CREATE_WORKER
UPDATE_WORKER
DELETE_WORKER
CREATE_TOOL
UPDATE_TOOL
DELETE_TOOL
CREATE_TRANSACTION
UPLOAD_APPROVAL_DOCUMENT
APPROVE_TRANSACTION
REJECT_TRANSACTION
SETTLE_TRANSACTION
UPDATE_COMPANY_SETTINGS
INVITE_USER
ACCEPT_INVITATION
CHANGE_USER_ROLE
DISABLE_USER
ARCHIVE_COMPANY
```

Required UI:

```text
Activity Logs
```

Filters:

```text
Date From / Date To
User
Role
Action
Module
Entity Type
Worker
Tool
Transaction Code
```

Details dialog:

```text
Action
Performed By
Performed At
Affected Entity
Old Values
New Values
Metadata
```

Entity timeline:

```text
Worker History
Tool History
Transaction History
Company User History
```

Rules:

- Owner/Admin can view full audit logs.
- Other roles can view limited logs if allowed.
- Audit logs should not be editable from UI.
- Audit logs should not be deleted by normal users.
- Future retention/archive policy can be added later.

---

# Phase O — Future Product Enhancements

Planned:

- Worker Acknowledgment Reports.
- Signed report storage.
- Void/Correction workflow.
- Database-level open-custody protection for deleting tools/workers.
- Better dashboard insights.
- Better PDF table layout for long reports.
- Export history.
- Notifications.
- Multi-company selection.
- Company switching.
- User invitation flow.
- Role management UI.
- Audit logs.
- Transaction correction flow.
- Settlement/deduction report if business needs it.
- Better signed document preview/download UI.
- Mobile/tablet UI polish.
- Better empty states.
- Dashboard trends.
- Search and filter improvements.
- Bulk import workers/tools if needed.
- Better reporting filters.
- Report templates versioning.
- Optional attachment history per transaction.
- Optional storage cleanup strategy for replaced files.
- Optional archived/inactive workers and tools improvements.
- Optional company subscription/licensing flow.
- Optional SaaS billing/tenant management flow.
- Optional offline-first support if needed later.
- Optional barcode/QR support for tools.
- Optional QR-based worker/tool selection.
- Optional approval notifications.
- Optional email export/share flow.

---

# Refactor Backlog

Some files may still need careful future refactor.

Rules for refactor:

- Do not change working UI behavior.
- Do not change business logic.
- Do not change database queries unless needed.
- Split large files into smaller focused widgets/services/functions.
- Run `dart format lib`.
- Run `flutter analyze`.
- Test affected screens manually.
- Commit refactor separately from feature work.

Deferred refactor candidate:

```text
lib/features/transactions/data/models/transaction_model.dart
```

Suggested safe refactor direction:

```text
transaction_model.dart
transaction_model_json.dart
transaction_model_copy_with.dart
transaction_model_parsers.dart
```

Only do this as a separate maintenance commit.

---

# Immediate Next Step

Next recommended development step:

```text
Phase L — Responsive & Orientation Hardening
```

Start with:

```text
Step L.1 — Run full mobile/tablet rotation audit.
```

Before writing any Flutter code:

```text
1. Test the app on mobile portrait.
2. Rotate to mobile landscape and list broken screens.
3. Test the app on tablet portrait.
4. Rotate to tablet landscape and list broken screens.
5. Capture screenshots for each broken screen.
6. Fix screens one by one, starting with the worst overflow.
```

After Phase L:

```text
Phase M — Company Users, Invitations & Role Management
```

Then:

```text
Phase N — Audit Trail & Activity Logs
```