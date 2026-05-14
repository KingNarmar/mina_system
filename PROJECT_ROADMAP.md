# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Source of Truth

This roadmap is the single source of truth for Mina System.

It is based on:

- The real GitHub repository.
- The verified Supabase backend state.
- The latest completed and pushed development checkpoints.
- The current product and engineering direction.

If the README conflicts with this roadmap, this roadmap wins.

---

## Latest Verified State

Latest verified pushed code commit:

`485eaee1b07dc23a3b25d3f61eaaf291852c5f6e`

Commit message:

`chore(transactions): remove temporary add transaction debug prints`

Current product phase:

**Phase R — Business Accountability & Audit Trail**

Current completed checkpoint:

**Post R6-F Cleanup — Remove temporary transaction debug prints**

Status:

**Completed and pushed**

Previous completed checkpoint:

**Step R6-F — Transaction Accountability Details Display**

Completed cleanup:

- Removed temporary `print` statements from `TransactionsCubitCrud.addTransaction`.
- Kept production user-facing error handling unchanged.
- Kept guarded `kDebugMode` debug logs in other areas unchanged.
- Ran `dart format lib`.
- Ran `flutter analyze`.
- `flutter analyze` result: **No issues found**.
- Cleanup commit was pushed to `main`.

Step R6-F completed sub-steps:

- **Step R6-F.1 — Add complete transaction accountability columns in Supabase**
- **Step R6-F.2 — Replace `create_custody_transaction` RPC**
- **Step R6-F.3 — Replace `upload_transaction_approval_document` RPC**
- **Step R6-F.4A — Replace `approve_lost_damaged_transaction` RPC**
- **Step R6-F.4B — Replace `reject_lost_damaged_transaction` RPC**
- **Step R6-F.5 — Replace `settle_lost_damaged_transaction` RPC**
- **Step R6-F.6 — Harden direct table access for `public.transactions`**
- **Step R6-F.7 — Verify issue transaction accountability**
- **Step R6-F.8 — Verify approval + settlement workflow accountability**
- **Step R6-F.9 — Verify rejection workflow accountability**
- **Step R6-F.10 — Update Flutter `TransactionModel`**
- **Step R6-F.11 — Update Flutter `TransactionsRepo` select columns**
- **Step R6-F.12 — Add Transaction Accountability section in Transaction Details**
- **Step R6-F.13 — Add Transaction Audit History button**
- **Step R6-F.14 — Add readable transaction audit action labels**

Verification status:

- Issue transaction creation was manually tested on Windows.
- Lost/Damaged approval document upload was manually tested.
- Lost/Damaged approve workflow was manually tested.
- Lost/Damaged settle workflow was manually tested.
- Lost/Damaged reject workflow was manually tested.
- Transaction accountability fields displayed correctly in Transaction Details.
- Transaction Audit History displayed created/uploaded/approved/settled/rejected events.
- Direct authenticated `INSERT` / `UPDATE` access to `public.transactions` was closed.
- Transaction mutations now go through secure RPC workflows only.
- Transaction tables remain clean without adding extra accountability columns.
- Post R6-F cleanup was verified with `flutter analyze`.

Known technical follow-ups:

- Replace `pending-*` proof image storage folders with official `TRX-*` paths after backend transaction code generation.
- Make transaction proof image upload web-compatible.

Next required checkpoint:

**Step R6-G.1 — Replace `pending-*` transaction proof paths with official `TRX-*` paths**

Deferred checkpoint:

**Step R6-G.2 — Make transaction proof uploads web-compatible**

Current decision:

Flutter Web upload is not a priority right now, so `R6-G.2` is deferred. The next practical engineering checkpoint is `R6-G.1`, focused only on fixing transaction proof storage paths without starting Flutter Web upload work.

---

# Product Vision

Mina System is a Flutter + Supabase inventory and custody management system built as a real multi-company SaaS/product.

The system manages:

- Companies
- Company users
- Roles and permissions
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
- Offline/network-aware behavior
- Direct user accountability
- Audit trail history

Every company must have isolated data using `company_id` and the active `currentCompanyId`.

The product should eventually support:

- Multiple users inside the same company
- Multiple companies under one user account
- Workspace/company switching
- Owner/Admin/Warehouse Manager/Warehouse User/Viewer roles
- Secure invitations
- Company-based subscriptions
- Free plan / trial plan
- Paid monthly packages
- B2B subscriptions
- Production Supabase environment separate from development/testing
- Web landing page
- Desktop installer download
- Google Play release
- App Store release
- Safe storage usage through compression and storage limits
- Clear offline/network behavior
- Mobile/tablet camera capture for proof/document upload workflows
- File upload fallback from device storage
- Future custom permission overrides without rebuilding the whole permission system

---

# Core Development Rules

- Work step by step.
- Review the real GitHub repo before continuing a new step.
- Do not rely only on README because it may be outdated.
- Keep `PROJECT_ROADMAP.md` as the single source of truth.
- Update this roadmap after each completed feature or major checkpoint.
- Do not create multiple roadmap files.
- Do not make large unrelated changes in one step.
- Do not change working UI unless needed.
- Avoid mixing unrelated architecture changes inside the same checkpoint.
- Keep implementation scalable and maintainable.
- Preserve current UI, workflow, permissions, validation, and business logic during refactors unless an approved bug fix is part of the batch.
- Split files only when responsibilities are mixed or maintainability clearly improves.
- Large but cohesive files may remain as-is.
- When changing existing files during guided development, provide complete file replacements when requested.

After each completed feature or major checkpoint:

1. Test manually.
2. Run `dart format lib`.
3. Run `flutter analyze`.
4. Commit.
5. Push.
6. Review repo again.
7. Update roadmap.

---

# Testing Rules

Every major feature should be tested on:

- Windows
- Mobile portrait
- Mobile landscape
- Tablet portrait
- Tablet landscape

Role-based features should be tested with:

- Owner
- Admin
- Warehouse Manager
- Warehouse User
- Viewer

Backend security-sensitive features must be tested at database/RPC level where applicable, not only through Flutter UI.

If a role cannot be tested due to missing test accounts, document that clearly.

---

# Architecture Rules

Preferred implementation order:

1. Review current repo files.
2. Confirm current database structure if needed.
3. Confirm security rules and RLS.
4. Model
5. Repository / Service
6. Cubit / State
7. UI
8. SQL Grants if needed
9. RLS Policies if needed
10. Storage Policies if needed
11. Manual test
12. Direct DB/RPC security test if relevant
13. `dart format lib`
14. `flutter analyze`
15. Commit / Push
16. Update roadmap

---

# Supabase / Security Rules

- Every business table must be connected to `company_id`.
- Every company query must be filtered by `currentCompanyId`.
- Never expose or use service role keys in Flutter.
- Admin Auth methods must not be called directly from Flutter.
- User invitations must be handled through secure backend logic, RPC, or Supabase Edge Functions.
- Before using any Supabase table:
  - Check real columns first.
  - Add correct grants.
  - Add safe RLS policies.
- Company users must access company data only through active company membership.
- RLS must enforce role permissions at database level, not UI only.
- Storage policies must enforce upload/read permissions at bucket level.
- Plan limits must be enforced at database/RPC level, not UI only.
- Subscription access must be checked securely using company subscription records.
- Sensitive member-management mutations must use secure RPCs, not direct client updates.
- Direct invitation creation must not be left open when a secure invitation RPC exists.
- Transactions should not be deleted from the system.
- Transaction editing should not be exposed as a normal UI action.
- Transaction corrections should be handled by corrective transactions, approval workflow, settlement workflow, or future void workflow.
- Lost/Damaged transactions should reduce worker custody balance only after final settlement/deduction is completed.
- Important business actions must be auditable.
- Important business records should store direct accountability fields where applicable.
- Audit logs must store the acting profile.
- Audit logs must be protected by RLS.
- Audit logs must not be editable or deletable by normal app users.
- Direct accountability fields must not be trusted from arbitrary client input unless protected by RLS/RPC/backend logic.
- Actor profile should be derived from authenticated backend context whenever possible.
- Transaction mutations must go through controlled RPC workflows only.

---

# Timezone and Date/Time Rules

Mina System handles business accountability, custody, reports, and audit trails, so date/time accuracy is critical.

## Storage Rule

- All database timestamps must remain stored as UTC.
- Supabase/Postgres timestamps such as `created_at`, `updated_at`, and audit log timestamps should use `timestamp with time zone` where appropriate.
- Do not store local display time as the source of truth.

## Display Rule

- Business-facing UI, reports, PDFs, Audit History screens, and accountability display sections must display timestamps using the current company timezone.
- The app must not permanently hardcode UAE time for all companies.
- Device local time may be used only as a fallback or suggestion, not as the source of truth for company timestamps.

## Company Timezone Rule

Company timezone is stored at company level:

`companies.timezone text not null default 'Asia/Dubai'`

Timezone value must use IANA timezone names, such as:

- `Asia/Dubai`
- `Asia/Kolkata`
- `Africa/Cairo`
- `Asia/Riyadh`

Do not rely only on fixed offsets such as `+04:00`, because some countries use daylight saving time.

## Current Timezone Implementation State

Completed:

- `companies.timezone` was added in Supabase.
- Existing companies can default to `Asia/Dubai`.
- `create_company_with_defaults` accepts `p_timezone`.
- `company_report_settings.default_timezone` is seeded from selected company timezone during company creation.
- Flutter uses the `timezone` package.
- Timezone database is initialized in `main.dart`.
- `CompanyModel` includes `timezone`.
- `CompanyProfileModel` includes `timezone`.
- `CreateCompanyRequest` includes `timezone`.
- `AppTimezones` utility was added.
- Reusable searchable timezone picker was added.
- Create Company screen allows selecting timezone.
- Company Settings allows editing timezone.
- Centralized company date/time formatter was added:
  - `lib/core/utils/company_date_time_formatter.dart`
- Transaction date formatting wrapper uses the centralized formatter:
  - `lib/features/transactions/presentation/functions/format_transaction_date.dart`
- Transactions UI uses current company timezone.
- Reports/PDF use report/company timezone.
- Audit History UI uses company timezone through `CompanyDateTimeFormatter`.
- Worker and Tool mobile accountability cards use company timezone through `RecordAccountabilitySection`.
- Worker and Tool desktop details dialogs use company timezone through `RecordAccountabilitySection`.
- Transaction accountability details use company timezone.

Remaining:

- Apply company timezone formatting to future accountability display sections such as company settings and team/member lifecycle displays.

---

# UI / Theme Rules

- Colors should be centralized inside `AppColors`.
- Do not use direct widget-level colors like `Colors.green` or `Colors.orange` unless they are first added to `AppColors`.
- PDF colors and PDF text styles should stay centralized.
- Reusable user messages should use `AppMessage`.
- Errors inside Bottom Sheets or Dialogs should appear inside the form/dialog when SnackBars would be hidden behind the overlay.
- Success/error/warning/info messages should be clear, professional, and user-friendly.
- Do not show raw technical errors to end users.
- General screen errors should use unified `AppMessage`.
- Important details screens should show direct accountability data where applicable.
- UI role restrictions must match database RLS and Storage policies.
- Navigation should reflect actual feature ownership:
  - Company settings belong in `Settings`.
  - Team/member management belongs in a dedicated `Team` area.
- Users with multiple companies should have:
  - A clear initial workspace selection flow when needed.
  - Persistent last selected workspace behavior.
  - A visible manual `Switch Company` action.
- If a Cubit preserves search state across navigation, the visible search field must restore the same query when the screen is rebuilt.
- If backend loads a list in a defined order, local add/update state should preserve the same order unless a product decision explicitly changes sorting behavior.
- Long scrollable screens that rebuild after mutations should preserve scroll position when practical.
- Desktop tables should remain readable and should not be overcrowded with too many accountability columns.
- Use details dialogs, bottom sheets, side panels, or expandable rows for dense accountability data when tables would become unreadable.

---

# Responsive / Adaptive Rules

- Do not assume mobile is always portrait.
- Do not assume tablet is always landscape.
- Do not lock orientation unless there is a clear business reason.
- Prefer adaptive layout based on available space.
- Use responsive tools such as:
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
- Dialogs and Bottom Sheets must respect available screen height.
- Tables must remain horizontally scrollable where needed.
- Action buttons must wrap instead of overflowing.
- Mobile landscape must remain a mobile experience unless there is a strong reason to switch.
- Android/iOS tablets should remain TabletShell even when screen width is large.
- DesktopShell should be used for desktop platforms, not for large simulated Android/iOS tablets.
- DevicePreview must not be required by normal runtime layouts.

---

# Storage / Image Optimization Rules

- Storage files must be saved in Supabase Storage.
- Database should store cloud storage paths only.
- Local file paths must not be saved in Supabase tables.
- Never upload large original images without compression unless there is a clear business reason.
- Transaction proof images must be compressed before upload.
- Approval document images should be compressed before upload when they are image files.
- PDF files should not be image-compressed.
- Company logos should be resized/compressed carefully without destroying quality.
- Use clear storage paths under company folders:
  - `{companyId}/transactions/...`
  - `{companyId}/logo/...`
  - `{companyId}/documents/...`
- Future storage usage must be tracked per company for plan limits.
- Camera capture should remain optional.
- File upload from device storage should remain supported as fallback.
- Transaction proof upload must support Windows, mobile, and web.
- Transaction proof storage should eventually use official transaction code paths instead of temporary `pending-*` folders.

---

# Offline / Network Rules

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

---

# Role / Permission Design Rules

Current roles:

- `owner`
- `admin`
- `warehouse_manager`
- `warehouse_user`
- `viewer`

Current rule:

- Permissions are assigned by role.
- Owner changes a user's role to change their access level.
- Per-user custom permission overrides are not implemented yet.

Current hierarchy for member lifecycle management:

- Owner can manage:
  - Admin
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Admin can manage:
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Warehouse Manager can manage lifecycle access for:
  - Warehouse User
  - Viewer

No role can manage:

- Itself
- Owner
- Same-level roles unless explicitly allowed in future
- Higher-level roles

Future scalable direction:

- Keep permission helper structure ready for:
  - Base role permissions
  - Extra allowed permissions
  - Explicit denied permissions

---

# Data Quality Rules

- HR Code remains the technical unique identifier for workers.
- Worker names must also remain unique inside the same company in the current app flow to prevent accidental duplicate worker records.
- Worker-name duplicate comparison uses Unicode-safe normalization.
- Current worker-name duplicate normalization ignores:
  - Case differences
  - Extra spaces
  - Separators and punctuation such as spaces, hyphens, dots, underscores, slashes, and commas
- If two real workers genuinely share the same apparent name, the entered name should be made more complete or more specific so both records remain clearly distinguishable.
- Worker-name duplicate protection is currently enforced in:
  - Form validation
  - In-memory helper validation
  - Cubit add flow
  - Cubit update flow
  - Repository backend checks
- Future hardening consideration:
  - Decide later whether production requires database-level unique protection for normalized worker names.

---

# Data Accountability Rules

Mina System tracks accountability in two levels:

1. Direct accountability fields on important business records.
2. Full audit trail logs for historical tracking.

Audit logs alone are not enough.

## Direct Accountability

Direct accountability fields answer:

**Who is responsible for the current/latest state?**

Important records should show:

- Who created the record
- Who last updated it
- When it was created
- When it was last updated

Common fields:

- `created_by_profile_id`
- `created_by_name_snapshot`
- `created_by_email_snapshot`
- `updated_by_profile_id`
- `updated_by_name_snapshot`
- `updated_by_email_snapshot`
- `created_at`
- `updated_at`

Transaction-specific direct accountability should also include:

- Proof image uploaded by
- Proof image uploaded at
- Signed approval document uploaded by
- Signed approval document uploaded at
- Approval decided by
- Approval decided at
- Settlement completed by
- Settlement completed at

## Audit Trail

Audit logs answer:

**What exactly happened over time?**

Every important business action should create an audit log record.

Audit logs should record:

- Company
- Acting profile
- Actor name/email snapshot
- Action
- Entity type
- Entity ID
- Entity label snapshot
- Old data
- New data
- Metadata
- Created timestamp in UTC

Audit logs must be append-only for normal app users.

Normal app users must not directly insert, update, or delete audit logs.

## Current Audit History Display Rules

- Audit History must show readable action labels.
- Audit History must show actor name/email snapshot.
- Audit History timestamps must use company timezone.
- Audit History must show old vs new values in a readable format.
- Audit History should not show raw JSON to normal users.
- Technical foreign keys should be resolved to readable names where possible:
  - `department_id` → Department
  - `job_title_id` → Job Title
  - `unit_id` → Unit
  - `category_id` → Category
- If lookup IDs cannot be resolved, UI should show a safe fallback such as `Unknown Department` instead of raw UUIDs.

## Current Direct Accountability Display Coverage

Workers:

- Created by
- Created at
- Last updated by
- Last updated at
- View Details
- View Audit History

Tools:

- Created by
- Created at
- Last updated by
- Last updated at
- View Details
- View Audit History

Transactions:

- Created by
- Created at
- Proof image status
- Proof uploaded by
- Proof uploaded at
- Signed document uploaded by
- Signed document uploaded at
- Approval decided by
- Approval decided at
- Settlement completed by
- Settlement completed at
- Last updated by
- Last updated at
- View Audit History

Pending display coverage:

- Company Settings accountability display.
- Team / Company Users lifecycle accountability display.

---

# Commercial / SaaS Rules

- The same app should support Free and Paid plans.
- Do not create separate apps for free and paid versions.
- Company subscription should determine enabled features and limits.
- Free plan limits must be simple, strict, and useful for demo/testing.
- Paid packages must be company-based.
- User access must depend on active company membership and company subscription status.
- App Store / Google Play builds should be free download/login-based.
- Do not add direct payment buttons inside mobile apps until store billing rules are reviewed.
- B2B subscription payment should preferably be handled outside the mobile app through website, invoice, or customer portal.
- The app should show a safe message like:
  - `Contact your company admin to manage subscription.`
- Production release must include:
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
- Dashboard reads real Supabase data.
- Reports/PDF core reports are working.
- Lost/Damaged approval and settlement workflow core flow is working.
- Offline/network handling phase is completed and manually tested.
- Friendly network error mapper is implemented.
- Unified `AppMessage` behavior is applied to main screens.
- DevicePreview has a separate entry point.
- Normal runtime layout no longer depends directly on DevicePreview.
- Cross-platform image compression foundation is implemented.
- Transaction proof images are compressed before upload.
- Approval document images are compressed before upload when selected file is an image.
- PDF approval documents are uploaded without image compression.
- Company logos are resized/compressed before upload.

## Completed Company / Team / Permission Foundation

- Company Users foundation is implemented.
- Company invitation table, grants, RLS policies, and acceptance/cancellation RPCs are implemented.
- Owner/Admin can invite users by email.
- Pending invitations can be listed and cancelled.
- Invited users can see company invitation details before joining.
- Invited users can accept invitations and join the company.
- Accepted users appear in Company Users with assigned role.
- Duplicate pending invitations are blocked.
- Duplicate active-member invitations are blocked at database level.
- Role-based UI permissions are implemented.
- App navigation is filtered by current company role.
- Workers/Tools/Transactions/Lookups/Reports/Settings actions are restricted by role in Flutter UI.
- Supabase public table RLS write policies are aligned with implemented RBAC matrix.
- Supabase Storage upload policies are aligned with implemented RBAC matrix.
- Secure invitation creation backend is implemented through `invite_company_user`.
- Direct authenticated insert access to `company_invitations` has been closed.
- Multi-company workspace selection is implemented.
- Existing users can receive invitations to additional companies.
- Users with multiple companies can choose a workspace.
- App remembers last selected workspace locally per profile.
- Users can manually switch companies through visible `Switch Company` action.
- Dedicated `Team` area is implemented for company users and member lifecycle management.
- Company user management has been moved out of `Settings`.

## Completed Maintainability / Stability Work

- Company Users UI was modularized.
- Company Users Cubit and pending invitations UI were modularized.
- Team scroll position preservation was implemented.
- Company Settings Cubit and settings UI were modularized.
- Current Context UI was modularized.
- Tools Cubit was modularized.
- Workers Cubit was modularized.
- Search state restoration was fixed for:
  - Tools
  - Workers
  - Transactions
  - Custody Balance
  - Tool Summary
- Workers and Tools preserve alphabetical order after load/add/update.
- Worker-name duplicate protection was strengthened.
- PDF colors and text styles were centralized under:
  - `lib/core/theme/app_pdf_colors.dart`
  - `lib/core/theme/app_pdf_text_styles.dart`

## Completed Company Timezone Foundation

- Backend `companies.timezone` field was added.
- Backend company timezone defaults to `Asia/Dubai`.
- Backend `create_company_with_defaults` accepts `p_timezone`.
- Backend validates timezone using valid IANA timezone names.
- New company report settings seed `default_timezone` from selected company timezone.
- `timezone` package was added to Flutter.
- Timezone database initialization was added in `main.dart`.
- `CompanyModel` includes `timezone`.
- `CompanyProfileModel` includes `timezone`.
- `CreateCompanyRequest` supports full company creation profile fields and `timezone`.
- `AppTimezones` utility was added.
- Searchable timezone picker was added.
- Create Company screen includes:
  - Company Name
  - Trade Name
  - Legal Name
  - Country
  - City
  - Company Timezone
  - Company Email
  - Company Phone
- Company Settings profile form supports timezone editing.
- Current company context can update both company name and timezone after profile changes.
- Centralized company date/time formatter is implemented.
- Transactions UI uses current company timezone.
- Reports/PDF use report/company timezone.
- Audit History UI uses current company timezone.
- Worker and Tool mobile accountability display uses current company timezone.
- Worker and Tool desktop details dialogs use current company timezone.
- Transaction accountability display uses current company timezone.

## Completed Audit History UI Foundation

- Audit Log Flutter model is implemented.
- Audit Logs repository is implemented.
- Audit Logs Cubit and State are implemented.
- Audit History Bottom Sheet is implemented.
- Audit Log tile is implemented.
- Audit Log data change section is implemented.
- Lookup resolver is implemented for audit foreign key display names.
- Worker and Tool Audit History helper functions are implemented.
- Worker cards and tables include `View Audit History`.
- Tool cards and tables include `View Audit History`.
- Transaction details include `View Audit History`.
- Audit History manually tested successfully for Workers and Tools.
- Audit History manually tested successfully for Transactions.
- Worker Department and Job Title display as readable names instead of UUIDs.
- Tool Unit and Category display as readable names instead of UUIDs.
- Transaction audit workflow actions display readable labels.

## Completed Direct Accountability Display Foundation

- Worker model resolves created/updated profile display names and emails.
- Tool model resolves created/updated profile display names and emails.
- Transaction model reads created/proof/document/decision/settlement/updated profile snapshots.
- Workers repository joins `profiles` for `created_by_profile_id` and `updated_by_profile_id`.
- Tools repository joins `profiles` for `created_by_profile_id` and `updated_by_profile_id`.
- Transactions repository selects direct transaction accountability snapshot fields.
- Reusable `RecordAccountabilitySection` was added:
  - `lib/core/widgets/record_accountability_section.dart`
- Worker mobile cards display direct accountability.
- Tool mobile cards display direct accountability.
- Worker desktop details dialog displays direct accountability.
- Tool desktop details dialog displays direct accountability.
- Transaction details dialog displays direct accountability.
- Worker, Tool, and Transaction timestamps use company timezone.
- Desktop tables remain clean without adding extra accountability columns.

---

# Current Active Product Phase

## Phase R — Business Accountability & Audit Trail

Status:

**In Progress**

Completed checkpoints:

- Step R1 — Transactions Backend Alignment
- Step R2A — Transaction Approval Workflow Alignment
- Step R2B — Approval Document Upload Accountability
- Step R3 — General Transaction Update Hardening
- Step R4 — Workers & Tools Accountability
- Step R5 — Audit Logs Foundation
- Step R5.5 — Company Timezone Setting Foundation
- Step R6-A — Audit Logs Flutter Model & Repository Foundation
- Step R6-B — Audit Logs Cubit & State Foundation
- Step R6-C — Audit History UI Foundation
- Step R6-C.2 — Resolve Audit Foreign Key Display Names
- Step R6-D — Connect Audit History to Workers & Tools
- Step R6-E.1 — Resolve Created/Updated Profile Display Names for Workers & Tools
- Step R6-E.2 — Display Direct Accountability in Worker & Tool Mobile Cards
- Step R6-E.3 — Add Worker/Tool Accountability Details for Desktop
- Step R6-F — Transaction Accountability Details Display
- Post R6-F Cleanup — Remove temporary transaction debug prints

Current checkpoint:

- Step R6-F — Transaction Accountability Details Display is completed and pushed.
- Transaction backend accountability fields are completed.
- Transaction controlled RPC workflows write actor snapshots and audit logs.
- Direct authenticated table insert/update access to `public.transactions` is closed.
- Transaction Details displays direct accountability.
- Transaction Details includes `View Audit History`.
- Transaction audit actions display readable labels.

Next checkpoint:

- Step R6-G.1 — Replace `pending-*` transaction proof paths with official `TRX-*` paths

Deferred checkpoint:

- Step R6-G.2 — Make transaction proof uploads web-compatible

---

# Phase R Checkpoints

## Step R1 — Transactions Backend Alignment

Status:

**Completed**

Completed:

- Transaction creation uses secure Supabase RPC `create_custody_transaction`.
- Official `transaction_code` is generated by backend.
- `created_by_profile_id` is derived from `private.current_profile_id()`.
- Flutter no longer sends trusted transaction creation accountability fields.
- General transaction creation relies on backend worker/tool snapshots.

---

## Step R2A — Transaction Approval Workflow Alignment

Status:

**Completed**

Completed:

- Lost/Damaged approval workflow uses secure RPCs:
  - `approve_lost_damaged_transaction`
  - `reject_lost_damaged_transaction`
  - `settle_lost_damaged_transaction`
- Flutter no longer sends:
  - `decidedByProfileId`
  - `settledByProfileId`
- Approval/rejection/settlement actors are derived from authenticated backend context.

---

## Step R2B — Approval Document Upload Accountability

Status:

**Completed**

Completed:

- Signed approval document upload uses secure RPC:
  - `upload_transaction_approval_document`
- Flutter uploads file to Supabase Storage.
- Backend writes:
  - `approval_document_path`
  - `approval_document_uploaded_by_profile_id`
  - `approval_document_uploaded_at`
  - `updated_at`
- Flutter reads upload accountability fields but does not write them directly.

---

## Step R3 — General Transaction Update Hardening

Status:

**Completed**

Completed:

- General transaction editing is disabled.
- `TransactionsRepo.updateTransaction()` throws `UnsupportedError`.
- `TransactionsCubit.updateTransaction()` returns false with a clear user-facing message.
- Transaction changes should be performed only through controlled workflows:
  - Create transaction RPC
  - Approval document upload RPC
  - Approve/reject/settle RPCs
  - Future correction/void workflow

---

## Step R4 — Workers & Tools Accountability

Status:

**Completed**

Completed:

- Supabase `workers` and `tools` were audited before implementation.
- `updated_by_profile_id` was added to:
  - `workers`
  - `tools`
- Secure backend RPCs were added for Workers:
  - `create_worker`
  - `update_worker`
  - `deactivate_worker`
  - `reactivate_worker`
- Secure backend RPCs were added for Tools:
  - `create_tool`
  - `update_tool`
  - `deactivate_tool`
  - `reactivate_tool`
- Worker and Tool create/update accountability is derived from backend authenticated context through `private.current_profile_id()`.
- Flutter Workers create/update flow uses secure RPCs instead of direct table insert/update.
- Flutter Tools create/update flow uses secure RPCs instead of direct table insert/update.
- Direct authenticated `INSERT`, `UPDATE`, and `DELETE` access was revoked from:
  - `workers`
  - `tools`
- Workers UI supports active/inactive filtering and deactivate/reactivate.
- Tools UI supports active/inactive filtering and deactivate/reactivate.
- Open custody blocking was tested and passed for Workers and Tools.
- Reports can select active and inactive Workers/Tools without depending on current screen filters.

Remaining:

- None.

---

## Step R5 — Audit Logs Foundation

Status:

**Completed and manually verified**

Backend completed:

- Created `public.audit_logs`.
- Added RLS to `audit_logs`.
- Granted `SELECT` only to `authenticated`.
- Revoked direct `INSERT`, `UPDATE`, and `DELETE` access from normal app users.
- Added protected helper:
  - `private.write_audit_log(...)`
- Helper derives actor from:
  - `private.current_profile_id()`
- Helper stores actor snapshots:
  - `actor_name_snapshot`
  - `actor_email_snapshot`
- Helper validates JSON object structure for:
  - `old_data`
  - `new_data`
  - `metadata`
- Audit logs are append-only from perspective of normal app users.

Connected RPCs:

Workers:

- `create_worker`
- `update_worker`
- `deactivate_worker`
- `reactivate_worker`

Tools:

- `create_tool`
- `update_tool`
- `deactivate_tool`
- `reactivate_tool`

Verification:

- Worker create/update/deactivate/reactivate audit logs tested.
- Tool create/update/deactivate/reactivate audit logs tested.
- Normal app users cannot directly insert/update/delete audit logs.

---

## Step R5.5 — Company Timezone Setting Foundation

Status:

**Completed**

Completed:

- Added `companies.timezone`.
- Updated company creation flow to accept timezone.
- Added timezone utility and searchable picker.
- Added timezone to company models and create company request.
- Added centralized `CompanyDateTimeFormatter`.
- Applied company timezone formatting to:
  - Transactions UI
  - Reports/PDF
  - Audit History
  - Worker accountability display
  - Tool accountability display
  - Transaction accountability display

---

## Step R6-A — Audit Logs Flutter Model & Repository Foundation

Status:

**Completed**

Completed:

- `AuditLogModel` implemented.
- Audit Logs repository implemented.
- JSON parsing for old/new/metadata implemented.
- Actor display name fallback implemented.
- Entity label fallback implemented.

---

## Step R6-B — Audit Logs Cubit & State Foundation

Status:

**Completed**

Completed:

- `AuditLogsCubit` implemented.
- `AuditLogsState` implemented.
- Load audit logs by entity implemented.
- Loading/error/empty states implemented.

---

## Step R6-C — Audit History UI Foundation

Status:

**Completed**

Completed:

- Audit History Bottom Sheet implemented.
- Audit Log tile implemented.
- Audit Log old/new data section implemented.
- Audit History timestamps use company timezone.
- Audit History supports retry and empty states.

---

## Step R6-C.2 — Resolve Audit Foreign Key Display Names

Status:

**Completed**

Completed:

- Lookup resolver implemented for audit display names.
- Department IDs resolve to department names.
- Job title IDs resolve to job title names.
- Tool unit IDs resolve to unit names.
- Tool category IDs resolve to category names.
- Safe fallback shown when lookup cannot be resolved.

---

## Step R6-D — Connect Audit History to Workers & Tools

Status:

**Completed**

Completed:

- Worker Audit History helper implemented.
- Tool Audit History helper implemented.
- Worker cards and desktop table actions include `View Audit History`.
- Tool cards and desktop table actions include `View Audit History`.
- Audit History manually tested for Workers and Tools.

---

## Step R6-E — Direct Accountability Display for Workers & Tools

Status:

**Completed and pushed**

Completed:

- Worker model resolves created/updated profile display names.
- Tool model resolves created/updated profile display names.
- Workers repository joins `profiles` for created/updated actors.
- Tools repository joins `profiles` for created/updated actors.
- Reusable `RecordAccountabilitySection` added.
- Worker mobile cards show direct accountability.
- Tool mobile cards show direct accountability.
- Worker desktop details dialog shows direct accountability.
- Tool desktop details dialog shows direct accountability.
- Worker and Tool desktop tables remain clean without extra accountability columns.

---

## Step R6-F — Transaction Accountability Details Display

Status:

**Completed and pushed**

Goal:

- Complete transaction accountability from backend to Flutter UI.
- Keep transaction tables clean without adding crowded accountability columns.
- Show transaction accountability inside transaction details.
- Connect transaction audit history to the existing Audit History UI.

Backend completed:

- Added transaction accountability columns:
  - `created_by_name_snapshot`
  - `created_by_email_snapshot`
  - `proof_image_uploaded_by_profile_id`
  - `proof_image_uploaded_by_name_snapshot`
  - `proof_image_uploaded_by_email_snapshot`
  - `proof_image_uploaded_at`
  - `approval_document_uploaded_by_name_snapshot`
  - `approval_document_uploaded_by_email_snapshot`
  - `approval_decided_by_name_snapshot`
  - `approval_decided_by_email_snapshot`
  - `settled_by_name_snapshot`
  - `settled_by_email_snapshot`
  - `updated_by_profile_id`
  - `updated_by_name_snapshot`
  - `updated_by_email_snapshot`

- Updated transaction RPCs:
  - `create_custody_transaction`
  - `upload_transaction_approval_document`
  - `approve_lost_damaged_transaction`
  - `reject_lost_damaged_transaction`
  - `settle_lost_damaged_transaction`

- Transaction RPCs now write:
  - Actor profile IDs
  - Actor name/email snapshots
  - Last updated accountability
  - Audit logs for important workflow actions

- Added transaction audit actions:
  - `transaction_created`
  - `transaction_approval_document_uploaded`
  - `transaction_approved`
  - `transaction_rejected`
  - `transaction_settled`

- Closed direct authenticated table mutations:
  - `INSERT` revoked from `public.transactions`
  - `UPDATE` revoked from `public.transactions`
  - `DELETE` remains unavailable to normal app users

- Transaction mutations now go through controlled RPC workflows only.

Flutter completed:

- Updated `TransactionModel` to read transaction accountability fields.
- Updated `TransactionsRepo` select columns to return new accountability fields.
- Added transaction details accountability section.
- Added transaction audit history helper.
- Added `View Audit History` button inside transaction details.
- Added readable audit action labels for transaction workflow actions.

Manual verification:

- Issue transaction was created successfully.
- Created by, proof uploaded by, and last updated by accountability displayed correctly.
- Lost transaction approval workflow was tested:
  - Created
  - Approval document uploaded
  - Approved
  - Settled
- Rejected lost transaction workflow was tested:
  - Created
  - Approval document uploaded
  - Rejected
- Audit logs were created and displayed for transaction workflows.
- Transaction details remain clean and do not overcrowd transaction tables.
- Accountability timestamps use company timezone.

Remaining technical improvements:

- Remove temporary debug prints from `TransactionsCubitCrud` if still present.
- Make transaction proof image upload web-compatible.
- Replace `pending-*` proof image storage folders with official transaction code paths after backend transaction code generation.

---

## Step R6-G — Transaction Proof Storage and Web Upload Improvements

Status:

**Next**

Goal:

- Make transaction proof image upload work correctly on Flutter Web.
- Keep Windows/Desktop and mobile upload behavior working.
- Avoid saving temporary `pending-*` proof folders as the final long-term storage path.
- Move toward official transaction-code-based proof paths.

Planned work:

- Review `TransactionStorageService`.
- Review `TransactionImagePickerField`.
- Support file bytes for web uploads instead of relying only on `dart:io File`.
- Keep image compression behavior.
- Ensure proof image upload is network-aware.
- Design a safe strategy for replacing `pending-*` folders with official `TRX-*` paths.
- Confirm Storage policies still protect company folders.
- Test on Windows and Web.
- Later test on mobile/tablet.

---

# Known Technical Debt / Watch List

## Immediate cleanup

- Remove temporary debug prints from transaction add flow if still present:
  - `ADD TRANSACTION ERROR`
  - `ADD TRANSACTION STACKTRACE`

## Transaction storage

- Proof image path currently may use:
  - `{companyId}/transactions/pending-{timestamp}/proof-{timestamp}.png`
- Future improvement should store final proof images under:
  - `{companyId}/transactions/{transactionCode}/...`

## Web upload support

- Current proof image upload path relies on local file path behavior on desktop/mobile.
- Flutter Web needs bytes-based upload support.
- `ImageCompressionService.compressImageBytes(...)` already exists and can support web-friendly compression.

## Database migration documentation

- Supabase SQL changes for Step R6-F were executed manually.
- Future improvement:
  - Add formal migration files or a backend change log folder to the repo.
  - Keep all production schema/RPC changes reproducible from source control.

---

# Future Roadmap Candidates

## Phase S — Transaction Correction / Void Workflow

Potential scope:

- Void/cancel transaction workflow.
- Correction transaction flow.
- Admin-only correction approval.
- Audit trail for correction/void actions.
- Strong business rules to prevent custody balance corruption.

## Phase T — Company Settings Accountability Display

Potential scope:

- Company profile update accountability.
- Report settings update accountability.
- Document template update accountability.
- Logo upload accountability.
- Company settings audit history entry points.

## Phase U — Team / Company Users Lifecycle Accountability

Potential scope:

- Invited by
- Invitation accepted by
- Role changed by
- Deactivated by
- Reactivated by
- Removed by, if remove-access is implemented later
- Team member audit history entry points

## Phase V — SaaS / Subscription Foundation

Potential scope:

- Company subscription records.
- Trial/free/paid plan model.
- Plan limits.
- Secure plan enforcement at database/RPC level.
- Billing workflow outside mobile stores where appropriate.
- Subscription status display in app.

## Phase W — Production Release Preparation

Potential scope:

- Environment separation.
- Production Supabase project.
- Privacy Policy.
- Terms of Service.
- Support contact.
- Store review demo account.
- Desktop installer flow.
- Web landing page.
- Google Play release.
- App Store release.

---

# End of Roadmap