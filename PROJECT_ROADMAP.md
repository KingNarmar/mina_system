# Mina System — Project Roadmap

## Project Name

**Mina System**

**Materials Inventory Navigation Assistant**

---

## Roadmap Purpose

This document is now a **completed-state snapshot** for Mina System.

It records:

- What has already been completed.
- The latest verified project state.
- The stable engineering/security/product rules that must continue to guide development.

This document is **not** the practical backlog anymore.

From now on:

- **GitHub Issues** are the practical backlog.
- **GitHub Project** is the execution board.
- `PROJECT_ROADMAP.md` should be updated only after major completed checkpoints, major architectural decisions, or important strategic changes.

---

## Source of Truth

The current source of truth is split clearly:

### Completed State / Strategic Rules

Stored in:

- `PROJECT_ROADMAP.md`

### Practical Backlog / Next Work

Tracked in:

- GitHub Issues
- GitHub Project board

### Important Rule

If an old README, old note, or old roadmap section conflicts with the real code, current Supabase state, GitHub Issues, or GitHub Project:

**The real repo + current GitHub Issues + current GitHub Project win.**

---

## Latest Verified State

Latest verified pushed code commit:

`ebca7f55396793e1343d7ec3348be5335fd4fc70`

Commit message:

`fix(transactions): store proof images under official TRX paths`

Current product phase:

**Phase R — Business Accountability & Audit Trail**

Current completed checkpoint:

**Step R6-G.1 — Replace `pending-*` transaction proof paths with official `TRX-*` paths**

Status:

**Completed, verified, pushed, documented, and GitHub Issue #1 closed as completed**

Related GitHub Issue:

- `#1 Step R6-G.1: Replace pending proof image paths with official TRX paths`

Completed in this checkpoint:

- Reviewed GitHub Issue #1.
- Reviewed the real transaction creation flow.
- Confirmed the old problem:
  - Proof images were uploaded before the backend returned the official transaction code.
  - This caused new proof image paths to use temporary `pending-*` folders.
- Added secure Supabase RPC:
  - `upload_transaction_proof_image`
- Updated Supabase RPC:
  - `create_custody_transaction`
- Added deferred proof image upload support through:
  - `p_defer_proof_image_upload boolean`
- Replaced the old transaction proof image check constraint with:
  - `transactions_proof_image_path_official_trx_format`
- Updated Flutter transaction creation flow to:
  - Create the transaction first.
  - Read the official backend-generated `TRX-*` transaction code.
  - Upload the proof image under the official `TRX-*` folder.
  - Save the uploaded proof image path through secure RPC.
- Removed the old `pending-*` path behavior from Flutter code.
- Preserved image compression behavior.
- Preserved network/offline validation behavior.
- Preserved secure RPC-only transaction mutation flow.
- Added Supabase SQL documentation:
  - `docs/supabase/r6_g_1_transaction_proof_trx_paths.sql`
- Manually tested creating an issue transaction with proof image.
- Confirmed the new proof image path uses official `TRX-*` folder.
- Confirmed the new proof image path no longer uses `pending-*`.
- Ran:
  - `dart format lib`
- Ran:
  - `flutter analyze`
- `flutter analyze` result:
  - **No issues found**
- Ran:
  - `findstr /s /n /i "pending-" lib\*.dart`
- `pending-*` search result:
  - **No results found in Flutter code**
- Commit was pushed to `main`.
- GitHub Issue #1 was closed as completed.

Manual verification result:

- New test transaction:
  - `TRX-00065`
- Proof image path format:
  - `{companyId}/transactions/TRX-00065/proof-...png`
- `uses_official_trx_path`:
  - `true`
- `still_uses_pending_path`:
  - `false`

---

# Completed Product State Snapshot

## Core Foundation

Completed:

- Authentication flow is working.
- Current Context flow is working.
- Create Company flow is working.
- Company Settings core foundation is working.
- Multi-company workspace selection is implemented.
- Last selected workspace behavior is implemented.
- Manual `Switch Company` action is visible and working.
- App navigation is filtered by current company role.
- DevicePreview has a separate entry point.
- Normal runtime layout no longer depends directly on DevicePreview.

---

## Company / Team / Permissions Foundation

Completed:

- Company Users foundation is implemented.
- Company invitation table, grants, RLS policies, and invitation RPCs are implemented.
- Owner/Admin can invite users by email.
- Pending invitations can be listed and cancelled.
- Invited users can see company invitation details before joining.
- Invited users can accept invitations and join the company.
- Accepted users appear in Company Users with assigned role.
- Duplicate pending invitations are blocked.
- Duplicate active-member invitations are blocked at database level.
- Role-based UI permissions are implemented.
- Workers/Tools/Transactions/Lookups/Reports/Settings actions are restricted by role in Flutter UI.
- Supabase public table RLS write policies are aligned with the implemented RBAC matrix.
- Supabase Storage upload policies are aligned with the implemented RBAC matrix.
- Secure invitation creation backend is implemented through:
  - `invite_company_user`
- Direct authenticated insert access to `company_invitations` is closed.
- Dedicated `Team` area is implemented for company users and member lifecycle management.
- Company user management has been moved out of `Settings`.

Current roles:

- `owner`
- `admin`
- `warehouse_manager`
- `warehouse_user`
- `viewer`

Current member management hierarchy:

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
- Same-level roles unless explicitly allowed by backend logic
- Higher-level roles

---

## Workers Foundation

Completed:

- Workers are Supabase-backed.
- Worker create/update/deactivate/reactivate flows use secure RPCs.
- Direct authenticated insert/update/delete access to `workers` is closed.
- Workers UI supports active/inactive filtering.
- Worker deactivate/reactivate behavior is implemented.
- Worker open-custody blocking was tested.
- Reports can select active and inactive workers without depending on current screen filters.
- Worker-name duplicate protection is implemented.
- Worker-name duplicate comparison uses Unicode-safe normalization.
- Workers preserve alphabetical order after load/add/update.
- Worker model resolves created/updated profile display names and emails.
- Worker mobile cards display direct accountability.
- Worker desktop details dialog displays direct accountability.
- Worker cards and tables include `View Audit History`.

Worker duplicate protection is enforced in:

- Form validation
- In-memory helper validation
- Cubit add flow
- Cubit update flow
- Repository backend checks

---

## Tools Foundation

Completed:

- Tools are Supabase-backed.
- Tool create/update/deactivate/reactivate flows use secure RPCs.
- Direct authenticated insert/update/delete access to `tools` is closed.
- Tools UI supports active/inactive filtering.
- Tool deactivate/reactivate behavior is implemented.
- Tool open-custody blocking was tested.
- Reports can select active and inactive tools without depending on current screen filters.
- Tools preserve alphabetical order after load/add/update.
- Tool model resolves created/updated profile display names and emails.
- Tool mobile cards display direct accountability.
- Tool desktop details dialog displays direct accountability.
- Tool cards and tables include `View Audit History`.

---

## Transactions Foundation

Completed:

- Transactions are Supabase-backed.
- Transaction creation uses secure Supabase RPC:
  - `create_custody_transaction`
- Official `transaction_code` is generated by backend.
- Transaction creation derives actor profile from backend authenticated context.
- Flutter no longer sends trusted transaction creation accountability fields.
- General transaction editing is disabled.
- `TransactionsRepo.updateTransaction()` throws `UnsupportedError`.
- `TransactionsCubit.updateTransaction()` returns false with a clear user-facing message.
- Transaction mutations go through controlled RPC workflows only.
- Direct authenticated insert/update access to `public.transactions` is closed.
- Transaction details display direct accountability.
- Transaction details include `View Audit History`.
- Transaction audit actions display readable labels.
- Transaction proof image upload now stores new proof images under official `TRX-*` paths.
- New proof images no longer use `pending-*` paths.
- Transaction proof images are compressed before upload.
- Transaction proof image upload preserves offline/network validation behavior.
- Transaction proof image path saving uses secure RPC:
  - `upload_transaction_proof_image`

Controlled transaction workflows currently include:

- Create transaction RPC.
- Upload transaction proof image RPC.
- Upload approval document RPC.
- Approve lost/damaged transaction RPC.
- Reject lost/damaged transaction RPC.
- Settle lost/damaged transaction RPC.

---

## Lost / Damaged Approval & Settlement Workflow

Completed:

- Lost/Damaged approval workflow uses secure RPCs:
  - `approve_lost_damaged_transaction`
  - `reject_lost_damaged_transaction`
  - `settle_lost_damaged_transaction`
- Flutter no longer sends:
  - `decidedByProfileId`
  - `settledByProfileId`
- Approval/rejection/settlement actors are derived from authenticated backend context.
- Signed approval document upload uses secure RPC:
  - `upload_transaction_approval_document`
- Flutter uploads approval documents to Supabase Storage.
- Backend writes approval document accountability fields.
- Lost/Damaged approval document upload was manually tested.
- Lost/Damaged approve workflow was manually tested.
- Lost/Damaged settle workflow was manually tested.
- Lost/Damaged reject workflow was manually tested.

---

## Reports / PDF Foundation

Completed:

- Reports/PDF core reports are working.
- Reports use real Supabase data.
- Reports can select active and inactive Workers/Tools without depending on current screen filters.
- PDF colors are centralized under:
  - `lib/core/theme/app_pdf_colors.dart`
- PDF text styles are centralized under:
  - `lib/core/theme/app_pdf_text_styles.dart`
- Reports/PDF use report/company timezone.

---

## Dashboard Foundation

Completed:

- Dashboard reads real Supabase data.
- Dashboard is connected to current company context.

---

## Lookups Foundation

Completed:

- Lookups are Supabase-backed.
- Lookup resolver is implemented for audit foreign key display names.
- Audit History can resolve:
  - Worker Department
  - Worker Job Title
  - Tool Unit
  - Tool Category

---

# Phase R — Business Accountability & Audit Trail

Status:

**In Progress**

This phase tracks completed accountability, audit, secure transaction, and storage-path work.

Future Phase R work is no longer listed in this document as a backlog. It is tracked through GitHub Issues and GitHub Project.

---

## Completed Phase R Checkpoints

Completed:

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
- Step R6-G.1 — Replace `pending-*` transaction proof paths with official `TRX-*` paths

---

## Step R1 — Transactions Backend Alignment

Status:

**Completed**

Completed:

- Transaction creation uses secure Supabase RPC:
  - `create_custody_transaction`
- Official `transaction_code` is generated by backend.
- `created_by_profile_id` is derived from:
  - `private.current_profile_id()`
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
- Flutter no longer sends approval/settlement actor IDs directly.
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
- Transaction changes are routed through controlled workflows only.

---

## Step R4 — Workers & Tools Accountability

Status:

**Completed**

Completed:

- Workers and Tools accountability fields were added.
- Secure backend RPCs were added for Workers.
- Secure backend RPCs were added for Tools.
- Flutter Workers create/update flow uses secure RPCs.
- Flutter Tools create/update flow uses secure RPCs.
- Direct authenticated insert/update/delete access was revoked from:
  - `workers`
  - `tools`
- Workers and Tools active/inactive lifecycle flows are implemented.
- Open custody blocking was tested and passed.

---

## Step R5 — Audit Logs Foundation

Status:

**Completed and manually verified**

Completed:

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
- Audit logs are append-only from perspective of normal app users.

---

## Step R5.5 — Company Timezone Setting Foundation

Status:

**Completed**

Completed:

- `companies.timezone` was added in Supabase.
- Existing companies can default to:
  - `Asia/Dubai`
- `create_company_with_defaults` accepts:
  - `p_timezone`
- New company report settings seed `default_timezone` from selected company timezone.
- Flutter uses the `timezone` package.
- Timezone database initialization was added in:
  - `main.dart`
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
- Audit History UI uses company timezone.
- Worker and Tool accountability displays use company timezone.
- Transaction accountability display uses company timezone.

---

## Step R6-A — Audit Logs Flutter Model & Repository Foundation

Status:

**Completed**

Completed:

- Audit Log Flutter model is implemented.
- Audit Logs repository is implemented.
- Audit logs can be loaded by entity.
- Recent audit logs can be loaded by company.

---

## Step R6-B — Audit Logs Cubit & State Foundation

Status:

**Completed**

Completed:

- Audit Logs Cubit is implemented.
- Audit Logs State is implemented.
- Loading, success, and error states are supported.

---

## Step R6-C — Audit History UI Foundation

Status:

**Completed**

Completed:

- Audit History Bottom Sheet is implemented.
- Audit Log tile is implemented.
- Audit Log data change section is implemented.
- Audit History displays readable action labels.
- Audit History displays actor name/email snapshot.
- Audit History timestamps use company timezone.
- Audit History shows old vs new values in readable format.

---

## Step R6-C.2 — Resolve Audit Foreign Key Display Names

Status:

**Completed**

Completed:

- Lookup resolver is implemented.
- Worker Department and Job Title display as readable names instead of UUIDs.
- Tool Unit and Category display as readable names instead of UUIDs.
- Safe fallback labels are used where lookup values cannot be resolved.

---

## Step R6-D — Connect Audit History to Workers & Tools

Status:

**Completed**

Completed:

- Worker Audit History helper functions are implemented.
- Tool Audit History helper functions are implemented.
- Worker cards and tables include `View Audit History`.
- Tool cards and tables include `View Audit History`.
- Audit History was manually tested for Workers.
- Audit History was manually tested for Tools.

---

## Step R6-E.1 — Resolve Created/Updated Profile Display Names for Workers & Tools

Status:

**Completed**

Completed:

- Worker model resolves created/updated profile display names and emails.
- Tool model resolves created/updated profile display names and emails.
- Workers repository joins `profiles`.
- Tools repository joins `profiles`.

---

## Step R6-E.2 — Display Direct Accountability in Worker & Tool Mobile Cards

Status:

**Completed**

Completed:

- Reusable `RecordAccountabilitySection` was added:
  - `lib/core/widgets/record_accountability_section.dart`
- Worker mobile cards display direct accountability.
- Tool mobile cards display direct accountability.
- Timestamps use company timezone.

---

## Step R6-E.3 — Add Worker/Tool Accountability Details for Desktop

Status:

**Completed**

Completed:

- Worker desktop details dialog displays direct accountability.
- Tool desktop details dialog displays direct accountability.
- Desktop tables remain clean without adding dense accountability columns.

---

## Step R6-F — Transaction Accountability Details Display

Status:

**Completed**

Completed:

- Transaction backend accountability fields are completed.
- Transaction controlled RPC workflows write actor snapshots and audit logs.
- Direct authenticated table insert/update access to `public.transactions` is closed.
- Transaction Details displays direct accountability.
- Transaction Details includes `View Audit History`.
- Transaction audit actions display readable labels.
- Transaction accountability fields displayed correctly in Transaction Details.
- Transaction Audit History displayed created/uploaded/approved/settled/rejected events.

---

## Post R6-F Cleanup — Remove Temporary Transaction Debug Prints

Status:

**Completed and pushed**

Completed:

- Removed temporary `print` statements from `TransactionsCubitCrud.addTransaction`.
- Kept production user-facing error handling unchanged.
- Kept guarded `kDebugMode` debug logs in other areas unchanged.
- Ran:
  - `dart format lib`
- Ran:
  - `flutter analyze`
- `flutter analyze` result:
  - **No issues found**
- Cleanup commit was pushed to `main`.

---

## Step R6-G.1 — Replace `pending-*` Transaction Proof Paths with Official `TRX-*` Paths

Status:

**Completed, verified, pushed, documented, and Issue #1 closed**

Completed:

- Reviewed current transaction creation flow.
- Confirmed that the old flow uploaded proof images before the backend returned the official transaction code.
- Removed temporary `pending-*` proof image path behavior from Flutter.
- Added secure RPC:
  - `upload_transaction_proof_image`
- Updated:
  - `create_custody_transaction`
- Added deferred proof image upload support:
  - `p_defer_proof_image_upload`
- Replaced old proof image check constraint with:
  - `transactions_proof_image_path_official_trx_format`
- Updated Flutter transaction creation flow to:
  - Create the transaction first.
  - Read official `TRX-*` code.
  - Upload proof image under official `TRX-*` folder.
  - Save proof image path through secure RPC.
- Preserved image compression behavior.
- Preserved offline/network handling behavior.
- Preserved secure RPC-only transaction creation flow.
- Added SQL documentation:
  - `docs/supabase/r6_g_1_transaction_proof_trx_paths.sql`
- Manually tested creating an issue transaction with proof image.
- Confirmed new proof image path uses official `TRX-*` folder.
- Confirmed new proof image path does not use `pending-*`.
- Ran:
  - `dart format lib`
- Ran:
  - `flutter analyze`
- `flutter analyze` result:
  - **No issues found**
- Confirmed:
  - `findstr /s /n /i "pending-" lib\*.dart`
  - returned no results.
- Commit pushed:
  - `ebca7f55396793e1343d7ec3348be5335fd4fc70`
- GitHub Issue #1 closed as completed.

---

# Current Stable Engineering Rules

These are active project rules, not backlog items.

---

## Supabase / Security Rules

- Every business table must be connected to `company_id`.
- Every company query must be filtered by current company context.
- Never expose or use service role keys in Flutter.
- Admin Auth methods must not be called directly from Flutter.
- Company users must access company data only through active company membership.
- RLS must enforce role permissions at database level, not UI only.
- Storage policies must enforce upload/read permissions at bucket level.
- Sensitive member-management mutations must use secure RPCs, not direct client updates.
- Direct invitation creation must not be left open when a secure invitation RPC exists.
- Transactions should not be deleted from the system.
- Transaction editing should not be exposed as a normal UI action.
- Transaction mutations must go through controlled RPC workflows only.
- Important business actions must be auditable.
- Important business records should store direct accountability fields where applicable.
- Audit logs must store the acting profile.
- Audit logs must be protected by RLS.
- Audit logs must not be editable or deletable by normal app users.
- Direct accountability fields must not be trusted from arbitrary client input unless protected by RLS/RPC/backend logic.
- Actor profile should be derived from authenticated backend context whenever possible.

---

## Transaction Rules

- Transactions are business records and should not be physically deleted.
- General transaction editing is disabled.
- Transaction creation must use secure RPC.
- Proof image path updates must use secure RPC.
- Approval document upload must use secure RPC.
- Approval/rejection/settlement must use secure RPC.
- Lost/Damaged transactions should reduce worker custody balance only after final settlement/deduction is completed.
- New transaction proof image paths must use official `TRX-*` folders.
- New transaction proof images must not use `pending-*` folders.
- Local file paths must not be saved in Supabase tables.

---

## Storage / Image Optimization Rules

- Storage files must be saved in Supabase Storage.
- Database should store cloud storage paths only.
- Local file paths must not be saved in Supabase tables.
- Never upload large original images without compression unless there is a clear business reason.
- Transaction proof images must be compressed before upload.
- Approval document images should be compressed before upload when they are image files.
- PDF approval documents should not be image-compressed.
- Company logos should be resized/compressed carefully without destroying quality.
- Use clear storage paths under company folders:
  - `{companyId}/transactions/...`
  - `{companyId}/logo/...`
  - `{companyId}/documents/...`
- Camera capture should remain optional.
- File upload from device storage should remain supported as fallback.

---

## Offline / Network Rules

- The app must not fail silently when there is no internet connection.
- The user must see a clear offline message when connection is unavailable.
- Offline mode must not bypass RLS, subscription limits, or business rules.
- Save/update/delete mutations should be blocked while offline until a safe sync model exists.
- Supabase Storage uploads should be blocked while offline.
- Cloud-only Storage file viewing should be blocked while offline unless a future cache system is implemented.
- Reports may generate offline from already-loaded in-memory data.
- Online assets inside reports, such as company logo, may be unavailable offline.
- Network errors must be user-friendly and separated from validation/auth/business-rule errors where possible.

---

## Timezone and Date/Time Rules

- All database timestamps must remain stored as UTC.
- Supabase/Postgres timestamps such as `created_at`, `updated_at`, and audit log timestamps should use `timestamp with time zone` where appropriate.
- Do not store local display time as the source of truth.
- Business-facing UI, reports, PDFs, Audit History screens, and accountability display sections must display timestamps using the current company timezone.
- The app must not permanently hardcode UAE time for all companies.
- Device local time may be used only as fallback or suggestion, not as source of truth for company timestamps.
- Company timezone is stored at company level:
  - `companies.timezone`
- Timezone value must use IANA timezone names, such as:
  - `Asia/Dubai`
  - `Asia/Kolkata`
  - `Africa/Cairo`
  - `Asia/Riyadh`
- Do not rely only on fixed offsets such as `+04:00`.

---

## UI / Theme Rules

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
- Company settings belong in `Settings`.
- Team/member management belongs in a dedicated `Team` area.
- Desktop tables should remain readable and should not be overcrowded with too many accountability columns.
- Use details dialogs, bottom sheets, side panels, or expandable rows for dense accountability data when tables would become unreadable.

---

## Responsive / Adaptive Rules

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

## Data Quality Rules

- HR Code remains the technical unique identifier for workers.
- Worker names must remain unique inside the same company in the current app flow to prevent accidental duplicate worker records.
- Worker-name duplicate comparison uses Unicode-safe normalization.
- Current worker-name duplicate normalization ignores:
  - Case differences
  - Extra spaces
  - Separators and punctuation such as spaces, hyphens, dots, underscores, slashes, and commas
- If two real workers genuinely share the same apparent name, the entered name should be made more complete or more specific so both records remain clearly distinguishable.

---

## Data Accountability Rules

Mina System tracks accountability in two levels:

1. Direct accountability fields on important business records.
2. Full audit trail logs for historical tracking.

Audit logs alone are not enough.

Direct accountability fields answer:

**Who is responsible for the current/latest state?**

Important records should show:

- Who created the record.
- Who last updated it.
- When it was created.
- When it was last updated.

Transaction-specific direct accountability should also include:

- Proof image uploaded by.
- Proof image uploaded at.
- Signed approval document uploaded by.
- Signed approval document uploaded at.
- Approval decided by.
- Approval decided at.
- Settlement completed by.
- Settlement completed at.

Audit logs answer:

**What exactly happened over time?**

Audit logs should record:

- Company.
- Acting profile.
- Actor name/email snapshot.
- Action.
- Entity type.
- Entity ID.
- Entity label snapshot.
- Old data.
- New data.
- Metadata.
- Created timestamp in UTC.

Audit logs must be append-only for normal app users.

Normal app users must not directly insert, update, or delete audit logs.

---

# Maintainability / Stability Work Completed

Completed:

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
- PDF colors and text styles were centralized.
- Transaction temporary debug prints were removed after verification.
- Supabase SQL scripts for important backend changes are documented under:
  - `docs/supabase/`

---

# Current Backlog Policy

This roadmap does not list the next development tasks.

All remaining work is tracked in:

- GitHub Issues
- GitHub Project board

When choosing the next task:

1. Open GitHub Project.
2. Pick the next prioritized open issue.
3. Review the real repo before planning.
4. Review the issue content.
5. Review related code files.
6. Present the plan before implementation.
7. Implement in small steps.
8. Test manually.
9. Run:
   - `dart format lib`
   - `flutter analyze`
10. Commit and push.
11. Close the GitHub Issue after verification.

---

# Roadmap Update Policy

`PROJECT_ROADMAP.md` should be updated only when:

- A major checkpoint is completed.
- A major architectural/security/product decision changes.
- The completed-state snapshot becomes outdated in a meaningful way.
- A new stable project rule is introduced.

It should not be updated after every small issue if GitHub Issues and GitHub Project already track the practical backlog.