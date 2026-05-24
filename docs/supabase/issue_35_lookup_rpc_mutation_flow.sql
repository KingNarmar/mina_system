-- Issue #35 — Lookup RPC Mutation Flow and Direct Write Hardening
--
-- Decision:
-- Lookup mutations are controlled through SECURITY DEFINER RPCs.
-- Flutter must not perform direct INSERT / UPDATE / DELETE on lookup tables.
--
-- Lookup tables:
-- - public.departments
-- - public.job_titles
-- - public.tool_units
-- - public.tool_categories
--
-- Mutation model:
-- - Create = create a new active record only.
-- - Delete = soft deactivate by setting is_active = false through RPC.
-- - Restore = reactivate inactive record through explicit RPC.
-- - UI displays Active / Inactive records separately.
--
-- Duplicate behavior:
-- - Active duplicates are rejected.
-- - Inactive duplicates are rejected with a restore instruction.
-- - Names are compared using normalized matching in Flutter and backend guards.

begin;

-- Keep lookup tables readable by authenticated users.
-- Remove all direct table privileges from client roles first.
revoke all privileges
on table
  public.departments,
  public.job_titles,
  public.tool_units,
  public.tool_categories
from anon, authenticated, public;

-- Re-grant read-only access to authenticated users.
-- Flutter needs SELECT for loading active/inactive lookup lists.
grant select
on table
  public.departments,
  public.job_titles,
  public.tool_units,
  public.tool_categories
to authenticated;

commit;

-- Verification query:
--
-- Expected result:
-- authenticated should have SELECT only.
-- anon and PUBLIC should have no table privileges.
--
-- select
--   grantee,
--   table_schema,
--   table_name,
--   privilege_type
-- from information_schema.role_table_grants
-- where table_schema = 'public'
--   and table_name in (
--     'departments',
--     'job_titles',
--     'tool_units',
--     'tool_categories'
--   )
--   and grantee in ('anon', 'authenticated', 'PUBLIC')
-- order by
--   table_name,
--   grantee,
--   privilege_type;