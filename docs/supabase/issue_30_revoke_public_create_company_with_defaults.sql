-- Issue #30 - Revoke PUBLIC execute from create_company_with_defaults
--
-- Goal:
-- Remove EXECUTE access from PUBLIC for:
-- public.create_company_with_defaults(text,text,text,text,text,text,text,text,text,text,text,text,text,text)
--
-- Keep EXECUTE access for authenticated users.
--
-- Why:
-- Company creation should only be available to authenticated users.
-- Anonymous / PUBLIC execution should not be allowed.
--
-- Do not modify PROJECT_ROADMAP.md for this issue.

-- ============================================================
-- 1) BEFORE CHECK - Confirm current function grants
-- ============================================================

select
  n.nspname as schema_name,
  p.proname as function_name,
  p.oid::regprocedure as function_signature,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  case
    when acl.grantee = 0 then 'PUBLIC'
    else r.rolname
  end as grantee,
  acl.privilege_type,
  acl.is_grantable
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
cross join lateral aclexplode(
  coalesce(
    p.proacl,
    acldefault('f', p.proowner)
  )
) as acl
left join pg_roles r
  on r.oid = acl.grantee
where n.nspname = 'public'
  and p.proname = 'create_company_with_defaults'
  and acl.privilege_type = 'EXECUTE'
order by
  p.oid::regprocedure,
  grantee;


-- ============================================================
-- 2) APPLY CHANGE - Revoke PUBLIC execute only
-- ============================================================

revoke execute
on function public.create_company_with_defaults(
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text
)
from public;


-- Keep authenticated execution explicitly granted.
grant execute
on function public.create_company_with_defaults(
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text
)
to authenticated;


-- ============================================================
-- 3) AFTER CHECK - Confirm final function grants
-- ============================================================

select
  n.nspname as schema_name,
  p.proname as function_name,
  p.oid::regprocedure as function_signature,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  case
    when acl.grantee = 0 then 'PUBLIC'
    else r.rolname
  end as grantee,
  acl.privilege_type,
  acl.is_grantable
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
cross join lateral aclexplode(
  coalesce(
    p.proacl,
    acldefault('f', p.proowner)
  )
) as acl
left join pg_roles r
  on r.oid = acl.grantee
where n.nspname = 'public'
  and p.proname = 'create_company_with_defaults'
  and acl.privilege_type = 'EXECUTE'
order by
  p.oid::regprocedure,
  grantee;


-- ============================================================
-- 4) EXPECTED RESULT
-- ============================================================
--
-- Expected AFTER CHECK:
--
-- grantee       | privilege_type
-- --------------|---------------
-- authenticated | EXECUTE
-- postgres      | EXECUTE
--
-- PUBLIC should no longer appear.
--
-- ============================================================
-- 5) MANUAL TEST CHECKLIST
-- ============================================================
--
-- [ ] Anonymous users cannot execute create_company_with_defaults.
-- [ ] Authenticated users can still create a company.
-- [ ] Company defaults are created correctly after company creation.
-- [ ] Existing Flutter create company flow still works.