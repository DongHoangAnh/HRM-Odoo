# Feature Specification: Employee Overtime Management and Tracking

**Feature Branch**: `003-manage-overtime`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Track and manage employee overtime from attendance with approval workflow, policy checks, and attendance synchronization"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Capture and Compute Overtime (Priority: P1)

As an HR user, I need overtime to be derived from attendance and/or entered manually so that extra working hours are captured accurately.

**Why this priority**: Without reliable overtime capture, approval, payroll, and compliance workflows cannot function.

**Independent Test**: Can be tested by creating attendance and manual overtime examples, then confirming overtime quantities and weekly totals are correct.

**Acceptance Scenarios**:

1. **Given** an employee works beyond standard daily hours, **When** overtime is computed, **Then** overtime hours equal worked hours above the expected baseline.
2. **Given** an employee has no computed overtime for a day, **When** an authorized HR user adds manual overtime, **Then** a new overtime line is created for that date and employee.
3. **Given** overtime exists across multiple days, **When** weekly overtime is summarized, **Then** total overtime equals the sum of daily overtime lines.

---

### User Story 2 - Overtime Approval Lifecycle (Priority: P1)

As an HR manager, I need overtime to move through approval states so that validated hours are separated from unapproved or refused hours.

**Why this priority**: Approval state controls what is eligible for compensation and downstream payroll impact.

**Independent Test**: Can be tested by creating overtime lines in pending state, approving/refusing them, and verifying validated totals and states update correctly.

**Acceptance Scenarios**:

1. **Given** an overtime line is pending review, **When** it is approved, **Then** its status becomes approved and its duration contributes to validated overtime totals.
2. **Given** an overtime line is pending review, **When** it is refused, **Then** its status becomes refused and its duration is excluded from validated overtime totals.
3. **Given** one attendance has mixed linked overtime states, **When** aggregate overtime status is computed, **Then** the attendance status remains pending review.

---

### User Story 3 - Policy Enforcement and Compensation Outcomes (Priority: P2)

As an HR manager, I need overtime rules and compensation handling so that policy limits and conversion outcomes are applied consistently.

**Why this priority**: Policy enforcement ensures legal/compliance consistency and predictable employee compensation outcomes.

**Independent Test**: Can be tested by applying rulesets with thresholds/time boundaries and converting approved overtime to compensation outcomes.

**Acceptance Scenarios**:

1. **Given** overtime exceeds a policy threshold, **When** policy validation runs, **Then** the excess is flagged and a warning is shown.
2. **Given** a rule applies only to specific periods, **When** overtime falls outside that period, **Then** the rule does not apply to that overtime.
3. **Given** approved overtime is designated for time-off compensation, **When** conversion is performed, **Then** the employee leave balance increases by the converted amount.

---

### User Story 4 - Attendance Synchronization and Oversight (Priority: P2)

As an HR attendance officer, I need linked attendance records to reflect overtime updates immediately so that attendance views remain accurate and actionable.

**Why this priority**: HR decisions are made from attendance screens, so stale overtime values create operational risk.

**Independent Test**: Can be tested by linking overtime lines to attendance records and changing line status/duration to verify attendance aggregates recompute.

**Acceptance Scenarios**:

1. **Given** an overtime line is linked to attendance, **When** the overtime status changes, **Then** linked attendance overtime status recalculates accordingly.
2. **Given** an overtime line duration changes, **When** recalculation occurs, **Then** linked attendance overtime and expected-hour values update.
3. **Given** an overtime line references an employee and matching attendance start time, **When** linkage is resolved, **Then** the related attendance is included in linked overtime computation.

---

### Edge Cases

- Overtime line with stop time earlier than start time is rejected with a clear validation message.
- Company policy defaults differ by validation mode; new overtime lines start in pending review for manager-validated companies and approved for auto-approved companies.
- Overtime line has no matching attendance record for the same employee/time; overtime remains valid but is flagged as unlinked for review.
- A single attendance links to overtime lines with approved and refused states; aggregate attendance status remains pending review until fully consistent.
- Manual duration and computed duration diverge after edits; system reconciles values based on policy-defined precedence and auditability rules.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST compute overtime hours from attendance duration relative to policy-defined expected hours.
- **FR-002**: System MUST allow authorized HR users to create manual overtime lines for employees and dates.
- **FR-003**: System MUST maintain overtime statuses with at least pending review, approved, and refused states.
- **FR-004**: System MUST set overtime aggregate status on attendance based on linked overtime line states.
- **FR-005**: System MUST include only approved overtime durations in validated overtime totals.
- **FR-006**: System MUST exclude refused overtime durations from validated overtime totals.
- **FR-007**: System MUST support approve and refuse actions for eligible overtime lines and record the resulting state changes.
- **FR-008**: System MUST apply company overtime validation mode to determine default status for newly created overtime lines.
- **FR-009**: System MUST enforce chronological validity where overtime end time is later than start time.
- **FR-010**: System MUST support linking overtime lines to attendance records using employee identity and attendance-time alignment rules.
- **FR-011**: System MUST recompute linked attendance overtime status and hour aggregates whenever linked overtime status or duration changes.
- **FR-012**: System MUST support overtime rules and rulesets that apply based on thresholds and time-bound applicability windows.
- **FR-013**: System MUST warn when policy thresholds are exceeded and identify excess overtime.
- **FR-014**: System MUST support overtime compensation designation at least for time-off and monetary outcomes.
- **FR-015**: System MUST support converting approved overtime designated for time-off into employee leave balance adjustments.
- **FR-016**: System MUST present overtime status and overtime-hour summaries in attendance records.
- **FR-017**: System MUST provide role-aware manager context indicators for overtime review without bypassing authorization controls.
- **FR-018**: System MUST preserve overtime and attendance aggregate integrity after recalculation and updates.

### Key Entities *(include if feature involves data)*

- **Overtime Line**: Represents one overtime interval for an employee, with start/stop, duration, manual duration, status, and compensation designation.
- **Attendance Overtime Aggregate**: Represents attendance-level overtime summary fields such as overtime hours, validated overtime hours, and overtime status.
- **Overtime Rule**: Represents one policy condition that determines overtime eligibility by threshold and/or time boundaries.
- **Overtime Ruleset**: Represents an ordered policy set used to evaluate overtime outcomes for a company context.
- **Compensation Outcome**: Represents the intended overtime settlement path (time off or money) and resulting entitlement adjustment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of overtime lines enforce valid chronological windows (end after start) during create and update actions.
- **SC-002**: At least 98% of overtime computations in acceptance test scenarios match expected overtime totals at day and week levels.
- **SC-003**: 100% of approved overtime durations are included in validated overtime totals, and 0% of refused durations are included.
- **SC-004**: Linked attendance overtime fields reflect overtime status/duration updates within one recomputation cycle for 99% of tested update events.
- **SC-005**: HR managers can complete approve/refuse actions for a target overtime line in under 30 seconds in standard workflow tests.
- **SC-006**: For policy-threshold scenarios, 100% of overtime amounts above configured limits are flagged with visible warning indicators.

## Assumptions

- Standard expected working hours per employee/day are defined and available for overtime baseline calculations.
- HR roles with overtime approval authority are already configured.
- Leave balances can accept hour-based adjustments from approved overtime conversion.
- Overtime rules and rulesets are managed per company context and are active before policy validation is executed.
- Attendance and overtime records use consistent timezone interpretation for linking and duration calculations.
