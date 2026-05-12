# Feature Specification: Leave Accrual Plan Management

**Feature Branch**: `003-leave-accrual-plans`  
**Created**: May 11, 2026  
**Status**: Draft  
**Input**: Leave Accrual Plan Management - As an HR Manager I want to configure leave accrual plans So that leave balances can grow automatically over time

## User Scenarios & Testing

### User Story 1 - Create and Configure Accrual Plans (Priority: P2)

HR managers need to create and configure leave accrual plans that define how employee leave balances grow over time. Plans are company-specific, name-optional (defaulting to "Unnamed Plan"), and can include multiple accrual levels (milestones) for progressive accrual.

**Why this priority**: Accrual plans are essential for organizations with progressive leave policies (seniority-based, role-based, or time-based accrual). However, this is a configuration activity (not daily operational) and some organizations use static allocations instead. Moderately common requirement.

**Independent Test**: Can be tested by creating a plan with and without name (verify default applied), linking to leave type (verify company derived), and verifying basic properties are set. Works independently from accrual execution.

**Acceptance Scenarios**:

1. **Given** an HR manager creating a leave accrual plan without specifying a name, **When** the plan is created, **Then** the name field defaults to "Unnamed Plan".

2. **Given** a leave type linked to company "Tech Corp", **When** an HR manager creates an accrual plan for that leave type, **Then** the accrual plan's company_id is automatically set to "Tech Corp" (derived from leave type).

3. **Given** an accrual plan with multiple accrual levels (milestones) configured, **When** the level_count is computed, **Then** it equals the number of distinct accrual level records linked to the plan.

4. **Given** an HR manager duplicating an existing accrual plan named "Seniority Plan", **When** the duplicate is created, **Then** the new plan's name is "Seniority Plan (copy)".

---

### User Story 2 - Define Accrual Levels with Progressive Rules (Priority: P2)

Accrual plans contain multiple levels (milestones) that define accrual amounts at different employee tenure points (e.g., 0-2 years: 10 days/year, 2-5 years: 15 days/year). Each level specifies when it applies and how many days accrue, supporting seniority-based or service-based accrual progression.

**Why this priority**: Progressive accrual is a common benefit strategy in many organizations, especially for seniority-based policies. More complex than flat allocation but essential for fairness in mature organizations.

**Independent Test**: Can be tested by creating a plan, adding multiple levels with different tenure thresholds and accrual amounts, and verifying levels are properly linked and counted. Works independently.

**Acceptance Scenarios**:

1. **Given** an accrual plan with one accrual level, **When** show_transition_mode is computed, **Then** it is False (transition mode is unnecessary with only one level).

2. **Given** an accrual plan with two or more accrual levels, **When** show_transition_mode is computed, **Then** it is True (displaying transitions between levels).

3. **Given** an HR manager creating a new accrual level within a plan that supports carryover, **When** the level creation form is opened, **Then** the context includes default values for carryover settings, gain_time (accrual frequency), and added_value_type (fixed days vs. percentage).

4. **Given** an accrual plan with accrual levels defined, **When** an HR manager opens a specific level for editing, **Then** the system displays the accrual level configuration record (hr.leave.accrual.level) for that level.

---

### User Story 3 - Configure Carryover Rules at Plan Level (Priority: P2)

Accrual plans can define carryover rules that allow unused accrued days to carry forward to the next period. The plan specifies carryover_month (when carryover occurs), carryover_day (which day of month), and whether carryover is enabled, with carryover_day clamped to the maximum days in the specified month (e.g., Feb 31 → Feb 29).

**Why this priority**: Carryover at the accrual plan level improves flexibility for organizations with different policies per accrual type (some types allow carryover, others don't). Important but depends on having accrual execution infrastructure.

**Independent Test**: Can be tested by creating a plan with February carryover_day set to 31 (should clamp to 29), and verifying the clamped value is stored/displayed. Works independently.

**Acceptance Scenarios**:

1. **Given** an accrual plan configured with carryover_month = February (month 2) and carryover_day = 31, **When** the plan is saved and carryover_day is computed, **Then** it is clamped to 29 (February's maximum day) and stored as 29.

2. **Given** an accrual plan with carryover enabled, **When** an HR manager creates accrual levels, **Then** each level can inherit carryover settings from the plan or override them.

3. **Given** an accrual plan with carryover disabled, **When** accrual execution occurs, **Then** unused accrued days do not carry forward to the next period.

---

### User Story 4 - Track Employee and Level Counts (Priority: P1)

The system must automatically compute and display employees_count (number of distinct employees with allocations under this plan) and level_count (number of accrual milestones). These provide visibility into plan scope and configuration complexity.

**Why this priority**: Count fields are critical for HR visibility and reporting. Used frequently in dashboards and list views. Low-complexity feature but high usability value.

**Independent Test**: Can be tested by creating a plan with allocations for specific employees, computing employees_count (should match distinct employees), and verifying it updates when allocations are added/removed. Works independently.

**Acceptance Scenarios**:

1. **Given** an accrual plan with allocations for 2 distinct employees (each may have multiple allocations), **When** employees_count is computed, **Then** it equals 2 (distinct count, not total allocation count).

2. **Given** an accrual plan with allocations for employees A, B, and C, **When** the allocation for employee B is canceled or deleted, **Then** employees_count is recomputed and equals 2.

3. **Given** an accrual plan with 3 accrual levels configured, **When** level_count is displayed, **Then** it shows 3.

4. **Given** an HR manager viewing an accrual plan list, **When** they see plans with employees_count and level_count columns, **Then** these values provide quick insight into plan scope without opening each plan.

---

### User Story 5 - Link Accrual Plans to Allocations (Priority: P2)

Accrual plans are linked to leave allocations created under that plan. The system must prevent deletion of a plan that has active (non-cancelled) allocations, ensuring data integrity and allowing HR to maintain audit trails.

**Why this priority**: Data integrity is essential. Prevents orphaned allocations and ensures consistency. Important safeguard but only relevant during plan lifecycle management (not frequent operations).

**Independent Test**: Can be tested by linking allocations to a plan, attempting to delete (should fail with validation error), canceling allocations, then retrying delete (should succeed). Works independently.

**Acceptance Scenarios**:

1. **Given** an accrual plan linked to one or more active (non-cancelled) leave allocations, **When** an HR manager attempts to delete the plan, **Then** a validation error is raised stating that linked allocations must be canceled or deleted before the plan can be removed.

2. **Given** an accrual plan with all linked allocations in "cancel" state, **When** the plan deletion is attempted, **Then** the deletion is allowed and succeeds.

3. **Given** an accrual plan with both active and canceled allocations, **When** deletion is attempted, **Then** the validation checks only active allocations and prevents deletion if any exist.

---

### User Story 6 - Manage Plan Employees via Linked Allocations (Priority: P3)

HR managers should be able to view a list of employees participating in an accrual plan (i.e., employees with allocations under that plan) and quickly navigate to their employee records for viewing/editing.

**Why this priority**: Useful operational convenience. Reduces navigation steps but not essential for core functionality. Nice-to-have UI enhancement.

**Independent Test**: Can be tested by opening an accrual plan, clicking "View Employees" action, and verifying the resulting list shows only employees with allocations under that plan. Works independently.

**Acceptance Scenarios**:

1. **Given** an accrual plan with allocations for employees A, B, and C, **When** the "Open Plan Employees" action is clicked, **Then** the system opens a list of those 3 employee records (hr.employee) with relevant details.

2. **Given** an accrual plan with no allocations, **When** "Open Plan Employees" is clicked, **Then** an empty employee list is shown (no error, just empty).

3. **Given** an employee with multiple allocations under the same plan, **When** the employee list is displayed, **Then** the employee appears once (distinct list, not one entry per allocation).

---

### Edge Cases

- What happens if an accrual plan is created but no levels are added before trying to use it?
- How should the system behave if carryover_month is set to a value outside 1-12?
- What occurs if an employee's accrual plan is changed while they have existing allocations?
- How are accruals calculated if an employee's tenure or role changes mid-year?
- What is the behavior if two accrual plans try to accrue for the same leave type in the same period?

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow HR managers to create leave accrual plans by specifying a leave type, and optionally a custom name; if name is not provided, system MUST default to "Unnamed Plan".

- **FR-002**: System MUST automatically derive company_id from the linked leave type's company; the accrual plan's company cannot be manually changed and must always match the leave type's company.

- **FR-003**: System MUST support multiple accrual levels (milestones) per plan, each defining conditions (e.g., tenure threshold, role, anniversary date) and accrual amounts (days per period, or percentage).

- **FR-004**: System MUST compute level_count as the number of distinct accrual level records linked to the accrual plan; this value is displayed in UI and updated whenever levels are added/removed.

- **FR-005**: System MUST compute employees_count as the number of distinct employees with active allocations under the plan; this count excludes canceled allocations and updates dynamically.

- **FR-006**: System MUST display show_transition_mode as True only if the plan has two or more accrual levels; if level_count <= 1, show_transition_mode is False.

- **FR-007**: System MUST support a carryover_enabled flag per plan; if True, the plan allows accrued days to carry forward based on carryover rules.

- **FR-008**: System MUST support carryover_month (month of year, 1-12) and carryover_day (day of month, 1-31) configuration; carryover_day MUST be clamped to the maximum day of the specified carryover_month (e.g., February 31 → 29/28).

- **FR-009**: System MUST validate carryover_month is in the range 1-12; invalid months MUST be rejected with a validation error.

- **FR-010**: System MUST prevent deletion of an accrual plan if it is linked to any active (non-cancelled state) leave allocations; deletion attempt MUST raise a validation error with a clear message explaining the constraint.

- **FR-011**: System MUST allow deletion of an accrual plan only if all linked allocations are in "cancel" state (or no allocations exist).

- **FR-012**: System MUST support plan duplication; when a plan is duplicated, the new plan's name is automatically set to "[Original Name] (copy)" and all accrual levels are cloned.

- **FR-013**: System MUST provide an "Open Plan Employees" action that displays a list of employee records (hr.employee) for all distinct employees with active allocations under the plan.

- **FR-014**: System MUST provide a "Create Accrual Level" action that opens an accrual level creation form with default context values for carryover_enabled, gain_time (accrual frequency), and added_value_type derived from the plan's configuration.

- **FR-015**: System MUST provide an "Open Accrual Level" action that, given a selected accrual level, opens the level record (hr.leave.accrual.level) for editing.

- **FR-016**: System MUST link accrual plans to leave allocations via a plan_id field on allocation records; accrual is triggered based on the linked plan's configuration.

- **FR-017**: System MUST support company-level accrual plan scoping; accrual plans are company-specific and only apply to employees in that company.

### Key Entities

- **Leave Accrual Plan**: Master configuration for progressive leave accrual. Key attributes: name (with default 'Unnamed Plan'), company_id (derived from leave type), holiday_status_id (leave type), carryover_enabled, carryover_month, carryover_day (clamped), level_count (computed), employees_count (computed), show_transition_mode (computed based on level count).

- **Accrual Level / Milestone**: Defines a tier of progressive accrual within a plan. Key attributes: accrual_plan_id, threshold_tenure (months), additional_value (days to gain), gain_time (e.g., monthly, per anniversary), added_value_type (fixed/percentage), carryover_enabled (can override plan-level), sequence/order.

- **Leave Allocation**: Links to accrual plan. Key attributes: accrual_plan_id, employee_id, linked to leave requests for deduction.

- **Company**: Constraint for plan scope. Key attributes: id, name.

## Success Criteria

### Measurable Outcomes

- **SC-001**: HR managers can create a new accrual plan with all mandatory configuration in under 3 minutes without errors.

- **SC-002**: Accrual plan list displays employees_count and level_count accurately for 100% of plans, with count updates within 5 seconds of allocation/level changes.

- **SC-003**: Plan duplication (including all linked accrual levels) completes successfully for 100% of duplicate requests within 2 seconds.

- **SC-004**: Deletion prevention for plans with active allocations works correctly for 100% of deletion attempts, with clear validation error message displayed within 1 second.

- **SC-005**: Carryover_day clamping is enforced for 100% of config changes; invalid days for the specified month are automatically corrected and stored with no user errors.

- **SC-006**: Accrual level creation with default context values succeeds for 100% of users, reducing manual form-filling effort.

- **SC-007**: Employee list actions display correct distinct employees for 100% of plans, with no duplicates or orphaned employees.

- **SC-008**: Accrual rules execute correctly for plans with multiple levels, applying the correct level's accrual amount based on employee tenure/condition for 100% of accrual runs.

- **SC-009**: Company-level scoping is enforced: accrual plans and their allocations are restricted to the linked company for 100% of operations.

- **SC-010**: Plan name defaulting ("Unnamed Plan") is applied for 100% of unnamed plan creations, with no blank name fields in final output.

## Assumptions

- **User & Data**: Leave types and companies are pre-existing and maintained separately; accrual plans are always linked to a valid leave type at creation.

- **Accrual Execution**: Actual accrual execution (automated allocation creation based on accrual plan rules) is handled by a separate scheduler/batch process and is not in scope for this spec (FRs handle configuration only).

- **Allocation Linking**: Leave allocations are created separately but reference an accrual_plan_id to enable tracking and validation.

- **Company Derivation**: Company is always derived from leave type and cannot be manually overridden; this ensures plan consistency and prevents misconfiguration.

- **Day Clamping Logic**: Carryover_day clamping uses the number of days in the specified carryover_month for the current year; leap year February (29 days) is considered.

- **Level Ordering**: Accrual levels are ordered by sequence/tenure threshold; the system applies the applicable level based on employee tenure at accrual time.

- **Scope Boundaries**: Accrual plan versioning (changing rules mid-year and maintaining prior versions) is out of scope for MVP; changes apply to all future accruals. Conditional accrual (role-based, department-based conditions) is out of scope—levels are tenure-based only in MVP.

- **Integration Context**: Accrual plans integrate with leave allocation module (FR-016) and a separate accrual scheduler/executor (not in this spec); UI actions (Open Employees, Create Level) follow standard Odoo action patterns.

- **Validation & Constraints**: Technical validation of carryover_month is 1-12 range; business rule validation (e.g., "plan must have at least one level before use") is handled by downstream accrual execution, not plan creation.
