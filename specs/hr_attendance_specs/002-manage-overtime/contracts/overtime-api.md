# Contracts — Overtime API

## OvertimeLine model (exposed fields)
- `id`, `employee_id`, `start_datetime`, `end_datetime`, `duration`, `status`, `attendance_id`, `compensation_outcome`, `notes`

## Endpoints / RPC
- `create_overtime_line(data)` → creates overtime line; returns created `OvertimeLine`.
- `approve_overtime_line(id, approver)` → sets status to `approved` and records `approved_by`.
- `refuse_overtime_line(id, approver, reason)` → sets status to `refused` with reason.
- `link_overtime_to_attendance(overtime_id, attendance_id)` → creates explicit linkage and recomputes aggregates.

## Events
- `overtime.approved` — payload: `{overtime_id, employee_id, duration}`
- `overtime.refused` — payload: `{overtime_id, employee_id, reason}`
