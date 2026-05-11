# HR Integration Spec

## Integration Goals
- Keep HR data synchronized with related Odoo apps.
- Define the contract between HR core and downstream modules.
- Ensure generation, notification, and access flows remain consistent across apps.

## Integrations

### res.users
- Create employees from users.
- Sync allowed HR fields from user writes.
- Sync employee fields into user-facing preferences when allowed.
- Keep employee/company mapping stable.

### mail and discuss
- Send notifications for sensitive personal information updates.
- Notify HR responsible users for expiring contracts and permits.
- Support message tracking for important employee changes.
- Preserve activity and follower handling on lifecycle events.

### hr_attendance
- Provide employee presence data and attendance link points.
- Support overtime derivation from attendance records.
- Expose employee timezone and working hour context.

### Project Context (Context Discovery alignment)

- Operations may supply teaching hours; HR attendance integration must accept and reconcile teaching hours coming from external scheduling systems.
- Payroll export format must be agreed with Finance (CSV/Excel layout) and support required Vietnamese payroll fields (insurance IDs, PIT flags, deductions).
- Keep integrations idempotent and namespaced under `hrm_*` custom modules; do not modify Odoo core integration points.

### hr_holidays
- Provide leave manager relations, absent status, and dashboard data.
- Support employee status updates when the employee is on leave.
- Keep time-off and contractual working time aligned.

### hr_work_entry and payroll-related flows
- Provide version and contract inputs used by work entry generation.
- Feed employee, calendar, and contract data into work entry creation.
- Ensure date changes can trigger work entry cleanup or recompute.

### hr_recruitment
- Allow applicants to become employees.
- Preserve job, department, and recruiter context during onboarding.
- Let recruitment create users or employees as part of hiring flows.

### calendar and activities
- Support departure reminders and expiring-document activities.
- Keep department activity plans and calendar actions in sync.

### accounting / bank setup
- Provide salary allocation data to payment flows.
- Keep bank account data ready for payroll or settlement processing.

## Event Contracts
- Employee creation must emit the expected linked resource and work contact state.
- User write events must propagate to employee records only for allowed fields.
- Department manager changes must update dependent employee manager links.
- Contract start/end changes must invalidate or recompute dependent work data.
- Archive and offboarding events must preserve traceable history.

## Cron and Background Jobs
- Contract/permit expiry notifications.
- Work entry regeneration for contract changes or missing periods.
- Potential future cleanup or reconciliation tasks.

## Integration Rules
- Cross-module writes must be idempotent.
- No integration should expose private employee data to public channels.
- Multi-company context must be preserved in every sync.
- Any downstream module should be able to rely on these HR contracts without re-deriving hidden business rules.

## Production Readiness Checks
- Verify related modules do not break when employee records are archived.
- Verify hiring still works when recruitment hands off to employee creation.
- Verify leave and attendance status reflect the employee lifecycle correctly.
- Verify work entry generation handles changes in version, calendar, and company context.
