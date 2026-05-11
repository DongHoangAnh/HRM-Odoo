# HR UI Spec

## Project Context (Context Discovery alignment)

- Interface language: Vietnamese by default for HR users; provide clear labels for teacher-specific fields (teaching hours, pay type).
- Ensure views expose teaching-hours input and payroll-relevant fields where HR or Finance roles need them, but keep those fields hidden from public/non-HR roles.
- Follow Odoo UI conventions and avoid core modifications; custom widgets should be included in `hrm_*` modules.

## UI Goals
- Make employee management fast for HR users.
- Keep public employee browsing simple and safe.
- Surface the most important actions from list, kanban, and form views.
- Keep sensitive actions behind role-appropriate buttons and views.

## Required Navigation
- Employees list / kanban / form.
- Departments kanban / list / form.
- Employee versions / contract form.
- Related contacts and bank account actions.
- Public employee form and kanban where appropriate.

## Employee View Requirements
- Form view must include core identity, work data, private HR data, and lifecycle fields.
- Employee list should support filters for department, company, newly hired, absent, and archived.
- Kanban should expose presence state and key work info.
- Form should expose action buttons for contact, version, archive, and related employee navigation.

## Department View Requirements
- Department kanban/list/form should show hierarchy, manager, employee count, and child departments.
- Department form should provide employee and activity plan shortcuts.
- Opening employees from department should respect user access and switch model when needed.

## Version and Contract UI
- Contract/version form should distinguish template mode from employee-backed version mode.
- Actions must open the correct target model depending on the viewer's access level.
- Effective dates, wage, structure, and contract status should be readable at a glance.

## Contact and Bank UI
- Related contacts action should open the linked partner record.
- Bank account forms should show employee allocation details.
- Non-HR users should see masked bank account display names.
- Salary allocation wizard should be reachable from bank records.

## Public UI
- hr.employee.public views must omit private HR-only fields.
- Public profile views should show safe presence, department, job, image, and activity data.
- Manager-only data should be computed conditionally.

## Interaction Patterns
- Search views must support company, department, presence, archive, and lifecycle filters.
- Context on actions must preserve default department, version, or employee references.
- Wizards should use clear defaults and not require redundant input.

## Empty States
- No employees: guide users toward creation.
- No departments: guide users toward department creation.
- No versions: show contract template or create-version entry points.
- No bank accounts: explain salary allocation setup.

## UX Acceptance Criteria
- Every high-value business action must be reachable in one or two clicks.
- Public users must never see private employee fields in any view.
- HR managers must be able to navigate from employee to contact, version, department, and bank records without losing context.
- Search and filters must match the access model, not just the raw data model.
