# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

Latest verified pushed **code** commit:

`575967c939248ad36e52040b6e2c9017ab549554`

Commit message:

`fix(auth): guard direct auth routes without email`

This roadmap is the single source of truth for the Mina System project.

It is based on the real GitHub repository, not the README.

Current high-level state:

- Current product phase:
  - **Phase R — Business Accountability & Audit Trail**
- Current product checkpoint:
  - **Phase R — Business Accountability & Audit Trail**
- Current parallel engineering checkpoint:
  - **None (Completed)**

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
- Do not split files only to reduce line count; split only when responsibilities are mixed or maintainability clearly improves.
- Large but cohesive files may remain as-is when splitting them would create unnecessary fragmentation.
- During maintainability refactors, preserve the current UI, workflow, permissions, validation, and business logic unless an explicitly approved bug fix or rule change is part of the batch.
- When changing existing files during guided development, provide complete file replacements when requested.
- Keep implementation scalable and maintainable.
- Start with simple fixed-role permissions, but keep the structure ready for future custom permission overrides.
- Prefer completing one coherent feature/checkpoint before opening a different large area.
- Avoid mixing unrelated architecture changes inside the same checkpoint.

After each completed feature or major checkpoint:

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
- If a Cubit intentionally preserves search state across navigation, the visible search field must restore the same query when the screen is rebuilt.
- If the backend loads a list in a defined order, local add/update state should preserve the same order unless a product decision explicitly changes sorting behavior.
- Long scrollable screens that rebuild after mutations should preserve scroll position when practical.

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

## Data Quality Rules

- HR Code remains the technical unique identifier for workers.
- Worker names must also remain unique inside the same company in the current app flow to prevent accidental duplicate worker records.
- Worker-name duplicate comparison uses Unicode-safe normalization.
- Current worker-name duplicate normalization ignores:
  - Case differences
  - Extra spaces
  - Separators and punctuation such as spaces, hyphens, dots, underscores, slashes, and commas
- Examples treated as the same normalized worker name:
  - `Ahmed Ali`
  - `ahmed ali`
  - `AHMED   ALI`
  - `Ahmed-Ali`
  - `Ahmed.Ali`
  - `Ahmed_Ali`
  - `Ahmed/Ali`
  - `Ahmed, Ali`
- If two real workers genuinely share the same apparent name, the entered name should be made more complete or more specific so both records remain clearly distinguishable.
- Worker-name duplicate protection is currently enforced in:
  - Form validation
  - In-memory helper validation
  - Cubit add flow
  - Cubit update flow
  - Repository backend checks
- Future hardening consideration:
  - Decide later whether production requires an additional database-level unique protection for normalized worker names.

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
- Dedicated `Team` area is implemented for company users and member lifecycle management.
- Company user management has been moved out of `Settings`.
- `Team` navigation is role-aware:
  - Owner/Admin can access Team.
  - Warehouse Manager can access Team without gaining Settings access.
  - Warehouse User/Viewer cannot access Team.
- Flutter member lifecycle flow is wired through Repo, Cubit, and UI for:
  - `deactivateCompanyMember`
  - `reactivateCompanyMember`
- Responsive member lifecycle UI is implemented for:
  - Change Role
  - Deactivate
  - Reactivate
- Team UI uses silent refresh after mutations instead of rebuilding the full section.
- Team action buttons use per-action loading instead of global button loading.
- Team success messages are action-specific, and invite form reset happens only after successful invitation creation.
- Manual lifecycle UI testing completed for:
  - Owner
  - Admin
  - Warehouse Manager
- Multi-company inactive-membership behavior was manually verified:
  - If a user is deactivated from one company but still has another active company, the app opens the remaining active company automatically.
  - Company switching disappears when only one active company remains.
- Tools now preserve alphabetical order after load/add/update.
- Workers now preserve alphabetical order after load/add/update.
- Worker names are protected against duplicate normalized names inside the same company through local and repository checks.
- Visible search-query state remains synchronized after navigation for:
  - Tools
  - Workers
  - Transactions
  - Custody Balance
  - Tool Summary

## Recently Completed Maintainability / Stability Work

### Batch 1 — Company Users UI Modularization

Completed.

- `company_users_section.dart` was reduced by extracting focused UI/helper files:
  - `company_users_helpers.dart`
  - `company_users_dialogs.dart`
  - `invite_company_user_form.dart`
  - `company_members_list.dart`
  - `company_invitations_list.dart`

### Batch 2 — Company Users Cubit + Pending Invitations Modularization

Completed.

- `company_users_cubit.dart` was split into focused part files:
  - `company_users_cubit_members.dart`
  - `company_users_cubit_invitations.dart`
- `pending_company_invitations_screen.dart` was reduced by extracting:
  - `pending_company_invitation_card.dart`
  - `pending_invitations_views.dart`

### UX Fix — Team Scroll Preservation

Completed.

- Team page scroll position is preserved after:
  - Change Role
  - Deactivate
  - Reactivate
- Implemented with `PageStorageKey`.

### Batch 3 — Company Settings Modularization

Completed.

- `company_settings_cubit.dart` was split into:
  - `company_settings_cubit_profile.dart`
  - `company_settings_cubit_reports.dart`
  - `company_settings_cubit_documents.dart`
- `company_report_settings_form.dart` was split into:
  - `report_settings_format_fields.dart`
  - `report_settings_visibility_switches.dart`
  - `report_settings_statement_fields.dart`
- `document_template_card.dart` was split into:
  - `document_template_general_fields.dart`
  - `document_template_signature_fields.dart`
- `company_settings_screen.dart` now preserves scroll position using `PageStorageKey`.

### Batch 4 — Current Context Modularization

Completed.

- `current_context_gate.dart` was reduced by extracting:
  - `current_context_loading_view.dart`
  - `current_context_offline_view.dart`
  - `current_context_failure_view.dart`
- `select_company_screen.dart` was reduced by extracting:
  - `company_selection_list.dart`
  - `pending_company_invitations_section.dart`
- Existing `PendingCompanyInvitationCard` was reused instead of duplicated.
- `current_context_cubit.dart` was intentionally left unchanged because it remained cohesive.

### Batch 5 — Tools Cubit Modularization + State Consistency

Completed.

- `tools_cubit.dart` was split into:
  - `tools_cubit_add.dart`
  - `tools_cubit_update.dart`
  - `tools_cubit_delete.dart`
- `add_edit_tool_form.dart` was intentionally left unchanged because it remained cohesive.
- Added centralized alphabetical ordering:
  - `sortToolsAlphabetically`
- `emitUpdatedTools(...)` now preserves alphabetical order after load/add/update.
- Fixed visible search-state desynchronization in Tools:
  - Preserved Cubit query state is now visibly restored in the search field after navigation.

### Cross-Feature Search-State Fix

Completed.

- Visible query state is now restored correctly after navigation for:
  - Workers
  - Transactions
  - Custody Balance
  - Tool Summary
- Search fields now remain visually synchronized with Cubit state instead of appearing empty while the list stays filtered.

### Batch 6 — Workers Cubit Modularization + Data Quality Hardening

Completed.

- `workers_cubit.dart` was split into:
  - `workers_cubit_add.dart`
  - `workers_cubit_update.dart`
  - `workers_cubit_delete.dart`
- `add_worker_form.dart` was intentionally kept as a cohesive form instead of being fragmented for line-count reasons.
- Added centralized alphabetical ordering:
  - `sortWorkersAlphabetically`
- `emitUpdatedWorkers(...)` now preserves alphabetical order after load/add/update.
- Added strong normalized duplicate worker-name prevention inside the same company.
- Worker-name duplicate prevention now covers:
  - Form validation
  - In-memory helper validation
  - Cubit add flow
  - Cubit update flow
  - Repository backend checks

---

# Current Active Product Phase

## Auth UX Checkpoint — Email-First Authentication Flow

Status:

**In Progress**

Goal:

Replace the current ambiguous register-first behavior with a clearer SaaS-style authentication entry flow.

Completed in current checkpoint:

- **Email Entry Route:** Added safe Email Entry screen at `/` as the unauthenticated entry route using `AppValidators.validateEmail`.
- **Safe Choice Step:** Added client-side choice wizard (without calling Supabase or revealing account existence) offering 'I already have an account' and 'Create a new account' options, strictly avoiding account-enumeration risks.
- **Prefilled & Locked Forms:** Integrated validated, read-only email passing to `/login` and `/register` via GoRouter state extra.
- **Direct Route Guards:** Implemented robust routing guards to automatically redirect direct unauthenticated access attempts on `/login` or `/register` back to `/` unless a valid email is passed.
- **Logout Behavior:** Adjusted logout behaviors to route back to Email Entry screen.
- **No backend account-existence detection was added (deferred to Phase S).**

Current product checkpoint:

**Auth UX Checkpoint — Email-First Authentication Flow**

Planned Safe UX:

1. User first enters only email.
2. App continues to a safe email-first choice step without revealing whether the email already has an account (to avoid account-enumeration risk).
3. User chooses:
   - I already have an account (goes to Login screen with email prefilled and locked).
   - Create a new account (goes to Register screen with email prefilled and locked).
4. CurrentContextGate and pending company invitation behavior remain unchanged after successful authentication.
5. True backend account-existence detection is deferred to a later secure Auth Security / Phase S checkpoint where Edge Functions, rate limiting, abuse protection, logs, and possible captcha can be designed properly. No public unauthenticated check_account_exists(email) RPC should be implemented in this checkpoint.

Reason for priority:

- Current Supabase signup behavior may return an obfuscated/fake user object for an already registered email under some auth-confirmation settings.
- The current product UX should become clearer and more professional.
- Mina System uses one account with multi-company membership, so email-first flow matches the product model better than separate blind register/login paths.

---

# Current Active Engineering Checkpoint

## Maintainability Refactor Pass — Post-Batch-6 Audit

Status:

**Completed**

Goal:

Improve readability and future maintainability of large files without changing approved product behavior unless a separately approved bug fix or rule change is included.

Completed in this checkpoint:

- Batch 1 — Company Users UI modularization
- Batch 2 — Company Users Cubit + pending invitations modularization
- Team scroll-preservation fix
- Batch 3 — Company Settings modularization
- Batch 4 — Current Context modularization
- Batch 5 — Tools Cubit modularization + sorting/search-state fixes
- Cross-feature search-state fix
- Batch 6 — Workers Cubit modularization + sorting + normalized unique worker names
- **Post-Batch-6 Maintainability & Scalability Audit:** Centralized scattered PDF colors and styles successfully under `lib/core/theme/app_pdf_colors.dart` and `lib/core/theme/app_pdf_text_styles.dart` without modifying normal Flutter UI themes or changing visual presentation. Verified quality with clean `flutter analyze` report.

Known decisions from the checkpoint:

- Leave cohesive large files unchanged when splitting would add fragmentation without real maintainability value.
- Current examples intentionally left cohesive:
  - `current_context_cubit.dart`
  - `add_edit_tool_form.dart`
  - `add_worker_form.dart`
- Prefer feature-by-feature refactors.
- Prefer part-file extensions for large Cubits when mutation flows are genuinely separate.
- **No Batch 7 required:** The codebase has reached a practical maintainability and scalability standard for the current product stage. Future refactors should only be opened when tied to real product or maintenance value, rather than line-count reduction alone.
- **Verification:** PDF visual review passed, `dart format lib` completed successfully, and `flutter analyze` reported no issues.

---

# Recommended Execution Order

This order puts core SaaS/product requirements first, and keeps improvements/enhancements for later.

## Priority 1 — Must-Have Product Foundation

1. **Phase O — Company Users, Roles & Invitations** ✅
2. **Phase P — Role-Based Access Control** ✅
3. **Phase Q — Secure Member Management & Invitation Backend** ✅
4. **Auth UX Checkpoint — Email-First Authentication Flow** ✅
5. **Phase R — Business Accountability & Audit Trail** 🚧
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

## Delivered capabilities

- Owner/Admin can invite users by email.
- Invited users can see pending invitation details.
- Invited users can accept invitations and join a company through secure RPC flow.
- Membership is stored in `company_members`.
- Company role is connected to current context.
- App loads companies and roles from membership data.
- Duplicate pending invitations are blocked.
- Invitations to already active members are blocked.
- Pending invitations can be cancelled.

## Important implementation results

- Added `warehouse_manager` role support.
- Added `company_invitations` structure and supporting invitation status model.
- Added secure RPCs for:
  - `accept_company_invitation`
  - `cancel_company_invitation`
- Added models for:
  - Company members
  - Company invitations
  - Invite requests
- Added `CompanyUsersRepo`, `CompanyUsersCubit`, and Company Users UI foundation.
- Added no-company invitation handling through `CurrentContextGate`.
- Added the pending-invitation screen and successful acceptance flow.

## Important security behavior

- Flutter does not use service role keys.
- Flutter does not call Admin Auth methods directly.
- Users cannot insert themselves into arbitrary companies.
- Invitation acceptance/cancellation runs through backend-controlled RPCs.

## Items intentionally deferred from Phase O

- Change member role — completed in Phase Q.
- Deactivate/reactivate member — completed in Phase Q.
- Remove member access — still future scope.
- Prevent last owner deactivation/removal — deactivation protected now; future remove/transfer flow still needs dedicated safeguards.
- Audit logs for member lifecycle actions — planned in Phase R.
- Invitation email delivery — deferred to Phase S.
- Production invitation email backend / Edge Function — deferred to Phase S.

---

# Phase P — Role-Based Access Control

## Status: Done

## Goal

Restrict app actions based on the current user's company role.

## Role model implemented

- `owner`
- `admin`
- `warehouse_manager`
- `warehouse_user`
- `viewer`

## Delivered capabilities

- Central permission helper structure through `CompanyRolePermissions`.
- Navigation filtered by current company role.
- Screen and action permissions enforced in Flutter UI.
- Supabase public-table write policies aligned with the fixed-role matrix.
- Supabase Storage upload policies aligned with the fixed-role matrix.
- Manual testing completed across all implemented roles.

## Current role behavior summary

### Owner

Full access to currently implemented features.

### Admin

Near-owner access to currently implemented features, but not future owner-only actions such as ownership transfer, delete company, or owner-level billing control.

### Warehouse Manager

Can manage operational data and workflows, including workers, tools, lookups, transactions, approvals, settlements, and reports.

After Phase Q decisions, Warehouse Manager can also manage Team lifecycle access for lower roles only through the dedicated `Team` area.

### Warehouse User

Can use operational flows allowed by the current product design, including transaction creation and proof upload, but cannot manage settings, team, approvals, or master-data mutations.

### Viewer

Read-only access limited to allowed areas.

## Security rule carried forward

UI restrictions are not enough on their own.

Every role-sensitive mutation must also be protected at database or storage-policy level.

## Phase P documentation

Created:

- `docs/supabase/phase_p_rbac_policies.md`

---

# Phase Q — Secure Member Management & Invitation Backend

## Status: Done (Closed)

## Goal

Harden company-user management beyond the Phase O foundation by moving sensitive lifecycle behavior into secure backend logic and preparing a cleaner production-ready Team architecture.

This phase covers:

- Secure invitation creation
- Multi-company invitation/workspace flows
- Secure role changes
- Secure deactivate/reactivate lifecycle operations
- Team architecture
- Member lifecycle UI
- Future audit readiness for member actions
- Invitation email delivery scope decision

## Confirmed lifecycle rules

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
- No normal member-management flow can:
  - Assign Owner
  - Change own role
  - Change Owner role
  - Bypass hierarchy protections

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

- `private.is_company_member(...)` requires active membership.
- `private.has_company_role(...)` requires active membership.

Inactive members therefore lose effective company access at database level.

## Completed implementation

### Step Q1 — Member Lifecycle Audit

Completed.

Confirmed required backend protections, hierarchy rules, ownership protections, multi-company impacts, and UI ownership between Settings and Team.

### Step Q2 — Secure Invitation Creation Backend

Completed.

Implemented secure RPC:

- `invite_company_user(uuid, text, text)`

Important results:

- Flutter moved from direct insert to secure RPC path.
- Direct authenticated insert access to `company_invitations` was closed.
- Duplicate pending invitation and active-member protections were preserved.

### Step Q2A — Multi-Company Invitation & Workspace Flow

Completed.

Implemented:

- Additional-company invitations for existing users
- Separate current-user invitation loading
- `SelectCompanyScreen`
- Persistent last-selected company storage per profile
- Manual `Switch Company` action
- Post-acceptance workspace selection flow for users with multiple companies

### Step Q3 — Secure Member Role Change

Completed.

Implemented secure RPC:

- `change_company_member_role(uuid, uuid, text)`

Direct DB security tests passed for hierarchy, self-protection, and owner protection.

Flutter repo/cubit/UI flow was connected.

### Step Q4 — Secure Member Deactivation & Reactivation Backend

Completed.

Implemented secure RPCs:

- `deactivate_company_member(uuid, uuid)`
- `reactivate_company_member(uuid, uuid)`

Direct DB security tests passed for:

- Admin hierarchy
- Warehouse Manager hierarchy
- Self-deactivation prevention
- Owner protection
- Same-level management blocking

### Step Q4.7 — Team Access Refactor & Member Lifecycle UI

Completed.

Implemented:

- Dedicated `Team` area
- Company user management moved out of `Settings`
- Role-aware Team navigation
- Warehouse Manager lifecycle access for lower roles only
- Repo/Cubit/UI wiring for:
  - Change Role
  - Deactivate
  - Reactivate
- Silent refresh after mutations
- Per-action loading
- Action-specific success messages
- Manual UI testing for:
  - Owner
  - Admin
  - Warehouse Manager
- Multi-company inactive-membership behavior verified

### Step Q4.8 — Decide Invitation Email Delivery Scope

Completed.

Decision:
- **Defer real invitation email delivery to Phase S (Production Environment & Secrets Setup).**
- Phase Q retains the highly secure **in-app invitation flow** only (invitations are managed, accepted, and cancelled safely through the pending invitation flow and backend RPCs).
- Establishing a real email provider, Supabase Edge Functions, email templates, custom domain verification, resend behaviors, and email error handling is production-readiness work that does not block core product features.

Status of Remaining Phase Q items:
- **Decide invitation email delivery scope:** Completed (deferred to Phase S).
- **Decide future remove-access strategy:** Completed. Soft deactivate is sufficient for now; full removal can be introduced later if business necessity dictates.
- **Preserve future last-owner protections:** Transferred as a design rule to future ownership transfer/removal features.
- **Prepare Phase R audit integration:** Transferred as a required target mapping for Phase R (Business Accountability & Audit Trail).

Recommendation:
- All currently scoped Phase Q deliverables have been implemented and the remaining email-delivery work has been deferred to Phase S. **Phase Q was formally closed following the Step Q4.8 decision.**

---

# Auth UX Checkpoint — Email-First Authentication Flow

## Status: Done (Final Polish Completed)

## Goal

Replace the current ambiguous register-first behavior with a clearer SaaS-style authentication entry flow.

## Completed Foundation Steps

- **Email Entry Route:** Added safe Email Entry screen at `/` as the unauthenticated entry route using `AppValidators.validateEmail`.
- **Safe Choice Step:** Added client-side choice wizard (without calling Supabase or revealing account existence) offering 'I already have an account' and 'Create a new account' options, strictly avoiding account-enumeration risks.
- **Prefilled & Locked Forms:** Integrated validated, read-only email passing to `/login` and `/register` via GoRouter state extra.
- **Direct Route Guards:** Implemented robust routing guards to automatically redirect direct unauthenticated access attempts on `/login` or `/register` back to `/` unless a valid email is passed.
- **Logout Behavior:** Adjusted logout behaviors to route back to Email Entry screen.
- **No backend account-existence detection was added (deferred to Phase S).**

## Final Verification Note

- **Final Polish Review:** Passed with zero issues.
- **Static Analysis & Formatting:** `dart format lib` and `flutter analyze` completed with no warnings/errors.

## Planned Safe UX

1. User first enters only email.
2. App continues to a safe email-first choice step without revealing whether the email already has an account. This avoids any account-enumeration risk.
3. User chooses:
   - I already have an account (routes to Login screen with email prefilled and locked).
   - Create a new account (routes to Register screen with email prefilled and locked).
4. CurrentContextGate and pending company invitation behavior remain unchanged after successful authentication.
5. True backend account-existence detection is deferred to a later secure Auth Security / Phase S checkpoint where Edge Functions, rate limiting, abuse protection, logs, and possible captcha can be designed properly.

## Security Constraints & Design Rules

- **No Public RPC:** Do not implement a public, unauthenticated `check_account_exists(email)` RPC in this checkpoint. We must strictly avoid account-enumeration risk.
- **Backend Architecture:** Supabase remains the backend; future secure checks should use server-side Supabase capabilities such as Edge Functions, not Flutter client logic.

## Reason for checkpoint

- The current product UX should become clearer and more professional.
- Mina System uses one account with multi-company membership, so email-first flow matches the product model better than separate blind register/login paths.
- Preparing the step-by-step layout split (Email Entry -> Choice/Form) builds the UX foundation for future server-side checks.

## Likely technical direction

- Build a stateful, interactive step-by-step wizard or router flow in Flutter.
- Cache the entered email locally during the login/registration sub-flows.
- Disable and lock the email input fields on both login and register screens once navigated from the entry step.
- Integrate invitation-aware guidance into auth copy and routing.

---

# Phase R — Business Accountability & Audit Trail

## Status: In Progress

## Goal

Add direct user accountability and historical audit logging for important business actions.

## Planned scope

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

## Planned scope

- Separate development and production Supabase projects.
- Secure environment handling.
- No hardcoded secrets in client code.
- Build configuration cleanup.
- Production storage review.
- Production auth/site URL review.
- Production email/redirect review.
- **Invitation email delivery integration:** Setup an SMTP/email delivery provider, secure backend Edge Functions, invitation email templates, custom sender verification, and resend/error handling.
- Release-safe configuration documentation.

---

# Phase T — Subscription Plans, Usage Limits & Company Access Control

## Status: Planned

## Goal

Turn Mina System into a scalable SaaS product with company-level subscription control.

## Planned scope

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

## Planned scope

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

## Planned scope

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

## Planned scope

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

## Planned scope

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

## Planned scope

- Storage usage per company.
- Approximate image/PDF size tracking.
- Quota visibility.
- Limit enforcement integration with subscription plans.

---

# Phase Z — Advanced Reports & PDF Enhancements

## Status: Planned

## Goal

Expand reporting power and polish generated documents.

## Planned scope

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

## Planned scope

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

## Planned scope

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

## Planned scope

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

## Planned scope

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

## Planned scope

- Installer packaging.
- Update strategy.
- Download page integration.
- Desktop release instructions.

---

# Phase AF — Advanced Analytics

## Status: Planned

## Goal

Add deeper operational analysis after core product maturity.

## Planned scope

- Usage trends.
- Worker/tool patterns.
- Company-level analytics.
- Exportable management insights.

---

# Phase AG — Custom Permission Overrides

## Status: Planned

## Goal

Support more flexible permissions beyond fixed roles.

## Planned scope

- Base role permissions.
- Extra allow permissions.
- Explicit deny permissions.
- User-specific overrides.
- Future UI for custom access management.
- Must preserve existing fixed-role compatibility.

---

# Future Hardening / Follow-Up Items

These items are intentionally not forgotten even when they are not the current active step:

- **Invitation email delivery & production backend (SMTP / Edge Functions)** — deferred from Phase Q to Phase S.
- Future remove-access flow if business need becomes clear.
- Last-owner protections for future ownership transfer/remove-access flows.
- Direct accountability and audit trail implementation.
- Auth UX email-first checkpoint.
- Production/dev environment split and secret handling.
- Subscription plans, feature gating, usage limits, and storage limits.
- Store/release preparation, demo account, and production data safety.
- Basic audit log screen after audit data exists.
- Mobile/tablet camera capture with file-picker fallback.
- Storage usage tracking.
- Advanced reports and PDF enhancements.
- Dashboard enhancements.
- Offline drafts and background sync.
- Notifications.
- Web landing page / customer portal.
- Desktop installer distribution.
- Advanced analytics.
- Custom permission overrides.
- Decide later whether normalized worker-name uniqueness also needs database-level enforcement in production.

---

# Current Next Action

- Begin **Phase R — Business Accountability & Audit Trail** to add direct user accountability and historical audit logging for important business actions.