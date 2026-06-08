-- Issue #49 - Team member identity visibility RPC
--
-- Scope:
-- - Backend SQL only.
-- - No Flutter changes in this file.
-- - No PROJECT_ROADMAP.md changes.
--
-- Problem:
-- Team screen previously read company_members directly and joined profiles.
-- The profiles RLS policy only exposes target profile data when the target member
-- is active in a shared company with the current user.
--
-- Resulting issue:
-- Some inactive company members could appear as Unknown/Anon in Team management,
-- even though the current active user is allowed to reactivate/manage them by
-- role hierarchy.
--
-- Design decision:
-- - Do not broaden the general profiles RLS policy.
-- - Add a read-only SECURITY DEFINER RPC specifically for Team management.
-- - Return profile identity only when it is safe for the current active actor role.
--
-- Visibility rules:
-- - Active target members: identity is returned.
-- - Inactive target members:
--   - owner can see all inactive member identities.
--   - admin can see inactive non-owner/non-admin identities.
--   - warehouse_manager can see inactive warehouse_user/viewer identities only.
--   - lower roles do not receive additional inactive identities.
--
-- Security:
-- - Caller must be authenticated.
-- - Caller must have an active membership in p_company_id.
-- - Function is SECURITY DEFINER.
-- - search_path is pinned to public, private.
-- - Function is read-only; it does not insert/update/delete data.
-- - EXECUTE is revoked from anon and public.
-- - EXECUTE is granted only to authenticated.

create or replace function public.get_company_members_for_team(
  p_company_id uuid
)
returns table (
  id uuid,
  company_id uuid,
  profile_id uuid,
  role text,
  status text,
  joined_at timestamptz,
  invited_by_profile_id uuid,
  created_at timestamptz,
  updated_at timestamptz,
  full_name text,
  email text,
  invited_by_name text,
  invited_by_email text
)
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
declare
  v_actor_profile_id uuid;
  v_actor_role public.company_member_role;
begin
  if auth.uid() is null then
    raise exception 'You must be logged in to view company team members.';
  end if;

  v_actor_profile_id := private.current_profile_id();

  if v_actor_profile_id is null then
    raise exception 'Current profile was not found.';
  end if;

  select cm.role
  into v_actor_role
  from public.company_members cm
  where cm.company_id = p_company_id
    and cm.profile_id = v_actor_profile_id
    and cm.status = 'active'::public.member_status
  limit 1;

  if v_actor_role is null then
    raise exception 'You do not have permission to view company team members.';
  end if;

  return query
  select
    cm.id,
    cm.company_id,
    cm.profile_id,
    cm.role::text as role,
    cm.status::text as status,
    cm.joined_at,
    cm.invited_by_profile_id,
    cm.created_at,
    cm.updated_at,

    case
      when cm.status = 'active'::public.member_status then pr.full_name
      when v_actor_role = 'owner'::public.company_member_role then pr.full_name
      when v_actor_role = 'admin'::public.company_member_role
        and cm.role not in (
          'owner'::public.company_member_role,
          'admin'::public.company_member_role
        )
        then pr.full_name
      when v_actor_role = 'warehouse_manager'::public.company_member_role
        and cm.role in (
          'warehouse_user'::public.company_member_role,
          'viewer'::public.company_member_role
        )
        then pr.full_name
      else null
    end as full_name,

    case
      when cm.status = 'active'::public.member_status then pr.email
      when v_actor_role = 'owner'::public.company_member_role then pr.email
      when v_actor_role = 'admin'::public.company_member_role
        and cm.role not in (
          'owner'::public.company_member_role,
          'admin'::public.company_member_role
        )
        then pr.email
      when v_actor_role = 'warehouse_manager'::public.company_member_role
        and cm.role in (
          'warehouse_user'::public.company_member_role,
          'viewer'::public.company_member_role
        )
        then pr.email
      else null
    end as email,

    inviter.full_name as invited_by_name,
    inviter.email as invited_by_email

  from public.company_members cm
  left join public.profiles pr
    on pr.id = cm.profile_id
  left join public.profiles inviter
    on inviter.id = cm.invited_by_profile_id
  where cm.company_id = p_company_id
  order by cm.created_at;
end;
$function$;

revoke execute
on function public.get_company_members_for_team(uuid)
from anon;

revoke execute
on function public.get_company_members_for_team(uuid)
from public;

grant execute
on function public.get_company_members_for_team(uuid)
to authenticated;

-- Verification queries used during implementation:
--
-- 1) Verify function security and grants:
-- select
--   n.nspname as schema_name,
--   p.proname as function_name,
--   pg_get_function_identity_arguments(p.oid) as arguments,
--   pg_get_function_result(p.oid) as result_type,
--   p.prosecdef as is_security_definer,
--   p.proconfig as function_settings,
--   has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_can_execute,
--   has_function_privilege('anon', p.oid, 'EXECUTE') as anon_can_execute
-- from pg_proc p
-- join pg_namespace n
--   on n.oid = p.pronamespace
-- where n.nspname = 'public'
--   and p.proname = 'get_company_members_for_team';
--
-- 2) Simulate authenticated role context in SQL Editor:
-- begin;
-- select set_config('request.jwt.claim.sub', '<auth_user_id>', true);
-- select set_config('request.jwt.claim.role', 'authenticated', true);
-- select * from public.get_company_members_for_team('<company_id>'::uuid);
-- rollback;
