# Implementation Plan: Manage Work Contacts & Bank Accounts

**Branch**: `004-manage-work-contacts-bank-accounts` | **Date**: 2026-05-11 | **Spec**: specs/hr_specs/004-manage-work-contacts-bank-accounts/spec.md
**Input**: Feature specification from `specs/feature/hr/06_work_contacts_and_bank_accounts.feature`

## Summary

Automatically create and maintain `work_contact` partner records for employees and provide robust bank account management with salary distribution rules. Key behaviors:
- Auto-create and link work contact when missing
- Sync phone/email from employee → work contact when contact is unique
- Prevent sync when contact is shared across employees
- Add/remove bank accounts, prevent duplicates, and maintain `salary_distribution` (fixed + percentage)
- Compute `is_trusted_bank_account`, `has_multiple_bank_accounts`, and `primary_bank_account_id`
- Filter bank account selection by work contact and company

## Technical Context

**Language/Version**: Python 3.11 (preferred). Confirm repo patch level. (NEEDS CLARIFICATION)
**Primary Dependencies**: Odoo core (server + ORM). No external libs required.
**Storage**: PostgreSQL via Odoo ORM.
**Testing**: Odoo unit/integration tests; map Gherkin scenarios where BDD harness exists. (NEEDS CLARIFICATION)
**Project Type**: Odoo add-on module (e.g., `addons/hr_work_contacts_bank_accounts`).

## Assumptions

- `res.partner` represents contacts and `bank.account` (or equivalent) exists and links to partners.
- `salary_distribution` is modeled as child records on `hr.employee` with fields: `sequence`, `amount`, `is_percentage`, and `bank_account_id`.
- Work contact uniqueness can be determined by whether `work_contact_id` is referenced by only one employee.

## Acceptance Criteria (mapped to feature scenarios)

- Work contact auto-creation: saving an employee without `work_contact_id` creates a partner with the employee's name and links it.
- Sync phone/email: when `work_contact_id` is unique, updates to `work_phone`/`work_email` update the partner.
- No sync for shared contacts: when a partner is referenced by multiple employees, updates do not propagate to the partner.
- Bank account add/remove: `bank_account_ids` updated; `salary_distribution` recalculated on adds/removes.
- Salary distribution single account: 100% assigned, sequence = 1.
- Salary distribution multiple accounts: percentages auto-split (e.g., 3 accounts → ~33.33% each) and ordered by sequence.
- Fixed+percentage mix: fixed amounts preserved; percentages distributed over remaining amount and ordered after fixed amounts.
- Percentage validation: percentage-only distributions must total 100% or raise validation error; fixed amounts exempt.
- Empty distribution allowed: no error when distribution empty.
- Duplicate bank prevention: duplicate account additions result in a single instance being kept.
- Trusted account detection and primary selection behaviors per spec.
- Bank account domain filters by `work_contact_id` and employee `company_id`.

## Implementation Plan (high level)

1. Scaffolding
  - Create `addons/hr_work_contacts_bank_accounts` with `__manifest__.py`, `models/`, `tests/`, and `data/`.
2. Models & Fields
  - Extend `hr.employee`:
    - `work_contact_id` (many2one res.partner)
    - `bank_account_ids` (one2many to `bank.account` through linking model or relation)
    - `salary_distribution` (one2many child model `hr.employee.bank.distribution`)
    - computed fields: `is_trusted_bank_account`, `has_multiple_bank_accounts`, `primary_bank_account_id`
  - `hr.employee.bank.distribution` fields: `sequence`, `bank_account_id`, `amount`, `is_percentage`.
3. Work contact behaviors
  - On employee save (create/write): if `work_contact_id` empty -> create partner with employee name and link.
  - On `work_phone`/`work_email` change: if `work_contact_id` is unique (only referenced by this employee) -> update partner fields; otherwise skip.
  - When `work_contact_id` changes: update linked bank accounts to the new partner and reset trusted flags as required.
4. Bank account behaviors
  - Add: append bank account to `bank_account_ids`; if duplicate, ignore and log.
  - Remove: remove from `bank_account_ids`; recalculate percentages across remaining percentage-based lines to total 100%.
  - On add/remove: auto-synchronize `salary_distribution` (distribute percentages evenly across percentage lines after fixed amounts).
  - Validation: on save, if there are percentage-only lines, ensure sum == 100%; otherwise raise `ValidationError` with clear message.
5. Salary distribution logic
  - Preserve sequence: fixed amounts ordered before percentages.
  - When mixing fixed and percentage: compute remaining percentage base after fixed amounts and allocate percentages accordingly.
6. Domain and UI helpers
  - Provide domain for bank account selection: accounts linked to `work_contact_id` AND account.company_id == employee.company_id (or no company).
7. Tests
  - Unit tests for each acceptance criterion and edge case: auto-create contact, sync rules, shared contact protection, add/remove bank accounts, distribution validation and redistribution, duplicate prevention, trusted detection, domain filtering.
8. Data/migration & docs
  - Provide migration scripts if bank relations differ in existing schema.
  - Update `quickstart.md` and `contracts/` with API/schema notes.

## Testing Plan

- Convert each Gherkin scenario into an Odoo unit/integration test. Include property tests for distribution math.
- Add tests for concurrent updates to avoid race conditions when multiple employees share a work contact.

## Deliverables

- `addons/hr_work_contacts_bank_accounts/` module (models, tests, manifest, sample data)
- Updated `specs/hr_specs/004-manage-work-contacts-bank-accounts/{research.md,data-model.md,quickstart.md,contracts/}`
- Test suite covering distribution math and sync rules

## Rollout & Migration Notes

- If existing partners are used as work contacts, provide a migration that links employees to existing partners when appropriate.
- Redistribution and validation should be applied at model-level to avoid UI inconsistencies during upgrade.

## Open Questions (NEEDS CLARIFICATION)

- Confirm the canonical `bank.account` model name and fields (e.g., `allow_out_payment`).
- Confirm how `salary_distribution` fixed amounts interact with payroll calculation (gross vs net basis).
- Confirm whether duplicate detection should dedupe by bank account ID only or also by account number.

---

