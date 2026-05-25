-- Issue #38 - Harden Supabase Security Advisor warnings
-- Step 38.1 - Document initial Security Advisor cleanup
--
-- Scope:
-- Documentation only. No Flutter changes. No PROJECT_ROADMAP.md changes.
--
-- Safety warning:
-- Do not bulk-revoke EXECUTE from every SECURITY DEFINER function that is
-- executable by authenticated users. Some of those functions are intentional
-- secure RPCs used by the Flutter app and must be reviewed one by one.


-- ============================================================
-- 1) Initial Security Advisor state
-- ============================================================

-- Before initial manual cleanup:
-- - Supabase Security Advisor showed 51 warnings.
--
-- After initial manual cleanup:
-- - Supabase Security Advisor showed 43 warnings.
--
-- Remaining warnings are mainly:
-- - Signed-In Users Can Execute SECURITY DEFINER Function
--
-- Decision:
-- Remaining warnings require function-by-function review, not a blanket
-- permission change.


-- ============================================================
-- 2) Manual cleanup already applied in Supabase
-- ============================================================

-- The following manual changes were already applied in Supabase and are
-- recorded here for audit/documentation purposes.
--
-- A) Fixed search_path for utility/helper functions:
--
--   alter function public.set_updated_at()
--   set search_path = pg_catalog;
--
--   alter function private.company_id_from_storage_path(text)
--   set search_path = pg_catalog;
--
-- B) Removed direct client execution from trigger/event/helper functions:
--
--   revoke execute on function public.handle_new_auth_user()
--   from anon, authenticated, public;
--
--   revoke execute on function public.prevent_inviting_existing_company_member()
--   from anon, authenticated, public;
--
--   revoke execute on function public.rls_auto_enable()
--   from anon, authenticated, public;
--
--   revoke execute on function public.set_updated_at()
--   from anon, authenticated, public;
--
-- Why:
-- - These helper functions should not be callable directly from client roles.
-- - The cleanup was limited and did not touch app-required RPCs.


-- ============================================================
-- 3) Verification query - fixed search_path state
-- ============================================================

-- Expected known result after cleanup:
-- - public.set_updated_at() function_config includes search_path=pg_catalog
-- - private.company_id_from_storage_path(text) function_config includes search_path=pg_catalog

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  case
    when p.prosecdef then 'SECURITY DEFINER'
    else 'SECURITY INVOKER'
  end as security_mode,
  p.proconfig as function_config
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where (n.nspname, p.proname) in (
  ('public', 'set_updated_at'),
  ('private', 'company_id_from_storage_path')
)
order by
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 4) Verification query - helper direct execute privileges
-- ============================================================

-- Expected known result after cleanup:
-- - anon can_execute = false for all listed public helper functions.
-- - authenticated can_execute = false for all listed public helper functions.

with checked_roles(role_name) as (
  values
    ('anon'),
    ('authenticated')
),
checked_functions(schema_name, function_name, identity_arguments) as (
  values
    ('public', 'handle_new_auth_user', ''),
    ('public', 'prevent_inviting_existing_company_member', ''),
    ('public', 'rls_auto_enable', ''),
    ('public', 'set_updated_at', '')
)
select
  checked_roles.role_name,
  checked_functions.schema_name,
  checked_functions.function_name,
  checked_functions.identity_arguments,
  has_function_privilege(
    checked_roles.role_name,
    format(
      '%I.%I(%s)',
      checked_functions.schema_name,
      checked_functions.function_name,
      checked_functions.identity_arguments
    ),
    'execute'
  ) as can_execute
from checked_roles
cross join checked_functions
order by
  checked_functions.schema_name,
  checked_functions.function_name,
  checked_roles.role_name;


-- ============================================================
-- 5) Verification query - private schema usage
-- ============================================================

-- Expected known result after cleanup:
-- - anon can_use_private_schema = false
-- - authenticated can_use_private_schema = false
--
-- Note:
-- private.company_id_from_storage_path(text) may still show EXECUTE privilege
-- for anon/authenticated when checked with has_function_privilege.
-- However, because USAGE on the private schema is false for client roles,
-- it should not be directly callable through the normal API surface.

select
  role_name,
  has_schema_privilege(role_name, 'private', 'usage') as can_use_private_schema
from (
  values
    ('anon'),
    ('authenticated')
) as checked_roles(role_name)
order by
  role_name;


-- ============================================================
-- 6) Review query - remaining SECURITY DEFINER functions
-- ============================================================

-- Purpose:
-- Capture the current list of SECURITY DEFINER functions that authenticated
-- users can execute. This is for review only.
--
-- Do not convert this result into a bulk permission-change script.

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  p.prosecdef as is_security_definer,
  p.proconfig as function_config,
  has_function_privilege('authenticated', p.oid, 'execute') as authenticated_can_execute,
  has_function_privilege('anon', p.oid, 'execute') as anon_can_execute
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where p.prosecdef = true
  and has_function_privilege('authenticated', p.oid, 'execute') = true
order by
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 7) Classification template for next steps
-- ============================================================

-- Each remaining SECURITY DEFINER function should be classified as one of:
--
-- 1. App-required RPC
--    Called by Flutter intentionally. Keep authenticated EXECUTE only if needed.
--
-- 2. Trigger/helper function
--    Used internally by triggers or maintenance. Usually should not be directly
--    executable by client roles.
--
-- 3. Legacy/duplicate function
--    Kept during migration/refactor. Candidate for later cleanup after checks.
--
-- 4. Candidate for targeted revoke
--    Not used by Flutter and not intended as an RPC endpoint.
--
-- 5. Candidate for deletion later
--    Unused, superseded, and safe to remove only after dependency checks.


-- ============================================================
-- 8) Required checks for app-required RPCs
-- ============================================================

-- For every app-required SECURITY DEFINER RPC, verify:
--
-- - Fixed search_path.
-- - Authenticated user check.
-- - Trusted current profile lookup from backend context.
-- - Active company membership check where applicable.
-- - Role permission check where applicable.
-- - Company scope check.
-- - No client-controlled actor identity.
-- - No tenant isolation bypass.
-- - No service-role key in Flutter.


-- ============================================================
-- 9) Current known state after Step 38.1
-- ============================================================

-- Known documented state:
-- - Security Advisor warnings were reduced from 51 to 43.
-- - public.set_updated_at() uses search_path=pg_catalog.
-- - private.company_id_from_storage_path(text) uses search_path=pg_catalog.
-- - Direct EXECUTE was removed from anon/authenticated/public for:
--   - public.handle_new_auth_user()
--   - public.prevent_inviting_existing_company_member()
--   - public.rls_auto_enable()
--   - public.set_updated_at()
-- - private schema USAGE remains unavailable to anon/authenticated.
-- - Remaining SECURITY DEFINER warnings still require structured review.
--
-- Next suggested step:
-- Step 38.2 - Capture and classify the remaining SECURITY DEFINER warnings.
