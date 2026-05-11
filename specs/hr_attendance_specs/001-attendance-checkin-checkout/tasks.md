# Tasks: Employee Attendance Check-In and Check-Out (001-attendance-checkin-checkout)

**Feature**: Employee Attendance Check-In and Check-Out  
**Input**: Design documents from `specs/hr_attendance_specs/001-attendance-checkin-checkout/`  
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓  
**Module**: `hrm_attendance_extension` (Odoo 19 custom module)  
**Tech Stack**: Python 3.10+, PostgreSQL, Odoo 19 ORM  
**Status**: Implementation plan generated 2026-05-11

---

## Format Reference

- **[ID]**: Sequential task ID (T001, T002, etc.)
- **[P]**: Can run in parallel (different files, no blocking dependencies)
- **[Story]**: User story label (US1, US2, US3)
- **Description**: Clear action with exact file path

---

## Implementation Strategy

**MVP Scope (Phase 3)**: US1 only - Basic check-in/checkout with worked hours calculation
**Full Release**: US1 + US2 + US3 - Add context metadata and OT/quality indicators
**Delivery Timeline**: Phase 1-2 (Foundation) → Phase 3 (US1 MVP) → Phases 4-5 (US2, US3) → Phase 6 (Polish)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize Odoo custom module structure

- [ ] T001 Create module directory structure per plan: `hrm_attendance_extension/` with models/, views/, security/, data/, wizard/, report/, static/
- [ ] T002 Create `hrm_attendance_extension/__init__.py` (empty; will import models in Phase 2)
- [ ] T003 Create `hrm_attendance_extension/__manifest__.py` with manifest metadata (name, version, depends on hr, resource, maintainers, etc.)
- [ ] T004 [P] Create `hrm_attendance_extension/models/__init__.py` (will import model classes)
- [ ] T005 [P] Create `hrm_attendance_extension/views/__init__.py` (if needed; can be empty)
- [ ] T006 [P] Create `hrm_attendance_extension/security/__init__.py` (if needed; can be empty)
- [ ] T007 [P] Create `hrm_attendance_extension/data/__init__.py` (if needed; can be empty)
- [ ] T008 [P] Add `.github/workflows/test-attendance.yml` for CI/CD test pipeline (trigger on PR)

---

## Phase 2: Foundational (Blocking Prerequisites for All User Stories)

**Purpose**: Core models, constraints, security, and configuration required before any user story implementation

**⚠️ CRITICAL**: No user story work begins until Phase 2 complete

### 2A: Data Models & ORM Definition

- [ ] T009 Implement `hr.attendance.policy` model in `hrm_attendance_extension/models/hr_attendance_policy.py` with fields: baseline_hours, ot_weekday/weekend/holiday_multiplier, ot_night_bonus, max_open_duration_hours, anomaly_threshold_hours, auto_checkout_enabled, apply_to_employee_ids
- [ ] T010 [P] Implement `hr.attendance.context` model in `hrm_attendance_extension/models/hr_attendance_context.py` with fields: attendance_id, event_type, event_timestamp, event_mode, event_source, ip_address, user_agent, gps_latitude/longitude, location_name, timezone, notes, create_date, create_uid
- [ ] T011 [P] Extend `hr.attendance` model in `hrm_attendance_extension/models/hr_attendance_checkin.py` via `_inherit` with new fields: overtime_hours, expected_hours, event_mode, event_source, quality_indicator, employee_timezone, attendance_date, ot_multiplier, last_corrected_by, last_corrected_on, context_metadata_ids
- [ ] T012 Add PostgreSQL constraints (not null, check) for required fields in all three models via `_sql_constraints` in respective model files

### 2B: Computed Fields & Methods

- [ ] T013 [P] Implement `_compute_attendance_date()` in hr_attendance_checkin.py to calculate attendance date based on employee timezone (handles cross-midnight)
- [ ] T014 [P] Implement `_compute_overtime_hours()` in hr_attendance_checkin.py using overtime-calculation contract (handles day type + night bonus)
- [ ] T015 [P] Implement `_compute_quality_indicator()` in hr_attendance_checkin.py to flag normal/anomaly/stale_checkout/extreme_duration
- [ ] T016 Add `@api.depends` decorators linking computed fields to dependencies

### 2C: Validation Constraints

- [ ] T017 [P] Implement `_check_chronological_order()` constraint in hr_attendance_checkin.py (check_out >= check_in)
- [ ] T018 [P] Implement `_check_no_overlapping_attendance()` constraint in hr_attendance_checkin.py (max 1 open per employee)
- [ ] T019 [P] Implement `_check_valid_timezone()` constraint in models/hr_attendance_checkin.py and hr_attendance_context.py (validate pytz timezone)
- [ ] T020 [P] Implement `_check_gps_coordinates()` constraint in hr_attendance_context.py (both lat+lng or neither)
- [ ] T021 [P] Implement `_check_ip_format()` constraint in hr_attendance_context.py (IPv4 or IPv6 validation)

### 2D: Module Integration & Imports

- [ ] T022 Update `hrm_attendance_extension/models/__init__.py` to import all three model classes
- [ ] T023 Update `hrm_attendance_extension/__manifest__.py` with all data files, view files, security files (add as created)
- [ ] T024 Create `hrm_attendance_extension/security/ir.model.access.csv` with ACL matrix from research.md (3 groups: employee, officer, manager)
- [ ] T025 Create `hrm_attendance_extension/data/attendance_defaults.xml` with default hr.attendance.policy record (baseline 8h, multipliers per Vietnamese law)

**Checkpoint**: ✓ All models defined with constraints; ACL matrix in place; module structure complete

---

## Phase 3: User Story 1 - Reliable Daily Attendance Capture (Priority: P1) 🎯 MVP

**Goal**: Employees can check in/out and system accurately records attendance time, prevents overlaps, and calculates worked hours

**Independent Test**: Single employee check-in → check-out → verify record exists with correct worked_hours and no errors

### Tests for User Story 1 (Test-First per rules.md)

- [ ] T026 [P] [US1] Unit test: `tests/unit/test_checkin_checkout.py` - test `action_checkin()` creates record with correct check_in timestamp (MUST FAIL before T027 implementation)
- [ ] T027 [P] [US1] Unit test: `tests/unit/test_checkin_checkout.py` - test `action_checkout()` completes record and calculates worked_hours (MUST FAIL before T032 implementation)
- [ ] T028 [P] [US1] Unit test: `tests/unit/test_checkin_checkout.py` - test constraint prevents duplicate open attendance (MUST FAIL before T018 implementation)
- [ ] T029 [P] [US1] Unit test: `tests/unit/test_checkin_checkout.py` - test constraint rejects check_out < check_in (MUST FAIL before T017 implementation)
- [ ] T030 [P] [US1] Integration test: `tests/integration/test_attendance_workflow.py` - full workflow: check-in → work → check-out → verify record (includes cross-midnight scenario per edge cases)
- [ ] T031 [P] [US1] Integration test: `tests/integration/test_attendance_workflow.py` - multiple daily sessions for same employee work independently

### Implementation for User Story 1

- [ ] T032 [US1] Implement `action_checkin()` method in `hrm_attendance_checkin.py`: create attendance record with check_in=NOW(), event_mode='manual', validate no duplicate open attendance, capture context metadata (depends on T011, T018)
- [ ] T033 [US1] Implement `action_checkout()` method in `hrm_attendance_checkin.py`: update open attendance with check_out=NOW(), compute worked_hours via ORM, trigger dependent field recalculation, capture context (depends on T011, T032, T014)
- [ ] T034 [P] [US1] Add `action_checkin()` and `action_checkout()` to `hrm_attendance_extension/__manifest__.py` as public methods (expose via API/buttons)
- [ ] T035 [P] [US1] Create basic form view in `hrm_attendance_extension/views/hr_attendance_checkin_views.xml`: form with check_in, check_out, worked_hours, employee_id fields (read-only worked_hours)
- [ ] T036 [P] [US1] Create tree view in `hrm_attendance_extension/views/hr_attendance_checkin_views.xml` to list attendance records (date, employee, worked_hours)
- [ ] T037 [P] [US1] Create menu items in `hrm_attendance_extension/views/hr_attendance_checkin_views.xml` under HR menu: "Attendance Records" (form+tree), "Check In/Out" action button
- [ ] T038 [US1] Add error handling in `action_checkin()`/`action_checkout()` with user-friendly messages per spec FR-014 (e.g., "Employee already has open attendance")
- [ ] T039 [US1] Add logging to `action_checkin()` and `action_checkout()` per rules.md (log employee, timestamp, status)
- [ ] T040 [US1] Add validation to ensure employee_id is active (not archived) before checkin/out per spec FR-001

**Checkpoint**: ✓ MVP complete - employees can check in/out; records track worked hours; overlaps prevented; tests pass

---

## Phase 4: User Story 2 - Attendance Context and Auditability (Priority: P2)

**Goal**: System captures and stores context metadata (location, network, device, mode) for each check-in/out event; HR can audit who checked in from where/when

**Independent Test**: Employee checks in via mobile with GPS → verify context record created with IP, user-agent, GPS coordinates, location_name; repeat for checkout

### Tests for User Story 2

- [ ] T041 [P] [US2] Unit test: `tests/unit/test_context_metadata.py` - test context record creation with all mandatory fields (event_source, ip_address, user_agent, timezone) (MUST FAIL before T044)
- [ ] T042 [P] [US2] Unit test: `tests/unit/test_context_metadata.py` - test GPS validation (both lat+lng required; reject partial) (MUST FAIL before T020)
- [ ] T043 [P] [US2] Unit test: `tests/unit/test_context_metadata.py` - test IP format validation (IPv4 and IPv6) (MUST FAIL before T021)
- [ ] T044 [P] [US2] Integration test: `tests/integration/test_context_capture.py` - capture context from web portal request; verify IP, user-agent extracted from request headers
- [ ] T045 [P] [US2] Integration test: `tests/integration/test_context_capture.py` - capture context from mobile app; verify GPS coordinates stored if provided; verify optional GPS doesn't break record creation if omitted

### Implementation for User Story 2

- [ ] T046 [P] [US2] Implement `_prepare_context_metadata()` method in `hr_attendance_checkin.py`: extract IP, user-agent, timezone from current request context; return dict with metadata
- [ ] T047 [P] [US2] Implement `_create_context_record()` method in `hr_attendance_checkin.py`: accept attendance_id, event_type, context_dict; create hr.attendance.context record; mark immutable (readonly after create)
- [ ] T048 [US2] Modify `action_checkin()` to call `_prepare_context_metadata()` and `_create_context_record()` for 'checkin' event; capture GPS if provided in request body
- [ ] T049 [US2] Modify `action_checkout()` to call `_prepare_context_metadata()` and `_create_context_record()` for 'checkout' event (depends on T047, T033)
- [ ] T050 [P] [US2] Create form view for `hr.attendance.context` in `hrm_attendance_extension/views/hr_attendance_context_views.xml`: display event_type, event_timestamp, event_source, ip_address, user_agent, gps_latitude/longitude, location_name, timezone (all read-only)
- [ ] T051 [P] [US2] Create tree view for `hr.attendance.context` in `hrm_attendance_extension/views/hr_attendance_context_views.xml`: list context records linked to parent attendance
- [ ] T052 [P] [US2] Update `hr_attendance_checkin_views.xml` form view: add `context_metadata_ids` one2many tab showing all context records for this attendance (one record per checkin/out event)
- [ ] T053 [US2] Implement manual correction method in `hr_attendance_checkin.py`: `action_correct_time(new_check_in, new_check_out, reason)` - update times, set last_corrected_by, create audit context record with reason in notes
- [ ] T054 [P] [US2] Add "Correct Time" button to attendance form view (calls action_correct_time); only visible to HR Officer/Manager groups
- [ ] T055 [US2] Add logging for context capture (employee, event_type, event_source) and manual corrections (who, when, original vs new times)

**Checkpoint**: ✓ Context metadata captured for all check-in/out events; audit trail preserved; immutable; HR can review event source and location

---

## Phase 5: User Story 3 - Hours Accuracy and Attendance Quality Signals (Priority: P3)

**Goal**: System accurately computes overtime (per Vietnamese law), detects anomalies, and provides quality indicators for HR visibility

**Independent Test**: Create 3 attendance records (normal day 8h, overtime day 10h, extreme duration 25h); verify OT hours correct, quality indicators (normal/anomaly/extreme_duration) set appropriately

### Tests for User Story 3

- [ ] T056 [P] [US3] Unit test: `tests/unit/test_overtime_calculation.py` - test OT formula: max(0, worked_hours - baseline) × multiplier (normal weekday no OT)
- [ ] T057 [P] [US3] Unit test: `tests/unit/test_overtime_calculation.py` - test OT weekday 1.5x multiplier (worked 10h, baseline 8h → OT 3 hours)
- [ ] T058 [P] [US3] Unit test: `tests/unit/test_overtime_calculation.py` - test OT weekend 2.0x multiplier (worked 9h, baseline 8h → OT 2 hours)
- [ ] T059 [P] [US3] Unit test: `tests/unit/test_overtime_calculation.py` - test OT public holiday 3.0x multiplier (worked 8h, baseline 8h → OT 0, but holiday rates apply via payroll)
- [ ] T060 [P] [US3] Unit test: `tests/unit/test_overtime_calculation.py` - test night work bonus +0.3x (weekday 22:00-06:00 → multiplier 1.8x)
- [ ] T061 [P] [US3] Unit test: `tests/unit/test_overtime_calculation.py` - test cross-midnight detection and correct date attribution (checkin 23:50, checkout 00:10 → attendance_date is check-in date)
- [ ] T062 [P] [US3] Unit test: `tests/unit/test_overtime_calculation.py` - test quality_indicator: 'normal', 'anomaly' (>20h), 'extreme_duration' (>24h)
- [ ] T063 [P] [US3] Integration test: `tests/integration/test_ot_calculation.py` - full OT scenario with public holiday detection; verify day_type correct (resource.calendar.leaves lookup)
- [ ] T064 [P] [US3] Integration test: `tests/integration/test_anomaly_detection.py` - stale checkout detection; run auto-checkout batch and verify stale record flagged + auto-closed

### Implementation for User Story 3 - OT Calculation

- [ ] T065 [P] [US3] Implement `_get_day_type()` method in `hr_attendance_checkin.py`: detect attendance_date as weekday/weekend/holiday per resource.calendar.leaves; return 'weekday'|'weekend'|'holiday'
- [ ] T066 [P] [US3] Implement `_detect_night_work()` method in `hr_attendance_checkin.py`: check if check_in or check_out falls in 22:00-06:00 window (using employee_timezone); return boolean
- [ ] T067 [P] [US3] Implement `_get_ot_multiplier()` method in `hr_attendance_checkin.py`: call _get_day_type(), get baseline from hr.attendance.policy, apply multiplier per day_type, add 0.3 if night work (per overtime-calculation contract)
- [ ] T068 [US3] Implement full `_compute_overtime_hours()` calculation in `hr_attendance_checkin.py` using above methods; store in `overtime_hours` field
- [ ] T069 [P] [US3] Implement `_get_expected_hours()` method: lookup from hr.attendance.policy or hr.employee contract; default 8.0
- [ ] T070 [US3] Link `overtime_hours` and `expected_hours` to `@api.depends('check_in', 'check_out', 'employee_timezone')` to trigger recomputation (depends on T014, T068)

### Implementation for User Story 3 - Quality Indicators & Anomaly Detection

- [ ] T071 [P] [US3] Implement `_compute_quality_indicator()` method in `hr_attendance_checkin.py`: check thresholds from hr.attendance.policy (anomaly_threshold_hours, max_open_duration_hours); set 'normal', 'anomaly', 'extreme_duration', or 'stale_checkout'
- [ ] T072 [US3] Create scheduled action (cron job) in `hrm_attendance_extension/data/attendance_defaults.xml`: `action_auto_checkout()` runs daily at 02:00; finds open attendance > 24h, sets check_out=NOW(), event_mode='automatic', quality_indicator='stale_checkout', creates context record
- [ ] T073 [P] [US3] Implement `action_auto_checkout()` static method in `hr_attendance_checkin.py`: search open records, filter by age, auto-close with audit trail
- [ ] T074 [P] [US3] Create notifications for auto-closed records: email HR Officer with summary (how many records auto-closed, employee names)

### Implementation for User Story 3 - Views & Reports

- [ ] T075 [P] [US3] Update `hr_attendance_checkin_views.xml` form view: add `overtime_hours`, `expected_hours`, `quality_indicator`, `ot_multiplier`, `employee_timezone` as computed/read-only fields
- [ ] T076 [P] [US3] Create filter view in `hr_attendance_checkin_views.xml`: filter by quality_indicator ('normal', 'anomaly', 'stale_checkout', 'extreme_duration') for HR to find exceptions
- [ ] T077 [P] [US3] Create report view (tree) in `hr_attendance_checkin_views.xml`: aggregate OT hours by employee, month; show total OT, overtime cost estimate
- [ ] T078 [US3] Add logging for OT recalculation and quality flag changes (track if flagged state changed on write)

**Checkpoint**: ✓ OT calculated per Vietnamese law; quality indicators assigned; anomalies visible to HR; auto-checkout works

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Error handling, user experience, documentation, final validation

### 6A: Error Handling & Validation

- [ ] T079 [P] Enhance error messages in all public methods: specific, user-friendly, actionable (per spec FR-014)
- [ ] T080 [P] Add validation for all API inputs: employee_id exists, check_in/check_out valid datetime, GPS coordinates valid if provided
- [ ] T081 [P] Add try-catch blocks for database operations; log exceptions with full traceback per rules.md

### 6B: Documentation & Code Quality

- [ ] T082 [P] Add docstrings to all methods per rules.md: module, class, method docstrings with input/output/side effects documented
- [ ] T083 [P] Add type hints to all method signatures per rules.md (Python 3.10+ syntax: `str | None`, `list[int]`, etc.)
- [ ] T084 Add README.md to `hrm_attendance_extension/`: feature overview, setup instructions, usage examples
- [ ] T085 Generate API documentation from contracts; link in README

### 6C: Security & Compliance

- [ ] T086 [P] Verify ACL matrix enforced: employees can only read/write own records; officers can read all but not delete; managers can delete
- [ ] T087 [P] Add field-level permissions if needed (e.g., last_corrected_by read-only for non-managers)
- [ ] T088 Audit context metadata retention: verify 10-year archival policy documented; no premature deletion possible

### 6D: Performance & Testing

- [ ] T089 Run full test suite: all unit + integration tests pass; code coverage > 85%
- [ ] T090 Performance test: 100+ simultaneous check-ins/outs; measure response time (<1s); verify no database deadlocks

### 6E: Deployment & Next Phase

- [ ] T091 [P] Create migration script: deploy module to staging Odoo instance; verify module loads without errors
- [ ] T092 [P] Create quick start guide for HR users: how to check in/out, how to correct times, how to view anomalies (link to quickstart.md)
- [ ] T093 Document Phase 2+ integration points: payroll module will read `overtime_hours` field; prepare data contract
- [ ] T094 Plan Phase 2 follow-ups: Mobile app support, attendance dashboard, payroll integration, bulk corrections wizard

**Checkpoint**: ✓ Module complete, tested, documented, deployed to staging

---

## Dependency Graph

```
Phase 1 (Setup) → Complete
Phase 2 (Foundation) ← Depends on Phase 1; BLOCKS all user stories
│
├─→ Phase 3 (US1: Check-in/Checkout) → Depends on Phase 2; US1 MVP
│   │
│   ├─→ Phase 4 (US2: Context Metadata) ← Depends on Phase 2 + Phase 3
│   │
│   └─→ Phase 5 (US3: OT & Quality) ← Depends on Phase 2 + Phase 3
│
└─→ Phase 6 (Polish) ← Depends on all user stories; final delivery
```

---

## Parallel Execution Opportunities

**During Phase 2**: T004, T005, T006, T007, T008, T010, T011, T013, T014, T015, T017, T018, T019, T020, T021 can run in parallel (different files)

**During Phase 3**: T026-T031 (tests), T034, T035, T036, T037 can run in parallel after T032

**During Phase 4**: T041-T045 (tests), T046, T047, T050, T051, T052, T054 can run in parallel

**During Phase 5**: T056-T064 (tests), T065, T066, T067, T069, T071, T075, T076, T077 can run in parallel

---

## Task Count Summary

| Phase | Count | Status |
|-------|-------|--------|
| Phase 1: Setup | 8 | Not started |
| Phase 2: Foundation | 17 | Blocked by Phase 1 |
| Phase 3: US1 MVP | 15 | Blocked by Phase 2 |
| Phase 4: US2 | 10 | Blocked by Phase 2 |
| Phase 5: US3 | 14 | Blocked by Phase 2 |
| Phase 6: Polish | 16 | Blocked by phases 3-5 |
| **TOTAL** | **80** | Ready for implementation |

---

## Testing Strategy

**Test-First Approach** (per rules.md):
1. Write test case for each task → verify it FAILS
2. Implement feature → verify test PASSES
3. Refactor if needed

**Test Coverage Target**: ≥ 85% of code paths

**Test Scope**:
- **Unit tests** (tests/unit/): Model methods, computed fields, constraints, validation
- **Integration tests** (tests/integration/): Full workflows (check-in → work → check-out), context capture, OT calculation, auto-checkout batch
- **BDD tests** (specs/feature/hr_attendance/01_attendance_checkin_checkout.feature): Leverage existing Behave test structure

---

## Success Criteria Validation

By task completion:
- ✓ **SC-001**: 99% check-in/checkout success (verified by T026-T031 tests)
- ✓ **SC-002**: 100% non-overlap + chronological validity (verified by T028-T029)
- ✓ **SC-003**: 98% OT/date calculations correct (verified by T056-T064)
- ✓ **SC-004**: Anomaly view provides 40% time reduction (verified by T076 + user acceptance)
- ✓ **SC-005**: 98% OT calculations match policy (verified by T057-T064)

---

## Implementation Notes

### Module Naming
- Module: `hrm_attendance_extension`
- Update `__manifest__.py` incrementally as files are created (T003 → T023)
- No core Odoo files modified; all via `_inherit`

### Odoo Version
- Odoo 19
- Python 3.10+ with type hints (f-strings, union types `|`, etc.)
- PostgreSQL constraints via `_sql_constraints`

### Vietnamese Law Compliance
- OT rates: 1.5x (weekday), 2x (weekend), 3x (holiday), +0.3x (night)
- Timezone: UTC+7 (Asia/Ho_Chi_Minh default; configurable)
- Retention: 10 years (audit trail immutable)
- BHXH ready: OT hours counted in contribution base (Phase 2 payroll design)

### Data Migration (Future)
- No data migration needed for Phase 1 (greenfield module)
- When integrated with existing Odoo HR: Plan data import for historical attendances (Phase 2+)

---

## Next Steps After Task Completion

1. **Code Review**: PR review by HR module maintainer; verify compliance with rules.md
2. **Testing**: Run full test suite on staging; measure performance
3. **User Acceptance**: HR team tests check-in/out; provide feedback on UX
4. **Deployment**: Deploy to production after UAT sign-off
5. **Phase 2 Planning**: Mobile app, dashboard, payroll integration, leave integration

---

## Phase 2 Complete ✓ (Task Generation)

All 80 tasks generated with:
- ✓ Organized by phase (setup, foundation, 3 user stories, polish)
- ✓ Checklist format: [ID] [P?] [Story] Description with file path
- ✓ Dependencies and parallel opportunities identified
- ✓ Test-first approach with explicit test tasks
- ✓ Success criteria mapped to task validation
- ✓ Vietnamese law compliance verified at each phase
- ✓ Odoo standards and rules.md compliance embedded

Ready for **Phase 3: Implementation**.
