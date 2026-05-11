# Implementation Plan: Archive & Unarchive Employees

**Branch**: `005-archive-unarchive-employees` | **Date**: 2026-05-11 | **Spec**: specs/hr_specs/005-archive-unarchive-employees/spec.md
**Input**: Feature specification from `specs/hr_specs/005-archive-unarchive-employees/spec.md`

## Summary

Add robust archive/unarchive workflows for `hr.employee` to support safe departure processing and reactivation. Key behaviors:
- Archive employee (set `active=False`), archive linked resource, and set `presence_state='archive'`
- Clear subordinate `parent_id` and `coach_id` references where appropriate
- Show a departure wizard when archiving a single employee with exactly one subordinate (suppressable with `no_wizard` for bulk operations)
- Store departure metadata (`departure_date`, `departure_reason_id`, `departure_description`) and post a message when provided
- Allow unarchiving which clears departure metadata and restores `active=True`
- Prevent circular manager relationships

## Technical Context

**Language/Version**: Python 3.11 (preferred). Confirm repo patch level. (NEEDS CLARIFICATION)
**Primary Dependencies**: Odoo core (server + ORM). No external libraries required.
**Storage**: PostgreSQL via Odoo ORM.
**Testing**: Odoo unit/integration tests; map Gherkin scenarios to test cases. (NEEDS CLARIFICATION)
**Project Type**: Odoo add-on module or change within existing HR addon (e.g., `addons/hr_archive`).

## Assumptions

- `hr.employee` and `res.resource` are present and linked 1:1.
- Departure reasons (`departure.reason`) exist as reference data.
- Bulk archival operations provide `no_wizard` in the context to suppress the wizard.
- Contracts may remain active and should not block archival.

## Acceptance Criteria (mapped to feature scenarios)

- Archive active employee: `active` becomes False, resource archived, `presence_state='archive'`.
- Manager/subordinate handling: when archiving a manager, subordinate `parent_id` values are cleared; manager relationships remain for other records.
- Coach clearing: when a coach is archived, related employees have their `coach_id` cleared.
- Departure wizard: appears only when archiving a single employee with exactly one subordinate and `no_wizard` is not set.
- Bulk archival: selecting multiple employees with `no_wizard=True` archives all without showing wizards.
- Departure info: stored on archive and posted as a message when provided.
- Unarchive: clears departure fields and sets `active=True`.
- Circular manager prevention: system prevents creation of cycles in manager graph.
- Re-archiving: no error if already archived.

## Implementation Plan (high level)

1. Scaffolding
  - Implement changes inside existing HR addon or create `addons/hr_archive` with `models/`, `tests/`, and `data/`.
2. Model changes and fields
  - Ensure `hr.employee` has: `departure_date`, `departure_reason_id`, `departure_description`, `presence_state` (if not present).
  - Add helper methods: `archive_employee(self, context)` and `unarchive_employee(self)`.
3. Archive behavior
  - `archive_employee`: within a transaction:
    - If `no_wizard` not set and there is exactly one subordinate: launch departure wizard (UI) and collect departure metadata.
    - Set `active=False`, set `presence_state='archive'`.
    - Archive linked `res.resource` (set `active=False` or archive flag depending on model).
    - Clear `parent_id` on subordinate employees; clear `coach_id` on employees where coach == archived employee.
    - Store departure metadata if provided and post a message with `departure_description`.
    - If employee already archived, return gracefully.
4. Unarchive behavior
  - `unarchive_employee`: set `active=True`, clear `departure_date`, `departure_reason_id`, `departure_description`, and restore presence state as appropriate.
5. Relationship safety
  - Add checks to prevent circular manager relationships on write/create of `parent_id` using depth-first traversal or SQL constraint with trigger to detect cycles.
6. Bulk operations
  - Implement batch archival operation respecting `no_wizard` context and processing employees in a single transaction where possible; suppress wizard UI.
7. Tests
  - Unit tests for: single archive, manager-subordinate cleanup, coach cleanup, wizard display conditions, bulk archival, departure metadata storage and message posting, unarchive behavior, circular manager prevention, re-archive idempotency.
8. Data/migration and docs
  - Provide migration guidance if fields are missing; document API for invoking archive/unarchive and `no_wizard` flag.

## Testing Plan

- Map each Gherkin scenario to an Odoo unit/integration test. Include tests for concurrent archival and bulk operations performance expectations.
- Add tests for circular manager prevention covering varied chain lengths.

## Deliverables

- `addons/hr_archive/` or patch to existing HR addon (models, tests, manifest)
- Updated `specs/hr_specs/005-archive-unarchive-employees/{research.md,data-model.md,quickstart.md,contracts/}`
- Test suite validating all acceptance criteria

## Rollout & Migration Notes

- Archival operations should be backward-compatible: existing contracts remain unchanged.
- Backfill: none required unless departure metadata needs to be populated from external sources.
- Schedule bulk archival during low-traffic windows to reduce locking risk when clearing subordinate references.

## Open Questions (NEEDS CLARIFICATION)

- Confirm whether `presence_state` is already used in codebase and expected values for archived state.
- Confirm whether archiving should also disable related user accounts or keep them active for payroll/reporting.
- Confirm desired behavior for large manager trees when archiving a top-level manager (e.g., reassign vs clear `parent_id`).

---

