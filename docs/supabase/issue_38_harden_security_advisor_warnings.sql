-- Issue #38 - Harden Supabase Security Advisor warnings
-- Step 38.1 - Document initial Security Advisor cleanup
--
-- Scope:
-- Documentation only. No Flutter changes. No PROJECT_ROADMAP.md changes.
--
-- Safety warning:
-- Do not bulk-revoke EXECUTE from every SECURITY DEFINER function that is
-- executable by authenticated users. Some of those functions are intentional
-- secure RPCs used by the Flutter app and must be reviewed one by one.


-- ============================================================
-- 1) Initial Security Advisor state
-- ============================================================

-- Before initial manual cleanup:
-- - Supabase Security Advisor showed 51 warnings.
--
-- After initial manual cleanup:
-- - Supabase Security Advisor showed 43 warnings.
--
-- Remaining warnings are mainly:
-- - Signed-In Users Can Execute SECURITY DEFINER Function
--
-- Decision:
-- Remaining warnings require function-by-function review, not a blanket
-- permission change.


-- ============================================================
-- 2) Manual cleanup already applied in Supabase
-- ============================================================

-- The following manual changes were already applied in Supabase and are
-- recorded here for audit/documentation purposes.
--
-- A) Fixed search_path for utility/helper functions:
--
--   alter function public.set_updated_at()
--   set search_path = pg_catalog;
--
--   alter function private.company_id_from_storage_path(text)
--   set search_path = pg_catalog;
--
-- B) Removed direct client execution from trigger/event/helper functions:
--
--   revoke execute on function public.handle_new_auth_user()
--   from anon, authenticated, public;
--
--   revoke execute on function public.prevent_inviting_existing_company_member()
--   from anon, authenticated, public;
--
--   revoke execute on function public.rls_auto_enable()
--   from anon, authenticated, public;
--
--   revoke execute on function public.set_updated_at()
--   from anon, authenticated, public;
--
-- Why:
-- - These helper functions should not be callable directly from client roles.
-- - The cleanup was limited and did not touch app-required RPCs.


-- ============================================================
-- 3) Verification query - fixed search_path state
-- ============================================================

-- Expected known result after cleanup:
-- - public.set_updated_at() function_config includes search_path=pg_catalog
-- - private.company_id_from_storage_path(text) function_config includes search_path=pg_catalog

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
  ('public', 'set_updated_at'),
  ('private', 'company_id_from_storage_path')
)
order by
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 4) Verification query - helper direct execute privileges
-- ============================================================

-- Expected known result after cleanup:
-- - anon can_execute = false for all listed public helper functions.
-- - authenticated can_execute = false for all listed public helper functions.

with checked_roles(role_name) as (
  values
    ('anon'),
    ('authenticated')
),
checked_functions(schema_name, function_name, identity_arguments) as (
  values
    ('public', 'handle_new_auth_user', ''),
    ('public', 'prevent_inviting_existing_company_member', ''),
    ('public', 'rls_auto_enable', ''),
    ('public', 'set_updated_at', '')
)
select
  checked_roles.role_name,
  checked_functions.schema_name,
  checked_functions.function_name,
  checked_functions.identity_arguments,
  has_function_privilege(
    checked_roles.role_name,
    format(
      '%I.%I(%s)',
      checked_functions.schema_name,
      checked_functions.function_name,
      checked_functions.identity_arguments
    ),
    'execute'
  ) as can_execute
from checked_roles
cross join checked_functions
order by
  checked_functions.schema_name,
  checked_functions.function_name,
  checked_roles.role_name;


-- ============================================================
-- 5) Verification query - private schema usage
-- ============================================================

-- Expected known result after cleanup:
-- - anon can_use_private_schema = false
-- - authenticated can_use_private_schema = false
--
-- Note:
-- private.company_id_from_storage_path(text) may still show EXECUTE privilege
-- for anon/authenticated when checked with has_function_privilege.
-- However, because USAGE on the private schema is false for client roles,
-- it should not be directly callable through the normal API surface.

select
  role_name,
  has_schema_privilege(role_name, 'private', 'usage') as can_use_private_schema
from (
  values
    ('anon'),
    ('authenticated')
) as checked_roles(role_name)
order by
  role_name;


-- ============================================================
-- 6) Review query - remaining SECURITY DEFINER functions
-- ============================================================

-- Purpose:
-- Capture the current list of SECURITY DEFINER functions that authenticated
-- users can execute. This is for review only.
--
-- Do not convert this result into a bulk permission-change script.

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  p.prosecdef as is_security_definer,
  p.proconfig as function_config,
  has_function_privilege('authenticated', p.oid, 'execute') as authenticated_can_execute,
  has_function_privilege('anon', p.oid, 'execute') as anon_can_execute
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where p.prosecdef = true
  and has_function_privilege('authenticated', p.oid, 'execute') = true
order by
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 7) Classification template for next steps
-- ============================================================

-- Each remaining SECURITY DEFINER function should be classified as one of:
--
-- 1. App-required RPC
--    Called by Flutter intentionally. Keep authenticated EXECUTE only if needed.
--
-- 2. Trigger/helper function
--    Used internally by triggers or maintenance. Usually should not be directly
--    executable by client roles.
--
-- 3. Legacy/duplicate function
--    Kept during migration/refactor. Candidate for later cleanup after checks.
--
-- 4. Candidate for targeted revoke
--    Not used by Flutter and not intended as an RPC endpoint.
--
-- 5. Candidate for deletion later
--    Unused, superseded, and safe to remove only after dependency checks.


-- ============================================================
-- 8) Required checks for app-required RPCs
-- ============================================================

-- For every app-required SECURITY DEFINER RPC, verify:
--
-- - Fixed search_path.
-- - Authenticated user check.
-- - Trusted current profile lookup from backend context.
-- - Active company membership check where applicable.
-- - Role permission check where applicable.
-- - Company scope check.
-- - No client-controlled actor identity.
-- - No tenant isolation bypass.
-- - No service-role key in Flutter.


-- ============================================================
-- 9) Current known state after Step 38.1
-- ============================================================

-- Known documented state:
-- - Security Advisor warnings were reduced from 51 to 43.
-- - public.set_updated_at() uses search_path=pg_catalog.
-- - private.company_id_from_storage_path(text) uses search_path=pg_catalog.
-- - Direct EXECUTE was removed from anon/authenticated/public for:
--   - public.handle_new_auth_user()
--   - public.prevent_inviting_existing_company_member()
--   - public.rls_auto_enable()
--   - public.set_updated_at()
-- - private schema USAGE remains unavailable to anon/authenticated.
-- - Remaining SECURITY DEFINER warnings still require structured review.
--
-- Next suggested step:
-- Step 38.2 - Capture and classify the remaining SECURITY DEFINER warnings.
-- ============================================================
-- 10) Step 38.2 - Capture and classify remaining SECURITY DEFINER warnings
-- ============================================================
--
-- Scope:
-- Review only.
-- Do not revoke permissions from any function in this step.
-- Do not modify Flutter code.
-- Do not modify PROJECT_ROADMAP.md.
--
-- Goal:
-- Capture the remaining SECURITY DEFINER functions executable by authenticated
-- users and compare them against RPCs known to be required by Flutter.
--
-- Important:
-- Any function returned by these queries must be reviewed function-by-function.
-- Do not convert the output into a bulk revoke script.


-- ============================================================
-- 10.1) Known Flutter app-required RPCs
-- ============================================================
--
-- These RPCs are currently called by Flutter or already documented as part of
-- the Flutter RPC surface. If they appear in Security Advisor warnings, they
-- should be classified first as App-required RPC candidates, not revoked blindly.
--
-- Each one still needs backend safety verification:
-- - fixed search_path
-- - authenticated user check
-- - trusted profile/actor lookup
-- - active company membership check where applicable
-- - role permission check where applicable
-- - company scope enforcement
-- - no client-controlled actor identity

with app_required_rpcs(function_name) as (
  values
    -- Current context / company creation
    ('create_company_with_defaults'),

    -- Company users / invitations
    ('invite_company_user'),
    ('change_company_member_role'),
    ('deactivate_company_member'),
    ('reactivate_company_member'),
    ('accept_company_invitation'),
    ('cancel_company_invitation'),

    -- Workers
    ('create_worker'),
    ('update_worker'),
    ('deactivate_worker'),
    ('reactivate_worker'),

    -- Tools
    ('create_tool'),
    ('update_tool'),
    ('deactivate_tool'),
    ('reactivate_tool'),

    -- Lookups
    ('create_department'),
    ('deactivate_department'),
    ('reactivate_department'),
    ('create_job_title'),
    ('deactivate_job_title'),
    ('reactivate_job_title'),
    ('create_tool_unit'),
    ('deactivate_tool_unit'),
    ('reactivate_tool_unit'),
    ('create_tool_category'),
    ('deactivate_tool_category'),
    ('reactivate_tool_category'),

    -- Transactions
    ('create_custody_transaction'),
    ('upload_transaction_proof_image'),
    ('upload_transaction_approval_document'),
    ('approve_lost_damaged_transaction'),
    ('reject_lost_damaged_transaction'),
    ('settle_lost_damaged_transaction'),
    ('rollback_failed_transaction_proof_upload')
)
select
  app_required_rpcs.function_name,
  n.nspname as schema_name,
  p.proname is not null as function_exists,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  case
    when p.oid is null then null
    when p.prosecdef then 'SECURITY DEFINER'
    else 'SECURITY INVOKER'
  end as security_mode,
  p.proconfig as function_config,
  case
    when p.oid is null then null
    else has_function_privilege('authenticated', p.oid, 'execute')
  end as authenticated_can_execute,
  case
    when p.oid is null then null
    else has_function_privilege('anon', p.oid, 'execute')
  end as anon_can_execute,
  'App-required RPC candidate - verify backend checks before any permission change' as initial_classification
from app_required_rpcs
left join pg_proc p
  on p.proname = app_required_rpcs.function_name
left join pg_namespace n
  on n.oid = p.pronamespace
order by
  app_required_rpcs.function_name,
  n.nspname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 10.2) Remaining SECURITY DEFINER functions executable by authenticated
-- ============================================================
--
-- Purpose:
-- This captures the current Security Advisor-style surface from the database.
--
-- Result handling:
-- - Functions in the known_app_required_rpc list need backend safety review.
-- - Functions outside that list need classification:
--   Trigger/helper, legacy/duplicate, targeted revoke candidate, or deletion candidate.

with app_required_rpcs(function_name) as (
  values
    ('create_company_with_defaults'),
    ('invite_company_user'),
    ('change_company_member_role'),
    ('deactivate_company_member'),
    ('reactivate_company_member'),
    ('accept_company_invitation'),
    ('cancel_company_invitation'),
    ('create_worker'),
    ('update_worker'),
    ('deactivate_worker'),
    ('reactivate_worker'),
    ('create_tool'),
    ('update_tool'),
    ('deactivate_tool'),
    ('reactivate_tool'),
    ('create_department'),
    ('deactivate_department'),
    ('reactivate_department'),
    ('create_job_title'),
    ('deactivate_job_title'),
    ('reactivate_job_title'),
    ('create_tool_unit'),
    ('deactivate_tool_unit'),
    ('reactivate_tool_unit'),
    ('create_tool_category'),
    ('deactivate_tool_category'),
    ('reactivate_tool_category'),
    ('create_custody_transaction'),
    ('upload_transaction_proof_image'),
    ('upload_transaction_approval_document'),
    ('approve_lost_damaged_transaction'),
    ('reject_lost_damaged_transaction'),
    ('settle_lost_damaged_transaction'),
    ('rollback_failed_transaction_proof_upload')
)
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  p.proconfig as function_config,
  has_function_privilege('authenticated', p.oid, 'execute') as authenticated_can_execute,
  has_function_privilege('anon', p.oid, 'execute') as anon_can_execute,
  case
    when app_required_rpcs.function_name is not null then 'App-required RPC candidate'
    when n.nspname = 'private' then 'Private helper candidate - verify schema USAGE and call path'
    else 'Needs classification'
  end as initial_classification
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
left join app_required_rpcs
  on app_required_rpcs.function_name = p.proname
where p.prosecdef = true
  and has_function_privilege('authenticated', p.oid, 'execute') = true
order by
  initial_classification,
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 10.3) Functions executable by authenticated but missing fixed search_path
-- ============================================================
--
-- Purpose:
-- Prioritize SECURITY DEFINER functions where search_path is missing or not fixed.
--
-- Notes:
-- - A function_config of null means no function-level SET config exists.
-- - We should inspect these first because mutable search_path is a common
--   security-hardening target.
-- - Do not change anything until each function body and usage is reviewed.

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  p.proconfig as function_config,
  has_function_privilege('authenticated', p.oid, 'execute') as authenticated_can_execute,
  has_function_privilege('anon', p.oid, 'execute') as anon_can_execute
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where p.prosecdef = true
  and has_function_privilege('authenticated', p.oid, 'execute') = true
  and (
    p.proconfig is null
    or not exists (
      select 1
      from unnest(p.proconfig) as config_item
      where config_item like 'search_path=%'
    )
  )
order by
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid);


-- ============================================================
-- 10.4) Initial manual classification table
-- ============================================================
--
-- This is a documentation template.
-- Fill this manually after running the queries above.

-- Classification meanings:
--
-- App-required RPC:
-- - Flutter calls it intentionally.
-- - Keep authenticated EXECUTE if needed.
-- - Verify internal auth/company/role checks.
--
-- Trigger/helper:
-- - Used by triggers/events/internal database logic.
-- - Usually should not be directly executable by client roles.
--
-- Legacy/duplicate:
-- - Old or superseded function.
-- - Do not delete/revoke until usage is confirmed.
--
-- Candidate for targeted revoke:
-- - Not called by Flutter.
-- - Not intended as a client RPC.
-- - Can be considered for targeted revoke after dependency review.
--
-- Candidate for deletion later:
-- - Unused and superseded.
-- - Requires dependency checks before deletion.


-- ============================================================
-- 10.5) Step 38.2 expected output
-- ============================================================
--
-- After running the queries above, record:
--
-- 1. Total SECURITY DEFINER functions executable by authenticated:
--    - TODO: fill after query result
--
-- 2. App-required RPC candidates:
--    - TODO: fill after query result
--
-- 3. Functions missing fixed search_path:
--    - TODO: fill after query result
--
-- 4. Trigger/helper candidates:
--    - TODO: fill after query result
--
-- 5. Legacy/duplicate candidates:
--    - TODO: fill after query result
--
-- 6. Targeted revoke candidates:
--    - TODO: fill after query result
--
-- 7. Deletion-later candidates:
--    - TODO: fill after query result
--
-- Next suggested step:
-- Step 38.3 - Review the first batch of functions and decide which are safe,
-- which need search_path hardening, and which are candidates for targeted revoke.
-- ============================================================
-- 11) Step 38.2 - Initial classification results
-- ============================================================
--
-- Result summary:
-- - All known Flutter app-required RPCs exist.
-- - All known app-required RPCs are SECURITY DEFINER.
-- - authenticated can execute the app-required RPCs.
-- - anon cannot execute the public app-required RPCs.
-- - No authenticated-executable SECURITY DEFINER function was found without
--   a fixed search_path.
--
-- Important:
-- No revoke action is recommended in this step.
-- This is classification documentation only.


-- ============================================================
-- 11.1) Public functions initially marked as Needs classification
-- ============================================================
--
-- These public SECURITY DEFINER functions were returned by the review query
-- outside the initial Flutter app-required RPC list.
--
-- Final initial classification:
--
-- 1. public.approve_loss_damage_transaction(...)
--    Classification:
--    Controlled signed-evidence RPC / future signature workflow.
--
--    Reason:
--    - Creates public.loss_damage_reports.
--    - Validates signed_pdf_path.
--    - Rejects local file paths.
--    - Enforces company path prefix.
--    - Checks role through private.has_company_role(...).
--    - Updates the linked lost/damaged transaction.
--
--    Decision:
--    Keep for now. Do not revoke in Issue #38 Step 38.2.
--    Revisit during the digital handwritten signature workflow review.
--
--
-- 2. public.create_custody_acknowledgement(...)
--    Classification:
--    Controlled signed-evidence RPC / future signature workflow.
--
--    Reason:
--    - Creates public.custody_acknowledgements.
--    - Creates public.custody_acknowledgement_items.
--    - Validates signed_pdf_path.
--    - Rejects local file paths.
--    - Enforces company path prefix.
--    - Checks role through private.has_company_role(...).
--    - Snapshots worker open custody through public.get_worker_open_custody(...).
--
--    Decision:
--    Keep for now. Do not revoke in Issue #38 Step 38.2.
--    Revisit during the digital handwritten signature workflow review.
--
--
-- 3. public.get_worker_open_custody(...)
--    Classification:
--    Backend helper/reporting RPC - keep.
--
--    Reason:
--    - Used internally by public.create_custody_acknowledgement(...).
--    - Used internally by public.deactivate_worker(...).
--    - Checks active company membership through private.is_company_member(...).
--    - Verifies worker belongs to the same company.
--
--    Decision:
--    Keep. Do not revoke.
--
--
-- 4. public.get_worker_tool_balance(...)
--    Classification:
--    Backend helper/reporting RPC - keep.
--
--    Reason:
--    - Used internally by public.create_custody_transaction(...).
--    - Used internally by public.deactivate_tool(...).
--    - Checks active company membership through private.is_company_member(...).
--    - Calculates official worker/tool open balance.
--
--    Decision:
--    Keep. Do not revoke.
--
--
-- 5. public.update_department(...)
--    Classification:
--    Lookup update RPC candidate - keep.
--
--    Reason:
--    - Has role check for owner/admin/warehouse_manager.
--    - Validates company scope.
--    - Validates duplicate department name.
--    - Uses fixed search_path.
--
--    Decision:
--    Keep for now. Do not revoke.
--    Flutter can later use this RPC for controlled lookup update flow.
--
--
-- 6. public.update_job_title(...)
--    Classification:
--    Lookup update RPC candidate - keep.
--
--    Reason:
--    - Has role check for owner/admin/warehouse_manager.
--    - Validates company scope.
--    - Validates department belongs to same company and is active.
--    - Validates duplicate job title name within department.
--    - Uses fixed search_path.
--
--    Decision:
--    Keep for now. Do not revoke.
--    Flutter can later use this RPC for controlled lookup update flow.
--
--
-- 7. public.update_tool_category(...)
--    Classification:
--    Lookup update RPC candidate - keep.
--
--    Reason:
--    - Has role check for owner/admin/warehouse_manager.
--    - Validates company scope.
--    - Validates duplicate tool category name.
--    - Uses fixed search_path.
--
--    Decision:
--    Keep for now. Do not revoke.
--    Flutter can later use this RPC for controlled lookup update flow.
--
--
-- 8. public.update_tool_unit(...)
--    Classification:
--    Lookup update RPC candidate - keep.
--
--    Reason:
--    - Has role check for owner/admin/warehouse_manager.
--    - Validates company scope.
--    - Validates duplicate tool unit name.
--    - Uses fixed search_path.
--
--    Decision:
--    Keep for now. Do not revoke.
--    Flutter can later use this RPC for controlled lookup update flow.


-- ============================================================
-- 11.2) Private helper function classification
-- ============================================================
--
-- Reviewed private helpers:
--
-- - private.current_profile_id()
-- - private.has_company_role(uuid, company_member_role[])
-- - private.is_company_member(uuid)
-- - private.enqueue_user_context_event()
-- - private.log_company_settings_audit_event()
-- - private.set_company_settings_accountability()
--
-- Current state:
-- - EXECUTE appears granted through PUBLIC for several private helper functions.
-- - anon/authenticated do not have USAGE on the private schema.
-- - Therefore, they are not normally callable through the client API surface.
--
-- Dependency findings:
--
-- private.current_profile_id()
-- - Used by private.has_company_role(...).
-- - Used by private.is_company_member(...).
-- - Used by private audit/accountability helpers.
-- - Used directly by several public SECURITY DEFINER RPCs.
-- - Used in RLS policies on companies, profiles, and user_context_events.
--
-- private.has_company_role(...)
-- - Used heavily by public mutation RPCs.
-- - Used heavily by public table RLS policies.
-- - Used by Storage policies for company-assets, transaction-proofs,
--   transaction-approval-documents, and custody-documents.
--
-- private.is_company_member(...)
-- - Used by reporting/helper RPCs.
-- - Used by SELECT policies on core public tables.
-- - Used by Storage read policies.
--
-- private.enqueue_user_context_event()
-- - Trigger function.
-- - Bound to public.company_members through:
--   trg_company_members_user_context_event.
--
-- private.log_company_settings_audit_event()
-- - Trigger function.
-- - Bound to:
--   audit_companies_settings_changes
--   audit_company_document_templates_changes
--   audit_company_report_settings_changes.
--
-- private.set_company_settings_accountability()
-- - Trigger function.
-- - Bound to:
--   set_companies_accountability
--   set_company_document_templates_accountability
--   set_company_report_settings_accountability.
--
-- Decision:
-- Do not revoke EXECUTE from these private helpers in Step 38.2.
-- They are core backend helpers and/or trigger functions.
-- Any future hardening must be tested carefully because these functions are
-- part of RLS, Storage policies, RPC security checks, and audit/accountability
-- triggers.


-- ============================================================
-- 11.3) Step 38.2 decision
-- ============================================================
--
-- No permission changes are applied in this step.
--
-- Reviewed warning categories:
-- - App-required RPCs: keep.
-- - Signed-evidence / future signature RPCs: keep for later Issue #28 review.
-- - Backend helper/reporting RPCs: keep.
-- - Lookup update RPC candidates: keep.
-- - Private security helpers: keep.
-- - Private trigger helpers: keep.
--
-- Current recommendation:
-- The remaining Security Advisor warnings should be treated as reviewed and
-- justified for now, not blindly revoked.
--
-- Next suggested step:
-- Step 38.3 - Review whether any public RPC should be documented as
-- intentionally client-callable, and optionally add comments in this file
-- listing every reviewed function by final category.
-- ============================================================
-- 12) Step 38.2 - Final classification summary
-- ============================================================
--
-- Final reviewed classification counts:
--
-- 1. App-required RPC - keep
--    Count: 34
--    Missing: 0
--    SECURITY DEFINER: 34
--    authenticated EXECUTE: 34
--    anon EXECUTE: 0
--
-- 2. Backend helper/reporting RPC - keep
--    Count: 2
--    Missing: 0
--    SECURITY DEFINER: 2
--    authenticated EXECUTE: 2
--    anon EXECUTE: 0
--
-- 3. Controlled signed-evidence RPC / future signature workflow - keep
--    Count: 2
--    Missing: 0
--    SECURITY DEFINER: 2
--    authenticated EXECUTE: 2
--    anon EXECUTE: 0
--
-- 4. Lookup update RPC candidate - keep
--    Count: 4
--    Missing: 0
--    SECURITY DEFINER: 4
--    authenticated EXECUTE: 4
--    anon EXECUTE: 0
--
-- 5. Private core security helper - keep
--    Count: 3
--    Missing: 0
--    SECURITY DEFINER: 3
--    authenticated EXECUTE: 3
--    anon EXECUTE: 3
--
--    Important note:
--    anon/authenticated do not have USAGE on the private schema.
--    These helpers are also used by RLS policies, Storage policies, and
--    SECURITY DEFINER RPC checks, so no revoke action is recommended here.
--
-- 6. Private trigger helper - keep
--    Count: 3
--    Missing: 0
--    SECURITY DEFINER: 3
--    authenticated EXECUTE: 3
--    anon EXECUTE: 3
--
--    Important note:
--    These are bound to active triggers on company_members, companies,
--    company_report_settings, and company_document_templates.
--    No revoke action is recommended in this step.
--
--
-- Step 38.2 final decision:
--
-- No permission changes are required from this classification pass.
-- No bulk revoke should be applied.
-- The remaining Security Advisor warnings are currently reviewed and justified
-- as intentional backend RPC/helper exposure, with private schema access still
-- blocked from anon/authenticated by lack of USAGE.
--
-- Next suggested step:
-- Step 38.3 - Review public RPC function bodies in batches and document
-- whether each app-required RPC has:
--
-- - fixed search_path
-- - authenticated user/profile check
-- - active membership check
-- - role check where applicable
-- - company scope enforcement
-- - no client-controlled actor identity
-- - no service-role dependency from Flutter