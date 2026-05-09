Phase P — Role-Based Access Control

Completed:
- Flutter UI role-based permissions
- Public table RLS write policies aligned with RBAC
- Storage policies aligned with RBAC

Roles:
- owner
- admin
- warehouse_manager
- warehouse_user
- viewer

Confirmed:
- warehouse_manager can manage workers, tools, lookups, and approval workflow
- warehouse_user can create transactions and upload transaction proof images
- warehouse_user cannot upload signed approval documents
- viewer can only access allowed read/report areas

Storage:
- transaction-proofs:
  owner, admin, warehouse_manager, warehouse_user

- transaction-approval-documents:
  owner, admin, warehouse_manager only