# Issue #16 — Security / RLS Verification Matrix

Status: Final closure review in progress  
Step: 16.5 — Final broad grants cleanup incorporated  
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

This file records verified facts separately from assumptions.

---

## 2. Verification Status Legend

| Status | Meaning |
|---|---|
| `Verified` | Confirmed through actual Supabase SQL inspection, repository review, or manual role test. |
| `Needs Verification` | Expected behavior is known, but actual Supabase state or app behavior still needs confirmation. |
| `Gap Found` | A security gap was identified and should become a separate GitHub issue. |
| `Not Applicable` | This check does not apply to the item. |
| `Documented Only` | Mentioned in repository docs, but not yet verified against live Supabase state. |
| `Business Decision Needed` | Technically allowed, but the business/security intent must be confirmed before marking it safe. |
| `Closed / Completed` | Confirmed through a closed follow-up issue and documented in the repo. |

---

## 3. Role Model

Current application roles:

| Role | Description | Matrix Status |
|---|---|---|
| `owner` | Company owner. Expected to have full company-level access. | Needs broader manual role test |
| `admin` | Company admin. Expected to manage most operational and configuration areas except owner-only actions. | Needs broader manual role test |
| `warehouse_manager` | Operational manager. Expected to manage workers, tools, lookups, transactions, and approval workflow depending on backend rules. | Needs broader manual role test |
| `warehouse_user` | Operational user. Expected to create transactions and upload transaction proofs, but not approve lost/damaged workflows or upload approval documents. | Needs broader manual role test |
| `viewer` | Full read-only company role. Can view operational/reporting data, but cannot perform mutation actions. Settings is intentionally hidden. | Verified through Issue #29 |

---

## 4. Flutter Permission Intent Matrix

This section maps the Flutter UI permission intent.  
These permissions must be verified against backend enforcement.

| Area | Permission | Owner | Admin | Warehouse Manager | Warehouse User | Viewer | Backend / Verification Status |
|---|---|---:|---:|---:|---:|---:|---|
| Dashboard | View dashboard | Yes | Yes | Yes | Yes | Yes | Viewer verified through Issue #29; broader role tests still recommended |
| Workers | View workers | Yes | Yes | Yes | Yes | Yes | Viewer read-only access verified through Issue #29 |
| Workers | Create workers | Yes | Yes | Yes | No | No | Mutations RPC-only through Issue #32 |
| Workers | Update workers | Yes | Yes | Yes | No | No | Mutations RPC-only through Issue #32 |
| Workers | Delete/deactivate workers | Yes | Yes | Yes | No | No | Mutations RPC-only through Issue #32 |
| Tools | View tools | Yes | Yes | Yes | Yes | Yes | Viewer read-only access verified through Issue #29 |
| Tools | Create tools | Yes | Yes | Yes | No | No | Mutations RPC-only through Issue #32 |
| Tools | Update tools | Yes | Yes | Yes | No | No | Mutations RPC-only through Issue #32 |
| Tools | Delete/deactivate tools | Yes | Yes | Yes | No | No | Mutations RPC-only through Issue #32 |
| Transactions | View transactions | Yes | Yes | Yes | Yes | Yes | Viewer read-only access verified through Issue #29 |
| Transactions | Create transactions | Yes | Yes | Yes | Yes | No | Needs broader manual role test |
| Transactions | General transaction edit | No / Disabled | No / Disabled | No / Disabled | No / Disabled | No | Verified by policy inspection: no direct transaction write policies detected |
| Approval Workflow | Upload approval document | Yes | Yes | Yes | No | No | Needs broader manual role test |
| Approval Workflow | Read approval document | Business decision | Business decision | Business decision | Business decision | Business decision | Gap Found / Business Decision Needed |
| Approval Workflow | Approve lost/damaged | Yes | Yes | Yes | No | No | Needs broader manual role test |
| Approval Workflow | Reject lost/damaged | Yes | Yes | Yes | No | No | Needs broader manual role test |
| Approval Workflow | Settle lost/damaged | Yes | Yes | Yes | No | No | Needs broader manual role test |
| Reports | View reports | Yes | Yes | Yes | Yes | Yes | Viewer read-only access verified through Issue #29 |
| Reports | Generate/read reports | Yes | Yes | Yes | Yes | Yes | Viewer reporting access verified through Issue #29; backend report restrictions still need broader testing |
| Lookups | View lookups | Yes | Yes | Yes | Possibly read-only depending UI | Yes | Viewer read-only access verified through Issue #29 |
| Lookups | Create lookups | Yes | Yes | Yes | No | No | RPC-only and table grants hardened through Issue #35 |
| Lookups | Deactivate / restore lookups | Yes | Yes | Yes | No | No | RPC-only and table grants hardened through Issue #35 |
| Company Settings | View settings | Yes | Yes | No / Limited | No | No | Viewer Settings tab intentionally hidden through Issue #29 |
| Company Settings | Manage company profile | Yes | Yes | No | No | No | Direct update retained; duplicate policies cleaned through Issue #34 |
| Company Settings | Upload company logo | Yes | Yes | No | No | No | Storage policy cleanup completed through Issue #34 |
| Company Settings | Manage report settings | Yes | Yes | No | No | No | Direct update retained; duplicate policies cleaned through Issue #34 |
| Company Settings | Manage document templates | Yes | Yes | No | No | No | Verified by policy inspection |
| Company Users / Team | View company users | Yes | Yes | Possibly read-only | No / Limited | Yes | Viewer Team read-only access verified through Issue #29 |
| Company Users / Team | Invite users | Yes | Yes | No | No | No | Mutations RPC-only through Issue #31 |
| Company Users / Team | Cancel invitations | Yes | Yes | No | No | No | Mutations RPC-only through Issue #31 |
| Company Users / Team | Change member role | Yes | Yes with hierarchy restrictions | No | No | No | Mutations RPC-only through Issue #31 |
| Company Users / Team | Deactivate/reactivate members | Yes | Yes with hierarchy restrictions | Possibly lower roles only if intended | No | No | Mutations RPC-only through Issue #31 |
| Audit Logs | View audit logs | Yes | Yes | Possibly Manager | No / Business decision | No / Business decision | Needs Business Decision |
| Audit Logs | Write audit logs | Backend only | Backend only | Backend only | Backend only | Backend only | Verified by grants/policy inspection |

---

## 5. Business Tables RLS Matrix

### 5.1 Core identity and tenancy tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `profiles` | User profile linked to Supabase auth user. | Select current profile and joined display data. | Users should only access own profile, invited-user context, and active company member profile data. | Verified / Cleaned through Issue #34 | Duplicate own-profile read policies were cleaned. `authenticated` has SELECT only; unnecessary non-DML grants were revoked from client roles on targeted tables. |
| `companies` | Company tenant record and company profile. | Select and direct update from company settings. | Active company members can read. Owner/admin can update company profile fields. Cross-company update blocked by policy. | Verified / Cleaned through Issue #34 | Duplicate update policies were cleaned. `authenticated` keeps SELECT/UPDATE only. |
| `company_members` | Company membership, role, and status. | Select active memberships and company team members. Mutations through RPCs. | Active members can read company members. All member-management mutations must go through secure RPCs. | Verified / Hardened through Issue #31 | Direct INSERT/UPDATE policies were removed. `authenticated` has SELECT only. `anon` has no direct privileges. |
| `company_invitations` | Company invitations. | Select invitations. Mutations through RPCs. | Invited users can read own pending invitations. Owners/admins can read company invitations. Direct insert/update/delete should remain closed. | Verified / Cleaned through Step 16.5 | Mutations are handled through invitation RPCs. Broad non-DML grants were removed through GAP-007 cleanup. |
| `profiles` | User profile record. | Auth Cubit creates profile indirectly through auth flow / triggers if configured. | Users can insert/update own profile only. Company members can read active member profiles. | Verified / Cleaned through Issue #34 | Own-profile read policies were simplified. |

### 5.2 Company configuration tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `company_report_settings` | Report formatting and report statement settings. | Select and direct update. | Active company members can read. Owner/admin can update. Cross-company update blocked. | Verified / Cleaned through Issue #34 | Duplicate read/update policies were cleaned. `authenticated` keeps SELECT/UPDATE only. |
| `company_document_templates` | Document titles/codes/signature labels per report type. | Select and direct update. | Active company members can read. Owner/admin can insert/update. Cross-company update blocked. | Verified by policy inspection | Important before signed PDFs. |

### 5.3 Operational lookup tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `departments` | Worker department lookup. | Select. Mutations through RPCs. | Active company members can read. Direct INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER privileges are removed from client roles. Create/deactivate/restore must go through RPCs. | Verified / Hardened through Issue #35 | `authenticated` has SELECT only. Direct table writes are blocked. See `docs/supabase/issue_35_lookup_rpc_mutation_flow.sql`. |
| `job_titles` | Worker job title lookup. | Select. Mutations through RPCs. | Active company members can read. Direct INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER privileges are removed from client roles. Create/deactivate/restore must go through RPCs. | Verified / Hardened through Issue #35 | `authenticated` has SELECT only. Direct table writes are blocked. Relationship validation and duplicate handling are enforced through the RPC/Flutter flow. |
| `tool_units` | Tool unit lookup. | Select. Mutations through RPCs. | Active company members can read. Direct INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER privileges are removed from client roles. Create/deactivate/restore must go through RPCs. | Verified / Hardened through Issue #35 | `authenticated` has SELECT only. Direct table writes are blocked. |
| `tool_categories` | Tool category lookup. | Select. Mutations through RPCs. | Active company members can read. Direct INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER privileges are removed from client roles. Create/deactivate/restore must go through RPCs. | Verified / Hardened through Issue #35 | `authenticated` has SELECT only. Direct table writes are blocked. |

### 5.4 Operational master tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `workers` | Worker master data. | Select. Mutations through RPCs in Flutter. | Active members can read. Worker create/update/deactivate/reactivate must go through secure RPCs. Direct table mutations are blocked. | Verified / Hardened through Issue #32 | Direct worker INSERT/UPDATE/DELETE policies were removed. `authenticated` has SELECT only. App worker flows were manually tested successfully. |
| `tools` | Tool master data. | Select. Mutations through RPCs in Flutter. | Active members can read. Tool create/update/deactivate/reactivate must go through secure RPCs. Direct table mutations are blocked. | Verified / Hardened through Issue #32 | Direct tool INSERT/UPDATE/DELETE policies were removed. `authenticated` has SELECT only. App tool flows were manually tested successfully. |

### 5.5 Transaction, custody, and audit tables

| Table | Purpose | Flutter Access | Expected RLS Behavior | Verification Status | Notes |
|---|---|---|---|---|---|
| `transactions` | Custody transactions and lost/damaged workflow. | Select. Mutations through RPCs. | Active members can read. Direct insert/update/delete blocked. Mutations enforced by RPCs. | Verified by policy inspection | Only SELECT policy detected for authenticated company members. |
| `custody_acknowledgements` | Future signed custody acknowledgement records. | Future signed PDF workflow. | Access should follow company membership and future signature workflow rules. | Broad grants cleaned through Step 16.5 | TRUNCATE / REFERENCES / TRIGGER removed from client roles through GAP-007 cleanup. |
| `custody_acknowledgement_items` | Future signed custody acknowledgement item records. | Future signed PDF workflow. | Access should follow company membership and future signature workflow rules. | Broad grants cleaned through Step 16.5 | TRUNCATE / REFERENCES / TRIGGER removed from client roles through GAP-007 cleanup. |
| `loss_damage_reports` | Future/related signed loss-damage report records. | Future signed PDF/report workflow. | Access should follow company membership and approval workflow rules. | Broad grants cleaned through Step 16.5 | TRUNCATE / REFERENCES / TRIGGER removed from client roles through GAP-007 cleanup. |
| `user_context_events` | User/current-context event tracking. | Internal context/realtime flow. | Client roles should not have broad non-DML privileges. | Broad grants cleaned through Step 16.5 | TRUNCATE / REFERENCES / TRIGGER removed from client roles through GAP-007 cleanup. |
| `audit_logs` | Immutable audit trail. | Select only. | Company members can read. Direct insert/update/delete from authenticated client blocked. Writes should be backend-only. | Verified by policy/grants inspection, business decision needed | All active company members can currently read audit logs via `private.is_company_member(company_id)`. Confirm if viewer/warehouse_user should read audit logs. |
| `storage.objects` | Supabase Storage metadata. | Used indirectly through Supabase Storage API. | Policies enforce bucket, company path, role, and operation. | Partially verified / Business Decision Needed | `company-assets` cleanup completed through Issue #34. `custody-documents` classified through Issue #33. Approval document read access still needs business decision if sensitive. |

---

## 6. RPC Verification Matrix

### 6.1 Company / context RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_company_with_defaults` | Create a new company and default setup. | Authenticated user creating own company. | Anonymous users / PUBLIC. | Verified / Hardened through Issue #30 | PUBLIC EXECUTE was revoked. `authenticated` EXECUTE remains. Flutter create-company flow was tested successfully. |

### 6.2 Company users and invitations RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `invite_company_user` | Create secure company invitation. | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | RPC-only member-management flow confirmed through Issue #31 | Direct `company_members` mutations were closed. |
| `accept_company_invitation` | Accept invitation. | Invited authenticated user with matching email and valid pending invitation. | Non-invited users, expired/cancelled invitations | RPC-only member-management flow confirmed through Issue #31 | Direct `company_members` mutations were closed. |
| `cancel_company_invitation` | Cancel pending invitation. | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | RPC-only member-management flow confirmed through Issue #31 | Direct `company_members` mutations were closed. |
| `change_company_member_role` | Change member role. | Owner; Admin for lower roles only | Self-change, owner target, admin managing admin, lower roles | RPC-only member-management flow confirmed through Issue #31; broader manual role tests still recommended | Direct update bypass risk was closed. |
| `deactivate_company_member` | Soft deactivate member. | Owner; Admin lower roles; Warehouse Manager lower roles if intended | Self-deactivation, owner target, same/higher role target | RPC-only member-management flow confirmed through Issue #31; broader manual role tests still recommended | Direct update bypass risk was closed. |
| `reactivate_company_member` | Reactivate inactive member. | Owner; Admin lower roles; Warehouse Manager lower roles if intended | Self-reactivation, owner target, same/higher role target | RPC-only member-management flow confirmed through Issue #31; broader manual role tests still recommended | Direct update bypass risk was closed. |

### 6.3 Worker RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_worker` | Create worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Verified / Hardened through Issue #32 | RPC exists, is SECURITY DEFINER, uses `search_path=""`, authenticated can execute, anon/public cannot. App test passed. |
| `update_worker` | Update worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Verified / Hardened through Issue #32 | RPC exists, is SECURITY DEFINER, uses `search_path=""`, authenticated can execute, anon/public cannot. App test passed. |
| `deactivate_worker` | Soft deactivate worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Verified / Hardened through Issue #32 | RPC exists, is SECURITY DEFINER, uses `search_path=""`, authenticated can execute, anon/public cannot. App test passed. |
| `reactivate_worker` | Reactivate worker. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Verified / Hardened through Issue #32 | RPC exists, is SECURITY DEFINER, uses `search_path=""`, authenticated can execute, anon/public cannot. App test passed. |

### 6.4 Tool RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_tool` | Create tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Verified / Hardened through Issue #32 | RPC exists, is SECURITY DEFINER, uses `search_path=""`, authenticated can execute, anon/public cannot. App test passed. |
| `update_tool` | Update tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Verified / Hardened through Issue #32 | RPC exists, is SECURITY DEFINER, uses `search_path=""`, authenticated can execute, anon/public cannot. App test passed. |
| `deactivate_tool` | Soft deactivate tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Verified / Hardened through Issue #32 | RPC exists, is SECURITY DEFINER, uses `search_path=""`, authenticated can execute, anon/public cannot. App test passed. |
| `reactivate_tool` | Reactivate tool. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members | Verified / Hardened through Issue #32 | RPC exists, is SECURITY DEFINER, uses `search_path=""`, authenticated can execute, anon/public cannot. App test passed. |

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

### 6.6 Lookup RPCs

| RPC | Purpose | Expected Allowed Roles | Expected Denied Roles | Verification Status | Notes |
|---|---|---|---|---|---|
| `create_department` | Create department lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Lookup mutations are RPC-controlled. |
| `deactivate_department` | Soft deactivate department lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Deactivate sets inactive instead of direct delete. |
| `reactivate_department` | Restore inactive department lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Restore is explicit. |
| `create_job_title` | Create job title lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Duplicate behavior includes active/inactive checks. |
| `deactivate_job_title` | Soft deactivate job title lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Deactivate sets inactive instead of direct delete. |
| `reactivate_job_title` | Restore inactive job title lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Restore is explicit. |
| `create_tool_unit` | Create tool unit lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Duplicate behavior includes active/inactive checks. |
| `deactivate_tool_unit` | Soft deactivate tool unit lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Deactivate sets inactive instead of direct delete. |
| `reactivate_tool_unit` | Restore inactive tool unit lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Restore is explicit. |
| `create_tool_category` | Create tool category lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Duplicate behavior includes active/inactive checks. |
| `deactivate_tool_category` | Soft deactivate tool category lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Deactivate sets inactive instead of direct delete. |
| `reactivate_tool_category` | Restore inactive tool category lookup. | Owner, Admin, Warehouse Manager | Warehouse User, Viewer, inactive members, anonymous users | Verified / Hardened through Issue #35 | Restore is explicit. |

---

## 7. RPC Grant Verification Matrix

Each exposed RPC should be checked for secure grants.

| RPC Area | Revoke From Public / Anon | Grant To Authenticated | Security Mode | Safe Search Path | Status |
|---|---|---|---|---|---|
| `create_company_with_defaults` | Verified through Issue #30 | Verified | `SECURITY DEFINER` | Verified | PUBLIC EXECUTE revoked; authenticated create-company flow tested |
| Company user/member RPCs | Verified / direct table mutation bypass closed through Issue #31 | Verified | `SECURITY DEFINER` | Verified / documented | Member mutations are RPC-only |
| Worker RPCs | Verified through Issue #32 | Verified | `SECURITY DEFINER` | `search_path=""` verified | Worker mutations are RPC-only |
| Tool RPCs | Verified through Issue #32 | Verified | `SECURITY DEFINER` | `search_path=""` verified | Tool mutations are RPC-only |
| Transaction RPCs | Grant verified | Verified | `SECURITY DEFINER` | Verified / needs body review | Manual role tests still recommended |
| Lookup RPCs | Verified through Issue #35 | Verified | `SECURITY DEFINER` | Verified / documented | Lookup mutations are RPC-only |

---

## 8. Storage Bucket Verification Matrix

| Bucket | Purpose | Expected Upload Roles | Expected Read Roles | Expected Delete Roles | Path Format | Verification Status | Notes |
|---|---|---|---|---|---|---|---|
| `company-assets` | Company logo and company asset files. | Owner, Admin | Active company members | Owner, Admin | `{companyId}/logo/company-logo-{timestamp}.{ext}` | Verified / Cleaned through Issue #34 | Duplicate/legacy policies were removed. Helper-based read/upload/update/delete policies remain. |
| `transaction-proofs` | Transaction proof images. | Owner, Admin, Warehouse Manager, Warehouse User | Active company members | Owner, Admin, Warehouse Manager, Warehouse User | `{companyId}/transactions/{TRX-code}/proof-{timestamp}.{ext}` | Verified by bucket/policy inspection | Bucket is private. Upload/delete/read policies detected. |
| `transaction-approval-documents` | Signed approval documents for lost/damaged transactions. | Owner, Admin, Warehouse Manager | Active company members currently | Owner, Admin, Warehouse Manager | `{companyId}/transactions/{TRX-code}/approval-document-{timestamp}.{ext}` | Gap Found / Business Decision Needed | Bucket is private, file size limit is 10MB, mime types restricted. Read policy currently allows all active company members. |
| `custody-documents` | Reserved bucket for future digitally signed custody PDFs. | Owner, Admin, Warehouse Manager, Warehouse User | Active company members | Not confirmed | `{companyId}/...` future signed PDF paths | Verified / Classified through Issue #33 | Planned/reserved active bucket. Private, PDF-only, 10MB limit, currently zero objects. Do not delete. |

---

## 9. Direct Write Verification Matrix

These are high-priority RLS checks because direct writes can bypass RPC-level validation and audit logic.

| Table | Operation | Expected Allowed Roles | Expected Denied Roles | Required RLS / Grant Checks | Verification Status |
|---|---|---|---|---|---|
| `companies` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only own active company. Cannot cross-company update. Cannot spoof protected fields. | Verified / Cleaned through Issue #34 |
| `company_report_settings` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only settings for active company membership. Cannot cross-company update. | Verified / Cleaned through Issue #34 |
| `company_document_templates` | update | Owner, Admin | Warehouse Manager, Warehouse User, Viewer, inactive members | Can update only templates for active company membership. Cannot cross-company update. | Verified by policy inspection |
| `company_members` | insert/update/delete | No direct client write allowed; RPC-only | All direct client table writes | Direct mutation policies removed. `authenticated` has SELECT only. `anon` has no privileges. | Verified / Hardened through Issue #31 |
| `workers` | insert/update/delete | No direct client write allowed; RPC-only | All direct client table writes | Direct mutation policies removed. `authenticated` has SELECT only. `anon`/PUBLIC have no direct dangerous privileges. | Verified / Hardened through Issue #32 |
| `tools` | insert/update/delete | No direct client write allowed; RPC-only | All direct client table writes | Direct mutation policies removed. `authenticated` has SELECT only. `anon`/PUBLIC have no direct dangerous privileges. | Verified / Hardened through Issue #32 |
| `departments` | insert/update/delete | Owner/Admin/Warehouse Manager through RPC only | Warehouse User, Viewer, inactive members, anonymous users, direct client table writes | Mutations must go through lookup RPCs. Direct client table privileges are removed; `authenticated` has SELECT only. | Verified / Hardened through Issue #35 |
| `job_titles` | insert/update/delete | Owner/Admin/Warehouse Manager through RPC only | Warehouse User, Viewer, inactive members, anonymous users, direct client table writes | Mutations must go through lookup RPCs. Direct client table privileges are removed; `authenticated` has SELECT only. | Verified / Hardened through Issue #35 |
| `tool_units` | insert/update/delete | Owner/Admin/Warehouse Manager through RPC only | Warehouse User, Viewer, inactive members, anonymous users, direct client table writes | Mutations must go through lookup RPCs. Direct client table privileges are removed; `authenticated` has SELECT only. | Verified / Hardened through Issue #35 |
| `tool_categories` | insert/update/delete | Owner/Admin/Warehouse Manager through RPC only | Warehouse User, Viewer, inactive members, anonymous users, direct client table writes | Mutations must go through lookup RPCs. Direct client table privileges are removed; `authenticated` has SELECT only. | Verified / Hardened through Issue #35 |
| `transactions` | insert/update/delete | No direct client write expected; RPC-only | Direct client table writes | Direct write policies not detected in prior inspection. | Verified by policy inspection / Manual role tests still recommended |
| `audit_logs` | insert/update/delete | Backend only | Direct client table writes | `authenticated` has SELECT only. | Verified by grants / Manual test still recommended |

---

## 10. Direct Write Recommendation Tracker

This section records whether a direct-write area should remain direct with strong RLS or be moved behind RPCs.

| Area | Current Pattern | Recommended Decision | Status | Notes |
|---|---|---|---|---|
| Company profile update | Direct update | Keep direct update only with strict RLS and clean policies. | Verified / Cleaned through Issue #34 | Duplicate policies and dangerous unused grants were cleaned. |
| Company report settings update | Direct update | Keep direct update only with strict RLS and clean policies. | Verified / Cleaned through Issue #34 | Duplicate policies and dangerous unused grants were cleaned. |
| Company document templates update | Direct update | Keep direct update only if RLS is strict. | Verified | Important before signed PDFs. |
| Company member mutation | RPC-controlled mutation flow | Keep member mutations behind secure RPCs. | Completed / Hardened through Issue #31 | Direct table mutations removed. |
| Workers/tools mutation | RPC-controlled mutation flow | Keep worker/tool mutations behind secure RPCs. | Completed / Hardened through Issue #32 | Direct table mutations removed. |
| Lookup creation/deactivation/restoration | RPC-controlled mutation flow | Keep lookup mutations behind SECURITY DEFINER RPCs. Flutter must use SELECT for loading and RPCs for create/deactivate/restore. | Completed / Hardened through Issue #35 | Direct table privileges were revoked from client roles and re-granted as authenticated SELECT only. |
| Company asset Storage policies | Helper-based Storage policies | Keep current helper-based policies. | Completed / Cleaned through Issue #34 | Duplicate/legacy company-assets policies removed. |
| Custody documents bucket | Planned/reserved active bucket | Keep bucket for future digitally signed custody PDFs. | Completed / Classified through Issue #33 | PDF-only, 10MB, private, zero objects currently. |
| Broad non-DML table grants | Unnecessary client privileges | Remove TRUNCATE / REFERENCES / TRIGGER from anon/authenticated/PUBLIC on public tables. | Completed through Step 16.5 / GAP-007 | Final verification query returned no rows. |

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

Updated result summary after follow-up issues:

- Duplicate/legacy policies on `companies`, `company_report_settings`, and `profiles` were cleaned through Issue #34.
- Direct mutation policies on `company_members` were removed through Issue #31.
- Direct mutation policies on `workers` and `tools` were removed through Issue #32.
- Lookup mutations were moved behind RPCs and direct lookup table writes were blocked through Issue #35.
- `company_invitations`, `transactions`, and `audit_logs` did not show direct INSERT/UPDATE/DELETE policies in the earlier inspection.

Verification Status: Verified with follow-up hardening incorporated

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

Updated result summary after follow-up issues:

- `company-assets` duplicate/legacy policies were cleaned through Issue #34.
- `custody-documents` was classified through Issue #33 as a planned/reserved active bucket.
- `custody-documents` is PDF-only, private, and has a 10MB file size limit.
- `transaction-proofs` remains an active private bucket.
- `transaction-approval-documents` remains an active private bucket.
- `transaction-approval-documents` read policy may still be broad if approval documents are considered sensitive.

Verification Status: Partially verified, with approval document read decision still open

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

Updated confirmed buckets:

- `company-assets`
- `custody-documents`
- `transaction-approval-documents`
- `transaction-proofs`

Updated result summary:

- All detected buckets are private.
- `custody-documents` is planned/reserved active, PDF-only, 10MB limit, and currently reserved for future signed custody PDFs.
- `transaction-approval-documents` has a 10MB file size limit and restricts MIME types to:
  - `application/pdf`
  - `image/jpeg`
  - `image/png`
  - `image/webp`

Verification Status: Verified, with approval document read access decision still open

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
        'create_department',
        'deactivate_department',
        'reactivate_department',
        'create_job_title',
        'deactivate_job_title',
        'reactivate_job_title',
        'create_tool_unit',
        'deactivate_tool_unit',
        'reactivate_tool_unit',
        'create_tool_category',
        'deactivate_tool_category',
        'reactivate_tool_category',
        'current_profile_id',
        'is_company_member',
        'has_company_role',
        'company_id_from_storage_path',
        'write_audit_log'
      )
    order by schema_name, function_name;

Updated result summary:

- Critical mutation RPCs are present.
- Worker/tool mutation RPCs are verified through Issue #32.
- Lookup mutation RPCs are verified through Issue #35.
- Company creation RPC grant hardening completed through Issue #30.
- Private helper functions are present.
- This query verifies function presence/security mode, not all internal business logic.

Verification Status: Verified for key follow-up areas, Function Body Review still recommended for critical business rules

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
        'rollback_failed_transaction_proof_upload',
        'create_department',
        'deactivate_department',
        'reactivate_department',
        'create_job_title',
        'deactivate_job_title',
        'reactivate_job_title',
        'create_tool_unit',
        'deactivate_tool_unit',
        'reactivate_tool_unit',
        'create_tool_category',
        'deactivate_tool_category',
        'reactivate_tool_category'
      )
    order by routine_name, grantee;

Updated result summary:

- `create_company_with_defaults` no longer has PUBLIC EXECUTE after Issue #30.
- `authenticated` retains EXECUTE for `create_company_with_defaults`.
- Worker/tool mutation RPC grants were verified through Issue #32.
- Lookup mutation RPC grants were verified through Issue #35.
- Transaction RPC grants still require broader manual role tests.

Verification Status: Verified for Issues #30, #32, #35; broader manual role tests still recommended

---

### 11.7 Confirm table grants

    select
      grantee,
      table_name,
      string_agg(privilege_type, ', ' order by privilege_type) as privileges
    from information_schema.role_table_grants
    where table_schema = 'public'
      and grantee in ('authenticated', 'anon', 'PUBLIC')
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

Updated result summary:

- `authenticated` has SELECT on the required readable business tables.
- `authenticated` keeps UPDATE only where the current app intentionally uses direct updates:
  - `companies`
  - `company_report_settings`
  - `company_document_templates`
- `authenticated` has SELECT only on:
  - `company_members`
  - `workers`
  - `tools`
  - `departments`
  - `job_titles`
  - `tool_units`
  - `tool_categories`
  - `transactions`
  - `audit_logs`
  - `company_invitations`
- `anon` has no direct privileges on the hardened sensitive tables covered by Issues #31, #32, #34, and #35.
- PUBLIC/dangerous table privileges were removed from targeted areas during hardening.

Verification Status: Verified with Issues #31, #32, #34, and #35 incorporated

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

### 11.10 Confirm no broad non-DML grants remain for client roles

    select
      grantee,
      table_schema,
      table_name,
      privilege_type
    from information_schema.role_table_grants
    where table_schema = 'public'
      and grantee in ('anon', 'authenticated', 'PUBLIC')
      and privilege_type in ('TRUNCATE', 'REFERENCES', 'TRIGGER')
    order by
      table_name,
      grantee,
      privilege_type;

Before Step 16.5 cleanup:

- Remaining broad non-DML grants were found on:
  - `company_invitations`
  - `custody_acknowledgement_items`
  - `custody_acknowledgements`
  - `loss_damage_reports`
  - `user_context_events`

Step 16.5 cleanup removed:

- `TRUNCATE`
- `REFERENCES`
- `TRIGGER`

from:

- `anon`
- `authenticated`
- `PUBLIC`

After Step 16.5 cleanup:

- Query returned no rows.

Verification Status: Verified / GAP-007 Closed

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
| User from Company A attempts to create lookup with Company B ID. | Denied through RPC/table grants. | Needs Manual Test |
| User from Company A attempts to upload Storage file under Company B path. | Denied. | Needs Manual Test |
| User from Company A attempts to create signed URL for Company B approval document. | Denied. | Needs Manual Test |

---

### 12.3 Viewer restriction tests

| Test | Expected Result | Status |
|---|---|---|
| Viewer opens Dashboard. | Allowed. | Verified through Issue #29 |
| Viewer opens Workers. | Allowed read-only. | Verified through Issue #29 |
| Viewer opens Tools. | Allowed read-only. | Verified through Issue #29 |
| Viewer opens Transactions. | Allowed read-only. | Verified through Issue #29 |
| Viewer opens Reports. | Allowed read-only. | Verified through Issue #29 |
| Viewer opens Lookups. | Allowed read-only. | Verified through Issue #29 |
| Viewer opens Team. | Allowed read-only. | Verified through Issue #29 |
| Viewer sees Settings tab. | Denied / hidden intentionally. | Verified through Issue #29 |
| Viewer attempts to create worker. | Denied. | Needs backend bypass/manual test |
| Viewer attempts to update company profile. | Denied. | Needs backend bypass/manual test |
| Viewer attempts to create lookup. | Denied. | Needs backend bypass/manual test |
| Viewer attempts to create transaction. | Denied. | Needs backend bypass/manual test |
| Viewer attempts to upload transaction proof. | Denied. | Needs backend bypass/manual test |
| Viewer attempts to upload approval document. | Denied. | Needs backend bypass/manual test |
| Viewer attempts to read approval document. | Business decision needed. | Needs Manual Test |
| Viewer attempts to approve lost/damaged transaction. | Denied. | Needs backend bypass/manual test |
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
| Warehouse User creates worker. | Denied. | Needs backend bypass/manual test |
| Warehouse User creates tool. | Denied. | Needs backend bypass/manual test |
| Warehouse User updates company settings. | Denied. | Needs backend bypass/manual test |

---

### 12.5 Warehouse Manager tests

| Test | Expected Result | Status |
|---|---|---|
| Warehouse Manager creates worker. | Allowed through RPC. | App flow verified through Issue #32 |
| Warehouse Manager creates tool. | Allowed through RPC. | App flow verified through Issue #32 |
| Warehouse Manager creates lookup. | Allowed through RPC only; direct table write should be blocked. | App flow verified through Issue #35 |
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
| Admin updates company settings. | Allowed. | App flow verified through Issue #34 |
| Admin uploads company logo. | Allowed. | App flow verified through Issue #34 |

---

### 12.7 Owner tests

| Test | Expected Result | Status |
|---|---|---|
| Owner creates company. | Allowed after authentication. | Verified through Issue #30 |
| Owner invites Admin. | Allowed. | Needs Manual Test |
| Owner invites Owner through normal invite flow. | Denied. | Needs Manual Test |
| Owner changes Admin role to Warehouse Manager. | Allowed. | Needs Manual Test |
| Owner deactivates Admin. | Allowed. | Needs Manual Test |
| Owner deactivates own membership. | Denied. | Needs Manual Test |
| Owner updates company settings. | Allowed. | App flow verified through Issue #34 |
| Owner uploads company logo. | Allowed. | App flow verified through Issue #34 |

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
| GAP-001 | Company Members | `company_members` allowed direct INSERT/UPDATE for owner, which could bypass secure member-management RPC rules and audit flow. | High | Completed. Keep member-management mutations RPC-only. | #31 | Closed |
| GAP-002 | Workers / Tools | `workers` and `tools` had direct INSERT/UPDATE/DELETE policies for owner/admin/warehouse_manager even though Flutter uses RPCs for mutations. | High | Completed. Keep worker/tool mutations RPC-only. | #32 | Closed |
| GAP-003 | Approval Document Read Access | `transaction-approval-documents` read policy allows active company members, which may include warehouse_user and viewer. | High | Decide intended read roles before or during Issue #28 signed PDF workflow. If documents are sensitive, restrict read/signed URL access to owner/admin/warehouse_manager or approved report roles only. | TBD | Open / Business Decision Needed |
| GAP-004 | Public Execute Grant | `create_company_with_defaults` had EXECUTE granted to PUBLIC. | Medium / High | Completed. PUBLIC EXECUTE revoked; authenticated EXECUTE kept. | #30 | Closed |
| GAP-005 | Custody Documents Bucket | `custody-documents` bucket and policies existed but were not part of the original active Flutter storage inventory. | Medium | Completed. Bucket classified as planned/reserved active for future signed custody PDFs. | #33 | Closed |
| GAP-006 | Policy Cleanup | Some overlapping policies existed on `companies`, `company_report_settings`, `profiles`, and `company-assets`. | Low | Completed. Duplicate/legacy policies and dangerous unused grants cleaned for targeted scope. | #34 | Closed |
| GAP-007 | Broad Non-DML Grants | Some broad non-DML grants such as REFERENCES/TRIGGER/TRUNCATE were previously detected on remaining public tables. | Low / Medium | Completed. Removed TRUNCATE / REFERENCES / TRIGGER from anon/authenticated/PUBLIC on remaining public tables. | Step 16.5 | Closed |
| GAP-008 | Direct Lookup Writes | Lookup tables previously allowed direct INSERT/UPDATE/DELETE for owner/admin/warehouse_manager. | Medium | Completed. Lookup mutations moved behind RPCs and table grants hardened to authenticated SELECT only. | #35 | Closed |

---

## 14. Verification Progress Tracker

| Section | Status | Notes |
|---|---|---|
| Role model matrix | Updated | Viewer role verified through Issue #29. Broader role tests still recommended. |
| Business table matrix | Updated / Mostly hardened | Company members, workers/tools, and lookups hardened through Issues #31, #32, and #35. Remaining broad grants cleaned through Step 16.5. |
| RPC matrix | Updated | Company creation, member management, workers/tools, and lookups incorporated from closed follow-up issues. Transaction RPCs still need broader manual role tests. |
| Storage matrix | Updated | `custody-documents` classified through Issue #33. `company-assets` cleanup completed through Issue #34. Approval document read access still needs decision. |
| Direct write matrix | Updated / Mostly hardened | Direct mutation bypass risks closed for company_members, workers/tools, and lookups. |
| Manual SQL queries | Updated | Query result notes updated to incorporate Issues #30–#35 and Step 16.5 broad grants cleanup. |
| Critical role tests | Partially verified | Viewer UI access verified through Issue #29. Worker/tool, lookup, company settings app flows partially verified through closed issues. Cross-company/inactive/bypass tests still recommended. |
| Gap register | Updated | GAP-001, GAP-002, GAP-004, GAP-005, GAP-006, GAP-007, GAP-008 are closed. GAP-003 remains open/business decision needed. |

---

## 15. Step 16.3 Conclusion

Step 16.3 completed the first SQL inspection pass.

Originally confirmed:

- RLS is enabled on all reviewed business tables.
- Public table policies exist for all reviewed business tables.
- Storage buckets are private.
- Storage policies exist for the reviewed buckets.
- Critical RPCs exist and are mostly `SECURITY DEFINER`.
- Most exposed RPCs grant EXECUTE to `authenticated`.
- `audit_logs` does not allow direct authenticated INSERT/UPDATE/DELETE by grants.
- No service role key was found in the local repository scan. Only documentation search-command text matched the scanned patterns.

Original gaps were converted into follow-up issues.

---

## 16. Step 16.4A Update — Lookup RPC Mutation Hardening

Issue #35 resolved the lookup direct-write gap.

Completed:

- Lookup mutations were moved to an RPC-controlled flow.
- Flutter uses SELECT to load active/inactive lookup records.
- Flutter uses RPCs for create/deactivate/restore operations.
- Direct client table write privileges were revoked for:
  - `public.departments`
  - `public.job_titles`
  - `public.tool_units`
  - `public.tool_categories`
- `authenticated` was re-granted SELECT only for those lookup tables.
- `anon` and `PUBLIC` have no direct table privileges for the lookup tables.
- Active and inactive duplicate behavior was tested from the app.
- Normalized matching was verified for case differences, spacing differences, and symbol/spacing variations.

Final verified lookup table grants:

| Grantee | Table Schema | Table Name | Privilege Type |
|---|---|---|---|
| authenticated | public | departments | SELECT |
| authenticated | public | job_titles | SELECT |
| authenticated | public | tool_categories | SELECT |
| authenticated | public | tool_units | SELECT |

Documentation added:

- `docs/supabase/issue_35_lookup_rpc_mutation_flow.sql`

GitHub issue:

- #35 — Closed as completed.

Status:

- Lookup direct write gap is closed.
- Lookup mutation architecture is now RPC-controlled.
- Security matrix has been updated to reflect Issue #35 completion.

---

## 17. Step 16.4B Update — Follow-up Issues #29–#35 Incorporated

This update incorporates the completed follow-up issues into the Issue #16 matrix.

Completed follow-up issues:

| Issue | Area | Result |
|---|---|---|
| #29 | Viewer role | Viewer is now a full read-only operational/reporting role. Settings is intentionally hidden. |
| #30 | `create_company_with_defaults` PUBLIC EXECUTE | PUBLIC EXECUTE revoked. Authenticated company creation still works. |
| #31 | `company_members` direct mutations | Direct member-management mutations removed. Member management is RPC-only. |
| #32 | `workers` / `tools` direct mutations | Direct worker/tool mutations removed. Worker/tool management is RPC-only. |
| #33 | `custody-documents` bucket | Bucket classified as planned/reserved active for future signed custody PDFs. |
| #34 | Duplicate/legacy RLS and Storage policies | Targeted duplicate/legacy policies and dangerous unused grants cleaned. |
| #35 | Lookup direct writes | Lookup mutations moved behind RPCs and lookup tables hardened to authenticated SELECT only. |

Remaining Issue #16 items after Step 16.4B:

- Decide or track approval document read access for `transaction-approval-documents`.
- Run a final global least-privilege grants query for any remaining broad non-DML grants.
- Complete or explicitly defer broader manual role tests:
  - cross-company access
  - inactive member access
  - backend bypass attempts
  - transaction approval workflow restrictions
  - audit log read policy decision

---

## 18. Step 16.5 Update — GAP-007 Final Broad Grants Cleanup

GAP-007 resolved the remaining broad non-DML grants.

Before cleanup, the final global least-privilege query found `TRUNCATE`, `REFERENCES`, and `TRIGGER` privileges for client-facing roles on:

- `public.company_invitations`
- `public.custody_acknowledgement_items`
- `public.custody_acknowledgements`
- `public.loss_damage_reports`
- `public.user_context_events`

Cleanup applied:

- Removed `TRUNCATE`, `REFERENCES`, and `TRIGGER` from:
  - `anon`
  - `authenticated`
  - `PUBLIC`

Final verification:

- The final broad non-DML grants query returned no rows.

Documentation added:

- `docs/supabase/issue_16_gap_007_final_least_privilege_cleanup.sql`

Status:

- GAP-007 is closed.
- No `TRUNCATE`, `REFERENCES`, or `TRIGGER` privileges remain for `anon`, `authenticated`, or `PUBLIC` on public tables.

Remaining Issue #16 items:

- GAP-003 — approval document read access business decision.
- Broader manual role tests can either be completed now or moved into a dedicated follow-up issue.