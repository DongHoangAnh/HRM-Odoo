---
description: "Task list for Employee Overtime Management (002-manage-overtime)"
---

# Tasks: Employee Overtime Management (002-manage-overtime)

**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Initialize Odoo module skeleton at addons/hr_attendance_overtime/__init__.py and __manifest__.py
- [ ] T002 [P] Create module folder structure: addons/hr_attendance_overtime/models, views, security, tests, data
- [ ] T003 [P] Add development tooling: pre-commit config and module README at addons/hr_attendance_overtime/README.md

---

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T004 Create base models: `OvertimeLine` and `OvertimeRules` in addons/hr_attendance_overtime/models/overtime_models.py
- [ ] T005 [P] Add security/ACL entries in addons/hr_attendance_overtime/security/ir.model.access.csv
- [ ] T006 [P] Add initial XML views (empty placeholders) for overtime models in addons/hr_attendance_overtime/views/overtime_views.xml
- [ ] T007 [P] Create test scaffolding folder and base test utils in addons/hr_attendance_overtime/tests/conftest.py
- [ ] T008 Create migrations/data files (if needed) in addons/hr_attendance_overtime/data/ to ensure safe install

---

## Phase 3: User Story 1 - Capture and Compute Overtime (Priority: P1) 🎯 MVP

**Goal**: Compute overtime from attendance automatically, allow manual overtime creation, and surface daily/weekly totals.

**Independent Test**: Create attendance and manual overtime examples; verify daily and weekly overtime totals.

- [ ] T010 [P] [US1] Implement overtime computation service in addons/hr_attendance_overtime/models/compute_overtime.py
- [ ] T011 [US1] Add attendance integration to compute overtime on attendance create/update in addons/hr_attendance_overtime/models/attendance_integration.py
- [ ] T012 [P] [US1] Implement RPC `create_overtime_line(data)` in addons/hr_attendance_overtime/models/overtime_rpc.py
- [ ] T013 [US1] Add tests for computed and manual overtime in addons/hr_attendance_overtime/tests/test_compute_overtime.py
- [ ] T014 [US1] Update attendance views to display overtime aggregates in addons/hr_attendance_overtime/views/attendance_overtime_inherit.xml

---

## Phase 4: User Story 2 - Overtime Approval Lifecycle (Priority: P1)

**Goal**: Provide approve/refuse workflow and ensure approved durations contribute to validated totals.

**Independent Test**: Create overtime lines in pending state, approve/refuse them, and verify validated totals and states.

- [ ] T020 [P] [US2] Add `status` field and workflow methods (`approve()`, `refuse()`) to addons/hr_attendance_overtime/models/overtime_models.py
- [ ] T021 [US2] Implement RPC endpoints `approve_overtime_line(id)` and `refuse_overtime_line(id, reason)` in addons/hr_attendance_overtime/models/overtime_actions.py
- [ ] T022 [US2] Add UI buttons and views for manager review in addons/hr_attendance_overtime/views/overtime_actions.xml
- [ ] T023 [US2] Add tests for approval lifecycle and validated totals in addons/hr_attendance_overtime/tests/test_approval_lifecycle.py
- [ ] T024 [US2] Ensure approval actions respect company `validation_mode` in addons/hr_attendance_overtime/models/config.py

---

## Phase 5: User Story 3 - Policy Enforcement and Compensation Outcomes (Priority: P2)

**Goal**: Support rules/rulesets, flag policy threshold violations, and convert approved overtime into compensation outcomes.

**Independent Test**: Apply rulesets with thresholds; verify violations flagged and approved-to-time-off conversion adjusts leave balances.

- [ ] T030 [P] [US3] Implement `OvertimeRule` and `OvertimeRuleset` models in addons/hr_attendance_overtime/models/rules.py
- [ ] T031 [US3] Implement rules evaluation engine in addons/hr_attendance_overtime/models/rules_engine.py
- [ ] T032 [US3] Implement compensation conversion for `time_off` in addons/hr_attendance_overtime/models/compensation.py
- [ ] T033 [P] [US3] Add tests for rules evaluation and compensation conversion in addons/hr_attendance_overtime/tests/test_rules_and_compensation.py

---

## Phase 6: User Story 4 - Attendance Synchronization and Oversight (Priority: P2)

**Goal**: Ensure linked attendance records reflect overtime updates immediately and recompute aggregates.

**Independent Test**: Link overtime lines to attendance, change status/duration, and verify attendance aggregates recompute.

- [ ] T040 [US4] Implement linking logic and `attendance_id` resolution in addons/hr_attendance_overtime/models/linking.py
- [ ] T041 [US4] Implement `recompute_overtime_aggregates(attendance_id)` to update validated totals in addons/hr_attendance_overtime/models/attendance_aggregate.py
- [ ] T042 [P] [US4] Add integration tests verifying attendance synchronization in addons/hr_attendance_overtime/tests/test_attendance_sync.py
- [ ] T043 [US4] Update attendance list/form views to show `overtime_hours` and `validated_overtime_hours` in addons/hr_attendance_overtime/views/attendance_overtime_inherit.xml

---

## Phase N: Polish & Cross-Cutting Concerns

- [ ] T050 [P] Documentation: Write `docs/overtime.md` describing configuration, rules, and admin flows
- [ ] T051 [P] Add logging, metrics, and error handling to core modules in addons/hr_attendance_overtime/models/logging.py
- [ ] T052 Run `quickstart.md` validation and record any missing setup steps in addons/hr_attendance_overtime/QUICKSTART_VALIDATION.md

---

## Dependencies & Execution Order

- Setup (Phase 1) → Foundational (Phase 2) → User Stories (Phase 3+)
- User stories may run in parallel after foundational tasks complete. Prioritize US1 for MVP.
