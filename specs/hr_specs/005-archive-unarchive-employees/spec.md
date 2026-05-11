# Feature Specification: Archive and Unarchive Employees

**Feature Branch**: `005-archive-unarchive-employees`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Archive and Unarchive Employees\n  As a Human Resources Manager\n  I want to archive and unarchive employees\n  So that I can manage active workforce and maintain historical records"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Archive employees with relationship cleanup (Priority: P1)

HR managers must archive employees and automatically clear subordinate relationships while preserving manager relationships, ensuring orphaned subordinates are properly handled.

**Why this priority**: Departing employees must be removed from active workforce without orphaning reports or breaking organizational hierarchy.

**Independent Test**: Archive an employee with manager and subordinate relationships; verify subordinate parent_id is cleared, manager relationship preserved, and presence state shows "archive".

**Acceptance Scenarios**:

1. **Given** an active employee with manager and subordinates, **When** archived, **Then** `active = False`, resource is archived, presence shows "archive", all subordinate `parent_id` values are cleared, and manager relationship remains.
2. **Given** an employee is a coach to others, **When** archived, **Then** other employees with this employee as coach have `coach_id` cleared.

---

### User Story 2 - Departure wizard for single subordinate (Priority: P1)

HR managers must see a guided workflow to record departure information when archiving an employee with exactly one subordinate, capturing reason and notes for HR records.

**Why this priority**: Departure documentation is required for compliance, exit processes, and severance handling.

**Independent Test**: Archive an employee with one subordinate and confirm wizard appears; archive with zero or multiple subordinates and confirm wizard does not appear; fill wizard and verify departure data stored and message posted.

**Acceptance Scenarios**:

1. **Given** an employee with exactly one subordinate, **When** archive initiated, **Then** departure wizard is displayed.
2. **Given** wizard displayed, **When** user enters `departure_date`, `departure_reason_id`, `departure_description` and confirms, **Then** employee is archived, departure fields are populated, and message is posted to employee timeline.

---

### User Story 3 - Bulk archival without wizard (Priority: P1)

HR managers must be able to archive multiple employees at once without triggering individual wizards to streamline workforce reductions.

**Why this priority**: Bulk archival (e.g., project end, RIF) must be efficient and consistent.

**Independent Test**: Select multiple employees and initiate bulk archive with `no_wizard` context flag; verify no wizard appears and all employees are archived.

**Acceptance Scenarios**:

1. **Given** multiple employees selected with `no_wizard=True` context, **When** archived, **Then** no departure wizard is displayed and all employees are archived.

---

### User Story 4 - Unarchive employees and clear departure data (Priority: P2)

HR managers must be able to reactivate archived employees (rehires) and automatically clear all departure information to restore clean records.

**Why this priority**: Rehires and temporary departures must be reversible without manual cleanup.

**Independent Test**: Unarchive an archived employee with departure data; verify `active=True`, all departure fields (`departure_date`, `departure_reason_id`, `departure_description`) are cleared.

**Acceptance Scenarios**:

1. **Given** an archived employee with departure information, **When** unarchived, **Then** `active = True`, departure fields are cleared, and employee appears in active lists.

---

### User Story 5 - Prevent circular manager relationships (Priority: P2)

System must detect and prevent creating circular reporting chains (e.g., A → B → A) to maintain hierarchy integrity.

**Why this priority**: Circular relationships break organizational reporting and payroll logic.

**Independent Test**: Attempt to create a circular chain and verify prevention; ensure valid chains are allowed.

**Acceptance Scenarios**:

1. **Given** an employee chain A → B, **When** attempting to set B as manager of A, **Then** system prevents the circular relationship and raises an error.

---

### Edge Cases

- Archiving an employee with active contracts: contracts remain unchanged; archival is not blocked.
- Re-archiving an already-archived employee: no error; status remains archived.
- Archiving an employee as manager to multiple subordinates: all subordinate `parent_id` are cleared.
- Unarchiving after 6+ months away: reactivation succeeds and employee is restored to active state.
- Departure wizard suppression with `no_wizard` context must override single-subordinate rule.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow archiving an employee, setting `active = False` and updating presence state to "archive".
- **FR-002**: System MUST archive the linked resource record when the employee is archived.
- **FR-003**: System MUST clear all subordinate `parent_id` values when an employee (manager) is archived.
- **FR-004**: System MUST NOT clear the employee's own `parent_id` or `coach_id` when archived.
- **FR-005**: System MUST clear `coach_id` on other employees when their coach is archived.
- **FR-006**: System MUST display a departure wizard when archiving a single employee with exactly one subordinate (unless `no_wizard=True`).
- **FR-007**: System MUST NOT display a departure wizard during bulk archival or when `no_wizard=True` context is set.
- **FR-008**: System MUST accept and store `departure_date`, `departure_reason_id`, and `departure_description` via the departure wizard.
- **FR-009**: System MUST post the `departure_description` as a message to the employee's timeline when archival completes.
- **FR-010**: System MUST allow unarchiving an archived employee, setting `active = True`.
- **FR-011**: System MUST clear all departure fields (`departure_date`, `departure_reason_id`, `departure_description`) when unarchiving.
- **FR-012**: System MUST prevent creating circular manager relationships (e.g., A → B → A cycles).
- **FR-013**: System MUST return a list of fields to clear on archive: `parent_id`, `coach_id`.
- **FR-014**: System MUST NOT block archival if the employee has active contracts; contracts remain unchanged.
- **FR-015**: System MUST allow re-archiving an already-archived employee without error.
- **FR-016**: System MUST restore archived employees to active workforce lists when unarchived.

### Key Entities *(include if feature involves data)*

- **hr.employee**: attributes include `active` (boolean), `presence_state` (enum: archive, present, etc.), `parent_id` (manager), `coach_id`, `departure_date`, `departure_reason_id`, `departure_description`.
- **departure_reason**: reference data for categorizing departure types.
- **res.resource**: linked to employee; archived when employee is archived.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Employee archival completes in under 2 seconds for single employees; under 5 seconds for bulk (10+ employees).
- **SC-002**: Subordinate `parent_id` clearing succeeds for 100% of manager-subordinate relationships on archive.
- **SC-003**: Departure wizard displays in 100% of single-subordinate archival scenarios (when `no_wizard` not set).
- **SC-004**: Departure wizard does NOT display in 100% of bulk archival scenarios.
- **SC-005**: Circular relationship prevention succeeds in 100% of attempted cycles with clear error messaging.
- **SC-006**: Unarchival correctly clears all departure fields in 100% of reactivations.
- **SC-007**: Re-archiving already-archived employees succeeds without error in 100% of attempts.
- **SC-008**: Archived employees appear in active workforce lists in 0% after archival; reappear in 100% after unarchival.

## Assumptions

- Resource records are linked 1:1 to employees; archiving an employee also archives the resource.
- Departure reasons are pre-configured reference data managed by HR admin.
- Manager/coach relationships are stored as foreign keys; clearing is a simple null/False update.
- Active contracts are not automatically archived; they may remain active for final payroll processing.
- Circular relationship detection uses graph traversal or constraint checks; exact implementation varies.
- Bulk archival uses `no_wizard=True` flag in the archival request context to suppress individual wizards.
- Rehired employees (unarchived) have no special rehire record; they return to active status with cleared departure info.
