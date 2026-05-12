# Feature Specification: Manage Employee Versions and Contracts

**Feature Branch**: `003-manage-versions-contracts`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Manage Employee Versions and Contract Management\n  As a Human Resources Manager\n  I want to create and manage employee versions with contract dates\n  So that I can track employee history and contract changes"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create and manage employee versions (Priority: P1)

HR managers must be able to create and retrieve employee versions at specific dates to track contract and employment history.

**Why this priority**: Version management is core to compliance, historical auditing, and supporting retroactive contract changes.

**Independent Test**: Create initial version on employee creation; create new version at specific dates; retrieve versions for dates and verify copy behavior from prior versions.

**Acceptance Scenarios**:

1. **Given** an employee is created, **When** the system initializes, **Then** an initial `hr.version` record is created with `date_version` = today and linked via `current_version_id`.
2. **Given** an employee exists, **When** a new version is created with `date_version` "2025-02-01", **Then** a new version record is created, copying data from the previous version.

---

### User Story 2 - Query versions and contracts for historical analysis (Priority: P1)

HR managers must retrieve versions and contracts for specific dates to support retroactive calculations, historical reporting, and date-based lookups.

**Why this priority**: Accurate historical data is required for payroll, leave accrual, and compliance audits.

**Independent Test**: Given multiple versions on different dates, retrieve the version for a query date and confirm the correct (most recent non-future) version is returned; retrieve current version; retrieve all contract date ranges.

**Acceptance Scenarios**:

1. **Given** employee has versions on 2024-01-01, 2024-06-01, 2025-01-01, **When** querying version for 2024-08-15, **Then** version dated 2024-06-01 is returned.
2. **Given** employee has multiple contracts, **When** querying for contract at date 2024-05-15, **Then** the matching (start, end) tuple is returned.

---

### User Story 3 - Contract lifecycle and status computation (Priority: P1)

HR managers must determine if an employee is in contract for any date, retrieve all contract periods, and handle permanent contracts (open-ended).

**Why this priority**: Contract status drives leave accrual, payroll eligibility, and termination workflows.

**Independent Test**: Set contract date ranges; query `is_in_contract` for dates within and outside ranges; handle permanent contracts with `contract_date_end = False`.

**Acceptance Scenarios**:

1. **Given** employee has contract 2024-01-01 to 2024-12-31, **When** checked on 2024-06-15, **Then** result is True; when checked on 2025-01-15, result is False.
2. **Given** employee has permanent contract (end = False), **When** any future date is checked, **Then** employee is always in contract.

---

### User Story 4 - Auto-compute current version and handle duplicates (Priority: P2)

HR manager actions must automatically compute the current version based on today's date, cache it for performance, and prevent duplicate versions on the same date.

**Why this priority**: Reduces manual date-picking logic and ensures consistent version resolution during rapid updates.

**Independent Test**: Change system date and verify `current_version_id` is auto-computed; attempt to create duplicate versions on same date and confirm deduplication.

**Acceptance Scenarios**:

1. **Given** employee has versions on different dates, **When** system date changes to 2025-06-01, **Then** `current_version_id` is automatically computed and stored.
2. **Given** a version exists on 2025-01-01, **When** attempting to create another on 2025-01-01, **Then** the existing version is returned without duplication.

---

### Edge Cases

- Retrieving version for a date before any version exists should handle gracefully (e.g., return first version or raise clear error).
- Contract with `contract_date_end = False` (permanent) should not be treated as expired.
- Multiple versions with the same `contract_date_start` must keep `contract_date_end` synchronized when updated.
- Gap detection in contract history must allow configurable threshold (e.g., > 4 days).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST create an initial `hr.version` record automatically when an employee is created, with `date_version` = today and reference it via `current_version_id`.
- **FR-002**: System MUST allow creating a new version at a specific date (`date_version`) and copy relevant data from the previous version.
- **FR-003**: System MUST retrieve the version for a given query date, returning the most recent non-future version.
- **FR-004**: System MUST compute and cache the current version based on today's date.
- **FR-005**: System MUST prevent duplicate versions on the same date, returning the existing version instead.
- **FR-006**: System MUST support updating version fields (`contract_wage`, `resource_calendar_id`, `contract_date_start`, `contract_date_end`) and inherit updated values to the parent employee.
- **FR-007**: System MUST determine if an employee is in contract for any given date based on contract date ranges.
- **FR-008**: System MUST handle open-ended (permanent) contracts where `contract_date_end = False`.
- **FR-009**: System MUST retrieve all contract date ranges (tuples of start and end) for an employee.
- **FR-010**: System MUST retrieve the contract (start, end) tuple for a specific query date.
- **FR-011**: System MUST synchronize `contract_date_end` across all versions with the same `contract_date_start` when one is updated.
- **FR-012**: System MUST support gap detection when retrieving the first contract date with configurable threshold (e.g., no_gap=True checks for gaps > 4 days).

### Key Entities *(include if feature involves data)*

- **hr.version**: versioned snapshot of employee data; attributes include `date_version` (effective date), `contract_date_start`, `contract_date_end`, `contract_wage`, `resource_calendar_id`, and link to parent employee.
- **hr.employee**: parent record; maintains `current_version_id` and inherits computed fields from the current version.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: New employee creation triggers automatic version record in 100% of cases.
- **SC-002**: Version retrieval for any date returns the correct (most recent non-future) version in 100% of queries.
- **SC-003**: Duplicate version prevention succeeds in 100% of attempts to create versions on the same date.
- **SC-004**: Current version auto-computation and caching completes in under 500ms for employees with up to 50 versions.
- **SC-005**: `is_in_contract` queries for contract date ranges return correct boolean values in 100% of test cases.
- **SC-006**: Contract synchronization updates all affected versions within 2 seconds in 95% of updates.
- **SC-007**: Gap detection with configurable threshold executes correctly in 100% of contract history queries.

## Assumptions

- Resource calendars (e.g., "Standard 40h", "Extended 45h") are pre-existing and managed by the organization module.
- Version history queries assume versions are ordered by `date_version`.
- Contract gaps are calculated as consecutive end-date to next start-date intervals; default threshold is > 4 days.
- Current version is recalculated on each employee fetch (or cached with TTL); caching strategy is transparent to API users.
- Permanent contracts use `contract_date_end = False` to indicate no end date; this is a data convention, not database NULL.
