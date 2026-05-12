# Data Model: Archive and Unarchive Employees

## Entities

- hr.employee
  - `active` (boolean)
  - `presence_state` (selection, includes `archive`)
  - `parent_id` (m2o -> hr.employee)
  - `coach_id` (m2o -> hr.employee)
  - `departure_date` (date)
  - `departure_reason_id` (m2o -> departure.reason)
  - `departure_description` (text)

- departure.reason
  - `name` (char)
  - `active` (boolean)

- hr.employee.departure.wizard
  - `employee_id` (m2o -> hr.employee)
  - `departure_date` (date)
  - `departure_reason_id` (m2o -> departure.reason)
  - `departure_description` (text)
  - `no_wizard` (boolean, context-driven)

## Relationships
- One employee can have many subordinates through `parent_id`.
- One employee can have one coach through `coach_id`.
- Wizard is transient and used only for the archival action flow.

## Validation Rules
- Prevent cycles in manager relationships.
- Clearing on archive must affect subordinate records and coached employees, not the archived employee's own manager/coach.
- Unarchive must clear all departure fields.

## State Transitions
- active -> archived: set `active=False`, archive resource, clear related subordinate links, optionally open wizard.
- archived -> active: set `active=True`, clear departure metadata.
