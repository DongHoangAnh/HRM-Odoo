# Feature Specification: Leave Allocation and Balance Management

**Feature Branch**: `002-leave-allocation-balance`  
**Created**: May 11, 2026  
**Status**: Draft  
**Input**: Leave Allocation and Balance Management - As an HR Manager I want to manage leave allocations for employees So that employees have proper leave balances throughout the year

## User Scenarios & Testing

### User Story 1 - Create and Validate Leave Allocations (Priority: P1)

HR managers need to create leave allocations for employees specifying the type, number of days, and allocation period. Allocations start in draft state and only impact employee balances when validated by an authorized HR manager.

**Why this priority**: This is the foundation of the entire leave balance system. Without allocations, employees cannot request leave. Required daily by HR teams and affects every employee at the start of each period.

**Independent Test**: Can be tested by creating a leave allocation in draft state (verify no balance change), then validating it (verify balance increases). Works independently and delivers core HR functionality.

**Acceptance Scenarios**:

1. **Given** an HR manager has permissions to allocate leave, **When** they create an allocation with employee_id, holiday_status_id (leave type), number_of_days, date_from, and date_to, **Then** the allocation is created in "confirm" (draft) state and the employee's balance is not immediately affected.

2. **Given** a leave allocation in draft state, **When** an HR manager validates it, **Then** the allocation state changes to "validate" and the employee's leave balance increases by the allocated days.

3. **Given** a draft leave allocation, **When** an HR manager refuses it, **Then** the allocation state changes to "refuse" and no balance change occurs.

4. **Given** a validated allocation, **When** an HR officer edits the number_of_days in draft before validation, **Then** the change is saved and the balance reflects the updated amount upon re-validation.

---

### User Story 2 - Deduct Approved Leave from Allocation (Priority: P1)

When a leave request is approved and moves to "validate" state, the system must automatically deduct the approved leave days from the employee's leave allocation. This maintains accurate real-time balance tracking.

**Why this priority**: Critical for preventing over-allocation. Without automatic deduction, the balance tracking breaks down immediately. Core business logic that must be bulletproof.

**Independent Test**: Can be tested by creating an allocation (20 days), approving a leave request (5 days), and verifying allocation is decremented to 15 days. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with 20 days annual leave allocation (validated state), **When** a leave request for 5 days is approved (transitions to "validate" state), **Then** the allocation balance is decreased by 5 days and virtual_remaining_leaves shows 15 days.

2. **Given** an approved leave request, **When** it is canceled (state → "cancel"), **Then** the deducted days are restored to the allocation balance.

3. **Given** a leave request pending approval, **When** it is still in pending state, **Then** the allocation balance is not yet affected (pending leaves may be included in virtual_remaining_leaves projection but not deducted from actual balance).

4. **Given** multiple allocations covering different periods, **When** a leave spans multiple allocation periods, **Then** the system deducts from the appropriate allocation(s) in chronological order.

---

### User Story 3 - Support Multiple Allocations per Employee (Priority: P1)

An employee may have multiple allocations for the same leave type covering different periods (e.g., 10 days Jan-Jun, 10 days Jul-Dec). The system must aggregate these correctly and track each allocation independently.

**Why this priority**: Many organizations divide annual allocations by period (half-year, quarters) or split between regular and bonus allocations. Supporting this flexibility is essential for real-world HR practices. Affects how most mid-to-large organizations structure their leave management.

**Independent Test**: Can be tested by creating two allocations for same employee/type with different periods, checking total balance (20 days), and verifying leaves are deducted from the correct period. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with two validated allocations (10 days Jan-Jun, 10 days Jul-Dec for same leave type), **When** the total balance is computed, **Then** total available is 20 days across both allocations.

2. **Given** multiple allocations for the same employee and leave type in different years, **When** each is checked, **Then** they are tracked separately by year and do not merge.

3. **Given** a 5-day leave request spanning Feb and Aug with two period-based allocations, **When** the leave is approved, **Then** the system deducts days from the applicable allocation period (Feb request uses Jan-Jun allocation, Aug uses Jul-Dec).

4. **Given** an employee with allocations in "confirm", "validate", and "refuse" states, **When** balance is computed, **Then** only "validate" state allocations contribute to available balance.

---

### User Story 4 - Enforce Allocation Expiry (Priority: P2)

Allocations have explicit expiry dates. Unused days from an expired allocation cannot be used for new leave requests. The system must mark expired allocations and exclude them from balance calculations after the expiry date.

**Why this priority**: Expiry enforcement is a critical control for budget planning and compliance (many jurisdictions require leave to be taken periodically). Important for all organizations but slightly less frequent than daily allocation creation/validation.

**Independent Test**: Can be tested by setting expiry date, creating allocation, waiting past expiry date, attempting leave request (should fail or require carryover), and verifying unused days are marked expired. Works independently.

**Acceptance Scenarios**:

1. **Given** an allocation with date_to = 2025-03-31 and 10 unused days, **When** the current date is checked on 2025-04-01, **Then** the allocation is marked as expired and the unused days are not available for new requests.

2. **Given** an expired allocation with unused days, **When** a leave request is attempted for a date after expiration, **Then** the system rejects the request and indicates that balance for the desired dates has expired.

3. **Given** multiple allocations where some are expired and others active, **When** balance is computed, **Then** only active (non-expired) allocations are included.

4. **Given** an allocation approaching expiry, **When** an HR officer runs a report, **Then** expiring allocations are highlighted for visibility and carryover planning.

---

### User Story 5 - Support Carryover with Limits (Priority: P2)

Leave types may support carryover of unused days to the next period or year, often with a maximum carryover limit. The system must implement carryover rules specified per leave type and enforce maximum carryover limits during year-end processing.

**Why this priority**: Carryover is common in many organizations but not universal. Significant business logic but involves batch processing (year-end) rather than real-time operations. Important for annual cycle management.

**Independent Test**: Can be tested by configuring carryover rules, creating allocation with 5 unused days, processing year-end, and verifying 5 days carry forward (or limited to maximum). Works independently.

**Acceptance Scenarios**:

1. **Given** a leave type configured to support carryover with no limit, **When** an allocation expires with 5 unused days and year-end processing is triggered, **Then** 5 days are automatically carried over to the next year's allocation.

2. **Given** a leave type with carryover_maximum = 3 days, **When** an allocation expires with 5 unused days, **Then** only 3 days carry over to next year and 2 days expire without carry.

3. **Given** a carryover that occurred in the prior year, **When** the new year's allocation is created, **Then** the carryover days are included in the new allocation balance.

4. **Given** multiple allocations expiring in the same year, **When** carryover processing runs, **Then** each allocation's unused days are subject to the carryover limit independently.

5. **Given** an allocation with carryover disabled, **When** it expires with unused days, **Then** the unused days are lost and not carried forward.

---

### User Story 6 - Manage Allocations with Approval Workflows (Priority: P2)

Some organizations require allocations to follow an approval workflow (draft state, validation by HR manager, refuse option). The system must support draft creation, explicit validation action, and refusal with no balance impact until validation.

**Why this priority**: Approval workflows add organizational control and audit trails but are not always required (some organizations auto-validate). Important for compliance-focused organizations; moderately common requirement.

**Independent Test**: Can be tested by creating draft allocation (no balance change), validating (balance updates), and refusing (no balance change). Works independently from validation models that auto-validate on creation.

**Acceptance Scenarios**:

1. **Given** an allocation workflow-enabled leave type, **When** an HR officer creates an allocation, **Then** it enters "confirm" state and the employee does not immediately see balance increase.

2. **Given** a draft allocation, **When** reviewed and validated by an HR manager, **Then** state changes to "validate" and the balance is updated.

3. **Given** a draft allocation, **When** an HR manager reviews and refuses it, **Then** state changes to "refuse", no balance change occurs, and the employee is notified.

4. **Given** a refused allocation, **When** an HR officer creates a replacement allocation with the correct data, **Then** the new allocation can be validated independently.

---

### User Story 7 - Enable Allocation at Department or Bulk Level (Priority: P2)

HR managers should be able to allocate leave to all employees in a department (or bulk-select employees) in a single operation, reducing manual effort during annual allocation cycles.

**Why this priority**: Bulk allocation significantly improves HR efficiency for organizations with departments or cohorts. Very useful during budget cycles and annual resets but not needed for individual spot allocations. Moderately common requirement.

**Independent Test**: Can be tested by selecting a department, creating allocation to all members, and verifying each employee receives the allocation independently. Works standalone.

**Acceptance Scenarios**:

1. **Given** an HR manager wanting to allocate 20 days to all employees in the HR department, **When** they select the department and create the allocation, **Then** each employee in that department receives the 20-day allocation in their respective allocation record.

2. **Given** a bulk allocation, **When** created in draft state, **Then** each employee's allocation is created separately (not a single shared allocation) to allow independent tracking.

3. **Given** multiple departments, **When** allocations are created using bulk operation, **Then** department membership is validated to ensure correct allocation.

---

### User Story 8 - Validate Allocation Eligibility for Leave Requests (Priority: P1)

The system must track whether an employee has a valid (validated state) allocation for a specific leave type, and leave request creation should be blocked or flagged if no valid allocation exists (for leave types requiring allocation).

**Why this priority**: This is the gatekeeping logic that prevents employees from requesting leave with no budget. Critical control that runs on every leave request creation.

**Independent Test**: Can be tested by checking has_valid_allocation field with/without valid allocation, and verifying leave request creation is blocked appropriately. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with a validated allocation for Annual Leave, **When** has_valid_allocation is checked for Annual Leave, **Then** the flag is True and leave requests for this type are allowed.

2. **Given** an employee with no allocation (or only refused allocations), **When** has_valid_allocation is checked, **Then** the flag is False and leave request creation for that type should be blocked with a clear message.

3. **Given** an employee with an allocation in draft state (not yet validated), **When** has_valid_allocation is checked, **Then** the flag is False (since balance is not yet updated).

4. **Given** a leave type marked as "doesn't require allocation" (requires_allocation = False), **When** has_valid_allocation is checked, **Then** the field shows True for all employees regardless of allocation records.

---

### User Story 9 - Compute Virtual Remaining Leaves (Priority: P1)

The system must compute virtual_remaining_leaves as: total_allocation - approved_leave_deducted - pending_leave_requests. This projection shows employees how much leave they can still request, accounting for both approved usage and pending requests.

**Why this priority**: Virtual remaining balance is the key metric employees and managers view when planning leave. Shown on every dashboard and form. Essential for transparency and planning.

**Independent Test**: Can be tested by creating allocation (20), approving leave (5), submitting pending leave (3), and verifying virtual_remaining_leaves = 12. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with total_allocation = 20 days, approved_leave_deducted = 5 days, and pending_leave_requests = 3 days, **When** virtual_remaining_leaves is computed, **Then** it equals 12 days.

2. **Given** a pending leave request, **When** it is approved and transitions to "validate", **Then** it moves from pending projection to approved deduction and virtual_remaining_leaves is recalculated.

3. **Given** a pending leave request, **When** it is refused or canceled, **Then** it is removed from the projection and virtual_remaining_leaves increases back.

4. **Given** an employee with expired allocation, **When** virtual_remaining_leaves is computed, **Then** expired days are excluded from the total.

---

### Edge Cases

- What happens when leave allocation date_from and date_to overlap with another allocation for the same employee/type?
- How should the system handle allocations created retroactively (past dates)?
- What is the behavior if carryover processing is run multiple times for the same year-end?
- How are fractional days handled (e.g., 20.5 days allocation)?
- What occurs if an employee is transferred to a different department after allocation but before leave is taken?

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow HR managers with allocation permissions to create leave allocations by specifying employee_id, holiday_status_id (leave type), number_of_days, date_from, and date_to.

- **FR-002**: Leave allocations MUST be created in "confirm" (draft) state and MUST NOT affect employee balance until explicitly validated.

- **FR-003**: System MUST allow HR managers to validate draft allocations, transitioning from "confirm" → "validate" state and updating the employee's leave balance by the allocated amount.

- **FR-004**: System MUST allow HR managers to refuse allocations, transitioning from "confirm" → "refuse" state with no balance impact.

- **FR-005**: System MUST prevent balance calculation from including refused or draft allocations; only "validate" state allocations count toward available balance.

- **FR-006**: System MUST support multiple allocations for the same employee and leave type with different date ranges (periods), aggregating them correctly for balance calculation.

- **FR-007**: System MUST track allocations separately by year; allocations in different years do not merge and can have different amounts.

- **FR-008**: On leave request approval (transitions to "validate" state), system MUST automatically deduct the number_of_days from the applicable employee allocation balance.

- **FR-009**: System MUST apply deductions to the correct allocation period if multiple allocations exist; days are deducted from allocations matching the leave date range in chronological order.

- **FR-010**: When an approved leave is canceled (transitions to "cancel" state), system MUST restore the deducted days back to the allocation balance.

- **FR-011**: For leave types marked as "requires_allocation" = True, system MUST check has_valid_allocation (existence of "validate" state allocation) before allowing leave requests.

- **FR-012**: For leave types marked as "requires_allocation" = False, system MUST NOT check allocation balance and MUST allow unlimited leave requests of that type.

- **FR-013**: System MUST flag allocations as "expired" when the current date exceeds their date_to value; expired allocations MUST NOT be used for balance calculations or new leave requests.

- **FR-014**: System MUST support carryover rules per leave type: carryover_enabled (boolean) and carryover_maximum (number of days) that specifies the maximum days that can carry over to the next period.

- **FR-015**: On year-end or period-end processing, system MUST identify unused days in expiring allocations and create new allocations in the next period with carryover amount (limited by carryover_maximum).

- **FR-016**: System MUST allow carryover_maximum to be 0 (no carryover allowed); unused days above the maximum MUST be marked as expired without carrying forward.

- **FR-017**: System MUST support bulk allocation creation; when an allocation is created with department_id or employee_list, system MUST create individual allocation records for each employee in the department/list.

- **FR-018**: System MUST compute virtual_remaining_leaves as: total_validated_allocation - approved_leave_deducted - pending_leave_requests (for future-dated pending requests).

- **FR-019**: System MUST handle fractional allocations (e.g., 20.5 days) by storing and calculating days with decimal precision.

- **FR-020**: System MUST allow HR managers to edit number_of_days in draft allocations; edits MUST be applied when the allocation is validated (previously draft is discarded).

### Key Entities

- **Leave Allocation / Employee Leave Balance**: Represents days allocated to an employee for a specific leave type. Key attributes: employee_id, holiday_status_id (leave type), number_of_days, date_from, date_to, state (confirm/validate/refuse), created_date, validated_date. Tracks actual allocated balance.

- **Leave Type / Holiday Status**: Defines leave category properties. Key attributes: name, requires_allocation (boolean), approval_workflow (boolean, whether allocations require approval), carryover_enabled, carryover_maximum, color.

- **Allocation Carryover Rule**: Tracks carryover from one period to the next. Key attributes: source_allocation_id, target_allocation_id, carryover_days, carryover_date.

- **Leave Request**: Links to allocation for deduction. Key attributes: employee_id, holiday_status_id, date_from, date_to, number_of_days, state, first_approver_id (used to trigger allocation deduction on approval).

- **Department**: Used for bulk allocation. Key attributes: employee_ids, name.

## Success Criteria

### Measurable Outcomes

- **SC-001**: HR managers can create and validate a leave allocation for one employee in under 1 minute without errors.

- **SC-002**: Bulk allocation to a 100-person department is created and distributed to all employees within 5 seconds.

- **SC-003**: Leave balance is updated within 1 second of allocation validation for 99.9% of allocations.

- **SC-004**: Approved leave deductions are reflected in allocation balance within 1 second of approval state transition for 99.9% of leaves.

- **SC-005**: Carryover processing for year-end completes without errors for 100% of organizations with carryover-enabled leave types.

- **SC-006**: Expired allocations are correctly excluded from balance calculations for 100% of leave request validations after expiry date.

- **SC-007**: Virtual remaining leaves calculation is accurate (total_allocation - approved - pending) for 100% of scenarios, including fractional days.

- **SC-008**: Multiple allocations per employee are aggregated correctly: total balance matches sum of individual "validate" state allocations for 100% of employees.

- **SC-009**: Allocations in draft state do not appear in employee-facing balance views; balance updates are visible only after validation for 100% of cases.

- **SC-010**: Carryover limits are enforced: maximum days carried over never exceed carryover_maximum setting, with excess days expiring for 100% of carryover operations.

## Assumptions

- **User & Data**: Employee records and leave type master data are maintained separately and available for allocation creation; HR managers have been granted appropriate permissions for allocation operations.

- **Allocation Workflow**: Allocations may optionally require validation workflow (draft → validate) or may auto-validate based on leave type configuration; both patterns are supported.

- **Bulk Operations**: Bulk allocation creates a separate allocation record per employee for independent tracking; allocation is not shared (each employee's record can be validated/refused independently).

- **Period & Year Structure**: "Year" and "period" refer to the organization's fiscal/allocation year (e.g., Jan-Dec, Apr-Mar, or custom). Carryover processing runs annually per the organization's defined year-end date.

- **Leave Deduction Timing**: Approved leaves automatically deduct from allocation when entering "validate" state; pending leaves are projected but not deducted until approval.

- **Fractional Precision**: Fractional days (e.g., 20.5, 0.5) are supported in allocations and leave requests; system stores and calculates with decimal precision (typically 2 decimal places).

- **Expiry Enforcement**: Allocation expiry is determined by date_to field comparison to current date; expired allocations are automatically excluded from balance calculations without separate expiry logic.

- **Scope Boundaries**: Carryover limits are enforced per leave type globally (same limit for all employees); employee-specific carryover overrides are out of scope for MVP. Leave allocation history/audit is tracked via state transitions but detailed audit logging is handled separately.

- **Integration Context**: Leave allocation integrates with existing leave request approval workflow (FR-008 deduction trigger); employee data and leave type configuration are sourced from existing Odoo HR modules.
