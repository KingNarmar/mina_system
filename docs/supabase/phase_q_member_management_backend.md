# Phase Q — Secure Member Management & Invitation Backend

## Scope

This document records the Supabase backend work completed during Phase Q only.

It covers:

- Secure invitation creation
- Multi-company invitation support implications
- Secure member role changes
- Secure member deactivation
- Secure member reactivation
- Active-membership enforcement confirmation
- Database-level security verification

It intentionally excludes Flutter UI implementation details.

---

# Existing Supabase Foundation Reviewed Before Phase Q

## Tables reviewed

- `company_members`
- `company_invitations`

## Existing enums reviewed

### `company_member_role`

- `owner`
- `admin`
- `warehouse_manager`
- `warehouse_user`
- `viewer`

### `member_status`

- `active`
- `inactive`
- `invited`

### `company_invitation_status`

- `pending`
- `accepted`
- `cancelled`
- `expired`

## Existing helper functions reviewed

- `private.current_profile_id()`
- `private.is_company_member(uuid)`
- `private.has_company_role(uuid, company_member_role[])`

## Existing invitation RPCs reviewed

- `accept_company_invitation(uuid)`
- `cancel_company_invitation(uuid)`

## Existing RLS reviewed

### `company_members`

- `Members can read company members`
- `Owners can insert company members`
- `Owners can update company members`

### `company_invitations`

Before Phase Q hardening, the invitation flow still included a direct insert path for authenticated users through:

- Grant:
  - `INSERT` on `company_invitations` for `authenticated`
- RLS policy:
  - `Owners and admins can create pending company invitations`

---

# Confirmed Membership Security Model

## Active-membership enforcement

The following private helper functions were confirmed to require active membership:

### `private.is_company_member(target_company_id uuid)`

Requires:

```sql
cm.status = 'active'
```

### `private.has_company_role(
  target_company_id uuid,
  allowed_roles company_member_role[]
)`

Requires:

```sql
cm.status = 'active'
```

## Security consequence

Any member whose status becomes `inactive`:

- Is no longer considered a valid company member by backend helper functions.
- Loses role-based access enforced through RLS policies that depend on these helpers.
- Cannot keep effective company access through inactive membership.

---

# Step Q2 — Secure Invitation Creation Backend

## Added RPC

```sql
public.invite_company_user(
  p_company_id uuid,
  p_email text,
  p_role text
)
```

## Purpose

Move invitation creation away from direct client inserts and enforce invitation rules centrally in the database.

## Rules enforced by the RPC

- Caller must be authenticated.
- Caller must have an active membership in the target company.
- Invitation role must be valid.
- `owner` cannot be invited through normal invitation flow.
- Owner can invite:
  - `admin`
  - `warehouse_manager`
  - `warehouse_user`
  - `viewer`
- Admin can invite:
  - `warehouse_manager`
  - `warehouse_user`
  - `viewer`
- Lower roles cannot invite company users.
- Duplicate pending invitations remain blocked.
- Invitations to already active members remain blocked.

## Legacy direct insert path closed

After Flutter was moved to the secure RPC path, the old direct insert path was removed.

### Removed RLS policy

```text
Owners and admins can create pending company invitations
```

### Removed grant

```sql
revoke insert
on table public.company_invitations
from authenticated;
```

## Final direct grants on `company_invitations` for `authenticated`

```text
SELECT
```

## Final active RLS policies on `company_invitations`

- `Invited users can read their pending invitations`
- `Owners and admins can read company invitations`

## Result

Invitation creation now goes through secure backend logic only.

---

# Step Q3 — Secure Member Role Change Backend

## Added RPC

```sql
public.change_company_member_role(
  p_company_id uuid,
  p_member_id uuid,
  p_new_role text
)
```

## Purpose

Move member role changes into a secure backend mutation instead of relying on Flutter UI restrictions only.

## Rules enforced by the RPC

- Caller must be authenticated.
- Caller must have an active membership in the company.
- Target member must exist in the same company.
- Only real members with status:
  - `active`
  - `inactive`
  can be managed.
- Caller cannot change their own role.
- Owner role cannot be changed through normal member management.
- Owner cannot be assigned through normal member management.
- Owner can assign:
  - `admin`
  - `warehouse_manager`
  - `warehouse_user`
  - `viewer`
- Admin can assign:
  - `warehouse_manager`
  - `warehouse_user`
  - `viewer`
- Admin cannot:
  - manage another `admin`
  - assign the `admin` role
- Lower roles cannot change member roles.

## Function execution grant

```sql
grant execute
on function public.change_company_member_role(uuid, uuid, text)
to authenticated;
```

## Direct DB security tests passed

- Admin can change a lower-role member.
- Admin cannot assign the `admin` role.
- Admin cannot manage another admin.
- User cannot change their own role.
- Owner role cannot be changed from normal member management.

---

# Step Q4 — Secure Member Lifecycle Backend

## Added RPCs

### Deactivate member

```sql
public.deactivate_company_member(
  p_company_id uuid,
  p_member_id uuid
)
```

### Reactivate member

```sql
public.reactivate_company_member(
  p_company_id uuid,
  p_member_id uuid
)
```

## Purpose

Use soft membership lifecycle control through `member_status` instead of physical deletion.

## Lifecycle design decision

Phase Q uses:

- `active`
- `inactive`

for real membership lifecycle behavior.

The system currently uses **soft deactivation**, not physical removal.

## Deactivation rules enforced

- Caller must be authenticated.
- Caller must have an active membership in the company.
- Target member must exist in the same company.
- Caller cannot deactivate themselves.
- Owner membership cannot be deactivated.
- Only `active` members can be deactivated.
- Owner can deactivate:
  - `admin`
  - `warehouse_manager`
  - `warehouse_user`
  - `viewer`
- Admin can deactivate:
  - `warehouse_manager`
  - `warehouse_user`
  - `viewer`
- Warehouse Manager can deactivate:
  - `warehouse_user`
  - `viewer`
- Same-level or higher-level targets are blocked unless explicitly allowed above.

## Reactivation rules enforced

- Caller must be authenticated.
- Caller must have an active membership in the company.
- Target member must exist in the same company.
- Caller cannot reactivate their own membership.
- Owner membership cannot be managed through normal member management.
- Only `inactive` members can be reactivated.
- Owner can reactivate:
  - `admin`
  - `warehouse_manager`
  - `warehouse_user`
  - `viewer`
- Admin can reactivate:
  - `warehouse_manager`
  - `warehouse_user`
  - `viewer`
- Warehouse Manager can reactivate:
  - `warehouse_user`
  - `viewer`
- Same-level or higher-level targets are blocked unless explicitly allowed above.

## Function execution grants

```sql
grant execute
on function public.deactivate_company_member(uuid, uuid)
to authenticated;
```

```sql
grant execute
on function public.reactivate_company_member(uuid, uuid)
to authenticated;
```

---

# Direct DB Security Verification

## Role-change tests passed

| Test Case | Result |
|---|---|
| Admin can change lower-role member | Passed |
| Admin cannot assign Admin role | Passed |
| Admin cannot manage another Admin | Passed |
| Admin cannot change own role | Passed |
| Admin cannot change Owner role | Passed |

## Deactivate / reactivate tests passed

| Test Case | Result |
|---|---|
| Admin can deactivate lower-role member | Passed |
| Admin can reactivate lower-role member | Passed |
| Admin cannot deactivate another Admin | Passed |
| Admin cannot reactivate another Admin | Passed |
| Admin cannot deactivate self | Passed |
| Admin cannot deactivate Owner | Passed |
| Warehouse Manager can deactivate lower-role member | Passed |
| Warehouse Manager can reactivate lower-role member | Passed |
| Warehouse Manager cannot deactivate Admin | Passed |
| Warehouse Manager cannot deactivate another Warehouse Manager | Passed |
| Warehouse Manager cannot reactivate another Warehouse Manager | Passed |
| Warehouse Manager cannot deactivate self | Passed |
| Warehouse Manager cannot deactivate Owner | Passed |

## Confirmed backend protections

The database now enforces:

- No self role change.
- No self deactivation.
- No normal member-management action against Owner membership.
- No Admin management of another Admin.
- No Warehouse Manager management of Admin or same-level Warehouse Manager.
- No member lifecycle action outside the allowed hierarchy.
- Inactive members lose effective access because company-membership helper functions require `status = 'active'`.

---

# Current Supabase Backend State After Phase Q Progress

## RPCs now available for company-user management

- `invite_company_user(uuid, text, text)`
- `accept_company_invitation(uuid)`
- `cancel_company_invitation(uuid)`
- `change_company_member_role(uuid, uuid, text)`
- `deactivate_company_member(uuid, uuid)`
- `reactivate_company_member(uuid, uuid)`

## Invitation creation security state

- Direct authenticated insert on `company_invitations` is closed.
- Invitation creation is routed through secure RPC logic only.

## Member lifecycle security state

- Role changes are backend-enforced.
- Deactivate/reactivate behavior is backend-enforced.
- Soft deactivation is the current lifecycle strategy.
- Owner lifecycle is protected from normal member-management actions.
- Active membership remains the source of effective access.

---

# Remaining Supabase Work Related to Future Phases

## Still pending after current Phase Q backend work

- Audit logging for:
  - invitation creation
  - invitation cancellation
  - invitation acceptance
  - role change
  - deactivation
  - reactivation
- Direct accountability fields for company-user lifecycle events where needed.
- Production invitation email delivery through backend/Edge Function if adopted.
- Future remove-access flow if business need is confirmed.
- Future ownership-transfer flow.
- Future last-owner protection for any remove-access / transfer-ownership workflow.
- Future plan/subscription enforcement.