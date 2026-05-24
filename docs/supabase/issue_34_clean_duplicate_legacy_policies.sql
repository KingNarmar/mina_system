-- Issue #34 - Clean up duplicate and legacy RLS and Storage policies
--
-- Goal:
-- Clean up duplicate, overlapping, or legacy RLS / Storage policies
-- after confirming functional security behavior.
--
-- Scope:
-- - public.companies
-- - public.company_report_settings
-- - public.profiles
-- - storage.objects policies for company-assets
--
-- Important:
-- This issue must not intentionally change app behavior.
-- It only removes clearly redundant/legacy policies and dangerous unused grants.
--
-- Do not modify PROJECT_ROADMAP.md for this issue.


-- ============================================================
-- 1) BEFORE CHECK - Inspect targeted public RLS policies
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
    'companies',
    'company_report_settings',
    'profiles'
  )
order by
  tablename,
  cmd,
  policyname;

-- Verified before cleanup:
--
-- public.companies:
-- - Authenticated users can create companies
-- - Invited users can read invited company
-- - Members can read their companies
-- - Company admins can update company profile
-- - Owners and admins can update companies
--
-- Duplicate / legacy finding:
-- - Company admins can update company profile
-- - Owners and admins can update companies
-- Both allow owner/admin updates. The helper-based policy is clearer.
--
-- public.company_report_settings:
-- - Owners and admins can insert report settings
-- - Company members can read report settings
-- - Members can read report settings
-- - Company admins can update report settings
-- - Owners and admins can update report settings
--
-- Duplicate / legacy finding:
-- - Company members can read report settings
-- - Members can read report settings
-- Both allow active company members to read.
--
-- - Company admins can update report settings
-- - Owners and admins can update report settings
-- Both allow owner/admin updates. The helper-based policy is clearer.
--
-- public.profiles:
-- - Users can insert their own profile
-- - Company members can read member profiles
-- - Invited users can read inviter profile
-- - Users can read own profile
-- - Users can read own profile for context refresh
-- - Users can read their own profile
-- - Users can update their own profile
--
-- Duplicate / legacy finding:
-- Three own-profile read policies existed.
-- Keep one clear own-profile read policy.


-- ============================================================
-- 2) BEFORE CHECK - Inspect company-assets Storage policies
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
    qual::text ilike '%company-assets%'
    or with_check::text ilike '%company-assets%'
    or policyname ilike '%company%asset%'
    or policyname ilike '%logo%'
  )
order by
  cmd,
  policyname;

-- Verified before cleanup:
--
-- DELETE:
-- - Company admins can delete company assets
--
-- INSERT:
-- - Company admins can upload company assets
-- - Owners and admins can upload company assets
--
-- SELECT:
-- - Company members can read company assets
-- - Members can read company assets
--
-- UPDATE:
-- - Company admins can update company assets
--
-- Duplicate / legacy findings:
--
-- Read duplicate:
-- - Company members can read company assets
-- - Members can read company assets
--
-- Upload duplicate:
-- - Company admins can upload company assets
-- - Owners and admins can upload company assets
--
-- Legacy-style policies:
-- - Company admins can delete company assets
-- - Company admins can update company assets
--
-- Those legacy policies used direct joins.
-- They were later replaced with helper-based owner/admin policies.


-- ============================================================
-- 3) BEFORE CHECK - Inspect table grants
-- ============================================================

select
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name in (
    'companies',
    'company_report_settings',
    'profiles'
  )
  and grantee in ('anon', 'authenticated', 'PUBLIC')
order by
  table_name,
  grantee,
  privilege_type;

-- Verified before cleanup:
--
-- public.companies:
-- - anon had REFERENCES / TRIGGER / TRUNCATE
-- - authenticated had REFERENCES / SELECT / TRIGGER / TRUNCATE / UPDATE
--
-- public.company_report_settings:
-- - anon had REFERENCES / TRIGGER / TRUNCATE
-- - authenticated had REFERENCES / SELECT / TRIGGER / TRUNCATE / UPDATE
--
-- public.profiles:
-- - anon had REFERENCES / TRIGGER / TRUNCATE
-- - authenticated had REFERENCES / SELECT / TRIGGER / TRUNCATE
--
-- Finding:
-- TRUNCATE / REFERENCES / TRIGGER are not needed by the Flutter client.
-- They are dangerous or unnecessary direct privileges for anon/authenticated roles.


-- ============================================================
-- 4) BEFORE CHECK - Confirm effective table privileges
-- ============================================================

with checked_roles(role_name) as (
  values
    ('authenticated'),
    ('anon')
),
checked_tables(table_name) as (
  values
    ('companies'),
    ('company_report_settings'),
    ('profiles')
)
select
  checked_roles.role_name,
  checked_tables.table_name,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'select'
  ) as can_select,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'insert'
  ) as can_insert,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'update'
  ) as can_update,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'delete'
  ) as can_delete,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'truncate'
  ) as can_truncate,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'references'
  ) as can_references,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'trigger'
  ) as can_trigger
from checked_roles
cross join checked_tables
order by
  checked_tables.table_name,
  checked_roles.role_name;

-- Verified before cleanup:
--
-- anon:
-- - companies: truncate/references/trigger = true
-- - company_report_settings: truncate/references/trigger = true
-- - profiles: truncate/references/trigger = true
--
-- authenticated:
-- - companies: select/update = true, truncate/references/trigger = true
-- - company_report_settings: select/update = true, truncate/references/trigger = true
-- - profiles: select = true, truncate/references/trigger = true


-- ============================================================
-- 5) APPLY CHANGE - Revoke dangerous unused table privileges
-- ============================================================

revoke truncate, references, trigger
on table public.companies
from anon;

revoke truncate, references, trigger
on table public.companies
from authenticated;

revoke truncate, references, trigger
on table public.companies
from public;


revoke truncate, references, trigger
on table public.company_report_settings
from anon;

revoke truncate, references, trigger
on table public.company_report_settings
from authenticated;

revoke truncate, references, trigger
on table public.company_report_settings
from public;


revoke truncate, references, trigger
on table public.profiles
from anon;

revoke truncate, references, trigger
on table public.profiles
from authenticated;

revoke truncate, references, trigger
on table public.profiles
from public;

-- Applied successfully.
--
-- Important:
-- This does not remove SELECT or UPDATE permissions required by the app.
--
-- Kept required table grants:
-- - authenticated SELECT / UPDATE on companies
-- - authenticated SELECT / UPDATE on company_report_settings
-- - authenticated SELECT on profiles


-- ============================================================
-- 6) AFTER CHECK - Verify table grants after cleanup
-- ============================================================

select
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name in (
    'companies',
    'company_report_settings',
    'profiles'
  )
  and grantee in ('anon', 'authenticated', 'PUBLIC')
order by
  table_name,
  grantee,
  privilege_type;

-- Verified final result:
--
-- public.companies:
-- - authenticated SELECT
-- - authenticated UPDATE
--
-- public.company_report_settings:
-- - authenticated SELECT
-- - authenticated UPDATE
--
-- public.profiles:
-- - authenticated SELECT
--
-- No anon grants remain.
-- No TRUNCATE / REFERENCES / TRIGGER grants remain.


-- ============================================================
-- 7) AFTER CHECK - Verify effective table privileges
-- ============================================================

with checked_roles(role_name) as (
  values
    ('authenticated'),
    ('anon')
),
checked_tables(table_name) as (
  values
    ('companies'),
    ('company_report_settings'),
    ('profiles')
)
select
  checked_roles.role_name,
  checked_tables.table_name,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'select'
  ) as can_select,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'insert'
  ) as can_insert,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'update'
  ) as can_update,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'delete'
  ) as can_delete,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'truncate'
  ) as can_truncate,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'references'
  ) as can_references,
  has_table_privilege(
    checked_roles.role_name,
    format('public.%I', checked_tables.table_name),
    'trigger'
  ) as can_trigger
from checked_roles
cross join checked_tables
order by
  checked_tables.table_name,
  checked_roles.role_name;

-- Verified final result:
--
-- anon:
-- - all privileges are false on companies
-- - all privileges are false on company_report_settings
-- - all privileges are false on profiles
--
-- authenticated:
-- - companies:
--   - can_select = true
--   - can_update = true
--   - all other privileges = false
--
-- - company_report_settings:
--   - can_select = true
--   - can_update = true
--   - all other privileges = false
--
-- - profiles:
--   - can_select = true
--   - all other privileges = false


-- ============================================================
-- 8) APPLY CHANGE - Remove duplicate public RLS policies
-- ============================================================

drop policy if exists "Company admins can update company profile"
on public.companies;


drop policy if exists "Company members can read report settings"
on public.company_report_settings;

drop policy if exists "Company admins can update report settings"
on public.company_report_settings;


drop policy if exists "Users can read own profile"
on public.profiles;

drop policy if exists "Users can read own profile for context refresh"
on public.profiles;

-- Applied successfully.
--
-- Kept clearer/current policies:
--
-- public.companies:
-- - Owners and admins can update companies
--
-- public.company_report_settings:
-- - Members can read report settings
-- - Owners and admins can update report settings
--
-- public.profiles:
-- - Users can read their own profile
-- - Company members can read member profiles
-- - Invited users can read inviter profile


-- ============================================================
-- 9) AFTER CHECK - Verify public RLS policies after cleanup
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
    'companies',
    'company_report_settings',
    'profiles'
  )
order by
  tablename,
  cmd,
  policyname;

-- Verified final public RLS state:
--
-- public.companies:
-- - Authenticated users can create companies
-- - Invited users can read invited company
-- - Members can read their companies
-- - Owners and admins can update companies
--
-- public.company_report_settings:
-- - Owners and admins can insert report settings
-- - Members can read report settings
-- - Owners and admins can update report settings
--
-- public.profiles:
-- - Users can insert their own profile
-- - Company members can read member profiles
-- - Invited users can read inviter profile
-- - Users can read their own profile
-- - Users can update their own profile


-- ============================================================
-- 10) APPLY CHANGE - Remove duplicate company-assets Storage policies
-- ============================================================

drop policy if exists "Company members can read company assets"
on storage.objects;

drop policy if exists "Company admins can upload company assets"
on storage.objects;

-- Applied successfully.
--
-- Removed duplicate / legacy-style policies:
-- - Company members can read company assets
-- - Company admins can upload company assets
--
-- Kept clearer helper-based policies:
-- - Members can read company assets
-- - Owners and admins can upload company assets


-- ============================================================
-- 11) CHECK - Verify company-assets Storage policies after duplicate cleanup
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
    qual::text ilike '%company-assets%'
    or with_check::text ilike '%company-assets%'
    or policyname ilike '%company%asset%'
    or policyname ilike '%logo%'
  )
order by
  cmd,
  policyname;

-- Verified intermediate result:
--
-- DELETE:
-- - Company admins can delete company assets
--
-- INSERT:
-- - Owners and admins can upload company assets
--
-- SELECT:
-- - Members can read company assets
--
-- UPDATE:
-- - Company admins can update company assets
--
-- Remaining old-style policies:
-- - Company admins can delete company assets
-- - Company admins can update company assets
--
-- These were not duplicates after the previous step, but they were legacy-style
-- join-based policies. They were replaced with helper-based policies below.


-- ============================================================
-- 12) APPLY CHANGE - Replace legacy company-assets delete/update policies
-- ============================================================

create policy "Owners and admins can delete company assets"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'company-assets'
  and private.has_company_role(
    private.company_id_from_storage_path(name),
    array[
      'owner'::company_member_role,
      'admin'::company_member_role
    ]
  )
);

create policy "Owners and admins can update company assets"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'company-assets'
  and private.has_company_role(
    private.company_id_from_storage_path(name),
    array[
      'owner'::company_member_role,
      'admin'::company_member_role
    ]
  )
)
with check (
  bucket_id = 'company-assets'
  and private.has_company_role(
    private.company_id_from_storage_path(name),
    array[
      'owner'::company_member_role,
      'admin'::company_member_role
    ]
  )
);


drop policy if exists "Company admins can delete company assets"
on storage.objects;

drop policy if exists "Company admins can update company assets"
on storage.objects;

-- Applied successfully.
--
-- Behavior intended to remain the same:
-- - owner/admin can delete company assets
-- - owner/admin can update company assets
--
-- Policy implementation is now helper-based and easier to audit.


-- ============================================================
-- 13) AFTER CHECK - Verify final company-assets Storage policies
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
    qual::text ilike '%company-assets%'
    or with_check::text ilike '%company-assets%'
    or policyname ilike '%company%asset%'
    or policyname ilike '%logo%'
  )
order by
  cmd,
  policyname;

-- Verified final company-assets Storage policies:
--
-- DELETE:
-- - Owners and admins can delete company assets
--
-- INSERT:
-- - Owners and admins can upload company assets
--
-- SELECT:
-- - Members can read company assets
--
-- UPDATE:
-- - Owners and admins can update company assets
--
-- Final behavior:
-- - Active company members can read company assets.
-- - Owners/admins can upload company assets.
-- - Owners/admins can update company assets.
-- - Owners/admins can delete company assets.


-- ============================================================
-- 14) AFTER CHECK - Verify removed legacy policies do not remain
-- ============================================================

select
  schemaname,
  tablename,
  policyname,
  cmd
from pg_policies
where (
  schemaname = 'public'
  and tablename in (
    'companies',
    'company_report_settings',
    'profiles'
  )
  and policyname in (
    'Company admins can update company profile',
    'Company members can read report settings',
    'Company admins can update report settings',
    'Users can read own profile',
    'Users can read own profile for context refresh'
  )
)
or (
  schemaname = 'storage'
  and tablename = 'objects'
  and policyname in (
    'Company members can read company assets',
    'Company admins can upload company assets',
    'Company admins can delete company assets',
    'Company admins can update company assets'
  )
)
order by
  schemaname,
  tablename,
  policyname;

-- Verified final result:
-- - No rows returned.


-- ============================================================
-- 15) MANUAL APP TEST CHECKLIST
-- ============================================================
--
-- Completed successfully:
--
-- [x] Company profile update works.
-- [x] Report settings update works.
-- [x] Company logo upload works.
-- [x] Company logo replace works.
-- [x] Old company logo deletion during replacement works.
-- [x] Company Settings read/navigation works.
-- [x] Report Settings read/navigation works.
-- [x] Current Context / profile read works.
-- [x] Dashboard or company/logo display still loads.
--
-- Notes:
-- CompanySettingsRepo still relies on:
-- - direct UPDATE on public.companies
-- - direct UPDATE on public.company_report_settings
-- - company-assets upload/remove for company logo replacement
--
-- These flows were tested after cleanup and remained functional.


-- ============================================================
-- 16) FINAL ISSUE #34 SUMMARY
-- ============================================================
--
-- What changed:
--
-- 1. Removed dangerous unused grants:
--    - TRUNCATE
--    - REFERENCES
--    - TRIGGER
--    from anon/authenticated/public on:
--    - public.companies
--    - public.company_report_settings
--    - public.profiles
--
-- 2. Removed duplicate public RLS policies:
--    - Company admins can update company profile
--    - Company members can read report settings
--    - Company admins can update report settings
--    - Users can read own profile
--    - Users can read own profile for context refresh
--
-- 3. Removed duplicate company-assets Storage policies:
--    - Company members can read company assets
--    - Company admins can upload company assets
--
-- 4. Replaced legacy company-assets Storage policies:
--    - Company admins can delete company assets
--    - Company admins can update company assets
--
--    with helper-based policies:
--    - Owners and admins can delete company assets
--    - Owners and admins can update company assets
--
-- Final result:
--
-- - Policy list is simpler.
-- - Policy logic is easier to audit.
-- - No intended access was broken.
-- - No unintended access was introduced.
-- - Company Settings still works.
-- - Report Settings still works.
-- - Company logo upload and replacement still work.
-- - anon has no direct table privileges on the targeted public tables.
-- - authenticated keeps only the permissions required by the app.