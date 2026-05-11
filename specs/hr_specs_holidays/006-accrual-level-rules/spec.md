# Feature Specification: Accrual Level Rules and Scheduling

**Feature Branch**: `006-accrual-level-rules`  
**Created**: May 11, 2026  
**Status**: Draft  
**Input**: Accrual Level Rules and Scheduling - As an HR Manager I want to configure accrual plan levels precisely So that leave accrual happens on the correct schedule with the correct caps

## User Scenarios & Testing

### User Story 1 - Configure Accrual Scheduling (Priority: P2)

HR managers need to configure when accrual milestones trigger for employees. Configuration includes when the level applies (creation date vs. after N months tenure), and the frequency of accrual (weekly, monthly, yearly, etc.). The system computes the appropriate milestone date and transition point based on tenure thresholds.

**Why this priority**: Essential for seniority-based and tenure-based accrual. However, configuration complexity means this is slightly less frequently used than basic accrual plan creation. Moderately common requirement.

**Independent Test**: Can be tested by creating levels with different start counts (0 vs 3), verifying milestone_date computation, and confirming transition date calculations. Works independently.

**Acceptance Scenarios**:

1. **Given** an accrual level with start_count = 0 (applies from creation), **When** milestone_date is computed, **Then** it equals "creation" and the level applies immediately upon allocation creation.

2. **Given** an accrual level with start_count = 3 (applies after 3 months tenure), **When** milestone_date is computed, **Then** it equals "after" and the system uses start_count to calculate the transition date.

3. **Given** an accrual level with start_count = 3 months, **When** level transition date is computed from allocation start date (e.g., 2025-01-01), **Then** the transition date is exactly 3 months later (2025-04-01) and accrual begins on that date.

4. **Given** an accrual level with start_count = 18 months, **When** transition date is computed from 2025-01-01, **Then** it equals 2026-07-01 (18 months later).

---

### User Story 2 - Support Multiple Accrual Frequencies (Priority: P2)

Accrual can occur on different schedules: weekly (every Friday), monthly (15th of each month), bimonthly (15th and 30th), yearly (January 1st), or anniversary. The system validates frequency-specific requirements and computes next/previous milestones correctly.

**Why this priority**: Flexibility in accrual schedules is important for matching organizational needs. Different organizations use different accrual rhythms. Moderately complex but essential for realistic policies.

**Independent Test**: Can be tested by configuring levels with different frequencies, computing next milestone dates, and verifying they match frequency rules. Works independently.

**Acceptance Scenarios**:

1. **Given** a weekly accrual level set to Friday, **When** next accrual date is computed from a Monday (day X), **Then** the result is the following Friday.

2. **Given** a weekly level, **When** saved without specifying a week_day, **Then** a validation error is raised requiring the day of week to be specified.

3. **Given** a monthly accrual level with first_day = 16, **When** next accrual date is computed from the 10th of any month, **Then** the result is the 16th of that month.

4. **Given** a bimonthly level with accrual on the 15th and 30th, **When** next accrual date is computed, **Then** the system returns the next occurrence (either 15th or 30th) in chronological order.

5. **Given** a bimonthly level configured with first_day = 15 and second_day = 10, **When** saved, **Then** a validation error is raised explaining that first_day must be less than second_day.

6. **Given** a yearly level set to January 1st, **When** previous accrual date is computed from March 10th of the same year, **Then** the result is January 1st of that year.

---

### User Story 3 - Apply Automatic Day Clamping (Priority: P2)

For months with fewer than 31 days, day numbers must be clamped to the month's maximum. For example, February 31 becomes February 29 (or 28 in non-leap years). The system applies clamping automatically to prevent invalid dates.

**Why this priority**: Essential for date logic correctness. Without clamping, February 31 would be invalid. Common issue in any calendar-based system.

**Independent Test**: Can be tested by setting monthly/yearly day to 31 for February, saving, and verifying it clamps to 29. Works independently.

**Acceptance Scenarios**:

1. **Given** an accrual level with first_month = February (2) and first_month_day = 31, **When** saved, **Then** first_month_day is automatically clamped to 29 (February maximum in leap years, 28 in non-leap years).

2. **Given** an accrual level with yearly_month = February and yearly_day = 31, **When** saved, **Then** yearly_day is clamped to 29.

3. **Given** an accrual level with second_month = August and second_month_day = 31, **When** saved, **Then** second_month_day remains 31 (August has 31 days).

4. **Given** an employee with allocation starting in non-leap year, **When** next yearly accrual on Feb 29 is computed, **Then** the system uses Feb 28 as the equivalent milestone date.

---

### User Story 4 - Derive Accrual Unit from Leave Type (Priority: P1)

Accrual added_value_type (days vs. hours) must match the linked leave type's request unit. The system derives added_value_type from the leave type automatically; all levels within a plan must use the same unit for consistency.

**Why this priority**: Data integrity and consistency. If one level accrues days and another hours, the system breaks. Automatic derivation prevents misconfiguration.

**Independent Test**: Can be tested by setting accrual plan to hour-based leave type, verifying levels inherit hours unit, and checking validation prevents mixing. Works independently.

**Acceptance Scenarios**:

1. **Given** an accrual plan linked to a leave type using "hour" as request unit, **When** the first level is created, **Then** added_value_type is automatically set to "hour" (derived from leave type).

2. **Given** an accrual plan with multiple levels, **When** the first level uses day-based accrual (added_value_type = "day"), **Then** subsequent levels automatically inherit "day" and cannot be changed to "hour" (or vice versa).

3. **Given** an attempt to configure the second level with a different unit than the first, **When** saved, **Then** a validation error is raised indicating all levels must use the same unit.

---

### User Story 5 - Validate Accrual Amounts and Caps (Priority: P1)

Accrual amounts and limits must be positive (non-zero) when configured. The system validates that added_value > 0, and when accrual caps are enabled (maximum_leave or maximum_leave_yearly), they must be positive values.

**Why this priority**: Critical for business logic. Zero or negative accrual amounts would cause system failures. Non-negotiable validation.

**Independent Test**: Can be tested by trying to set added_value = 0 or caps = 0 and verifying validation errors. Works independently.

**Acceptance Scenarios**:

1. **Given** a level being created without specifying added_value, **When** the form defaults added_value to 0, **Then** a validation error prevents saving, requiring a positive number.

2. **Given** a level with cap_accrued_time enabled, **When** maximum_leave is set to 0, **Then** a UserError is raised requiring a positive cap value.

3. **Given** a level with cap_accrued_time_yearly enabled, **When** maximum_leave_yearly is set to 0, **Then** a validation error is raised.

4. **Given** a level with positive added_value, **When** the form is saved, **Then** no validation error occurs and accrual will accrue the specified amount.

---

### User Story 6 - Configure Carryover and Cap Rules (Priority: P2)

Accrual levels can define how unused accrued days are handled (carryover to next period, expiration, or capping). The system validates carryover configuration: if carryover_options = "limited", postpone_max_days must be positive.

**Why this priority**: Important for fair leave policies. Many organizations enforce carryover limits or caps to prevent excessive accumulation. Moderately complex configuration.

**Independent Test**: Can be tested by enabling carryover limits and verifying postpone_max_days must be positive. Works independently.

**Acceptance Scenarios**:

1. **Given** a level with carryover_options = "limited" and action_with_unused_accruals = "all", **When** postpone_max_days is set to 0, **Then** a validation error is raised requiring a positive carryover limit.

2. **Given** a level with carryover_options = "no_rollover", **When** the level is used in an accrual run, **Then** unused accrued days are not carried forward and are lost.

3. **Given** a level with carryover_options = "limited" and postpone_max_days = 5, **When** accrual execution occurs, **Then** only up to 5 unused days carry forward to the next period.

---

### User Story 7 - Support Accrual Validity and Expiry (Priority: P2)

Accrual can be configured to expire if unused within a certain time period (accrual validity). The system validates that accrual_validity_count (days/months/years) is positive when validity is enabled.

**Why this priority**: Supports use-it-or-lose-it policies. Some organizations require employees to use accrued leave within a period or it expires. Moderately common in regulated industries.

**Independent Test**: Can be tested by enabling accrual_validity and setting count to 0, verifying validation error. Works independently.

**Acceptance Scenarios**:

1. **Given** a level with accrual_validity enabled and accrual_validity_period = "month", **When** accrual_validity_count is set to 0, **Then** a validation error is raised requiring a positive duration.

2. **Given** a level with accrual_validity = True and accrual_validity_count = 12, **When** accrual is executed, **Then** accrued days expire if not used within 12 months (or configured period).

---

### User Story 8 - Support Bidirectional Milestone Date Conversion (Priority: P3)

The system supports converting between two representations of milestone dates: a human-readable form (creation vs. after) and a numeric start_count (months). Converting milestone_date to its inverse should produce the correct start_count and vice versa.

**Why this priority**: UX convenience for configuration forms. Allows HR managers to think in terms of "creation" or "after N months" interchangeably. Nice-to-have but improves usability.

**Independent Test**: Can be tested by setting milestone_date = "creation", computing inverse (should get start_count = 0), and vice versa. Works independently.

**Acceptance Scenarios**:

1. **Given** a level with milestone_date = "creation", **When** the inverse conversion is applied, **Then** start_count becomes 0.

2. **Given** a level with start_count = 18, **When** milestone_date is computed, **Then** it equals "after" and further conversions use start_count as the source.

3. **Given** a form with milestone_date dropdown, **When** "creation" is selected, **Then** start_count is internally set to 0 (and vice versa for UI consistency).

---

### User Story 9 - Compute Sequence Order (Priority: P3)

Within a multi-level accrual plan, levels are ordered by their sequence number. The system derives sequence from start_count to maintain chronological order. For example, a level starting after 2 months has sequence = 60 (2 months × 30 days). This automatically orders levels for progression.

**Why this priority**: Useful for displaying levels in UI and determining progression. However, this can be computed on-the-fly or cached. Nice-to-have for organization purposes.

**Independent Test**: Can be tested by creating levels with different start_counts and verifying sequence values increase chronologically. Works independently.

**Acceptance Scenarios**:

1. **Given** a level with start_count = 2 months, **When** sequence is computed, **Then** it equals 60 (2 × 30 days).

2. **Given** multiple levels in the same plan with start_counts = 0, 2, 5, **When** levelsorting by sequence, **Then** sequence values are 0, 60, 150 (maintaining chronological order).

---

### Edge Cases

- What happens if an employee's allocation start date is before the accrual plan was created (retroactive allocation)?
- How should the system handle timezone-sensitive date calculations for international employees?
- What occurs when a level's frequency changes (e.g., from monthly to weekly) with existing accruals?
- How are leap years handled in day clamping (Feb 29 in leap years vs. 28 in others)?
- What is the behavior if an employee transfers and their level progression is affected?

## Requirements

### Functional Requirements

- **FR-001**: System MUST compute milestone_date as "creation" if start_count = 0; milestone occurs immediately upon allocation creation.

- **FR-002**: System MUST compute milestone_date as "after" if start_count > 0; milestone occurs start_count months after allocation creation.

- **FR-003**: System MUST compute level_transition_date by adding start_count months to the allocation start date; for example, allocation on 2025-01-01 with start_count = 18 transitions on 2026-07-01.

- **FR-004**: System MUST support bidirectional conversion between milestone_date (creation/after) and start_count; setting milestone_date = "creation" sets start_count = 0 and vice versa.

- **FR-005**: System MUST compute added_value_type from the linked leave type's request unit (day or hour); all levels in a plan MUST use the same unit derived from the leave type.

- **FR-006**: System MUST enforce that no level can override added_value_type; if a level attempts a different unit than the first level, system MUST raise a validation error.

- **FR-007**: System MUST clamp day-of-month values to the month's maximum days; for example, February 31 → 29 (leap year) or 28 (non-leap year).

- **FR-008**: System MUST clamp first_month_day, second_month_day, and yearly_day independently when set; each is validated against its respective month's length.

- **FR-009**: System MUST support multiple accrual frequencies: weekly (requires week_day to be specified), monthly (first_day, optionally second_day), bimonthly (requires first_day < second_day), yearly (month + day), anniversary (month + day relative to anniversary).

- **FR-010**: System MUST validate weekly frequency: if frequency = "weekly", week_day MUST be specified (Monday-Sunday); saving without week_day MUST raise a validation error.

- **FR-011**: System MUST validate bimonthly frequency: if frequency = "bimonthly", first_day MUST be less than second_day; if first_day >= second_day, raise a validation error explaining the ordering requirement.

- **FR-012**: System MUST compute next_accrual_date based on accrual frequency and current date:
  - Weekly: advance to next occurrence of the configured weekday
  - Monthly: use first_day (or second_day if first has passed)
  - Bimonthly: use the next occurrence of first_day or second_day
  - Yearly: use the configured month and day

- **FR-013**: System MUST compute previous_accrual_date (reverse of next_accrual_date) to find the most recent milestone before a given date.

- **FR-014**: System MUST validate added_value (accrual amount per period) is strictly positive (> 0); zero or negative values MUST raise a validation error.

- **FR-015**: System MUST validate cap_accrued_time: if enabled, maximum_leave MUST be a positive number; zero value MUST raise a UserError.

- **FR-016**: System MUST validate cap_accrued_time_yearly: if enabled, maximum_leave_yearly MUST be positive; zero MUST raise a validation error.

- **FR-017**: System MUST validate carryover limits: if carryover_options = "limited", postpone_max_days MUST be positive; zero MUST raise a validation error.

- **FR-018**: System MUST validate accrual_validity: if accrual_validity is enabled, accrual_validity_count MUST be positive (> 0); zero MUST raise a validation error.

- **FR-019**: System MUST compute sequence number for ordering levels in a plan; sequence is derived from start_count (e.g., 2 months = 60 days sequence) to maintain chronological progression of levels.

- **FR-020**: System MUST provide a "Save and Add New Level" action that saves the current level and reopens the level creation form for the parent accrual plan, improving UX for configuring multi-level plans.

### Key Entities

- **Accrual Level / Accrual Plan Level**: Defines a tier within an accrual plan. Key attributes: accrual_plan_id, sequence (computed), milestone_date (creation/after, computed), start_count (months until level applies), frequency (weekly/monthly/bimonthly/yearly/anniversary), week_day (for weekly), first_month_day, second_month_day (clamped), yearly_month, yearly_day (clamped), added_value (accrual amount, > 0), added_value_type (day/hour, derived from leave type), cap_accrued_time, maximum_leave (caps maximum accrued days), cap_accrued_time_yearly, maximum_leave_yearly, carryover_options (none/unlimited/limited), postpone_max_days (carryover limit, must be positive if limited), accrual_validity (boolean), accrual_validity_count, accrual_validity_period (day/month/year).

- **Accrual Plan**: References levels. Key attributes: leave type (drives added_value_type for all levels).

- **Leave Type**: Provides request unit (day/hour) that determines added_value_type for all levels.

## Success Criteria

### Measurable Outcomes

- **SC-001**: HR managers can configure a multi-level accrual plan (3+ levels with different frequencies) in under 5 minutes without validation errors.

- **SC-002**: Day clamping is applied correctly for 100% of date configurations; February 31 automatically becomes 29/28 without user intervention.

- **SC-003**: Frequency validation prevents invalid configurations (weekly without weekday, bimonthly with unordered days) for 100% of save attempts, with clear error messages within 1 second.

- **SC-004**: Next accrual date calculations are accurate for 100% of frequencies (weekly, monthly, bimonthly, yearly), computing correctly within 500ms.

- **SC-005**: Level progression is correct: transition dates match tenure thresholds (e.g., 18 months from allocation start), and accrual amount changes at transitions for 100% of allocations.

- **SC-006**: Accrual unit (day/hour) consistency is enforced for 100% of multi-level plans; mixing units is prevented with validation errors.

- **SC-007**: Cap and validity rules are accurate: cap prevents accumulation beyond maximum for 100% of accruals, validity expires unused days within timeout for 100% of cases.

- **SC-008**: Carryover limits are enforced: limited carryover carries over only up to postpone_max_days for 100% of year-end processes.

- **SC-009**: Milestone date conversion (creation ↔ after + start_count) is bidirectional and consistent for 100% of conversions.

- **SC-010**: Save and Add New Level action seamlessly allows configuring multiple levels, improving HR efficiency for bulk accrual plan setup.

## Assumptions

- **Accrual Scheduling**: Accrual execution (automated creation of accruals on computed dates) is handled by a separate scheduler/batch process, not in this spec. This spec defines configuration and date computation only.

- **Leap Year Handling**: Day clamping uses the actual number of days in each month per the calendar, accounting for leap years (Feb 29 in leap years, Feb 28 otherwise).

- **Timezone Handling**: Date calculations use the company's or employee's configured timezone; details are deferred to implementation.

- **Frequency Constraints**: Each frequency requires specific configuration:
  - Weekly: must specify week_day (0-6 for Monday-Sunday)
  - Monthly/Bimonthly: must specify first_day; bimonthly requires first_day < second_day
  - Yearly: must specify month and day (clamped)
  - Anniversary: uses employee's anniversary (hire date) + month/day offset

- **Unit Derivation**: added_value_type is derived from leave type and inherited by all levels; no per-level override is permitted.

- **Sequence Computation**: Sequence is computed as start_count (in months) × 30 for ordering purposes; this is approximate but sufficient for UI ordering. Actual tenure calculation uses precise date math.

- **Validation Timing**: Validations occur on save (not on field edit); this allows users to configure fields in any order before committing.

- **Carryover Semantics**: carryover_options values:
  - "no_rollover": unused days are lost
  - "unlimited": all unused days carry forward
  - "limited": only up to postpone_max_days carry forward

- **Scope Boundaries**: Employee-specific accrual adjustments (e.g., discretionary additions) are out of scope. Accrual recalculation on employee termination is handled separately. Accrual pause/resume on leave of absence is out of scope for MVP.

- **Integration Context**: Accrual level rules integrate with accrual plan configuration (003) and accrual execution scheduler (not in this spec). Date calculations follow standard calendar logic and assume system clock is reliable.
