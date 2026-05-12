# Implementation Plan: Create Employee

**Branch**: `001-create-employee` | **Date**: 2026-05-11 | **Spec**: specs/hr_specs/001-create-employee/spec.md
**Input**: Feature specification from `specs/feature/hr/01_create_employee.feature`

## Summary

Implement the Create Employee feature by extending Odoo's `hr.employee` behavior to ensure:
- Per-company unique user linking with a clear error on duplicates
- Automatic linked `resource` and initial `hr.version` creation
- Normalized international phone formatting for `work_phone` and `mobile_phone`
- Optional automatic creation of a work contact (partner) when permitted
- Preservation of creation order for bulk-imported employees

## Technical Context

**Language/Version**: Python 3.11 (preferred). Confirm repo policy for exact patch version. (NEEDS CLARIFICATION)
**Primary Dependencies**: Odoo core (server + ORM). Optional: `phonenumbers` for E.164 formatting. PostgreSQL for persistence.
**Testing**: Odoo unit/integration tests (server-side tests). Pytest integration optional depending on repo harness. (NEEDS CLARIFICATION)
**Target Platform**: Linux server for production; development on Windows via WSL is acceptable. (NEEDS CLARIFICATION)

## Assumptions

- There is an `hr.employee` model available to inherit without breaking other modules.
- `hr.version` model exists (or an equivalent versioning facility) to track employee state; if not, we'll add a lightweight `hr.version` model.
- The repository uses an `addons/` layout where new modules can be placed (we will create `addons/hr_employee`).
- Permissions: HR users have create permission for employees; contact creation permission is gated and checked at runtime.

## Acceptance Criteria (mapped to feature scenarios)

- Create basic employee: Employee is created, active, has resource record, default category color.
- User-linking: Employee links to `res.users` and `work_contact_id` points to the user's partner.
- Phone formatting: `work_phone` and `mobile_phone` are stored in international (E.164-like) format when parseable.
- Personal info: `legal_name`, `birthday`, and place/country of birth are stored and retrievable.
- Initial version: An initial `hr.version` is created and `current_version_id` points to it.
- Order preservation: Bulk creates preserve provided order and create unique resource records.
- Work contact: If user has permission, a partner record is created and linked.
- Duplicate user linking: Creating another employee with the same `user_id` in the same company fails with a clear error.
- Tags/timezone/barcode/pin across examples behave as expected (category_ids, tz, barcode, pin fields are stored).

## Implementation Plan (high level)

1. Scaffolding
	- Create Odoo add-on `addons/hr_employee` with manifest (`__manifest__.py`), `models/`, `tests/`, and `data/` dirs.
2. Data models
	- Add `models/hr_employee.py` that inherits `hr.employee` and:
	  - Adds/ensures fields: `legal_name`, `place_of_birth`, `country_of_birth`, `current_version_id`.
	  - On create: create a linked `resource.resource` entry and a first `hr.version` record; set `current_version_id`.
	  - Enforce uniqueness: SQL/ORM constraint or Python check to prevent duplicate `user_id` per company.
3. Phone normalization
	- Add utility to normalize phone numbers using `phonenumbers` when available; fall back to stored input and log warning if not parseable.
4. Work contact creation
	- If `work_contact_id` absent and user has contact creation permission, create partner and link it.
5. Bulk import ordering
	- Ensure create ordering via ORM sequence and document recommended import approach; write tests verifying order.
6. Tests
	- Unit tests for each acceptance criterion; integration tests for user-link duplicate and work contact creation.
7. Data/migration
	- Add data migration scripts if necessary to backfill `current_version_id` for existing employees.
8. Docs & quickstart
	- Update `quickstart.md` with install, upgrade, and migration steps. Add `contracts/employee-create.md` with API/usage notes.

## Testing Plan (tasks mapped to feature scenarios)

- Create unit tests for: basic create, user link, phone formatting, personal info, initial version, duplicate user prevention, category tags, timezone, barcode/pin, multi-company user reuse.
- Add an integration scenario that runs the feature's Gherkin scenarios (if repo uses a BDD test harness) or map them to Odoo test cases.

## Deliverables

- `addons/hr_employee/` module with models, tests, manifest, and sample data
- `specs/hr_specs/001-create-employee/{research.md,data-model.md,quickstart.md,contracts/employee-create.md}` updated
- Migration/backfill script (if required)

## Rollout & Migration Notes

- Backfill: If `current_version_id` doesn't exist for existing employees, provide a safe backfill that creates a version per existing employee and sets `current_version_id`.
- Upgrade: Add an `odoo` pre/post-install hook if needed for partner linking.

## Next Steps / Work Items

- Implement scaffolding and model changes (PR)
- Implement phone normalization utility and tests
- Implement work contact creation logic and permission checks
- Add migration/backfill (if required)
- Run tests and validate scenarios

## Open Questions (NEEDS CLARIFICATION)

- Confirm repository Python version policy (patch level).
- Confirm whether `hr.version` exists or needs to be added.
- Confirm preferred add-on naming and target `addons/` path.

---

