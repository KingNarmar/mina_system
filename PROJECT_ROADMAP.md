# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Project Vision

Mina System is a Flutter + Supabase application for managing tool custody, warehouse workers, tools, transactions, dashboard data, company settings, users, roles, invitations, approvals, settlements, audit logs, responsive layouts, professional PDF reports, subscription plans, usage limits, offline-aware behavior, and production-ready distribution for companies and warehouses.

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

## Storage / Image Optimization Rules

- Never upload large original images without compression unless there is a business reason.
- Transaction proof images must be compressed before upload.
- Approval document images should be compressed before upload when they are image files.
- PDF files should not be image-compressed.
- Company logos should be resized/compressed carefully without destroying quality.
- Store only the compressed/uploaded cloud path in the database.
- Keep the original local file path out of Supabase tables.
- Use clear storage paths under company folders:
  - `{companyId}/transactions/...`
  - `{companyId}/logo/...`
  - `{companyId}/documents/...`
- Future storage usage must be tracked per company for plan limits.

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

Required future flow after Subscriptions:

```text
Register/Login
→ Load Current Context
→ Load Current Company Subscription
→ If subscription is active/free/trial: continue
→ If subscription expired: show Subscription Required screen
→ If company has no plan: assign Free plan by default
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

Required future behavior after subscriptions:

```text
Current company loaded
→ Check subscription/plan
→ Check plan status
→ Check usage limits
→ Continue or show limited/expired state
```

Required future behavior after offline handling:

```text
No internet while loading context
→ Show offline/network error screen
→ Retry when internet returns
→ Later: load last cached read-only company context if offline cache is implemented
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
- Assign Free plan automatically after company creation.
- Create default subscription record after company creation.
- Initialize usage counters/limits after company creation.
- Prevent creating unlimited companies from one account if abused.
- Add company onboarding checklist after creation.

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

Future improvements:

- Add subscription section inside Company Settings for owners/admins.
- Show current plan name.
- Show plan status:
  - Free
  - Trial
  - Active
  - Past Due
  - Expired
  - Suspended
- Show current usage:
  - Workers used / allowed
  - Tools used / allowed
  - Transactions this month / allowed
  - Storage used / allowed
  - Users used / allowed
- Show upgrade/contact message without direct mobile payment link.
- Add billing/contact email fields if needed later.

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

Pending / Future Enhancements:

- Add image compression/resizing before logo upload.
- Recommended logo max width:
  - `800 px`
- Preserve transparency when possible for PNG/WebP logos.
- Add max upload size validation.
- Add friendly error if logo file is too large or invalid.
- Track logo storage usage under company storage quota.

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
- Add plan-based report watermark if company is on Free plan if needed.
- Add report export history if required later.

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

Pending / Future Enhancements:

- Add plan-based access to advanced template customization if needed.
- Keep basic templates available for Free plan.
- Keep advanced customization for paid plans if used commercially.

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

Future improvements:

- Add plan-based lookup limits if needed.
- Add import defaults from industry templates later.
- Add offline-friendly error message if lookups fail due to no internet.

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

Pending / Future Enhancements:

- Enforce plan limit before adding a worker.
- Free plan example limit:
  - 25 workers
- Starter plan example limit:
  - 300 workers
- Standard plan example limit:
  - 1,000 workers
- Professional plan example limit:
  - 5,000 workers
- Add friendly upgrade message when worker limit is reached.
- Add database/RPC-level worker limit enforcement.
- Add offline-friendly message if worker add/update/delete fails due to no internet.

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

Pending / Future Enhancements:

- Enforce plan limit before adding a tool.
- Free plan example limit:
  - 50 tools
- Starter plan example limit:
  - 500 tools
- Standard plan example limit:
  - 2,000 tools
- Professional plan example limit:
  - 10,000 tools
- Add friendly upgrade message when tool limit is reached.
- Add database/RPC-level tool limit enforcement.
- Add offline-friendly message if tool add/update/delete fails due to no internet.

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
- Add image compression before uploading proof images.
- Recommended transaction image settings:
  - Max width: `1280 px`
  - JPEG quality: `70–75`
  - Output format: `jpg` unless transparency is required
- Add max proof image size validation.
- Track proof image storage usage per company.
- Enforce monthly transaction limits by plan.
- Free plan example limit:
  - 100 transactions/month
- Starter plan example limit:
  - 1,000 transactions/month
- Standard plan example limit:
  - 10,000 transactions/month
- Professional plan example limit:
  - 50,000 transactions/month
- Add friendly upgrade message when transaction limit is reached.
- Add database/RPC-level transaction limit enforcement.
- Add clear offline behavior:
  - First stage: block transaction submission while offline.
  - Later stage: save transaction draft locally and sync later.

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
- Add subscription/plan card for owners/admins:
  - Current plan
  - Plan status
  - Renewal date
  - Usage summary
- Add storage usage card:
  - Used storage
  - Plan storage limit
- Add offline banner at dashboard level when connection is unavailable.

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

Future maintenance additions:

- Add dedicated image compression service:
  - `lib/core/services/image_compression_service.dart`
- Add dedicated network status service/cubit:
  - `lib/core/network/network_cubit.dart`
  - `lib/core/network/network_state.dart`
- Add plan/limits service:
  - `lib/features/subscriptions/...`
- Keep commercial logic out of widgets where possible.

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
- Add report usage tracking if reports become plan-limited.
- Add Free plan watermark only if required commercially.
- Avoid blocking core operational reports for paid users.
- Ensure PDF preview handles offline errors clearly when Supabase assets cannot be loaded.

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

Implemented:

- Lost/Damaged approval status exists in transaction flow.
- Pending approval does not reduce custody balance.
- Rejected does not reduce custody balance.
- Approved alone does not reduce custody balance.
- Final settlement reduces custody balance.
- Pending approvals UI exists.
- Upload signed approval document flow exists.
- Approve transaction flow exists.
- Reject transaction flow exists.
- Settle approved transaction flow exists.
- Dashboard refreshes after approve/reject/settle.
- Signed document opening on Android was fixed.
- Lost/Damaged Approval Report exists in Reports.
- Approval Status filter exists in Reports.
- Transaction details display approval and settlement data.

Pending / Future Enhancements:

- Add stronger approval notes UI.
- Add required approval decision note if needed.
- Add required settlement note if needed.
- Add settlement/deduction PDF report if required.
- Add audit log entries for:
  - approval document upload
  - approve
  - reject
  - settle
- Add notification/alert for pending approvals.
- Add dashboard card for pending approvals.
- Add dashboard card for pending settlements.
- Add approval workflow permissions by role.
- Add plan-based access if advanced approval workflow becomes paid-only.
- Compress signed approval document images before upload.
- Keep PDF files unchanged when uploading signed PDF documents.
- Add storage quota check before signed document upload.
- Add friendly offline message if upload/approve/reject/settle fails due to network.

---

# Phase I — Company Users, Roles & Invitations

## Status: Planned / High Priority

Goal:

Allow company owners/admins to invite users, manage company members, and enforce role permissions across the system.

Required Roles:

- Owner
- Admin
- Warehouse Manager
- Warehouse User
- Viewer / Read Only

Required Database Tables / Logic:

- `company_members`
- `company_invitations`
- Role fields
- Invitation status
- Invitation expiry
- Invited email
- Invited by profile
- Accepted at
- Revoked at if needed

Required Secure Flow:

```text
Owner/Admin enters user email
→ System creates invitation
→ User receives invitation
→ User registers/logs in
→ System checks pending invitations by email
→ User accepts invitation
→ Company membership is created
→ User gets role-based access
```

Rules:

- Flutter must not call Supabase Admin Auth directly.
- Invitations must be handled through secure backend logic / Edge Function.
- RLS must enforce access by active company membership.
- UI role visibility is not enough.
- Role permissions must be enforced at database level.

Planned UI:

- Company Users screen.
- Invite User button.
- Members table.
- Role selector.
- Revoke member action.
- Pending invitations list.
- Resend invitation action.
- Cancel invitation action.

Role-Based UI Restrictions:

- Owner/Admin:
  - Full settings access.
  - Users/invitations access.
  - Subscription/plan visibility.
- Warehouse Manager:
  - Workers/Tools/Transactions/Reports.
  - Approval workflow if allowed.
- Warehouse User:
  - Operational transactions only.
- Viewer:
  - Read-only dashboard/reports.

Dependencies:

- Current Context must load `currentUserRole`.
- RLS policies must support role checks.
- Company Settings should show/hide sections based on role.
- Subscription management should only be visible to Owner/Admin.

---

# Phase J — Subscription Plans, Free Version & Package Limits

## Status: Not Started / Commercial Foundation

Goal:

Turn Mina System from a working internal app into a commercial SaaS product with Free and Paid packages.

Main decision:

Do not create separate Free and Paid apps.

Use the same app with company-based subscription records.

Planned Plans:

| Plan | Workers | Tools | Transactions/month | Storage | Users |
| --- | ---: | ---: | ---: | ---: | ---: |
| Free | 25 | 50 | 100 | 250 MB | 1 |
| Starter | 300 | 500 | 1,000 | 2 GB | 3 |
| Standard | 1,000 | 2,000 | 10,000 | 10 GB | 10 |
| Professional | 5,000 | 10,000 | 50,000 | 30 GB | 25 |
| Enterprise | Custom | Custom | Custom | Custom | Custom |

Suggested Pricing:

| Plan | Suggested Price |
| --- | ---: |
| Free | 0 AED/month |
| Starter | 99 AED/month |
| Standard | 199 AED/month |
| Professional | 349 AED/month |
| Enterprise | From 699 AED/month or custom |

Setup Fee:

| Customer Type | Suggested Setup Fee |
| --- | ---: |
| Small customer | 300–500 AED |
| Medium customer | 750–1,500 AED |
| Large customer | 2,000–5,000 AED |

Required Tables:

```text
plans
company_subscriptions
company_usage_counters
company_billing_contacts
```

Suggested `plans` fields:

- `id`
- `code`
- `name`
- `monthly_price`
- `currency`
- `max_workers`
- `max_tools`
- `max_users`
- `max_transactions_per_month`
- `max_storage_mb`
- `features`
- `is_active`
- `created_at`
- `updated_at`

Suggested `company_subscriptions` fields:

- `id`
- `company_id`
- `plan_id`
- `status`
- `started_at`
- `trial_ends_at`
- `current_period_start`
- `current_period_end`
- `cancelled_at`
- `payment_provider`
- `external_subscription_id`
- `created_at`
- `updated_at`

Subscription Status Values:

- `free`
- `trialing`
- `active`
- `past_due`
- `expired`
- `cancelled`
- `suspended`

Required Enforcement:

- Worker limit before adding workers.
- Tool limit before adding tools.
- Monthly transaction limit before adding transactions.
- User limit before inviting users.
- Storage limit before uploading images/documents.
- Subscription expired state before allowing operational writes.

Important Rule:

Plan limits must be enforced in Supabase functions/RPC/database logic, not only in Flutter UI.

Flutter UI Responsibilities:

- Show current plan.
- Show current usage.
- Show upgrade/contact message.
- Disable actions when limit is reached.
- Show friendly explanation.
- Do not expose direct payment buttons in mobile apps until store billing strategy is finalized.

Supabase Responsibilities:

- Enforce limits securely.
- Prevent bypass from API clients.
- Return clear error codes for limit reached.
- Keep usage counters accurate.

Planned Screens:

- Subscription Overview screen.
- Plan Usage widget in Company Settings.
- Limit Reached dialog.
- Subscription Expired screen.
- Contact Sales / Contact Admin message.

---

# Phase K — Offline Detection & Network Resilience

## Status: Not Started / Required Before Production

Goal:

Make the app behave clearly and safely when the device has no internet connection.

Current behavior:

- The app depends on Supabase directly.
- If there is no internet, loading data or submitting data may fail with generic errors.
- There is no dedicated offline banner.
- There is no local sync queue.
- There is no local database cache.

Stage 1 — Required First:

Add offline detection and friendly network handling.

Required package:

```yaml
connectivity_plus: ^6.x.x
```

Required files:

```text
lib/core/network/network_cubit.dart
lib/core/network/network_state.dart
lib/core/network/network_banner.dart
lib/core/errors/app_error_mapper.dart
```

Required Behavior:

- Show top banner when offline:
  - `You are offline. Some features may not work until connection is restored.`
- Show clear message if loading context fails due to no internet.
- Show clear message if dashboard/workers/tools/transactions fail due to no internet.
- Disable transaction submission while offline.
- Disable image/document upload while offline.
- Allow retry after connection returns.
- Keep current generic error fallback for unknown errors.

Stage 1 Save Behavior:

```text
Offline + user tries to add transaction
→ Block save
→ Show: "Cannot save transaction while offline. Please reconnect and try again."
```

Stage 2 — Future Offline Drafts:

Add local draft support without full sync.

Potential behavior:

```text
Offline + user starts transaction
→ Allow form filling
→ Save as local draft only
→ User can submit when online
```

Stage 3 — Full Offline Sync:

Add full offline operation support.

Required future components:

- Local database:
  - Drift / SQLite
- Sync queue
- Pending uploads queue
- Conflict handling
- Local draft status
- `Pending Sync` badges
- Retry failed sync
- Audit log for synced records

Important Rule:

Full offline sync must not be added quickly or randomly. It must be designed carefully because transactions affect custody balances.

---

# Phase L — Image Compression & Storage Optimization

## Status: Not Started / Required Before Commercial Launch

Goal:

Reduce Supabase Storage usage and improve upload speed by compressing images before upload.

Current behavior:

- Transaction proof images are uploaded as original files.
- Approval document images are uploaded as original files.
- Company logos are uploaded as original files.
- PDF files are uploaded unchanged.
- No compression package is currently implemented.

Recommended package:

```yaml
image: ^4.x.x
```

Reason:

- Works with Dart/Flutter.
- More suitable for cross-platform including desktop.
- Can decode, resize, and encode images.

Required service:

```text
lib/core/services/image_compression_service.dart
```

Transaction Proof Image Rules:

- Max width: `1280 px`
- JPEG quality: `70–75`
- Output format: `jpg`
- Expected target size:
  - 300 KB to 800 KB depending on image content
- Keep original aspect ratio.
- Do not upscale small images.

Approval Document Image Rules:

- If file is PDF:
  - Do not compress.
- If file is image:
  - Compress like transaction proof image.
- Keep file readable for approval records.

Company Logo Rules:

- Max width: `800 px`
- Preserve transparency when possible.
- Avoid aggressive compression.
- Keep quality suitable for PDF reports.

Required Integration Points:

```text
lib/features/transactions/data/services/transaction_storage_service.dart
lib/features/company_settings/data/repo/company_settings_repo.dart
lib/features/transactions/presentation/widgets/pending_approvals/pending_approval_actions.dart
```

Required Validations:

- Allowed image extensions:
  - JPG
  - JPEG
  - PNG
  - WEBP
- Max selected file size before compression.
- Max uploaded file size after compression.
- Friendly error if image cannot be decoded.
- Friendly error if compressed image fails.

Future Enhancements:

- Track storage usage per company.
- Show storage usage in Subscription Overview.
- Prevent upload if company storage limit is reached.
- Add cleanup job for orphaned files if needed.
- Add image thumbnail generation if needed later.

---

# Phase M — Production Environment & Release Configuration

## Status: Not Started / Required Before Store Submission

Goal:

Separate development, staging, and production environments and prepare safe production builds.

Current issue:

- Supabase URL and anon key are currently initialized directly in `main.dart`.
- This is acceptable during development but not ideal for production environment separation.

Required Environments:

- Development
- Staging
- Production

Required Configuration:

Use `--dart-define` or Flutter flavors.

Example:

```bash
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Required Files / Structure:

```text
lib/core/config/app_config.dart
lib/core/config/app_environment.dart
```

Required Behavior:

- App reads Supabase URL from environment config.
- App reads Supabase anon key from environment config.
- Debug builds can show environment label.
- Release builds must not show debug labels.
- Development and production data must never be mixed.

Production Supabase Requirements:

- Create separate Supabase project for production.
- Apply final schema.
- Apply RLS policies.
- Apply storage policies.
- Create storage buckets:
  - `company-assets`
  - `transaction-proofs`
  - `transaction-approval-documents`
- Create default plans.
- Create default document templates.
- Test with real production-like data.

Pre-Release Checklist:

- `dart format lib`
- `flutter analyze`
- Test Windows build.
- Test Android release build.
- Test iOS build when available.
- Test web build if enabled.
- Test Supabase production connection.
- Test auth.
- Test create company.
- Test workers/tools/transactions.
- Test image upload.
- Test PDF generation.
- Test signed document opening.
- Test offline/no internet behavior.

---

# Phase N — Store Publishing & Distribution

## Status: Not Started / Required Before Public Release

Goal:

Prepare Mina System for distribution through:

- Google Play Store
- Apple App Store
- Website
- Desktop download page

Main Strategy:

- Mobile apps should be free to download.
- Users log in after their company account/subscription exists.
- Payments should be handled outside the mobile app at first for B2B customers.
- Avoid direct in-app payment buttons until Google Play Billing and Apple IAP rules are fully reviewed.
- Desktop app should be downloadable from the official website.

Google Play Requirements:

- Google Play Developer account.
- App name.
- App icon.
- App screenshots.
- Short description.
- Full description.
- Privacy Policy URL.
- Data Safety form.
- App signing.
- Release build using app bundle.
- Demo/review account if needed.

Android Build Command:

```bash
flutter build appbundle --release
```

Apple App Store Requirements:

- Apple Developer Program account.
- Bundle ID.
- App icon.
- App screenshots.
- Privacy Policy URL.
- App Privacy details.
- Review/demo account if needed.
- iOS release build.
- TestFlight testing before release.

Website Requirements:

- Landing page.
- Product explanation.
- Features.
- Pricing/packages.
- Contact form.
- WhatsApp/contact button if needed.
- Download for Windows.
- Future Download for macOS.
- Privacy Policy.
- Terms of Service.
- Support email.
- Changelog/release notes.

Desktop Distribution:

- Build Windows release.
- Package installer.
- Sign installer later if needed.
- Host download on website.
- Add auto-update later if required.

Website Download Page Should Include:

- Latest version.
- Release date.
- Download button.
- Minimum system requirements.
- Installation instructions.
- Support contact.
- Known limitations.

---

# Phase O — Website, Customer Portal & Billing Operations

## Status: Future Commercial Phase

Goal:

Create a simple external website/customer portal to manage subscriptions, downloads, customer onboarding, and support.

Recommended Initial Approach:

Do not overbuild.

Start with:

- Landing page.
- Pricing page.
- Contact/demo request.
- Manual customer activation.
- Manual invoice/payment collection.
- Admin-controlled subscription status in Supabase.

Later Add:

- Customer portal.
- Online payment provider.
- Invoice download.
- Subscription renewal.
- Upgrade/downgrade.
- Payment history.
- Company billing contacts.

Possible Payment Strategy:

Stage 1:

```text
Manual B2B payment
→ Owner pays outside app
→ Admin activates subscription from backend/Supabase
```

Stage 2:

```text
Website payment
→ Payment provider webhook
→ Update company_subscriptions
```

Stage 3:

```text
Full customer portal
→ Customer manages billing online
```

Important Mobile App Rule:

- Avoid direct mobile in-app payment buttons at the beginning.
- Keep subscription management outside the mobile apps.
- Inside app, show plan status and contact/admin message only.

---

# Phase P — Production Monitoring, Support & Audit Logs

## Status: Future Production Phase

Goal:

Improve reliability, traceability, and customer support after commercial launch.

Required Audit Logs:

- Login events if needed.
- Company creation.
- Company settings updates.
- User invitation created.
- User invitation accepted.
- User role changed.
- Worker created/updated/deleted.
- Tool created/updated/deleted.
- Transaction created.
- Approval document uploaded.
- Transaction approved.
- Transaction rejected.
- Transaction settled.
- Subscription changed.
- Plan limit reached.
- Storage limit reached.

Required Support Features:

- Error reporting.
- Support contact inside app.
- Version number in settings/about screen.
- Environment/build info in debug only.
- Changelog link.
- Customer support notes if needed.

Possible Tools Later:

- Sentry or similar error monitoring.
- Supabase logs.
- Custom `audit_logs` table.
- Admin dashboard for customer support.

---

# Recommended Next Development Sequence

## Immediate Next Steps

1. Add image compression for transaction proof images.
2. Add image compression for approval document images.
3. Add safe logo resizing/compression.
4. Add offline/network detection.
5. Add friendly network error mapping.
6. Add production environment configuration using `--dart-define`.
7. Add subscription plans database design.
8. Add default Free plan after company creation.
9. Add plan usage display in Company Settings.
10. Add limit enforcement for workers/tools/transactions.
11. Add user invitations and role-based UI/database enforcement.
12. Add production Supabase project.
13. Prepare website landing page and desktop download page.
14. Prepare Google Play and App Store assets.
15. Prepare Privacy Policy and Terms of Service.
16. Prepare production release checklist.

## Suggested Order Before Public Launch

```text
Storage Optimization
→ Network/Offline Handling
→ Production Environment Separation
→ Subscription Plan Tables
→ Usage Limits
→ User Invitations / Roles
→ Store/Website Preparation
→ Production Supabase Setup
→ Beta Testing
→ First Customer Pilot
→ Public Launch
```

---

# Commercial Launch Readiness Checklist

## Product Core

- [x] Auth
- [x] Create Company
- [x] Company Settings
- [x] Lookups
- [x] Workers
- [x] Tools
- [x] Transactions
- [x] Dashboard
- [x] Reports/PDF core
- [x] Lost/Damaged workflow core
- [ ] Image compression
- [ ] Offline detection
- [ ] Friendly network errors
- [ ] Subscriptions/plans
- [ ] Usage limits
- [ ] User invitations
- [ ] Role-based UI
- [ ] Database-level role enforcement review
- [ ] Production environment separation

## Commercial

- [ ] Pricing finalized
- [ ] Free plan finalized
- [ ] Starter/Standard/Professional limits finalized
- [ ] Setup fee policy finalized
- [ ] Billing process defined
- [ ] Subscription status screen
- [ ] Limit reached dialog
- [ ] Website landing page
- [ ] Desktop download page
- [ ] Privacy Policy
- [ ] Terms of Service
- [ ] Support email/contact

## Store Publishing

- [ ] Google Play developer account
- [ ] Apple Developer account
- [ ] App icon
- [ ] Splash screen review
- [ ] Store screenshots
- [ ] Store descriptions
- [ ] Demo account
- [ ] Android app bundle
- [ ] iOS TestFlight build
- [ ] Privacy forms
- [ ] Data safety forms

## Infrastructure

- [ ] Production Supabase project
- [ ] Production database schema
- [ ] Production RLS policies
- [ ] Production storage buckets
- [ ] Production storage policies
- [ ] Production default plans
- [ ] Production environment variables
- [ ] Backup policy
- [ ] Monitoring/logging plan
- [ ] Support process

---

# Notes

- The current app is functionally strong as an operational inventory/custody system.
- The next major work should focus on turning it into a safe commercial SaaS product.
- The most urgent technical risks before selling are:
  - Large uncompressed image uploads.
  - No clear offline handling.
  - No plan/subscription enforcement.
  - No production environment separation.
- The best commercial model is:
  - Free app download.
  - Company-based subscription.
  - Website/manual billing at first.
  - In-app plan status only.
  - No direct mobile payment buttons at the beginning.