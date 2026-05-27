-- Issue #28 - Add digital handwritten signature workflow for reports and store signed PDFs
-- Step 28.3A - Preflight verification only
--
-- Scope:
-- Read-only verification.
-- No table creation.
-- No RPC creation.
-- No RLS policy changes.
-- No Storage policy changes.
-- No PROJECT_ROADMAP.md changes.
--
-- Goal:
-- Verify the current Supabase state before adding the signed_reports metadata table
-- and the secure RPC for signed PDF metadata creation.

-- ============================================================
-- 1) CHECK - Confirm expected helper functions exist
-- ============================================================

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
  ('private', 'current_profile_id'),
  ('private', 'is_company_member'),
  ('private', 'has_company_role'),
  ('private', 'company_id_from_storage_path'),
  ('private', 'write_audit_log')
)
order by
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 2) CHECK - Confirm required business tables exist
-- ============================================================

select
  table_schema,
  table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in (
    'companies',
    'profiles',
    'company_members',
    'workers',
    'transactions',
    'company_document_templates',
    'audit_logs',
    'signed_reports',
    'custody_acknowledgements',
    'loss_damage_reports'
  )
order by
  table_name;


-- ============================================================
-- 3) CHECK - Confirm whether signed_reports already exists
-- ============================================================

select
  c.table_schema,
  c.table_name,
  c.column_name,
  c.data_type,
  c.is_nullable,
  c.column_default
from information_schema.columns c
where c.table_schema = 'public'
  and c.table_name = 'signed_reports'
order by
  c.ordinal_position;


-- ============================================================
-- 4) CHECK - Confirm existing report template type values
-- ============================================================

select
  report_type,
  count(*) as template_count
from public.company_document_templates
group by report_type
order by report_type;


-- ============================================================
-- 5) CHECK - Confirm custody-documents bucket state
-- ============================================================

select
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at,
  updated_at
from storage.buckets
where id = 'custody-documents'
   or name = 'custody-documents';


-- ============================================================
-- 6) CHECK - Count objects currently inside custody-documents
-- ============================================================

select
  bucket_id,
  count(*) as object_count,
  min(created_at) as first_object_created_at,
  max(created_at) as last_object_created_at,
  min(updated_at) as first_object_updated_at,
  max(updated_at) as last_object_updated_at
from storage.objects
where bucket_id = 'custody-documents'
group by bucket_id;


-- ============================================================
-- 7) CHECK - List custody-documents storage policies
-- ============================================================

select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and (
    qual::text ilike '%custody-documents%'
    or with_check::text ilike '%custody-documents%'
    or policyname ilike '%custody%'
  )
order by
  policyname,
  cmd;


-- ============================================================
-- 8) CHECK - Confirm transaction/report source columns needed for metadata
-- ============================================================

select
  c.table_name,
  c.column_name,
  c.data_type,
  c.is_nullable
from information_schema.columns c
where c.table_schema = 'public'
  and c.table_name in ('transactions', 'workers', 'profiles', 'companies')
  and c.column_name in (
    'id',
    'company_id',
    'transaction_code',
    'worker_id',
    'worker_hr_code_snapshot',
    'worker_name_snapshot',
    'hr_code',
    'full_name',
    'email',
    'created_at'
  )
order by
  c.table_name,
  c.ordinal_position;


-- ============================================================
-- 9) CHECK - Confirm existing signed PDF references in old/future tables
-- ============================================================

select
  'custody_acknowledgements' as table_name,
  count(*) filter (
    where signed_pdf_path is not null
      and trim(signed_pdf_path) <> ''
  ) as non_empty_signed_pdf_path_count
from public.custody_acknowledgements

union all

select
  'loss_damage_reports' as table_name,
  count(*) filter (
    where signed_pdf_path is not null
      and trim(signed_pdf_path) <> ''
  ) as non_empty_signed_pdf_path_count
from public.loss_damage_reports;


-- ============================================================
-- 10) CHECK - Inspect public RLS state for signed-report-related tables
-- ============================================================

select
  n.nspname as schemaname,
  c.relname as tablename,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls_enabled
from pg_class c
join pg_namespace n
  on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind in ('r', 'p')
  and c.relname in (
    'transactions',
    'workers',
    'company_document_templates',
    'audit_logs',
    'signed_reports',
    'custody_acknowledgements',
    'loss_damage_reports'
  )
order by
  c.relname;
-- ============================================================
-- 11) CHECK - List policies for signed-report-related public tables
-- ============================================================

select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname = 'public'
  and tablename in (
    'transactions',
    'workers',
    'company_document_templates',
    'audit_logs',
    'signed_reports',
    'custody_acknowledgements',
    'loss_damage_reports'
  )
order by
  tablename,
  policyname,
  cmd;


-- ============================================================
-- 12) CHECK - Confirm direct grants for signed-report-related tables
-- ============================================================

select
  grantee,
  table_schema,
  table_name,
  privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name in (
    'transactions',
    'workers',
    'company_document_templates',
    'audit_logs',
    'signed_reports',
    'custody_acknowledgements',
    'loss_damage_reports'
  )
  and grantee in ('anon', 'authenticated', 'public')
order by
  table_name,
  grantee,
  privilege_type;


-- ============================================================
-- 13) Expected notes after running this read-only step
-- ============================================================

-- Expected / desired findings:
--
-- 1. signed_reports probably does not exist yet.
-- 2. custody-documents should exist.
-- 3. custody-documents should be private.
-- 4. custody-documents should allow application/pdf only.
-- 5. custody-documents should have a 10MB file size limit.
-- 6. Storage policies should already allow company-isolated read/upload.
-- 7. old signed_pdf_path references may exist in:
--    - custody_acknowledgements
--    - loss_damage_reports
--    but they should not be treated as the new signed_reports metadata design.
--
-- Next step after this:
-- Step 28.3B - Add signed_reports table, indexes, RLS, and secure RPC.
-- ============================================================
-- Issue #28 - Add digital handwritten signature workflow for reports and store signed PDFs
-- Step 28.3B - Add signed_reports metadata table, RLS, RPC, and orphan cleanup policy
-- ============================================================
--
-- Scope:
-- - Create signed_reports metadata table.
-- - Add indexes and constraints.
-- - Enable RLS.
-- - Allow company members to read signed report metadata.
-- - Keep signed report metadata writes behind a secure RPC.
-- - Add secure RPC to create signed report metadata after PDF upload.
-- - Add Storage DELETE policy for orphan cleanup only.
--
-- Important:
-- - This script does NOT modify PROJECT_ROADMAP.md.
-- - This script does NOT overwrite existing signed PDFs.
-- - PDF files remain in Supabase Storage bucket: custody-documents.
-- - Database stores metadata only.

begin;

-- ============================================================
-- 1) Create signed_reports metadata table
-- ============================================================

create table if not exists public.signed_reports (
  id uuid primary key default gen_random_uuid(),

  company_id uuid not null
    references public.companies(id)
    on delete restrict,

  transaction_id uuid null
    references public.transactions(id)
    on delete restrict,

  worker_id uuid null
    references public.workers(id)
    on delete restrict,

  report_type text not null,
  report_number text not null,

  storage_bucket text not null default 'custody-documents',
  file_path text not null,
  file_name text not null,
  file_size bigint not null,
  file_hash text not null,

  signed_by_name text not null,
  signed_at timestamptz not null,

  signature_input_method text null,
  signature_platform text null,

  worker_name_snapshot text null,
  worker_hr_code_snapshot text null,
  transaction_code_snapshot text null,

  filters_snapshot jsonb not null default '{}'::jsonb,
  transaction_ids_snapshot jsonb not null default '[]'::jsonb,

  created_by_profile_id uuid not null
    references public.profiles(id)
    on delete restrict,

  created_by_name_snapshot text null,
  created_by_email_snapshot text null,

  created_at timestamptz not null default now(),

  constraint signed_reports_report_type_check check (
    report_type in (
      'worker_custody_report',
      'tool_history_report',
      'transactions_report',
      'lost_damaged_report',
      'loss_damage_report',
      'tool_summary_report'
    )
  ),

  constraint signed_reports_storage_bucket_check check (
    storage_bucket = 'custody-documents'
  ),

  constraint signed_reports_file_size_check check (
    file_size > 0
    and file_size <= 10485760
  ),

  constraint signed_reports_file_hash_sha256_check check (
    file_hash ~ '^[A-Fa-f0-9]{64}$'
  ),

  constraint signed_reports_file_path_pdf_check check (
    lower(file_path) like '%.pdf'
  ),

  constraint signed_reports_file_name_pdf_check check (
    lower(file_name) like '%.pdf'
  ),

  constraint signed_reports_signed_by_name_check check (
    length(btrim(signed_by_name)) > 0
  ),

  constraint signed_reports_report_number_check check (
    length(btrim(report_number)) > 0
  )
);


-- ============================================================
-- 2) Indexes / uniqueness
-- ============================================================

create unique index if not exists signed_reports_company_report_number_unique
on public.signed_reports (company_id, report_number);

create unique index if not exists signed_reports_storage_path_unique
on public.signed_reports (storage_bucket, file_path);

create index if not exists signed_reports_company_signed_at_idx
on public.signed_reports (company_id, signed_at desc);

create index if not exists signed_reports_company_report_type_idx
on public.signed_reports (company_id, report_type);

create index if not exists signed_reports_company_worker_idx
on public.signed_reports (company_id, worker_id);

create index if not exists signed_reports_company_transaction_idx
on public.signed_reports (company_id, transaction_id);

create index if not exists signed_reports_company_worker_hr_code_idx
on public.signed_reports (company_id, worker_hr_code_snapshot);

create index if not exists signed_reports_company_transaction_code_idx
on public.signed_reports (company_id, transaction_code_snapshot);

create index if not exists signed_reports_company_created_by_idx
on public.signed_reports (company_id, created_by_profile_id);


-- ============================================================
-- 3) Enable RLS
-- ============================================================

alter table public.signed_reports enable row level security;


-- ============================================================
-- 4) Grants
-- ============================================================

revoke all
on table public.signed_reports
from anon, authenticated, public;

grant select
on table public.signed_reports
to authenticated;


-- ============================================================
-- 5) RLS policies
-- ============================================================

drop policy if exists "Members can read signed reports"
on public.signed_reports;

create policy "Members can read signed reports"
on public.signed_reports
for select
to authenticated
using (
  private.is_company_member(company_id)
);

-- No direct INSERT / UPDATE / DELETE policies are created.
-- Signed report metadata must be created through public.create_signed_report_metadata().
-- Signed report rows are intended to be permanent evidence records.


-- ============================================================
-- 6) Secure RPC - create signed report metadata
-- ============================================================

create or replace function public.create_signed_report_metadata(
  p_company_id uuid,
  p_report_type text,
  p_report_number text,
  p_storage_bucket text,
  p_file_path text,
  p_file_name text,
  p_file_size bigint,
  p_file_hash text,
  p_signed_by_name text,
  p_signed_at timestamptz,
  p_worker_id uuid default null,
  p_transaction_id uuid default null,
  p_filters_snapshot jsonb default '{}'::jsonb,
  p_transaction_ids_snapshot jsonb default '[]'::jsonb,
  p_signature_input_method text default null,
  p_signature_platform text default null
)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_profile_id uuid;
  v_actor_name text;
  v_actor_email text;

  v_report_id uuid;

  v_clean_report_type text;
  v_clean_report_number text;
  v_clean_storage_bucket text;
  v_clean_file_path text;
  v_clean_file_name text;
  v_clean_file_hash text;
  v_clean_signed_by_name text;
  v_clean_signature_input_method text;
  v_clean_signature_platform text;

  v_worker_id uuid;
  v_worker_name text;
  v_worker_hr_code text;

  v_transaction_id uuid;
  v_transaction_code text;
  v_transaction_worker_id uuid;
  v_transaction_worker_name text;
  v_transaction_worker_hr_code text;

  v_storage_object_exists boolean;
begin
  -- ============================================================
  -- 1. Current authenticated actor
  -- ============================================================

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


  -- ============================================================
  -- 2. Basic validation
  -- ============================================================

  if p_company_id is null then
    raise exception 'Company ID is required.';
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
    raise exception 'Access denied. You do not have permission to save signed reports for this company.';
  end if;

  v_clean_report_type := nullif(btrim(coalesce(p_report_type, '')), '');
  v_clean_report_number := nullif(btrim(coalesce(p_report_number, '')), '');
  v_clean_storage_bucket := nullif(btrim(coalesce(p_storage_bucket, '')), '');
  v_clean_file_path := nullif(btrim(coalesce(p_file_path, '')), '');
  v_clean_file_name := nullif(btrim(coalesce(p_file_name, '')), '');
  v_clean_file_hash := nullif(btrim(coalesce(p_file_hash, '')), '');
  v_clean_signed_by_name := nullif(btrim(coalesce(p_signed_by_name, '')), '');
  v_clean_signature_input_method := nullif(btrim(coalesce(p_signature_input_method, '')), '');
  v_clean_signature_platform := nullif(btrim(coalesce(p_signature_platform, '')), '');

  if v_clean_report_type is null then
    raise exception 'Report type is required.';
  end if;

  if v_clean_report_type not in (
    'worker_custody_report',
    'tool_history_report',
    'transactions_report',
    'lost_damaged_report',
    'loss_damage_report',
    'tool_summary_report'
  ) then
    raise exception 'Invalid report type: %', v_clean_report_type;
  end if;

  if v_clean_report_number is null then
    raise exception 'Report number is required.';
  end if;

  if v_clean_storage_bucket is distinct from 'custody-documents' then
    raise exception 'Signed report PDFs must be stored in custody-documents bucket.';
  end if;

  if v_clean_file_path is null then
    raise exception 'File path is required.';
  end if;

  if v_clean_file_name is null then
    raise exception 'File name is required.';
  end if;

  if p_file_size is null or p_file_size <= 0 then
    raise exception 'File size must be greater than zero.';
  end if;

  if p_file_size > 10485760 then
    raise exception 'Signed PDF exceeds the 10MB custody-documents limit.';
  end if;

  if v_clean_file_hash is null then
    raise exception 'File hash is required.';
  end if;

  if v_clean_file_hash !~ '^[A-Fa-f0-9]{64}$' then
    raise exception 'File hash must be a SHA-256 hex string.';
  end if;

  if v_clean_signed_by_name is null then
    raise exception 'Signed by name is required.';
  end if;

  if p_signed_at is null then
    raise exception 'Signed at timestamp is required.';
  end if;

  if lower(v_clean_file_path) not like '%.pdf' then
    raise exception 'Signed report file path must point to a PDF file.';
  end if;

  if lower(v_clean_file_name) not like '%.pdf' then
    raise exception 'Signed report file name must be a PDF file.';
  end if;

  if v_clean_file_path !~ ('^' || p_company_id::text || '/') then
    raise exception 'Signed report file path must start with company_id.';
  end if;

  if v_clean_file_path ~* '(^file:|^[A-Z]:\\|^/storage/|^/Users/|\\.\\.)' then
    raise exception 'Invalid signed report file path.';
  end if;

  if p_filters_snapshot is null or jsonb_typeof(p_filters_snapshot) <> 'object' then
    raise exception 'Filters snapshot must be a JSON object.';
  end if;

  if p_transaction_ids_snapshot is null or jsonb_typeof(p_transaction_ids_snapshot) <> 'array' then
    raise exception 'Transaction IDs snapshot must be a JSON array.';
  end if;


  -- ============================================================
  -- 3. Validate Storage object exists
  -- ============================================================

  select exists (
    select 1
    from storage.objects o
    where o.bucket_id = v_clean_storage_bucket
      and o.name = v_clean_file_path
  )
  into v_storage_object_exists;

  if not v_storage_object_exists then
    raise exception 'Signed PDF file was not found in Supabase Storage.';
  end if;


  -- ============================================================
  -- 4. Optional transaction validation and snapshot
  -- ============================================================

  if p_transaction_id is not null then
    select
      t.id,
      t.transaction_code,
      t.worker_id,
      t.worker_name_snapshot,
      t.worker_hr_code_snapshot
    into
      v_transaction_id,
      v_transaction_code,
      v_transaction_worker_id,
      v_transaction_worker_name,
      v_transaction_worker_hr_code
    from public.transactions t
    where t.id = p_transaction_id
      and t.company_id = p_company_id
    limit 1;

    if v_transaction_id is null then
      raise exception 'Transaction was not found in this company.';
    end if;
  end if;


  -- ============================================================
  -- 5. Optional worker validation and snapshot
  -- ============================================================

  if p_worker_id is not null then
    select
      w.id,
      w.full_name,
      w.hr_code
    into
      v_worker_id,
      v_worker_name,
      v_worker_hr_code
    from public.workers w
    where w.id = p_worker_id
      and w.company_id = p_company_id
    limit 1;

    if v_worker_id is null then
      raise exception 'Worker was not found in this company.';
    end if;
  end if;

  if v_transaction_id is not null and v_worker_id is not null then
    if v_transaction_worker_id is distinct from v_worker_id then
      raise exception 'Worker does not match the selected transaction.';
    end if;
  end if;

  if v_worker_id is null and v_transaction_worker_id is not null then
    v_worker_id := v_transaction_worker_id;
    v_worker_name := v_transaction_worker_name;
    v_worker_hr_code := v_transaction_worker_hr_code;
  end if;


  -- ============================================================
  -- 6. Prevent duplicate metadata for same official report/path
  -- ============================================================

  if exists (
    select 1
    from public.signed_reports sr
    where sr.company_id = p_company_id
      and sr.report_number = v_clean_report_number
  ) then
    raise exception 'A signed report with this report number already exists.';
  end if;

  if exists (
    select 1
    from public.signed_reports sr
    where sr.storage_bucket = v_clean_storage_bucket
      and sr.file_path = v_clean_file_path
  ) then
    raise exception 'This signed PDF file path is already linked to a signed report.';
  end if;


  -- ============================================================
  -- 7. Insert metadata
  -- ============================================================

  insert into public.signed_reports (
    company_id,
    transaction_id,
    worker_id,
    report_type,
    report_number,
    storage_bucket,
    file_path,
    file_name,
    file_size,
    file_hash,
    signed_by_name,
    signed_at,
    signature_input_method,
    signature_platform,
    worker_name_snapshot,
    worker_hr_code_snapshot,
    transaction_code_snapshot,
    filters_snapshot,
    transaction_ids_snapshot,
    created_by_profile_id,
    created_by_name_snapshot,
    created_by_email_snapshot
  )
  values (
    p_company_id,
    v_transaction_id,
    v_worker_id,
    v_clean_report_type,
    v_clean_report_number,
    v_clean_storage_bucket,
    v_clean_file_path,
    v_clean_file_name,
    p_file_size,
    lower(v_clean_file_hash),
    v_clean_signed_by_name,
    p_signed_at,
    v_clean_signature_input_method,
    v_clean_signature_platform,
    v_worker_name,
    v_worker_hr_code,
    v_transaction_code,
    p_filters_snapshot,
    p_transaction_ids_snapshot,
    v_profile_id,
    v_actor_name,
    v_actor_email
  )
  returning id
  into v_report_id;


  -- ============================================================
  -- 8. Audit log
  -- ============================================================

  perform private.write_audit_log(
    p_company_id => p_company_id,
    p_action => 'signed_report_created',
    p_entity_type => 'signed_report',
    p_entity_id => v_report_id,
    p_entity_label_snapshot => v_clean_report_number,
    p_old_data => null,
    p_new_data => jsonb_build_object(
      'report_id', v_report_id,
      'report_type', v_clean_report_type,
      'report_number', v_clean_report_number,
      'transaction_id', v_transaction_id,
      'transaction_code_snapshot', v_transaction_code,
      'worker_id', v_worker_id,
      'worker_name_snapshot', v_worker_name,
      'worker_hr_code_snapshot', v_worker_hr_code,
      'storage_bucket', v_clean_storage_bucket,
      'file_path', v_clean_file_path,
      'file_name', v_clean_file_name,
      'file_size', p_file_size,
      'file_hash', lower(v_clean_file_hash),
      'signed_by_name', v_clean_signed_by_name,
      'signed_at', p_signed_at
    ),
    p_metadata => jsonb_build_object(
      'created_by_profile_id', v_profile_id,
      'created_by_name_snapshot', v_actor_name,
      'created_by_email_snapshot', v_actor_email,
      'signature_input_method', v_clean_signature_input_method,
      'signature_platform', v_clean_signature_platform
    )
  );

  return v_report_id;
end;
$function$;


-- ============================================================
-- 7) RPC grants
-- ============================================================

revoke all
on function public.create_signed_report_metadata(
  uuid,
  text,
  text,
  text,
  text,
  text,
  bigint,
  text,
  text,
  timestamptz,
  uuid,
  uuid,
  jsonb,
  jsonb,
  text,
  text
)
from public;

grant execute
on function public.create_signed_report_metadata(
  uuid,
  text,
  text,
  text,
  text,
  text,
  bigint,
  text,
  text,
  timestamptz,
  uuid,
  uuid,
  jsonb,
  jsonb,
  text,
  text
)
to authenticated;


-- ============================================================
-- 8) Storage DELETE policy for orphan cleanup only
-- ============================================================
--
-- Purpose:
-- Allow Flutter to remove a newly uploaded custody PDF only if metadata creation fails.
-- Once a row exists in signed_reports, the PDF is protected from deletion by this policy.

drop policy if exists "Owner admin manager user can delete orphan custody documents"
on storage.objects;

create policy "Owner admin manager user can delete orphan custody documents"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'custody-documents'
  and private.has_company_role(
    private.company_id_from_storage_path(name),
    array[
      'owner',
      'admin',
      'warehouse_manager',
      'warehouse_user'
    ]::public.company_member_role[]
  )
  and not exists (
    select 1
    from public.signed_reports sr
    where sr.storage_bucket = storage.objects.bucket_id
      and sr.file_path = storage.objects.name
  )
);

commit;


-- ============================================================
-- 9) Verification queries after Step 28.3B
-- ============================================================

-- Verify signed_reports columns
select
  c.table_schema,
  c.table_name,
  c.column_name,
  c.data_type,
  c.is_nullable,
  c.column_default
from information_schema.columns c
where c.table_schema = 'public'
  and c.table_name = 'signed_reports'
order by
  c.ordinal_position;


-- Verify signed_reports RLS
select
  n.nspname as schemaname,
  c.relname as tablename,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls_enabled
from pg_class c
join pg_namespace n
  on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relname = 'signed_reports';


-- Verify signed_reports policies
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname = 'public'
  and tablename = 'signed_reports'
order by
  policyname,
  cmd;


-- Verify signed_reports grants
select
  grantee,
  table_schema,
  table_name,
  privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name = 'signed_reports'
  and grantee in ('anon', 'authenticated', 'public')
order by
  grantee,
  privilege_type;


-- Verify RPC exists and execute grants
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  case
    when p.prosecdef then 'SECURITY DEFINER'
    else 'SECURITY INVOKER'
  end as security_mode,
  p.proconfig as function_config,
  has_function_privilege('authenticated', p.oid, 'execute') as authenticated_can_execute,
  has_function_privilege('anon', p.oid, 'execute') as anon_can_execute
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'create_signed_report_metadata'
order by
  pg_get_function_identity_arguments(p.oid);


-- Verify custody-documents policies after orphan cleanup policy
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and (
    qual::text ilike '%custody-documents%'
    or with_check::text ilike '%custody-documents%'
    or policyname ilike '%custody%'
  )
order by
  policyname,
  cmd;