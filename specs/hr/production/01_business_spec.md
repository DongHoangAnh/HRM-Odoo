# HR Business Spec

## Goal
Build the HR core for an education company on Odoo 19, focused on employee master data, contracts, attendance, leave, payroll, and recruitment.

## Project Context (Context Discovery alignment)

- Scope is limited to five HR modules: Employee, Attendance, Leave, Payroll, and Recruitment.
- Target domain: an education company where teachers and teaching assistants (TAs) are managed as `hr.employee` (no separate models for teachers).
- Teacher payroll may require a separate salary structure (e.g., hourly / per-class pay) in addition to office staff structures.
- Technical constraints: Odoo 19, do not modify core; custom modules prefixed consistently (e.g., `hrm_...`).
- Legal / payroll constraints (Vietnam): social insurance, health insurance, unemployment insurance, PIT (7 tax brackets), and statutory family/personal deductions must be supported, not hard-coded.
- Priority order: employee master data → attendance / teaching hours → leave → payroll → recruitment.

## Primary Users
- HR User
- HR Manager
- HR Officer
- Employee
- System Administrator

## Core Business Capabilities

### Employee master data
- Create and maintain employee records in `hr.employee`.
- Keep teachers and TAs inside `hr.employee`, not separate models.
- Link an employee to a user, a work contact, a department, a job, a manager, and a contract.
- Track private and work-facing profile data separately.
- Support employee categories, work location, and timezone.

### Contract and lifecycle
- Keep one active contract or version context per employee.
- Support contract history without losing old records.
- Track current, past, future, and in-contract states.
- Prevent overlapping contract periods for the same employee.
- Notify HR on contract expiry.

### Attendance
- Record check-in and check-out.
- Compute worked hours, overtime, and teaching hours.
- Support manual attendance when device integration is not available.
- Keep attendance usable for payroll calculation.

### Leave
- Manage leave types, allocations, requests, and balances.
- Support approval workflow.
- Feed approved leave into payroll logic when needed.

### Payroll
- Define separate salary structures for office staff and teachers.
- Support monthly payroll.
- Calculate gross, net, insurance, PIT, allowances, and teaching-hour pay when configured.
- Export payroll output for Finance.

### Recruitment
- Manage job positions, applicants, stages, sources, offers, and onboarding.
- Convert hired applicants into employees.

## Production Outcomes
- HR users can maintain employee data without breaking contract history.
- Teachers and TAs are treated as employees inside the same HR data model.
- Attendance, leave, and payroll stay connected.
- Payroll output can be handed to Finance in a consistent format.

## Acceptance Criteria
- An employee can be created with required company and role context.
- Teachers and TAs remain inside `hr.employee`.
- No employee may end up with overlapping active contracts.
- Attendance can be used as payroll input.
- Sensitive employee fields stay protected from non-HR users.
