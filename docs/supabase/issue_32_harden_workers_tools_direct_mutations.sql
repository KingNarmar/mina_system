-- Issue #32 - Harden workers and tools direct mutation policies
--
-- Goal:
-- Review and remove direct INSERT / UPDATE / DELETE mutation policies
-- from public.workers and public.tools, then keep worker/tool mutations
-- routed through secure RPCs only.
--
-- Decision:
-- Worker and tool mutations must go through secure RPCs only.
--
-- Workers:
-- - public.create_worker(...)
-- - public.update_worker(...)
-- - public.deactivate_worker(...)
-- - public.reactivate_worker(...)
--
-- Tools:
-- - public.create_tool(...)
-- - public.update_tool(...)
-- - public.deactivate_tool(...)
-- - public.reactivate_tool(...)
--
-- Why:
-- Flutter already uses RPCs for worker/tool mutations.
-- Direct table mutation policies create confusion and may become a bypass risk
-- if direct table grants are accidentally widened in the future.
--
-- Final architecture:
-- - Direct table access to public.workers = SELECT only for authenticated users.
-- - Direct table access to public.tools = SELECT only for authenticated users.
-- - Worker mutations = RPC-only.
-- - Tool mutations = RPC-only.
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
  and tablename in ('workers', 'tools')
order by
  tablename;

-- Verified result:
-- - public.tools   rowsecurity = true
-- - public.workers rowsecurity = true


-- ============================================================
-- 2) BEFORE CHECK - Confirm current RLS policies
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
  and tablename in ('workers', 'tools')
order by
  tablename,
  cmd,
  policyname;

-- Verified before result:
--
-- public.tools:
-- - Owner admin manager can delete tools   DELETE
-- - Owner admin manager can insert tools   INSERT
-- - Members can read tools                 SELECT
-- - Owner admin manager can update tools   UPDATE
--
-- public.workers:
-- - Owner admin manager can delete workers DELETE
-- - Owner admin manager can insert workers INSERT
-- - Members can read workers               SELECT
-- - Owner admin manager can update workers UPDATE


-- ============================================================
-- 3) BEFORE CHECK - Confirm current table grants
-- ============================================================

select
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name in ('workers', 'tools')
  and grantee in ('anon', 'authenticated', 'PUBLIC')
order by
  table_name,
  grantee,
  privilege_type;

-- Verified before result:
-- - authenticated has SELECT only on public.tools.
-- - authenticated has SELECT only on public.workers.
-- - anon has no direct grants.
-- - PUBLIC has no direct grants.


-- ============================================================
-- 4) BEFORE CHECK - Confirm effective table privileges
-- ============================================================

with checked_roles(role_name) as (
  values
    ('authenticated'),
    ('anon')
),
checked_tables(table_name) as (
  values
    ('workers'),
    ('tools')
)
select
  checked_roles.role_name,
  checked_tables.table_name,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'select'
  ) as can_select,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'insert'
  ) as can_insert,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'update'
  ) as can_update,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'delete'
  ) as can_delete,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'truncate'
  ) as can_truncate,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'references'
  ) as can_references,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'trigger'
  ) as can_trigger
from checked_roles
cross join checked_tables
order by
  checked_tables.table_name,
  checked_roles.role_name;

-- Verified before result:
-- - authenticated can_select = true on workers/tools.
-- - authenticated all mutation/dangerous privileges = false.
-- - anon all privileges = false.


-- ============================================================
-- 5) BEFORE CHECK - Confirm worker/tool RPC definitions
-- ============================================================

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_arguments(p.oid) as arguments,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  case
    when p.prosecdef then 'SECURITY DEFINER'
    else 'SECURITY INVOKER'
  end as security_mode,
  p.proconfig as function_config
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'create_worker',
    'update_worker',
    'deactivate_worker',
    'reactivate_worker',
    'create_tool',
    'update_tool',
    'deactivate_tool',
    'reactivate_tool'
  )
order by
  p.proname,
  pg_get_function_identity_arguments(p.oid);

-- Verified result:
-- - All 8 worker/tool mutation RPCs exist.
-- - All 8 RPCs are SECURITY DEFINER.
-- - All 8 RPCs use search_path="".


-- ============================================================
-- 6) BEFORE CHECK - Confirm worker/tool RPC grants
-- ============================================================

select
  routine_schema,
  routine_name,
  grantee,
  privilege_type
from information_schema.routine_privileges
where routine_schema = 'public'
  and routine_name in (
    'create_worker',
    'update_worker',
    'deactivate_worker',
    'reactivate_worker',
    'create_tool',
    'update_tool',
    'deactivate_tool',
    'reactivate_tool'
  )
order by
  routine_name,
  grantee,
  privilege_type;

-- Verified before result:
-- - authenticated has EXECUTE on all 8 worker/tool RPCs.
-- - postgres has EXECUTE on all 8 worker/tool RPCs.
-- - anon has no EXECUTE grants.
-- - PUBLIC has no EXECUTE grants.


-- ============================================================
-- 7) SAFETY CHECK - Confirm there are no ALL policies
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
  and tablename in ('workers', 'tools')
  and cmd = 'ALL'
order by
  tablename,
  policyname;

-- Verified result:
-- - No rows returned.
--
-- This means the mutation-policy removal can safely target
-- INSERT / UPDATE / DELETE policies only.


-- ============================================================
-- 8) APPLY CHANGE - Remove direct mutation policies
-- ============================================================

drop policy if exists "Owner admin manager can insert tools"
on public.tools;

drop policy if exists "Owner admin manager can update tools"
on public.tools;

drop policy if exists "Owner admin manager can delete tools"
on public.tools;


drop policy if exists "Owner admin manager can insert workers"
on public.workers;

drop policy if exists "Owner admin manager can update workers"
on public.workers;

drop policy if exists "Owner admin manager can delete workers"
on public.workers;

-- Applied successfully:
-- - No errors.
-- - No result rows expected.


-- ============================================================
-- 9) APPLY CHANGE - Revoke unnecessary direct table privileges
-- ============================================================
--
-- Keep SELECT for authenticated users.
-- Revoke direct mutation and whole-table privileges from client-facing roles.

revoke insert, update, delete, truncate, references, trigger
on table public.workers
from authenticated;

revoke insert, update, delete, truncate, references, trigger
on table public.workers
from anon;

revoke insert, update, delete, truncate, references, trigger
on table public.workers
from public;


revoke insert, update, delete, truncate, references, trigger
on table public.tools
from authenticated;

revoke insert, update, delete, truncate, references, trigger
on table public.tools
from anon;

revoke insert, update, delete, truncate, references, trigger
on table public.tools
from public;

-- Applied successfully:
-- - No errors.
-- - No result rows expected.


-- ============================================================
-- 10) AFTER CHECK - Confirm final RLS policies
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
  and tablename in ('workers', 'tools')
order by
  tablename,
  cmd,
  policyname;

-- Verified final result:
--
-- public.tools:
-- - Members can read tools   SELECT
--
-- public.workers:
-- - Members can read workers SELECT
--
-- No direct INSERT / UPDATE / DELETE policies remain.


-- ============================================================
-- 11) AFTER CHECK - Confirm no mutation policies remain
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
  and tablename in ('workers', 'tools')
  and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
order by
  tablename,
  cmd,
  policyname;

-- Verified final result:
-- - No rows returned.


-- ============================================================
-- 12) AFTER CHECK - Confirm final table grants
-- ============================================================

select
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name in ('workers', 'tools')
  and grantee in ('anon', 'authenticated', 'PUBLIC')
order by
  table_name,
  grantee,
  privilege_type;

-- Verified final result:
-- - authenticated has SELECT only on public.tools.
-- - authenticated has SELECT only on public.workers.
-- - anon has no direct grants.
-- - PUBLIC has no direct grants.


-- ============================================================
-- 13) AFTER CHECK - Confirm final effective table privileges
-- ============================================================

with checked_roles(role_name) as (
  values
    ('authenticated'),
    ('anon')
),
checked_tables(table_name) as (
  values
    ('workers'),
    ('tools')
)
select
  checked_roles.role_name,
  checked_tables.table_name,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'select'
  ) as can_select,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'insert'
  ) as can_insert,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'update'
  ) as can_update,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'delete'
  ) as can_delete,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'truncate'
  ) as can_truncate,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'references'
  ) as can_references,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'trigger'
  ) as can_trigger
from checked_roles
cross join checked_tables
order by
  checked_tables.table_name,
  checked_roles.role_name;

-- Verified final result:
--
-- anon on tools:
-- - all privileges = false
--
-- authenticated on tools:
-- - can_select = true
-- - all mutation/dangerous privileges = false
--
-- anon on workers:
-- - all privileges = false
--
-- authenticated on workers:
-- - can_select = true
-- - all mutation/dangerous privileges = false


-- ============================================================
-- 14) AFTER CHECK - Confirm RPC grants remain valid
-- ============================================================

select
  routine_schema,
  routine_name,
  grantee,
  privilege_type
from information_schema.routine_privileges
where routine_schema = 'public'
  and routine_name in (
    'create_worker',
    'update_worker',
    'deactivate_worker',
    'reactivate_worker',
    'create_tool',
    'update_tool',
    'deactivate_tool',
    'reactivate_tool'
  )
order by
  routine_name,
  grantee,
  privilege_type;

-- Verified final result:
-- - authenticated has EXECUTE on all 8 worker/tool RPCs.
-- - postgres has EXECUTE on all 8 worker/tool RPCs.
-- - anon has no EXECUTE grants.
-- - PUBLIC has no EXECUTE grants.


-- ============================================================
-- 15) AFTER CHECK - Confirm effective RPC execute privileges
-- ============================================================

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  has_function_privilege(
    'authenticated',
    p.oid,
    'execute'
  ) as authenticated_can_execute,
  has_function_privilege(
    'anon',
    p.oid,
    'execute'
  ) as anon_can_execute,
  has_function_privilege(
    'public',
    p.oid,
    'execute'
  ) as public_can_execute
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'create_worker',
    'update_worker',
    'deactivate_worker',
    'reactivate_worker',
    'create_tool',
    'update_tool',
    'deactivate_tool',
    'reactivate_tool'
  )
order by
  p.proname,
  pg_get_function_identity_arguments(p.oid);

-- Verified final result:
-- - authenticated_can_execute = true for all 8 worker/tool RPCs.
-- - anon_can_execute = false for all 8 worker/tool RPCs.
-- - public_can_execute = false for all 8 worker/tool RPCs.


-- ============================================================
-- 16) MANUAL APP TEST CHECKLIST
-- ============================================================
--
-- Positive RPC flow tests completed:
--
-- [x] Worker create works through UI/RPC.
-- [x] Worker update works through UI/RPC.
-- [x] Worker deactivate works through UI/RPC.
-- [x] Worker reactivate works through UI/RPC.
--
-- [x] Tool create works through UI/RPC.
-- [x] Tool update works through UI/RPC.
-- [x] Tool deactivate works through UI/RPC.
-- [x] Tool reactivate works through UI/RPC.
--
-- Read/display flow:
--
-- [x] Workers list can still read workers.
-- [x] Tools list can still read tools.
--
-- Remaining recommended role-denial tests before closing Issue #32:
--
-- [ ] Warehouse User cannot create worker.
-- [ ] Warehouse User cannot update worker.
-- [ ] Warehouse User cannot deactivate worker.
-- [ ] Warehouse User cannot reactivate worker.
--
-- [ ] Viewer cannot create worker.
-- [ ] Viewer cannot update worker.
-- [ ] Viewer cannot deactivate worker.
-- [ ] Viewer cannot reactivate worker.
--
-- [ ] Warehouse User cannot create tool.
-- [ ] Warehouse User cannot update tool.
-- [ ] Warehouse User cannot deactivate tool.
-- [ ] Warehouse User cannot reactivate tool.
--
-- [ ] Viewer cannot create tool.
-- [ ] Viewer cannot update tool.
-- [ ] Viewer cannot deactivate tool.
-- [ ] Viewer cannot reactivate tool.
--
-- Cross-company tests recommended before final security sign-off:
--
-- [ ] User from Company A cannot read Company B workers.
-- [ ] User from Company A cannot read Company B tools.
-- [ ] User from Company A cannot mutate Company B workers through RPC.
-- [ ] User from Company A cannot mutate Company B tools through RPC.


-- ============================================================
-- 17) FINAL ISSUE #32 SUMMARY
-- ============================================================
--
-- Final decision:
-- Worker and tool mutations are RPC-only.
--
-- Final public.workers state:
-- - RLS enabled.
-- - SELECT policy remains:
--   - Members can read workers
-- - Direct INSERT / UPDATE / DELETE policies removed.
-- - authenticated has SELECT only.
-- - anon has no direct privileges.
-- - PUBLIC has no direct mutation / dangerous privileges.
--
-- Final public.tools state:
-- - RLS enabled.
-- - SELECT policy remains:
--   - Members can read tools
-- - Direct INSERT / UPDATE / DELETE policies removed.
-- - authenticated has SELECT only.
-- - anon has no direct privileges.
-- - PUBLIC has no direct mutation / dangerous privileges.
--
-- Final RPC state:
-- - create_worker authenticated EXECUTE remains available.
-- - update_worker authenticated EXECUTE remains available.
-- - deactivate_worker authenticated EXECUTE remains available.
-- - reactivate_worker authenticated EXECUTE remains available.
-- - create_tool authenticated EXECUTE remains available.
-- - update_tool authenticated EXECUTE remains available.
-- - deactivate_tool authenticated EXECUTE remains available.
-- - reactivate_tool authenticated EXECUTE remains available.
-- - anon cannot execute worker/tool mutation RPCs.
-- - PUBLIC cannot execute worker/tool mutation RPCs.
--
-- Result:
-- Direct worker/tool table mutation bypass risk is removed.
-- Worker/tool mutation architecture is now clearer and aligned with the RPC flow.