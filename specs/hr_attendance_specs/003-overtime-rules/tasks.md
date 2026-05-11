# Tasks: Overtime Rules and Ruleset Configuration

**Input**: Design documents from `/specs/hr_attendance_specs/003-overtime-rules/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/overtime-ruleset-contract.md, quickstart.md

**Tests**: Included because the feature specification has mandatory testing scenarios and independent test criteria per user story.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize module scaffolding and registration for overtime policy feature.

- [ ] T001 Create module scaffolding and package initializers in addons/hrm_attendance_overtime/__init__.py
- [ ] T002 Create module manifest with dependencies and data/test registration in addons/hrm_attendance_overtime/__manifest__.py
- [ ] T003 [P] Create models package initializer wiring ruleset/rule/regeneration models in addons/hrm_attendance_overtime/models/__init__.py
- [ ] T004 [P] Create wizard package initializer wiring regeneration wizard in addons/hrm_attendance_overtime/wizard/__init__.py
- [ ] T005 [P] Create security baseline groups and permissions definition in addons/hrm_attendance_overtime/security/overtime_security.xml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build shared domain foundation that all user stories depend on.

**⚠️ CRITICAL**: No user story work should begin until this phase completes.

- [ ] T006 Define base ruleset model fields and defaults in addons/hrm_attendance_overtime/models/hr_attendance_overtime_ruleset.py
- [ ] T007 [P] Define base rule model fields, enums, and ordering in addons/hrm_attendance_overtime/models/hr_attendance_overtime_rule.py
- [ ] T008 [P] Define regeneration run model skeleton and audit fields in addons/hrm_attendance_overtime/models/hr_attendance_overtime_regeneration.py
- [ ] T009 Implement ACL entries for manager/user access in addons/hrm_attendance_overtime/security/ir.model.access.csv
- [ ] T010 Implement common validation error helpers and user-facing messages in addons/hrm_attendance_overtime/models/hr_attendance_overtime_rule.py
- [ ] T011 Implement reusable eligibility domain builder for attendance scope in addons/hrm_attendance_overtime/models/hr_attendance_overtime_regeneration.py

**Checkpoint**: Foundation ready, user stories can now proceed.

---

## Phase 3: User Story 1 - Create and Organize Policy Rulesets (Priority: P1) 🎯 MVP

**Goal**: HR attendance managers can create active company/country-scoped rulesets with default combination mode and visible rule count.

**Independent Test**: Create a ruleset and verify active default, company/country scope, default combination mode, and rule count display.

### Tests for User Story 1

- [ ] T012 [P] [US1] Add contract test for ruleset create defaults and scoping in addons/hrm_attendance_overtime/tests/test_ruleset_contract.py
- [ ] T013 [P] [US1] Add integration test for ruleset rule_count computation in addons/hrm_attendance_overtime/tests/test_overtime_ruleset.py

### Implementation for User Story 1

- [ ] T014 [US1] Implement ruleset create logic with default active and combination mode in addons/hrm_attendance_overtime/models/hr_attendance_overtime_ruleset.py
- [ ] T015 [US1] Implement computed stored rule_count on ruleset in addons/hrm_attendance_overtime/models/hr_attendance_overtime_ruleset.py
- [ ] T016 [P] [US1] Implement ruleset list/form views with company, country, active, combination mode, and rule count in addons/hrm_attendance_overtime/views/overtime_ruleset_views.xml
- [ ] T017 [US1] Register ruleset action/menu for HR attendance managers in addons/hrm_attendance_overtime/views/overtime_ruleset_views.xml

**Checkpoint**: US1 is fully functional and independently testable.

---

## Phase 4: User Story 2 - Define Overtime Eligibility Rules (Priority: P1)

**Goal**: Managers can create valid quantity/timing rules and receive clear validation errors for invalid configurations.

**Independent Test**: Create valid and invalid quantity/timing rules and verify acceptance/rejection and rule detail summaries.

### Tests for User Story 2

- [ ] T018 [P] [US2] Add contract test for create/update overtime rule validation matrix in addons/hrm_attendance_overtime/tests/test_rule_contract.py
- [ ] T019 [P] [US2] Add integration test for quantity rules expected-hours validation in addons/hrm_attendance_overtime/tests/test_overtime_rules_validation.py
- [ ] T020 [P] [US2] Add integration test for timing rules schedule and hour-bound validation in addons/hrm_attendance_overtime/tests/test_overtime_rules_validation.py

### Implementation for User Story 2

- [ ] T021 [US2] Implement quantity-rule constraints for period and expected-hours source requirements in addons/hrm_attendance_overtime/models/hr_attendance_overtime_rule.py
- [ ] T022 [US2] Implement timing-rule constraints for schedule requirement and hour-of-day boundaries in addons/hrm_attendance_overtime/models/hr_attendance_overtime_rule.py
- [ ] T023 [US2] Implement rule information summary display fields/methods in addons/hrm_attendance_overtime/models/hr_attendance_overtime_rule.py
- [ ] T024 [P] [US2] Implement overtime rule form/tree views for quantity and timing variants in addons/hrm_attendance_overtime/views/overtime_rule_views.xml
- [ ] T025 [US2] Wire ruleset-to-rule one2many editing experience in ruleset view in addons/hrm_attendance_overtime/views/overtime_ruleset_views.xml

**Checkpoint**: US2 is fully functional and independently testable.

---

## Phase 5: User Story 3 - Apply Rule Timing and Scope (Priority: P2)

**Goal**: Rules apply only in intended contexts (working day, non-working day, leave, schedule windows).

**Independent Test**: Evaluate rules against working-day, weekend/non-working day, leave interval, and schedule-window scenarios.

### Tests for User Story 3

- [ ] T026 [P] [US3] Add integration test for work-day and non-work-day applicability in addons/hrm_attendance_overtime/tests/test_overtime_applicability.py
- [ ] T027 [P] [US3] Add integration test for leave-based applicability in addons/hrm_attendance_overtime/tests/test_overtime_applicability.py
- [ ] T028 [P] [US3] Add integration test for schedule-window applicability in addons/hrm_attendance_overtime/tests/test_overtime_applicability.py

### Implementation for User Story 3

- [ ] T029 [US3] Implement applicability context resolver from attendance, calendar, and leave data in addons/hrm_attendance_overtime/models/hr_attendance_overtime_rule.py
- [ ] T030 [US3] Implement timing-type evaluation methods for work_day/non_work_day/leave/schedule_window in addons/hrm_attendance_overtime/models/hr_attendance_overtime_rule.py
- [ ] T031 [US3] Implement deterministic rule ordering and applicability filter pipeline in addons/hrm_attendance_overtime/models/hr_attendance_overtime_rule.py

**Checkpoint**: US3 is fully functional and independently testable.

---

## Phase 6: User Story 4 - Regenerate Overtime from Policy Changes (Priority: P2)

**Goal**: Managers can trigger scoped regeneration that recomputes overtime using active rules and selected aggregation mode.

**Independent Test**: Trigger regeneration on a ruleset and verify only eligible attendances are recomputed with correct aggregation behavior.

### Tests for User Story 4

- [ ] T032 [P] [US4] Add contract test for regeneration action input/output behavior in addons/hrm_attendance_overtime/tests/test_regeneration_contract.py
- [ ] T033 [P] [US4] Add integration test for scoped eligible attendance recomputation in addons/hrm_attendance_overtime/tests/test_overtime_regeneration.py
- [ ] T034 [P] [US4] Add integration test for max_rate and sum_rate aggregation outcomes in addons/hrm_attendance_overtime/tests/test_overtime_regeneration.py

### Implementation for User Story 4

- [ ] T035 [US4] Implement regeneration service method applying active rules at execution time in addons/hrm_attendance_overtime/models/hr_attendance_overtime_regeneration.py
- [ ] T036 [US4] Implement aggregation strategy handlers for max_rate and sum_rate in addons/hrm_attendance_overtime/models/hr_attendance_overtime_regeneration.py
- [ ] T037 [US4] Implement regeneration audit metrics and status transitions in addons/hrm_attendance_overtime/models/hr_attendance_overtime_regeneration.py
- [ ] T038 [P] [US4] Implement regeneration wizard and action entrypoint in addons/hrm_attendance_overtime/wizard/overtime_regeneration_wizard.py
- [ ] T039 [P] [US4] Implement wizard view and ruleset action button for regeneration in addons/hrm_attendance_overtime/views/overtime_regeneration_wizard_views.xml
- [ ] T040 [US4] Implement scheduled regeneration cron configuration for stale policy changes in addons/hrm_attendance_overtime/data/overtime_cron.xml

**Checkpoint**: US4 is fully functional and independently testable.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, traceability, and end-to-end verification across stories.

- [ ] T041 [P] Add end-to-end test coverage for full policy lifecycle in addons/hrm_attendance_overtime/tests/test_overtime_end_to_end.py
- [ ] T042 Ensure manifest data/test ordering and dependencies are final in addons/hrm_attendance_overtime/__manifest__.py
- [ ] T043 [P] Add user documentation notes and runbook updates in specs/hr_attendance_specs/003-overtime-rules/quickstart.md
- [ ] T044 Execute quickstart validation checklist and capture outcomes in specs/hr_attendance_specs/003-overtime-rules/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): No dependencies.
- Foundational (Phase 2): Depends on Phase 1 and blocks all user stories.
- User Stories (Phase 3-6): Depend on Phase 2 completion.
- Polish (Phase 7): Depends on completion of desired user stories.

### User Story Dependencies

- US1 (P1): Starts immediately after Foundational phase.
- US2 (P1): Starts after Foundational phase; can run in parallel with US1 once shared model base is merged.
- US3 (P2): Starts after US2 rule definitions are available.
- US4 (P2): Starts after US1 and US2 (ruleset + rule base) and can overlap late US3 testing.

### Within Each User Story

- Tests first (write and fail before implementation).
- Model logic before UI wiring.
- Regeneration computation before wizard/cron integration.
- Story must satisfy its independent test before moving forward.

## Parallel Opportunities

- Setup parallel tasks: T003, T004, T005.
- Foundational parallel tasks: T007, T008.
- US1 parallel tasks: T012 and T013; T016 can run while T015 is in progress.
- US2 parallel tasks: T018, T019, T020, and T024.
- US3 parallel tasks: T026, T027, T028.
- US4 parallel tasks: T032, T033, T034, and UI/wizard tasks T038, T039 after T035 baseline is merged.
- Polish parallel tasks: T041 and T043.

## Parallel Example: User Story 1

```bash
Task: "T012 [US1] Add contract test for ruleset create defaults and scoping in addons/hrm_attendance_overtime/tests/test_ruleset_contract.py"
Task: "T013 [US1] Add integration test for ruleset rule_count computation in addons/hrm_attendance_overtime/tests/test_overtime_ruleset.py"
Task: "T016 [US1] Implement ruleset list/form views with company, country, active, combination mode, and rule count in addons/hrm_attendance_overtime/views/overtime_ruleset_views.xml"
```

## Parallel Example: User Story 2

```bash
Task: "T018 [US2] Add contract test for create/update overtime rule validation matrix in addons/hrm_attendance_overtime/tests/test_rule_contract.py"
Task: "T019 [US2] Add integration test for quantity rules expected-hours validation in addons/hrm_attendance_overtime/tests/test_overtime_rules_validation.py"
Task: "T020 [US2] Add integration test for timing rules schedule and hour-bound validation in addons/hrm_attendance_overtime/tests/test_overtime_rules_validation.py"
Task: "T024 [US2] Implement overtime rule form/tree views for quantity and timing variants in addons/hrm_attendance_overtime/views/overtime_rule_views.xml"
```

## Parallel Example: User Story 3

```bash
Task: "T026 [US3] Add integration test for work-day and non-work-day applicability in addons/hrm_attendance_overtime/tests/test_overtime_applicability.py"
Task: "T027 [US3] Add integration test for leave-based applicability in addons/hrm_attendance_overtime/tests/test_overtime_applicability.py"
Task: "T028 [US3] Add integration test for schedule-window applicability in addons/hrm_attendance_overtime/tests/test_overtime_applicability.py"
```

## Parallel Example: User Story 4

```bash
Task: "T032 [US4] Add contract test for regeneration action input/output behavior in addons/hrm_attendance_overtime/tests/test_regeneration_contract.py"
Task: "T033 [US4] Add integration test for scoped eligible attendance recomputation in addons/hrm_attendance_overtime/tests/test_overtime_regeneration.py"
Task: "T034 [US4] Add integration test for max_rate and sum_rate aggregation outcomes in addons/hrm_attendance_overtime/tests/test_overtime_regeneration.py"
Task: "T038 [US4] Implement regeneration wizard and action entrypoint in addons/hrm_attendance_overtime/wizard/overtime_regeneration_wizard.py"
```

## Implementation Strategy

### MVP First (US1 + US2)

1. Complete Phase 1 and Phase 2.
2. Deliver US1 to make rulesets manageable.
3. Deliver US2 to make rules valid and usable.
4. Validate both independent tests before broader rollout.

### Incremental Delivery

1. Foundation complete (Phase 1-2).
2. Ship US1 + US2 as first policy-management increment.
3. Add US3 for applicability correctness.
4. Add US4 for historical regeneration and aggregation behavior.
5. Finalize with Phase 7 polish and quickstart verification.

### Suggested MVP Scope

- Suggested MVP: User Story 1 + User Story 2 (core policy configuration).
- Post-MVP: User Story 3 + User Story 4 (advanced applicability and regeneration).
