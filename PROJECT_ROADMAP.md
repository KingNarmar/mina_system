# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Last Verified GitHub State

Latest verified pushed commit:

`23e5b44415efe0cc57e0eef02bfaef187de13055`

Commit message:

`complete role-based access control`

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
- Update this roadmap after each completed feature or phase.
- Do not create multiple roadmap files.
- If a file becomes too large, refactor it into smaller focused files without changing working behavior.
- When changing existing files during guided development, provide complete file replacements when requested.
- Keep implementation scalable and maintainable.
- Start with simple fixed-role permissions, but keep the structure ready for future custom permission overrides.

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
11. `dart format lib`
12. `flutter analyze`
13. Commit / Push
14. Update roadmap

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
- Role-based UI permissions are implemented.
- App navigation is filtered by current company role.
- Workers/Tools/Transactions/Lookups/Reports/Settings actions are restricted by role in Flutter UI.
- Supabase public table RLS write policies are aligned with the implemented RBAC matrix.
- Supabase Storage upload policies are aligned with the implemented RBAC matrix.
- Manual role testing completed for:
  - Owner
  - Warehouse Manager
  - Warehouse User
  - Viewer
- Admin was not manually tested due to lack of extra email account, but current policies treat Admin with Owner/Admin access for implemented features.

## Current Active Phase

**Phase Q — Secure Member Management & Invitation Backend**

Status:

**Next / Not Started**

Reason for priority:

Phase P completed the RBAC foundation for fixed roles across Flutter UI, Supabase RLS, and Storage policies.

The next required step is to improve company user management and invitation production readiness.

This includes:

- Secure role-change RPCs
- Deactivate/reactivate member RPCs
- Last-owner protection
- Optional invitation email delivery through backend/Edge Function
- Stronger member management UI for Owner/Admin
- Audit readiness for company user changes

---

# Recommended Execution Order

This order puts core SaaS/product requirements first, and keeps improvements/enhancements for later.

## Priority 1 — Must-Have Product Foundation

1. **Phase O — Company Users, Roles & Invitations** ✅
2. **Phase P — Role-Based Access Control** ✅
3. **Phase Q — Secure Member Management & Invitation Backend**
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
19. **Phase AG — Custom Permission Overrides**

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

- Change member role.
- Deactivate/reactivate member.
- Remove member access from company.
- Prevent last owner deactivation/removal.
- Audit logs for invite/cancel/accept/role-change/deactivate/reactivate/remove actions.
- Email delivery for invitations.
- Supabase Edge Function for production invitation email sending.

These belong to:

- Phase Q — Secure Member Management & Invitation Backend
- Phase R — Business Accountability & Audit Trail

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

Warehouse Manager cannot:

- See Settings tab
- Manage Company Users
- Invite users
- Manage company profile/logo/report settings/templates
- Manage subscriptions

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
- Lower roles cannot view Company Users section.

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
- `tool_units`
- `tool_categories`
- `transactions`

Implemented policy behavior:

Workers:

- Owner/Admin/Warehouse Manager can insert/update/delete.
- Members can read existing workers through existing read policy.

Tools:

- Owner/Admin/Warehouse Manager can insert/update/delete.
- Members can read existing tools through existing read policy.

Lookups:

- Owner/Admin/Warehouse Manager can insert/update/delete:
  - departments
  - job titles
  - tool units
  - tool categories
- Members can read lookups through existing read policies.

Transactions:

- Owner/Admin/Warehouse Manager/Warehouse User can insert transactions.
- Owner/Admin/Warehouse Manager can update pending transactions.
- Owner/Admin/Warehouse Manager can upload signed approval document path.
- Owner/Admin/Warehouse Manager can approve/reject lost/damaged transactions.
- Owner/Admin/Warehouse Manager can settle approved lost/damaged transactions.
- Members can read transactions through existing read policy.

### Step P5 — Align Supabase Storage Policies

Completed.

Audited Storage buckets:

- `company-assets`
- `transaction-proofs`
- `transaction-approval-documents`

Confirmed:

- Buckets are private.
- `transaction-approval-documents` has file size limit configured.
- `transaction-approval-documents` allows:
  - `application/pdf`
  - `image/jpeg`
  - `image/png`
  - `image/webp`

Updated Storage policies:

`transaction-proofs`:

- Owner/Admin/Warehouse Manager/Warehouse User can upload.
- Reason: all these roles can create transactions and upload proof images.

`transaction-approval-documents`:

- Owner/Admin/Warehouse Manager can upload.
- Warehouse User cannot upload.
- Reason: signed approval documents belong to approval workflow.

Important fix:

- Initial policy used a strict folder condition that caused:
  - `new row violates row-level security policy`
- Fixed by simplifying policy to use:
  - `private.company_id_from_storage_path(name)`
- Uploading signed approval documents now works for Owner and Manager roles.

### Step P6 — Manual Role Testing

Completed.

Tested manually:

Owner:

- Navigation visible as expected.
- Settings visible.
- Workers/Tools/Lookups CRUD available.
- Transactions available.
- Pending approval Upload Signed works.
- Approval workflow works after document upload.

Warehouse Manager:

- Settings hidden.
- Workers/Tools/Lookups CRUD available.
- Transactions available.
- Pending approval Upload Signed available.
- Approval/Reject/Settle available.

Warehouse User:

- Settings hidden.
- Lookups hidden.
- Workers/Tools visible as read-only.
- Transactions available.
- Can create transactions.
- Can upload transaction proof images.
- Pending Approvals shows View only.
- Upload Signed/Approve/Reject/Settle hidden.

Viewer:

- Dashboard visible.
- Reports visible.
- Workers hidden.
- Tools hidden.
- Transactions hidden.
- Lookups hidden.
- Settings hidden.
- No mutation actions visible.

Admin:

- Not manually tested due to no additional email account.
- Current RLS and helper rules treat Admin with Owner/Admin access for currently implemented features.
- Admin should still be tested once a test email/account is available.

### Step P7 — Commit / Push

Completed.

Committed and pushed:

- Flutter UI RBAC implementation
- RLS / Storage documentation
- Final RBAC completion checkpoint

Latest verified commit:

`23e5b44415efe0cc57e0eef02bfaef187de13055`

Commit message:

`complete role-based access control`

## Remaining items moved to next phases

The following items are intentionally not completed inside Phase P:

- Change member role UI.
- Change member role RPC.
- Deactivate member RPC.
- Reactivate member RPC.
- Remove/deactivate company access.
- Prevent last owner removal/deactivation.
- Prevent owner/admin self-lockout scenarios.
- Full Admin-specific manual test.
- Invitation email delivery.
- Edge Function for production invitation flow.
- Audit logs for role/member changes.
- Per-user custom permission overrides.

Moved to:

- Phase Q — Secure Member Management & Invitation Backend
- Phase R — Business Accountability & Audit Trail
- Phase AG — Custom Permission Overrides

---

# Phase Q — Secure Member Management & Invitation Backend

## Status: Next / Not Started

## Goal

Improve company user management and production invitation handling.

Phase O allowed inviting and accepting users.

Phase P added role-based access control.

Phase Q should add safer member lifecycle controls and production invitation readiness.

## Required Features

### Member Management RPCs

Add secure RPCs for:

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
- All RPCs should derive acting user/profile from authenticated context.
- All RPCs should be protected by role checks.
- All RPCs should be prepared for future audit logging.

### Company Users UI Enhancements

Add controls for Owner/Admin:

- Change role.
- Deactivate member.
- Reactivate member.
- Show active/inactive members clearly.
- Keep accepted membership history visible.
- Do not hard delete members by default.

### Invitation Backend / Edge Function

Preferred future production approach:

- Supabase Edge Function for invitation creation and optional email sending.

Required behavior:

- Owner/Admin invites email.
- Invitation is stored.
- Email is sent to invited user.
- User signs up/logs in with invited email.
- App detects pending invitation.
- User accepts invitation.
- Membership is created.
- Invitation becomes accepted.

Security:

- Edge Function uses service role key server-side only.
- Flutter never receives service role key.
- Edge Function validates caller membership and role.
- Edge Function validates target email and company.
- Edge Function rate-limits or protects repeated invitation attempts where needed.

## Suggested Implementation Order

1. Audit `company_members` columns and current member UI.
2. Define member status behavior.
3. Create secure RPC:
   - `change_company_member_role`
4. Create secure RPC:
   - `deactivate_company_member`
5. Create secure RPC:
   - `reactivate_company_member`
6. Add last-owner protection.
7. Add repository/cubit methods.
8. Add Company Users UI actions.
9. Test Owner/Admin/lower roles.
10. Add Edge Function invitation email flow if ready.
11. Commit/push/update roadmap.

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
- `company_user.invited`
- `company_user.invitation_cancelled`
- `company_user.invitation_accepted`
- `company_user.role_changed`
- `company_user.deactivated`
- `company_user.reactivated`
- `company_user.access_removed`

## Suggested Implementation Order

1. Audit existing accountability columns.
2. Decide which direct fields to add first.
3. Create `audit_logs` table.
4. Add safe grants.
5. Add RLS policies:
   - Members can read audit logs for their company if allowed.
   - Normal users cannot insert arbitrary audit logs.
   - Normal users cannot update/delete audit logs.
6. Decide whether audit records are created by:
   - RPCs
   - database triggers
   - controlled repository logic
7. Start with transaction audit events.
8. Add worker/tool/settings/member audit events.
9. Add basic audit log screen later in Phase W.

---

# Phase S — Production Environment & Secrets Setup

## Status: Future / High Priority

## Goal

Prepare Mina System for real production use with safe environment separation.

## Required Work

- Create production Supabase project.
- Keep development/test Supabase project separate.
- Configure environment variables safely.
- Avoid hardcoded production secrets.
- Confirm Flutter builds use correct environment.
- Confirm Storage buckets exist in production.
- Confirm RLS policies are applied in production.
- Confirm required RPCs/functions exist in production.
- Confirm app cannot accidentally write test data to production.
- Prepare migration/documentation process for database changes.

## Suggested Implementation Order

1. List all Supabase tables/functions/policies/buckets.
2. Create production Supabase environment.
3. Apply schema and policies.
4. Configure app environment switching.
5. Test login/company creation in production.
6. Test role-based access in production.
7. Test Storage uploads in production.
8. Document production setup.

---

# Phase T — Subscription Plans, Usage Limits & Company Access Control

## Status: Future / High Priority

## Goal

Add SaaS subscription logic and usage limits.

## Required Work

- Define plans:
  - Free
  - Trial
  - Basic
  - Pro
  - Enterprise
- Add company subscription table.
- Add plan limits:
  - users
  - workers
  - tools
  - transactions
  - storage usage
  - reports
  - advanced features
- Enforce limits at database/RPC level.
- Add clear UI messages for plan limits.
- Add company access control based on active subscription.
- Add subscription admin screen later.
- Keep payments outside mobile app at first.

## Important Rules

- Do not rely on UI-only checks.
- Limits must be enforced server-side.
- Mobile apps should not include direct payment buttons until store rules are reviewed.
- B2B subscription payment can be handled through website/invoice/customer portal.

---

# Phase U — Store / Release Preparation

## Status: Future

## Goal

Prepare the app for Google Play, App Store, and future desktop release.

## Required Work

- App icon.
- App name.
- App description.
- Privacy Policy.
- Terms of Service.
- Support email.
- Demo/review account.
- Production backend.
- Release build configuration.
- Android signing.
- iOS release requirements.
- Store screenshots.
- Store listing copy.
- App permissions review.
- File/camera permissions review.
- Ensure no debug secrets are included.

---

# Phase V — Production Data Safety & Demo Account

## Status: Future

## Goal

Prepare safe demo/testing behavior for production and store reviewers.

## Required Work

- Create demo company.
- Create demo users by role.
- Create sample workers/tools/transactions.
- Ensure demo data is isolated.
- Prevent demo users from damaging production data.
- Add demo reset process if needed.
- Document demo credentials securely.

---

# Phase W — Basic Audit Log Screen

## Status: Future

## Goal

Display audit history inside the app after audit logging is implemented.

## Required Work

- Audit log list screen.
- Filter by action/entity/user/date.
- Show actor details.
- Show old/new values safely.
- Add role-based visibility.
- Add company-level audit access policies.
- Keep UI readable and not overly technical.

---

# Phase X — Mobile/Tablet Camera Capture

## Status: Future

## Goal

Allow users to capture proof images and documents directly from mobile/tablet camera.

## Required Work

- Add camera capture option.
- Keep file picker fallback.
- Compress captured images.
- Store cloud paths only.
- Test Android mobile/tablet.
- Test iOS later.
- Respect permissions.
- Handle denied camera permission gracefully.

---

# Phase Y — Storage Usage Tracking

## Status: Future

## Goal

Track storage usage per company for SaaS plan limits.

## Required Work

- Track uploaded file sizes.
- Store file metadata.
- Calculate company storage usage.
- Add usage limit checks.
- Add admin/company usage display.
- Prevent uploads above plan limit.
- Prepare cleanup/delete policies where allowed.

---

# Phase Z — Advanced Reports & PDF Enhancements

## Status: Future

## Goal

Improve report quality and add advanced reporting features.

## Required Work

- Better PDF branding.
- Company logo display improvements.
- More report filters.
- Export improvements.
- Report templates by company.
- PDF numbering/document control.
- Better lost/damaged approval documents.
- More summary reports.
- Print-friendly layouts.
- Possible Excel export later.

---

# Phase AA — Dashboard Enhancements

## Status: Future

## Goal

Make the dashboard more useful for managers and owners.

## Possible Enhancements

- Open custody count.
- Lost/damaged pending approval count.
- Pending settlement count.
- Top tools in custody.
- Workers with most open custody.
- Recent transactions.
- Storage usage.
- Plan usage.
- Role-aware dashboard cards.

---

# Phase AB — Offline Drafts & Background Sync

## Status: Future / Advanced

## Goal

Allow limited offline work without breaking data safety.

## Important Rule

Offline mode must not bypass RLS, subscription limits, or business rules.

## Possible Scope

- Offline transaction drafts.
- Local queue.
- Sync when online.
- Conflict handling.
- Upload retry for images/documents.
- Clear sync status.

---

# Phase AC — Notifications

## Status: Future

## Goal

Notify users about important workflow events.

## Possible Notifications

- Invitation received.
- Lost/damaged approval pending.
- Transaction approved.
- Transaction rejected.
- Settlement completed.
- Subscription/plan warnings.
- Storage limit warning.
- Pending actions for owner/admin/manager.

---

# Phase AD — Web Landing Page / Customer Portal

## Status: Future

## Goal

Create a public-facing web/customer layer.

## Possible Scope

- Product landing page.
- Pricing page.
- Contact form.
- Company subscription management.
- Customer portal.
- Invoice/payment instructions.
- Download links.
- Support/help docs.

---

# Phase AE — Desktop Installer Distribution

## Status: Future

## Goal

Prepare desktop app distribution.

## Possible Scope

- Windows installer.
- Auto-update strategy.
- Download page.
- Code signing later.
- Desktop release documentation.
- Environment selection for production.

---

# Phase AF — Advanced Analytics

## Status: Future

## Goal

Add advanced insights for operations and management.

## Possible Scope

- Worker custody risk.
- Tool loss/damage trends.
- Department-level summaries.
- Tool usage frequency.
- Approval/settlement cycle time.
- Monthly activity reports.
- Company-level KPIs.

---

# Phase AG — Custom Permission Overrides

## Status: Future / Advanced

## Goal

Allow company owners to give selected users extra permissions without changing their main role.

## Current Rule

The current implementation uses fixed roles only.

## Future Direction

Support:

- Base role permissions
- Extra allowed permissions
- Explicit denied permissions

Possible tables:

- `company_role_permissions`
- `company_member_permission_overrides`

Important:

- Flutter must not be the only enforcement layer.
- Supabase RLS/RPC must check the final effective permission.
- The current helper structure should be extended, not replaced.
- This phase should happen only after fixed-role RBAC is stable.

---

# Latest Manual Test Summary

## Tested Roles

Owner:

- Passed.

Warehouse Manager:

- Passed.

Warehouse User:

- Passed.

Viewer:

- Passed.

Admin:

- Not manually tested yet due to lack of extra email/test account.
- Expected to behave correctly because current helper and RLS policies include Admin in Owner/Admin permission groups for implemented features.

## Tested Features

- Navigation filtering by role.
- Workers role restrictions.
- Tools role restrictions.
- Transactions role restrictions.
- Pending approval action restrictions.
- Lookups role restrictions.
- Settings visibility restrictions.
- Report permission behavior.
- Public table RLS write policies.
- Storage policies for:
  - `transaction-proofs`
  - `transaction-approval-documents`
- Signed approval document upload fixed and tested.
- `dart format lib` completed.
- `flutter analyze` completed with no issues.
- Commit and push completed.

---

# Next Recommended Step

Start:

**Phase Q — Secure Member Management & Invitation Backend**

First step:

**Step Q1 — Audit Company Members Management Requirements**

Review:

- `company_members` table columns
- current `CompanyUsersRepo`
- current `CompanyUsersCubit`
- current `CompanyUsersSection`
- current RLS policies on `company_members`
- existing RPCs:
  - `accept_company_invitation`
  - `cancel_company_invitation`

Expected output:

- Define exact member lifecycle rules.
- Define who can change which role.
- Define last-owner protection rules.
- Define required RPCs.
- Define UI controls for Owner/Admin.