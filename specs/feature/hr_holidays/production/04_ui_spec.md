# HR Leave UI Spec

## UI Goals
- Make leave requests and approvals easy to understand.
- Surface balances, allocations, and current leave state clearly.
- Keep configuration for leave types and accrual plans manageable.

## Project Context (Context Discovery alignment)

- Default UI language for HR users is Vietnamese; clearly label accrual and payroll-facing fields so Finance can use them.
- Ensure leave UI surfaces payroll-relevant values (allocation remaining, accruals) to HR/Finance roles while hiding private notes from public/non-HR.

## Required Screens
- Leave request form, list, and calendar views.
- Leave allocation form and list views.
- Leave type configuration form.
- Accrual plan and accrual level forms.
- Employee time-off dashboard and calendar views.
- Public/employee leave status views where needed.

## Leave Request UI Requirements
- Show request dates, durations, type, and state clearly.
- Expose approve, refuse, cancel, validate, and reset actions where allowed.
- Show private notes separately from employee-facing notes.
- Display calendar links for approved leave.

## Allocation UI Requirements
- Show allocated, remaining, and expired amounts.
- Support department-based allocation creation.
- Display allocation approval state and history.

## Accrual UI Requirements
- Show the plan, levels, carryover behavior, and caps.
- Make milestone dates and recurrence behavior understandable.
- Prevent unsafe combinations through immediate validation feedback.

## Leave Type UI Requirements
- Surface request unit, validation type, allocation requirement, public holiday behavior, and dashboard visibility.
- Make negative cap and accrual eligibility constraints explicit.

## Employee Dashboard UI Requirements
- Show current leave type and current leave state.
- Show available allocations and remaining balance.
- Provide direct actions to open dashboard and calendar.

## Search and Filter Requirements
- Filter by employee, leave type, state, year, department, and accrual plan.
- Allow searching pending approvals and validated allocations.

## UX Acceptance Criteria
- Leave request flows must not require unnecessary navigation.
- HR users must be able to approve or refuse directly from the record.
- Configuration screens must expose the impact of changes before saving.
- Public-facing views must remain safe and minimal.
