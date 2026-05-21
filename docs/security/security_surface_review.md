# Issue #16 — Step 16.1 Security Surface Review

Status: Review only  
Scope: Current security surface inventory before building the full Security/RLS verification matrix  
Do not modify: `PROJECT_ROADMAP.md`

---

## 1. Goal

This document records the current security surface of Mina System before creating the full Security/RLS verification matrix.

This step does not change Flutter code, SQL, RLS policies, Storage policies, RPCs, or project roadmap files.

The purpose is to identify:

- Current Supabase configuration surface
- Current user roles
- Flutter-side permission model
- Tables accessed directly by Flutter
- RPC functions called by Flutter
- Storage buckets used by Flutter
- Direct write paths that must be verified carefully
- Existing Supabase security documentation already present in the repository
- Open verification targets for the next steps of Issue #16

---

## 2. Source Files Reviewed

### GitHub Issue

- `Issue #16 — Create full security and RLS verification matrix`

### Flutter Security / Access Files

- `lib/main.dart`
- `lib/core/config/app_environment.dart`
- `lib/core/permissions/company_role_permissions.dart`
- `lib/core/routes/routes.dart`
- `lib/features/auth/presentation/cubit/auth_cubit.dart`
- `lib/features/current_context/data/repo/current_context_repo.dart`
- `lib/features/company_users/data/repo/company_users_repo.dart`
- `lib/features/company_settings/data/repo/company_settings_repo.dart`
- `lib/features/workers/data/repo/workers_repo.dart`
- `lib/features/tools/data/repo/tools_repo.dart`
- `lib/features/lookups/data/repo/lookups_repo.dart`
- `lib/features/transactions/data/repo/transactions_repo.dart`
- `lib/features/transactions/data/services/transaction_storage_service.dart`
- `lib/features/transactions/data/services/transaction_approval_service.dart`
- `lib/features/transactions/data/services/transaction_code_service.dart`
- `lib/features/audit_logs/data/repo/audit_logs_repo.dart`
- `lib/features/dashboard/data/repo/dashboard_repo.dart`

### Supabase Documentation / SQL Artifacts

- `docs/supabase/phase_p_rbac_policies.md`
- `docs/supabase/phase_q_member_management_backend.md`
- `docs/supabase/r6_g_1_transaction_proof_trx_paths.sql`
- `docs/supabase/issue_20_orphan_storage_cleanup.sql`
- `docs/supabase/issue_27_safe_transaction_code_generation.sql`

---

## 3. Supabase Configuration Surface

### Current state

The app initializes Supabase in `lib/main.dart` using:

- `AppEnvironment.supabaseUrl`
- `AppEnvironment.supabaseAnonKey`

The configuration values are read from compile-time environment variables using `String.fromEnvironment`.

### Environment variables detected

From `lib/core/config/app_environment.dart`:

- `APP_ENV`
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `SUPABASE_ANON_KEY`

### Initial finding

No service role key is intentionally used by the Flutter initialization path reviewed in this step.

### Verification still required

Issue #16 must still formally verify that no service role key or admin secret exists anywhere in the Flutter app, build files, docs, examples, or committed configuration files.

Suggested verification queries for next step:

```bash
grep -R "service_role" .
grep -R "SERVICE_ROLE" .
grep -R "supabase_service" .
grep -R "SUPABASE_SERVICE" .
grep -R "secret" lib docs test android ios macos windows linux web
```

---

## 4. Authentication Surface

### Flutter auth entry points

Detected in `lib/features/auth/presentation/cubit/auth_cubit.dart`:

- Login:
  - `supabase.auth.signInWithPassword`
- Register:
  - `supabase.auth.signUp`

### Route guard

Detected in `lib/core/routes/routes.dart`:

- Authenticated users are redirected away from auth pages.
- Unauthenticated users are redirected away from protected app pages.
- Login/Register require valid email extra.

### Important note

Route guards are UX/security support only. They must not be considered a replacement for RLS, RPC validation, or Storage policies.

---

## 5. Role Model Surface

### Roles detected

Defined in `lib/core/permissions/company_role_permissions.dart`:

- `owner`
- `admin`
- `warehouse_manager`
- `warehouse_user`
- `viewer`

### Flutter permission model

The Flutter permission map includes permissions for:

- Dashboard
- Workers
- Tools
- Transactions
- Approval workflow
- Custody balance
- Tool summary
- Reports
- Lookups
- Company settings
- Team / company users

### Important note

Flutter role permissions are UI-side guards only.

The full Security/RLS matrix must verify that every allowed or blocked action is enforced at database level through:

- RLS policies
- RPC internal checks
- Storage policies
- Function grants
- Table grants

---

## 6. Existing Supabase Security Foundation

### Phase P documentation

`docs/supabase/phase_p_rbac_policies.md` states that Phase P completed:

- Flutter UI role-based permissions
- Public table RLS write policies aligned with RBAC
- Storage policies aligned with RBAC

It also documents these Storage expectations:

- `transaction-proofs`
  - owner
  - admin
  - warehouse_manager
  - warehouse_user

- `transaction-approval-documents`
  - owner
  - admin
  - warehouse_manager only

### Phase Q documentation

`docs/supabase/phase_q_member_management_backend.md` documents reviewed backend security for:

- `company_members`
- `company_invitations`
- `private.current_profile_id()`
- `private.is_company_member(uuid)`
- `private.has_company_role(uuid, company_member_role[])`
- invitation RPCs
- member lifecycle RPCs

It also states that active membership is required by the helper functions.

### Important note

These docs are useful evidence, but Issue #16 requires verification, not assumption.

The full matrix must validate actual Supabase state using SQL verification queries.

---

## 7. Tables Accessed Directly by Flutter

This section lists tables detected from Flutter repositories and services.

### 7.1 Authentication / Context

| Table | Access Type | File | Notes |
|---|---:|---|---|
| `profiles` | select | `current_context_repo.dart` | Used to load current profile by `auth_user_id`. |
| `company_members` | select | `current_context_repo.dart`, `company_users_repo.dart` | Used to load active memberships and company members. |
| `companies` | select / update | `current_context_repo.dart`, `company_settings_repo.dart` | Company creation uses RPC, profile/settings updates use direct update. |

### 7.2 Company Settings

| Table | Access Type | File | Notes |
|---|---:|---|---|
| `companies` | select / update | `company_settings_repo.dart` | Company profile and logo path update. |
| `company_report_settings` | select / update | `company_settings_repo.dart` | Report settings direct update. |
| `company_document_templates` | select / update | `company_settings_repo.dart` | Document templates direct update. |

### 7.3 Company Users

| Table | Access Type | File | Notes |
|---|---:|---|---|
| `company_members` | select | `company_users_repo.dart` | Reads team members and joined profile info. |
| `company_invitations` | select | `company_users_repo.dart` | Invitation creation/cancel/accept use RPCs. |
| `profiles` | select via joins | `company_users_repo.dart` | Used for member/invitation display data. |
| `companies` | select via joins | `company_users_repo.dart` | Used for invitation display data. |

### 7.4 Workers

| Table | Access Type | File | Notes |
|---|---:|---|---|
| `workers` | select | `workers_repo.dart`, `dashboard_repo.dart` | Mutations use RPCs. Some duplicate/code checks use direct select. |
| `departments` | select via joins | `workers_repo.dart` | Display worker department. |
| `job_titles` | select via joins | `workers_repo.dart` | Display worker job title. |
| `profiles` | select via joins | `workers_repo.dart` | Accountability display fields. |

### 7.5 Tools

| Table | Access Type | File | Notes |
|---|---:|---|---|
| `tools` | select | `tools_repo.dart`, `dashboard_repo.dart` | Mutations use RPCs. Some duplicate/code checks use direct select. |
| `tool_units` | select via joins | `tools_repo.dart` | Display tool unit. |
| `tool_categories` | select via joins | `tools_repo.dart` | Display tool category. |
| `profiles` | select via joins | `tools_repo.dart` | Accountability display fields. |

### 7.6 Lookups

| Table | Access Type | File | Notes |
|---|---:|---|---|
| `departments` | select / insert / delete | `lookups_repo.dart` | Direct write path. Requires careful RLS verification. |
| `job_titles` | select / insert / delete | `lookups_repo.dart` | Direct write path. Requires careful RLS verification. |
| `tool_units` | select / insert / delete | `lookups_repo.dart` | Direct write path. Requires careful RLS verification. |
| `tool_categories` | select / insert / delete | `lookups_repo.dart` | Direct write path. Requires careful RLS verification. |

### 7.7 Transactions

| Table | Access Type | File | Notes |
|---|---:|---|---|
| `transactions` | select | `transactions_repo.dart`, `transaction_approval_service.dart`, `transaction_code_service.dart` | Main mutations use RPCs. |
| `workers` | referenced by RPC / select elsewhere | Multiple | Used for transaction snapshots and dashboard. |
| `tools` | referenced by RPC / select elsewhere | Multiple | Used for transaction snapshots and dashboard. |

### 7.8 Audit Logs

| Table | Access Type | File | Notes |
|---|---:|---|---|
| `audit_logs` | select | `audit_logs_repo.dart` | Flutter reads audit logs. Writes should remain backend-only through database functions. |

---

## 8. RPC Surface Detected from Flutter

### 8.1 Current Context / Company Creation

| RPC | Called From | Purpose |
|---|---|---|
| `create_company_with_defaults` | `current_context_repo.dart` | Create company with default setup. |

### 8.2 Company Users / Invitations

| RPC | Called From | Purpose |
|---|---|---|
| `invite_company_user` | `company_users_repo.dart` | Secure invitation creation. |
| `change_company_member_role` | `company_users_repo.dart` | Secure role change. |
| `deactivate_company_member` | `company_users_repo.dart` | Soft deactivate member. |
| `reactivate_company_member` | `company_users_repo.dart` | Reactivate member. |
| `accept_company_invitation` | `company_users_repo.dart` | Accept invitation. |
| `cancel_company_invitation` | `company_users_repo.dart` | Cancel invitation. |

### 8.3 Workers

| RPC | Called From | Purpose |
|---|---|---|
| `create_worker` | `workers_repo.dart` | Secure worker creation. |
| `update_worker` | `workers_repo.dart` | Secure worker update. |
| `deactivate_worker` | `workers_repo.dart` | Soft delete/deactivate worker. |
| `reactivate_worker` | `workers_repo.dart` | Reactivate worker. |

### 8.4 Tools

| RPC | Called From | Purpose |
|---|---|---|
| `create_tool` | `tools_repo.dart` | Secure tool creation. |
| `update_tool` | `tools_repo.dart` | Secure tool update. |
| `deactivate_tool` | `tools_repo.dart` | Soft delete/deactivate tool. |
| `reactivate_tool` | `tools_repo.dart` | Reactivate tool. |

### 8.5 Transactions

| RPC | Called From | Purpose |
|---|---|---|
| `create_custody_transaction` | `transactions_repo.dart` | Create issue/return/lost/damaged transaction. |
| `upload_transaction_proof_image` | `transactions_repo.dart` | Link uploaded proof image to transaction. |
| `upload_transaction_approval_document` | `transactions_repo.dart` | Link approval document to lost/damaged transaction. |
| `approve_lost_damaged_transaction` | `transaction_approval_service.dart` | Approve lost/damaged transaction. |
| `reject_lost_damaged_transaction` | `transaction_approval_service.dart` | Reject lost/damaged transaction. |
| `settle_lost_damaged_transaction` | `transaction_approval_service.dart` | Settle approved lost/damaged transaction. |
| `rollback_failed_transaction_proof_upload` | `transactions_repo.dart` | Roll back incomplete transaction after proof upload/link failure. |

---

## 9. Storage Surface

### Buckets detected

| Bucket | Used In | Purpose |
|---|---|---|
| `company-assets` | `company_settings_repo.dart` | Company logo upload/delete. |
| `transaction-proofs` | `transaction_storage_service.dart` | Transaction proof image upload/delete. |
| `transaction-approval-documents` | `transaction_storage_service.dart` | Lost/damaged approval document upload/delete/signed URL. |

### Storage operations detected

| Operation | Bucket | File | Notes |
|---|---|---|---|
| uploadBinary | `company-assets` | `company_settings_repo.dart` | Upload company logo. |
| remove | `company-assets` | `company_settings_repo.dart` | Delete old/unlinked company logo. |
| uploadBinary | `transaction-proofs` | `transaction_storage_service.dart` | Upload proof image. |
| remove | `transaction-proofs` | `transaction_storage_service.dart` | Delete orphaned proof image. |
| uploadBinary | `transaction-approval-documents` | `transaction_storage_service.dart` | Upload approval PDF/image document. |
| remove | `transaction-approval-documents` | `transaction_storage_service.dart` | Delete orphaned approval document. |
| createSignedUrl | dynamic bucket argument | `transaction_storage_service.dart` | Currently used for approval documents. |

### Existing Storage policy evidence

`docs/supabase/issue_20_orphan_storage_cleanup.sql` includes delete policies for:

- `transaction-proofs`
- `transaction-approval-documents`

It uses:

- `private.company_id_from_storage_path(name)`
- `private.has_company_role(...)`

### Verification still required

The full matrix must verify:

- Upload policies for all buckets.
- Read/download/signed URL policies for all buckets.
- Delete policies for all buckets.
- Whether `viewer` can read files.
- Whether `warehouse_user` is blocked from approval document upload/read/delete where intended.
- Whether path validation prevents cross-company access.
- Whether signed URL creation is allowed only to intended roles.

---

## 10. Direct Write Surface

This is the most important part of the Step 16.1 review.

### 10.1 Direct table writes detected

| Area | Table | Operation | File | Risk Level | Notes |
|---|---|---:|---|---|---|
| Company Settings | `companies` | update | `company_settings_repo.dart` | Medium / High | Must verify only allowed roles can update company profile and logo path. |
| Company Settings | `company_report_settings` | update | `company_settings_repo.dart` | Medium / High | Must verify only allowed roles can update report settings. |
| Company Settings | `company_document_templates` | update | `company_settings_repo.dart` | Medium / High | Must verify only allowed roles can update document templates. |
| Lookups | `departments` | insert / delete | `lookups_repo.dart` | High | Direct client writes must be covered by strict RLS. |
| Lookups | `job_titles` | insert / delete | `lookups_repo.dart` | High | Direct client writes must be covered by strict RLS. |
| Lookups | `tool_units` | insert / delete | `lookups_repo.dart` | High | Direct client writes must be covered by strict RLS. |
| Lookups | `tool_categories` | insert / delete | `lookups_repo.dart` | High | Direct client writes must be covered by strict RLS. |

### 10.2 Direct writes not detected in reviewed core flows

The following areas appear to use RPCs for mutations:

- Company creation
- Company invitation creation
- Member role change
- Member deactivation/reactivation
- Worker create/update/deactivate/reactivate
- Tool create/update/deactivate/reactivate
- Transaction creation
- Transaction approval workflow
- Transaction proof linking
- Transaction upload rollback

### Important note

This does not mean the system is fully verified yet.

It only means Step 16.1 has identified which areas are direct-write and which are RPC-protected from the reviewed files.

---

## 11. UI Permission Surface vs Backend Surface

### UI permissions exist for:

- workers
- tools
- transactions
- approvals
- reports
- lookups
- company settings
- company users

### Important backend verification rule

Every UI permission must be mapped to one or more backend controls.

Example:

| UI Permission | Required Backend Verification |
|---|---|
| `createWorkers` | `create_worker` RPC role checks + execute grant |
| `deleteWorkers` | `deactivate_worker` RPC role checks + execute grant |
| `createTools` | `create_tool` RPC role checks + execute grant |
| `createTransactions` | `create_custody_transaction` RPC role checks + execute grant |
| `uploadApprovalDocument` | Storage upload policy + `upload_transaction_approval_document` RPC checks |
| `manageLookups` | Direct table insert/delete RLS on lookup tables |
| `manageCompanyProfile` | Direct update RLS on `companies` |
| `manageReportSettings` | Direct update RLS on `company_report_settings` |
| `manageDocumentTemplates` | Direct update RLS on `company_document_templates` |
| `viewReports` | Select policies on all report source tables |
| `viewCompanyUsers` | Select policies on `company_members`, `company_invitations`, joined profiles |

---

## 12. Current Risk Register from Step 16.1

### Risk 1 — Direct lookup writes

`LookupsRepo` directly inserts and deletes lookup records.

Affected tables:

- `departments`
- `job_titles`
- `tool_units`
- `tool_categories`

Required next verification:

- Confirm RLS insert/delete policies restrict these actions to intended roles.
- Confirm cross-company inserts are impossible.
- Confirm cross-company deletes are impossible.
- Confirm delete is still intended, or whether lookup deletion should become soft deactivate.
- Consider whether future hardening should move lookup mutations into RPCs.

### Risk 2 — Direct company settings updates

`CompanySettingsRepo` directly updates:

- `companies`
- `company_report_settings`
- `company_document_templates`

Required next verification:

- Confirm update policies allow only intended roles.
- Confirm users cannot update another company by changing `company_id` or `id`.
- Confirm accountability fields cannot be spoofed if they are client-controlled anywhere.
- Confirm logo path cannot be pointed to another company path.

### Risk 3 — Storage path security

Storage paths include company ID at the beginning of the path.

Examples:

- `{companyId}/logo/company-logo-{timestamp}.ext`
- `{companyId}/transactions/{TRX-code}/proof-{timestamp}.ext`
- `{companyId}/transactions/{TRX-code}/approval-document-{timestamp}.ext`

Required next verification:

- Confirm Storage policies derive company ID from path safely.
- Confirm path traversal or fake prefix tricks are not possible.
- Confirm users cannot upload files under another company ID.
- Confirm signed URL access is restricted correctly.

### Risk 4 — Approval document access

Approval documents may include signed PDFs or sensitive evidence.

Required next verification:

- Confirm `warehouse_user` cannot upload approval documents.
- Confirm `warehouse_user` cannot approve/reject/settle lost/damaged transactions.
- Confirm `viewer` cannot upload/read approval documents unless explicitly intended.
- Confirm signed URL creation is not over-permissive.

### Risk 5 — Audit log write protection

Flutter reads audit logs.

Required next verification:

- Confirm Flutter cannot insert/update/delete `audit_logs` directly.
- Confirm audit writes happen only through secure database functions.
- Confirm all critical RPCs write audit logs consistently.

### Risk 6 — RPC grants and SECURITY DEFINER behavior

Several critical operations use RPCs.

Required next verification:

- Confirm every exposed RPC has:
  - `revoke all ... from public`
  - `grant execute ... to authenticated`
  - internal authentication checks
  - active membership checks
  - role checks
  - company ownership / company scope checks
  - safe `search_path`

---

## 13. Initial Business Tables Inventory

This list is based on detected Flutter access and Supabase documentation.

### Core identity / tenancy

- `profiles`
- `companies`
- `company_members`
- `company_invitations`

### Company configuration

- `company_report_settings`
- `company_document_templates`

### Operational master data

- `departments`
- `job_titles`
- `workers`
- `tool_units`
- `tool_categories`
- `tools`

### Transactions and custody

- `transactions`

### Audit

- `audit_logs`

### Supabase Storage metadata

- `storage.objects`

---

## 14. Initial RPC Inventory

This list is based on detected Flutter calls and existing Supabase docs.

### Company / context

- `create_company_with_defaults`

### Company users / invitations

- `invite_company_user`
- `accept_company_invitation`
- `cancel_company_invitation`
- `change_company_member_role`
- `deactivate_company_member`
- `reactivate_company_member`

### Workers

- `create_worker`
- `update_worker`
- `deactivate_worker`
- `reactivate_worker`

### Tools

- `create_tool`
- `update_tool`
- `deactivate_tool`
- `reactivate_tool`

### Transactions

- `create_custody_transaction`
- `upload_transaction_proof_image`
- `upload_transaction_approval_document`
- `approve_lost_damaged_transaction`
- `reject_lost_damaged_transaction`
- `settle_lost_damaged_transaction`
- `rollback_failed_transaction_proof_upload`

### Helper functions referenced in docs / SQL

- `private.current_profile_id`
- `private.is_company_member`
- `private.has_company_role`
- `private.company_id_from_storage_path`
- `private.write_audit_log`

---

## 15. Initial Storage Bucket Inventory

- `company-assets`
- `transaction-proofs`
- `transaction-approval-documents`

---

## 16. Verification Targets for Step 16.2

Step 16.2 should start building the actual matrix.

Recommended matrix sections:

1. Roles matrix
2. Business tables matrix
3. RPC matrix
4. Storage bucket matrix
5. Direct write verification matrix
6. Manual SQL verification queries
7. Critical role test scenarios
8. Gap register

### Suggested Step 16.2 deliverable

Create:

```text
docs/security/security_rls_verification_matrix.md
```

This file should include:

- Table-by-table RLS expectations
- RPC-by-RPC permissions
- Bucket-by-bucket Storage permissions
- Manual verification SQL queries
- Test accounts / test role scenarios
- Gap tracking section

---

## 17. Step 16.1 Conclusion

The current security surface is mixed.

### Strong areas

- Supabase config is environment-based.
- No service role key is intentionally used in the reviewed Flutter initialization path.
- Role model is clearly defined in Flutter.
- Many critical mutations are routed through RPCs.
- Member management has backend security documentation.
- Transaction creation and approval workflow use backend functions.
- Storage cleanup policies exist for transaction files.

### Areas requiring careful verification

- Direct lookup writes.
- Direct company settings updates.
- Storage read/upload/delete policies.
- Signed URL access control.
- Audit log write protection.
- RPC grants and internal role checks.
- Exact alignment between Flutter UI permissions and backend enforcement.

### Final note

Step 16.1 is a discovery/review step only.

No code, SQL, policy, or roadmap file should be modified as part of this step.