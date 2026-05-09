# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Last Verified GitHub State

Latest verified pushed commit:

`d63f6e9096e6ef85683916c72fde84559ada3e1b`

Commit message:

`close offline network handling phase`

This roadmap is the single source of truth for the Mina System project.

It is based on the real GitHub repository, not the README.

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
- Audit trail history for important actions
- Future subscriptions, plans, usage limits, and storage limits

Every company must have isolated data using `company_id` and the active `currentCompanyId`.

The product should eventually support:

- Multiple users inside the same company
- Owner/Admin/User/Viewer roles
- Secure invitations
- Company-based subscriptions
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
- Mobile/tablet camera capture for proof/document upload workflows
- File upload fallback from device storage

---

# Core Rules

## Development Rules

- Work step by step.
- Do not make large changes in one step.
- Do not change a working UI unless needed.
- Always review the real GitHub repo before continuing a new step.
- Do not rely only on README because it may be outdated.
- Keep `PROJECT_ROADMAP.md` as the single source of truth.
- Update this roadmap after each completed feature or phase.
- Do not create multiple roadmap files.
- If a file becomes too large, refactor it into smaller focused files without changing working behavior.

After each completed feature:

1. Test manually.
2. Run `dart format lib`.
3. Run `flutter analyze`.
4. Commit.
5. Push.
6. Review repo again.

## Testing Rules

Every major feature should be tested on:

- Windows
- Mobile portrait
- Mobile landscape
- Tablet portrait
- Tablet landscape

## Architecture Rules

Follow this pattern where applicable:

1. Review current repo files.
2. Confirm current database structure if needed.
3. Model
4. Repository / Service
5. Cubit / State
6. UI
7. SQL Grants if needed
8. RLS Policies if needed
9. Manual test
10. `dart format lib`
11. `flutter analyze`
12. Commit / Push
13. Update roadmap

## Supabase Rules

- Every business table must be connected to `company_id`.
- Every company query must be filtered by `currentCompanyId`.
- Never expose or use service role keys in Flutter.
- Admin Auth methods must not be called directly from Flutter.
- User invitations must be handled through secure backend logic or Supabase Edge Functions.
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
- Important business actions should be auditable.
- Important business records should store direct accountability fields where applicable.
- Business records should show who created them and who last updated them.
- Transactions should show who created them, uploaded documents, approved/rejected them, and settled them.
- Audit logs must store the acting user/profile.
- Audit logs must be protected by RLS.
- Audit logs should not be editable or deletable by normal app users.
- Direct accountability fields must not be trusted from arbitrary client input unless protected by RLS/RPC/backend logic.
- Where possible, actor profile should be derived from authenticated user context.

## UI / Theme Rules

- Colors should be centralized inside `AppColors`.
- Do not use direct widget-level colors like `Colors.green` or `Colors.orange` unless they are first added to `AppColors`.
- Reusable user messages should use `AppMessage`.
- Errors inside Bottom Sheets or Dialogs should appear inside the form/dialog when SnackBars would be hidden behind the overlay.
- Success/error/warning/info messages should be clear, professional, and user-friendly.
- Do not show raw technical errors to end users.
- General screen errors should use unified `AppMessage`.
- In-page banners should be used only when they are part of the page design, not for temporary action errors.
- Important details screens should show direct accountability data where applicable.

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
- Offline banner must not cause keyboard overflow.
- DevicePreview must not be required by normal runtime layouts.

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

## Data Accountability Rules

Mina System must track user accountability in two levels:

1. Direct accountability fields on important business records.
2. Full audit trail logs for historical tracking.

Audit logs alone are not enough.

When the user opens any important record, the UI should clearly show who created it, who last updated it, and who performed key workflow actions where applicable.

### Entity-Level Accountability Rule

Every important business table should store direct user/profile tracking fields where applicable.

Common fields:

- `created_by_profile_id`
- `created_by_name_snapshot`
- `created_by_email_snapshot`
- `updated_by_profile_id`
- `updated_by_name_snapshot`
- `updated_by_email_snapshot`
- `created_at`
- `updated_at`

These fields allow the app to show accountability directly inside details screens without requiring the user to open the audit log.

### Transaction Accountability Rule

Transactions require stronger accountability because they are the core custody records.

Each transaction should clearly show:

- Who created the transaction
- When it was created
- Who uploaded the proof image, if applicable
- Who uploaded the signed approval document, if applicable
- Who approved the lost/damaged transaction, if applicable
- Who rejected the lost/damaged transaction, if applicable
- Who settled the transaction, if applicable
- Who last updated the transaction through any controlled workflow, if applicable

Suggested transaction-related fields:

- `created_by_profile_id`
- `created_by_name_snapshot`
- `created_by_email_snapshot`
- `proof_uploaded_by_profile_id`
- `proof_uploaded_by_name_snapshot`
- `proof_uploaded_by_email_snapshot`
- `approval_document_uploaded_by_profile_id`
- `approval_document_uploaded_by_name_snapshot`
- `approval_document_uploaded_by_email_snapshot`
- `approval_decided_by_profile_id`
- `approval_decided_by_name_snapshot`
- `approval_decided_by_email_snapshot`
- `settled_by_profile_id`
- `settled_by_name_snapshot`
- `settled_by_email_snapshot`
- `updated_by_profile_id`
- `updated_by_name_snapshot`
- `updated_by_email_snapshot`

Important:

- Some of these fields may already exist partially.
- Before adding any column, check the real Supabase table columns first.
- Do not duplicate existing fields unnecessarily.
- If a field already exists as profile ID only, consider adding safe display snapshots if needed.

### Direct Display Rule

The UI should show accountability information directly in relevant details views.

Examples:

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
- Last updated by

Tool details should show:

- Created by
- Last updated by

Company Settings should show where applicable:

- Last profile update by
- Last report settings update by
- Last document template update by
- Last logo upload by

Company Users screen should show:

- Invited by
- Invitation accepted by
- Role changed by
- Removed by

### Audit Trail Rule

In addition to direct accountability fields, every important business action must also create an audit log record.

The direct fields answer:

- Who is responsible for the current/latest state?

The audit log answers:

- What exactly happened over time?

Both are required.

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
- Offline/network handling phase is completed and manually tested.
- Friendly network error mapper is implemented.
- Unified `AppMessage` behavior is applied to main screens.
- DevicePreview has a separate entry point.
- Normal runtime layout no longer depends directly on DevicePreview.

## Current Active Phase

**Phase O — Company Users, Roles & Invitations**

Status:

**Next / Not Started**

Reason for priority:

This phase is required before Mina System can become a real company SaaS product.

Camera capture, dashboard improvements, and other enhancements are useful, but multi-user company access, roles, permissions, and accountability are more important for real business usage.

---

# Recommended Execution Order

This order puts core SaaS/product requirements first, and keeps improvements/enhancements for later.

## Priority 1 — Must-Have Product Foundation

1. **Phase O — Company Users, Roles & Invitations**
2. **Phase P — Role-Based Access Control**
3. **Phase Q — Secure Invitation Backend / Edge Function**
4. **Phase R — Business Accountability & Audit Trail**
5. **Phase S — Production Environment & Secrets Setup**
6. **Phase T — Subscription Plans, Usage Limits & Company Access Control**

## Priority 2 — Release Readiness

7. **Phase U — Store / Release Preparation**
8. **Phase V — Production Data Safety & Demo Account**
9. **Phase W — Basic Audit Log Screen**

## Priority 3 — Operational Improvements

10. **Phase X — Mobile/Tablet Camera Capture**
11. **Phase Y — Storage Usage Tracking**
12. **Phase Z — Advanced Reports & PDF Enhancements**
13. **Phase AA — Dashboard Enhancements**

## Priority 4 — Future / Advanced Features

14. **Phase AB — Offline Drafts & Background Sync**
15. **Phase AC — Notifications**
16. **Phase AD — Web Landing Page / Customer Portal**
17. **Phase AE — Desktop Installer Distribution**
18. **Phase AF — Advanced Analytics**

---

# Phase O — Company Users, Roles & Invitations

## Status: Next / Not Started

## Goal

Allow a company owner to add users to the company so the system can be used by more than one person.

This phase should support:

- Owner can invite users by email.
- Invited user can join the company.
- User membership is stored safely.
- Company role is connected to current context.
- App should load current user companies and roles correctly.
- Users should only access companies they belong to.

## Why this phase comes first

Mina System is intended to be a real company system, not a single-user app.

Before adding more operational features, the app needs:

- Company users
- Memberships
- Roles
- Permissions
- Secure invitation flow

## Required investigation first

Before writing code:

- Review current Supabase tables:
  - `profiles`
  - `companies`
  - existing company membership tables if any
  - current RPCs
  - current RLS policies
- Review:
  - `CurrentContextRepo`
  - `CurrentContextCubit`
  - `CurrentContextState`
  - `CompanyModel`
  - `ProfileModel`
  - current role loading
  - current company settings structure
- Confirm whether a company membership table already exists.
- Confirm whether current company role is already stored and where.
- Confirm whether invitation-related tables exist.
- Confirm whether Edge Function is needed immediately or can be staged.

## Suggested database structure

Potential tables:

- `company_members`
  - `id`
  - `company_id`
  - `profile_id`
  - `role`
  - `status`
  - `created_at`
  - `updated_at`
  - `created_by_profile_id`
  - `updated_by_profile_id`

- `company_invitations`
  - `id`
  - `company_id`
  - `email`
  - `role`
  - `status`
  - `invited_by_profile_id`
  - `accepted_by_profile_id`
  - `cancelled_by_profile_id`
  - `expires_at`
  - `created_at`
  - `accepted_at`
  - `cancelled_at`

Suggested roles:

- `owner`
- `admin`
- `warehouse_manager`
- `warehouse_user`
- `viewer`

Suggested invitation statuses:

- `pending`
- `accepted`
- `cancelled`
- `expired`

## Security rules

- Owner can invite users.
- Admin may invite users if allowed by owner.
- Users cannot add themselves to companies.
- Flutter must not call Supabase Admin Auth methods.
- Flutter must not use service role key.
- Invitation acceptance must be protected by:
  - RLS
  - RPC
  - or Edge Function
- User access must be enforced by database RLS, not UI only.

## UI Scope

Start simple:

- Company Settings → Users tab
- Show current company members
- Show pending invitations
- Invite user by email
- Select role
- Cancel pending invitation
- Optional: remove user from company
- Optional: change role

## Current phase steps

### Step O1 — Audit Current Company/User Structure

Review real GitHub repo and real Supabase structure.

Files to review:

- `PROJECT_ROADMAP.md`
- `lib/features/current_context/data/repo/current_context_repo.dart`
- `lib/features/current_context/presentation/cubit/current_context_cubit.dart`
- `lib/features/current_context/presentation/cubit/current_context_state.dart`
- `lib/features/current_context/data/models/company_model.dart`
- `lib/features/current_context/data/models/profile_model.dart`
- `lib/features/company_settings/...`
- `lib/core/routes/...`
- SQL/RLS if stored in repo

Expected output:

- Confirm existing tables.
- Confirm missing tables.
- Confirm current role source.
- Define safe implementation plan.

### Step O2 — Add/Confirm Database Tables

Only after audit.

Potential SQL:

- Create/confirm `company_members`.
- Create/confirm `company_invitations`.
- Add indexes.
- Add constraints.
- Add grants.
- Add RLS policies.

### Step O3 — Models

Add models:

- `CompanyMemberModel`
- `CompanyInvitationModel`
- `InviteCompanyUserRequest`

### Step O4 — Repository

Add repository:

- `CompanyUsersRepo`
  - get members
  - get invitations
  - create invitation
  - cancel invitation
  - update role
  - remove member

### Step O5 — Cubit / State

Add:

- `CompanyUsersCubit`
- `CompanyUsersState`

State should support:

- loading
- submitting
- members
- invitations
- error message
- clear error message

### Step O6 — UI

Add Company Users screen/tab under Company Settings.

### Step O7 — Invitation Acceptance Flow

Add flow after login/current context:

- Check pending invitations by email.
- If invitation exists:
  - show pending invitation screen
  - accept invitation
  - join company
- If no company and no invitation:
  - create company flow

### Step O8 — Manual Test

Test:

- Owner invites user.
- Invited email sees invitation.
- Invited user accepts invitation.
- User gets correct role.
- User sees company data.
- User cannot access other company data.
- Owner can cancel invitation.
- Owner/admin permissions work.

---

# Phase P — Role-Based Access Control

## Status: Future / High Priority

## Goal

Restrict app actions based on role.

## Required after Phase O

Once users and memberships exist, role permissions must be enforced.

## Permission examples

Owner:

- Full access
- Manage company users
- Manage settings
- Manage subscription
- Approve/reject/settle
- Reports
- Workers/tools/lookups/transactions

Admin:

- Manage most operational data
- Manage users except owner
- Reports
- Approvals if allowed

Warehouse Manager:

- Workers/tools/transactions/reports
- Approval workflow if allowed

Warehouse User:

- Create transactions
- View assigned screens
- Limited edit/delete permissions

Viewer:

- Read-only dashboard/reports

## Important rule

UI restrictions are not enough.

Database RLS/RPC rules must enforce permissions.

## Implementation order

1. Define role permission matrix.
2. Add helper functions in Supabase:
   - `private.is_company_member`
   - `private.has_company_role`
   - any needed permission helpers
3. Update RLS policies.
4. Add Flutter permission helpers.
5. Hide/disable UI actions based on role.
6. Test unauthorized access.

---

# Phase Q — Secure Invitation Backend / Edge Function

## Status: Future / High Priority

## Goal

Implement secure invitation flow without exposing service role keys in Flutter.

## Options

Preferred:

- Supabase Edge Function for invitation creation and optional email sending.

Possible staged approach:

- Phase O can create invitation records with RLS/RPC if safe.
- Phase Q adds Edge Function and email sending.

## Required behavior

- Owner/Admin invites email.
- Invitation is stored.
- Optional email is sent.
- User signs up/logs in with invited email.
- App detects pending invitation.
- User accepts invitation.
- Membership is created.
- Invitation becomes accepted.

## Security

- Edge Function uses service role key server-side only.
- Flutter never receives service role key.
- Edge Function validates caller membership and role.
- Edge Function validates target email and company.

---

# Phase R — Business Accountability & Audit Trail

## Status: Future / High Priority

## Goal

Track every important business action in the system so the company can clearly know:

- Who performed the action
- When the action happened
- Which company the action belongs to
- Which entity was affected
- What type of action was performed
- What important data changed
- What the current record accountability is
- What the historical action trail is

This phase is required for real business accountability.

Mina System must not only store the final data.

It must also keep a clear history of important actions performed by users.

## Core Accountability Rule

Every important create/update/delete/approve/reject/settle/upload action must record the acting user/profile in two places where applicable:

1. The affected business record itself.
2. The audit log.

The system should answer questions like:

- Who added this worker?
- Who last updated this worker?
- Who added this tool?
- Who last updated this tool?
- Who created this transaction?
- Who uploaded this proof image?
- Who uploaded this signed approval document?
- Who approved this lost/damaged transaction?
- Who rejected it?
- Who settled it?
- Who changed company settings?
- Who invited this user?
- Who changed this user role?
- Who removed this user from the company?
- What exactly changed over time?

## Important Actions to Track Directly and Audit

Audit logs should be created for:

- Add worker
- Update worker
- Delete worker
- Add tool
- Update tool
- Delete tool
- Add lookup item
- Delete lookup item
- Create transaction
- Upload transaction proof image
- Upload signed approval document
- Approve lost/damaged transaction
- Reject lost/damaged transaction
- Settle lost/damaged transaction
- Update company profile
- Update report settings
- Update document templates
- Upload company logo
- Invite company user
- Cancel invitation
- Accept invitation
- Change user role
- Remove user from company
- Subscription/plan changes later
- Storage-limit related actions later

Direct accountability fields should be added or confirmed for:

- Workers
- Tools
- Lookups where needed
- Transactions
- Approval documents
- Company profile
- Company report settings
- Company document templates
- Company logo uploads
- Company members
- Company invitations

## Suggested Direct Accountability Fields

Common fields:

- `created_by_profile_id`
- `created_by_name_snapshot`
- `created_by_email_snapshot`
- `updated_by_profile_id`
- `updated_by_name_snapshot`
- `updated_by_email_snapshot`
- `created_at`
- `updated_at`

Transaction-specific fields:

- `created_by_profile_id`
- `created_by_name_snapshot`
- `created_by_email_snapshot`
- `proof_uploaded_by_profile_id`
- `proof_uploaded_by_name_snapshot`
- `proof_uploaded_by_email_snapshot`
- `approval_document_uploaded_by_profile_id`
- `approval_document_uploaded_by_name_snapshot`
- `approval_document_uploaded_by_email_snapshot`
- `approval_decided_by_profile_id`
- `approval_decided_by_name_snapshot`
- `approval_decided_by_email_snapshot`
- `settled_by_profile_id`
- `settled_by_name_snapshot`
- `settled_by_email_snapshot`
- `updated_by_profile_id`
- `updated_by_name_snapshot`
- `updated_by_email_snapshot`

## Suggested Audit Log Table

`audit_logs`

Suggested columns:

- `id`
- `company_id`
- `actor_profile_id`
- `actor_email_snapshot`
- `actor_name_snapshot`
- `actor_role_snapshot`
- `action`
- `entity_type`
- `entity_id`
- `entity_code_snapshot`
- `entity_name_snapshot`
- `old_values`
- `new_values`
- `metadata`
- `created_at`

## Suggested Action Examples

Examples for `action`:

- `worker.created`
- `worker.updated`
- `worker.deleted`
- `tool.created`
- `tool.updated`
- `tool.deleted`
- `lookup.created`
- `lookup.deleted`
- `transaction.created`
- `transaction.proof_uploaded`
- `transaction.approval_document_uploaded`
- `transaction.approved`
- `transaction.rejected`
- `transaction.settled`
- `company.profile_updated`
- `company.logo_uploaded`
- `company.report_settings_updated`
- `company.document_template_updated`
- `user.invited`
- `user.invitation_cancelled`
- `user.invitation_accepted`
- `user.role_changed`
- `user.removed`

## Suggested Entity Types

Examples for `entity_type`:

- `worker`
- `tool`
- `lookup`
- `transaction`
- `approval_document`
- `company`
- `company_logo`
- `report_settings`
- `document_template`
- `company_user`
- `company_invitation`
- `subscription`

## Snapshot Rule

Audit logs and direct accountability fields should store useful snapshots because the original data may change later.

Examples:

- If a worker name changes later, old logs should still show the name at the time of the action.
- If a tool name changes later, old logs should still show the tool name/code at the time of the action.
- If a user role changes later, old logs should still show the acting user's role at the time of the action.
- If a user profile name/email changes later, old records should still show who performed the action at that time.

## UI Display Rule

Important details screens should show accountability data.

Examples:

Transaction Details:

- Created by
- Created at
- Proof uploaded by
- Signed document uploaded by
- Approval decided by
- Settlement completed by
- Last updated by

Worker Details:

- Created by
- Last updated by

Tool Details:

- Created by
- Last updated by

Company Settings:

- Last updated by
- Logo uploaded by
- Report settings updated by
- Document templates updated by

Company Users:

- Invited by
- Accepted by
- Role changed by
- Removed by

## Security Rules

- Users should not be able to edit audit logs.
- Users should not be able to delete audit logs.
- Audit logs should be insert-only from trusted application flows, RPCs, or backend logic.
- Audit logs must be filtered by `company_id`.
- Company users can only read audit logs for companies they belong to.
- Owner/Admin can view full audit logs.
- Lower roles may have limited or no audit log access.
- RLS must protect audit logs at database level.
- Direct accountability fields must not be trusted from arbitrary client input unless validated by RLS/RPC/backend logic.
- Where possible, actor profile should be derived from authenticated user context.

## Implementation Notes

This phase should start after:

1. Company users and invitations are implemented.
2. Role-based access control is defined.
3. Current user role is reliably loaded from current context.

Recommended implementation approach:

1. Audit current existing columns first.
2. Identify which tables already have `created_by_profile_id` or similar fields.
3. Add missing direct accountability fields.
4. Create or confirm `audit_logs` table.
5. Add SQL grants.
6. Add RLS policies.
7. Add `AuditLogModel`.
8. Add `AuditLogService` or `AuditLogRepo`.
9. Add helper method like:
   - `recordAuditLog(...)`
10. Call audit logging after successful business actions.
11. Update details screens to show direct accountability fields.
12. Add Audit Log screen later for Owner/Admin.

## Priority Note

This phase should happen before serious production usage.

It is not just a UI enhancement.

It is a business accountability feature.

---

# Phase S — Production Environment & Secrets Setup

## Status: Future / High Priority

## Goal

Separate development/testing from production.

## Required

- Production Supabase project.
- Development Supabase project.
- Environment configuration.
- No hardcoded production secrets in source code.
- Separate app configs for:
  - development
  - staging if needed
  - production
- Safe handling for:
  - Supabase URL
  - anon key
  - Edge Function URLs
  - app identifiers
- Prepare release build settings.

## Flutter setup options

- `--dart-define`
- environment config class
- separate launch configs
- separate build commands

## Why this is high priority

Before store release or real customer usage, the app must not rely on test database or hardcoded values.

---

# Phase T — Subscription Plans, Usage Limits & Company Access Control

## Status: Future / High Priority

## Goal

Make Mina System commercially ready.

## Plan model

The same app should support:

- Free plan
- Trial plan
- Paid company plans

## Suggested limits

Free plan could limit:

- number of workers
- number of tools
- number of users
- monthly transactions
- storage usage
- reports
- approval workflow access if needed

## Required tables

Potential:

- `plans`
- `company_subscriptions`
- `company_usage_counters`

## Required enforcement

- UI can show limits.
- Database/RPC must enforce limits.
- Plan checks should not be UI-only.

## Required UI

- Company Settings → Subscription tab
- Current plan
- Plan status
- Usage summary
- Message:
  - `Contact your company admin to manage subscription.`
- Upgrade/contact flow outside mobile payment if needed.

## Important mobile store rule

Do not add direct payment buttons inside mobile apps until App Store / Google Play billing rules are reviewed.

---

# Phase U — Store / Release Preparation

## Status: Future / High Priority

## Goal

Prepare the app for real distribution.

## Required before release

- Production Supabase project.
- Environment separation.
- Privacy Policy.
- Terms of Service.
- Support email/contact.
- Demo/review account if required by stores.
- App icons.
- App name finalization.
- Android package name review.
- iOS bundle ID review.
- App permissions review.
- Screenshots.
- Store descriptions.
- Support website or landing page.
- Error handling audit.
- Release build testing.

## Platforms

- Google Play
- App Store
- Desktop installer later

---

# Phase V — Production Data Safety & Demo Account

## Status: Future / High Priority

## Goal

Prepare safe production/demo usage.

## Required

- Seed demo company.
- Demo users by role.
- Demo data:
  - workers
  - tools
  - transactions
  - reports
  - approvals
- Safe reset/cleanup flow for demo data if needed.
- Production backup considerations.
- Data deletion/export policy.

---

# Phase W — Basic Audit Log Screen

## Status: Future / High Priority

## Goal

Show audit log history to Owner/Admin after the audit trail backend exists.

## Scope

- Audit Log screen.
- Filter by action.
- Filter by entity type.
- Filter by user.
- Filter by date.
- View old/new values where useful.
- Read-only access.
- Owner/Admin only by default.

---

# Phase X — Mobile/Tablet Camera Capture

## Status: Future / Medium Priority

## Goal

Allow mobile/tablet users to capture photos directly.

## Use cases

- Transaction proof image.
- Signed approval document image.

## Requirements

- Keep file upload from device storage as fallback.
- Add camera capture option.
- Compress captured images before upload.
- Block capture/upload while offline if upload is required immediately.
- Do not store local paths in Supabase tables.
- Store cloud paths only.
- Add Android camera permission.
- Add iOS camera permission when preparing iOS.

## Suggested UI

When choosing proof/document:

- Take Photo
- Choose File
- Cancel

## Important

This is useful, but it comes after Company Users/Roles/Accountability because multi-user company access and user accountability are more critical for SaaS readiness.

---

# Phase Y — Storage Usage Tracking

## Status: Future / Medium Priority

## Goal

Track storage usage per company for plan limits.

## Requirements

- Track uploaded file size.
- Track company storage usage.
- Apply plan storage limit.
- Show storage usage in Company Settings.
- Prevent upload when limit is exceeded.
- Add friendly upgrade/contact message.

## Relevant uploads

- Transaction proof images
- Approval documents
- Company logos
- Future document templates/assets

---

# Phase Z — Advanced Reports & PDF Enhancements

## Status: Future / Medium Priority

## Goals

Improve reports after product foundation is stable.

## Improvements

- Worker Acknowledgment Report.
- Optional settlement/deduction report.
- PDF Approval Status Summary section.
- Better PDF table layouts for long reports.
- Export/download history.
- Apply `timeFormat` to PDF timestamps.
- Apply `defaultTimezone` to report generation dates/times.
- Improve online/offline logo handling if needed.
- Consider server-side PDF optimization later if large PDFs become an issue.

---

# Phase AA — Dashboard Enhancements

## Status: Future / Medium Priority

## Goals

Improve dashboard after role/subscription foundation.

## Improvements

- Dashboard loading skeletons/shimmer.
- Better empty states.
- Trends/percentages.
- Role-based dashboard cards.
- Dashboard date filters.
- Pending invitations card.
- Pending approvals card.
- Pending settlements card.
- Recent critical activities.
- Subscription/plan card for owners/admins.
- Storage usage card.

---

# Phase AB — Offline Drafts & Background Sync

## Status: Future / Advanced

## Goal

Allow offline draft creation and later sync.

## Important

This is advanced and must not be started until:

- users/roles are stable
- RLS is stable
- subscription limits are stable
- online mutation rules are stable
- conflict handling is designed

## Possible scope

- Offline transaction drafts.
- Draft proof images stored locally.
- Sync when online.
- Conflict detection.
- Failed sync recovery.
- Clear user status.

---

# Phase AC — Notifications

## Status: Future / Advanced

## Goals

Notify users about important events.

## Possible notifications

- Pending approval.
- Pending settlement.
- Invitation received.
- Transaction created.
- Storage limit reached.
- Subscription expiring.

## Channels

- In-app notifications.
- Push notifications later.
- Email notifications later.

---

# Phase AD — Web Landing Page / Customer Portal

## Status: Future / Business

## Goals

Support SaaS/business usage outside the app.

## Possible features

- Landing page.
- Pricing page.
- Contact form.
- Customer portal.
- Subscription management.
- Download desktop installer.
- Support links.
- Privacy Policy.
- Terms of Service.

---

# Phase AE — Desktop Installer Distribution

## Status: Future / Business

## Goals

Make desktop app distribution easier.

## Possible tasks

- Windows installer.
- Auto-update strategy.
- Download page.
- Code signing if needed.
- Versioning.
- Release notes.

---

# Phase AF — Advanced Analytics

## Status: Future / Advanced

## Possible features

- Worker custody trends.
- Lost/damaged trends.
- Tool usage frequency.
- Department-level usage.
- Monthly transaction analytics.
- Cost/deduction analytics.
- Company-level KPI dashboard.

---

# Completed Feature Sections

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

Future priority:

- Pending invitation screen.
- Select Company screen for multiple companies.
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

Future priority:

- Add company onboarding checklist after creation.
- Prevent accidental company creation as much as possible.
- Assign Free plan automatically after company creation.
- Create default subscription record after company creation.

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

Future priority:

- Add Company Users tab.
- Add Subscription tab.
- Show current plan name.
- Show plan status.
- Show usage summary.
- Add direct accountability fields:
  - profile updated by
  - report settings updated by
  - document template updated by
  - logo uploaded by
- Add storage usage summary after storage tracking is implemented.

Future enhancement:

- Preserve transparency when possible for PNG/WebP logos.
- Add optional visual preview/crop flow before uploading logo.
- Fine-tune PDF logo box size if needed.

---

# Phase B — Lookups Supabase Integration

## Status: Done / Offline-Aware

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
- Main screen error messages unified through `AppMessage`.
- `flutter analyze` has no errors after implementation.

Future priority:

- Add role-based permissions.
- Add plan-based lookup limits if needed.
- Add accountability/audit support for add/delete actions.

Future enhancement:

- Add import defaults from industry templates.
- Optional edit/rename lookup flow if needed.

---

# Phase C — Workers Supabase Integration

## Status: Done / Offline-Aware

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
- Main screen error messages unified through `AppMessage`.
- `flutter analyze` has no errors after implementation.

Database rules confirmed:

- `workers.company_id` references `companies(id)`.
- `workers.department_id` references `departments`.
- `workers.job_title_id` is constrained to match the selected department.
- `hr_code` is unique inside the same company.
- `worker_code` is unique inside the same company.
- Department and Job Title deletion is protected by foreign key rules when workers depend on them.

Future priority:

- Add role-based permissions.
- Enforce plan limit before adding a worker.
- Add database/RPC-level worker limit enforcement.
- Add direct accountability fields:
  - created by
  - last updated by
- Show accountability in Worker details.
- Add audit logs for create/update/delete worker actions.

Future enhancement:

- Add stronger open-custody protection before worker deletion if needed.
- Advanced worker profile fields if needed.

---

# Phase D — Tools Supabase Integration

## Status: Done / Offline-Aware

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
- Main screen error messages unified through `AppMessage`.
- `flutter analyze` has no errors after implementation.

Database rules confirmed:

- `tools.company_id` references `companies(id)`.
- `tools.unit_id` is constrained to match a valid `tool_units` record for the same company.
- `tools.category_id` is constrained to match a valid `tool_categories` record for the same company.
- `tool_code` is unique inside the same company.
- `tool_name` has a normalized unique index inside the same company.
- Tool Unit and Tool Category deletion is protected by foreign key constraints when tools depend on them.

Future priority:

- Add role-based permissions.
- Enforce plan limit before adding a tool.
- Add database/RPC-level tool limit enforcement.
- Add direct accountability fields:
  - created by
  - last updated by
- Show accountability in Tool details.
- Add audit logs for create/update/delete tool actions.

Future enhancement:

- Add stronger database-level open-custody delete protection if needed.
- Tool status history if needed.

---

# Phase E — Transactions / Custody Core Supabase Integration

## Status: Done / Offline-Aware

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
- Main screen error messages unified through `AppMessage`.
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

Future priority:

- Add role-based permissions.
- Enforce monthly transaction limits by plan.
- Add database/RPC-level transaction limit enforcement.
- Add direct transaction accountability fields:
  - created by
  - proof uploaded by
  - signed document uploaded by
  - approved/rejected by
  - settled by
  - last updated by
- Show accountability in Transaction details.
- Add audit logs for:
  - transaction creation
  - proof upload
  - signed document upload
  - approval/rejection
  - settlement
- Add controlled correction/void workflow if needed for production.

Future enhancement:

- Add camera capture support on mobile/tablet for transaction proof images.
- Add offline transaction drafts and sync later.

---

# Phase F — Dashboard Supabase Data

## Status: Done

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

Future priority:

- Add role-based dashboard behavior.
- Add subscription/plan card for owners/admins.
- Add storage usage card after storage tracking.
- Add audit/accountability summaries if useful.

Future enhancement:

- Add loading skeletons/shimmer.
- Add better empty states.
- Add trends/percentages.
- Add dashboard date filters.
- Add pending invitations/approvals/settlements cards.

---

# Phase G — Reports / PDF

## Status: Core Reports Implemented

Reports available / planned:

- Worker Custody Report
- Tool History Report
- Transactions Report
- Lost & Damaged Report
- Tool Summary Report
- Lost/Damaged Approval Report
- Worker Acknowledgment Report
- Future signed settlement report if needed

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

Future priority:

- Add role-based report access.
- Add Worker Acknowledgment Report.
- Add audit/export history if needed for production.
- Add accountability fields into relevant reports where needed.

Future enhancement:

- Add PDF Approval Status Summary section.
- Add better PDF table layouts for long reports.
- Add optional settlement/deduction report.
- Apply `timeFormat`.
- Apply `defaultTimezone`.
- Consider server-side PDF optimization later.

---

# Phase H — Lost/Damaged Approval & Settlement Workflow

## Status: Core Workflow Implemented / Offline-Aware

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

Future priority:

- Add role-based permissions for approve/reject/settle.
- Add direct accountability fields for approval/rejection/settlement actions.
- Add audit trail entries for approval/settlement actions.

Future enhancement:

- Add optional signed settlement/deduction report.
- Add optional notification flow for pending approvals and settlements.
- Add mobile/tablet camera capture for signed approval document photos.

---

# Phase I — Android Signed Document Opening

## Status: Done

Implemented:

- Added Android handling for opening signed approval document URLs.
- Confirmed View Signed Document works on Android Emulator when online.
- Signed document viewing is now blocked offline with a clear user message.

Future enhancement:

- Add better in-app document preview if needed.
- Add cached document preview later if secure offline cache is implemented.

---

# Phase J — Large File Refactor Checkpoint

## Status: Mostly Done

Implemented:

- Several large feature files were split into focused widgets/services.
- Pending Approvals UI was refactored into smaller widgets.
- PDF generation was split into smaller files.
- Reports services were organized under PDF-specific service folders.
- Transaction Cubit was split into part files for load/search, CRUD, approval workflow, and calculations.
- UI behavior was preserved during refactors.

Future ongoing rule:

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

Future ongoing rule:

- Re-test platform builds after future Flutter upgrades.
- Watch for package compatibility changes, especially:
  - Supabase
  - file_picker
  - printing/pdf
  - image
  - url_launcher
  - connectivity_plus
  - device_preview

---

# Phase L — Responsive & Orientation Hardening

## Status: Done

Goal:

Harden the app layout across mobile and tablet orientations and prevent UI overflows when rotating between portrait and landscape.

Completed:

- Responsive and orientation hardening audit completed.
- Mobile landscape behavior improved.
- Tablet portrait/landscape behavior reviewed.
- DevicePreview separated from normal runtime layout.
- `ResponsiveLayout` no longer depends directly on DevicePreview.
- Offline banner no longer causes keyboard overflow.
- Search/input fields tested with keyboard in tablet portrait and landscape.

Future ongoing rule:

- Every new form must be tested in portrait and landscape.
- Every new form must remain scrollable when keyboard is open.
- Do not introduce fixed-height layouts for long forms.

---

# Phase M — Storage & Image Optimization

## Status: Done

Implemented:

- Cross-platform image compression foundation.
- Transaction proof image compression before upload.
- Approval document image compression before upload when selected file is an image.
- PDF approval documents uploaded without image compression.
- Company logo resize/compression before upload.
- Storage paths saved under company folders.
- Database stores cloud storage paths only.
- Local file paths are not saved in Supabase tables.

Future priority:

- Storage usage tracking per company.
- Enforce storage limits by plan.

Future enhancement:

- Optional preview/crop flow.
- Preserve PNG/WebP transparency where possible.
- Camera capture integration.

---

# Phase N — Offline & Network Handling

## Status: Done

Completed:

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
- Friendly Network Error Mapper first pass added.
- Supabase/Auth/Postgrest/Storage/Socket/Timeout technical errors are mapped to user-friendly messages.
- Friendly error mapper applied to:
  - Auth
  - Current Context
  - Dashboard
  - Workers
  - Tools
  - Lookups
  - Company Settings
  - Transactions load/save/approval workflow
  - Cloud proof image preview
  - Cloud proof image thumbnails
  - Signed document opening
  - Company logo picker
  - Network status Cubit
- Friendly error messages are unified using `AppMessage` for main screens.
- Tools, Workers, Lookups, and Transactions no longer show in-page error banners for general Cubit errors.
- Offline banner is hidden automatically while the keyboard is open to prevent tablet/landscape overflow.
- DevicePreview was separated into its own entry point:
  - `lib/main.dart`
  - `lib/main_device_preview.dart`
- `ResponsiveLayout` no longer depends directly on `DevicePreview`.
- Manual testing completed on:
  - Windows
  - Tablet landscape
  - Tablet portrait
- Offline behavior confirmed for:
  - Workers
  - Tools
  - Lookups
  - Transactions
  - Reports from already-loaded data
  - Cloud file viewing restrictions
  - Friendly network error messages

Future enhancement:

- Offline drafts and sync later.
- Offline cached file previews later if secure and needed.

---

# Low Priority / Deferred Backlog

These items are useful but should not be started before the high-priority SaaS/product foundation unless there is a clear reason.

## UI Enhancements

- Better loading skeletons.
- More polished empty states.
- Better animation.
- Optional table column customization.
- Optional theme customization.
- Optional dark mode.

## Operational Enhancements

- Import workers/tools from Excel/CSV.
- Export reports history.
- Bulk actions.
- Tool maintenance history.
- Worker advanced profiles.
- More advanced filters.

## Advanced Approval Enhancements

- Multi-level approval.
- Approval notifications.
- Digital signature support.
- In-app PDF signing.
- Settlement/deduction report.

## Advanced SaaS Enhancements

- Customer portal.
- Online billing integration.
- In-app usage analytics.
- Admin dashboard for all companies.
- Multi-tenant admin console.

---

# Immediate Next Step

Start **Phase O — Company Users, Roles & Invitations**.

First step:

**Step O1 — Audit Current Company/User Structure**

Before writing code:

- Review the real GitHub repo.
- Review current Supabase company/profile/membership structure.
- Confirm existing tables.
- Confirm missing tables.
- Confirm current role source.
- Decide whether invitation creation can start with RLS/RPC or must use Edge Function immediately.

After updating this roadmap:

1. Run `git status`.
2. Commit:
   - `update roadmap priorities and accountability plan`
3. Push.
4. Review the real GitHub repo before starting Step O1.