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

`682db0592248232393f7966ea7377bea73f0de4f`

Commit message:

`feat(accountability): show worker and tool direct accountability`

Current product phase:

**Phase R — Business Accountability & Audit Trail**

Current completed checkpoint:

**Step R6-E — Direct Accountability Display for Workers & Tools**

Status:

**Partially completed and pushed**

Completed sub-steps:

- **Step R6-E.1 — Resolve Created/Updated Profile Display Names for Workers & Tools**
- **Step R6-E.2 — Display Direct Accountability in Worker & Tool Mobile Cards**

Verification status:

- `dart format lib` completed.
- `flutter analyze` completed with no issues.
- Worker and Tool direct accountability code was committed and pushed.
- Repo review confirmed the pushed commit.

Next required checkpoint:

**Step R6-E.3 — Add Worker/Tool Accountability Details for Desktop**

Next recommended engineering step:

**Step R6-E.3 — Add a desktop-friendly accountability display without overcrowding tables**

Recommended direction:

- Do not add four extra accountability columns directly into Workers/Tools desktop tables.
- Prefer a desktop details dialog, bottom sheet, side panel, or expandable details action.
- Keep mobile cards and desktop tables clean and readable.
- Reuse `RecordAccountabilitySection` where possible.

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

Remaining:

- Apply company timezone formatting to future accountability display sections such as desktop details, transaction details, company settings, and team/member lifecycle displays.

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

Some tables currently have profile IDs only. Display snapshots can be added later where needed.

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

## Current Direct Accountability Display Rules

Worker records should show:

- Created by
- Created at
- Last updated by
- Last updated at
- View Audit History

Tool records should show:

- Created by
- Created at
- Last updated by
- Last updated at
- View Audit History

Current completed display coverage:

- Workers mobile cards show direct accountability.
- Tools mobile cards show direct accountability.
- Worker and Tool accountability timestamps use company timezone.
- Worker and Tool display names are resolved from `profiles.full_name` and `profiles.email`.
- Safe fallback is `Unknown User` when no display name or email is available.

Pending display coverage:

- Workers desktop accountability display.
- Tools desktop accountability display.
- Transaction details expanded accountability display.
- Company Settings accountability display.
- Team / Company Users lifecycle accountability display.

## Direct Display Examples

Transaction details should eventually show:

- Created by
- Created at
- Proof uploaded by
- Signed document uploaded by
- Approval decided by
- Settlement completed by
- Last updated by

Company Settings should eventually show:

- Last profile update by
- Last report settings update by
- Last document template update by
- Last logo upload by

Team / Company Users should eventually show:

- Invited by
- Invitation accepted by
- Role changed by
- Deactivated by
- Reactivated by
- Removed by, if remove-access is implemented later

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
- Audit History manually tested successfully for Workers and Tools.
- Worker Department and Job Title display as readable names instead of UUIDs.
- Tool Unit and Category display as readable names instead of UUIDs.

## Completed Direct Accountability Display Foundation

- Worker model resolves created/updated profile display names and emails.
- Tool model resolves created/updated profile display names and emails.
- Workers repository joins `profiles` for `created_by_profile_id` and `updated_by_profile_id`.
- Tools repository joins `profiles` for `created_by_profile_id` and `updated_by_profile_id`.
- Reusable `RecordAccountabilitySection` was added:
  - `lib/core/widgets/record_accountability_section.dart`
- Worker mobile cards display:
  - Created by
  - Created at
  - Last updated by
  - Last updated at
- Tool mobile cards display:
  - Created by
  - Created at
  - Last updated by
  - Last updated at
- Worker and Tool mobile accountability timestamps use company timezone.
- `flutter analyze` passed with no issues.

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

Current checkpoint:

- Step R6-E — Direct Accountability Display for Workers & Tools is partially completed.
- Mobile cards are completed.
- Desktop display still needs a dedicated implementation.

Next checkpoint:

- Step R6-E.3 — Add Worker/Tool Accountability Details for Desktop

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
- Flutter no longer sends trusted `created_by_profile_id` for Worker/Tool creation.
- Direct authenticated `INSERT`, `UPDATE`, and `DELETE` access was revoked from:
  - `workers`
  - `tools`
- Workers UI supports:
  - Active filter
  - Inactive filter
  - Deactivate worker
  - Reactivate worker
- Tools UI supports:
  - Active filter
  - Inactive filter
  - Deactivate tool
  - Reactivate tool
- Worker and Tool deactivation use soft status change instead of physical delete.
- Open custody blocking was tested and passed for Workers and Tools.
- Reports filters load Workers and Tools independently from report-specific data sources.
- Reports can select active and inactive Workers/Tools without depending on current Workers/Tools screen filter.

Remaining:

- None.

---

## Step R5 — Audit Logs Foundation

Status:

**Completed and manually verified**

Goal:

- Create protected audit logs foundation.
- Record who did what, when, and on which record.
- Connect initial audit logging to Workers and Tools actions.
- Ensure actor profile comes from authenticated backend context, not Flutter.
- Prevent normal app users from editing or deleting audit logs.

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

Behavior:

- Create actions store `old_data = null` and full `new_data`.
- Update actions store both `old_data` and `new_data`.
- Update actions do not create audit logs when there is no actual data change.
- Deactivate actions record status change:
  - `active` → `inactive`
- Reactivate actions record status change:
  - `inactive` → `active`
- Repeated deactivate on already inactive record is blocked with a clear backend error.
- Reactivate on already active record returns without creating a fake audit log.

Manual verification completed:

Tools:

- `create_tool`
- `update_tool`
- `deactivate_tool`
- `reactivate_tool`

Workers:

- `create_worker`
- `update_worker`
- `deactivate_worker`
- `reactivate_worker`

Verified audit fields:

- `action`
- `entity_type`
- `entity_label_snapshot`
- `actor_name_snapshot`
- `actor_email_snapshot`
- `old_data`
- `new_data`
- `created_at`

Remaining:

- None.

---

## Step R5.5 — Company Timezone Setting Foundation

Status:

**Completed**

Reason:

Audit history, custody records, and reports are business-critical. Time must be displayed according to company timezone, not hardcoded UAE time.

Goal:

- Add company-level timezone support before building final Audit History UI.
- Keep database timestamps in UTC.
- Display timestamps using current company timezone.
- Use `Asia/Dubai` only as safe default/fallback, not as hardcoded global display timezone.

Completed backend work:

- Added `companies.timezone text not null default 'Asia/Dubai'`.
- Added non-blank validation for `companies.timezone`.
- Backfilled existing company timezone values where needed.
- Updated `create_company_with_defaults` to accept `p_timezone`.
- New companies store timezone in `companies.timezone`.
- New company report settings seed `default_timezone` from selected company timezone.
- RPC validates timezone using valid IANA timezone names.

Completed Flutter foundation work:

- Added `timezone` dependency.
- Initialized timezone database in `main.dart`.
- Added `timezone` to `CompanyModel`.
- Added `timezone` to `CompanyProfileModel`.
- Added timezone and company profile fields to `CreateCompanyRequest`.
- Added `AppTimezones` helper.
- Added reusable `SearchableTimezoneFormField`.
- Expanded Create Company screen with:
  - Company Name
  - Trade Name
  - Legal Name
  - Country
  - City
  - Company Timezone
  - Company Email
  - Company Phone
- Added timezone editing to Company Settings profile form.
- Updated current company context after profile changes so company name and timezone remain in sync.

Completed formatter and display work:

- Added centralized company date/time formatter:
  - `lib/core/utils/company_date_time_formatter.dart`
- Updated transaction date formatting wrapper to use centralized formatter:
  - `lib/features/transactions/presentation/functions/format_transaction_date.dart`
- Applied company timezone formatting to:
  - Transactions table
  - Transaction cards
  - Transaction details
  - Approval decision timestamps
  - Settlement timestamps
- Fixed transaction details dialog context access by preserving `CurrentContextCubit` inside the dialog.
- Updated report/PDF date formatting to use centralized formatter.
- Applied report/company timezone formatting to:
  - Transactions PDF table
  - PDF generated date
  - PDF document control effective date
  - PDF filters date range
  - Lost/Damaged Approval PDF transaction date
- Audit History UI now uses the same centralized formatter.
- Worker and Tool mobile accountability cards now use the same centralized formatter.

Remaining:

- None for completed screens.
- Future accountability screens must continue using the same formatter.

Expected result:

- UAE company sees UAE time.
- India company sees India time.
- Egypt company sees Egypt time.
- Database remains UTC and globally consistent.
- UI, reports, PDF, Audit History, and current accountability displays use company timezone where implemented.

---

## Step R6 — Audit History UI & Record Accountability Display

Status:

**In Progress**

Depends on:

- Step R5 completed.
- Step R5.5 completed.

Goal:

- Allow users to open full audit history for a specific record.
- Allow users to see direct accountability inside important record screens.

Completed in Step R6-A — Audit Logs Flutter Model & Repository Foundation:

- Added Audit Log model:
  - `lib/features/audit_logs/data/models/audit_log_model.dart`
- Added Audit Logs repository:
  - `lib/features/audit_logs/data/repo/audit_logs_repo.dart`
- Repository supports:
  - Audit logs by entity.
  - Recent audit logs for future use.
- Audit log model parses:
  - Actor profile
  - Actor name/email snapshots
  - Action
  - Entity type
  - Entity ID
  - Entity label snapshot
  - Old data
  - New data
  - Metadata
  - Created timestamp

Completed in Step R6-B — Audit Logs Cubit & State Foundation:

- Added Audit Logs Cubit.
- Added Audit Logs State.
- Added loading/error/empty handling foundation.
- Added entity-specific audit loading flow.
- Added recent audit loading flow for future use.

Completed in Step R6-C — Audit History UI Foundation:

- Added Audit History Bottom Sheet.
- Added Audit Log tile.
- Added readable action labels.
- Added actor display support.
- Added created timestamp display.
- Added old vs new data change display.
- Avoided raw JSON display for normal users.
- Used `AppMessage` / friendly error handling where applicable.

Completed in Step R6-C.2 — Resolve Audit Foreign Key Display Names:

- Added lookup resolver for audit logs.
- Resolved Worker audit foreign keys:
  - `department_id` → Department name
  - `job_title_id` → Job Title name
- Resolved Tool audit foreign keys:
  - `unit_id` → Unit name
  - `category_id` → Category name
- Added safe fallback labels when lookup values cannot be resolved.

Completed in Step R6-D — Connect Audit History to Workers & Tools:

- Worker cards include `View Audit History`.
- Worker desktop/table actions include `View Audit History`.
- Tool cards include `View Audit History`.
- Tool desktop/table actions include `View Audit History`.
- Worker Audit History opens by entity:
  - `entity_type = worker`
  - `entity_id = worker.id`
- Tool Audit History opens by entity:
  - `entity_type = tool`
  - `entity_id = tool.id`
- Audit History uses current company timezone.
- Worker Department and Job Title display as readable names instead of UUIDs.
- Tool Unit and Category display as readable names instead of UUIDs.
- Step was manually verified successfully.

Completed in Step R6-E.1 — Resolve Created/Updated Profile Display Names for Workers & Tools:

- `WorkerModel` now includes:
  - `createdByProfileName`
  - `createdByProfileEmail`
  - `updatedByProfileName`
  - `updatedByProfileEmail`
  - `createdByDisplayName`
  - `updatedByDisplayName`
- `ToolModel` now includes:
  - `createdByProfileName`
  - `createdByProfileEmail`
  - `updatedByProfileName`
  - `updatedByProfileEmail`
  - `createdByDisplayName`
  - `updatedByDisplayName`
- `WorkersRepo` now joins:
  - `created_by_profile:profiles!workers_created_by_profile_id_fkey`
  - `updated_by_profile:profiles!workers_updated_by_profile_id_fkey`
- `ToolsRepo` now joins:
  - `created_by_profile:profiles!tools_created_by_profile_id_fkey`
  - `updated_by_profile:profiles!tools_updated_by_profile_id_fkey`
- Display name fallback rule:
  - Use profile full name.
  - If full name is missing, use profile email.
  - If both are missing, show `Unknown User`.

Completed in Step R6-E.2 — Display Direct Accountability in Worker & Tool Mobile Cards:

- Added reusable widget:
  - `lib/core/widgets/record_accountability_section.dart`
- Worker mobile cards now show:
  - Created by
  - Created at
  - Last updated by
  - Last updated at
- Tool mobile cards now show:
  - Created by
  - Created at
  - Last updated by
  - Last updated at
- Worker and Tool mobile cards pass current company timezone.
- Accountability timestamps use `CompanyDateTimeFormatter`.
- `flutter analyze` completed with no issues.
- Changes were committed and pushed.

Remaining in Step R6-E:

- Add desktop-friendly Worker accountability display.
- Add desktop-friendly Tool accountability display.
- Avoid overcrowding existing desktop tables with too many extra columns.

Recommended next sub-step:

## Step R6-E.3 — Add Worker/Tool Accountability Details for Desktop

Status:

**Next**

Goal:

- Show the same direct accountability data for desktop users without making Workers/Tools tables unreadable.

Recommended UI options:

1. Details dialog from a row action.
2. Bottom sheet from a row action.
3. Side panel on desktop.
4. Expandable row section.

Preferred direction:

- Add a reusable details action such as `View Details`.
- Reuse `RecordAccountabilitySection`.
- Keep existing `View Audit History` action.
- Keep edit/deactivate/reactivate flows unchanged.
- Do not add many columns directly to the desktop table unless a later product decision requires it.

---

# Immediate Next Work Queue

1. **Step R6-E.3 — Add Worker/Tool Accountability Details for Desktop**
   - Show accountability in a clean desktop-friendly details view.
   - Reuse existing `RecordAccountabilitySection`.
   - Keep Workers/Tools tables readable.

2. **Step R6-F — Transaction Direct Accountability Display**
   - Show transaction creation/update/accountability details.
   - Include proof upload, approval document upload, decision, settlement, and update actors where available.

3. **Step R6-G — Company Settings Accountability Display**
   - Show last profile/settings/template/logo update information where backend fields exist.
   - Add backend fields later if missing.

4. **Step R6-H — Team / Company Users Lifecycle Accountability Display**
   - Show invited by, accepted by, role changed by, deactivated by, reactivated by, and future removed by.

---

# Manual Verification Checklist for Current State

After pulling latest code on any machine:

```bash
dart format lib
flutter analyze
```

Expected result:

```text
No issues found
```

Functional checks:

- Open Workers screen.
- Switch to mobile layout.
- Confirm Worker card shows Accountability section.
- Confirm Worker card shows Created by / Created at / Last updated by / Last updated at.
- Confirm Worker Audit History still opens.
- Confirm Worker Edit still opens.
- Confirm Worker Deactivate/Reactivate still works.
- Open Tools screen.
- Switch to mobile layout.
- Confirm Tool card shows Accountability section.
- Confirm Tool card shows Created by / Created at / Last updated by / Last updated at.
- Confirm Tool Audit History still opens.
- Confirm Tool Edit still opens.
- Confirm Tool Deactivate/Reactivate still works.
- Confirm timestamps are formatted using company timezone.

---

# Current Commit References

Latest verified pushed commit:

`682db0592248232393f7966ea7377bea73f0de4f`

Commit message:

`feat(accountability): show worker and tool direct accountability`

Previous verified audit commit:

`491a2d35cfa196940fbd8be18cf0123ad6b3dae6`

Previous commit message:

`feat(audit): add audit history UI for workers and tools`