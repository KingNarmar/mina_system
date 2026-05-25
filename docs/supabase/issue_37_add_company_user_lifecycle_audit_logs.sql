-- Issue #37 - Add audit logging for company user lifecycle actions
--
-- Scope:
-- - Backend SQL only.
-- - No Flutter changes.
-- - No PROJECT_ROADMAP.md changes.
-- - No RLS policy changes.
-- - No permission revoke changes.
--
-- Goal:
-- Add trusted audit log records for company-user lifecycle RPC actions:
-- - invite_company_user
-- - accept_company_invitation
-- - cancel_company_invitation
-- - change_company_member_role
-- - deactivate_company_member
-- - reactivate_company_member
--
-- Safety:
-- Actor identity is not accepted from Flutter/client input.
-- Actor identity is resolved by private.write_audit_log() using trusted backend context.
-- Existing secure RPC role restrictions remain unchanged.


-- ============================================================
-- 1) invite_company_user
-- ============================================================

create or replace function public.invite_company_user(
  p_company_id uuid,
  p_email text,
  p_role text
)
returns uuid
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
declare
  v_profile_id uuid;
  v_actor_role public.company_member_role;
  v_email text;
  v_role text;
  v_invitation_id uuid;
begin
  if auth.uid() is null then
    raise exception 'You must be logged in to invite a company user.';
  end if;

  v_profile_id := private.current_profile_id();

  if v_profile_id is null then
    raise exception 'Current profile was not found.';
  end if;

  v_email := lower(trim(coalesce(p_email, '')));
  v_role := lower(trim(coalesce(p_role, '')));

  if v_email = '' then
    raise exception 'Email is required.';
  end if;

  if v_role not in (
    'admin',
    'warehouse_manager',
    'warehouse_user',
    'viewer'
  ) then
    raise exception 'Invalid invitation role.';
  end if;

  select cm.role
  into v_actor_role
  from public.company_members cm
  where cm.company_id = p_company_id
    and cm.profile_id = v_profile_id
    and cm.status = 'active'::public.member_status
  limit 1;

  if v_actor_role is null then
    raise exception 'You do not have permission to invite company users.';
  end if;

  if v_actor_role = 'owner'::public.company_member_role then
    null;
  elsif v_actor_role = 'admin'::public.company_member_role then
    if v_role = 'admin' then
      raise exception 'Admins cannot invite another admin.';
    end if;
  else
    raise exception 'You do not have permission to invite company users.';
  end if;

  if exists (
    select 1
    from public.company_invitations ci
    where ci.company_id = p_company_id
      and lower(trim(ci.email)) = v_email
      and ci.status = 'pending'::public.company_invitation_status
  ) then
    raise exception 'A pending invitation already exists for this email.';
  end if;

  if exists (
    select 1
    from public.profiles p
    join public.company_members cm
      on cm.profile_id = p.id
    where cm.company_id = p_company_id
      and cm.status = 'active'::public.member_status
      and lower(trim(p.email)) = v_email
  ) then
    raise exception 'This user is already an active company member.';
  end if;

  insert into public.company_invitations (
    company_id,
    email,
    role,
    status,
    invited_by_profile_id,
    created_at,
    updated_at
  )
  values (
    p_company_id,
    v_email,
    v_role::public.company_member_role,
    'pending'::public.company_invitation_status,
    v_profile_id,
    now(),
    now()
  )
  returning id into v_invitation_id;

  perform private.write_audit_log(
    p_company_id,
    'company_user_invited',
    'company_invitation',
    v_invitation_id,
    v_email,
    null,
    jsonb_build_object(
      'email', v_email,
      'role', v_role,
      'status', 'pending',
      'invited_by_profile_id', v_profile_id
    ),
    jsonb_build_object(
      'rpc', 'invite_company_user'
    )
  );

  return v_invitation_id;
end;
$function$;


-- ============================================================
-- 2) accept_company_invitation
-- ============================================================

create or replace function public.accept_company_invitation(
  p_invitation_id uuid
)
returns uuid
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
declare
  v_profile_id uuid;
  v_profile_email text;
  v_invitation record;
  v_member_id uuid;
begin
  if auth.uid() is null then
    raise exception 'You must be logged in to accept an invitation.';
  end if;

  v_profile_id := private.current_profile_id();

  if v_profile_id is null then
    raise exception 'Current profile was not found.';
  end if;

  select p.email
  into v_profile_email
  from public.profiles p
  where p.id = v_profile_id
    and p.auth_user_id = auth.uid();

  if v_profile_email is null then
    raise exception 'Current profile email was not found.';
  end if;

  select *
  into v_invitation
  from public.company_invitations ci
  where ci.id = p_invitation_id
  for update;

  if not found then
    raise exception 'Invitation was not found.';
  end if;

  if v_invitation.status <> 'pending'::public.company_invitation_status then
    raise exception 'This invitation is no longer pending.';
  end if;

  if v_invitation.expires_at <= now() then
    update public.company_invitations
    set
      status = 'expired'::public.company_invitation_status,
      updated_at = now()
    where id = p_invitation_id;

    raise exception 'This invitation has expired.';
  end if;

  if lower(trim(v_invitation.email)) <> lower(trim(v_profile_email)) then
    raise exception 'This invitation does not belong to the current user.';
  end if;

  insert into public.company_members (
    company_id,
    profile_id,
    role,
    status,
    joined_at,
    invited_by_profile_id,
    created_at,
    updated_at
  )
  values (
    v_invitation.company_id,
    v_profile_id,
    v_invitation.role,
    'active'::public.member_status,
    now(),
    v_invitation.invited_by_profile_id,
    now(),
    now()
  )
  on conflict (company_id, profile_id)
  do update
  set
    role = case
      when public.company_members.status = 'active'::public.member_status
        then public.company_members.role
      else excluded.role
    end,
    status = 'active'::public.member_status,
    joined_at = coalesce(public.company_members.joined_at, now()),
    invited_by_profile_id = coalesce(
      public.company_members.invited_by_profile_id,
      excluded.invited_by_profile_id
    ),
    updated_at = now();

  select cm.id
  into v_member_id
  from public.company_members cm
  where cm.company_id = v_invitation.company_id
    and cm.profile_id = v_profile_id
  limit 1;

  update public.company_invitations
  set
    status = 'accepted'::public.company_invitation_status,
    accepted_by_profile_id = v_profile_id,
    accepted_at = now(),
    updated_at = now()
  where id = p_invitation_id;

  perform private.write_audit_log(
    v_invitation.company_id,
    'company_invitation_accepted',
    'company_invitation',
    p_invitation_id,
    v_invitation.email,
    jsonb_build_object(
      'email', v_invitation.email,
      'role', v_invitation.role::text,
      'status', 'pending',
      'invited_by_profile_id', v_invitation.invited_by_profile_id
    ),
    jsonb_build_object(
      'email', v_invitation.email,
      'role', v_invitation.role::text,
      'status', 'accepted',
      'accepted_by_profile_id', v_profile_id,
      'member_id', v_member_id,
      'member_profile_id', v_profile_id
    ),
    jsonb_build_object(
      'rpc', 'accept_company_invitation'
    )
  );

  return v_invitation.company_id;
end;
$function$;


-- ============================================================
-- 3) cancel_company_invitation
-- ============================================================

create or replace function public.cancel_company_invitation(
  p_invitation_id uuid
)
returns uuid
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
declare
  v_profile_id uuid;
  v_invitation record;
begin
  if auth.uid() is null then
    raise exception 'You must be logged in to cancel an invitation.';
  end if;

  v_profile_id := private.current_profile_id();

  if v_profile_id is null then
    raise exception 'Current profile was not found.';
  end if;

  select *
  into v_invitation
  from public.company_invitations ci
  where ci.id = p_invitation_id
  for update;

  if not found then
    raise exception 'Invitation was not found.';
  end if;

  if not private.has_company_role(
    v_invitation.company_id,
    array[
      'owner'::public.company_member_role,
      'admin'::public.company_member_role
    ]
  ) then
    raise exception 'You do not have permission to cancel this invitation.';
  end if;

  if v_invitation.status <> 'pending'::public.company_invitation_status then
    raise exception 'Only pending invitations can be cancelled.';
  end if;

  update public.company_invitations
  set
    status = 'cancelled'::public.company_invitation_status,
    cancelled_by_profile_id = v_profile_id,
    cancelled_at = now(),
    updated_at = now()
  where id = p_invitation_id;

  perform private.write_audit_log(
    v_invitation.company_id,
    'company_invitation_cancelled',
    'company_invitation',
    p_invitation_id,
    v_invitation.email,
    jsonb_build_object(
      'email', v_invitation.email,
      'role', v_invitation.role::text,
      'status', 'pending',
      'invited_by_profile_id', v_invitation.invited_by_profile_id
    ),
    jsonb_build_object(
      'email', v_invitation.email,
      'role', v_invitation.role::text,
      'status', 'cancelled',
      'cancelled_by_profile_id', v_profile_id
    ),
    jsonb_build_object(
      'rpc', 'cancel_company_invitation'
    )
  );

  return v_invitation.company_id;
end;
$function$;


-- ============================================================
-- 4) change_company_member_role
-- ============================================================

create or replace function public.change_company_member_role(
  p_company_id uuid,
  p_member_id uuid,
  p_new_role text
)
returns void
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
declare
  v_actor_profile_id uuid;
  v_actor_role public.company_member_role;
  v_target_profile_id uuid;
  v_target_role public.company_member_role;
  v_target_status public.member_status;
  v_target_name text;
  v_target_email text;
  v_new_role text;
begin
  if auth.uid() is null then
    raise exception 'You must be logged in to change a member role.';
  end if;

  v_actor_profile_id := private.current_profile_id();

  if v_actor_profile_id is null then
    raise exception 'Current profile was not found.';
  end if;

  v_new_role := lower(trim(coalesce(p_new_role, '')));

  if v_new_role not in (
    'admin',
    'warehouse_manager',
    'warehouse_user',
    'viewer'
  ) then
    raise exception 'Invalid member role.';
  end if;

  select cm.role
  into v_actor_role
  from public.company_members cm
  where cm.company_id = p_company_id
    and cm.profile_id = v_actor_profile_id
    and cm.status = 'active'::public.member_status
  limit 1;

  if v_actor_role is null then
    raise exception 'You do not have permission to change member roles.';
  end if;

  select
    cm.profile_id,
    cm.role,
    cm.status,
    p.full_name,
    p.email
  into
    v_target_profile_id,
    v_target_role,
    v_target_status,
    v_target_name,
    v_target_email
  from public.company_members cm
  left join public.profiles p
    on p.id = cm.profile_id
  where cm.company_id = p_company_id
    and cm.id = p_member_id
  limit 1;

  if v_target_profile_id is null then
    raise exception 'Company member was not found.';
  end if;

  if v_target_profile_id = v_actor_profile_id then
    raise exception 'You cannot change your own role.';
  end if;

  if v_target_role = 'owner'::public.company_member_role then
    raise exception 'Owner role cannot be changed from member management.';
  end if;

  if v_target_status not in (
    'active'::public.member_status,
    'inactive'::public.member_status
  ) then
    raise exception 'Only active or inactive members can be managed.';
  end if;

  if v_target_role::text = v_new_role then
    raise exception 'Member already has this role.';
  end if;

  if v_actor_role = 'owner'::public.company_member_role then
    null;
  elsif v_actor_role = 'admin'::public.company_member_role then
    if v_target_role = 'admin'::public.company_member_role then
      raise exception 'Admins cannot manage another admin.';
    end if;

    if v_new_role = 'admin' then
      raise exception 'Admins cannot assign the admin role.';
    end if;
  else
    raise exception 'You do not have permission to change member roles.';
  end if;

  update public.company_members
  set
    role = v_new_role::public.company_member_role,
    updated_at = now()
  where company_id = p_company_id
    and id = p_member_id;

  perform private.write_audit_log(
    p_company_id,
    'company_member_role_changed',
    'company_member',
    p_member_id,
    coalesce(nullif(trim(coalesce(v_target_email, '')), ''), v_target_profile_id::text),
    jsonb_build_object(
      'member_id', p_member_id,
      'profile_id', v_target_profile_id,
      'full_name', v_target_name,
      'email', v_target_email,
      'role', v_target_role::text,
      'status', v_target_status::text
    ),
    jsonb_build_object(
      'member_id', p_member_id,
      'profile_id', v_target_profile_id,
      'full_name', v_target_name,
      'email', v_target_email,
      'role', v_new_role,
      'status', v_target_status::text
    ),
    jsonb_build_object(
      'rpc', 'change_company_member_role',
      'old_role', v_target_role::text,
      'new_role', v_new_role
    )
  );
end;
$function$;


-- ============================================================
-- 5) deactivate_company_member
-- ============================================================

create or replace function public.deactivate_company_member(
  p_company_id uuid,
  p_member_id uuid
)
returns void
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
declare
  v_actor_profile_id uuid;
  v_actor_role public.company_member_role;
  v_target_profile_id uuid;
  v_target_role public.company_member_role;
  v_target_status public.member_status;
  v_target_name text;
  v_target_email text;
begin
  if auth.uid() is null then
    raise exception 'You must be logged in to deactivate a member.';
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
    raise exception 'You do not have permission to deactivate members.';
  end if;

  select
    cm.profile_id,
    cm.role,
    cm.status,
    p.full_name,
    p.email
  into
    v_target_profile_id,
    v_target_role,
    v_target_status,
    v_target_name,
    v_target_email
  from public.company_members cm
  left join public.profiles p
    on p.id = cm.profile_id
  where cm.company_id = p_company_id
    and cm.id = p_member_id
  limit 1;

  if v_target_profile_id is null then
    raise exception 'Company member was not found.';
  end if;

  if v_target_profile_id = v_actor_profile_id then
    raise exception 'You cannot deactivate your own membership.';
  end if;

  if v_target_role = 'owner'::public.company_member_role then
    raise exception 'Owner membership cannot be deactivated.';
  end if;

  if v_target_status <> 'active'::public.member_status then
    raise exception 'Only active members can be deactivated.';
  end if;

  if v_actor_role = 'owner'::public.company_member_role then
    null;

  elsif v_actor_role = 'admin'::public.company_member_role then
    if v_target_role = 'admin'::public.company_member_role then
      raise exception 'Admins cannot manage another admin.';
    end if;

  elsif v_actor_role = 'warehouse_manager'::public.company_member_role then
    if v_target_role not in (
      'warehouse_user'::public.company_member_role,
      'viewer'::public.company_member_role
    ) then
      raise exception 'Warehouse managers can manage only warehouse users or viewers.';
    end if;

  else
    raise exception 'You do not have permission to deactivate members.';
  end if;

  update public.company_members
  set
    status = 'inactive'::public.member_status,
    updated_at = now()
  where company_id = p_company_id
    and id = p_member_id;

  perform private.write_audit_log(
    p_company_id,
    'company_member_deactivated',
    'company_member',
    p_member_id,
    coalesce(nullif(trim(coalesce(v_target_email, '')), ''), v_target_profile_id::text),
    jsonb_build_object(
      'member_id', p_member_id,
      'profile_id', v_target_profile_id,
      'full_name', v_target_name,
      'email', v_target_email,
      'role', v_target_role::text,
      'status', 'active'
    ),
    jsonb_build_object(
      'member_id', p_member_id,
      'profile_id', v_target_profile_id,
      'full_name', v_target_name,
      'email', v_target_email,
      'role', v_target_role::text,
      'status', 'inactive'
    ),
    jsonb_build_object(
      'rpc', 'deactivate_company_member'
    )
  );
end;
$function$;


-- ============================================================
-- 6) reactivate_company_member
-- ============================================================

create or replace function public.reactivate_company_member(
  p_company_id uuid,
  p_member_id uuid
)
returns void
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
declare
  v_actor_profile_id uuid;
  v_actor_role public.company_member_role;
  v_target_profile_id uuid;
  v_target_role public.company_member_role;
  v_target_status public.member_status;
  v_target_name text;
  v_target_email text;
begin
  if auth.uid() is null then
    raise exception 'You must be logged in to reactivate a member.';
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
    raise exception 'You do not have permission to reactivate members.';
  end if;

  select
    cm.profile_id,
    cm.role,
    cm.status,
    p.full_name,
    p.email
  into
    v_target_profile_id,
    v_target_role,
    v_target_status,
    v_target_name,
    v_target_email
  from public.company_members cm
  left join public.profiles p
    on p.id = cm.profile_id
  where cm.company_id = p_company_id
    and cm.id = p_member_id
  limit 1;

  if v_target_profile_id is null then
    raise exception 'Company member was not found.';
  end if;

  if v_target_profile_id = v_actor_profile_id then
    raise exception 'You cannot reactivate your own membership.';
  end if;

  if v_target_role = 'owner'::public.company_member_role then
    raise exception 'Owner membership cannot be managed from member management.';
  end if;

  if v_target_status <> 'inactive'::public.member_status then
    raise exception 'Only inactive members can be reactivated.';
  end if;

  if v_actor_role = 'owner'::public.company_member_role then
    null;

  elsif v_actor_role = 'admin'::public.company_member_role then
    if v_target_role = 'admin'::public.company_member_role then
      raise exception 'Admins cannot manage another admin.';
    end if;

  elsif v_actor_role = 'warehouse_manager'::public.company_member_role then
    if v_target_role not in (
      'warehouse_user'::public.company_member_role,
      'viewer'::public.company_member_role
    ) then
      raise exception 'Warehouse managers can manage only warehouse users or viewers.';
    end if;

  else
    raise exception 'You do not have permission to reactivate members.';
  end if;

  update public.company_members
  set
    status = 'active'::public.member_status,
    updated_at = now()
  where company_id = p_company_id
    and id = p_member_id;

  perform private.write_audit_log(
    p_company_id,
    'company_member_reactivated',
    'company_member',
    p_member_id,
    coalesce(nullif(trim(coalesce(v_target_email, '')), ''), v_target_profile_id::text),
    jsonb_build_object(
      'member_id', p_member_id,
      'profile_id', v_target_profile_id,
      'full_name', v_target_name,
      'email', v_target_email,
      'role', v_target_role::text,
      'status', 'inactive'
    ),
    jsonb_build_object(
      'member_id', p_member_id,
      'profile_id', v_target_profile_id,
      'full_name', v_target_name,
      'email', v_target_email,
      'role', v_target_role::text,
      'status', 'active'
    ),
    jsonb_build_object(
      'rpc', 'reactivate_company_member'
    )
  );
end;
$function$;


-- ============================================================
-- 7) Verification query - RPC definitions include audit logging
-- ============================================================

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  position('private.write_audit_log' in pg_get_functiondef(p.oid)) > 0 as includes_audit_logging,
  p.prosecdef as is_security_definer,
  p.proconfig as function_config
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'invite_company_user',
    'accept_company_invitation',
    'cancel_company_invitation',
    'change_company_member_role',
    'deactivate_company_member',
    'reactivate_company_member'
  )
order by
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 8) Verification query - private.write_audit_log direct client access
-- ============================================================

select
  checked_roles.role_name,
  has_schema_privilege(checked_roles.role_name, 'private', 'usage') as can_use_private_schema,
  has_function_privilege(
    checked_roles.role_name,
    'private.write_audit_log(uuid,text,text,uuid,text,jsonb,jsonb,jsonb)',
    'execute'
  ) as can_execute_write_audit_log
from (
  values
    ('anon'),
    ('authenticated')
) as checked_roles(role_name)
order by
  checked_roles.role_name;


-- ============================================================
-- 9) Verification query - recent lifecycle audit logs
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
  'company_user_invited',
  'company_invitation_accepted',
  'company_invitation_cancelled',
  'company_member_role_changed',
  'company_member_deactivated',
  'company_member_reactivated'
)
order by created_at desc
limit 50;