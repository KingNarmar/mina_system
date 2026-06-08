-- Issue #48 - Targeted resume refresh RPC
--
-- Scope:
-- - Backend SQL only.
-- - No Flutter changes in this file.
-- - No PROJECT_ROADMAP.md changes.
--
-- Goal:
-- Add a lightweight authenticated RPC that allows the app to detect which
-- company data areas changed while the app was in background / lock screen.
--
-- This avoids refreshing all live data on every app resume.
--
-- Design:
-- - No company_change_events table is used for now.
-- - Detection relies on created_at / updated_at in existing company tables.
-- - DELETE is not handled through this RPC because public authenticated users
--   do not have direct DELETE grants on the tracked tables, and the current
--   domain model uses status / is_active / is_voided style soft-state columns.
-- - The RPC returns only grouped refresh areas, not row data.
--
-- Security:
-- - Function is SECURITY DEFINER.
-- - search_path is pinned to public, private.
-- - Result is gated by private.is_company_member(p_company_id).
-- - EXECUTE is revoked from anon and public.
-- - EXECUTE is granted only to authenticated.

create or replace function public.get_company_refresh_areas(
  p_company_id uuid,
  p_since timestamptz
)
returns table (
  change_area text,
  changed_rows bigint,
  last_change_at timestamptz
)
language sql
security definer
set search_path to 'public', 'private'
as $function$
  with changes as (
    select
      'transactions'::text as change_area,
      count(*)::bigint as changed_rows,
      max(greatest(created_at, updated_at)) as last_change_at
    from public.transactions
    where company_id = p_company_id
      and greatest(created_at, updated_at) > p_since

    union all

    select
      'workers'::text,
      count(*)::bigint,
      max(greatest(created_at, updated_at))
    from public.workers
    where company_id = p_company_id
      and greatest(created_at, updated_at) > p_since

    union all

    select
      'tools'::text,
      count(*)::bigint,
      max(greatest(created_at, updated_at))
    from public.tools
    where company_id = p_company_id
      and greatest(created_at, updated_at) > p_since

    union all

    select
      'company_users'::text,
      count(*)::bigint,
      max(greatest(created_at, updated_at))
    from public.company_members
    where company_id = p_company_id
      and greatest(created_at, updated_at) > p_since

    union all

    select
      'lookups'::text,
      count(*)::bigint,
      max(greatest(created_at, updated_at))
    from public.departments
    where company_id = p_company_id
      and greatest(created_at, updated_at) > p_since

    union all

    select
      'lookups'::text,
      count(*)::bigint,
      max(greatest(created_at, updated_at))
    from public.job_titles
    where company_id = p_company_id
      and greatest(created_at, updated_at) > p_since

    union all

    select
      'lookups'::text,
      count(*)::bigint,
      max(greatest(created_at, updated_at))
    from public.tool_units
    where company_id = p_company_id
      and greatest(created_at, updated_at) > p_since

    union all

    select
      'lookups'::text,
      count(*)::bigint,
      max(greatest(created_at, updated_at))
    from public.tool_categories
    where company_id = p_company_id
      and greatest(created_at, updated_at) > p_since
  )
  select
    change_area,
    sum(changed_rows)::bigint as changed_rows,
    max(last_change_at) as last_change_at
  from changes
  where private.is_company_member(p_company_id)
  group by change_area
  having sum(changed_rows) > 0
  order by max(last_change_at) desc;
$function$;

revoke execute
on function public.get_company_refresh_areas(uuid, timestamptz)
from anon;

revoke execute
on function public.get_company_refresh_areas(uuid, timestamptz)
from public;

grant execute
on function public.get_company_refresh_areas(uuid, timestamptz)
to authenticated;
