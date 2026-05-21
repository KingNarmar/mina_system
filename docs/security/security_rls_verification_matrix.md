# Issue #16 — Security / RLS Verification Matrix

Status: SQL inspection in progress  
Step: 16.3  
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
| `Business Decision Needed` | Technically allowed, but the business/security intent must be confirmed before marking it safe. |

---

## 3. Role Model

Current application roles:

| Role | Description | Matrix Status |
|---|---|---|
| `owner` | Company owner. Expected to have full company-level access. | Needs Manual Role Test |
| `admin` | Company admin. Expected to manage most operational and configuration areas except owner-only actions. | Needs Manual Role Test |
| `warehouse_manager` | Operational manager. Expected to manage workers, tools, lookups, transactions, and approval workflow depending on backend rules. | Needs Manual Role Test |
| `warehouse_user` | Operational user. Expected to create transactions and upload transaction proofs, but not approve lost/damaged workflows or upload approval documents. | Needs Manual Role Test |
| `viewer` | Read/report-only role. Expected to have no write access. | Needs Manual Role Test |

---

## 4. Flutter Permission Intent Matrix

This section maps the Flutter UI permission intent.  
These permissions must be verified against backend enforcement.

| Area | Permission | Owner | Admin | Warehouse Manager | Warehouse User | Viewer | Backend Status |
|---|---|---:|---:|---:|---:|---:|---|
| Dashboard | View dashboard | Yes | Yes | Yes | Yes | Yes | Needs Manual Role Test |
| Workers | View workers | Yes | Yes | Yes | Yes | No / Limited | Needs Manual Role Test |
| Workers | Create workers | Yes | Yes | Yes | No | No | Gap Found |
| Workers | Update workers | Yes | Yes | Yes | No | No | Gap Found |
| Workers | Delete/deactivate workers | Yes | Yes | Yes | No | No | Gap Found |
| Tools | View tools | Yes | Yes | Yes | Yes | No / Limited | Needs Manual Role Test |
| Tools | Create tools | Yes | Yes | Yes | No | No | Gap Found |
| Tools | Update tools | Yes | Yes | Yes | No | No | Gap Found |
| Tools | Delete/deactivate tools | Yes | Yes | Yes | No | No | Gap Found |
| Transactions | View transactions | Yes | Yes | Yes | Yes | No / Limited | Needs Manual Role Test |
| Transactions | Create transactions | Yes | Yes | Yes | Yes | No | Needs Manual Role Test |
| Transactions | General transaction edit | No / Disabled | No / Disabled | No / Disabled | No / Disabled | No | Verified by policy inspection: no direct transaction write policies detected |
| Approval Workflow | Upload approval document | Yes | Yes | Yes | No | No | Needs Manual Role Test |
| Approval Workflow | Read approval document | Business decision | Business decision | Business decision | Business decision | Business decision | Gap Found / Business Decision Needed |
| Approval Workflow | Approve lost/damaged | Yes | Yes | Yes | No | No | Needs Manual Role Test |
| Approval Workflow | Reject lost/damaged | Yes | Yes | Yes | No | No | Needs Manual Role Test |
| Approval Workflow | Settle lost/damaged | Yes | Yes | Yes | No | No | Needs Manual Role Test |
| Reports | View reports | Yes | Yes | Yes | Yes | Yes | Needs Manual Role Test |
| Reports | Generate reports | Yes | Yes | Yes | Yes | Yes | Needs Manual Role Test |
| Lookups | View lookups | Yes | Yes | Yes | No / Limited | No | Needs Manual Role Test |
| Lookups | Create lookups | Yes | Yes | Yes | No | No | Verified by policy inspection, but direct-write hardening needed |
| Lookups | Delete lookups | Yes | Yes | Yes | No | No | Verified by policy inspection, but direct-write hardening needed |
| Company Settings | View settings | Yes | Yes | No / Limited | No | No | Needs Manual Role Test |
| Company Settings | Manage company profile | Yes | Yes | No | No | No | Verified by policy inspection, duplicate policies need cleanup |
| Company Settings | Upload company logo | Yes | Yes | No | No | No | Verified by storage policy inspection, duplicate policies need cleanup |
| Company Settings | Manage report settings | Yes | Yes | No | No | No | Verified by policy inspection, duplicate policies need cleanup |
| Company Settings | Manage document templates | Yes | Yes | No | No | No | Verified by policy inspection |
| Company Users | View company users | Yes | Yes | No / Limited | No | No | Needs Manual Role Test |
| Company Users | Invite users | Yes | Yes | No | No | No | Needs Manual Role Test |
| Company Users | Cancel invitations | Yes | Yes | No | No | No | Needs Manual Role Test |
| Company Users | Change member role | Yes | Yes | No | No | No | Gap Found |
| Company Users | Deactivate/reactivate members | Yes | Yes | Yes for lower roles only | No | No | Gap Found |
| Audit Logs | View audit logs | Yes | Yes | Possibly Manager | No | No | Needs Business Decision |
| Audit Logs | Write audit logs | Backend only | Backend only | Backend only | Backend only | Backend only | Verified by grants/policy inspection |

---

## 5. Business Tables RLS Matrix

### 5.1 Core identity and tenancy tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `profiles` | User profile linked to Supabase auth user. | Select current profile and joined display data. | Users should only access own profile, invited-user context, and active company member profile data. | Verified by policy inspection, cleanup recommended | Multiple overlapping own-profile read policies exist. |
| `companies` | Company tenant record and company profile. | Select and direct update from company settings. | Active company members can read. Owner/admin can update company profile fields. Cross-company update blocked by policy. | Verified by policy inspection, cleanup recommended | Duplicate/overlapping update policies exist. |
| `company_members` | Company membership, role, and status. | Select active memberships and company team members. | Active members can read company members. Mutations should go through secure member-management RPCs. | Gap Found | Direct owner INSERT/UPDATE policies exist and may bypass lifecycle RPC rules/audit logic. |
| `company_invitations` | Company invitations. | Select invitations. Mutations through RPCs. | Invited users can read own pending invitations. Owners/admins can read company invitations. Direct insert/update/delete should be closed. | Verified by policy inspection | Only SELECT policies detected in policy query result. |
| `profiles` | User profile record. | Auth Cubit creates profile indirectly through auth flow / triggers if configured. | Users can insert/update own profile only. Company members can read active member profiles. | Verified by policy inspection | Multiple read policies should be cleaned later to reduce confusion. |

### 5.2 Company configuration tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `company_report_settings` | Report formatting and report statement settings. | Select and direct update. | Active company members can read. Owner/admin can update. Cross-company update blocked. | Verified by policy inspection, cleanup recommended | Multiple overlapping read/update policies exist. |
| `company_document_templates` | Document titles/codes/signature labels per report type. | Select and direct update. | Active company members can read. Owner/admin can insert/update. Cross-company update blocked. | Verified by policy inspection | Important before signed PDFs. |

### 5.3 Operational lookup tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `departments` | Worker department lookup. | Select, insert, update, delete. | Active company members can read. Owner/admin/warehouse_manager can insert/update/delete. Cross-company writes blocked by `with_check`. | Verified by policy inspection, hardening recommended | Direct writes are intentionally allowed by current policies. Consider RPC for audit/validation. |
| `job_titles` | Worker job title lookup. | Select, insert, update, delete. | Active company members can read. Owner/admin/warehouse_manager can insert/update/delete. Cross-company writes blocked by `with_check`. | Verified by policy inspection, hardening recommended | Direct writes are intentionally allowed by current policies. Need relationship validation review. |
| `tool_units` | Tool unit lookup. | Select, insert, update, delete. | Active company members can read. Owner/admin/warehouse_manager can insert/update/delete. Cross-company writes blocked by `with_check`. | Verified by policy inspection, hardening recommended | Direct writes are intentionally allowed by current policies. |
| `tool_categories` | Tool category lookup. | Select, insert, update, delete. | Active company members can read. Owner/admin/warehouse_manager can insert/update/delete. Cross-company writes blocked by `with_check`. | Verified by policy inspection, hardening recommended | Direct writes are intentionally allowed by current policies. |

### 5.4 Operational master tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `workers` | Worker master data. | Select. Mutations through RPCs in Flutter. | Active members can read. Mutations should be enforced by RPCs only if RPC-controlled architecture is intended. | Gap Found | Policies allow owner/admin/warehouse_manager direct INSERT/UPDATE/DELETE, while table grants currently show authenticated SELECT only. This mismatch requires review. |
| `tools` | Tool master data. | Select. Mutations through RPCs in Flutter. | Active members can read. Mutations should be enforced by RPCs only if RPC-controlled architecture is intended. | Gap Found | Policies allow owner/admin/warehouse_manager direct INSERT/UPDATE/DELETE, while table grants currently show authenticated SELECT only. This mismatch requires review. |

### 5.5 Transaction and audit tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `transactions` | Custody transactions and lost/damaged workflow. | Select. Mutations through RPCs. | Active members can read. Direct insert/update/delete blocked. Mutations enforced by RPCs. | Verified by policy inspection | Only SELECT policy detected for authenticated company members. |
| `audit_logs` | Immutable audit trail. | Select only. | Company members can read. Direct insert/update/delete from authenticated client blocked. Writes should be backend-only. | Verified by policy/grants inspection, business decision needed | All active company members can currently read audit logs via `private.is_company_member(company_id)`. Confirm if viewer/warehouse_user should read audit logs. |
| `storage.objects` | Supabase Storage metadata. | Used indirectly through Supabase Storage API. | Policies enforce bucket, company path, role, and operation. | Gap Found / Business Decision Needed | Approval document read policy appears broad for all active company members. `custody-documents` bucket also exists and must be tracked. |

---

## 6. RPC Verification Matrix

### 6.1 Company / context RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_company_with_defaults` | Create a new company and default setup. | Authenticated user creating own company. | Anonymous users. | Gap Found | Function grants show `PUBLIC EXECUTE`. Revoke from PUBLIC should be reviewed. Function is `SECURITY DEFINER` with `search_path=""`. |

### 6.2 Company users and invitations RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `invite_company_user` | Create secure company invitation. | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `accept_company_invitation` | Accept invitation. | Invited authenticated user with matching email and valid pending invitation. | Non-invited users, expired/cancelled invitations | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `cancel_company_invitation` | Cancel pending invitation. | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `change_company_member_role` | Change member role. | Owner; Admin for lower roles only | Self-change, owner target, admin managing admin, lower roles | Grant Verified / Gap Found | Direct company_members update policy may bypass RPC rules. Manual RPC tests still required. |
| `deactivate_company_member` | Soft deactivate member. | Owner; Admin lower roles; Warehouse Manager lower roles if intended | Self-deactivation, owner target, same/higher role target | Grant Verified / Gap Found | Direct company_members update policy may bypass RPC rules. Manual RPC tests still required. |
| `reactivate_company_member` | Reactivate inactive member. | Owner; Admin lower roles; Warehouse Manager lower roles if intended | Self-reactivation, owner target, same/higher role target | Grant Verified / Gap Found | Direct company_members update policy may bypass RPC rules. Manual RPC tests still required. |

### 6.3 Worker RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_worker` | Create worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `update_worker` | Update worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `deactivate_worker` | Soft deactivate worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `reactivate_worker` | Reactivate worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |

### 6.4 Tool RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_tool` | Create tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `update_tool` | Update tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `deactivate_tool` | Soft deactivate tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `reactivate_tool` | Reactivate tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |

### 6.5 Transaction RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_custody_transaction` | Create issue/return/lost/damaged transaction. | Owner, Admin, Warehouse Manager, Warehouse User | Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `upload_transaction_proof_image` | Link proof image after Storage upload. | Owner, Admin, Warehouse Manager, Warehouse User | Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `upload_transaction_approval_document` | Link signed approval document. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. Critical for Issue #28 signed PDFs. |
| `approve_lost_damaged_transaction` | Approve lost/damaged transaction. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `reject_lost_damaged_transaction` | Reject lost/damaged transaction. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `settle_lost_damaged_transaction` | Settle approved lost/damaged transaction. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |
| `rollback_failed_transaction_proof_upload` | Roll back incomplete transaction after failed proof image linking. | Creator with Owner/Admin/Warehouse Manager/Warehouse User role within short rollback window | Viewer, inactive members, non-creator, expired rollback window | Grant Verified / Manual Role Test Needed | `authenticated` execute grant detected. Function is `SECURITY DEFINER`. |

---

## 7. RPC Grant Verification Matrix

Each exposed RPC should be checked for secure grants.

| RPC | Revoke From Public | Grant To Authenticated | Auth Check | Active Membership Check | Role Check | Safe Search Path | Status |
|---|---|---|---|---|---|---|---|
| `create_company_with_defaults` | Gap Found | Verified | Needs Function Body Review | Not Applicable / Needs Function Body Review | Needs Function Body Review | Verified | Gap Found |
| `invite_company_user` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `accept_company_invitation` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `cancel_company_invitation` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `change_company_member_role` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `deactivate_company_member` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `reactivate_company_member` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `create_worker` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `update_worker` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `deactivate_worker` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `reactivate_worker` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `create_tool` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `update_tool` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `deactivate_tool` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `reactivate_tool` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `create_custody_transaction` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `upload_transaction_proof_image` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `upload_transaction_approval_document` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `approve_lost_damaged_transaction` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `reject_lost_damaged_transaction` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `settle_lost_damaged_transaction` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |
| `rollback_failed_transaction_proof_upload` | Verified | Verified | Needs Function Body Review | Needs Function Body Review | Needs Function Body Review | Verified | Grant Verified / Body Review Needed |

---

## 8. Storage Bucket Verification Matrix

| Bucket | Purpose | Expected Upload Roles | Expected Read Roles | Expected Delete Roles | Path Format | Verification Status | Notes |
|---|---|---|---|---|---|---|---|
| `company-assets` | Company logo and company asset files. | Owner, Admin | Active company members | Owner, Admin | `{companyId}/logo/company-logo-{timestamp}.{ext}` | Verified by bucket/policy inspection, cleanup recommended | Bucket is private. Duplicate/overlapping upload/read policies exist. |
| `transaction-proofs` | Transaction proof images. | Owner, Admin, Warehouse Manager, Warehouse User | Active company members | Owner, Admin, Warehouse Manager, Warehouse User | `{companyId}/transactions/{TRX-code}/proof-{timestamp}.{ext}` | Verified by bucket/policy inspection | Bucket is private. Upload/delete/read policies detected. |
| `transaction-approval-documents` | Signed approval documents for lost/damaged transactions. | Owner, Admin, Warehouse Manager | Active company members currently | Owner, Admin, Warehouse Manager | `{companyId}/transactions/{TRX-code}/approval-document-{timestamp}.{ext}` | Gap Found / Business Decision Needed | Bucket is private, file size limit is 10MB, mime types restricted. Read policy currently allows all active company members. |
| `custody-documents` | Existing custody document Storage bucket. | Owner, Admin, Warehouse User according to detected policy | Active company members | Not confirmed | `{companyId}/...` based on helper path extraction | Business Decision Needed | Bucket exists and has policies, but it was not part of the original three-bucket inventory. Must decide whether it is legacy, active, or should be removed/refactored. |

---

## 9. Direct Write Verification Matrix

These are the highest-priority RLS checks because Flutter writes directly to some tables.

| Table | Operation | Expected Allowed Roles | Expected Denied Roles | Required RLS Checks | Verification Status |
|---|---|---|---|---|---|
| `companies` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only own active company. Cannot cross-company update. Cannot spoof protected fields. | Verified by policy inspection, cleanup recommended |
| `company_report_settings` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only settings for active company membership. Cannot cross-company update. | Verified by policy inspection, cleanup recommended |
| `company_document_templates` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only templates for active company membership. Cannot cross-company update. | Verified by policy inspection |
| `departments` | insert | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Insert company_id must be an active company where caller has allowed role. | Verified by policy inspection, hardening recommended |
| `departments` | update | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Update only same-company records. Confirm direct update is intended. | Verified by policy inspection, hardening recommended |
| `departments` | delete | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Delete only same-company records. Confirm hard delete is intended. | Verified by policy inspection, hardening recommended |
| `job_titles` | insert | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Insert company_id and department_id must belong to same company. | Verified by policy inspection, relationship validation still needed |
| `job_titles` | update | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Update only same-company records. Confirm department relationship cannot be corrupted. | Verified by policy inspection, relationship validation still needed |
| `job_titles` | delete | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Delete only same-company records. Confirm hard delete is intended. | Verified by policy inspection, hardening recommended |
| `tool_units` | insert | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Insert company_id must be an active company where caller has allowed role. | Verified by policy inspection, hardening recommended |
| `tool_units` | update | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Update only same-company records. | Verified by policy inspection, hardening recommended |
| `tool_units` | delete | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Delete only same-company records. Confirm hard delete is intended. | Verified by policy inspection, hardening recommended |
| `tool_categories` | insert | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Insert company_id must be an active company where caller has allowed role. | Verified by policy inspection, hardening recommended |
| `tool_categories` | update | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Update only same-company records. | Verified by policy inspection, hardening recommended |
| `tool_categories` | delete | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Delete only same-company records. Confirm hard delete is intended. | Verified by policy inspection, hardening recommended |
| `company_members` | insert/update | Owner only by policy | Non-owner roles | Should ideally go through RPC only to enforce lifecycle hierarchy and audit logging. | Gap Found |
| `workers` | insert/update/delete | Owner, Admin, Warehouse Manager by policy | Warehouse User, Viewer, inactive members | Should ideally go through RPC only to enforce validation and audit logging. | Gap Found |
| `tools` | insert/update/delete | Owner, Admin, Warehouse Manager by policy | Warehouse User, Viewer, inactive members | Should ideally go through RPC only to enforce validation and audit logging. | Gap Found |

---

## 10. Direct Write Recommendation Tracker

This section records whether a direct-write area should remain direct with strong RLS or be moved behind RPCs.

| Area | Current Pattern | Recommended Decision | Status | Notes |
|---|---|---|---|---|
| Company profile update | Direct update | Keep only if RLS and accountability are strict; otherwise move to RPC. | Verified with cleanup recommended | Duplicate policies should be cleaned later. |
| Company report settings update | Direct update | Keep only if RLS is strict; otherwise move to RPC. | Verified with cleanup recommended | Duplicate policies should be cleaned later. |
| Company document templates update | Direct update | Keep only if RLS is strict; otherwise move to RPC. | Verified | Important before signed PDFs. |
| Lookup creation/update/deletion | Direct insert/update/delete | Consider moving to RPCs if audit/accountability is required. | Verified with hardening recommended | Current RLS restricts writes to owner/admin/warehouse_manager. |
| Company member mutation | Direct insert/update still allowed for owner | Move fully behind RPCs unless there is a strong reason to keep owner direct write. | Gap Found | May bypass member-management RPC rules. |
| Workers/tools mutation | Direct policies exist, but table grants show authenticated SELECT only | Review mismatch and decide whether to remove policies or keep direct writes. | Gap Found | Flutter uses RPCs for these mutations. |

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

Result:

- RLS is enabled on all listed business tables.

Verification Status: Verified

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

Result:

Confirmed:

- Public business tables have policies.
- `company_invitations` does not show direct INSERT/UPDATE/DELETE policies in this result.
- `transactions` does not show direct INSERT/UPDATE/DELETE policies in this result.
- `audit_logs` does not show direct INSERT/UPDATE/DELETE policies in this result.
- Lookup tables are restricted by role-based RLS policies.
- Company settings tables are restricted to owner/admin policies.

Gaps found:

- `company_members` still allows direct INSERT/UPDATE for owner.
- `workers` still has direct INSERT/UPDATE/DELETE policies for owner/admin/warehouse_manager.
- `tools` still has direct INSERT/UPDATE/DELETE policies for owner/admin/warehouse_manager.

Cleanup note:

- Some overlapping policies exist on `companies`, `company_report_settings`, and `profiles`.

Verification Status: Gap Found

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

Result:

Confirmed:

- `company-assets` has upload/read/update/delete policies.
- `transaction-proofs` has upload/read/delete policies.
- `transaction-approval-documents` has upload/read/delete policies.
- Policies generally check bucket ID and company membership/roles.
- Upload policy for `transaction-approval-documents` restricts extensions to PDF/JPG/JPEG/PNG/WEBP.
- Upload/delete policy for `transaction-approval-documents` is limited to owner/admin/warehouse_manager.

Gaps / decisions found:

- `transaction-approval-documents` read policy allows active company members through `private.is_company_member`, which may include warehouse_user and viewer.
- `custody-documents` policies exist and must be added to the matrix.
- `company-assets` has overlapping old/new policies.

Verification Status: Gap Found / Business Decision Needed

---

### 11.4 Confirm Storage buckets

    select
      id,
      name,
      public,
      file_size_limit,
      allowed_mime_types
    from storage.buckets
    order by id;

Result:

Confirmed buckets:

- `company-assets`
- `custody-documents`
- `transaction-approval-documents`
- `transaction-proofs`

Confirmed:

- All detected buckets are private.
- `transaction-approval-documents` has a 10MB file size limit.
- `transaction-approval-documents` restricts MIME types to:
  - `application/pdf`
  - `image/jpeg`
  - `image/png`
  - `image/webp`

Verification Status: Verified, with Business Decision Needed for `custody-documents`

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

Result:

Confirmed:

- Critical mutation RPCs are present.
- Critical mutation RPCs are `SECURITY DEFINER`.
- Most critical RPCs use safe `search_path` configuration such as:
  - `search_path=""`
  - `search_path=public, private`
- Private helper functions are present.

Notes:

- `private.company_id_from_storage_path` is `SECURITY INVOKER` with no function config. This may be acceptable if it is a simple path parser, but the function body should be reviewed.
- This query verifies function presence/security mode, not internal business logic.

Verification Status: Verified for presence/security mode, Function Body Review Needed

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

Result:

Confirmed:

- Most exposed RPCs have EXECUTE granted to `authenticated`.
- Expected `postgres` EXECUTE grants exist.

Gap found:

- `create_company_with_defaults` has EXECUTE granted to `PUBLIC`.

Verification Status: Gap Found

---

### 11.7 Confirm table grants

    select
      grantee,
      table_name,
      string_agg(privilege_type, ', ' order by privilege_type) as privileges
    from information_schema.role_table_grants
    where table_schema = 'public'
      and grantee in ('authenticated', 'anon')
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
    group by grantee, table_name
    order by grantee, table_name;

Result:

Confirmed:

- `authenticated` has SELECT on:
  - `audit_logs`
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
- `authenticated` has UPDATE on:
  - `companies`
  - `company_document_templates`
  - `company_report_settings`
- `authenticated` has INSERT/UPDATE/DELETE on:
  - `departments`
  - `job_titles`
  - `tool_categories`
  - `tool_units`
- `authenticated` only has SELECT on:
  - `tools`
  - `workers`
  - `transactions`
  - `audit_logs`
  - `company_invitations`

Notes:

- Direct table grants align with lookup direct-write design.
- Direct table grants do not show authenticated INSERT/UPDATE/DELETE on workers/tools, even though policies exist for those operations. This mismatch should be reviewed.
- `anon` has non-DML privileges such as REFERENCES/TRIGGER/TRUNCATE on some tables. This should be reviewed for least privilege, even if not exposed through normal PostgREST workflows.

Verification Status: Verified with cleanup review needed

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

Result:

Confirmed:

- `authenticated` has SELECT only on `audit_logs`.
- No authenticated INSERT/UPDATE/DELETE grant was detected for `audit_logs`.

Verification Status: Verified

---

### 11.9 Confirm service role key is not in repository

PowerShell command used:

    $patterns = @(
      "service_role",
      "SERVICE_ROLE",
      "supabase_service",
      "SUPABASE_SERVICE",
      "SUPABASE_SERVICE_ROLE"
    )

    Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object {
        $_.FullName -notmatch "\\.git\\" -and
        $_.FullName -notmatch "\\build\\" -and
        $_.FullName -notmatch "\\.dart_tool\\"
      } |
      Select-String -Pattern $patterns -SimpleMatch

Result:

- Matches found only inside documentation files:
  - `docs/security/security_rls_verification_matrix.md`
  - `docs/security/security_surface_review.md`
- Matches are only search command text, not real keys.

Verification Status: Verified

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
| User from Company A attempts to read Company B workers. | Denied / no rows returned. | Needs Manual Test |
| User from Company A attempts to update Company B settings. | Denied. | Needs Manual Test |
| User from Company A attempts to create lookup with Company B ID. | Denied. | Needs Manual Test |
| User from Company A attempts to upload Storage file under Company B path. | Denied. | Needs Manual Test |
| User from Company A attempts to create signed URL for Company B approval document. | Denied. | Needs Manual Test |

---

### 12.3 Viewer restriction tests

| Test | Expected Result | Status |
|---|---|---|
| Viewer attempts to create worker. | Denied. | Needs Manual Test |
| Viewer attempts to update company profile. | Denied. | Needs Manual Test |
| Viewer attempts to create lookup. | Denied. | Needs Manual Test |
| Viewer attempts to create transaction. | Denied. | Needs Manual Test |
| Viewer attempts to upload transaction proof. | Denied. | Needs Manual Test |
| Viewer attempts to upload approval document. | Denied. | Needs Manual Test |
| Viewer attempts to read approval document. | Business decision needed. | Needs Manual Test |
| Viewer attempts to approve lost/damaged transaction. | Denied. | Needs Manual Test |
| Viewer attempts to read audit logs. | Business decision needed. | Needs Manual Test |

---

### 12.4 Warehouse User restriction tests

| Test | Expected Result | Status |
|---|---|---|
| Warehouse User creates transaction. | Allowed. | Needs Manual Test |
| Warehouse User uploads transaction proof. | Allowed. | Needs Manual Test |
| Warehouse User uploads approval document. | Denied. | Needs Manual Test |
| Warehouse User reads approval document. | Business decision needed. | Needs Manual Test |
| Warehouse User approves lost/damaged transaction. | Denied. | Needs Manual Test |
| Warehouse User settles lost/damaged transaction. | Denied. | Needs Manual Test |
| Warehouse User creates worker. | Denied. | Needs Manual Test |
| Warehouse User creates tool. | Denied. | Needs Manual Test |
| Warehouse User updates company settings. | Denied. | Needs Manual Test |

---

### 12.5 Warehouse Manager tests

| Test | Expected Result | Status |
|---|---|---|
| Warehouse Manager creates worker. | Allowed. | Needs Manual Test |
| Warehouse Manager creates tool. | Allowed. | Needs Manual Test |
| Warehouse Manager creates lookup. | Allowed if business rule remains intended. | Needs Manual Test |
| Warehouse Manager uploads approval document. | Allowed. | Needs Manual Test |
| Warehouse Manager approves lost/damaged transaction. | Allowed. | Needs Manual Test |
| Warehouse Manager manages Warehouse User member lifecycle. | Allowed if intended. | Needs Manual Test |
| Warehouse Manager manages another Warehouse Manager. | Denied. | Needs Manual Test |
| Warehouse Manager manages Admin. | Denied. | Needs Manual Test |
| Warehouse Manager manages Owner. | Denied. | Needs Manual Test |

---

### 12.6 Admin tests

| Test | Expected Result | Status |
|---|---|---|
| Admin invites Warehouse Manager. | Allowed. | Needs Manual Test |
| Admin invites Admin. | Denied. | Needs Manual Test |
| Admin invites Owner. | Denied. | Needs Manual Test |
| Admin changes Warehouse User role to Viewer. | Allowed. | Needs Manual Test |
| Admin changes another Admin role. | Denied. | Needs Manual Test |
| Admin deactivates Owner. | Denied. | Needs Manual Test |
| Admin updates company settings. | Allowed. | Needs Manual Test |
| Admin uploads company logo. | Allowed. | Needs Manual Test |

---

### 12.7 Owner tests

| Test | Expected Result | Status |
|---|---|---|
| Owner invites Admin. | Allowed. | Needs Manual Test |
| Owner invites Owner through normal invite flow. | Denied. | Needs Manual Test |
| Owner changes Admin role to Warehouse Manager. | Allowed. | Needs Manual Test |
| Owner deactivates Admin. | Allowed. | Needs Manual Test |
| Owner deactivates own membership. | Denied. | Needs Manual Test |
| Owner updates company settings. | Allowed. | Needs Manual Test |
| Owner uploads company logo. | Allowed. | Needs Manual Test |

---

### 12.8 Inactive member tests

| Test | Expected Result | Status |
|---|---|---|
| Inactive member reads company data. | Denied / no rows returned. | Needs Manual Test |
| Inactive member creates transaction. | Denied. | Needs Manual Test |
| Inactive member uploads Storage object. | Denied. | Needs Manual Test |
| Inactive member calls any company mutation RPC. | Denied. | Needs Manual Test |
| Inactive member creates signed URL. | Denied. | Needs Manual Test |

---

### 12.9 Audit log tests

| Test | Expected Result | Status |
|---|---|---|
| Authorized user reads company audit logs. | Allowed according to business rule. | Needs Manual Test |
| Unauthorized company member reads audit logs. | Denied. | Needs Manual Test |
| Viewer reads audit logs. | Business decision needed. | Needs Manual Test |
| Authenticated user directly inserts audit log. | Denied. | Verified by grants / Needs Manual Test |
| Authenticated user directly updates audit log. | Denied. | Verified by grants / Needs Manual Test |
| Authenticated user directly deletes audit log. | Denied. | Verified by grants / Needs Manual Test |
| Critical RPC writes audit log. | Allowed through backend function only. | Needs Manual Test |

---

## 13. Gap Register

Use this section to record issues found during verification.

| Gap ID | Area | Description | Severity | Recommended Action | GitHub Issue | Status |
|---|---|---|---|---|---|---|
| GAP-001 | Company Members | `company_members` allows direct INSERT/UPDATE for owner, which may bypass secure member-management RPC rules and audit flow. | High | Review whether direct owner writes should be removed and replaced fully by RPC-controlled lifecycle actions. | TBD | Open |
| GAP-002 | Workers / Tools | `workers` and `tools` have direct INSERT/UPDATE/DELETE policies for owner/admin/warehouse_manager even though Flutter uses RPCs for mutations. | High | Review whether direct worker/tool write policies should be removed so mutations must go through RPCs, or document why policies should remain. | TBD | Open |
| GAP-003 | Approval Document Read Access | `transaction-approval-documents` read policy allows active company members, which may include warehouse_user and viewer. | High | Decide intended read roles before Issue #28 signed PDFs. If documents are sensitive, restrict read/signed URL access to owner/admin/warehouse_manager or approved report roles only. | TBD | Open |
| GAP-004 | Public Execute Grant | `create_company_with_defaults` has EXECUTE granted to PUBLIC. | Medium / High | Revoke EXECUTE from PUBLIC and keep EXECUTE for authenticated only, unless a verified reason exists. | TBD | Open |
| GAP-005 | Custody Documents Bucket | `custody-documents` bucket and policies exist but were not part of the original active Flutter storage inventory. | Medium | Decide whether this bucket is active, legacy, or should be removed/refactored. Add it to the storage matrix until resolved. | TBD | Open |
| GAP-006 | Policy Cleanup | Some overlapping policies exist on `companies`, `company_report_settings`, `profiles`, and `company-assets`. | Low | Review and clean duplicate/legacy policies after functional security is confirmed. | TBD | Open |
| GAP-007 | Broad Non-DML Grants | `anon` and `authenticated` have broad non-DML grants such as REFERENCES/TRIGGER/TRUNCATE on some tables. | Low / Medium | Review least-privilege grants. Confirm whether these are Supabase defaults and whether they can be safely tightened. | TBD | Open |
| GAP-008 | Direct Lookup Writes | Lookup tables allow direct INSERT/UPDATE/DELETE for owner/admin/warehouse_manager. This is currently protected by RLS but bypasses RPC-level audit/validation if needed later. | Medium | Decide whether lookup mutations should remain direct-RLS or move to RPCs for stronger auditability. | TBD | Open |

---

## 14. Verification Progress Tracker

| Section | Status | Notes |
|---|---|---|
| Role model matrix | Drafted | Manual role tests still required. |
| Business table matrix | SQL policy inspection partially verified | Some gaps found around direct writes and policy cleanup. |
| RPC matrix | Grants and security mode inspected | Function body review and manual role tests still required. |
| Storage matrix | Policies and buckets inspected | Approval document read access and custody-documents bucket require decisions. |
| Direct write matrix | Inspected | Company members, workers/tools, and lookup write paths require hardening decisions. |
| Manual SQL queries | Mostly completed | 11.1 through 11.9 completed with findings. |
| Critical role tests | Drafted | Requires test users. |
| Gap register | Updated | 8 current gaps recorded. |

---

## 15. Step 16.3 Conclusion

Step 16.3 completed the first SQL inspection pass.

Confirmed:

- RLS is enabled on all reviewed business tables.
- Public table policies exist for all reviewed business tables.
- Storage buckets are private.
- Storage policies exist for the reviewed buckets.
- Critical RPCs exist and are mostly `SECURITY DEFINER`.
- Most exposed RPCs grant EXECUTE to `authenticated`.
- `audit_logs` does not allow direct authenticated INSERT/UPDATE/DELETE by grants.
- No service role key was found in the local repository scan. Only documentation search-command text matched the scanned patterns.

Gaps found:

- Direct owner INSERT/UPDATE remains on `company_members`.
- Direct worker/tool write policies exist despite RPC mutation architecture.
- Approval document read access appears broad for all active company members.
- `create_company_with_defaults` has PUBLIC EXECUTE.
- `custody-documents` bucket exists and must be classified.
- Duplicate/overlapping policies should be cleaned later.
- Broad non-DML grants should be reviewed for least privilege.
- Lookup direct writes should be reviewed for audit and validation requirements.

Next recommended step:

- Step 16.4 — Convert confirmed gaps into separate GitHub issues or define one hardening plan issue for:
  - direct member mutation hardening
  - worker/tool direct write policy cleanup
  - approval document read restriction
  - PUBLIC EXECUTE revoke
  - custody-documents bucket decision
  - policy/grant cleanup