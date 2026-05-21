# Issue #16 — Security / RLS Verification Matrix

Status: Draft matrix skeleton  
Step: 16.2  
Scope: Tables, RPCs, Storage buckets, roles, direct writes, manual verification queries, critical role tests, and gap tracking  
Do not modify: `PROJECT_ROADMAP.md`

---

## 1. Purpose

This document is the working verification matrix for Issue #16.

The goal is to verify the security model of Mina System across:

- Supabase business tables
- RLS policies
- RPC functions
- Function grants
- Storage buckets
- Storage object policies
- Flutter direct read/write paths
- Role-based access rules
- Critical manual role tests

This file must record verified facts separately from assumptions.

---

## 2. Verification Status Legend

| Status | Meaning |
|---|---|
| `Verified` | Confirmed through actual Supabase SQL inspection or manual role test. |
| `Needs Verification` | Expected behavior is known, but actual Supabase state still needs confirmation. |
| `Gap Found` | A security gap was identified and should become a separate GitHub issue. |
| `Not Applicable` | This check does not apply to the item. |
| `Documented Only` | Mentioned in repository docs, but not yet verified against live Supabase state. |

---

## 3. Role Model

Current application roles:

| Role | Description | Matrix Status |
|---|---|---|
| `owner` | Company owner. Expected to have full company-level access. | Needs Verification |
| `admin` | Company admin. Expected to manage most operational and configuration areas except owner-only actions. | Needs Verification |
| `warehouse_manager` | Operational manager. Expected to manage workers, tools, lookups, transactions, and approval workflow depending on backend rules. | Needs Verification |
| `warehouse_user` | Operational user. Expected to create transactions and upload transaction proofs, but not approve lost/damaged workflows or upload approval documents. | Needs Verification |
| `viewer` | Read/report-only role. Expected to have no write access. | Needs Verification |

---

## 4. Flutter Permission Intent Matrix

This section maps the Flutter UI permission intent.  
These permissions must be verified against backend enforcement.

| Area | Permission | Owner | Admin | Warehouse Manager | Warehouse User | Viewer | Backend Status |
|---|---|---:|---:|---:|---:|---:|---|
| Dashboard | View dashboard | Yes | Yes | Yes | Yes | Yes | Needs Verification |
| Workers | View workers | Yes | Yes | Yes | Yes | No / Limited | Needs Verification |
| Workers | Create workers | Yes | Yes | Yes | No | No | Needs Verification |
| Workers | Update workers | Yes | Yes | Yes | No | No | Needs Verification |
| Workers | Delete/deactivate workers | Yes | Yes | Yes | No | No | Needs Verification |
| Tools | View tools | Yes | Yes | Yes | Yes | No / Limited | Needs Verification |
| Tools | Create tools | Yes | Yes | Yes | No | No | Needs Verification |
| Tools | Update tools | Yes | Yes | Yes | No | No | Needs Verification |
| Tools | Delete/deactivate tools | Yes | Yes | Yes | No | No | Needs Verification |
| Transactions | View transactions | Yes | Yes | Yes | Yes | No / Limited | Needs Verification |
| Transactions | Create transactions | Yes | Yes | Yes | Yes | No | Needs Verification |
| Transactions | General transaction edit | No / Disabled | No / Disabled | No / Disabled | No / Disabled | No | Needs Verification |
| Approval Workflow | Upload approval document | Yes | Yes | Yes | No | No | Needs Verification |
| Approval Workflow | Approve lost/damaged | Yes | Yes | Yes | No | No | Needs Verification |
| Approval Workflow | Reject lost/damaged | Yes | Yes | Yes | No | No | Needs Verification |
| Approval Workflow | Settle lost/damaged | Yes | Yes | Yes | No | No | Needs Verification |
| Reports | View reports | Yes | Yes | Yes | Yes | Yes | Needs Verification |
| Reports | Generate reports | Yes | Yes | Yes | Yes | Yes | Needs Verification |
| Lookups | View lookups | Yes | Yes | Yes | No / Limited | No | Needs Verification |
| Lookups | Create lookups | Yes | Yes | Yes | No | No | Needs Verification |
| Lookups | Delete lookups | Yes | Yes | Yes | No | No | Needs Verification |
| Company Settings | View settings | Yes | Yes | No / Limited | No | No | Needs Verification |
| Company Settings | Manage company profile | Yes | Yes | No | No | No | Needs Verification |
| Company Settings | Upload company logo | Yes | Yes | No | No | No | Needs Verification |
| Company Settings | Manage report settings | Yes | Yes | No | No | No | Needs Verification |
| Company Settings | Manage document templates | Yes | Yes | No | No | No | Needs Verification |
| Company Users | View company users | Yes | Yes | No / Limited | No | No | Needs Verification |
| Company Users | Invite users | Yes | Yes | No | No | No | Needs Verification |
| Company Users | Cancel invitations | Yes | Yes | No | No | No | Needs Verification |
| Company Users | Change member role | Yes | Yes | No | No | No | Needs Verification |
| Company Users | Deactivate/reactivate members | Yes | Yes | Yes for lower roles only | No | No | Needs Verification |
| Audit Logs | View audit logs | Yes | Yes | Possibly Manager | No | No | Needs Verification |
| Audit Logs | Write audit logs | Backend only | Backend only | Backend only | Backend only | Backend only | Needs Verification |

---

## 5. Business Tables RLS Matrix

### 5.1 Core identity and tenancy tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `profiles` | User profile linked to Supabase auth user. | Select current profile and joined display data. | Users should only access allowed profile data. Profile self-access and joined company member access must be verified. | Needs Verification | Must confirm users cannot read unrelated sensitive profile data. |
| `companies` | Company tenant record and company profile. | Select and direct update from company settings. | Active company members can read. Only owner/admin should update company profile fields. Cross-company update must be blocked. | Needs Verification | Direct update path exists; high-priority verification. |
| `company_members` | Company membership, role, and status. | Select active memberships and company team members. | Active members should read allowed company members. Only secure RPCs should mutate lifecycle/roles. Direct client mutation must be blocked except intended policies. | Needs Verification | Phase Q docs state helper functions require active membership, but live verification is required. |
| `company_invitations` | Company invitations. | Select invitations. Mutations through RPCs. | Invited users can read their pending invitations. Owners/admins can read company invitations. Direct insert should be closed. Mutations should go through RPCs. | Needs Verification | Phase Q docs state direct insert was closed, but live verification is required. |

### 5.2 Company configuration tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `company_report_settings` | Report formatting and report statement settings. | Select and direct update. | Active members with settings permission should read. Only owner/admin should update. Cross-company update must be blocked. | Needs Verification | Direct update path exists; high-priority verification. |
| `company_document_templates` | Document titles/codes/signature labels per report type. | Select and direct update. | Active members with settings permission should read. Only owner/admin should update. Cross-company update must be blocked. | Needs Verification | Needed before signed PDF work in Issue #28. |

### 5.3 Operational lookup tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `departments` | Worker department lookup. | Select, insert, delete. | Active company members can read. Only owner/admin/warehouse_manager should create/delete if intended. Cross-company writes must be blocked. | Needs Verification | Direct insert/delete path exists; high-priority verification. |
| `job_titles` | Worker job title lookup. | Select, insert, delete. | Active company members can read. Only owner/admin/warehouse_manager should create/delete if intended. Cross-company writes must be blocked. | Needs Verification | Direct insert/delete path exists; high-priority verification. |
| `tool_units` | Tool unit lookup. | Select, insert, delete. | Active company members can read. Only owner/admin/warehouse_manager should create/delete if intended. Cross-company writes must be blocked. | Needs Verification | Direct insert/delete path exists; high-priority verification. |
| `tool_categories` | Tool category lookup. | Select, insert, delete. | Active company members can read. Only owner/admin/warehouse_manager should create/delete if intended. Cross-company writes must be blocked. | Needs Verification | Direct insert/delete path exists; high-priority verification. |

### 5.4 Operational master tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `workers` | Worker master data. | Select. Mutations through RPCs. | Active members with worker permissions can read. Direct insert/update/delete should be blocked unless intentionally allowed. Mutations should be enforced by RPCs. | Needs Verification | Duplicate checks use direct select. |
| `tools` | Tool master data. | Select. Mutations through RPCs. | Active members with tool permissions can read. Direct insert/update/delete should be blocked unless intentionally allowed. Mutations should be enforced by RPCs. | Needs Verification | Duplicate checks use direct select. |

### 5.5 Transaction and audit tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `transactions` | Custody transactions and lost/damaged workflow. | Select. Mutations through RPCs. | Active members with transaction/report permissions can read. Direct insert/update/delete should be blocked unless intentionally allowed. Mutations should be enforced by RPCs. | Needs Verification | Main transaction workflows use RPCs. |
| `audit_logs` | Immutable audit trail. | Select only. | Authorized company roles can read. Direct insert/update/delete from Flutter should be blocked. Writes should be backend-only. | Needs Verification | Must verify audit immutability. |
| `storage.objects` | Supabase Storage metadata. | Used indirectly through Supabase Storage API. | Policies must enforce bucket, company path, role, and operation. | Needs Verification | Storage security is critical before signed PDFs. |

---

## 6. RPC Verification Matrix

### 6.1 Company / context RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_company_with_defaults` | Create a new company and default setup. | Authenticated user creating own company. | Anonymous users. Possibly unrelated users. | Needs Verification | Must verify owner membership is created safely. |

### 6.2 Company users and invitations RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `invite_company_user` | Create secure company invitation. | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Needs Verification | Must verify owner cannot be invited through normal flow. |
| `accept_company_invitation` | Accept invitation. | Invited authenticated user with matching email and valid pending invitation. | Non-invited users, expired/cancelled invitations | Needs Verification | Must verify email and invitation status checks. |
| `cancel_company_invitation` | Cancel pending invitation. | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Needs Verification | Must verify cross-company cancellation blocked. |
| `change_company_member_role` | Change member role. | Owner; Admin for lower roles only | Self-change, owner target, admin managing admin, lower roles | Needs Verification | Phase Q docs mention passed DB tests, but live verification still needed. |
| `deactivate_company_member` | Soft deactivate member. | Owner; Admin lower roles; Warehouse Manager lower roles if intended | Self-deactivation, owner target, same/higher role target | Needs Verification | Must verify active membership requirement. |
| `reactivate_company_member` | Reactivate inactive member. | Owner; Admin lower roles; Warehouse Manager lower roles if intended | Self-reactivation, owner target, same/higher role target | Needs Verification | Must verify inactive target handling. |

### 6.3 Worker RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_worker` | Create worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify company scope and lookup relationship constraints. |
| `update_worker` | Update worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify cross-company update blocked. |
| `deactivate_worker` | Soft deactivate worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify not physically deleted. |
| `reactivate_worker` | Reactivate worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify status transition rules. |

### 6.4 Tool RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_tool` | Create tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify company scope and lookup relationship constraints. |
| `update_tool` | Update tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify cross-company update blocked. |
| `deactivate_tool` | Soft deactivate tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify not physically deleted. |
| `reactivate_tool` | Reactivate tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify status transition rules. |

### 6.5 Transaction RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_custody_transaction` | Create issue/return/lost/damaged transaction. | Owner, Admin, Warehouse Manager, Warehouse User | Viewer, inactive members | Needs Verification | Must verify quantity, worker/tool company scope, proof rules, and role checks. |
| `upload_transaction_proof_image` | Link proof image after Storage upload. | Owner, Admin, Warehouse Manager, Warehouse User | Viewer, inactive members | Needs Verification | Must verify path format and official TRX folder rules. |
| `upload_transaction_approval_document` | Link signed approval document. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Critical for Issue #28 signed PDFs. |
| `approve_lost_damaged_transaction` | Approve lost/damaged transaction. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify document required before approval. |
| `reject_lost_damaged_transaction` | Reject lost/damaged transaction. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify document required before rejection. |
| `settle_lost_damaged_transaction` | Settle approved lost/damaged transaction. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Needs Verification | Must verify only approved pending-settlement records can be settled. |
| `rollback_failed_transaction_proof_upload` | Roll back incomplete transaction after failed proof image linking. | Creator with Owner/Admin/Warehouse Manager/Warehouse User role within short rollback window | Viewer, inactive members, non-creator, expired rollback window | Needs Verification | Must verify rollback guards. |

---

## 7. RPC Grant Verification Matrix

Each exposed RPC should be checked for secure grants.

| RPC | Revoke From Public | Grant To Authenticated | Auth Check | Active Membership Check | Role Check | Safe Search Path | Status |
|---|---|---|---|---|---|---|---|
| `create_company_with_defaults` | Needs Verification | Needs Verification | Needs Verification | Not Applicable / Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `invite_company_user` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `accept_company_invitation` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `cancel_company_invitation` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `change_company_member_role` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `deactivate_company_member` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `reactivate_company_member` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `create_worker` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `update_worker` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `deactivate_worker` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `reactivate_worker` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `create_tool` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `update_tool` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `deactivate_tool` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `reactivate_tool` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `create_custody_transaction` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `upload_transaction_proof_image` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `upload_transaction_approval_document` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `approve_lost_damaged_transaction` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `reject_lost_damaged_transaction` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `settle_lost_damaged_transaction` | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification | Needs Verification |
| `rollback_failed_transaction_proof_upload` | Documented Only | Documented Only | Documented Only | Documented Only | Documented Only | Documented Only | Needs Verification |

---

## 8. Storage Bucket Verification Matrix

| Bucket | Purpose | Expected Upload Roles | Expected Read Roles | Expected Delete Roles | Path Format | Verification Status | Notes |
|---|---|---|---|---|---|---|---|
| `company-assets` | Company logo and company asset files. | Owner, Admin | Active company members / report readers depending on business decision | Owner, Admin | `{companyId}/logo/company-logo-{timestamp}.{ext}` | Needs Verification | Must verify company logo path cannot point to another company. |
| `transaction-proofs` | Transaction proof images. | Owner, Admin, Warehouse Manager, Warehouse User | Authorized transaction viewers/report generators | Owner, Admin, Warehouse Manager, Warehouse User for orphan cleanup | `{companyId}/transactions/{TRX-code}/proof-{timestamp}.{ext}` | Needs Verification | Delete policy is documented in Issue #20 SQL, but live verification is required. |
| `transaction-approval-documents` | Signed approval documents for lost/damaged transactions. | Owner, Admin, Warehouse Manager | Owner, Admin, Warehouse Manager, possibly report readers if intended | Owner, Admin, Warehouse Manager for orphan cleanup | `{companyId}/transactions/{TRX-code}/approval-document-{timestamp}.{ext}` | Needs Verification | Critical before Issue #28 signed PDFs. Warehouse User should be blocked. |

---

## 9. Direct Write Verification Matrix

These are the highest-priority RLS checks because Flutter writes directly to these tables.

| Table | Operation | Expected Allowed Roles | Expected Denied Roles | Required RLS Checks | Verification Status |
|---|---|---|---|---|---|
| `companies` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only own active company. Cannot cross-company update. Cannot spoof protected fields. | Needs Verification |
| `company_report_settings` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only settings for active company membership. Cannot cross-company update. | Needs Verification |
| `company_document_templates` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only templates for active company membership. Cannot cross-company update. | Needs Verification |
| `departments` | insert | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Insert company_id must be an active company where caller has allowed role. | Needs Verification |
| `departments` | delete | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Delete only same-company records. Confirm hard delete is intended. | Needs Verification |
| `job_titles` | insert | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Insert company_id and department_id must belong to same company. | Needs Verification |
| `job_titles` | delete | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Delete only same-company records. Confirm hard delete is intended. | Needs Verification |
| `tool_units` | insert | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Insert company_id must be an active company where caller has allowed role. | Needs Verification |
| `tool_units` | delete | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Delete only same-company records. Confirm hard delete is intended. | Needs Verification |
| `tool_categories` | insert | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Insert company_id must be an active company where caller has allowed role. | Needs Verification |
| `tool_categories` | delete | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Delete only same-company records. Confirm hard delete is intended. | Needs Verification |

---

## 10. Direct Write Recommendation Tracker

This section records whether a direct-write area should remain direct with strong RLS or be moved behind RPCs.

| Area | Current Pattern | Recommended Decision | Status | Notes |
|---|---|---|---|---|
| Company profile update | Direct update | Keep only if RLS and accountability are strict; otherwise move to RPC. | Needs Verification | Must verify updated_by fields cannot be spoofed. |
| Company report settings update | Direct update | Keep only if RLS is strict; otherwise move to RPC. | Needs Verification | Important for document/report integrity. |
| Company document templates update | Direct update | Keep only if RLS is strict; otherwise move to RPC. | Needs Verification | Important before signed PDFs. |
| Lookup creation/deletion | Direct insert/delete | Consider moving to RPCs if RLS/accountability is not enough. | Needs Verification | Hard delete should be reviewed carefully. |

---

## 11. Manual SQL Verification Queries

Run these queries in Supabase SQL Editor using an admin/developer account.

### 11.1 Confirm RLS is enabled on business tables

    select
      schemaname,
      tablename,
      rowsecurity
    from pg_tables
    where schemaname = 'public'
      and tablename in (
        'profiles',
        'companies',
        'company_members',
        'company_invitations',
        'company_report_settings',
        'company_document_templates',
        'departments',
        'job_titles',
        'workers',
        'tool_units',
        'tool_categories',
        'tools',
        'transactions',
        'audit_logs'
      )
    order by tablename;

Expected:

- `rowsecurity = true` for all business tables that are exposed to the Data API.

Verification Status: Needs Verification

---

### 11.2 List all public table policies

    select
      schemaname,
      tablename,
      policyname,
      permissive,
      roles,
      cmd,
      qual,
      with_check
    from pg_policies
    where schemaname = 'public'
      and tablename in (
        'profiles',
        'companies',
        'company_members',
        'company_invitations',
        'company_report_settings',
        'company_document_templates',
        'departments',
        'job_titles',
        'workers',
        'tool_units',
        'tool_categories',
        'tools',
        'transactions',
        'audit_logs'
      )
    order by tablename, policyname;

Expected:

- Policies should be scoped by active company membership where applicable.
- Write policies should match the intended role model.
- No broad authenticated write policy should exist unless tightly restricted by `with_check`.

Verification Status: Needs Verification

---

### 11.3 List Storage object policies

    select
      schemaname,
      tablename,
      policyname,
      permissive,
      roles,
      cmd,
      qual,
      with_check
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
    order by policyname;

Expected:

- Policies exist for:
  - `company-assets`
  - `transaction-proofs`
  - `transaction-approval-documents`
- Policies should check bucket ID.
- Policies should derive company ID safely from the object path.
- Policies should use active company role checks.

Verification Status: Needs Verification

---

### 11.4 Confirm Storage buckets

    select
      id,
      name,
      public,
      file_size_limit,
      allowed_mime_types
    from storage.buckets
    where id in (
      'company-assets',
      'transaction-proofs',
      'transaction-approval-documents'
    )
    order by id;

Expected:

- Buckets should not be public unless intentionally required and documented.
- Sensitive transaction and approval documents should not be public.

Verification Status: Needs Verification

---

### 11.5 Confirm RPC definitions and security mode

    select
      n.nspname as schema_name,
      p.proname as function_name,
      pg_get_function_arguments(p.oid) as arguments,
      case
        when p.prosecdef then 'SECURITY DEFINER'
        else 'SECURITY INVOKER'
      end as security_mode,
      p.proconfig as function_config
    from pg_proc p
    join pg_namespace n
      on n.oid = p.pronamespace
    where n.nspname in ('public', 'private')
      and p.proname in (
        'create_company_with_defaults',
        'invite_company_user',
        'accept_company_invitation',
        'cancel_company_invitation',
        'change_company_member_role',
        'deactivate_company_member',
        'reactivate_company_member',
        'create_worker',
        'update_worker',
        'deactivate_worker',
        'reactivate_worker',
        'create_tool',
        'update_tool',
        'deactivate_tool',
        'reactivate_tool',
        'create_custody_transaction',
        'upload_transaction_proof_image',
        'upload_transaction_approval_document',
        'approve_lost_damaged_transaction',
        'reject_lost_damaged_transaction',
        'settle_lost_damaged_transaction',
        'rollback_failed_transaction_proof_upload',
        'current_profile_id',
        'is_company_member',
        'has_company_role',
        'company_id_from_storage_path',
        'write_audit_log'
      )
    order by schema_name, function_name;

Expected:

- Critical mutation RPCs should use safe internal checks.
- SECURITY DEFINER functions must use safe `search_path`.
- Private helper functions should remain in private schema where appropriate.

Verification Status: Needs Verification

---

### 11.6 Confirm function grants

    select
      routine_schema,
      routine_name,
      grantee,
      privilege_type
    from information_schema.routine_privileges
    where routine_schema in ('public', 'private')
      and routine_name in (
        'create_company_with_defaults',
        'invite_company_user',
        'accept_company_invitation',
        'cancel_company_invitation',
        'change_company_member_role',
        'deactivate_company_member',
        'reactivate_company_member',
        'create_worker',
        'update_worker',
        'deactivate_worker',
        'reactivate_worker',
        'create_tool',
        'update_tool',
        'deactivate_tool',
        'reactivate_tool',
        'create_custody_transaction',
        'upload_transaction_proof_image',
        'upload_transaction_approval_document',
        'approve_lost_damaged_transaction',
        'reject_lost_damaged_transaction',
        'settle_lost_damaged_transaction',
        'rollback_failed_transaction_proof_upload'
      )
    order by routine_name, grantee;

Expected:

- Exposed RPCs should grant execute to `authenticated`.
- Exposed RPCs should not grant unsafe execute access to `anon` or `public`.
- Private helper functions should not be broadly executable unless intentionally required.

Verification Status: Needs Verification

---

### 11.7 Confirm table grants

    select
      table_schema,
      table_name,
      grantee,
      privilege_type
    from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name in (
        'profiles',
        'companies',
        'company_members',
        'company_invitations',
        'company_report_settings',
        'company_document_templates',
        'departments',
        'job_titles',
        'workers',
        'tool_units',
        'tool_categories',
        'tools',
        'transactions',
        'audit_logs'
      )
    order by table_name, grantee, privilege_type;

Expected:

- Grants should be reviewed together with RLS.
- Broad grants are acceptable only when RLS is strict.
- Direct insert/update/delete grants require extra attention.

Verification Status: Needs Verification

---

### 11.8 Confirm audit_logs cannot be directly written by authenticated clients

    select
      table_schema,
      table_name,
      grantee,
      privilege_type
    from information_schema.role_table_grants
    where table_schema = 'public'
      and table_name = 'audit_logs'
    order by grantee, privilege_type;

Expected:

- Authenticated users may have select if intended.
- Authenticated users should not have direct insert/update/delete unless RLS fully blocks it.
- Preferred model: backend functions write audit logs.

Verification Status: Needs Verification

---

### 11.9 Confirm service role key is not in repository

Run locally from repository root:

    grep -R "service_role" .
    grep -R "SERVICE_ROLE" .
    grep -R "supabase_service" .
    grep -R "SUPABASE_SERVICE" .
    grep -R "secret" lib docs test android ios macos windows linux web

Expected:

- No service role key in Flutter, docs, build files, or committed files.
- Any harmless documentation-only mention should be reviewed manually.

Verification Status: Needs Verification

---

## 12. Critical Manual Role Test Scenarios

These tests should be performed with controlled test users.

### 12.1 Test users needed

| Test User | Role |
|---|---|
| User A | Owner |
| User B | Admin |
| User C | Warehouse Manager |
| User D | Warehouse User |
| User E | Viewer |
| User F | Inactive Member |
| User G | Member in another company |
| User H | Invited user |

---

### 12.2 Company scope tests

| Test | Expected Result | Status |
|---|---|---|
| User from Company A attempts to read Company B workers. | Denied / no rows returned. | Needs Verification |
| User from Company A attempts to update Company B settings. | Denied. | Needs Verification |
| User from Company A attempts to create lookup with Company B ID. | Denied. | Needs Verification |
| User from Company A attempts to upload Storage file under Company B path. | Denied. | Needs Verification |
| User from Company A attempts to create signed URL for Company B approval document. | Denied. | Needs Verification |

---

### 12.3 Viewer restriction tests

| Test | Expected Result | Status |
|---|---|---|
| Viewer attempts to create worker. | Denied. | Needs Verification |
| Viewer attempts to update company profile. | Denied. | Needs Verification |
| Viewer attempts to create lookup. | Denied. | Needs Verification |
| Viewer attempts to create transaction. | Denied. | Needs Verification |
| Viewer attempts to upload transaction proof. | Denied. | Needs Verification |
| Viewer attempts to upload approval document. | Denied. | Needs Verification |
| Viewer attempts to approve lost/damaged transaction. | Denied. | Needs Verification |

---

### 12.4 Warehouse User restriction tests

| Test | Expected Result | Status |
|---|---|---|
| Warehouse User creates transaction. | Allowed. | Needs Verification |
| Warehouse User uploads transaction proof. | Allowed. | Needs Verification |
| Warehouse User uploads approval document. | Denied. | Needs Verification |
| Warehouse User approves lost/damaged transaction. | Denied. | Needs Verification |
| Warehouse User settles lost/damaged transaction. | Denied. | Needs Verification |
| Warehouse User creates worker. | Denied. | Needs Verification |
| Warehouse User creates tool. | Denied. | Needs Verification |
| Warehouse User updates company settings. | Denied. | Needs Verification |

---

### 12.5 Warehouse Manager tests

| Test | Expected Result | Status |
|---|---|---|
| Warehouse Manager creates worker. | Allowed. | Needs Verification |
| Warehouse Manager creates tool. | Allowed. | Needs Verification |
| Warehouse Manager creates lookup. | Allowed if business rule remains intended. | Needs Verification |
| Warehouse Manager uploads approval document. | Allowed. | Needs Verification |
| Warehouse Manager approves lost/damaged transaction. | Allowed. | Needs Verification |
| Warehouse Manager manages Warehouse User member lifecycle. | Allowed if intended. | Needs Verification |
| Warehouse Manager manages another Warehouse Manager. | Denied. | Needs Verification |
| Warehouse Manager manages Admin. | Denied. | Needs Verification |
| Warehouse Manager manages Owner. | Denied. | Needs Verification |

---

### 12.6 Admin tests

| Test | Expected Result | Status |
|---|---|---|
| Admin invites Warehouse Manager. | Allowed. | Needs Verification |
| Admin invites Admin. | Denied. | Needs Verification |
| Admin invites Owner. | Denied. | Needs Verification |
| Admin changes Warehouse User role to Viewer. | Allowed. | Needs Verification |
| Admin changes another Admin role. | Denied. | Needs Verification |
| Admin deactivates Owner. | Denied. | Needs Verification |
| Admin updates company settings. | Allowed. | Needs Verification |
| Admin uploads company logo. | Allowed. | Needs Verification |

---

### 12.7 Owner tests

| Test | Expected Result | Status |
|---|---|---|
| Owner invites Admin. | Allowed. | Needs Verification |
| Owner invites Owner through normal invite flow. | Denied. | Needs Verification |
| Owner changes Admin role to Warehouse Manager. | Allowed. | Needs Verification |
| Owner deactivates Admin. | Allowed. | Needs Verification |
| Owner deactivates own membership. | Denied. | Needs Verification |
| Owner updates company settings. | Allowed. | Needs Verification |
| Owner uploads company logo. | Allowed. | Needs Verification |

---

### 12.8 Inactive member tests

| Test | Expected Result | Status |
|---|---|---|
| Inactive member reads company data. | Denied / no rows returned. | Needs Verification |
| Inactive member creates transaction. | Denied. | Needs Verification |
| Inactive member uploads Storage object. | Denied. | Needs Verification |
| Inactive member calls any company mutation RPC. | Denied. | Needs Verification |
| Inactive member creates signed URL. | Denied. | Needs Verification |

---

### 12.9 Audit log tests

| Test | Expected Result | Status |
|---|---|---|
| Authorized user reads company audit logs. | Allowed according to business rule. | Needs Verification |
| Unauthorized company member reads audit logs. | Denied. | Needs Verification |
| Viewer reads audit logs. | Denied unless intentionally allowed. | Needs Verification |
| Authenticated user directly inserts audit log. | Denied. | Needs Verification |
| Authenticated user directly updates audit log. | Denied. | Needs Verification |
| Authenticated user directly deletes audit log. | Denied. | Needs Verification |
| Critical RPC writes audit log. | Allowed through backend function only. | Needs Verification |

---

## 13. Gap Register

Use this section to record issues found during verification.

| Gap ID | Area | Description | Severity | Recommended Action | GitHub Issue | Status |
|---|---|---|---|---|---|---|
| GAP-001 | TBD | No gap recorded yet. | TBD | TBD | TBD | Open |

---

## 14. Verification Progress Tracker

| Section | Status | Notes |
|---|---|---|
| Role model matrix | Drafted | Needs backend verification. |
| Business table matrix | Drafted | Needs RLS inspection. |
| RPC matrix | Drafted | Needs grants and function body inspection. |
| Storage matrix | Drafted | Needs bucket and storage policy verification. |
| Direct write matrix | Drafted | High-priority verification area. |
| Manual SQL queries | Drafted | Must be executed in Supabase SQL Editor. |
| Critical role tests | Drafted | Requires test users. |
| Gap register | Started | No confirmed gap yet. |

---

## 15. Step 16.2 Conclusion

This file creates the first full Security/RLS verification matrix skeleton.

Current status:

- The matrix structure exists.
- The current security surface from Step 16.1 has been mapped into tables, RPCs, Storage, roles, and tests.
- Most items remain marked as `Needs Verification`.
- No security behavior should be marked as `Verified` until confirmed by actual SQL inspection or manual role testing.

Next recommended step:

- Step 16.3 — Run SQL inspection queries and start marking matrix rows as `Verified`, `Gap Found`, or `Needs Verification`.