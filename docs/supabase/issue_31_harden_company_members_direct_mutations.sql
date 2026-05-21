-- Issue #31 - Harden company_members direct mutation policies
--
-- Goal:
-- Remove direct INSERT / UPDATE mutation policies from public.company_members
-- and close unnecessary table-level privileges.
--
-- Decision:
-- Member-management mutations must go through secure RPCs only:
--
-- - public.invite_company_user(uuid, text, text)
-- - public.accept_company_invitation(uuid)
-- - public.cancel_company_invitation(uuid)
-- - public.change_company_member_role(uuid, uuid, text)
-- - public.deactivate_company_member(uuid, uuid)
-- - public.reactivate_company_member(uuid, uuid)
--
-- Why:
-- Direct table mutations may bypass secure RPC rules for:
--
-- - role hierarchy
-- - self role-change prevention
-- - self-deactivation prevention
-- - Owner protection
-- - admin / manager restrictions
-- - audit logging
--
-- PostgreSQL Row Level Security does not apply to whole-table operations
-- such as TRUNCATE and REFERENCES, so these privileges should not be
-- available to anon/authenticated roles on this sensitive table.
--
-- Do not modify PROJECT_ROADMAP.md for this issue.

-- ============================================================
-- 1) BEFORE CHECK - Confirm RLS status
-- ============================================================

select
  schemaname,
  tablename,
  rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename = 'company_members';


-- ============================================================
-- 2) BEFORE CHECK - Confirm current table grants
-- ============================================================

select
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name = 'company_members'
  and grantee in ('anon', 'authenticated', 'PUBLIC')
order by
  grantee,
  privilege_type;


-- ============================================================
-- 3) BEFORE CHECK - Confirm current RLS policies
-- ============================================================

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
  and tablename = 'company_members'
order by
  cmd,
  policyname;


-- ============================================================
-- 4) APPLY CHANGE - Remove direct mutation policies
-- ============================================================

drop policy if exists "Owners can insert company members"
on public.company_members;

drop policy if exists "Owners can update company members"
on public.company_members;


-- ============================================================
-- 5) APPLY CHANGE - Revoke unnecessary direct privileges
-- ============================================================

revoke insert, update, delete, truncate, references, trigger
on table public.company_members
from authenticated;

revoke insert, update, delete, truncate, references, trigger
on table public.company_members
from anon;

revoke insert, update, delete, truncate, references, trigger
on table public.company_members
from public;


-- ============================================================
-- 6) AFTER CHECK - Confirm final RLS policies
-- ============================================================

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
  and tablename = 'company_members'
order by
  cmd,
  policyname;


-- ============================================================
-- 7) AFTER CHECK - Confirm final table grants
-- ============================================================

select
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name = 'company_members'
  and grantee in ('anon', 'authenticated', 'PUBLIC')
order by
  grantee,
  privilege_type;


-- ============================================================
-- 8) AFTER CHECK - Confirm authenticated final privileges
-- ============================================================

select
  'authenticated' as role_name,
  has_table_privilege(
    'authenticated',
    'public.company_members',
    'select'
  ) as can_select,
  has_table_privilege(
    'authenticated',
    'public.company_members',
    'insert'
  ) as can_insert,
  has_table_privilege(
    'authenticated',
    'public.company_members',
    'update'
  ) as can_update,
  has_table_privilege(
    'authenticated',
    'public.company_members',
    'delete'
  ) as can_delete,
  has_table_privilege(
    'authenticated',
    'public.company_members',
    'truncate'
  ) as can_truncate,
  has_table_privilege(
    'authenticated',
    'public.company_members',
    'references'
  ) as can_references,
  has_table_privilege(
    'authenticated',
    'public.company_members',
    'trigger'
  ) as can_trigger;


-- ============================================================
-- 9) AFTER CHECK - Confirm anon final privileges
-- ============================================================

select
  'anon' as role_name,
  has_table_privilege(
    'anon',
    'public.company_members',
    'select'
  ) as can_select,
  has_table_privilege(
    'anon',
    'public.company_members',
    'insert'
  ) as can_insert,
  has_table_privilege(
    'anon',
    'public.company_members',
    'update'
  ) as can_update,
  has_table_privilege(
    'anon',
    'public.company_members',
    'delete'
  ) as can_delete,
  has_table_privilege(
    'anon',
    'public.company_members',
    'truncate'
  ) as can_truncate,
  has_table_privilege(
    'anon',
    'public.company_members',
    'references'
  ) as can_references,
  has_table_privilege(
    'anon',
    'public.company_members',
    'trigger'
  ) as can_trigger;


-- ============================================================
-- 10) EXPECTED FINAL RESULT
-- ============================================================
--
-- Expected final policies on public.company_members:
--
-- - Members can read company members
--
-- Expected removed policies:
--
-- - Owners can insert company members
-- - Owners can update company members
--
-- Expected final table grants:
--
-- - authenticated: SELECT only
-- - anon: no privileges
--
-- Expected authenticated privileges:
--
-- - can_select = true
-- - can_insert = false
-- - can_update = false
-- - can_delete = false
-- - can_truncate = false
-- - can_references = false
-- - can_trigger = false
--
-- Expected anon privileges:
--
-- - can_select = false
-- - can_insert = false
-- - can_update = false
-- - can_delete = false
-- - can_truncate = false
-- - can_references = false
-- - can_trigger = false
--
-- ============================================================
-- 11) MANUAL TEST CHECKLIST
-- ============================================================
--
-- [ ] Owner can invite user through RPC/UI.
-- [ ] Admin can invite allowed lower roles through RPC/UI.
-- [ ] Invalid invite roles are rejected.
-- [ ] Owner can change lower member role through RPC/UI.
-- [ ] Admin can change lower member role through RPC/UI.
-- [ ] Admin cannot change another Admin role.
-- [ ] User cannot change their own role.
-- [ ] Owner membership cannot be changed through normal member management.
-- [ ] Owner/Admin/Manager can deactivate allowed lower roles.
-- [ ] User cannot deactivate themselves.
-- [ ] Owner membership cannot be deactivated through normal member management.
-- [ ] Reactivation works only for allowed lower roles.