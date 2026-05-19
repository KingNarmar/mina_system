-- =====================================================
-- Issue #20 — Handle orphaned storage files after failed uploads
-- =====================================================
--
-- Goal:
-- - Allow safe cleanup of newly uploaded Supabase Storage files when
--   the related database/RPC operation fails.
-- - Prevent incomplete transaction records from remaining when:
--     1. create_custody_transaction succeeds,
--     2. proof image upload succeeds,
--     3. upload_transaction_proof_image fails.
--
-- Covered flows:
-- - transaction-proofs bucket cleanup
-- - transaction-approval-documents bucket cleanup
-- - failed transaction proof upload rollback
--
-- Notes:
-- - This script does not clean old test data.
-- - This script does not modify PROJECT_ROADMAP.md.
-- - Company logo cleanup is already covered by existing company-assets DELETE policy.
-- - DELETE permissions mirror the matching upload permissions:
--     transaction-proofs:
--       owner, admin, warehouse_manager, warehouse_user
--     transaction-approval-documents:
--       owner, admin, warehouse_manager
--
-- Related GitHub Issue:
-- #20 — Handle orphaned storage files after failed uploads
-- =====================================================

begin;

-- =====================================================
-- 1. Allow safe cleanup of orphaned transaction proof files
-- =====================================================

drop policy if exists
  "Owner admin manager user can delete transaction proofs"
on storage.objects;

create policy
  "Owner admin manager user can delete transaction proofs"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'transaction-proofs'
  and private.has_company_role(
    private.company_id_from_storage_path(name),
    array[
      'owner'::public.company_member_role,
      'admin'::public.company_member_role,
      'warehouse_manager'::public.company_member_role,
      'warehouse_user'::public.company_member_role
    ]
  )
);

-- =====================================================
-- 2. Allow safe cleanup of orphaned approval document files
-- =====================================================

drop policy if exists
  "Owner admin manager can delete transaction approval documents"
on storage.objects;

create policy
  "Owner admin manager can delete transaction approval documents"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'transaction-approval-documents'
  and private.has_company_role(
    private.company_id_from_storage_path(name),
    array[
      'owner'::public.company_member_role,
      'admin'::public.company_member_role,
      'warehouse_manager'::public.company_member_role
    ]
  )
);

-- =====================================================
-- 3. Roll back incomplete transactions after failed proof linking
-- =====================================================

create or replace function public.rollback_failed_transaction_proof_upload(
  p_company_id uuid,
  p_transaction_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = public, private
as $$
declare
  v_actor_profile_id uuid;
  v_actor_full_name text;
  v_actor_email text;
  v_transaction record;
begin
  if auth.uid() is null then
    raise exception 'Authentication required.';
  end if;

  if p_company_id is null then
    raise exception 'Company ID is required.';
  end if;

  if p_transaction_id is null then
    raise exception 'Transaction ID is required.';
  end if;

  v_actor_profile_id := private.current_profile_id();

  if v_actor_profile_id is null then
    raise exception 'Current profile was not found.';
  end if;

  if not private.has_company_role(
    p_company_id,
    array[
      'owner'::public.company_member_role,
      'admin'::public.company_member_role,
      'warehouse_manager'::public.company_member_role,
      'warehouse_user'::public.company_member_role
    ]
  ) then
    raise exception 'You do not have permission to roll back failed transaction uploads.';
  end if;

  select
    t.id,
    t.company_id,
    t.transaction_code,
    t.transaction_type,
    t.worker_id,
    t.worker_name_snapshot,
    t.tool_id,
    t.tool_name_snapshot,
    t.quantity,
    t.proof_image_path,
    t.approval_document_path,
    t.approval_status,
    t.settlement_status,
    t.created_by_profile_id,
    t.created_at,
    t.updated_at
  into v_transaction
  from public.transactions t
  where t.id = p_transaction_id
    and t.company_id = p_company_id
  for update;

  if not found then
    return false;
  end if;

  -- Safety guard 1:
  -- Only transactions that require proof image can be rolled back here.
  if v_transaction.transaction_type::text not in ('issue', 'damaged') then
    raise exception 'Only issue or damaged transactions can be rolled back by this function.';
  end if;

  -- Safety guard 2:
  -- Never delete a transaction that already has a linked proof image.
  if nullif(btrim(coalesce(v_transaction.proof_image_path, '')), '') is not null then
    raise exception 'Transaction already has a proof image and cannot be rolled back.';
  end if;

  -- Safety guard 3:
  -- Never delete a transaction that already has an approval document.
  if nullif(btrim(coalesce(v_transaction.approval_document_path, '')), '') is not null then
    raise exception 'Transaction already has an approval document and cannot be rolled back.';
  end if;

  -- Safety guard 4:
  -- Only the same user who created the failed transaction can roll it back.
  if v_transaction.created_by_profile_id is distinct from v_actor_profile_id then
    raise exception 'Only the creator can roll back this failed transaction.';
  end if;

  -- Safety guard 5:
  -- Rollback window is intentionally short to avoid deleting old valid records.
  if v_transaction.created_at < now() - interval '10 minutes' then
    raise exception 'Rollback window expired for this transaction.';
  end if;

  -- Safety guard 6:
  -- Do not roll back records that already moved into settlement.
  if v_transaction.settlement_status::text not in ('not_required', 'pending') then
    raise exception 'Transaction settlement state is not safe for rollback.';
  end if;

  select
    p.full_name,
    p.email
  into
    v_actor_full_name,
    v_actor_email
  from public.profiles p
  where p.id = v_actor_profile_id
  limit 1;

  perform private.write_audit_log(
    p_company_id => p_company_id,
    p_action => 'transaction_rolled_back_after_failed_proof_upload',
    p_entity_type => 'transaction',
    p_entity_id => p_transaction_id,
    p_entity_label_snapshot => v_transaction.transaction_code,
    p_old_data => jsonb_build_object(
      'transaction_code', v_transaction.transaction_code,
      'transaction_type', v_transaction.transaction_type::text,
      'worker_id', v_transaction.worker_id,
      'worker_name_snapshot', v_transaction.worker_name_snapshot,
      'tool_id', v_transaction.tool_id,
      'tool_name_snapshot', v_transaction.tool_name_snapshot,
      'quantity', v_transaction.quantity,
      'proof_image_path', v_transaction.proof_image_path,
      'approval_document_path', v_transaction.approval_document_path,
      'approval_status', v_transaction.approval_status::text,
      'settlement_status', v_transaction.settlement_status::text,
      'created_by_profile_id', v_transaction.created_by_profile_id,
      'created_at', v_transaction.created_at
    ),
    p_new_data => null,
    p_metadata => jsonb_build_object(
      'rollback_reason', 'proof_image_link_rpc_failed',
      'rolled_back_by_profile_id', v_actor_profile_id,
      'rolled_back_by_name_snapshot', v_actor_full_name,
      'rolled_back_by_email_snapshot', v_actor_email
    )
  );

  delete from public.transactions
  where id = p_transaction_id
    and company_id = p_company_id;

  return true;
end;
$$;

revoke all
on function public.rollback_failed_transaction_proof_upload(uuid, uuid)
from public;

grant execute
on function public.rollback_failed_transaction_proof_upload(uuid, uuid)
to authenticated;

commit;

-- =====================================================
-- Optional verification queries
-- =====================================================
--
-- Verify DELETE policies:
--
-- select
--   policyname,
--   cmd,
--   roles,
--   qual
-- from pg_policies
-- where schemaname = 'storage'
--   and tablename = 'objects'
--   and policyname in (
--     'Owner admin manager user can delete transaction proofs',
--     'Owner admin manager can delete transaction approval documents'
--   )
-- order by policyname;
--
-- Verify rollback RPC:
--
-- select
--   routine_schema,
--   routine_name,
--   routine_type
-- from information_schema.routines
-- where routine_schema = 'public'
--   and routine_name = 'rollback_failed_transaction_proof_upload';