# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Last Verified GitHub State

Latest verified pushed commit:

`697bc76454743ebe0ff176a1c5ccf8131898263a`

Commit message:

`add secure company member role management`

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
- Multi-company user access under one account
- Workspace/company switching
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
- Future custom permission overrides without rebuilding the whole permission system

---

# Core Rules

## Development Rules

- Work step by step.
- Do not make large changes in one step.
- Do not change a working UI unless needed.
- Always review the real GitHub repo before continuing a new step.
- Do not rely only on README because it may be outdated.
- Keep `PROJECT_ROADMAP.md` as the single source of truth.
- Update this roadmap after each completed feature or major checkpoint.
- Do not create multiple roadmap files.
- If a file becomes too large, refactor it into smaller focused files without changing working behavior.
- When changing existing files during guided development, provide complete file replacements when requested.
- Keep implementation scalable and maintainable.
- Start with simple fixed-role permissions, but keep the structure ready for future custom permission overrides.
- Prefer completing one coherent feature/checkpoint before opening a different large area.
- Avoid mixing unrelated architecture changes inside the same checkpoint.

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

Role-based features should be tested with:

- Owner
- Admin
- Warehouse Manager
- Warehouse User
- Viewer

If a role cannot be tested due to lack of email/test account, document that clearly.

Backend security-sensitive features must also be tested at database level where applicable, not only through Flutter UI.

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
9. Storage Policies if needed
10. Manual test
11. Direct DB/RPC security test if relevant
12. `dart format lib`
13. `flutter analyze`
14. Commit / Push
15. Update roadmap

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
- Storage policies must enforce upload/read permissions at bucket level.
- Plan limits must be enforced at database/RPC level, not UI only.
- Subscription access must be checked securely using company subscription records.
- Sensitive member-management mutations must use secure RPCs, not direct client updates.
- Direct invitation creation must not be left open when a secure invitation RPC exists.
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
- UI role restrictions must match database RLS and Storage policies.
- Navigation should reflect actual feature ownership:
  - Company settings belong in `Settings`.
  - Team/member management belongs in a dedicated `Team` area.
- Users with multiple companies should have:
  - A clear initial workspace selection flow when needed.
  - Persistent last selected workspace behavior.
  - A visible manual `Switch Company` action.

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

## Role / Permission Design Rules

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
- No role can manage:
  - Itself
  - Owner
  - Same-level roles unless explicitly allowed in future
  - Higher-level roles

Future scalable direction:

- Keep the permission helper structure ready for:
  - Base role permissions
  - Extra allowed permissions
  - Explicit denied permissions
- Future custom permissions should not require rebuilding all screens from scratch.

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
- Who rejected it, if applicable
- Who settled it, if applicable
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

Team / Company Users should eventually show:

- Invited by
- Invitation accepted by
- Role changed by
- Deactivated by
- Reactivated by
- Removed by, if remove-access is implemented later

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
- Owner/Admin can invite users by email.
- Pending invitations can be listed and cancelled.
- Invited users can see company invitation details before joining.
- Invited users can accept invitations and join the company.
- Accepted users appear in Company Users with their assigned role.
- Duplicate pending invitations are blocked.
- Duplicate active-member invitations are blocked at database level.
- Company user business errors are displayed with clear user-facing messages.
- Role-based UI permissions are implemented.
- App navigation is filtered by current company role.
- Workers/Tools/Transactions/Lookups/Reports/Settings actions are restricted by role in Flutter UI.
- Supabase public table RLS write policies are aligned with the implemented RBAC matrix.
- Supabase Storage upload policies are aligned with the implemented RBAC matrix.
- Manual role testing completed for:
  - Owner
  - Admin
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Secure invitation creation backend is implemented through `invite_company_user`.
- Direct authenticated insert access to `company_invitations` has been closed after moving Flutter to the secure RPC path.
- Multi-company workspace selection is implemented.
- Existing users can receive invitations to additional companies.
- Users with multiple companies can choose a workspace.
- The app remembers the last selected workspace locally per profile.
- Users can manually switch companies through a visible `Switch Company` action.
- Secure member role management is implemented through `change_company_member_role`.
- Role changes are wired through Flutter Repo, Cubit, and UI.
- Direct SQL security tests passed for:
  - Admin lower-role changes
  - Admin forbidden Admin assignment
  - Admin forbidden same-level management
  - Self role-change prevention
  - Owner protection
- Active company membership enforcement is confirmed in:
  - `private.is_company_member`
  - `private.has_company_role`
- Secure member deactivation backend is implemented through `deactivate_company_member`.
- Secure member reactivation backend is implemented through `reactivate_company_member`.
- Direct SQL security tests passed for:
  - Admin deactivate/reactivate hierarchy
  - Warehouse Manager deactivate/reactivate hierarchy
  - Self-deactivation prevention
  - Owner protection
  - Same-level management blocking

## Current Active Phase

**Phase Q — Secure Member Management & Invitation Backend**

Status:

**In Progress**

Completed in current phase:

- Step Q1 — Member lifecycle audit completed.
- Step Q2 — Secure invitation creation backend completed.
- Step Q2A — Multi-company invitation/workspace flow completed.
- Step Q3 — Secure member role-change backend + Flutter flow completed.
- Step Q4 backend foundation — Secure deactivate/reactivate RPCs completed and direct SQL security tests passed.

Current active checkpoint:

**Step Q4.7 — Team Access Refactor & Member Lifecycle UI**

Current decision:

- Move member management out of `Settings`.
- Add a dedicated `Team` area for company users/member lifecycle.
- Keep `Settings` focused on company configuration only.
- Allow Warehouse Manager to manage lifecycle access for lower roles only:
  - `warehouse_user`
  - `viewer`

Next required work:

- Update `CompanyRolePermissions` for new Team access and Warehouse Manager lifecycle permissions.
- Add dedicated Team / Company Users screen.
- Add `Team` navigation item.
- Remove `CompanyUsersSection` from `CompanySettingsScreen`.
- Wire Flutter methods for:
  - `deactivateCompanyMember`
  - `reactivateCompanyMember`
- Add responsive member lifecycle UI:
  - Change Role
  - Deactivate
  - Reactivate
- Manually test lifecycle UI by role.
- Re-run direct DB/RPC security verification after UI connection if needed.
- Decide whether invitation email delivery belongs inside the remaining Phase Q scope or a later production-readiness checkpoint.

Reason for priority:

Phase P completed the RBAC foundation for fixed roles across Flutter UI, Supabase RLS, and Storage policies.

Phase Q is now hardening company-user management through secure backend mutations, protected member lifecycle operations, multi-company flows, and a cleaner Team architecture before audit logging and release-readiness work begin.

---

# Recommended Execution Order

This order puts core SaaS/product requirements first, and keeps improvements/enhancements for later.

## Priority 1 — Must-Have Product Foundation

1. **Phase O — Company Users, Roles & Invitations** ✅
2. **Phase P — Role-Based Access Control** ✅
3. **Phase Q — Secure Member Management & Invitation Backend** 🚧
4. **Auth UX Checkpoint — Email-First Authentication Flow**
5. **Phase R — Business Accountability & Audit Trail**
6. **Phase S — Production Environment & Secrets Setup**
7. **Phase T — Subscription Plans, Usage Limits & Company Access Control**

## Priority 2 — Release Readiness

8. **Phase U — Store / Release Preparation**
9. **Phase V — Production Data Safety & Demo Account**
10. **Phase W — Basic Audit Log Screen**

## Priority 3 — Operational Improvements

11. **Phase X — Mobile/Tablet Camera Capture**
12. **Phase Y — Storage Usage Tracking**
13. **Phase Z — Advanced Reports & PDF Enhancements**
14. **Phase AA — Dashboard Enhancements**

## Priority 4 — Future / Advanced Features

15. **Phase AB — Offline Drafts & Background Sync**
16. **Phase AC — Notifications**
17. **Phase AD — Web Landing Page / Customer Portal**
18. **Phase AE — Desktop Installer Distribution**
19. **Phase AF — Advanced Analytics**
20. **Phase AG — Custom Permission Overrides**

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
- Added safe grants at the time of Phase O:
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

Important historical note:

- Direct authenticated insert access was later closed in Phase Q after invitation creation moved to the secure `invite_company_user` RPC.

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

## Items moved out of Phase O

The following items were intentionally deferred from Phase O:

- Change member role.
- Deactivate/reactivate member.
- Remove member access from company.
- Prevent last owner deactivation/removal.
- Audit logs for invite/cancel/accept/role-change/deactivate/reactivate/remove actions.
- Email delivery for invitations.
- Supabase Edge Function for production invitation email sending.

Current follow-up status:

- Change member role: completed in Phase Q.
- Deactivate/reactivate backend RPCs: completed in Phase Q.
- Remove member access: still pending.
- Last owner protection for deactivation: covered because owner deactivation is blocked.
- Last owner protection for future remove/transfer flows: still pending.
- Audit logs: pending Phase R.
- Invitation email delivery: still pending.
- Production invitation email sending backend/Edge Function: still pending.

---

# Phase P — Role-Based Access Control

## Status: Done

## Goal

Restrict app actions based on the current user's company role.

Phase O made multi-user company access possible. Phase P made that access safer by enforcing fixed-role access through:

- Flutter UI permission helpers
- Navigation filtering
- Screen/action-level permission checks
- Supabase RLS write policies
- Supabase Storage policies
- Manual role testing

## Role Model Implemented

Implemented fixed roles:

- `owner`
- `admin`
- `warehouse_manager`
- `warehouse_user`
- `viewer`

Important design decision:

- This phase uses fixed roles.
- The owner changes a user's role to change access.
- Per-user custom permission overrides are future scope.
- The permission helper is intentionally structured to allow future expansion.

## Implemented Permission Behavior

### Owner

Owner has full access to currently implemented features:

- Dashboard
- Workers
- Tools
- Transactions
- Pending Approvals
- Custody Balance
- Tool Summary
- Reports
- Lookups
- Settings
- Company Profile
- Company Logo
- Company Users
- Report Settings
- Document Templates
- Upload transaction proof images
- Upload signed approval documents
- Approve/reject lost or damaged transactions
- Settle approved lost/damaged transactions

### Admin

Admin is treated as near-owner for currently implemented features:

- Dashboard
- Workers
- Tools
- Transactions
- Pending Approvals
- Custody Balance
- Tool Summary
- Reports
- Lookups
- Settings
- Company Profile
- Company Logo
- Company Users
- Report Settings
- Document Templates
- Upload transaction proof images
- Upload signed approval documents
- Approve/reject lost or damaged transactions
- Settle approved lost/damaged transactions

Future difference:

- Owner should remain higher than Admin for sensitive actions such as:
  - Transfer ownership
  - Delete company
  - Manage subscription owner-level billing
  - Promote users to owner
  - Remove/deactivate last owner

### Warehouse Manager

Warehouse Manager can:

- View Dashboard
- View/manage Workers
- View/manage Tools
- View/manage Lookups
- View/create Transactions
- Upload transaction proof images
- Upload signed approval documents
- Approve/reject lost or damaged transactions
- Settle approved lost/damaged transactions
- View/generate Reports

Warehouse Manager cannot in the Phase P implementation:

- See Settings tab
- Manage Company Users
- Invite users
- Manage company profile/logo/report settings/templates
- Manage subscriptions

Phase Q follow-up decision:

- Warehouse Manager should be able to manage lifecycle access for lower roles:
  - `warehouse_user`
  - `viewer`
- This will be exposed through a dedicated `Team` area, not by opening the whole Settings area.

### Warehouse User

Warehouse User can:

- View Dashboard
- View Workers
- View Tools
- View Transactions
- Create Transactions
- Upload transaction proof images
- View Pending Approvals
- View Custody Balance
- View Tool Summary
- View/generate Reports according to current helper configuration

Warehouse User cannot:

- Add/edit/delete Workers
- Add/edit/delete Tools
- See Lookups tab
- See Settings tab
- Upload signed approval documents
- Approve/reject lost or damaged transactions
- Settle approved lost/damaged transactions
- Manage Company Users
- Manage company settings

### Viewer

Viewer can:

- View Dashboard
- View Reports according to current helper configuration

Viewer cannot:

- See Workers tab
- See Tools tab
- See Transactions tab
- See Lookups tab
- See Settings tab
- Create/update/delete any business data
- Upload documents
- Manage approvals
- Manage company users/settings

Future note:

- If Viewer should become strictly view-only without report generation, remove `generateReports` from `viewer` permissions in `CompanyRolePermissions`.

## Completed implementation

### Step P1 — Audit Current Role Usage

Completed.

Reviewed:

- `PROJECT_ROADMAP.md`
- `CurrentContextRepo`
- `CurrentContextCubit`
- `CompanyModel`
- `current_context_extensions.dart`
- `AppShell`
- `AppNavItems`
- Workers screens/actions
- Tools screens/actions
- Transactions screens/actions
- Lookups screens/actions
- Reports screens/actions
- Company Settings screens/actions
- Company Users section
- Existing Supabase RLS policies
- Existing Supabase helper functions
- Existing Supabase Storage policies

Confirmed role source:

- `company_members.role`
- `CurrentContextRepo`
- `CompanyModel.role`
- `context.currentUserRole`

Confirmed existing helper functions:

- `private.current_profile_id()`
- `private.is_company_member(uuid)`
- `private.has_company_role(uuid, company_member_role[])`
- `private.company_id_from_storage_path(text)`

### Step P2 — Add Flutter Permission Helpers

Completed.

Added central role/permission helper:

- `lib/core/permissions/company_role_permissions.dart`

Implemented:

- `CompanyPermission`
- `CompanyRoles`
- `CompanyRolePermissions`

Included permission methods for:

- Dashboard
- Workers
- Tools
- Transactions
- Lost/Damaged approval workflow
- Custody balance
- Tool summary
- Reports
- Lookups
- Company settings
- Company users
- Invitations
- Member management placeholders/future methods

Supported role assignment helpers:

- `assignableRolesFor`
- `canAssignRole`
- `canManageTargetRole`

Important scalability decision:

- The current helper uses fixed role permissions.
- Structure is ready for future custom permission overrides.

### Step P3 — Apply UI Restrictions

Completed.

Updated app navigation:

- `AppNavItem`
- `AppNavItems`
- `DesktopShell`
- `TabletShell`
- `MobileShell`

Navigation is now filtered by current user role.

Updated Company Users:

- Replaced local Owner/Admin check with `CompanyRolePermissions`.
- Owner can invite Admin/Warehouse Manager/Warehouse User/Viewer.
- Admin can invite Warehouse Manager/Warehouse User/Viewer.
- Lower roles cannot view Company Users section in the Phase P implementation.

Updated Workers:

- Owner/Admin/Warehouse Manager can Add/Edit/Delete.
- Warehouse User can view only.
- Viewer cannot see Workers tab.

Updated Tools:

- Owner/Admin/Warehouse Manager can Add/Edit/Delete.
- Warehouse User can view only.
- Viewer cannot see Tools tab.

Updated Transactions:

- Owner/Admin/Warehouse Manager/Warehouse User can create transactions.
- Warehouse User can upload transaction proof images.
- Warehouse User sees View only in Pending Approvals.
- Owner/Admin/Warehouse Manager can upload signed approval documents.
- Owner/Admin/Warehouse Manager can approve/reject/settle.
- Viewer cannot see Transactions tab.

Updated Lookups:

- Owner/Admin/Warehouse Manager can Add/Delete lookups.
- Warehouse User cannot see Lookups tab.
- Viewer cannot see Lookups tab.
- Lookup list tiles support hidden delete actions.

Updated Company Settings:

- Settings tab visible only to Owner/Admin.
- Internal settings sections also use permission checks for future scalability.
- Company Profile, Company Logo, Company Users, Report Settings, and Document Templates are permission-gated.

Updated Reports:

- Report cards respect `canGenerateReports`.
- Report Builder and Preview PDF respect `canGenerateReports`.
- Future read-only report behavior is supported.

### Step P4 — Align Public Table RLS Policies

Completed.

Audited RLS status:

- All important public tables have RLS enabled.

Tables confirmed with RLS:

- `companies`
- `company_document_templates`
- `company_invitations`
- `company_members`
- `company_report_settings`
- `departments`
- `job_titles`
- `profiles`
- `tool_categories`
- `tool_units`
- `tools`
- `transactions`
- `workers`

Updated write policies for:

- `workers`
- `tools`
- `departments`
- `job_titles`
- `tool_categories`
- `tool_units`
- `transactions`

Confirmed intended write access:

- Workers:
  - `owner`
  - `admin`
  - `warehouse_manager`
- Tools:
  - `owner`
  - `admin`
  - `warehouse_manager`
- Lookups:
  - `owner`
  - `admin`
  - `warehouse_manager`
- Transactions insert:
  - `owner`
  - `admin`
  - `warehouse_manager`
  - `warehouse_user`
- Transactions approval workflow update:
  - `owner`
  - `admin`
  - `warehouse_manager`

### Step P5 — Align Storage Policies

Completed.

Updated storage policies for:

- `transaction-proofs`
- `transaction-approval-documents`

Confirmed intended upload access:

- `transaction-proofs`
  - `owner`
  - `admin`
  - `warehouse_manager`
  - `warehouse_user`
- `transaction-approval-documents`
  - `owner`
  - `admin`
  - `warehouse_manager`

Important fix:

- Upload Signed initially failed because of Storage RLS:
  - `new row violates row-level security policy`
- Fixed by simplifying the policy and using:
  - `private.company_id_from_storage_path(name)`
- Upload Signed worked after the policy correction.

### Step P6 — Manual Role Testing

Completed.

Tested manually:

- Owner
- Admin
- Warehouse Manager
- Warehouse User
- Viewer

Confirmed:

- Navigation matches role.
- Worker actions match role.
- Tool actions match role.
- Transaction actions match role.
- Lookups visibility/actions match role.
- Settings visibility matches role.
- Report generation checks are enforced in UI.
- Storage upload behavior matches intended roles.
- Warehouse User can upload proof image but cannot upload signed approval document.
- Viewer cannot access hidden operational tabs.

## Phase P Documentation

Created:

- `docs/supabase/phase_p_rbac_policies.md`

---

# Phase Q — Secure Member Management & Invitation Backend

## Status: In Progress

## Goal

Harden company-user management beyond the Phase O foundation by moving sensitive lifecycle behavior into secure backend logic and preparing a cleaner production-ready Team architecture.

This phase covers:

- Secure invitation creation
- Multi-company invitation/workspace flows
- Secure role changes
- Secure deactivate/reactivate lifecycle operations
- Team-access refactor
- Stronger member management UI
- Future audit readiness for member actions
- Future invitation email delivery decision

## Confirmed Lifecycle Rules

### Role assignment

- Owner can assign:
  - Admin
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Admin can assign:
  - Warehouse Manager
  - Warehouse User
  - Viewer
- No user can:
  - Assign Owner from normal member management
  - Change own role
  - Change Owner role
  - Change same-level Admin rules outside allowed hierarchy

### Lifecycle management

- Owner can deactivate/reactivate:
  - Admin
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Admin can deactivate/reactivate:
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Warehouse Manager can deactivate/reactivate:
  - Warehouse User
  - Viewer
- No user can:
  - Deactivate/reactivate themselves
  - Manage Owner lifecycle
  - Manage same-level roles unless explicitly allowed in future
  - Manage higher-level roles

### Membership enforcement

Confirmed active-membership enforcement:

- `private.is_company_member(...)` requires:
  - `cm.status = 'active'`
- `private.has_company_role(...)` requires:
  - `cm.status = 'active'`

This means inactive users lose effective company access at database level.

## Completed implementation

### Step Q1 — Audit Company Members Management Requirements

Completed.

Reviewed:

- `company_members` structure
- `company_invitations` structure
- member/invitation enums
- constraints
- indexes
- RLS status
- grants
- existing RPCs
- `CompanyUsersRepo`
- `CompanyUsersCubit`
- `CompanyUsersState`
- `CompanyUsersSection`
- `CurrentContextRepo`
- `current_context_extensions.dart`
- `CompanyRolePermissions`
- `AppShell`
- `AppNavItems`

Confirmed:

- Member lifecycle should use soft deactivation, not physical deletion.
- `company_members.status` already supports:
  - `active`
  - `inactive`
  - `invited`
- Current real membership flow uses:
  - `active`
  - `inactive`
- `invited` exists in the enum but is not the real post-acceptance membership flow.
- Owners must not be manageable through normal member lifecycle actions.
- Last-owner risk is prevented for deactivation because Owner deactivation is blocked entirely.
- Future remove-access / ownership-transfer flows still require separate owner safeguards.

### Step Q2 — Secure Invitation Creation Backend

Completed.

Implemented secure RPC:

- `invite_company_user(uuid, text, text)`

The RPC now enforces:

- Authenticated actor only.
- Actor must be active in the target company.
- Valid invitation role only.
- Owner cannot be invited.
- Owner can invite:
  - Admin
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Admin can invite:
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Duplicate pending invitation remains blocked.
- Already-active-member invitation remains blocked.

Flutter changes:

- `CompanyUsersRepo.inviteCompanyUser()` now calls:
  - `invite_company_user`
- Legacy direct insert path is no longer used by Flutter.

Security hardening:

- Removed legacy direct authenticated insert privilege from `company_invitations`.
- Removed old direct-insert RLS policy:
  - `Owners and admins can create pending company invitations`
- `authenticated` now keeps only:
  - `SELECT`
  on `company_invitations`.

Manual test:

- Owner can still create invitation successfully after direct insert path was closed.

### Step Q2A — Multi-Company Invitation & Workspace Flow

Completed.

Reason:

- Existing invitation flow originally assumed users had either:
  - no company
  - or one company
- A user who already owned one company but was invited to a second company needed a correct multi-company flow.

Implemented:

- Split invitation state into:
  - `companyInvitations`
  - `currentUserInvitations`
- Added dedicated loading:
  - `isCurrentUserInvitationsLoading`
- Fixed current-user invitation query to filter by the signed-in user's email only.
- Existing users can now see invitations to additional companies.
- Added `SelectCompanyScreen`.
- Added multi-company workspace selection flow.
- Added persistent local storage for last selected company per profile through:
  - `CurrentCompanyStorageService`
- Added manual `Switch Company` action in:
  - `AppTopBar`
  - `MobileShell`
- Added `loadCurrentContext(restoreLastSelectedCompany: false)` flow after accepting a new invitation, so a user can choose between companies after joining another workspace.

Manual test confirmed:

- A user with one company can receive an invitation to another company.
- The invitation appears for the invited account only.
- The inviter does not see the invited user's own pending invitation.
- The invited user can accept the invitation.
- A user with multiple companies can choose a workspace.
- Refresh preserves the last selected workspace.
- `Switch Company` opens workspace selection manually.
- Selecting another company persists after refresh.

### Step Q3 — Secure Member Role Change

Completed.

Implemented secure RPC:

- `change_company_member_role(uuid, uuid, text)`

The RPC enforces:

- Authenticated actor only.
- Actor must be active in the company.
- Valid target member required.
- No self role change.
- No Owner role change from normal member management.
- No assignment to Owner.
- Owner can assign:
  - Admin
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Admin can assign:
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Admin cannot manage another Admin.
- Only active/inactive real members can be managed.

Flutter changes:

- Added `changeCompanyMemberRole()` to:
  - `CompanyUsersRepo`
  - `CompanyUsersCubit`
- Added Change Role UI in `CompanyUsersSection`.
- Fixed dialog-provider context issue by using the parent context.

Manual UI tests confirmed:

- Owner can change lower member roles.
- Admin can manage lower roles only.
- Admin cannot assign Admin from the UI.
- Owner and self rows are protected from invalid UI actions.

Direct DB security tests passed for:

- Admin can change lower-role member.
- Admin cannot assign Admin.
- Admin cannot manage another Admin.
- Admin cannot change own role.
- Admin cannot change Owner role.

### Step Q4 — Secure Member Deactivation & Reactivation Backend

Backend foundation completed.

Implemented secure RPCs:

- `deactivate_company_member(uuid, uuid)`
- `reactivate_company_member(uuid, uuid)`

The RPCs enforce:

- Authenticated actor only.
- Actor must be active in the company.
- No self deactivation/reactivation.
- No Owner lifecycle management.
- Only `active` members can be deactivated.
- Only `inactive` members can be reactivated.
- Owner can manage:
  - Admin
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Admin can manage:
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Warehouse Manager can manage:
  - Warehouse User
  - Viewer

Confirmed backend membership behavior:

- `private.is_company_member(...)` checks active membership only.
- `private.has_company_role(...)` checks active membership only.
- Inactive members lose effective company access through RLS-backed helper functions.

Direct DB security tests passed for:

- Admin can deactivate/reactivate lower-role members.
- Admin cannot deactivate/reactivate another Admin.
- Admin cannot deactivate self.
- Admin cannot deactivate Owner.
- Warehouse Manager can deactivate/reactivate lower-role members.
- Warehouse Manager cannot manage another Warehouse Manager.
- Warehouse Manager cannot manage Admin.
- Warehouse Manager cannot deactivate self.
- Warehouse Manager cannot deactivate Owner.

## Current in-progress checkpoint

### Step Q4.7 — Team Access Refactor & Member Lifecycle UI

Decision:

- Do not keep member management buried inside `Settings`.
- Add a dedicated `Team` area.
- Keep `Settings` focused on company configuration.
- Expose Warehouse Manager lifecycle permissions through `Team`, not by opening all Settings.

Planned implementation:

1. Update `CompanyRolePermissions`
   - Add `warehouse_manager` lifecycle permissions for:
     - `viewCompanyUsers`
     - `deactivateMember`
     - `reactivateMember`
   - Update `canManageTargetRole` to allow Warehouse Manager to manage:
     - `warehouse_user`
     - `viewer`
2. Add dedicated screen:
   - `lib/features/company_users/presentation/screens/company_users_screen.dart`
3. Add new nav item:
   - `Team`
4. Remove `CompanyUsersSection` from:
   - `CompanySettingsScreen`
5. Add Flutter repo/cubit methods:
   - `deactivateCompanyMember`
   - `reactivateCompanyMember`
6. Add lifecycle UI:
   - Deactivate
   - Reactivate
7. Ensure UI visibility matches backend hierarchy.
8. Manually test by role:
   - Owner
   - Admin
   - Warehouse Manager
   - Warehouse User
   - Viewer
9. Run:
   - `dart format lib`
   - `flutter analyze`
10. Commit / Push
11. Update roadmap and Supabase documentation.

## Remaining Phase Q items

- Complete `Team` access refactor and lifecycle UI.
- Decide and implement whether production invitation email delivery belongs inside Phase Q or later release-readiness work.
- Decide future remove-access strategy:
  - Keep soft deactivate only for now
  - Add remove access later only if business need is clear
- Preserve future last-owner protections for any later ownership transfer/remove-access flow.
- Prepare Phase R audit integration for:
  - invite
  - cancel invitation
  - accept invitation
  - role change
  - deactivate
  - reactivate

---

# Auth UX Checkpoint — Email-First Authentication Flow

## Status: Planned After Phase Q

## Goal

Replace the current ambiguous register-first behavior with a clearer SaaS-style authentication entry flow.

Planned UX:

1. User first enters only email.
2. Backend determines whether an account already exists.
3. If account exists:
   - Route user to login.
   - Show clear message:
     - `An account already exists for this email. Please log in.`
4. If account does not exist:
   - Route user to registration.
5. Invitations remain linked to the same account/email model.
6. Existing users invited to additional companies log in with the same account and accept the invitation.

Reason for checkpoint:

- Current Supabase signup behavior may return an obfuscated/fake user object for an already registered email under some auth-confirmation settings.
- The current product UX should become clearer and more professional.
- Mina System uses one account with multi-company membership, so email-first flow matches the product model better than separate blind register/login paths.

Likely technical direction:

- Server-side account-status check through a secure backend function/Edge Function.
- No service-role logic in Flutter.
- Rate limiting and abuse protection required because explicit account-existence checks create email-enumeration risk.
- Integrate invitation-aware guidance into auth copy and routing.

---

# Phase R — Business Accountability & Audit Trail

## Status: Planned

## Goal

Add direct user accountability and historical audit logging for important business actions.

Planned scope:

- Direct accountability fields on important records.
- Transaction accountability fields for:
  - created by
  - proof uploaded by
  - signed approval document uploaded by
  - approval decided by
  - settled by
  - last updated by
- Audit log table and secure insert strategy.
- RLS-protected audit history.
- UI display of accountability fields on relevant details screens.
- Company user audit readiness for:
  - invitation creation
  - invitation cancellation
  - invitation acceptance
  - role change
  - deactivation
  - reactivation
  - future remove-access action

---

# Phase S — Production Environment & Secrets Setup

## Status: Planned

## Goal

Prepare the project for safe production deployment.

Planned scope:

- Separate development and production Supabase projects.
- Secure environment handling.
- No hardcoded secrets in client code.
- Build configuration cleanup.
- Production storage review.
- Production auth/site URL review.
- Production email/redirect review.
- Release-safe configuration documentation.

---

# Phase T — Subscription Plans, Usage Limits & Company Access Control

## Status: Planned

## Goal

Turn Mina System into a scalable SaaS product with company-level subscription control.

Planned scope:

- Company subscriptions.
- Plan tiers.
- Usage limits.
- Storage limits.
- Feature gating.
- Trial/free-plan behavior.
- Company access restrictions when plan expires.
- Secure DB/RPC enforcement for plan limits.

---

# Phase U — Store / Release Preparation

## Status: Planned

## Goal

Prepare the app for Google Play, App Store, and desktop distribution readiness.

Planned scope:

- App metadata.
- Icons.
- Splash.
- Release signing.
- Store screenshots.
- Privacy policy.
- Terms of service.
- Support contact.
- Demo/review credentials if needed.
- Final QA checklist.

---

# Phase V — Production Data Safety & Demo Account

## Status: Planned

## Goal

Protect production data and provide safe review/demo access.

Planned scope:

- Remove test data before production.
- Safe seed/demo data strategy.
- Demo company/account strategy.
- Backup/export plan.
- Data reset plan for non-production environments.
- Production safety checklist.

---

# Phase W — Basic Audit Log Screen

## Status: Planned

## Goal

Expose audit history to authorized users after backend logging exists.

Planned scope:

- Basic audit list.
- Filters.
- Actor.
- Action.
- Entity.
- Timestamp.
- Secure permission gating.
- Later drill-down expansion.

---

# Phase X — Mobile/Tablet Camera Capture

## Status: Planned

## Goal

Improve field usability for proof/document workflows.

Planned scope:

- Camera capture for transaction proof images.
- Camera capture for approval-document images where applicable.
- Preserve file picker fallback.
- Permission handling.
- Image compression integration.
- Mobile/tablet testing.

---

# Phase Y — Storage Usage Tracking

## Status: Planned

## Goal

Track storage consumption per company for future billing and limits.

Planned scope:

- Storage usage per company.
- Approximate image/PDF size tracking.
- Quota visibility.
- Limit enforcement integration with subscription plans.

---

# Phase Z — Advanced Reports & PDF Enhancements

## Status: Planned

## Goal

Expand reporting power and polish generated documents.

Planned scope:

- Additional filters.
- Better summary sections.
- More report types.
- Branding improvements.
- Possible export variants.
- Better offline/report asset handling.

---

# Phase AA — Dashboard Enhancements

## Status: Planned

## Goal

Improve management visibility and operational insight.

Planned scope:

- Additional KPIs.
- Alerts.
- Trend cards.
- Role-aware dashboard widgets.
- Better responsive dashboard layout.

---

# Phase AB — Offline Drafts & Background Sync

## Status: Planned

## Goal

Support more resilient offline workflows beyond current network blocking.

Planned scope:

- Offline drafts.
- Sync queue.
- Retry behavior.
- Conflict handling.
- Clear user status.
- Must not bypass server-side rules.

---

# Phase AC — Notifications

## Status: Planned

## Goal

Add important user notifications.

Planned scope:

- Invitation notifications.
- Approval workflow notifications.
- Settlement notifications.
- Optional reminders.
- Future push/email integration.

---

# Phase AD — Web Landing Page / Customer Portal

## Status: Planned

## Goal

Support product presentation, onboarding, and subscription flow outside the app.

Planned scope:

- Marketing landing page.
- Pricing.
- Product screenshots.
- Support/contact.
- Subscription/customer portal.
- Possibly documentation/help center.

---

# Phase AE — Desktop Installer Distribution

## Status: Planned

## Goal

Provide polished Windows distribution.

Planned scope:

- Installer packaging.
- Update strategy.
- Download page integration.
- Desktop release instructions.

---

# Phase AF — Advanced Analytics

## Status: Planned

## Goal

Add deeper operational analysis after core product maturity.

Planned scope:

- Usage trends.
- Worker/tool patterns.
- Company-level analytics.
- Exportable management insights.

---

# Phase AG — Custom Permission Overrides

## Status: Planned

## Goal

Support more flexible permissions beyond fixed roles.

Planned scope:

- Base role permissions.
- Extra allow permissions.
- Explicit deny permissions.
- User-specific overrides.
- Future UI for custom access management.
- Must preserve existing fixed-role compatibility.

---

# Current Next Action

Continue Phase Q from:

## Step Q4.7.1 — Update `CompanyRolePermissions` for Team Access and Warehouse Manager Lifecycle Permissions

Next files expected to be reviewed before editing:

- `lib/core/permissions/company_role_permissions.dart`
- `lib/core/layout/app_nav_items.dart`
- `lib/features/company_settings/presentation/screens/company_settings_screen.dart`
- `lib/features/company_users/presentation/widgets/company_users_section.dart`

Next design target:

- Add dedicated `Team` navigation area.
- Keep `Settings` for company configuration.
- Allow Warehouse Manager to manage only lower-role member lifecycle access.
- Keep all backend lifecycle protections already implemented in Supabase.