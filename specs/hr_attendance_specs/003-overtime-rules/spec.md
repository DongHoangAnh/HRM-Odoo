# Feature Specification: Overtime Rules and Ruleset Configuration

**Feature Branch**: `004-overtime-rules`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Configure overtime rules and rulesets so overtime can be generated according to company policy"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create and Organize Policy Rulesets (Priority: P1)

As an HR attendance manager, I need to create overtime rulesets tied to a company and country so that overtime policy can be organized and applied in the correct context.

**Why this priority**: Rulesets are the foundation for all overtime policy evaluation and must exist before rules can be applied.

**Independent Test**: Can be tested by creating a ruleset, verifying its default values, and confirming it counts attached rules correctly.

**Acceptance Scenarios**:

1. **Given** a company and country are available, **When** an HR attendance manager creates a ruleset, **Then** the ruleset is created as active and scoped to that company and country.
2. **Given** a ruleset has attached overtime rules, **When** the manager opens the ruleset, **Then** the ruleset displays the correct rule count.
3. **Given** a new ruleset is created without an explicit combination mode, **When** it is saved, **Then** it defaults to the standard maximum-rate combination mode.

---

### User Story 2 - Define Overtime Eligibility Rules (Priority: P1)

As an HR attendance manager, I need to define overtime rules for quantity-based and timing-based scenarios so that overtime generation follows company policy.

**Why this priority**: Policy rules determine when overtime exists and how it should be evaluated.

**Independent Test**: Can be tested by creating valid and invalid rules for quantity and timing conditions, then verifying validation behavior and displayed summaries.

**Acceptance Scenarios**:

1. **Given** a quantity-based rule is being created, **When** the rule uses contract-based expected hours and includes a period, **Then** the rule is accepted.
2. **Given** a quantity-based rule is missing required expected-hours data or its period, **When** it is saved, **Then** a validation error explains what is missing.
3. **Given** a timing-based schedule rule is being created, **When** the rule includes a work schedule and valid hour boundaries, **Then** the rule is accepted.

---

### User Story 3 - Apply Rule Timing and Scope (Priority: P2)

As an HR attendance manager, I need overtime rules to apply only within the intended timing scope so that overtime does not trigger outside policy boundaries.

**Why this priority**: Correct applicability prevents incorrect overtime generation across working days, non-working days, leave periods, and schedule-based windows.

**Independent Test**: Can be tested by creating rules with different timing types and verifying whether they apply for working days, weekends, leave, or schedule-based intervals.

**Acceptance Scenarios**:

1. **Given** a work-day rule is configured, **When** overtime is generated on a working day, **Then** the rule applies.
2. **Given** a non-work-day rule is configured, **When** overtime is generated on a non-working day, **Then** the rule applies.
3. **Given** a leave rule is configured, **When** the employee is on approved leave, **Then** the rule applies to the leave interval.

---

### User Story 4 - Regenerate Overtime from Policy Changes (Priority: P2)

As an HR attendance manager, I need to regenerate overtime from a ruleset so that existing attendances are re-evaluated when policy changes.

**Why this priority**: Policy changes must be able to update eligible history without requiring manual rework.

**Independent Test**: Can be tested by triggering regeneration on a ruleset and confirming that eligible attendances are recomputed according to active rules.

**Acceptance Scenarios**:

1. **Given** a ruleset is linked to employee versions, **When** regeneration is triggered, **Then** overtime records are recomputed for eligible attendances.
2. **Given** active overtime rules have changed, **When** regeneration completes, **Then** results follow the current rule definitions.
3. **Given** a ruleset contains multiple rules, **When** evaluation runs, **Then** the combined result respects the configured rate combination mode.

---

### Edge Cases

- Timing start or stop values outside a valid hour range are rejected with a clear validation message.
- A quantity-based rule without required expected-hours information is rejected unless contract-based hours are explicitly enabled.
- A timing-based schedule rule without a work schedule is rejected.
- Multiple overtime rules apply to the same interval and the combined result follows the configured aggregation mode.
- Regeneration is limited to eligible attendances so historical records are not unintentionally modified.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow HR attendance managers to create overtime rulesets scoped to a company and country.
- **FR-002**: System MUST default new rulesets to an active state unless explicitly configured otherwise.
- **FR-003**: System MUST display the number of overtime rules attached to a ruleset.
- **FR-004**: System MUST support rate combination modes for rulesets, including a default maximum-rate mode and an additive sum mode.
- **FR-005**: System MUST allow creation of quantity-based overtime rules with required period settings.
- **FR-006**: System MUST allow quantity-based rules to derive expected hours from contract-based work patterns when enabled.
- **FR-007**: System MUST reject quantity-based rules that omit required expected-hours information when contract-based derivation is disabled.
- **FR-008**: System MUST allow creation of timing-based overtime rules with valid schedule and boundary information.
- **FR-009**: System MUST reject timing-based rules that are missing a work schedule when the rule depends on schedule timing.
- **FR-010**: System MUST reject timing boundaries that fall outside valid hour-of-day values.
- **FR-011**: System MUST clearly describe configured rule details in the rule information display.
- **FR-012**: System MUST apply timing-based rules according to working-day, non-working-day, leave, and schedule-based conditions.
- **FR-013**: System MUST support regeneration of overtime records for eligible attendances from a ruleset.
- **FR-014**: System MUST evaluate regenerated overtime using the active overtime rules at the time of regeneration.
- **FR-015**: System MUST combine overlapping rule results according to the ruleset aggregation mode.
- **FR-016**: System MUST prevent invalid configurations from being saved and MUST provide user-facing validation messages.
- **FR-017**: System MUST preserve existing valid attendance history outside eligible regeneration scope.

### Key Entities *(include if feature involves data)*

- **Overtime Ruleset**: A company- and country-scoped policy container that groups overtime rules and controls combination behavior.
- **Overtime Rule**: A policy definition that determines when overtime applies based on quantity or timing conditions.
- **Rule Applicability Context**: The employee, date, schedule, leave, and working-day context used to evaluate whether a rule applies.
- **Regeneration Result**: The outcome of recomputing overtime for eligible attendances using the active ruleset.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of new rulesets are created with the correct company, country, and default active state in accepted test scenarios.
- **SC-002**: 100% of invalid rule configurations are blocked with a clear validation message.
- **SC-003**: At least 98% of valid quantity-based and timing-based rule creation scenarios pass without manual correction.
- **SC-004**: At least 95% of rule-application test cases return the expected applicability result for working-day, non-working-day, leave, and schedule contexts.
- **SC-005**: Regeneration requests complete with all eligible attendances recomputed in 100% of tested policy-change scenarios.
- **SC-006**: HR managers can identify a ruleset’s rule count and combination mode in a single review step in standard usability tests.

## Assumptions

- Company and country records already exist for the policy context being configured.
- HR attendance managers are authorized to create and edit overtime rulesets and rules.
- Valid working-hour boundaries are defined on a 24-hour basis for timing rules.
- Contract-based expected hours are available when rules rely on contract schedules.
- Regeneration is intended only for eligible attendances and does not override explicitly protected historical records.
