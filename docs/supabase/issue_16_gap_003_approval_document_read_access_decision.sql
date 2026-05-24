-- Issue #16 / GAP-003 - Approval document read access decision
--
-- Goal:
-- Document the final business decision for reading files stored in:
-- storage bucket: transaction-approval-documents
--
-- Decision:
-- Approval documents should remain readable by all active company members,
-- including:
--
-- - owner
-- - admin
-- - warehouse_manager
-- - warehouse_user
-- - viewer
--
-- Why:
-- Approval documents explain why a lost/damaged transaction was approved
-- or rejected.
--
-- Warehouse User needs read visibility because this role deals directly
-- with workers and may need to explain the approval/rejection outcome.
--
-- Viewer also needs read visibility because this role may represent senior
-- company titles who need operational oversight without mutation access.
--
-- Important:
-- This decision is READ ONLY.
--
-- Viewer and Warehouse User must not be allowed to:
--
-- - upload approval documents
-- - approve lost/damaged transactions
-- - reject lost/damaged transactions
-- - settle lost/damaged transactions
--
-- Those mutation actions remain restricted to the approved operational roles.
--
-- Related matrix item:
-- GAP-003 - Approval Document Read Access
--
-- Do not modify PROJECT_ROADMAP.md for this issue.

-- ============================================================
-- 1) VERIFICATION - Inspect approval document Storage policies
-- ============================================================

select
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and (
    policyname ilike '%approval%'
    or qual::text ilike '%transaction-approval-documents%'
    or with_check::text ilike '%transaction-approval-documents%'
  )
order by
  cmd,
  policyname;

-- Expected read policy decision:
--
-- Read access may remain based on active company membership.
--
-- This means active company members can read approval documents if the object
-- path belongs to their company.
--
-- This is accepted because:
--
-- - Owner/Admin/Warehouse Manager need management visibility.
-- - Warehouse User needs operational explanation visibility.
-- - Viewer needs oversight visibility.
--
-- Mutation actions remain restricted separately through:
--
-- - Storage INSERT/DELETE policies
-- - transaction approval RPC role checks
-- - Flutter permission guards

-- ============================================================
-- 2) FINAL STATUS
-- ============================================================
--
-- No Storage policy change is required for GAP-003.
--
-- GAP-003 is closed as:
--
-- Business Decision Accepted.
--
-- Final decision:
--
-- transaction-approval-documents read access remains available to all
-- active company members.
--
-- Mutation access remains restricted.