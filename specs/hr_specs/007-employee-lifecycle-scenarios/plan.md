# Implementation Plan: Employee Lifecycle and Scenario Management

**Branch**: `007-employee-lifecycle-scenarios` | **Date**: 2026-05-11 | **Spec**: specs/feature/hr/11_lifecycle_and_scenarios.feature
**Input**: Feature specification from `specs/feature/hr/11_lifecycle_and_scenarios.feature`

## Summary

Enhance HR employee management with lifecycle features: onboarding congratulations + wizard link, demo scenario data (departments, employees, categories) with duplicate prevention, role-based form views (public vs HR), auto-generated SVG avatars, field change audit logging, departure notifications, related contacts navigation, birthday visibility control, and department channel auto-subscriptions. Implement across Odoo 19 as `addons/hrm_employee_lifecycle`.

## Technical Context

**Language/Version**: Python 3.11 (preferred). Confirm repo patch level. (NEEDS CLARIFICATION)
**Primary Dependencies**: Odoo core (server, ORM, mail, web), `hr.employee` model, `res.partner`, `mail.channel`.
**Storage**: PostgreSQL via Odoo ORM.
**Testing**: Odoo unit/integration tests; map Gherkin scenarios to test cases. (NEEDS CLARIFICATION on BDD runner availability)
**Project Type**: Odoo add-on module (`addons/hrm_employee_lifecycle`).

## Assumptions

- `hr.employee` and `hr.employee.public` (read-only variant) will be used for role-based access.
- Demo data is stored as XML and loaded via `_load_demo_data()` method; duplicate detection uses name/code matching.
- SVG avatar generation uses initials + deterministic color hash based on employee name.
- Department channel auto-subscription uses standard Odoo `mail.channel` APIs.
- Newly hired threshold is configurable (e.g., last 30/90 days); defaults to 30 days.
- Audit logging uses Odoo's built-in field tracking (`_track_visibility`, `track_visibility`).
- Birthday visibility is a user preference; defaults to hidden for privacy compliance.

## Acceptance Criteria (mapped to feature scenarios)

- Onboarding: congratulations message shown on new employee create with link to wizard.
- Demo data: load departments, employees, categories from XML; recognize and skip existing demo data on repeated runs.
- Form access: non-HR users see `hr.employee.public` form with restricted fields; HR users see full `hr.employee` form.
- Avatars: auto-generate SVG for new employees without images; apply to both employee and work contact; preserve existing images.
- Audit: all tracked fields logged with user, old/new values, and timestamp; history accessible via modification history view.
- Departure: message posted to employee timeline when departure description provided during archival.
- Related contacts: display kanban/list when multiple exist; open form directly when single; compute count correctly (0, 1, or 2+).
- Birthday display: compute "DD Month" string when public; "hidden" when private.
- Channel subscription: auto-subscribe to department channels on create and update; handle department moves.
- Newly hired filter: return employees by creation date threshold.
- Version context: support version_id in context for field access; handle new draft mode correctly.

## Implementation Plan (high level)

1. Scaffolding
   - Create `addons/hrm_employee_lifecycle` with `__manifest__.py`, `models/`, `wizards/`, `views/`, `security/`, `data/`, and `tests/`.
2. Onboarding & congratulations
   - Override `hr.employee.create()` to display congratulations message (banner or pop-up) with link to onboarding wizard.
   - Implement onboarding wizard in `wizards/onboarding.py` with guided setup steps.
3. Demo data & scenarios
   - Create `data/demo_scenario.xml` with sample departments, employees, and categories.
   - Implement `_load_demo_data()` method in `models/employee.py`:
     - Query for existing demo entries by name/code to detect duplicates.
     - Load XML if no duplicates found; skip gracefully if data exists.
4. Role-based form access
   - Create `hr.employee.public` model (inherit `hr.employee` with restricted fields).
   - Override `get_formview_action()` and `get_formview_id()` in `hr.employee`:
     - Return public form for non-HR users; full form for HR users.
     - Apply record rules (IR rules) to restrict field visibility per role.
5. Avatar generation
   - Implement `_generate_avatar(name)` helper to create SVG based on initials + color hash.
   - Override `hr.employee.create()` and `write()` to auto-generate avatar when:
     - Employee has no image AND no linked user with image.
     - Apply same avatar to `work_contact_id` if set.
     - Preserve existing images (don't overwrite if image field already filled).
6. Audit logging & change tracking
   - Add `_track` dict to `hr.employee` model specifying tracked fields.
   - Use Odoo's built-in `track_visibility` to log changes to mail.thread.
   - Implement `get_modification_history()` action to display log entries.
7. Departure notifications
   - Hook into `archive_employee()` (from feature 005) to post departure description as message.
   - Include departure description in message body and link to employee timeline.
8. Related contacts & metadata
   - Add computed field `related_partners_count`: count of work_contact_id + user.partner_id (non-null).
   - Implement `action_related_contacts()`:
     - If count == 0: show notification "no related contacts".
     - If count == 1: open form view of that contact directly.
     - If count > 1: open kanban/list view of all related contacts.
   - Add computed field `birthday_public_display_string`:
     - If `birthday_public_display=True` and birthday set: return "DD Month" format.
     - Otherwise: return "hidden".
9. Channel subscriptions
   - Add `channel_ids` to `department` model with auto-subscribe flag.
   - Override `hr.employee.create()` and `write()` to auto-subscribe when:
     - Employee created in or moved to a department with auto-subscribe channels.
     - Use standard `mail.channel.subscribe()` API.
10. Newly hired filtering
    - Add `newly_hired` computed field based on `create_date` (within last 30/90 days, configurable).
    - Implement search/filter logic for `newly_hired=True` queries.
11. Version context handling
    - Support `version_id` in context during field access and searches.
    - Handle draft mode for new employees with version fields.
12. Tests
    - Unit tests for: congratulations message, demo data loading + duplicate prevention, form access control, avatar generation and preservation, audit logging, change history, related contacts (0/1/many), birthday display, channel subscriptions, newly hired filter, version context.
    - Integration tests for end-to-end workflows (create employee → onboard → move → archive).
13. Data & migrations
    - Demo data XML: `data/demo_scenario.xml` with sample departments/employees/categories.
    - Provide migration if adding new fields to existing models.
    - Document security groups and field-level access rules.

## Testing Plan

- Map each Gherkin scenario to an Odoo unit/integration test.
- Include boundary tests (avatar generation with/without user image, related contacts edge cases).
- Add performance tests for demo data load and bulk channel subscriptions if needed.

## Deliverables

- `addons/hrm_employee_lifecycle/` module (models, wizards, views, tests, manifest, demo data)
- `specs/hr_specs/007-employee-lifecycle-scenarios/{research.md,data-model.md,quickstart.md,contracts/}` updated
- Test suite covering all acceptance criteria and edge cases

## Rollout & Migration Notes

- Deploy during low-traffic window if backfilling avatars for existing employees.
- Security groups: define HR Manager, HR User, and Public roles with appropriate access levels.
- Demo data: provide guidance to admins on when/how to load demo scenarios for training/testing.
- Channel subscriptions: provide documentation on configuring department auto-subscribe channels.

## Open Questions (NEEDS CLARIFICATION)

- What is the exact newly hired threshold in days? (assumed 30, configurable?)
- Should avatars be regenerated if employee name changes, or only on creation?
- For department channel subscriptions, should previous subscriptions be removed when moving departments?
- What is the fallback behavior if SVG avatar generation fails (use placeholder vs error)?
- Should modification history be visible to all users or restricted to HR/admin?
- Is there an existing onboarding wizard/module that the link should reference?

---
