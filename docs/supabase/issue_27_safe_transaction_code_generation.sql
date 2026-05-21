begin;

create or replace function public.create_custody_transaction(
  p_company_id uuid,
  p_worker_id uuid,
  p_tool_id uuid,
  p_transaction_type public.transaction_kind,
  p_quantity numeric,
  p_proof_image_path text default null::text,
  p_note text default null::text,
  p_defer_proof_image_upload boolean default false
)
returns table(transaction_id uuid, transaction_code text)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_profile_id uuid;
  v_actor_name text;
  v_actor_email text;

  v_worker_hr_code text;
  v_worker_name text;
  v_worker_department text;
  v_worker_job_title text;

  v_tool_code text;
  v_tool_name text;
  v_tool_unit text;
  v_tool_category text;

  v_current_balance numeric(12, 2);
  v_transaction_id uuid;
  v_transaction_code text;
  v_next_transaction_number integer;

  v_approval_required boolean;
  v_approval_status public.approval_status;

  v_clean_proof_image_path text;
  v_clean_note text;

  v_has_proof_image boolean;
  v_defer_proof_image_upload boolean;
begin
  -- =====================================================
  -- 1. Security check
  -- =====================================================

  v_profile_id := private.current_profile_id();

  if v_profile_id is null then
    raise exception 'No profile found for current user.';
  end if;

  select
    p.full_name,
    p.email
  into
    v_actor_name,
    v_actor_email
  from public.profiles p
  where p.id = v_profile_id
  limit 1;

  if not found then
    raise exception 'Current profile record was not found.';
  end if;

  -- =====================================================
  -- 2. Basic validation
  -- =====================================================

  if p_company_id is null then
    raise exception 'Company ID is required.';
  end if;

  if p_worker_id is null then
    raise exception 'Worker ID is required.';
  end if;

  if p_tool_id is null then
    raise exception 'Tool ID is required.';
  end if;

  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than zero.';
  end if;

  if p_transaction_type is null then
    raise exception 'Transaction type is required.';
  end if;

  if not private.has_company_role(
    p_company_id,
    array[
      'owner',
      'admin',
      'warehouse_manager',
      'warehouse_user'
    ]::public.company_member_role[]
  ) then
    raise exception 'Access denied. You do not have permission to create transactions for this company.';
  end if;

  -- =====================================================
  -- 3. Company-level transaction lock
  -- =====================================================
  -- This prevents two devices from generating the same transaction code
  -- at the same time for the same company.

  perform pg_catalog.pg_advisory_xact_lock(
    821027,
    pg_catalog.hashtext(p_company_id::text)
  );

  v_clean_proof_image_path := nullif(btrim(coalesce(p_proof_image_path, '')), '');
  v_clean_note := nullif(btrim(coalesce(p_note, '')), '');

  v_has_proof_image := v_clean_proof_image_path is not null;
  v_defer_proof_image_upload := coalesce(p_defer_proof_image_upload, false);

  if p_transaction_type in ('issue', 'damaged') then
    if not v_has_proof_image and not v_defer_proof_image_upload then
      raise exception 'Proof image is required for issue and damaged transactions.';
    end if;
  end if;

  if p_transaction_type in ('lost', 'damaged') then
    if v_clean_note is null then
      raise exception 'Note is required for lost and damaged transactions.';
    end if;
  end if;

  -- File path validation:
  -- Source file can be local temporarily,
  -- but database reference must always be cloud storage path.
  if v_has_proof_image then
    if v_clean_proof_image_path ~* '^(file:|[A-Z]:\\|/storage/|/Users/)' then
      raise exception 'Local file paths are not allowed. Upload the file to Supabase Storage first.';
    end if;

    if v_clean_proof_image_path not like p_company_id::text || '/%' then
      raise exception 'Proof image path must start with company_id.';
    end if;
  end if;

  -- =====================================================
  -- 4. Load worker snapshot
  -- =====================================================

  select
    w.hr_code,
    w.full_name,
    d.name,
    jt.name
  into
    v_worker_hr_code,
    v_worker_name,
    v_worker_department,
    v_worker_job_title
  from public.workers w
  join public.departments d
    on d.id = w.department_id
   and d.company_id = w.company_id
  join public.job_titles jt
    on jt.id = w.job_title_id
   and jt.company_id = w.company_id
  where w.id = p_worker_id
    and w.company_id = p_company_id
  limit 1;

  if v_worker_name is null then
    raise exception 'Worker not found in this company.';
  end if;

  -- =====================================================
  -- 5. Load tool snapshot
  -- =====================================================

  select
    t.tool_code,
    t.tool_name,
    tu.name,
    tc.name
  into
    v_tool_code,
    v_tool_name,
    v_tool_unit,
    v_tool_category
  from public.tools t
  join public.tool_units tu
    on tu.id = t.unit_id
   and tu.company_id = t.company_id
  join public.tool_categories tc
    on tc.id = t.category_id
   and tc.company_id = t.company_id
  where t.id = p_tool_id
    and t.company_id = p_company_id
  limit 1;

  if v_tool_name is null then
    raise exception 'Tool not found in this company.';
  end if;

  -- =====================================================
  -- 6. Balance validation for closing transactions
  -- =====================================================

  if p_transaction_type in ('return', 'lost', 'damaged') then
    select public.get_worker_tool_balance(
      p_company_id,
      p_worker_id,
      p_tool_id
    )
    into v_current_balance;

    if p_quantity > v_current_balance then
      raise exception
        'Quantity exceeds current open custody balance. Current balance: %, requested: %',
        v_current_balance,
        p_quantity;
    end if;
  end if;

  -- =====================================================
  -- 7. Approval logic
  -- =====================================================

  if p_transaction_type in ('issue', 'return') then
    v_approval_required := false;
    v_approval_status := 'not_required';
  else
    v_approval_required := true;
    v_approval_status := 'pending';
  end if;

  -- =====================================================
  -- 8. Generate transaction code safely
  -- =====================================================
  -- Do not use count(*) + 1.
  -- It breaks if a previous transaction was deleted/rolled back
  -- or if two devices create transactions at the same time.

  select
    coalesce(
      max(
        (
          pg_catalog.regexp_match(
            t.transaction_code,
            '^TRX-([0-9]+)$'
          )
        )[1]::integer
      ),
      0
    ) + 1
  into v_next_transaction_number
  from public.transactions t
  where t.company_id = p_company_id
    and t.transaction_code ~ '^TRX-[0-9]+$';

  v_transaction_code :=
    'TRX-' || lpad(v_next_transaction_number::text, 5, '0');

  -- =====================================================
  -- 9. Insert transaction
  -- =====================================================

  insert into public.transactions (
    company_id,
    transaction_code,
    transaction_type,

    worker_id,
    worker_hr_code_snapshot,
    worker_name_snapshot,
    worker_department_snapshot,
    worker_job_title_snapshot,

    tool_id,
    tool_code_snapshot,
    tool_name_snapshot,
    tool_unit_snapshot,
    tool_category_snapshot,

    quantity,
    proof_image_path,
    note,

    approval_required,
    approval_status,

    created_by_profile_id,
    created_by_name_snapshot,
    created_by_email_snapshot,

    proof_image_uploaded_by_profile_id,
    proof_image_uploaded_by_name_snapshot,
    proof_image_uploaded_by_email_snapshot,
    proof_image_uploaded_at,

    updated_by_profile_id,
    updated_by_name_snapshot,
    updated_by_email_snapshot
  )
  values (
    p_company_id,
    v_transaction_code,
    p_transaction_type,

    p_worker_id,
    v_worker_hr_code,
    v_worker_name,
    v_worker_department,
    v_worker_job_title,

    p_tool_id,
    v_tool_code,
    v_tool_name,
    v_tool_unit,
    v_tool_category,

    p_quantity,
    v_clean_proof_image_path,
    v_clean_note,

    v_approval_required,
    v_approval_status,

    v_profile_id,
    v_actor_name,
    v_actor_email,

    case when v_has_proof_image then v_profile_id else null end,
    case when v_has_proof_image then v_actor_name else null end,
    case when v_has_proof_image then v_actor_email else null end,
    case when v_has_proof_image then now() else null end,

    v_profile_id,
    v_actor_name,
    v_actor_email
  )
  returning id, transactions.transaction_code
  into v_transaction_id, v_transaction_code;

  -- =====================================================
  -- 10. Audit log
  -- =====================================================

  perform private.write_audit_log(
    p_company_id => p_company_id,
    p_action => 'transaction_created',
    p_entity_type => 'transaction',
    p_entity_id => v_transaction_id,
    p_entity_label_snapshot => v_transaction_code,
    p_old_data => null,
    p_new_data => jsonb_build_object(
      'transaction_code', v_transaction_code,
      'transaction_type', p_transaction_type::text,
      'worker_id', p_worker_id,
      'worker_hr_code_snapshot', v_worker_hr_code,
      'worker_name_snapshot', v_worker_name,
      'tool_id', p_tool_id,
      'tool_code_snapshot', v_tool_code,
      'tool_name_snapshot', v_tool_name,
      'quantity', p_quantity,
      'approval_required', v_approval_required,
      'approval_status', v_approval_status::text,
      'proof_image_attached', v_has_proof_image,
      'proof_image_deferred', v_defer_proof_image_upload,
      'proof_image_path', v_clean_proof_image_path,
      'note', v_clean_note
    ),
    p_metadata => jsonb_build_object(
      'created_by_profile_id', v_profile_id,
      'created_by_name_snapshot', v_actor_name,
      'created_by_email_snapshot', v_actor_email,
      'proof_image_uploaded_by_profile_id',
        case when v_has_proof_image then v_profile_id else null end,
      'proof_image_uploaded_at',
        case when v_has_proof_image then now() else null end,
      'proof_image_deferred',
        v_defer_proof_image_upload
    )
  );

  -- =====================================================
  -- 11. Return result

  
  -- =====================================================

  return query
  select
    v_transaction_id,
    v_transaction_code;
end;
$function$;

revoke all
on function public.create_custody_transaction(
  uuid,
  uuid,
  uuid,
  public.transaction_kind,
  numeric,
  text,
  text,
  boolean
)
from public;

grant execute
on function public.create_custody_transaction(
  uuid,
  uuid,
  uuid,
  public.transaction_kind,
  numeric,
  text,
  text,
  boolean
)
to authenticated;

commit;