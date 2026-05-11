# Implementation Plan: Manage Employee Information

**Branch**: `002-manage-employee-information` | **Date**: 2026-05-11 | **Spec**: specs/hr_specs/002-manage-employee-information/spec.md
**Input**: Feature specification from `specs/feature/hr/02_manage_employee_information.feature`

## Summary

Extend Odoo 19 HR employee management with comprehensive information updates: employee name synchronization to linked resource/contact records, auto-creation and smart syncing of work contacts (unique vs. shared), personal data fields (legal_name, birthday, place_of_birth, country_of_birth), timezone propagation to linked user, manager/coach assignment with company-domain constraints and auto-fallback, contract date versioning with open-ended contract handling, phone number normalization (E.164 format with country-based fallback), category management, departure tracking with timeline posts, image synchronization, and field change audit logging. Implement as `addons/hrm_employee_management` addon extending core `hr.employee` model.

## Technical Context

**Language/Version**: Python 3.11 (preferred; confirm patch level). Odoo 19 runtime supports 3.10+. (NEEDS CLARIFICATION on specific patch requirement)
**Primary Dependencies**: Odoo 19 core (hr, mail, web modules), PostgreSQL, optional `phonenumbers` library for phone formatting, standard ORM features.
**Storage**: PostgreSQL via Odoo ORM; no direct SQL allowed per project rules.
**Testing**: Odoo unit/integration tests; map Gherkin scenarios to test cases. (NEEDS CLARIFICATION on BDD runner availability)
**Project Type**: Odoo addon module (extend `hr.employee` via inheritance).
**Performance Goals**: Employee save/update flows complete within ~2s; bulk updates (10+ employees) within ~5s.
**Constraints**: No core modifications, ORM-only schema changes, use ACLs for role-based access control per project rules.md.

## Assumptions

- `hr.employee` model exists in Odoo core; enhancements via `_inherit`.
- `resource.resource` linked to employee exists and has `name` field synced from employee.
- Work contact uniqueness: a `res.partner` is unique to an employee if only one employee references it; shared if multiple employees reference it.
- Phone formatting uses `phonenumbers` library if available; fallback to basic E.164 attempt if not. (NEEDS CLARIFICATION on library availability)
- Timezone updates propagate to linked `res.users` record (if employee has user_id).
- Coach auto-fallback: if coach_id unset and manager changes, coach_id automatically set to new manager.
- Company move warning: display warning in UI but allow update (not prevented); recommendation to create new employee provided.
- Contract dates stored in version record (from feature 003); `is_in_contract` computed based on current date vs. version dates.
- Image synchronization: `image_1920` synced from employee to work contact when contact is unique to employee.
- Audit logging uses Odoo's built-in field tracking (`_track` dict) and `mail.thread`.

## Acceptance Criteria (mapped to feature scenarios)

1. **Update employee name**: Employee name updates sync to linked resource and create audit log entry.
2. **Update work contact details**: Phone normalized to international format, email stored; propagation only to unique contacts.
3. **Shared contact safety**: Multiple employees sharing contact; updates do NOT propagate to shared contact.
4. **Auto-create work contact**: Employee saved without contact; work contact automatically created and linked.
5. **Update personal information**: `legal_name`, `birthday`, `place_of_birth`, `country_of_birth` stored and accessible to employee.
6. **Update timezone**: Timezone updates; if linked user exists, user's timezone also updated.
7. **Update manager**: `parent_id` set; reverse `child_ids` reflects relationship; field tracked.
8. **Update coach**: `coach_id` set; coach must be from same company or company-agnostic.
9. **Auto-update coach on manager change**: No explicit coach; manager changes; coach auto-updates to new manager.
10. **Phone validation**: Invalid phone numbers formatted based on country; international fallback attempted.
11. **Company move warning**: Company change attempted; warning displayed; employee not moved automatically; recommendation to create new employee.
12. **Contract dates**: Contract dates stored in version; `is_in_contract` status updated.
13. **Open-ended contracts**: Empty contract end date allowed; `is_in_contract` returns False for dates after indefinite end.
14. **Category management**: Employees assigned multiple categories; filterable by category.
15. **Manager from same company only**: Manager domain validates same company or company-agnostic.
16. **Departure information**: Departure date, reason, description stored; message posted to employee timeline.
17. **Tracked field changes**: Multiple field updates logged; modification history accessible.
18. **Image update**: Profile image updated to `image_1920`; derived sizes computed; work contact image synced if unique.
19. **Work contact auto-linking**: New employee without explicit contact; contact auto-created and linked.
20. **Concurrent updates safety**: Multiple fields updated in single save; all tracked independently.

## Implementation Plan (high level)

1. **Extend hr.employee model**
   - Add/enhance fields: `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `work_phone`, `work_email`, `work_contact_id` (many2one res.partner), `coach_id` (many2one hr.employee), `departure_date`, `departure_reason_id`, `departure_description`.
   - Add computed field `is_in_contract` based on contract date version (depends on feature 003).
   - Add computed field `employee_count` for manager (inverse of parent_id).
   - Ensure `parent_id` (manager), `coach_id`, and key personal fields are tracked in `_track` dict.

2. **Implement name synchronization**
   - Override `write()` to detect `name` changes.
   - When name changes, update linked `resource.resource.name` (via resource_id foreign key).
   - Update work_contact.name if work_contact is unique to this employee.
   - Log change via `_track`.

3. **Implement work contact auto-creation**
   - Override `create()` to auto-create work contact if none provided.
   - Create `res.partner` with `name = employee.name`, `type = 'contact'`, `company_id = employee.company_id`.
   - Link to employee via `work_contact_id`.
   - Optionally set partner as delivery/invoicing address if needed. (NEEDS CLARIFICATION on contact type/purpose)

4. **Implement work phone/email sync with shared contact detection**
   - Add method `_is_work_contact_unique()`: query if work_contact_id linked to other employees; return True if unique, False if shared.
   - Override `write()` to detect `work_phone` and `work_email` changes.
   - If unique contact: update `work_contact_id.phone` and `work_contact_id.email`.
   - If shared contact: do NOT update contact; store only in employee fields.
   - Call `_normalize_phone()` before storing/syncing phone.

5. **Implement phone number normalization**
   - Add helper method `_normalize_phone(phone_str, country_code)`:
     - Use `phonenumbers` library if available to format to E.164 format based on country_code.
     - Fallback: attempt basic E.164 pattern (+CC-NNNNNNNNN).
     - Return normalized phone or original if normalization fails.
   - Call during phone field write; catch exceptions gracefully.

6. **Implement timezone propagation**
   - Override `write()` to detect `tz` (timezone) field changes.
   - If `user_id` linked: update `user_id.tz` to match employee timezone.
   - Validate timezone against available Odoo timezones. (NEEDS CLARIFICATION on validation source)

7. **Implement manager and coach assignment**
   - Add constraint `_check_manager_domain()`: manager must be in same company_id or company_id is null (company-agnostic).
   - Add constraint `_check_coach_domain()`: coach must be in same company_id or company_id is null.
   - Add constraint `_check_no_manager_self_loop()`: prevent manager = self.
   - Add constraint `_check_no_coach_self_loop()`: prevent coach = self.

8. **Implement auto-coach-fallback on manager change**
   - Override `write()` to detect `parent_id` (manager) changes.
   - If manager changed AND `coach_id` is null (not explicitly set): set `coach_id = new parent_id`.
   - If manager changed AND `coach_id` explicitly set to old manager: update `coach_id = new parent_id`.
   - Log via `_track`.

9. **Implement company move warning**
   - Override `write()` to detect `company_id` changes.
   - If company changes: log warning to employee record (message post or chatter notification).
   - Display message: "Changing company may affect linked contracts, permissions, and related records. Consider creating a new employee record instead."
   - Allow update (don't prevent); include recommendation link. (NEEDS CLARIFICATION on exact UI flow for warning)

10. **Implement contract versioning integration**
    - During employee save: if `contract_date_start` or `contract_date_end` provided, call feature 003 method to create/update contract version.
    - Compute `is_in_contract` as: `contract_date_start <= today <= contract_date_end` (or `contract_date_end is null` for open-ended).
    - Store contract dates in version record, not employee record directly. (NEEDS CLARIFICATION on whether to store start/end on employee for quick access)

11. **Implement category management**
    - Add `employee_category_ids` (many2many `hr.employee.category`).
    - Ensure categories are company-scoped or global per Odoo design. (NEEDS CLARIFICATION on category scoping)
    - Implement search/filter by category.

12. **Implement departure tracking**
    - Add fields: `departure_date`, `departure_reason_id` (many2one `hr.departure.reason`), `departure_description`.
    - Override `write()` to detect departure field updates.
    - When departure_description provided: post message to employee timeline (mail.thread) with description.
    - Include formatted timestamp and reason in message. (NEEDS CLARIFICATION on message format/template)

13. **Implement image synchronization**
    - Override `write()` to detect `image_1920` changes.
    - Call `_is_work_contact_unique()` to check if contact is unique.
    - If unique: update `work_contact_id.image_1920` to match employee image.
    - If shared: do NOT update contact image.
    - Handle image resizing/derivatives via Odoo's built-in image field mechanisms.

14. **Implement audit logging (field tracking)**
    - Add `_track` dict to `hr.employee` model:
      - Track fields: `name`, `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `tz`, `parent_id`, `coach_id`, `company_id`, `work_phone`, `work_email`, `image_1920`, `departure_date`, `departure_reason_id`, `departure_description`.
    - Use Odoo's `mail.thread` for change logging (automatic via `_track` if `mail.thread` inherited).
    - Implement `get_modification_history()` action to display log entries.

15. **Views & UI**
    - Create/extend form view with sections: Personal Info (legal_name, birthday, place_of_birth, country_of_birth), Contact (work_phone, work_email, work_contact_id), Relationships (parent_id/manager, coach_id), Company & Dates (company_id, contract_date_start/end, categories), Departure (departure_date, reason, description), Images (image_1920).
    - Add quick action buttons: "View Modification History", "Manage Categories", "Change Manager/Coach".
    - Add domain filters on manager/coach fields.

16. **Tests**
    - Unit tests for: name sync to resource/contact, work contact auto-creation, shared contact safety (no propagation), phone normalization (valid/invalid numbers), timezone propagation, manager/coach assignment (same company + company-agnostic), circular prevention (manager/coach = self), auto-coach-fallback on manager change, company move warning, contract version integration, category management, departure tracking with message post, image sync (unique vs. shared), audit logging (all tracked fields), edge cases (concurrent updates, empty fields, null relationships).
    - Integration tests for: full employee lifecycle (create → update personal → set manager → add categories → departure → archive).

17. **Security & ACL**
    - Define IR rules: HR Manager → full access to all fields, HR User → access to most fields except sensitive (NEEDS CLARIFICATION on field-level restrictions), non-HR → read-only access to hr.employee.public with restricted fields.
    - Restrict field visibility: personal data, departure info, manager/coach only visible to authorized roles.

## Testing Plan

- Map all 20 Gherkin scenarios to Odoo test methods.
- Include boundary tests: empty personal info, null manager/coach, shared vs. unique contacts, invalid phones, edge case timezones.
- Performance tests: bulk updates (50+ employees), concurrent saves, image processing on large images.
- Edge cases: duplicate names, special characters in phone/email, timezone conversion edge cases, contract date ranges with gaps.

## Data Model Overview

**hr.employee** (extended):
- `id` (int, auto)
- `name` (char, required)
- `legal_name` (char, optional)
- `birthday` (date, optional)
- `place_of_birth` (char, optional)
- `country_of_birth` (many2one res.country, optional)
- `work_phone` (char, normalized to E.164)
- `work_email` (email, validated)
- `work_contact_id` (many2one res.partner, optional, unique=False)
- `timezone` / `tz` (selection, validated)
- `parent_id` (many2one hr.employee, optional, manager)
- `coach_id` (many2one hr.employee, optional)
- `child_ids` (one2many hr.employee, inverse of parent_id)
- `company_id` (many2one res.company, required)
- `user_id` (many2one res.users, optional)
- `departure_date` (date, optional)
- `departure_reason_id` (many2one hr.departure.reason, optional)
- `departure_description` (text, optional)
- `image_1920` (binary, employee photo)
- `employee_category_ids` (many2many hr.employee.category)
- `is_in_contract` (boolean, computed)
- `resource_id` (many2one resource.resource, linked)
- Tracked fields: `name`, `legal_name`, `birthday`, `tz`, `parent_id`, `coach_id`, `company_id`, `work_phone`, `work_email`, `departure_*`, `image_1920`.

**res.partner** (work_contact):
- Linked via `hr.employee.work_contact_id`
- Fields: `name`, `phone`, `email`, `image_1920`, `type` (contact/delivery/invoice)
- Uniqueness: if referenced by multiple employees, treated as shared (no sync).

**hr.employee.category** (existing Odoo model):
- Used for employee classification and filtering.

**hr.version** (from feature 003):
- Stores versioned contract dates; `hr.employee.contract_date_start`, `contract_date_end` reference version.

## Deliverables

- `addons/hrm_employee_management/` addon with models, views, tests, manifest
- `specs/hr_specs/002-manage-employee-information/{research.md, data-model.md, quickstart.md, contracts/}` (Phase 1 artifacts)
- Test suite covering all 20 scenarios and edge cases
- Security group definitions and IR rules

## Rollout & Migration Notes

- Deploy during low-traffic window if modifying existing employee records.
- Data migration: backfill work contacts for existing employees without contacts.
- Phone formatting: batch normalize existing phone numbers; log any failures for manual review.
- Image sync: backfill work contact images if employee images exist and contacts are unique.
- Manager reassignment: ensure no circular manager relationships exist in data before deployment.
- Documentation: provide admin guide on phone formatting rules, timezone handling, departure workflows.

## Open Questions (NEEDS CLARIFICATION)

- Should phone normalization fail silently (keep original) or raise validation error?
- Is `phonenumbers` library installed in project? What is fallback formatting strategy?
- Should contract start/end dates be stored on employee record for quick access, or only in version?
- What is the exact format for departure message post (template, fields included)?
- Should changing company trigger employee archival/unarchival as safeguard, or only display warning?
- How should company move be prevented if there are linked contracts/versions in new company? (NEEDS CLARIFICATION on constraints)
- For work contact uniqueness detection, should we check across all companies or current company only?
- Should timezone validation use Odoo's standard timezone list or custom list?
- What is the fallback behavior if linked user doesn't exist during timezone update?
- For manager domain validation, should company-agnostic managers be allowed globally or per-company scope?
- Should coach auto-fallback behavior be configurable (feature flag)?
- What categories should be pre-loaded in demo data?

---
