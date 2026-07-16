-- Issue #47 - Disable authenticated self-service company creation
--
-- Goal:
-- Keep company workspace creation outside the public Flutter application.
-- Company workspaces must be provisioned only through an approved backend/admin
-- onboarding process. A normal authenticated app user must not be able to call
-- public.create_company_with_defaults(...).
--
-- IMPORTANT:
-- 1. Run the BEFORE CHECK first and confirm the function signature.
-- 2. Apply this script to every release Supabase environment.
-- 3. Verify the Flutter no-company flow shows the approved-onboarding screen.
-- 4. Provision companies only from trusted backend/admin context.

-- ============================================================
-- 1) BEFORE CHECK - Confirm current grants
-- ============================================================

select
  n.nspname as schema_name,
  p.proname as function_name,
  p.oid::regprocedure as function_signature,
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
-- 2) APPLY - Remove public app execution
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
from public, anon, authenticated;

-- Keep trusted server-side provisioning available when an approved backend
-- process explicitly uses the Supabase service role. Never expose that key in
-- Flutter or any public client.
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
to service_role;

-- ============================================================
-- 3) AFTER CHECK - Confirm final grants
-- ============================================================

select
  n.nspname as schema_name,
  p.proname as function_name,
  p.oid::regprocedure as function_signature,
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

-- Expected release result:
-- - PUBLIC: no EXECUTE
-- - anon: no EXECUTE
-- - authenticated: no EXECUTE
-- - service_role: EXECUTE
-- - postgres/function owner may retain owner privileges

-- ============================================================
-- 4) RELEASE VERIFICATION CHECKLIST
-- ============================================================
--
-- [ ] Unauthenticated user cannot execute the RPC.
-- [ ] Authenticated user without a company cannot execute the RPC.
-- [ ] Authenticated user without a company sees Company access required.
-- [ ] A valid pending invitation can still be accepted.
-- [ ] Existing active company members can still open their company workspace.
-- [ ] Trusted admin/backend provisioning can create a company.
-- [ ] No service-role key exists in Flutter, build arguments, or repository.
