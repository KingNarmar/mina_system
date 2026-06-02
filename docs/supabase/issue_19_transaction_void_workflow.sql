-- Issue #19 - Phase A: Add transaction void workflow
--
-- Scope:
-- - Backend SQL only.
-- - No Flutter changes in this step.
-- - No PROJECT_ROADMAP.md changes.
-- - No normal transaction editing.
-- - No transaction deletion.
--
-- Business decision:
-- - Void is allowed only for:
--   - owner
--   - admin
--   - warehouse_manager
-- - warehouse_user cannot void transactions.
-- - viewer cannot void transactions.
--
-- Concept:
-- - Original transaction remains in public.transactions.
-- - Voided transaction is excluded from custody balance.
-- - User creates a new correct transaction after voiding the wrong one.
-- - Every void action is audited through private.write_audit_log().

begin;

-- ============================================================
-- 1. Add void metadata columns
-- ============================================================

alter table public.transactions
  add column if not exists is_voided boolean not null default false;

alter table public.transactions
  add column if not exists voided_at timestamptz;

alter table public.transactions
  add column if not exists voided_by_profile_id uuid;

alter table public.transactions
  add column if not exists voided_by_name_snapshot text;

alter table public.transactions
  add column if not exists voided_by_email_snapshot text;

alter table public.transactions
  add column if not exists void_reason text;


-- ============================================================
-- 2. Add safe consistency constraints
-- ============================================================

alter table public.transactions
  drop constraint if exists transactions_void_metadata_consistency;

alter table public.transactions
  add constraint transactions_void_metadata_consistency
  check (
    (
      is_voided = false
      and voided_at is null
      and voided_by_profile_id is null
      and voided_by_name_snapshot is null
      and voided_by_email_snapshot is null
      and nullif(btrim(coalesce(void_reason, '')), '') is null
    )
    or
    (
      is_voided = true
      and voided_at is not null
      and voided_by_profile_id is not null
      and nullif(btrim(coalesce(void_reason, '')), '') is not null
    )
  ) not valid;

alter table public.transactions
  drop constraint if exists transactions_void_reason_length;

alter table public.transactions
  add constraint transactions_void_reason_length
  check (
    void_reason is null
    or length(btrim(void_reason)) between 3 and 500
  ) not valid;


-- ============================================================
-- 3. Add helpful indexes
-- ============================================================

create index if not exists idx_transactions_company_voided
  on public.transactions (company_id, is_voided);

create index if not exists idx_transactions_voided_at
  on public.transactions (voided_at)
  where is_voided = true;


-- ============================================================
-- 4. Replace balance helper to ignore voided transactions
-- ============================================================
--
-- Important:
-- create_custody_transaction depends on public.get_worker_tool_balance().
-- If voided transactions are not ignored here, future transaction validation
-- will still count cancelled movements incorrectly.

create or replace function public.get_worker_tool_balance(
  p_company_id uuid,
  p_worker_id uuid,
  p_tool_id uuid
)
returns numeric
language sql
stable
security definer
set search_path to ''
as $function$
  select
    coalesce(
      sum(
        case
          when t.transaction_type::text = 'issue' then
            t.quantity

          when t.transaction_type::text = 'return' then
            -t.quantity

          when t.transaction_type::text in ('lost', 'damaged')
            and t.approval_status::text = 'approved'
            and t.settlement_status::text = 'settled' then
            -t.quantity

          else
            0
        end
      ),
      0
    )
  from public.transactions t
  where t.company_id = p_company_id
    and t.worker_id = p_worker_id
    and t.tool_id = p_tool_id
    and coalesce(t.is_voided, false) = false;
$function$;

revoke all
on function public.get_worker_tool_balance(uuid, uuid, uuid)
from public;

revoke all
on function public.get_worker_tool_balance(uuid, uuid, uuid)
from anon;

grant execute
on function public.get_worker_tool_balance(uuid, uuid, uuid)
to authenticated;


-- ============================================================
-- 5. Add secure void transaction RPC
-- ============================================================

create or replace function public.void_transaction(
  p_company_id uuid,
  p_transaction_id uuid,
  p_void_reason text
)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_actor_profile_id uuid;
  v_actor_name text;
  v_actor_email text;

  v_transaction record;

  v_clean_reason text;

  v_current_balance numeric;
  v_transaction_effect numeric;
  v_balance_after_void numeric;
begin
  -- ==========================================================
  -- 1. Authentication and required input validation
  -- ==========================================================

  if auth.uid() is null then
    raise exception 'Authentication required.';
  end if;

  if p_company_id is null then
    raise exception 'Company ID is required.';
  end if;

  if p_transaction_id is null then
    raise exception 'Transaction ID is required.';
  end if;

  v_clean_reason := nullif(btrim(coalesce(p_void_reason, '')), '');

  if v_clean_reason is null then
    raise exception 'Void reason is required.';
  end if;

  if length(v_clean_reason) < 3 then
    raise exception 'Void reason must be at least 3 characters.';
  end if;

  if length(v_clean_reason) > 500 then
    raise exception 'Void reason cannot be longer than 500 characters.';
  end if;


  -- ==========================================================
  -- 2. Resolve trusted backend actor identity
  -- ==========================================================

  v_actor_profile_id := private.current_profile_id();

  if v_actor_profile_id is null then
    raise exception 'Current profile was not found.';
  end if;

  select
    p.full_name,
    p.email
  into
    v_actor_name,
    v_actor_email
  from public.profiles p
  where p.id = v_actor_profile_id
  limit 1;

  if not found then
    raise exception 'Current profile record was not found.';
  end if;


  -- ==========================================================
  -- 3. Role check
  -- ==========================================================
  --
  -- Business decision:
  -- warehouse_user is intentionally NOT allowed to void transactions.

  if not private.has_company_role(
    p_company_id,
    array[
      'owner',
      'admin',
      'warehouse_manager'
    ]::public.company_member_role[]
  ) then
    raise exception 'You do not have permission to void transactions.';
  end if;


  -- ==========================================================
  -- 4. Company-level lock
  -- ==========================================================
  --
  -- Use the same lock family as transaction creation to avoid race conditions
  -- between creating and voiding movements in the same company.

  perform pg_catalog.pg_advisory_xact_lock(
    821027,
    pg_catalog.hashtext(p_company_id::text)
  );


  -- ==========================================================
  -- 5. Load transaction and lock it
  -- ==========================================================

  select
    t.id,
    t.company_id,
    t.transaction_code,
    t.transaction_type,
    t.worker_id,
    t.worker_hr_code_snapshot,
    t.worker_name_snapshot,
    t.tool_id,
    t.tool_code_snapshot,
    t.tool_name_snapshot,
    t.quantity,
    t.approval_required,
    t.approval_status,
    t.settlement_status,
    t.is_voided,
    t.voided_at,
    t.void_reason,
    t.created_at
  into v_transaction
  from public.transactions t
  where t.id = p_transaction_id
    and t.company_id = p_company_id
  for update;

  if not found then
    raise exception 'Transaction was not found.';
  end if;

  if coalesce(v_transaction.is_voided, false) = true then
    raise exception 'This transaction is already voided.';
  end if;


  -- ==========================================================
  -- 6. Calculate transaction effect on current custody balance
  -- ==========================================================
  --
  -- issue: increases balance
  -- return: decreases balance
  -- lost/damaged: decreases balance only after approved + settled
  -- pending/rejected lost/damaged: no custody balance effect yet

  v_transaction_effect :=
    case
      when v_transaction.transaction_type::text = 'issue' then
        v_transaction.quantity

      when v_transaction.transaction_type::text = 'return' then
        -v_transaction.quantity

      when v_transaction.transaction_type::text in ('lost', 'damaged')
        and v_transaction.approval_status::text = 'approved'
        and v_transaction.settlement_status::text = 'settled' then
        -v_transaction.quantity

      else
        0
    end;

  select public.get_worker_tool_balance(
    p_company_id,
    v_transaction.worker_id,
    v_transaction.tool_id
  )
  into v_current_balance;

  v_balance_after_void := v_current_balance - v_transaction_effect;


  -- ==========================================================
  -- 7. Protect custody balance integrity
  -- ==========================================================
  --
  -- Example:
  -- If an issue transaction of 5 pcs was followed by a return of 3 pcs,
  -- current balance is 2.
  -- Voiding the original issue would make balance -3, so it must be blocked.

  if v_balance_after_void < 0 then
    raise exception
      'This transaction cannot be voided because it would make custody balance negative. Current balance: %, transaction effect: %, balance after void: %',
      v_current_balance,
      v_transaction_effect,
      v_balance_after_void;
  end if;


  -- ==========================================================
  -- 8. Mark transaction as voided
  -- ==========================================================

  update public.transactions
  set
    is_voided = true,
    voided_at = now(),
    voided_by_profile_id = v_actor_profile_id,
    voided_by_name_snapshot = v_actor_name,
    voided_by_email_snapshot = v_actor_email,
    void_reason = v_clean_reason,

    updated_by_profile_id = v_actor_profile_id,
    updated_by_name_snapshot = v_actor_name,
    updated_by_email_snapshot = v_actor_email,
    updated_at = now()
  where id = p_transaction_id
    and company_id = p_company_id
    and is_voided = false;


  -- ==========================================================
  -- 9. Audit log
  -- ==========================================================

  perform private.write_audit_log(
    p_company_id => p_company_id,
    p_action => 'transaction_voided',
    p_entity_type => 'transaction',
    p_entity_id => p_transaction_id,
    p_entity_label_snapshot => v_transaction.transaction_code,
    p_old_data => jsonb_build_object(
      'is_voided', false,
      'transaction_code', v_transaction.transaction_code,
      'transaction_type', v_transaction.transaction_type::text,
      'worker_id', v_transaction.worker_id,
      'worker_hr_code_snapshot', v_transaction.worker_hr_code_snapshot,
      'worker_name_snapshot', v_transaction.worker_name_snapshot,
      'tool_id', v_transaction.tool_id,
      'tool_code_snapshot', v_transaction.tool_code_snapshot,
      'tool_name_snapshot', v_transaction.tool_name_snapshot,
      'quantity', v_transaction.quantity,
      'approval_required', v_transaction.approval_required,
      'approval_status', v_transaction.approval_status::text,
      'settlement_status', v_transaction.settlement_status::text,
      'balance_before_void', v_current_balance
    ),
    p_new_data => jsonb_build_object(
      'is_voided', true,
      'voided_at', now(),
      'voided_by_profile_id', v_actor_profile_id,
      'voided_by_name_snapshot', v_actor_name,
      'voided_by_email_snapshot', v_actor_email,
      'void_reason', v_clean_reason,
      'transaction_effect_removed', v_transaction_effect,
      'balance_after_void', v_balance_after_void
    ),
    p_metadata => jsonb_build_object(
      'rpc', 'void_transaction',
      'void_type', 'direct_manager_void',
      'allowed_roles', jsonb_build_array(
        'owner',
        'admin',
        'warehouse_manager'
      ),
      'warehouse_user_allowed', false
    )
  );

  return p_transaction_id;
end;
$function$;

revoke all
on function public.void_transaction(uuid, uuid, text)
from public;

revoke all
on function public.void_transaction(uuid, uuid, text)
from anon;

grant execute
on function public.void_transaction(uuid, uuid, text)
to authenticated;


-- ============================================================
-- 6. Verification queries
-- ============================================================

-- 6.1 Confirm new columns exist
select
  column_name,
  data_type,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'public'
  and table_name = 'transactions'
  and column_name in (
    'is_voided',
    'voided_at',
    'voided_by_profile_id',
    'voided_by_name_snapshot',
    'voided_by_email_snapshot',
    'void_reason'
  )
order by column_name;


-- 6.2 Confirm transaction table remains client-safe
select
  grantee,
  table_schema,
  table_name,
  privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name = 'transactions'
  and grantee in ('anon', 'authenticated', 'PUBLIC')
order by grantee, privilege_type;


-- 6.3 Confirm void RPC and balance helper security
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  p.prosecdef as is_security_definer,
  p.proconfig as function_config,
  has_function_privilege('anon', p.oid, 'execute') as anon_can_execute,
  has_function_privilege('authenticated', p.oid, 'execute') as authenticated_can_execute
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'void_transaction',
    'get_worker_tool_balance'
  )
order by p.proname;


-- 6.4 Confirm get_worker_tool_balance ignores voided transactions
select
  p.proname as function_name,
  position('is_voided' in pg_get_functiondef(p.oid)) > 0 as includes_is_voided_filter
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'get_worker_tool_balance';


-- 6.5 Confirm void_transaction writes audit log
select
  p.proname as function_name,
  position('private.write_audit_log' in pg_get_functiondef(p.oid)) > 0 as includes_write_audit_log,
  position('transaction_voided' in pg_get_functiondef(p.oid)) > 0 as includes_transaction_voided_action
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'void_transaction';

commit;