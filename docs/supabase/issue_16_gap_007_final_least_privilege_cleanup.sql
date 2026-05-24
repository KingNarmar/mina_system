-- Issue #16 / GAP-007 - Final broad non-DML grants cleanup
--
-- Goal:
-- Close the remaining broad non-DML grants gap by removing unnecessary
-- TRUNCATE / REFERENCES / TRIGGER privileges from client-facing roles.
--
-- Why:
-- Flutter clients do not need TRUNCATE / REFERENCES / TRIGGER privileges.
-- These privileges are not row-level operations and should not be exposed
-- to anon, authenticated, or PUBLIC roles.
--
-- Related matrix item:
-- GAP-007 - Broad Non-DML Grants
--
-- Do not modify PROJECT_ROADMAP.md for this issue.

-- ============================================================
-- 1) BEFORE CHECK - Find remaining broad non-DML grants
-- ============================================================

select
  grantee,
  table_schema,
  table_name,
  privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and grantee in ('anon', 'authenticated', 'PUBLIC')
  and privilege_type in ('TRUNCATE', 'REFERENCES', 'TRIGGER')
order by
  table_name,
  grantee,
  privilege_type;

-- Verified before cleanup:
--
-- Remaining broad non-DML grants were found on:
--
-- - public.company_invitations
-- - public.custody_acknowledgement_items
-- - public.custody_acknowledgements
-- - public.loss_damage_reports
-- - public.user_context_events
--
-- Affected roles:
--
-- - anon
-- - authenticated
--
-- Affected privileges:
--
-- - REFERENCES
-- - TRIGGER
-- - TRUNCATE


-- ============================================================
-- 2) APPLY CHANGE - Remove broad non-DML grants
-- ============================================================

begin;

revoke truncate, references, trigger
on table
  public.company_invitations,
  public.custody_acknowledgement_items,
  public.custody_acknowledgements,
  public.loss_damage_reports,
  public.user_context_events
from anon, authenticated, public;

commit;


-- ============================================================
-- 3) AFTER CHECK - Confirm no broad non-DML grants remain
-- ============================================================

select
  grantee,
  table_schema,
  table_name,
  privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and grantee in ('anon', 'authenticated', 'PUBLIC')
  and privilege_type in ('TRUNCATE', 'REFERENCES', 'TRIGGER')
order by
  table_name,
  grantee,
  privilege_type;

-- Verified after cleanup:
--
-- No rows returned.
--
-- Final result:
--
-- - anon has no TRUNCATE / REFERENCES / TRIGGER privileges on public tables.
-- - authenticated has no TRUNCATE / REFERENCES / TRIGGER privileges on public tables.
-- - PUBLIC has no TRUNCATE / REFERENCES / TRIGGER privileges on public tables.
--
-- GAP-007 is closed.