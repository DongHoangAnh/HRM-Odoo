# Data Model: Versions & Contracts

## Entities

- EmployeeVersion
  - `id` (pk)
  - `employee_id` (m2o -> hr.employee)
  - `versioned_at` (datetime)
  - `data_json` (json) — full snapshot of employee record
  - `author_id` (m2o -> res.users)
  - `reason` (text)

- ContractVersion
  - `id` (pk)
  - `contract_id` (m2o -> hr.contract)
  - `versioned_at` (datetime)
  - `data_json` (json)
  - `author_id` (m2o -> res.users)
  - `effective_date` (date)

- hr.contract (extended)
  - add `current_version_id` (m2o -> contract.version)
  - add `is_superseded` (bool)

## Relationships
- `hr.employee` 1..* `EmployeeVersion`
- `hr.contract` 1..* `ContractVersion`

## Validation Rules
- Restoring a version must validate unique constraints (no duplicate work contacts, etc.).
- Contract effective dates cannot overlap with active contracts for the same employee unless explicitly allowed.

## Notes
- Prefer `json` snapshot to simplify restore; later optimize to delta if storage concerns appear.
