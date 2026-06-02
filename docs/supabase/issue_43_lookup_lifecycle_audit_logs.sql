-- Issue #43 - Add audit logging and direct accountability for lookup lifecycle actions
--
-- Scope:
-- - Backend SQL only.
-- - No Flutter changes.
-- - No RLS policy changes.
-- - No direct table privilege changes.
-- - No PROJECT_ROADMAP.md changes.
--
-- Goal:
-- Add trusted backend audit logging for lookup lifecycle RPC actions:
-- - departments
-- - job_titles
-- - tool_units
-- - tool_categories
--
-- Safety:
-- - Actor identity is NOT accepted from Flutter/client input.
-- - Actor identity is resolved by private.write_audit_log()
--   through private.current_profile_id().
-- - private.write_audit_log() stores:
--   - actor_profile_id
--   - actor_name_snapshot
--   - actor_email_snapshot
-- - Existing RPC-only lookup mutation flow from Issue #35 is preserved.
-- - Existing role checks are preserved.
-- - Existing company-scope checks are preserved.
-- - Existing direct write hardening remains unchanged.
--
-- Applied in batches:
-- - Batch A: Departments
-- - Batch B: Job Titles
-- - Batch C: Tool Units
-- - Batch D: Tool Categories
--
-- Verified:
-- - All 12 lookup lifecycle RPCs include private.write_audit_log.
-- - All 12 lookup lifecycle RPCs include the expected audit action.
-- - All 12 lookup lifecycle RPCs remain SECURITY DEFINER.
-- - All 12 lookup lifecycle RPCs keep search_path="".
-- - anon cannot execute the RPCs.
-- - authenticated can execute the RPCs.
-- - lookup tables remain SELECT-only for authenticated.
-- - audit_logs remains SELECT-only for authenticated.
-- - Manual tool unit lifecycle test passed:
--   - tool_unit_created
--   - tool_unit_deactivated
--   - tool_unit_reactivated


-- ============================================================
-- Final RPC audit logging verification
-- ============================================================

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  position('private.write_audit_log' in pg_get_functiondef(p.oid)) > 0 as includes_write_audit_log,
  case p.proname
    when 'create_department' then
      position('department_created' in pg_get_functiondef(p.oid)) > 0
    when 'deactivate_department' then
      position('department_deactivated' in pg_get_functiondef(p.oid)) > 0
    when 'reactivate_department' then
      position('department_reactivated' in pg_get_functiondef(p.oid)) > 0

    when 'create_job_title' then
      position('job_title_created' in pg_get_functiondef(p.oid)) > 0
    when 'deactivate_job_title' then
      position('job_title_deactivated' in pg_get_functiondef(p.oid)) > 0
    when 'reactivate_job_title' then
      position('job_title_reactivated' in pg_get_functiondef(p.oid)) > 0

    when 'create_tool_unit' then
      position('tool_unit_created' in pg_get_functiondef(p.oid)) > 0
    when 'deactivate_tool_unit' then
      position('tool_unit_deactivated' in pg_get_functiondef(p.oid)) > 0
    when 'reactivate_tool_unit' then
      position('tool_unit_reactivated' in pg_get_functiondef(p.oid)) > 0

    when 'create_tool_category' then
      position('tool_category_created' in pg_get_functiondef(p.oid)) > 0
    when 'deactivate_tool_category' then
      position('tool_category_deactivated' in pg_get_functiondef(p.oid)) > 0
    when 'reactivate_tool_category' then
      position('tool_category_reactivated' in pg_get_functiondef(p.oid)) > 0

    else false
  end as includes_expected_action,
  p.prosecdef as is_security_definer,
  p.proconfig as function_config,
  has_function_privilege('anon', p.oid, 'execute') as anon_can_execute,
  has_function_privilege('authenticated', p.oid, 'execute') as authenticated_can_execute
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
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
order by
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- Final table privileges verification
-- ============================================================

select
  grantee,
  table_schema,
  table_name,
  privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name in (
    'departments',
    'job_titles',
    'tool_units',
    'tool_categories',
    'audit_logs'
  )
  and grantee in ('anon', 'authenticated', 'PUBLIC')
order by
  table_name,
  grantee,
  privilege_type;


-- ============================================================
-- Final recent lookup lifecycle audit rows check
-- ============================================================

select
  id,
  company_id,
  actor_profile_id,
  actor_name_snapshot,
  actor_email_snapshot,
  action,
  entity_type,
  entity_id,
  entity_label_snapshot,
  old_data,
  new_data,
  metadata,
  created_at
from public.audit_logs
where action in (
  'department_created',
  'department_deactivated',
  'department_reactivated',
  'job_title_created',
  'job_title_deactivated',
  'job_title_reactivated',
  'tool_unit_created',
  'tool_unit_deactivated',
  'tool_unit_reactivated',
  'tool_category_created',
  'tool_category_deactivated',
  'tool_category_reactivated'
)
order by created_at desc
limit 50;


-- ============================================================
-- Manual verification result
-- ============================================================
--
-- Test entity:
-- - table: public.tool_units
-- - id: fc9632f8-912c-4abc-abc5-02f06af5ae9a
-- - label: Test Unit
-- - company_id: defc381c-13d3-4f08-b1ac-128b52505311
--
-- Verified audit rows:
-- - tool_unit_created
-- - tool_unit_deactivated
-- - tool_unit_reactivated
--
-- Verified actor snapshot:
-- - actor_profile_id: 26aad88b-e62b-41c7-827f-08572f0dbf31
-- - actor_name_snapshot: Mina Adly Bushra
-- - actor_email_snapshot: adlymina99@gmail.com
--
-- Verified metadata:
-- - {"rpc":"create_tool_unit"}
-- - {"rpc":"deactivate_tool_unit"}
-- - {"rpc":"reactivate_tool_unit"}
--
-- Notes:
-- - No direct audit_logs INSERT/UPDATE/DELETE privilege was granted.
-- - No direct lookup table INSERT/UPDATE/DELETE privilege was granted.
-- - Lookup lifecycle mutation remains RPC-only.