# Implementation Plan: Notify Expiring Contracts and Work Permits

**Branch**: `006-notify-expiring-contracts-permits` | **Date**: 2026-05-11 | **Spec**: specs/feature/hr/09_notify_expiring_contracts_permits.feature
**Input**: Feature specification from `specs/feature/hr/09_notify_expiring_contracts_permits.feature`

## Summary

Implement a daily scheduled job that detects employee contract and work-permit expirations per-company notice periods and creates `mail.activity` notifications for the responsible HR users. The job must avoid duplicates, skip permanent/expired records, and support multi-company configurations.

## Technical Context

- Target: Odoo 19, Python 3.11+ (confirm repo patch level). (NEEDS CLARIFICATION)
- Implement as an Odoo add-on, e.g., `addons/hr_notifications_expiry`, using ORM inheritance and `ir.cron` for scheduling.
- Primary Odoo services: `hr.employee`, `hr.contract` (if present), `mail.activity`, `res.company` configuration fields.
- Storage: PostgreSQL via Odoo ORM.
- Testing: Odoo unit/integration tests; map Gherkin scenarios to tests. (NEEDS CLARIFICATION whether the repository has a BDD runner.)

## Assumptions

- Company-level settings exist or will be added: `contract_expiration_notice_period` (days) and `work_permit_expiration_notice_period` (days).
- Employee fields used: `contract_date_end`, `work_permit_expiration_date`, `hr_responsible_id`.
- Duplicate detection is done by searching existing `mail.activity` for the same employee, activity type, and deadline.
- Cron runs once daily; timezone handling uses company timezone where appropriate.

## Acceptance Criteria (mapped to feature scenarios)

- Activities created when expiration date equals (today + company_notice_days) for contract and permit respectively.
- Activity title includes employee name and type (contract/work permit) and deadline equals expiration date.
- Activities assigned to `hr_responsible_id` when set; otherwise assigned to current/backup user.
- No activity created for expired records, permanent contracts, or records outside the notice window.
- No duplicate activities created across repeated cron runs.
- Multi-company notice periods are respected.

## Implementation Plan (high level)

1. Scaffolding
	- Create `addons/hr_notifications_expiry` with `__manifest__.py`, `models/`, `data/`, and `tests/`.
2. Configuration
	- Add company fields (in `res.company`):
	  - `contract_expiration_notice_period` (integer, days, optional)
	  - `work_permit_expiration_notice_period` (integer, days, optional)
	- Provide defaults and UI to configure per company.
3. Core cron job
	- Implement `models/cron.py` or `models/hr_notifications.py` with method `cron_notify_expirations(cron_args=None)`:
	  - Query employees per company where `contract_date_end` is not False and contract_date_end == (today + notice_days).
	  - Query employees per company where `work_permit_expiration_date` is not False and equals (today + permit_notice_days).
	  - For each matching event, call helper to create activity.
	- Use company timezone and date arithmetic carefully (use `fields.Date` or timezone-aware conversions as needed).
4. Activity creation helper
	- Implement `_create_expiration_activity(employee, expiration_date, type)`:
	  - Determine activity type: use `mail.mail_activity_data_todo` or configured activity type id. (NEEDS CLARIFICATION)
	  - Determine assignee: `hr_responsible_id` or fallback to configured default user.
	  - Prevent duplicates by searching `mail.activity` for matching `res_model='hr.employee'`, `res_id`, `activity_type_id`, and `date_deadline`.
	  - Create activity with `mail_activity_quick_update` context and proper summary/title.
5. Duplicate prevention
	- Use a unique query (employee + expiration date + expiry type) to skip creation when a matching activity exists.
	- Optionally mark created activities with a custom tag or `note` to ease searching.
6. Edge cases & rules
	- Skip permanent contracts where `contract_date_end` is False.
	- Skip contracts with missing end date or invalid ranges.
	- Support multi-company runs by grouping employees by `company_id` and using that company's notice period.
7. Indexes & performance
	- Ensure indexes on `hr.employee(contract_date_end)`, `hr.employee(work_permit_expiration_date)`, and `mail.activity` lookup fields to keep cron under target duration.
8. Tests
	- Unit tests for: detection logic per company, activity creation, duplicate prevention, assignment fallback, permanent/expired skip, multi-company behavior.
	- Integration tests simulating daily cron runs and asserting activities created/not created as per scenarios.
9. Backfill & quickstart
	- Provide optional backfill script to create activities for imminent expirations during upgrade.
	- Document cron schedule, configuration steps, and how to run the job manually for testing.

## Testing Plan

- Map each Gherkin scenario to a unit/integration test; include boundary-day tests (e.g., 29/30/31 days).
- Add tests to ensure duplicate activity prevention across multiple cron runs.

## Deliverables

- `addons/hr_notifications_expiry/` module with models, cron, tests, and sample data
- `specs/hr_specs/006-notify-expiring-contracts-permits/{research.md,data-model.md,quickstart.md,contracts/}` updated
- Test suite covering acceptance criteria and edge cases

## Rollout & Migration Notes

- Deploy during low-traffic window if backfilling many activities to avoid notification spam.
- Default cron frequency: daily; provide guidance to increase frequency if required.
- If company notice fields are empty, cron should skip that company (or use explicit default if instructed).

## Open Questions (NEEDS CLARIFICATION)

- Are notice periods measured in calendar days or working days? (affects calculation)
- Which activity type id should be used exactly (`mail.mail_activity_data_todo` assumed)?
- What is the fallback user when `hr_responsible_id` is not set (current user vs company HR fallback)?
- Should the cron respect employee `active` status (skip inactive employees) or include them if dates are in future?

---

