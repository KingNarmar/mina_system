-- Issue #33 - Classify custody-documents storage bucket and policies
--
-- Goal:
-- Decide whether the custody-documents Storage bucket is active, legacy,
-- unused, or planned/reserved for a future workflow.
--
-- Final Decision:
-- custody-documents is a planned / reserved active bucket.
--
-- Purpose:
-- This bucket will be used later for digitally signed custody PDF documents
-- when the digital handwritten signature workflow is implemented.
--
-- Intended future flow:
-- - Generate custody PDF.
-- - Worker signs the PDF using a touch signature device connected to the PC.
-- - Signature is embedded into the PDF.
-- - Signed PDF is uploaded to Supabase Storage.
-- - Database stores the signed PDF path for future retrieval.
--
-- Do not delete this bucket.
-- Do not treat it as unused production waste.
-- Do not modify PROJECT_ROADMAP.md for this issue.


-- ============================================================
-- 1) CHECK - Confirm custody-documents bucket exists
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

-- Verified before classification:
-- - Bucket exists.
-- - id = custody-documents
-- - name = custody-documents
-- - public = false
-- - initial file_size_limit = null
-- - initial allowed_mime_types = null
-- - created_at = 2026-05-04 13:31:57.763687+00


-- ============================================================
-- 2) CHECK - Count current objects inside custody-documents
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

-- Verified result:
-- - No rows returned.
-- - custody-documents currently contains zero objects.
--
-- Interpretation:
-- This is expected because the digital handwritten signature workflow
-- has not been implemented yet.


-- ============================================================
-- 3) CHECK - List custody-documents Storage policies
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

-- Verified before update:
--
-- Read policy:
-- - Members can read custody documents
-- - SELECT
-- - authenticated
-- - bucket_id = custody-documents
-- - private.is_company_member(private.company_id_from_storage_path(name))
--
-- Upload policy before update:
-- - Owner admin warehouse can upload custody documents
-- - INSERT
-- - authenticated
-- - Allowed roles before update:
--   - owner
--   - admin
--   - warehouse_user
--
-- Finding:
-- The upload policy did not include warehouse_manager.
-- Business decision confirmed:
-- warehouse_manager must also be able to upload signed custody PDFs.


-- ============================================================
-- 4) CHECK - Search public text/json records for custody-documents references
-- ============================================================

drop table if exists temp_custody_documents_references;

create temp table temp_custody_documents_references (
  table_schema text,
  table_name text,
  column_name text,
  matched_count bigint
);

do $$
declare
  column_record record;
  match_count bigint;
begin
  for column_record in
    select
      table_schema,
      table_name,
      column_name
    from information_schema.columns
    where table_schema = 'public'
      and data_type in ('text', 'character varying', 'json', 'jsonb')
    order by
      table_name,
      column_name
  loop
    execute format(
      'select count(*) from %I.%I where %I::text ilike %L',
      column_record.table_schema,
      column_record.table_name,
      column_record.column_name,
      '%custody-documents%'
    )
    into match_count;

    if match_count > 0 then
      insert into temp_custody_documents_references (
        table_schema,
        table_name,
        column_name,
        matched_count
      )
      values (
        column_record.table_schema,
        column_record.table_name,
        column_record.column_name,
        match_count
      );
    end if;
  end loop;
end $$;

select
  table_schema,
  table_name,
  column_name,
  matched_count
from temp_custody_documents_references
order by
  table_name,
  column_name;

-- Verified result:
-- - No rows returned.
--
-- Interpretation:
-- Database file paths do not store the bucket name explicitly.
-- Paths are stored as company-scoped object paths such as:
-- {company_id}/...


-- ============================================================
-- 5) CHECK - Identify file/path/document related columns
-- ============================================================

select
  c.table_schema,
  c.table_name,
  c.column_name,
  c.data_type
from information_schema.columns c
where c.table_schema = 'public'
  and (
    c.column_name ilike '%path%'
    or c.column_name ilike '%url%'
    or c.column_name ilike '%file%'
    or c.column_name ilike '%document%'
    or c.column_name ilike '%image%'
    or c.column_name ilike '%logo%'
  )
order by
  c.table_name,
  c.column_name;

-- Important detected columns included:
--
-- - companies.logo_path
-- - transactions.proof_image_path
-- - transactions.approval_document_path
-- - custody_acknowledgement_items.last_proof_image_path_snapshot
-- - custody_acknowledgements.signed_pdf_path
-- - loss_damage_reports.proof_image_path_snapshot
-- - loss_damage_reports.signed_pdf_path
-- - profiles.avatar_path


-- ============================================================
-- 6) CHECK - Count non-null file/path values
-- ============================================================

select
  'companies.logo_path' as field_name,
  count(*) filter (where logo_path is not null and trim(logo_path) <> '') as non_null_count
from public.companies

union all

select
  'profiles.avatar_path' as field_name,
  count(*) filter (where avatar_path is not null and trim(avatar_path) <> '') as non_null_count
from public.profiles

union all

select
  'transactions.proof_image_path' as field_name,
  count(*) filter (where proof_image_path is not null and trim(proof_image_path) <> '') as non_null_count
from public.transactions

union all

select
  'transactions.approval_document_path' as field_name,
  count(*) filter (where approval_document_path is not null and trim(approval_document_path) <> '') as non_null_count
from public.transactions

union all

select
  'custody_acknowledgement_items.last_proof_image_path_snapshot' as field_name,
  count(*) filter (
    where last_proof_image_path_snapshot is not null
      and trim(last_proof_image_path_snapshot) <> ''
  ) as non_null_count
from public.custody_acknowledgement_items

union all

select
  'custody_acknowledgements.signed_pdf_path' as field_name,
  count(*) filter (
    where signed_pdf_path is not null
      and trim(signed_pdf_path) <> ''
  ) as non_null_count
from public.custody_acknowledgements

union all

select
  'loss_damage_reports.proof_image_path_snapshot' as field_name,
  count(*) filter (
    where proof_image_path_snapshot is not null
      and trim(proof_image_path_snapshot) <> ''
  ) as non_null_count
from public.loss_damage_reports

union all

select
  'loss_damage_reports.signed_pdf_path' as field_name,
  count(*) filter (
    where signed_pdf_path is not null
      and trim(signed_pdf_path) <> ''
  ) as non_null_count
from public.loss_damage_reports
order by
  field_name;

-- Verified result:
--
-- - companies.logo_path = 2
-- - custody_acknowledgement_items.last_proof_image_path_snapshot = 0
-- - custody_acknowledgements.signed_pdf_path = 1
-- - loss_damage_reports.proof_image_path_snapshot = 1
-- - loss_damage_reports.signed_pdf_path = 1
-- - profiles.avatar_path = 0
-- - transactions.approval_document_path = 26
-- - transactions.proof_image_path = 54


-- ============================================================
-- 7) CHECK - Inspect stored path samples
-- ============================================================

select
  'companies.logo_path' as field_name,
  logo_path as stored_path
from public.companies
where logo_path is not null
  and trim(logo_path) <> ''

union all

select
  'transactions.proof_image_path' as field_name,
  proof_image_path as stored_path
from public.transactions
where proof_image_path is not null
  and trim(proof_image_path) <> ''
limit 10;


select
  'transactions.approval_document_path' as field_name,
  approval_document_path as stored_path
from public.transactions
where approval_document_path is not null
  and trim(approval_document_path) <> ''

union all

select
  'custody_acknowledgements.signed_pdf_path' as field_name,
  signed_pdf_path as stored_path
from public.custody_acknowledgements
where signed_pdf_path is not null
  and trim(signed_pdf_path) <> ''

union all

select
  'loss_damage_reports.proof_image_path_snapshot' as field_name,
  proof_image_path_snapshot as stored_path
from public.loss_damage_reports
where proof_image_path_snapshot is not null
  and trim(proof_image_path_snapshot) <> ''

union all

select
  'loss_damage_reports.signed_pdf_path' as field_name,
  signed_pdf_path as stored_path
from public.loss_damage_reports
where signed_pdf_path is not null
  and trim(signed_pdf_path) <> ''
order by
  field_name,
  stored_path;

-- Verified findings:
--
-- - Stored paths do not include bucket names.
-- - Paths begin with company_id.
-- - transaction proof paths belong to transaction-proofs.
-- - transaction approval document paths belong to transaction-approval-documents.
-- - signed_pdf_path examples:
--   - {company_id}/acknowledgements/test/ACK-00001.pdf
--   - {company_id}/loss-damage/test/LDR-00001.pdf
--
-- Finding:
-- Existing signed_pdf_path records are historical test references.


-- ============================================================
-- 8) CHECK - Verify signed PDF paths exist in Storage
-- ============================================================

with db_paths as (
  select
    'custody_acknowledgements.signed_pdf_path' as source_field,
    signed_pdf_path as stored_path
  from public.custody_acknowledgements
  where signed_pdf_path is not null
    and trim(signed_pdf_path) <> ''

  union all

  select
    'loss_damage_reports.signed_pdf_path' as source_field,
    signed_pdf_path as stored_path
  from public.loss_damage_reports
  where signed_pdf_path is not null
    and trim(signed_pdf_path) <> ''
)
select
  db_paths.source_field,
  db_paths.stored_path,
  storage.objects.bucket_id,
  storage.objects.name as storage_object_name,
  storage.objects.created_at as object_created_at,
  storage.objects.updated_at as object_updated_at
from db_paths
left join storage.objects
  on storage.objects.name = db_paths.stored_path
order by
  db_paths.source_field,
  db_paths.stored_path,
  storage.objects.bucket_id;

-- Verified result:
--
-- - custody_acknowledgements.signed_pdf_path:
--   bucket_id = null
--
-- - loss_damage_reports.signed_pdf_path:
--   bucket_id = null
--
-- Interpretation:
-- The DB references exist, but the files do not exist in any Storage bucket.
-- These are historical test references, not active production Storage objects.


-- ============================================================
-- 9) CHECK - Inspect signed PDF records
-- ============================================================

select
  'custody_acknowledgements' as table_name,
  id,
  company_id,
  document_code_snapshot,
  document_title_snapshot,
  signed_pdf_path,
  created_at,
  updated_at,
  voided_at
from public.custody_acknowledgements
where signed_pdf_path is not null
  and trim(signed_pdf_path) <> ''

union all

select
  'loss_damage_reports' as table_name,
  id,
  company_id,
  document_code_snapshot,
  document_title_snapshot,
  signed_pdf_path,
  created_at,
  updated_at,
  voided_at
from public.loss_damage_reports
where signed_pdf_path is not null
  and trim(signed_pdf_path) <> ''
order by
  table_name,
  created_at;

-- Verified result:
--
-- custody_acknowledgements:
-- - document_code_snapshot = MNA-CUS-ACK-001
-- - document_title_snapshot = Worker Custody Acknowledgement
-- - signed_pdf_path contains /test/ACK-00001.pdf
--
-- loss_damage_reports:
-- - document_code_snapshot = MNA-LDR-001
-- - document_title_snapshot = Lost / Damaged Tool Clearance Report
-- - signed_pdf_path contains /test/LDR-00001.pdf
--
-- Both records belong to company:
-- f57e9ce7-0e36-43fe-a1aa-cf651d78c305


-- ============================================================
-- 10) CHECK - Inspect company owning signed PDF test records
-- ============================================================

select
  id,
  name,
  trade_name,
  legal_name,
  email,
  phone,
  city,
  country,
  logo_path,
  created_at,
  updated_at
from public.companies
where id = 'f57e9ce7-0e36-43fe-a1aa-cf651d78c305';

-- Verified result:
--
-- - name = Mina System Test Company
-- - trade_name = Mina System
-- - legal_name = Mina System Test Company LLC
-- - email = info@mina-system.com
-- - city = Dubai
-- - country = United Arab Emirates
--
-- Interpretation:
-- Existing signed PDF references belong to test company data.


-- ============================================================
-- 11) CHECK - Storage bucket object count summary
-- ============================================================

select
  b.id as bucket_id,
  b.name,
  b.public,
  b.file_size_limit,
  b.allowed_mime_types,
  count(o.id) as object_count,
  min(o.created_at) as first_object_created_at,
  max(o.created_at) as last_object_created_at
from storage.buckets b
left join storage.objects o
  on o.bucket_id = b.id
group by
  b.id,
  b.name,
  b.public,
  b.file_size_limit,
  b.allowed_mime_types
order by
  b.id;

-- Verified before update:
--
-- company-assets:
-- - object_count = 2
--
-- custody-documents:
-- - object_count = 0
--
-- transaction-approval-documents:
-- - object_count = 34
--
-- transaction-proofs:
-- - object_count = 53
--
-- Interpretation:
-- custody-documents is not currently used by implemented Flutter flows,
-- but is intentionally reserved for the future signed custody PDF workflow.


-- ============================================================
-- 12) APPLY CHANGE - Restrict custody-documents to signed PDF files
-- ============================================================

update storage.buckets
set
  file_size_limit = 10485760,
  allowed_mime_types = array['application/pdf']::text[],
  updated_at = now()
where id = 'custody-documents';

-- Applied successfully.
--
-- Final intended bucket settings:
-- - public = false
-- - file_size_limit = 10485760
-- - allowed_mime_types = ["application/pdf"]


-- ============================================================
-- 13) APPLY CHANGE - Add warehouse_manager to upload policy
-- ============================================================

drop policy if exists "Owner admin warehouse can upload custody documents"
on storage.objects;

create policy "Owner admin manager user can upload custody documents"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'custody-documents'
  and private.has_company_role(
    private.company_id_from_storage_path(name),
    array[
      'owner'::company_member_role,
      'admin'::company_member_role,
      'warehouse_manager'::company_member_role,
      'warehouse_user'::company_member_role
    ]
  )
);

-- Applied successfully.
--
-- Final upload roles:
-- - owner
-- - admin
-- - warehouse_manager
-- - warehouse_user


-- ============================================================
-- 14) AFTER CHECK - Verify final bucket settings
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
where id = 'custody-documents';

-- Verified final result:
-- - id = custody-documents
-- - name = custody-documents
-- - public = false
-- - file_size_limit = 10485760
-- - allowed_mime_types = ["application/pdf"]
-- - updated_at changed after the update


-- ============================================================
-- 15) AFTER CHECK - Verify final Storage policies
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

-- Verified final result:
--
-- Read policy:
-- - Members can read custody documents
-- - SELECT
-- - authenticated
-- - bucket_id = custody-documents
-- - private.is_company_member(private.company_id_from_storage_path(name))
--
-- Upload policy:
-- - Owner admin manager user can upload custody documents
-- - INSERT
-- - authenticated
-- - bucket_id = custody-documents
-- - allowed roles:
--   - owner
--   - admin
--   - warehouse_manager
--   - warehouse_user


-- ============================================================
-- 16) AFTER CHECK - Verify final object count
-- ============================================================

select
  b.id as bucket_id,
  b.public,
  b.file_size_limit,
  b.allowed_mime_types,
  count(o.id) as object_count
from storage.buckets b
left join storage.objects o
  on o.bucket_id = b.id
where b.id = 'custody-documents'
group by
  b.id,
  b.public,
  b.file_size_limit,
  b.allowed_mime_types;

-- Verified final result:
-- - bucket_id = custody-documents
-- - public = false
-- - file_size_limit = 10485760
-- - allowed_mime_types = ["application/pdf"]
-- - object_count = 0


-- ============================================================
-- 17) FINAL ISSUE #33 SUMMARY
-- ============================================================
--
-- Final classification:
-- custody-documents is a planned / reserved active bucket.
--
-- It is reserved for:
-- - Digitally signed custody acknowledgement PDFs.
-- - Future touch-signature device workflow.
-- - Replacing printed custody paper with signed PDF storage.
--
-- It is not currently used by Flutter because:
-- - The digital handwritten signature workflow has not been implemented yet.
-- - Current Flutter transaction storage uses:
--   - transaction-proofs
--   - transaction-approval-documents
--
-- Existing historical DB references:
-- - custody_acknowledgements.signed_pdf_path = 1
-- - loss_damage_reports.signed_pdf_path = 1
--
-- These references:
-- - belong to Mina System Test Company.
-- - contain /test/ paths.
-- - point to files that do not currently exist in any Storage bucket.
-- - should be treated as historical test data, not active production usage.
--
-- Final bucket state:
-- - Bucket remains.
-- - Bucket is private.
-- - Bucket allows PDF only.
-- - Bucket max file size is 10MB.
-- - Bucket currently contains zero objects.
--
-- Final policy state:
-- - Active company members can read custody documents.
-- - owner/admin/warehouse_manager/warehouse_user can upload custody documents.
--
-- Do not delete custody-documents.
-- Revisit this bucket when implementing the digital handwritten signature workflow.