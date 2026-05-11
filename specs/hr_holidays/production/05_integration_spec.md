# HR Leave Integration Spec

## Integration Goals
- Connect leave workflows with employee status, attendance, calendar, and downstream payroll/work-entry flows.
- Ensure accrual and allocation policy stays consistent with operational data.

## Integrations

### hr.employee and hr.employee.public
- Compute current leave state, absence, and leave manager.
- Expose safe leave data on public employee records.
- Keep employee leave dashboard data synchronized.

### hr.department
- Support department allocation actions.
- Derive department context for leave visibility and planning.

### calendar.event
- Create calendar events for approved leave where configured.
- Keep leave busy status and calendar presence consistent.

### resource.calendar and resource.calendar.leaves
- Use schedules for leave duration calculation.
- Respect public holidays and configured calendar leave rules.
- Support accrual calculations and carryover rules.

### hr_attendance
- Attendance presence and leave status must align.
- Leave may affect overtime and absence-related calculations.

### hr_work_entry / payroll
- Leave data should be usable by work-entry and payroll layers.
- Time off types and accrual eligibility must be compatible with downstream salary rules.

### mail / activities
- Approval notifications and reminders must be sent to the correct approvers.
- Expiring or policy-related reminders should be traceable.

## Event Contracts
- Leave approval must update balances and employee state.
- Leave refusal or cancellation must not deduct balances incorrectly.
- Allocation validation must update availability immediately.
- Accrual plan processing must add or carry over balances safely.
- Policy changes should never silently rewrite historical leave decisions.

## Cron and Batch Expectations
- Accrual and carryover processing should run safely in batch.
- Notification workflows should handle multiple employees and companies.
- Dashboard counts should remain performant on larger datasets.

## Production Readiness Checks
- Confirm leave request workflows match approval rules.
- Confirm accrual plan changes do not corrupt existing allocations.
- Confirm public employee views remain private-data safe.
- Confirm integrations with attendance and payroll remain deterministic.
