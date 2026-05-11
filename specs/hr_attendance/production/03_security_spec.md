# HR Attendance Security Spec

## Project Context (Context Discovery alignment)

- Teaching hours may be provided by Operations; ensure security rules allow trusted integration users to write teaching-hours fields while preventing general user edits.
- Payroll-related attendance fields (validated_overtime_hours, teaching_hours) should be visible to HR and Finance roles but editable only by authorized attendance/HR managers.

## Security Goals
- Restrict overtime configuration to attendance managers and HR roles.
- Protect employee attendance data from unauthorized edits.
- Respect company and manager boundaries.
- Keep public exposure minimal.

## Roles
- System Administrator
- HR Manager
- HR Attendance Manager
- HR Attendance Officer
- Employee Self-Service User
- Read-only attendee or own-attendance user

## Access Rules

### hr.attendance
- Employees can access their own records where allowed.
- Attendance managers and HR managers can manage team attendance.
- Record rules must respect company boundaries.

### hr.attendance.overtime.line
- HR attendance managers can manage overtime lines.
- Officers can manage overtime lines for employees they supervise.
- Own-reader access should only allow reading of own overtime lines.

### hr.attendance.overtime.rule and ruleset
- Overtime rules and rulesets are configuration objects.
- Only attendance managers or HR managers should modify them.
- Ruleset regeneration must be restricted to authorized users.

### Company settings
- Overtime validation mode is a company-level setting.
- Only configuration-authorized users should change it.

## Field Protection Rules
- Overtime approval and rate fields are not for general users.
- Configuration fields must be restricted to manager/administrator groups.
- Manager flag computation must not grant write access.

## Record Rule Expectations
- Users should only see attendance and overtime data for allowed companies.
- Rulesets should not be editable outside the permitted company context.
- Read access to own overtime lines should not reveal unrelated employee overtime data.

## Action Security
- Approve/refuse actions must validate role and record scope.
- Regenerate overtime action must be protected.
- Public views of attendance should not expose policy internals.

## Audit Expectations
- Approval and refusal should remain traceable.
- Config changes should be visible in audit trails where mail.thread exists.
- Recompute workflows should not silently alter unauthorized records.
