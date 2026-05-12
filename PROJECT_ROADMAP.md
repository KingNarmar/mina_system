# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Source of Truth

This roadmap is the single source of truth for the Mina System project.

It is based on the real GitHub repository and the verified Supabase backend state, not the README.

The README may be useful for public explanation, but if it conflicts with this roadmap, this roadmap wins.

---

## Latest Verified State

Latest verified pushed **code** commit:

`84f6eeb049dbc868c9fa8c0fad1e391ca125ae68`

Commit message:

`feat(accountability): align workers and tools create update with secure RPCs`

Latest verified backend checkpoint:

**Step R5 — Audit Logs Foundation**

Status:

**Completed and manually verified**

Important note:

- The R5 backend SQL changes were applied directly in Supabase.
- The roadmap still needs to be committed/pushed after this document update is approved.

Current high-level state:

- Current product phase:
  - **Phase R — Business Accountability & Audit Trail**
- Current completed checkpoint:
  - **Step R5 — Audit Logs Foundation**
- Next recommended checkpoint:
  - **Step R5.5 — Company Timezone Setting Foundation**
- Current parallel engineering checkpoint:
  - **None**

---

# Project Vision

Mina System is a Flutter + Supabase inventory and custody management system built as a real multi-company SaaS/product.

The system manages:

- Companies
- Company users
- User roles and permissions
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
- Direct user accountability on important records
- Audit trail history for important business actions
- Future subscriptions, plans, usage limits, and storage limits

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
- Do not make large changes in one step.
- Do not change a working UI unless needed.
- Always review the real GitHub repo before continuing a new step.
- Do not rely only on README because it may be outdated.
- Keep `PROJECT_ROADMAP.md` as the single source of truth.
- Update this roadmap after each completed feature or major checkpoint.
- Do not create multiple roadmap files.
- Keep implementation scalable and maintainable.
- Prefer completing one coherent feature/checkpoint before opening another large area.
- Avoid mixing unrelated architecture changes inside the same checkpoint.
- Do not split files only to reduce line count.
- Split files only when responsibilities are mixed or maintainability clearly improves.
- Large but cohesive files may remain as-is.
- Preserve current UI, workflow, permissions, validation, and business logic during refactors unless an approved bug fix is part of the batch.
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

Backend security-sensitive features must be tested at database level where applicable, not only through Flutter UI.

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

# Supabase Rules

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

- Business-facing UI, reports, PDFs, and Audit History screens must display timestamps using the current company timezone.
- The app must not permanently hardcode UAE time for all companies.
- UAE time may only be used as a temporary fallback during UAE-based testing until company timezone support is implemented.

## Company Timezone Rule

A future company-level timezone setting must be added before building the final Audit History UI.

Recommended field:

`companies.timezone text not null default 'Asia/Dubai'`

or an equivalent company settings field.

The timezone value should use IANA timezone names, such as:

- `Asia/Dubai`
- `Asia/Kolkata`
- `Africa/Cairo`
- `Asia/Riyadh`

Do not rely only on fixed offsets such as `+04:00`, because some countries use daylight saving time.

## Audit Display Example

Stored value:

`2026-05-12 14:50:54+00`

Displayed for UAE company:

`2026-05-12 18:50:54 Asia/Dubai`

Displayed for India company:

`2026-05-12 20:20:54 Asia/Kolkata`

## Roadmap Decision

Before implementing the final Audit History UI:

- Add company timezone foundation.
- Load timezone through current company context.
- Format all audit/report timestamps using the current company timezone.
- Keep UTC available internally for technical verification and cross-region consistency.

---

# UI / Theme Rules

- Colors should be centralized inside `AppColors`.
- Do not use direct widget-level colors like `Colors.green` or `Colors.orange` unless they are first added to `AppColors`.
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
- If the backend loads a list in a defined order, local add/update state should preserve the same order unless a product decision explicitly changes sorting behavior.
- Long scrollable screens that rebuild after mutations should preserve scroll position when practical.

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
- Dialogs must respect available screen height.
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
- File upload from device storage should remain supported as a fallback.

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

The current implementation uses fixed role-based permissions.

Current roles:

- `owner`
- `admin`
- `warehouse_manager`
- `warehouse_user`
- `viewer`

Current rule:

- Permissions are assigned by role.
- The owner changes a user's role to change their access level.
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

- Keep the permission helper structure ready for:
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
  - Decide later whether production requires an additional database-level unique protection for normalized worker names.

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

Some tables may currently have profile IDs only. Display snapshots can be added later where needed.

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

## Direct Display Examples

Transaction details should show:

- Created by
- Created at
- Proof uploaded by
- Signed document uploaded by
- Approval decided by
- Settlement completed by
- Last updated by

Worker details should show:

- Created by
- Created at
- Last updated by
- Last updated at
- View Audit History

Tool details should show:

- Created by
- Created at
- Last updated by
- Last updated at
- View Audit History

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
- Dashboard reads real Supabase data.
- Reports / PDF core reports are working.
- Lost/Damaged approval and settlement workflow core flow is working.
- Offline/network handling phase is completed and manually tested.
- Friendly network error mapper is implemented.
- Unified `AppMessage` behavior is applied to main screens.
- DevicePreview has a separate entry point.
- Normal runtime layout no longer depends directly on DevicePreview.
- Cross-platform image compression foundation is implemented.
- Transaction proof images are compressed before upload.
- Approval document images are compressed before upload when the selected file is an image.
- PDF approval documents are uploaded without image compression.
- Company logos are resized/compressed before upload.

## Completed Company / Team / Permission Foundation

- Company Users foundation is implemented.
- Company invitation table, grants, RLS policies, and acceptance/cancellation RPCs are implemented.
- Owner/Admin can invite users by email.
- Pending invitations can be listed and cancelled.
- Invited users can see company invitation details before joining.
- Invited users can accept invitations and join the company.
- Accepted users appear in Company Users with their assigned role.
- Duplicate pending invitations are blocked.
- Duplicate active-member invitations are blocked at database level.
- Role-based UI permissions are implemented.
- App navigation is filtered by current company role.
- Workers/Tools/Transactions/Lookups/Reports/Settings actions are restricted by role in Flutter UI.
- Supabase public table RLS write policies are aligned with the implemented RBAC matrix.
- Supabase Storage upload policies are aligned with the implemented RBAC matrix.
- Secure invitation creation backend is implemented through `invite_company_user`.
- Direct authenticated insert access to `company_invitations` has been closed.
- Multi-company workspace selection is implemented.
- Existing users can receive invitations to additional companies.
- Users with multiple companies can choose a workspace.
- The app remembers the last selected workspace locally per profile.
- Users can manually switch companies through a visible `Switch Company` action.
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
- No Batch 7 is currently required. Future refactors should be tied to real product or maintenance value, not line count.

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

Next recommended checkpoint:

- Step R5.5 — Company Timezone Setting Foundation

Then:

- Step R6 — Audit History UI & Record Accountability Display

---

# Phase R Checkpoints

## Step R1 — Transactions Backend Alignment

Status:

**Completed**

Completed:

- Transaction creation now uses secure Supabase RPC `create_custody_transaction`.
- Official `transaction_code` is generated by the backend.
- `created_by_profile_id` is derived from `private.current_profile_id()`.
- Flutter no longer sends trusted transaction creation accountability fields.
- General transaction creation now relies on backend worker/tool snapshots.

---

## Step R2A — Transaction Approval Workflow Alignment

Status:

**Completed**

Completed:

- Lost/Damaged approval workflow now uses secure RPCs:
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

- Signed approval document upload now uses secure RPC:
  - `upload_transaction_approval_document`
- Flutter uploads the file to Supabase Storage.
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
- `TransactionsRepo.updateTransaction()` now throws `UnsupportedError`.
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
- Worker and Tool deactivation now use soft status change instead of physical delete.
- Open custody blocking was tested and passed for Workers and Tools.
- Reports filters now load Workers and Tools independently from report-specific data sources.
- Reports can select active and inactive Workers/Tools without depending on the current Workers/Tools screen filter.

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
- Audit logs are append-only from the perspective of normal app users.

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

- `create_tool` ✅
- `update_tool` ✅
- `deactivate_tool` ✅
- `reactivate_tool` ✅

Workers:

- `create_worker` ✅
- `update_worker` ✅
- `deactivate_worker` ✅
- `reactivate_worker` ✅

Verified audit fields:

- `action`
- `entity_type`
- `entity_label_snapshot`
- `actor_name_snapshot`
- `actor_email_snapshot`
- `old_data`
- `new_data`
- `created_at`

Important result:

- Audit logs now correctly show:
  - Who performed the action
  - What action was performed
  - Which record was affected
  - What changed from old data to new data
  - When the action happened in UTC

Remaining in Step R5:

- None.

---

## Step R5.5 — Company Timezone Setting Foundation

Status:

**Next**

Reason:

Audit history, custody records, and reports are business-critical. Time must be displayed according to the company timezone, not hardcoded UAE time.

Goal:

- Add company-level timezone support before building the final Audit History UI.
- Keep database timestamps in UTC.
- Display timestamps using current company timezone.
- Use temporary fallback `Asia/Dubai` only until company timezone support is implemented.

Suggested backend work:

- Add timezone field to `companies` or company settings.
- Recommended field:
  - `timezone text not null default 'Asia/Dubai'`
- Store timezone using IANA timezone names.
- Validate timezone values where practical.

Suggested Flutter work:

- Add timezone to current company context.
- Add a centralized date/time formatter.
- Use it in:
  - Audit History UI
  - Reports
  - Transaction details
  - Worker details
  - Tool details
  - PDF reports where business timestamps are shown

Expected result:

- UAE company sees UAE time.
- India company sees India time.
- Egypt company sees Egypt time.
- Database remains UTC and globally consistent.

---

## Step R6 — Audit History UI & Record Accountability Display

Status:

**Planned**

Depends on:

- Step R5 completed.
- Step R5.5 company timezone foundation completed.

Goal:

- Allow the user to see direct accountability inside important record screens.
- Allow the user to open full audit history for a specific record.

Backend/API expected work:

- Add Audit Log model.
- Add Audit Logs repository/service.
- Add query methods for:
  - Audit logs by entity:
    - `company_id`
    - `entity_type`
    - `entity_id`
  - Recent audit logs if needed later
- Ensure queries are filtered by `currentCompanyId`.

UI expected work:

- Worker details:
  - Show created/updated accountability where available.
  - Add `View Audit History`.
- Tool details:
  - Show created/updated accountability where available.
  - Add `View Audit History`.
- Audit History view:
  - Timeline/list of actions.
  - Actor name/email.
  - Action date/time displayed using company timezone.
  - Old data vs new data in a readable format.
  - Do not show raw JSON to normal users unless a developer/admin view is explicitly added later.

Design rule:

- The record screen should show direct accountability immediately.
- Full audit history should be available through a separate action such as `View Audit History`.

---

# Future Phase R Extensions

After Workers and Tools audit history UI is stable, extend audit logging to:

Transactions:

- Create transaction
- Upload proof image
- Upload approval document
- Approve lost/damaged
- Reject lost/damaged
- Settle lost/damaged
- Future correction/void workflow

Company Users / Team:

- Invite user
- Cancel invitation
- Accept invitation
- Change role
- Deactivate member
- Reactivate member
- Future remove access
- Future ownership transfer

Company Settings:

- Company profile update
- Report settings update
- Document template update
- Logo upload/update

Lookups:

- Departments
- Job titles
- Tool categories
- Tool units

---

# Current Active Engineering Checkpoint

Status:

**None**

The previous maintainability refactor pass is completed.

Known decisions:

- Leave cohesive large files unchanged when splitting would add fragmentation without real maintainability value.
- Current examples intentionally left cohesive:
  - `current_context_cubit.dart`
  - `add_edit_tool_form.dart`
  - `add_worker_form.dart`
- Prefer feature-by-feature refactors.
- Prefer part-file extensions for large Cubits when mutation flows are genuinely separate.
- No Batch 7 required at this stage.

---

# Recommended Execution Order

## Priority 1 — Must-Have Product Foundation

1. **Phase O — Company Users, Roles & Invitations** ✅
2. **Phase P — Role-Based Access Control** ✅
3. **Phase Q — Secure Member Management & Invitation Backend** ✅
4. **Auth UX Checkpoint — Email-First Authentication Flow** ✅
5. **Phase R — Business Accountability & Audit Trail** 🚧
   - R1 Transactions Backend Alignment ✅
   - R2A Transaction Approval Workflow Alignment ✅
   - R2B Approval Document Upload Accountability ✅
   - R3 General Transaction Update Hardening ✅
   - R4 Workers & Tools Accountability ✅
   - R5 Audit Logs Foundation ✅
   - R5.5 Company Timezone Setting Foundation ⏭️
   - R6 Audit History UI & Record Accountability Display ⏭️
6. **Phase S — Production Environment & Secrets Setup**
7. **Phase T — Subscription / Plan Limits Foundation**
8. **Phase U — Store Release Preparation**

## Priority 2 — Product Expansion

- Extend audit logging to Transactions.
- Extend audit logging to Team / Company Users.
- Extend audit logging to Company Settings.
- Extend audit logging to Lookups.
- Add production-safe support/contact/legal pages.
- Add SaaS plan limits and subscription enforcement.
- Add production onboarding/demo flow.

## Priority 3 — Later Enhancements

- Offline drafts and future sync.
- Advanced reporting.
- Advanced dashboard analytics.
- Custom permission overrides.
- Ownership transfer.
- Remove-access flow.
- Web landing page.
- Desktop installer.
- Advanced storage usage tracking.
- Multi-language support if needed.

---

# Immediate Next Step

Recommended next step:

**Step R5.5 — Company Timezone Setting Foundation**

Why this should come before Audit History UI:

- Audit history is time-sensitive.
- Reports are time-sensitive.
- Custody accountability depends on accurate business time.
- The app is intended to be multi-company and potentially multi-country.
- Hardcoding UAE time would be incorrect for companies outside the UAE.

After Step R5.5:

Proceed to:

**Step R6 — Audit History UI & Record Accountability Display**

---

# Notes for Next Session

When continuing from here:

1. Review the real GitHub repo first.
2. Review `PROJECT_ROADMAP.md`.
3. Do not rely on README if it conflicts with the roadmap.
4. Confirm whether this updated roadmap version has been committed and pushed.
5. Start with Step R5.5 unless a higher-priority bug appears.
6. Do not implement Audit History UI before confirming company timezone handling.
7. Continue step by step.
8. Do not change working UI or backend behavior without approval.
