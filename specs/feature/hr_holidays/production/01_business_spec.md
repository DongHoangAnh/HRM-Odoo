# HR Leave Business Spec

## Goal
Build production time-off functionality that manages leave requests, allocations, accrual plans, employee leave status, and leave type policy in a way that matches Odoo-style HR workflows.

## Project Context (Context Discovery alignment)

- Scope is limited to five HR modules: Employee, Attendance, Leave, Payroll, and Recruitment.
- Teachers and TAs are stored in `hr.employee`; leave flows must support teaching-hour implications when payroll is configured to use teaching hours.
- Follow Odoo 19 constraints: do not modify core; implement customizations in `hrm_*` modules.
- Compliance: Vietnamese legal requirements for leave, data retention, and payroll interactions must be considered.

## Primary Users
- Employee
- HR User
- HR Manager
- HR Officer
- Approver / Manager
- System Administrator

## Core Business Capabilities

### Leave requests
- Create leave requests in day, half-day, or hour units.
- Validate leave balance and policy before approval.
- Support single-step and multi-step approval.
- Support refusal, cancellation, reset, and re-approval.
- Create calendar events for approved leave where configured.

### Leave allocations
- Allocate leave balances to employees or departments.
- Validate, refuse, and track allocation states.
- Track yearly allocations, carryover, and expiry.
- Allow unlimited leave types where configured.

### Accrual plans
- Build leave balances over time.
- Support milestone levels and date-based progression.
- Support carryover, cap, and validity policies.
- Process accrual plans over time and prevent unsafe deletion when in use.

### Employee leave status
- Show the employee's current leave type and state.
- Indicate absence, remaining balance, and leave manager.
- Expose dashboard and calendar entry points.

### Leave type policy
- Control whether allocation is required.
- Control request units and validation type.
- Control whether public holidays count.
- Control whether requests on top are allowed.
- Control accrual eligibility and negative caps.

## Production Outcomes
- Employees can request time off with understandable validation.
- HR can allocate and approve leave consistently.
- Accruals can be configured without losing track of balances.
- Leave policy changes remain safe and auditable.

## Acceptance Criteria
- Leave duration must compute correctly for day, half-day, and hour requests.
- Leave requests must not exceed available policy and balance.
- Multi-step approval must transition through the proper states.
- Accrual plans and levels must not allow unsafe zero-value or overlapping configurations.
- Leave type policy changes must not break existing leave history.
- Employee leave status must stay synchronized with validated leave records.
- Dashboard actions must present the correct filtered time-off data.
