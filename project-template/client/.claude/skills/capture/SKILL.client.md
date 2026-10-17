
## Client types

- `change-request`: Request · Source · Requested by · Impact (hours, fee, dates) · Client approval link (leave empty). Also add `enhancement` and `needs-triage`. Never mark it ready yourself.
- `direction-change`: From · To · Why, decided by, source · Superseded items · Deliverables to update · Client approval link (leave empty)
- `dependency`: What we need · From whom · Due date · Impact if late
- `access-grant`: System · Identity and role · Granted by, date · Secret name and store · At handover (revoke / transfer / rotate)
- `out-of-scope`: Ask · Who asked · Why not

The heading `### Client approval link` must match exactly. CI reads it.
