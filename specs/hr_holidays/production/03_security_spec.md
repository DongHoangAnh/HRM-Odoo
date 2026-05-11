# HR Leave Security Spec

## Security Goals
- Protect private leave information.
- Restrict approval and allocation workflows to the correct HR roles.
- Allow employees to see only what they are allowed to see.
- Preserve company and manager boundaries.

## Roles
- System Administrator
- HR Manager
- HR Officer
- Leave Approver / Manager
- Employee Self-Service User
- Public / Non-HR User

## Access Rules

### hr.leave
- Employees can manage their own requests within policy.
- Managers can approve or refuse subordinate leave where allowed.
- HR officers can manage allocations and validation workflows.

### hr.leave.type
- Configuration is HR controlled.
- Visibility rules for dashboard and policy fields must be enforced.

### hr.leave.allocation
- HR manages allocations.
- Employees can only interact with their own allocations where permitted.
- Department allocation actions must remain scoped.

### hr.leave.accrual.plan and level
- Accrual configuration must be restricted to HR managers.
- Unsafe configurations must be blocked regardless of client behavior.

### Employee leave status
- Public employee views must not reveal private leave notes.
- Non-HR users must only see the leave fields intended for them.

## Field Protection Rules
- private_name and other sensitive leave notes are HR-only.
- leave approval fields should not be writable by unauthorized users.
- leave type policy controls must be manager-only.
- accrual caps and validity settings are configuration-only.

## Record Rule Expectations
- Employees should only access their own leave records unless role permissions expand access.
- Department and manager-based leave visibility must respect company boundaries.
- Public employee leave projection must remain safe and read-only.

## Action Security
- Approve, refuse, cancel, back-to-approval, and validate actions must check permissions.
- Allocation validation and refusal must check permissions.
- Accrual plan deletion must block used plans.
- Dashboard and calendar actions must not bypass record rules.

## Audit Expectations
- Approvals and refusals should remain traceable.
- Allocation and accrual changes should be auditable.
- Policy changes must not silently mutate protected historical leaves.
