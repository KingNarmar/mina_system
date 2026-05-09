# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Last Verified GitHub State

Latest verified pushed commit:

`faeda85b4c2a74c16a96ca67042c49e72aff6a04`

Commit message:

`finalize company invitation validation`

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
- Owner/Admin/Warehouse Manager/Warehouse User/Viewer roles
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
- When changing existing files during guided development, provide complete file replacements when requested.

After each completed feature:

1. Test manually.
2. Run `dart format lib`.
3. Run `flutter analyze`.
4. Commit.
5. Push.
6. Review repo again.
7. Update roadmap when a phase or major checkpoint is completed.

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
- User invitations must be handled through secure backend logic, RPC, or Supabase Edge Functions.
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
- Company Users foundation is implemented.
- Company invitation table, grants, RLS policies, and acceptance/cancellation RPCs are implemented.
- Company Settings includes a Company Users section.
- Owner/Admin can invite users by email.
- Pending invitations can be listed and cancelled.
- Invited users can see company invitation details before joining.
- Invited users can accept invitations and join the company.
- Accepted users appear in Company Users with their assigned role.
- Duplicate pending invitations are blocked.
- Duplicate active-member invitations are blocked at database level.
- Company user business errors are displayed with clear user-facing messages.

## Current Active Phase

**Phase P — Role-Based Access Control**

Status:

**Next / Not Started**

Reason for priority:

Company users and invitations are now implemented. The next required step is to restrict app actions based on the current user's role.

Role-based access must be enforced by both UI behavior and database RLS/RPC rules.

---

# Recommended Execution Order

This order puts core SaaS/product requirements first, and keeps improvements/enhancements for later.

## Priority 1 — Must-Have Product Foundation

1. **Phase O — Company Users, Roles & Invitations** ✅
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

## Status: Done

## Goal

Allow a company owner to add users to the company so the system can be used by more than one person.

This phase supports:

- Owner/Admin can invite users by email.
- Invited user can see pending invitation details.
- Invited user can join the company through a secure RPC.
- User membership is stored safely in `company_members`.
- Company role is connected to current context.
- App loads current user companies and roles correctly.
- Users can access only companies they belong to.
- Duplicate pending invitations are blocked.
- Invitations to already active company members are blocked.
- Owner/Admin can cancel pending invitations.

## Completed implementation

### Step O1 — Audit Current Company/User Structure

Completed.

Confirmed current Supabase structure:

- `profiles` exists.
- `companies` exists.
- `company_members` exists.
- `company_members.role` uses `company_member_role`.
- `company_members.status` uses `member_status`.
- `company_members` already stores current company role source.
- Current context already loads companies and role from `company_members`.
- `company_invitations` did not exist before this phase.

Confirmed current app structure:

- `CurrentContextRepo` loads current profile and company memberships.
- `CompanyModel` stores company role.
- `CurrentContextGate` controls company creation / app entry flow.
- Company Settings existed but did not include user management before this phase.

### Step O2 — Database Tables, Grants, RLS, RPCs

Completed.

Implemented / confirmed:

- Added missing role:
  - `warehouse_manager`
- Created invitation status enum:
  - `company_invitation_status`
- Created table:
  - `company_invitations`
- Added fields:
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
  - `updated_at`
- Added indexes:
  - company lookup index
  - lower-email lookup index
  - status index
  - unique pending invitation index per company/email
- Added safe grants:
  - authenticated can `select`
  - authenticated can `insert`
  - direct `update` removed
- Added RLS policies:
  - Owner/Admin can read company invitations.
  - Invited users can read their pending invitations.
  - Owner/Admin can create pending invitations.
  - Invited users can read invited company basic data.
  - Invited users can read inviter profile.
  - Company members can read profiles of active members in the same company.
- Added secure RPCs:
  - `accept_company_invitation(uuid)`
  - `cancel_company_invitation(uuid)`
- Added trigger/function:
  - Prevent inviting an email that already belongs to an active company member.

Important security behavior:

- Flutter does not use service role key.
- Flutter does not call Supabase Admin Auth methods.
- Accepting invitation is handled by RPC.
- Cancelling invitation is handled by RPC.
- Users cannot directly insert themselves into arbitrary companies.
- Users cannot directly update invitation status from Flutter.

### Step O3 — Models

Completed.

Added:

- `CompanyMemberModel`
- `CompanyInvitationModel`
- `InviteCompanyUserRequest`

Implemented model support for:

- Company member profile details.
- Invitation company details.
- Inviter profile details.
- Invitation status/date fields.
- Role display data.

### Step O4 — Repository

Completed.

Added:

- `CompanyUsersRepo`

Implemented:

- `getCompanyMembers`
- `getCompanyInvitations`
- `getCurrentUserPendingInvitations`
- `inviteCompanyUser`
- `acceptCompanyInvitation`
- `cancelCompanyInvitation`

Important fixes:

- `company_members` profile join uses explicit FK:
  - `member_profile:profiles!company_members_profile_id_fkey`
- `company_invitations` joins company and inviter profile details using explicit embedded selects.

### Step O5 — Cubit / State

Completed.

Added:

- `CompanyUsersCubit`
- `CompanyUsersState`

State supports:

- members
- invitations
- loading
- submitting
- error message
- clear error message
- pending invitation filtering

Cubit supports:

- Load company users.
- Load current user pending invitations.
- Invite company user.
- Accept invitation.
- Cancel invitation.
- Online check before mutations.

### Step O6 — Company Users UI

Completed.

Added Company Users section under Company Settings.

The UI supports:

- Display company members.
- Display member name/email/role/status.
- Invite users by email.
- Select invite role.
- Display pending invitations.
- Cancel pending invitations.
- Show clear messages on success/error.
- Responsive layout for compact/tablet screens.

Completed UI fixes:

- Fixed `Expanded` inside compact `Column` layout issue.
- Fixed company member profile display.
- Fixed unknown member caused by profile RLS.
- Added visible error text for failed loading.

### Step O7 — Invitation Acceptance Flow

Completed.

Added:

- `PendingCompanyInvitationsScreen`
- No-company invitation gate inside `CurrentContextGate`

Flow now works as follows:

- User logs in.
- Current context loads.
- If user has company membership, app opens normally.
- If user has no company, app checks pending invitations.
- If pending invitation exists, app shows invitation details.
- If no pending invitation exists, app shows Create Company screen.
- User can accept invitation.
- RPC creates/activates company membership.
- Invitation becomes accepted.
- Current context reloads.
- User enters the company workspace.

Invitation screen displays:

- Company name.
- Invited email.
- Invited by name.
- Invited by email.
- Assigned role.
- Expiration date.
- Accept Invitation button.

Completed flow fixes:

- Fixed blinking/loading loop by keeping invitation loading inside the gate only.
- Added RLS policies so invited users can read company/inviter details before accepting.
- Added profile RLS so company members can see member names/emails.

### Step O8 — Manual Test

Completed.

Tested and confirmed:

- Owner can invite a user.
- Pending invitation appears in Company Users.
- Owner can cancel pending invitation.
- Cancelled invitations are removed from pending UI.
- Invited email can see pending invitation.
- Invitation details show company and inviter information.
- Invited user can accept invitation.
- Accepted user joins company.
- Accepted user gets correct role.
- Accepted user appears in Company Users.
- Owner can see accepted user's name/email.
- Duplicate pending invitation is blocked by unique index.
- Inviting an already active company member is blocked at database level.
- Business-rule database errors are shown clearly to the user.

## Remaining items moved to next phases

The following items are intentionally not completed inside Phase O and should be handled in future phases:

- Full role permission matrix.
- Hide/disable UI actions by role across all screens.
- Database-level role restrictions for every business action.
- Change member role.
- Deactivate/reactivate member.
- Remove member access from company.
- Prevent last owner deactivation/removal.
- Audit logs for invite/cancel/accept/role-change/deactivate/reactivate/remove actions.
- Email delivery for invitations.
- Supabase Edge Function for production invitation email sending.

These belong to:

- Phase P — Role-Based Access Control
- Phase Q — Secure Invitation Backend / Edge Function
- Phase R — Business Accountability & Audit Trail

---

# Phase P — Role-Based Access Control

## Status: Next / Not Started

## Goal

Restrict app actions based on the current user's company role.

Phase O made multi-user company access possible. Phase P must make that access safe.

The app must not rely on UI-only restrictions. Role permissions must be enforced through:

- Flutter UI helpers
- Supabase RLS
- RPCs where needed
- Business-rule validation

## Required after Phase O

Once users and memberships exist, role permissions must be enforced.

## Permission examples

Owner:

- Full access.
- Manage company users.
- Invite users.
- Cancel invitations.
- Change user roles.
- Deactivate/reactivate members.
- Remove member access where allowed.
- Manage company settings.
- Manage subscription later.
- Approve/reject/settle.
- Reports.
- Workers/tools/lookups/transactions.

Admin:

- Manage most operational data.
- Invite users if allowed.
- Manage users except owner.
- Reports.
- Approvals if allowed.
- Cannot deactivate/remove the last owner.
- Cannot promote self to owner.

Warehouse Manager:

- Workers/tools/transactions/reports.
- Approval workflow if allowed.
- Limited company settings access.
- No subscription management.
- No owner/admin role changes unless explicitly allowed.

Warehouse User:

- Create transactions.
- View assigned screens.
- Limited edit/delete permissions.
- No company user management.
- No company settings management.

Viewer:

- Read-only dashboard/reports.
- No mutations.
- No user management.
- No settings changes.

## Important rule

UI restrictions are not enough.

Database RLS/RPC rules must enforce permissions.

## Implementation order

### Step P1 — Audit Current Role Usage

Review:

- `CurrentContextRepo`
- `CurrentContextCubit`
- `CompanyModel`
- `current_context_extensions.dart`
- all screens/actions that create/update/delete data
- existing RLS policies
- current `private.has_company_role`
- current `private.is_company_member`

Expected output:

- Confirm all places where current role is available.
- Confirm all actions that need role checks.
- Define role permission matrix.

### Step P2 — Add Flutter Permission Helpers

Add a central permission helper such as:

- `AppPermissions`
- `CompanyRolePermissions`
- `CurrentUserPermissions`

Should support:

- `canManageCompanyUsers`
- `canInviteUsers`
- `canCancelInvitations`
- `canChangeMemberRole`
- `canDeactivateMember`
- `canReactivateMember`
- `canManageCompanySettings`
- `canManageLookups`
- `canManageWorkers`
- `canManageTools`
- `canCreateTransactions`
- `canViewReports`
- `canApproveLostDamaged`
- `canSettleLostDamaged`

### Step P3 — Apply UI Restrictions

Update UI to:

- Hide or disable actions that current role cannot use.
- Show read-only states where appropriate.
- Show clear messages where actions are restricted.
- Keep owner/admin management actions visible only to allowed roles.

### Step P4 — Add Secure Member Management RPCs

Add RPCs for:

- Change member role.
- Deactivate member.
- Reactivate member.
- Remove/deactivate company access.

Rules:

- Owner can manage most roles.
- Admin may manage lower roles only if allowed.
- No user can deactivate/remove the last owner.
- No user can change the last owner away from owner.
- Users should not be able to promote themselves to owner.
- Users should not be able to deactivate themselves if that would leave company without owner.
- Member status changes should be soft changes, not hard deletes.

### Step P5 — Update Company Users UI

Add controls for Owner/Admin:

- Change role.
- Deactivate member.
- Reactivate member.
- Show active/inactive members clearly.
- Keep accepted membership history visible.
- Do not hard delete members by default.

### Step P6 — Strengthen RLS Policies

Update RLS policies for:

- Workers
- Tools
- Lookups
- Transactions
- Reports-related reads
- Company settings
- Company users
- Company invitations

Rules:

- RLS must match the permission matrix.
- Lower roles must not mutate restricted tables.
- Viewer must be read-only.
- Warehouse User must not manage settings/users.
- Owner/Admin should retain full or near-full control.

### Step P7 — Manual Test

Test by role:

- Owner
- Admin
- Warehouse Manager
- Warehouse User
- Viewer

Test:

- Which screens are visible.
- Which buttons are visible.
- Which mutations succeed.
- Which unauthorized mutations fail at database/RPC level.
- Role change behavior.
- Deactivate/reactivate behavior.
- Last owner protection.

---

# Phase Q — Secure Invitation Backend / Edge Function

## Status: Future / High Priority

## Goal

Implement production-grade invitation handling without exposing service role keys in Flutter.

Phase O supports invitation records and acceptance through safe client-accessible logic. Phase Q should add the production backend layer for email delivery and stronger server-side validation.

## Options

Preferred:

- Supabase Edge Function for invitation creation and optional email sending.

Possible staged approach:

- Phase O creates invitation records with RLS/RPC safely.
- Phase Q adds Edge Function and email sending.

## Required behavior

- Owner/Admin invites email.
- Invitation is stored.
- Email is sent to invited user.
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
- Edge Function rate-limits or protects repeated invitation attempts where needed.

## Implementation order

1. Decide email provider.
2. Create Edge Function.
3. Validate caller role inside function.
4. Create/send invitation.
5. Update Flutter repo to call function instead of direct insert if needed.
6. Test invite email delivery.
7. Keep RPC-based acceptance.

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
- Who cancelled this invitation?
- Who accepted this invitation?
- Who changed this user role?
- Who deactivated/reactivated this user?
- Who removed this user from the company?
- What exactly changed over time?

## Important Actions to Track Directly and Audit

Audit logs should be created for:

- Add worker
- Update worker
- Delete/deactivate worker if supported
- Add tool
- Update tool
- Delete/deactivate tool if supported
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
- Deactivate user
- Reactivate user
- Remove user access
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
- `user.deactivated`
- `user.reactivated`
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
- separate build commands.

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

- Company Settings → Subscription tab.
- Current plan.
- Plan status.
- Usage summary.
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

- Google Play.
- App Store.
- Desktop installer later.

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
- Safe separation between demo and customer data.

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

Allow mobile/tablet users to capture photos directly from camera for proof/document upload workflows.

## Scope

- Transaction proof image camera capture.
- Approval document camera capture.
- File picker fallback remains available.
- Compression still applies after camera capture.
- Works across Android/iOS tablets and phones.

## Rules

- Camera capture should not replace file upload.
- Storage paths must remain cloud paths.
- Compression rules must remain active.
- Offline upload must still be blocked until offline sync exists.

---

# Phase Y — Storage Usage Tracking

## Status: Future / Medium Priority

## Goal

Track storage usage per company for plan limits and safe SaaS operation.

## Scope

- Track uploaded files.
- Track file size.
- Track storage category:
  - transaction proof
  - approval document
  - logo
  - other future document
- Show usage summary in Company Settings / Subscription area.
- Enforce storage limits later with subscription plans.

## Possible tables

- `company_storage_files`
- `company_storage_usage`

## Notes

This should come after production plan/subscription design or be prepared as a foundation for it.

---

# Phase Z — Advanced Reports & PDF Enhancements

## Status: Future / Medium Priority

## Goal

Improve reports and PDF output beyond the current core reports.

## Possible improvements

- More report templates.
- Better filtering.
- More document-control options.
- Better PDF layout for long tables.
- More signature sections.
- Export/share improvements.
- Report preview improvements.
- Role-based report access.

---

# Phase AA — Dashboard Enhancements

## Status: Future / Medium Priority

## Goal

Improve dashboard usefulness for real operations.

## Possible improvements

- More KPIs.
- Open custody balances.
- Pending lost/damaged approvals.
- Pending settlements.
- Recently issued tools.
- Recently returned tools.
- Workers with high outstanding custody.
- Tools frequently lost/damaged.
- Role-based dashboard widgets.

---

# Phase AB — Offline Drafts & Background Sync

## Status: Future / Advanced

## Goal

Allow limited offline drafting without bypassing RLS or business rules.

## Scope

- Offline drafts for selected forms only.
- Background sync after reconnect.
- Clear sync status.
- Conflict handling.
- No offline approval/settlement bypass.
- No storage upload while offline unless queued safely.

## Important rule

Offline mode must not bypass database security, subscription limits, or business workflows.

---

# Phase AC — Notifications

## Status: Future / Advanced

## Goal

Notify users about important events.

## Possible notifications

- Invitation received.
- Lost/Damaged approval pending.
- Settlement pending.
- Transaction created.
- Document uploaded.
- Role changed.
- User deactivated/reactivated.
- Subscription/storage warning.

## Possible channels

- In-app notifications.
- Push notifications.
- Email notifications later.

---

# Phase AD — Web Landing Page / Customer Portal

## Status: Future / Advanced

## Goal

Provide a public web presence and customer-facing portal for Mina System.

## Scope

- Landing page.
- Product overview.
- Pricing information.
- Contact/demo request.
- Terms and Privacy links.
- Customer portal for subscription/contact if needed.
- Support documentation.

---

# Phase AE — Desktop Installer Distribution

## Status: Future / Advanced

## Goal

Prepare desktop distribution for Windows users.

## Scope

- Windows installer.
- Versioning.
- Update strategy.
- Desktop app signing if needed.
- Installer download page.
- Production environment configuration.

---

# Phase AF — Advanced Analytics

## Status: Future / Advanced

## Goal

Add advanced analytics for companies after core SaaS foundation is stable.

## Possible analytics

- Tool usage trends.
- Worker custody behavior.
- Lost/Damaged trends.
- Department-level analysis.
- Cost/deduction analysis later.
- Inventory movement trends.
- Report exports for management.

---

# Current Next Step

The next implementation phase is:

**Phase P — Role-Based Access Control**

Start with:

## Step P1 — Audit Current Role Usage

Review real GitHub repo and current Supabase policies.

Files to review first:

- `PROJECT_ROADMAP.md`
- `lib/features/current_context/data/repo/current_context_repo.dart`
- `lib/features/current_context/presentation/extensions/current_context_extensions.dart`
- `lib/features/company_users/...`
- `lib/core/layout/app_nav_items.dart`
- all main feature screens:
  - workers
  - tools
  - transactions
  - lookups
  - reports
  - company settings
- current SQL/RLS policies

Expected output:

- Confirm current role source.
- Define permission matrix.
- Define UI restrictions.
- Define RPC/RLS changes needed.
- Decide first implementation step for Owner/Admin member management:
  - change role
  - deactivate member
  - reactivate member
  - protect last owner

