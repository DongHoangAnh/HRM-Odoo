# Implementation Plan: Manage Employee Versions & Contracts

**Branch**: `003-manage-versions-contracts` | **Date**: 2026-05-11 | **Spec**: specs/feature/hr/03_manage_versions_and_contracts.feature
**Input**: Feature specification from `specs/feature/hr/03_manage_versions_and_contracts.feature`

## Summary

Provide a robust employee versioning system (`hr.version`) and contract-date management so HR can:
- Create and retrieve employee versions by date
- Maintain a computed `current_version_id` (cached/stored for performance)
- Create and link contracts to versions with proper start/end semantics
- Prevent duplicate versions for the same `date_version` and synchronize `contract_date_end` across related versions

## Technical Context

**Language/Version**: Python 3.11 (preferred). Confirm repository policy for exact patch level. (NEEDS CLARIFICATION)
**Primary Dependencies**: Odoo core (server + ORM). No external dependencies required.
**Storage**: PostgreSQL via Odoo ORM.
**Testing**: Odoo unit and integration tests. BDD mapping available; consider using existing Gherkin runner if present. (NEEDS CLARIFICATION)
**Target Platform**: Odoo server environment (Linux production; development on WSL or native Windows supported). (NEEDS CLARIFICATION)
**Project Type**: Odoo add-on module (e.g., `addons/hr_versions_contracts`).
**Performance Goals**: Compute `current_version_id` efficiently for read-heavy views; store computed value and invalidate on relevant writes. (NEEDS CLARIFICATION for load targets)

## Assumptions

- `hr.employee` exists and can be safely extended.
- A new model `hr.version` will be introduced if not already present.
- Contracts are represented by either `hr.contract` or will be modeled alongside `hr.version`; the plan assumes `hr.contract` exists or is introduced to represent employment contracts.
- The repository follows an `addons/` layout where new modules can be placed.

## Acceptance Criteria (mapped to feature scenarios)

- Initial version: Creating an employee creates an initial `hr.version` dated today and sets `current_version_id`.
- New version creation: Creating a version with `date_version` creates a `hr.version` record copying previous version data when applicable.
- Contract creation: Creating a contract on a version records `contract_date_start` and `contract_date_end` per rules.
- Version lookup: Getting version for a date returns the nearest previous `date_version` (e.g., 2024-08-15 → 2024-06-01).
- Current version: `current_version_id` resolves to the latest `date_version` and is stored for performance.
- Duplicate date handling: Creating a version with an existing `date_version` returns the existing version rather than creating a duplicate.
- Contract range queries: Methods return correct (start,end) tuples and boolean contract membership for a given date.
- Synchronization: Creating/updating versions with same `contract_date_start` updates `contract_date_end` consistently across versions.
- Permanent contracts: `contract_date_end = False` denotes permanent contract and `in_contract` checks treat it as always active.

## Implementation Plan (high level)

1. Scaffolding
  - Create `addons/hr_versions_contracts` with `__manifest__.py`, `models/`, `tests/`, and `data/`.
2. Models
  - Add `models/hr_version.py` defining `hr.version` with fields:
    - `employee_id` (many2one hr.employee)
    - `date_version` (date)
    - `contract_date_start` (date)
    - `contract_date_end` (date | False)
    - `contract_wage`, `resource_calendar_id`, and other copied fields
    - `is_permanent` computed from `contract_date_end` being False
  - Add/extend `hr.employee` to include `current_version_id` (many2one hr.version) and helper compute methods.
3. Core behaviors
  - On employee create: create initial `hr.version` with `date_version = today` and set `current_version_id`.
  - Creating a version: if a version with the same `employee_id` and `date_version` exists, return it; otherwise create and copy relevant fields from the previous version.
  - Implement `get_version_for_date(employee, date)` to return the version with the greatest `date_version` <= date.
  - Implement `compute_current_version()` to find the latest `date_version` and store it on `hr.employee.current_version_id`. Invalidate/store on version create/update/delete and on date change signals.
4. Contract helpers
  - Implement helpers: `is_in_contract(employee, date)`, `get_contract_ranges(employee)`, `get_contract_for_date(employee, date)`, and `get_first_contract_date(employee, no_gap=False, gap_days=4)`.
  - When creating a new version with a `contract_date_start`, update the `contract_date_end` of previous versions as required (ensure transactions and locking to avoid races).
5. Synchronization rules
  - Ensure a single source-of-truth for `contract_date_end` by using transactional updates and database constraints where appropriate.
6. Performance
  - Index `hr.version(employee_id, date_version)` and add an index on `contract_date_start`/`contract_date_end` for range queries.
  - Cache `current_version_id` on employee and write tests to verify invalidation behavior.
7. Tests
  - Unit tests for: initial version creation, version creation with copy semantics, get_version_for_date, compute_current_version, is_in_contract, get_contract_ranges, duplicate date handling, synchronization of `contract_date_end`, permanent contract handling.
8. Data/migration
  - Provide backfill script: for employees without versions, create a single `hr.version` from current employee fields with `date_version` = first known employment date or today.

## Testing Plan

- Map each Gherkin scenario to an Odoo unit or integration test.
- Add tests for concurrency: simultaneous version creation for same date should not create duplicates (use DB constraints or retry logic).
- Add performance tests for `compute_current_version` on large numbers of versions if needed.

## Deliverables

- `addons/hr_versions_contracts/` module with models, helpers, tests, manifest, and migrations/backfills
- `specs/hr_specs/003-manage-versions-contracts/{research.md,data-model.md,quickstart.md,contracts/}` updated
- Test suite covering all acceptance criteria

## Rollout & Migration Notes

- Backfill existing employees with a version if none exist.
- Add DB indexes during upgrade to avoid migration-time performance issues.
- Carefully schedule the `compute_current_version` backfill to avoid heavy locking on large datasets.

## Open Questions (NEEDS CLARIFICATION)

- Confirm whether `hr.contract` model is already present in the codebase and its fields (if present, adapt integration).
- Confirm acceptable gap threshold for `no_gap` logic (default used here: 4 days).
- Confirm repository Python patch level and test harness (BDD runner availability).

---

