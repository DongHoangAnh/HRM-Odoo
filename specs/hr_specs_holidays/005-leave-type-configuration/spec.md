# Feature Specification: Leave Type Configuration and Validation

**Feature Branch**: `005-leave-type-configuration`  
**Created**: May 11, 2026  
**Status**: Draft  
**Input**: Leave Type Configuration and Validation - As an HR Manager I want to configure leave types correctly So that leave requests, balances, and accruals behave as intended

## User Scenarios & Testing

### User Story 1 - Create Leave Types with Defaults (Priority: P1)

HR managers need to create leave types (e.g., Annual Leave, Sick Leave, Unpaid Leave) with sensible defaults to quickly establish a basic leave type that works for employees. The system applies default values for request unit, allocation requirement, and active status.

**Why this priority**: Leave types are foundational. Every organization needs to create them before requests, allocations, or accruals can work. Required for all other leave management features.

**Independent Test**: Can be tested by creating a new leave type without specifying optional fields, and verifying defaults are applied (active=True, request_unit="day", requires_allocation=True). Works independently.

**Acceptance Scenarios**:

1. **Given** an HR manager creating a new leave type named "Annual Leave" without specifying other settings, **When** the leave type is created, **Then** it is active by default, default_request_unit is set to "day", and requires_allocation defaults to True.

2. **Given** a new leave type, **When** created without specifying active status, **Then** the leave type is active by default (available for employees to request immediately).

3. **Given** a leave type with requires_allocation = True, **When** an employee tries to request this type, **Then** the system validates that a valid allocation exists before allowing the request.

4. **Given** a leave type with requires_allocation = False (e.g., Sick Leave), **When** an employee requests this type, **Then** no allocation validation occurs and the request is allowed.

---

### User Story 2 - Validate Leave Type Eligibility (Priority: P1)

The system must compute has_valid_allocation for each leave type-employee combination, indicating whether the employee has a valid (non-expired, validated) allocation for that leave type. This controls whether the employee can request that leave type.

**Why this priority**: This is the gating logic for leave requests. If misconfigured, either employees can't request valid leave or invalid leave gets approved. Critical for system correctness.

**Independent Test**: Can be tested by checking has_valid_allocation with/without allocations, and verifying leave request behavior matches. Works independently.

**Acceptance Scenarios**:

1. **Given** a leave type with requires_allocation = False (unlimited), **When** has_valid_allocation is checked for any employee, **Then** the result is True regardless of allocation records.

2. **Given** a leave type with requires_allocation = True and the employee has a validated allocation, **When** has_valid_allocation is checked, **Then** the result is True.

3. **Given** a leave type with requires_allocation = True and the employee has no allocation (or only invalid/expired), **When** has_valid_allocation is checked, **Then** the result is False.

4. **Given** a leave type with requires_allocation = True and the employee has a draft (unvalidated) allocation, **When** has_valid_allocation is checked, **Then** the result is False (draft allocations don't count).

---

### User Story 3 - Search Valid Leave Types (Priority: P2)

HR users need to search for leave types associated with valid employee allocations to understand which leave types are actually active in the organization. The system provides a search domain that filters leave types based on whether the current employee has valid allocations.

**Why this priority**: Useful reporting and configuration tool. Helps identify which leave types are actually in use vs. just defined. Moderately common HR function.

**Independent Test**: Can be tested by creating allocations for specific leave types, running the valid-leaves search, and verifying only types with valid allocations are returned. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with a valid allocation for "Annual Leave" but no allocation for "Sabbatical", **When** the "valid leave types" search is executed, **Then** Annual Leave is included in results and Sabbatical is excluded.

2. **Given** multiple employees with allocations for the same leave type, **When** the valid types search is executed for a specific employee, **Then** only that employee's valid types are considered.

3. **Given** an employee with both valid and expired allocations for the same leave type, **When** the valid types search is executed, **Then** the leave type is still included (at least one valid allocation exists).

---

### User Story 4 - Prevent Conflicting Configurations (Priority: P2)

The system must enforce validation rules that prevent HR managers from creating invalid configurations. These rules include: absence types cannot allow stacking requests, worked-time types must support accrual, allocation requirements cannot change after leaves are taken, etc.

**Why this priority**: Data integrity protection. Invalid configurations can cause systemic failures (e.g., employees being able to approve their own leave, allocations being modified mid-leave). Essential safeguards.

**Independent Test**: Can be tested by attempting invalid configurations and verifying validation errors are raised. Works independently.

**Acceptance Scenarios**:

1. **Given** a leave type marked as "absence" (is_absent = True), **When** an HR manager tries to enable allow_request_on_top (stacking multiple concurrent leaves), **Then** a validation error is raised explaining that absence types cannot allow overlapping requests.

2. **Given** a leave type with time_type = "other" (worked time), **When** an HR manager tries to disable eligible_for_accrual_rate, **Then** a validation error is raised because worked-time types must remain eligible for accrual calculations.

3. **Given** a leave type that already has employees with approved leaves, **When** an HR manager tries to change requires_allocation from True to False (or vice versa), **Then** a UserError is raised indicating that the change is blocked due to existing leave history.

4. **Given** existing leaves that overlap with public holidays for a leave type, **When** an HR manager tries to change include_public_holidays_in_duration, **Then** a validation error is raised because the configuration change would alter historical leave calculations.

---

### User Story 5 - Derive Company Country (Priority: P2)

Leave type country should be automatically derived from the leave type's company, ensuring consistency. The system computes country_id based on the linked company.

**Why this priority**: Data consistency and configuration simplification. Prevents manual misalignment where a leave type's country differs from its company. Important for compliance and reporting.

**Independent Test**: Can be tested by creating/linking to companies with different countries, verifying country_id auto-updates. Works independently.

**Acceptance Scenarios**:

1. **Given** a leave type linked to a company in Belgium, **When** the country_id is computed, **Then** it automatically reflects Belgium.

2. **Given** a leave type linked to a company, **When** the company country changes, **Then** the leave type's country_id automatically updates to match.

3. **Given** a leave type, **When** an attempt is made to manually override the country (if the field permits), **Then** the system either prevents it or resets it to match the company on save.

---

### User Story 6 - Configure Negative Balance Rules (Priority: P2)

Some organizations allow employees to go negative on leave balance (e.g., borrow from next year). The system supports an allows_negative flag and requires a positive max_allowed_negative value to specify the limit. This prevents invalid configurations like negative allowance with zero limit.

**Why this priority**: Supports flexible leave policies. Many organizations allow negative balances with limits. Important for policy flexibility but not all organizations use it.

**Independent Test**: Can be tested by enabling allows_negative and checking that max_allowed_negative must be positive (non-zero) or validation fails. Works independently.

**Acceptance Scenarios**:

1. **Given** a leave type with allows_negative enabled, **When** an HR manager sets max_allowed_negative to 0, **Then** a validation error is raised requiring a positive value.

2. **Given** a leave type with allows_negative = True and max_allowed_negative = 5, **When** an employee with -3 balance available requests 2 more days, **Then** the request is allowed (total -5, at limit).

3. **Given** the same configuration with an employee at -5 balance, **When** they request 1 more day, **Then** the request is rejected (would exceed -5 limit).

4. **Given** a leave type with allows_negative = False, **When** an employee balance reaches 0, **Then** further leave requests are blocked regardless of max_allowed_negative setting.

---

### User Story 7 - Control Dashboard Visibility (Priority: P3)

HR managers can hide certain leave types from employee dashboard lists (e.g., administrative leave types not commonly used by employees) while keeping them selectable in leave request forms. The hide_on_dashboard flag controls visibility without preventing selection.

**Why this priority**: UX enhancement that reduces clutter in employee dashboards. Not critical but improves usability for organizations with many leave types.

**Independent Test**: Can be tested by hiding a type on dashboard, checking it doesn't appear in dashboard list, but verifying it's still available in leave request dropdown. Works independently.

**Acceptance Scenarios**:

1. **Given** a leave type with hide_on_dashboard = True, **When** an employee opens the time-off dashboard, **Then** this leave type is not shown in the balance/allocation list.

2. **Given** the same leave type with hide_on_dashboard = True, **When** the employee opens a leave request form, **Then** the leave type is still selectable in the leave type dropdown.

3. **Given** a hidden leave type, **When** an employee has active leaves of this type, **Then** the active leaves are still displayed (hiding only affects the type selector, not the actual leaves).

---

### Edge Cases

- What happens when a company's country changes? Should all linked leave types update automatically?
- How should the system behave if max_allowed_negative is set but allows_negative is False?
- What occurs if a manager tries to change active status while employees have pending leaves?
- How are leave types with different allocation units (days vs. hours) handled in accrual—must they be separate?
- What is the behavior if multiple leave types are configured as "default" for the same company?

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow HR managers to create leave types by specifying name, and leave type MUST be created in active status by default.

- **FR-002**: System MUST apply default_request_unit = "day" for newly created leave types (employees request leave in days unless otherwise specified).

- **FR-003**: System MUST set requires_allocation = True by default for new leave types; this can be changed at creation time but affects validation behavior.

- **FR-004**: System MUST compute has_valid_allocation as True if requires_allocation = False (unlimited leaves) regardless of allocation records.

- **FR-005**: System MUST compute has_valid_allocation as True if requires_allocation = True AND the employee has at least one validated (state = "validate") allocation for the leave type.

- **FR-006**: System MUST compute has_valid_allocation as False if requires_allocation = True AND the employee has no validated allocations (draft, refused, or no allocations all result in False).

- **FR-007**: System MUST prevent enabling allow_request_on_top (stacking) on absence-type leave types; attempting to do so MUST raise a validation error explaining the constraint.

- **FR-008**: System MUST require worked-time leave types (time_type = "other") to remain eligible_for_accrual_rate = True; attempting to disable this flag MUST raise a validation error.

- **FR-009**: System MUST prevent changing requires_allocation value if there are existing approved leaves (state = "validate" or "refuse") for the leave type in the system; the change MUST raise a UserError explaining the data integrity constraint.

- **FR-010**: System MUST prevent changing include_public_holidays_in_duration if there are existing leaves overlapping with configured public holidays for the leave type; the change MUST raise a validation error.

- **FR-011**: System MUST compute country_id from the leave type's company_id; country CANNOT be manually overridden and MUST always match the company's country.

- **FR-012**: When a leave type's company changes, system MUST automatically update country_id to match the new company's country.

- **FR-013**: System MUST validate that if allows_negative = True, max_allowed_negative MUST be a positive number (> 0); setting to 0 or negative MUST raise a validation error.

- **FR-014**: System MUST enforce negative balance limits: if allows_negative = False, employees cannot go negative. If allows_negative = True, employees can go negative down to max_allowed_negative.

- **FR-015**: System MUST support hide_on_dashboard flag; when True, the leave type is excluded from employee dashboard balance/allocation displays.

- **FR-016**: System MUST ensure hide_on_dashboard does NOT prevent the type from appearing in leave request forms; employees can still request hidden types.

- **FR-017**: System MUST ensure active leaves (state = "validate") are displayed even if the leave type is hidden on dashboard; visibility control applies only to the type selector.

- **FR-018**: System MUST provide a domain/filter for valid leave types that returns leave types for which the employee has valid allocations (requires_allocation = False or has_valid_allocation = True).

- **FR-019**: System MUST support is_absent type flag; absence types affect presence state computation and may have restricted configurations (no stacking, etc.).

- **FR-020**: System MUST support color coding per leave type for calendar and dashboard display; color is optional but recommended for usability.

### Key Entities

- **Leave Type / Holiday Status**: Master configuration for leave categories. Key attributes: name, company_id, country_id (computed from company), active (default True), requires_allocation (default True), default_request_unit ("day" or "hour"), is_absent (boolean), allow_request_on_top (blocked for absence types), eligible_for_accrual_rate (mandatory True for worked time), include_public_holidays_in_duration, allows_negative, max_allowed_negative (must be positive if allows_negative=True), hide_on_dashboard, color.

- **Employee**: References leave types via requests and allocations. Computed field: has_valid_allocation (per leave type).

- **Leave Request**: References leave type; constrains based on leave type configuration.

- **Leave Allocation**: References leave type; created per leave type per employee.

- **Company**: Drives leave type country derivation.

## Success Criteria

### Measurable Outcomes

- **SC-001**: HR managers can create a new leave type with correct defaults in under 1 minute without errors.

- **SC-002**: Leave type validation rules block invalid configurations for 100% of validation violations, with clear error messages displayed within 1 second.

- **SC-003**: has_valid_allocation computation is accurate for 100% of leave type-employee combinations, computed in real-time within 500ms.

- **SC-004**: Country derivation from company is correct for 100% of leave types; country updates automatically when company changes within 1 second.

- **SC-005**: Negative balance enforcement is accurate for 100% of leave requests; employees cannot exceed negative limits, and positive balance requirements are enforced when allows_negative = False.

- **SC-006**: Dashboard visibility control correctly hides/shows leave types for 100% of employees; hidden types don't appear in dashboards but remain selectable in forms.

- **SC-007**: Change-blocking validations (allocation requirement, holiday duration) prevent invalid modifications for 100% of attempts when existing leave data exists.

- **SC-008**: Valid leave type search returns accurate results for 100% of searches, filtering correctly by allocation validity.

- **SC-009**: Leave type configuration changes that affect all dependent leaves (requests, allocations, accruals) are validated and prevented when data would be corrupted for 100% of cases.

- **SC-010**: Color coding is consistently applied across dashboard, calendar, and list views for 100% of leave types with defined colors.

## Assumptions

- **User & Data**: HR managers have permissions to create and modify leave types; companies and their countries are pre-configured.

- **Defaults**: Default_request_unit defaults to "day" to match most organizational practices; organizations using hours can specify differently at creation time. Requires_allocation defaults to True (safer default; can be changed to False for unlimited types).

- **Color Support**: Color coding is optional; leave types without assigned colors use a default/neutral color. Color format is standard hex code or color name per Odoo conventions.

- **Allocation History**: Validation that prevents changing requires_allocation checks for any approved leaves (state = "validate" or "refuse"); draft leaves don't trigger the validation (draft is reversible).

- **Company-Country Linkage**: Country field is always computed from company; manual override is technically prevented (field is readonly or ignored on save). If use case requires per-leave-type country override, that requires a separate flag.

- **Absence Type Implications**: is_absent flag affects presence state computation (in dashboard spec) and may have restricted configurations (no stacking per this spec). Other implications (e.g., paid vs. unpaid) are handled separately.

- **Negative Balance Details**: allows_negative applies globally to the leave type (all employees). max_allowed_negative is a threshold (most negative allowed, e.g., -5 means balance can reach -5 but not -6). Organization-level or employee-level overrides are out of scope for MVP.

- **Worked Time Definition**: time_type = "other" or similar flag denotes worked time; such types must remain eligible_for_accrual_rate. This may integrate with HR modules defining time types in a related system.

- **Scope Boundaries**: Leave type variants (e.g., different approval chains per department) are out of scope; approval chains are managed separately. Multi-country leave type variants are out of scope for MVP—one leave type per company.

- **Integration Context**: Leave type configuration integrates with leave request validation (001), allocation validation (002), accrual plan rules (003), and dashboard visibility (004). Technical constraints (e.g., field readonly logic, validation hooks) follow standard Odoo patterns.
