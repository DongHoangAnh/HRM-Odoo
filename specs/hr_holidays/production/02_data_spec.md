# HR Leave Data Spec

## Aggregate Model Map

### Core entities
- hr.leave
- hr.leave.type
- hr.leave.allocation
- hr.leave.accrual.plan
- hr.leave.accrual.level

## Project Context (Context Discovery alignment)

- Scope limited to Employee, Attendance, Leave, Payroll, Recruitment.
- Leave balances and accruals must feed payroll and respect teaching-hour policies when configured.
- Keep custom fields and modules namespaced with `hrm_*` and avoid core changes.

### Related entities
- hr.employee
- hr.employee.public
- hr.department
- resource.calendar
- resource.calendar.leaves
- calendar.event
- mail.message.subtype
- res.company

## Key Relationships

- hr.leave belongs to one employee and one leave type.
- hr.leave.type controls request and validation policy.
- hr.leave.allocation is linked to an employee, a type, and optionally an accrual plan.
- hr.leave.accrual.plan contains multiple accrual levels.
- hr.leave.accrual.level belongs to one accrual plan.
- hr.employee and hr.employee.public expose leave-related computed data.
- hr.department can expose leave actions for its members.

## Data Contracts

### Leave request data
- request_date_from and request_date_to define the request period.
- request_unit must match the chosen duration model.
- state must move through the configured workflow.
- description/private_name must respect confidentiality rules.
- meeting/calendar linkage must be optional but consistent.

### Leave allocation data
- number_of_days and number_of_hours represent allocation value.
- state must be draft, validate, refuse, or cancel as applicable.
- allocation visibility must reflect policy and balance.
- department-based allocation must remain company scoped.

### Accrual plan data
- name is required, with a safe default when omitted.
- time_off_type_id links a plan to a leave type when needed.
- level_ids store milestones.
- carryover fields determine how unused balances roll forward.
- company_id must follow the leave type or active company.

### Accrual level data
- start_count and start_type define milestone offset.
- frequency defines recurrence behavior.
- added_value and added_value_type define accrual amount.
- cap fields limit total and yearly accrual.
- carryover and validity fields define unused accrual handling.

### Employee leave data
- current_leave_id and current_leave_state reflect validated leaves.
- allocation_count and allocation_remaining_display show balances.
- show_leaves controls visibility in the UI.
- is_absent and leave manager fields reflect current leave status.

### Leave type data
- requires_allocation determines whether balance is mandatory.
- leave_validation_type and allocation_validation_type define approvals.
- request_unit determines how requests are measured.
- hide_on_dashboard and include_public_holidays_in_duration affect visibility and duration logic.
- negative caps require a valid maximum.

## Constraints

- Leave types with absence policy cannot request on top.
- Worked time leave types must remain accrual eligible.
- Allocation requirement cannot change after leaves are already used.
- Public-holiday inclusion changes must not invalidate existing overlapping leaves.
- Accrual plan levels must reject zero-value caps or invalid schedules.
- Date and duration fields must stay internally consistent.

## Derived Fields

- leave_date_from and leave_date_to
- current_leave_state
- is_absent
- allocation_count and allocations_count
- virtual_remaining_leaves and max_leaves
- accrual plan level_count and employees_count
- show_transition_mode and carryover flags

## Persistence Expectations

- Approvals must update balances and leave status consistently.
- Refusals and cancellations must not corrupt balances.
- Accrual computations must be safe across years and carryover boundaries.
- Employee/public projections must stay aligned.
