# Feature Specification: Work Entry Generation, Validation, and Types

**Feature Branch**: `002-work-entry-generation`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: Work Entry Generation, Validation, and Types feature

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate Work Entries from Contracts and Attendance (Priority: P1)

HR managers need to automatically generate work entries for employees based on contracts and attendance data for a specified date range, enabling efficient bulk processing of work time records.

**Why this priority**: Automatic generation is essential for scalability. Without this capability, HR managers would need to manually create entries for hundreds or thousands of employees, which is impractical. This directly enables the entire payroll system to function at scale.

**Independent Test**: This can be fully tested independently by: providing a contract and attendance data for a date range (e.g., 2025-01-01 to 2025-01-31), running the generation process, and verifying work entries are created for the period with correct types and durations.

**Acceptance Scenarios**:

1. **Given** a contract with work rules and attendance data for January 2025, **When** I generate work entries from 2025-01-01 to 2025-01-31, **Then** work entries should be created for each day in the period based on contract and attendance.
2. **Given** existing work entries in a period, **When** I generate work entries with force=True, **Then** the work entries should be regenerated, replacing previous entries.
3. **Given** an employee with generated work entries in the system, **When** I check the has_work_entries flag, **Then** it should be True.

---

### User Story 2 - Access and Filter Work Entries by Employee (Priority: P1)

HR managers need to quickly access and view all work entries for a specific employee, with filtering by date range to enable record review and corrections.

**Why this priority**: This is essential for day-to-day HR operations. Without easy access to work entries, HR managers cannot review, validate, or troubleshoot payroll data.

**Independent Test**: This can be tested independently by: opening work entries for a specific employee and date range, verifying the list is filtered to show only that employee's entries for the specified dates.

**Acceptance Scenarios**:

1. **Given** an employee with work entries in January, **When** I open work entries for that employee, **Then** the system should show a filtered list of work entries for that employee and date range.
2. **Given** work entry records for multiple employees, **When** I filter by employee, **Then** only that employee's entries should be displayed.

---

### User Story 3 - Compute and Display Work Entry Names (Priority: P1)

The system must compute readable display names for work entries that include the type and relevant timing information, enabling HR managers to quickly understand entry details.

**Why this priority**: User experience is critical. Without readable display names, entries are difficult to understand and review. This directly impacts data accuracy through improved visibility.

**Independent Test**: This can be tested by: creating work entries of various types and verifying display names reflect the type and timing (e.g., "Normal Work - 8h00", "Sick Leave - 4h00").

**Acceptance Scenarios**:

1. **Given** a work entry of type "Normal Work" with 8 hours and interval from attendance data, **When** I compute the display name, **Then** it should show "Normal Work - 8h00" or similar format reflecting type and timing.
2. **Given** a work entry interval from attendance, **When** I compute the name, **Then** the name should be populated from the interval data (date, type, duration).

---

### User Story 4 - Validate Work Entry Duration (Priority: P1)

The system must validate that work entry durations are positive and do not exceed 24 hours, preventing invalid data from corrupting payroll calculations.

**Why this priority**: Duration validation is critical for data quality. Invalid durations would cause incorrect payroll calculations and must be caught at entry creation time.

**Independent Test**: This can be tested by: attempting to create entries with invalid durations (0, negative, > 24 hours) and verifying validation errors are raised.

**Acceptance Scenarios**:

1. **Given** an attempt to create a work entry with duration 0 or negative, **When** I try to save it, **Then** a validation error should be raised.
2. **Given** an attempt to create a work entry with duration 25 hours, **When** I try to save it, **Then** a validation error should be raised.

---

### User Story 5 - Split Work Entries Across Dates (Priority: P2)

The system must automatically split work entries that span midnight into separate entries for each date, ensuring each date has only entries within that day's boundaries.

**Why this priority**: While important for data accuracy, this refinement can be implemented after basic generation works. Splitting ensures that multi-day entries are properly broken down for daily payroll calculations.

**Independent Test**: This can be tested by: creating a work entry that must span two dates and verifying it's split into two separate entries, one for each date.

**Acceptance Scenarios**:

1. **Given** a work entry that must be split across calendar dates, **When** the split process runs, **Then** a new work entry should be created for the split interval and both should have correct durations.

---

### User Story 6 - Detect and Mark Work Entry Conflicts (Priority: P2)

The system must detect overlapping work entries for the same employee and mark them with state "conflict" to flag for manual resolution.

**Why this priority**: Conflict detection is important for data quality but can be implemented after basic generation. Marking conflicts enables HR managers to identify and resolve issues.

**Independent Test**: This can be tested by: creating overlapping entries for the same employee and verifying they're marked as conflict and can be reset.

**Acceptance Scenarios**:

1. **Given** overlapping work entries for the same employee, **When** the conflict check runs, **Then** the conflicting entries should be marked with state "conflict".
2. **Given** a work entry marked as conflict, **When** I reset the conflicting state, **Then** the work entry should return to draft state.

---

### User Story 7 - Configure Work Entry Types (Priority: P1)

The system must support configuration of work entry types (Normal Work, Sick Leave, etc.) with unique codes, country constraints, and work/non-work classification, enabling flexible work categorization.

**Why this priority**: Work entry types are foundational. Without proper type configuration, the system cannot accurately categorize work. Type configuration directly impacts payroll calculations and compliance.

**Independent Test**: This can be tested independently by: creating work entry types with unique codes, enforcing code uniqueness, applying country constraints, and verifying the work flag is mirrored by is_work property.

**Acceptance Scenarios**:

1. **Given** two work entry types with the same code, **When** I try to save them, **Then** a validation error should be raised enforcing code uniqueness.
2. **Given** a work entry type linked to a specific country, **When** I try to assign it to an incompatible company setup, **Then** a validation error should be raised.
3. **Given** a work entry type marked as work, **When** I check the is_work flag, **Then** it should be consistent with the work property.

---

### User Story 8 - Search Work Entries by Country (Priority: P2)

The system must support searching and filtering work entries by employee country, enabling country-specific payroll processing and compliance.

**Why this priority**: Country-based filtering is useful for compliance and reporting, but can be implemented after basic search/filtering works.

**Independent Test**: This can be tested by: searching work entries by country and verifying results are correctly filtered using the employee country relation.

**Acceptance Scenarios**:

1. **Given** work entries for employees in multiple countries, **When** I search work entries by country, **Then** the domain should resolve using the employee country relation and return only matching entries.

---

### User Story 9 - Integrate with Resource Calendar Attendance (Priority: P2)

The system must integrate with resource calendar attendance records, automatically assigning the default work entry type and copying leave values to work entries.

**Why this priority**: Calendar integration improves efficiency by automating work entry type assignment, but can be implemented after basic generation works.

**Independent Test**: This can be tested by: creating resource calendar attendance and verifying default work entry type is assigned, and copying leave values to preserve work entry fields.

**Acceptance Scenarios**:

1. **Given** a resource calendar attendance line, **When** I create it, **Then** the default work entry type should be automatically assigned.
2. **Given** a resource calendar leave interval, **When** I copy the leave values, **Then** the work entry fields should be preserved with leave details.

---

### User Story 10 - Generate Missing Work Entries via Scheduled Process (Priority: P3)

The system must support a scheduled (cron) process that automatically generates missing work entries for gaps in expected coverage, reducing manual intervention.

**Why this priority**: Automated gap-filling improves reliability but is optional for initial launch. Can be implemented as an enhancement after core generation works.

**Independent Test**: This can be tested by: creating scenarios where work entries have gaps, running the cron process, and verifying missing entries are generated.

**Acceptance Scenarios**:

1. **Given** there are gaps in expected work entries for an employee, **When** the cron process runs, **Then** missing work entries should be generated automatically for the gaps.

---

### User Story 11 - Protect Deletion of Active Work Entries (Priority: P2)

The system must prevent deletion of work entries in certain states (e.g., validated, payslip-included), only allowing deletion when state permits, protecting data integrity.

**Why this priority**: Deletion protection is important for data integrity but can be implemented as a refinement to core functionality.

**Independent Test**: This can be tested by: attempting to delete draft vs. validated entries and verifying deletion is prevented unless the state allows it.

**Acceptance Scenarios**:

1. **Given** a draft work entry, **When** I try to delete it, **Then** deletion should be prevented unless the state is one that allows deletion.

---

### Edge Cases

- What happens when generating entries for a leap year February? (Correct number of days should be processed; no data loss)
- How are contract changes during a generation period handled? (Entries should use the correct contract for each date based on contract validity)
- What occurs when attendance data conflicts with contract rules? (Conflict detection should flag for manual review)
- How does the system handle retroactive generation for past periods? (Allowed but requires confirmation; existing entries can be force-regenerated)
- What if work entry type is deleted while entries of that type exist? (Type becomes inactive; existing entries retain type reference)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST generate work entries for a specified date range based on contracts and attendance data
- **FR-002**: System MUST support force regeneration of work entries, replacing previous entries for a period
- **FR-003**: System MUST compute and display work entry names that include type and timing information
- **FR-004**: System MUST populate work entry names from source interval data (date, type, duration)
- **FR-005**: System MUST validate work entry duration is positive (> 0)
- **FR-006**: System MUST validate work entry duration does not exceed 24 hours
- **FR-007**: System MUST automatically split work entries spanning midnight into separate entries per date
- **FR-008**: System MUST detect overlapping work entries for the same employee and mark as "conflict"
- **FR-009**: System MUST allow resetting conflicting state back to draft for manual resolution
- **FR-010**: System MUST provide filter/search for work entries by employee
- **FR-011**: System MUST provide filter/search for work entries by date range
- **FR-012**: System MUST provide search for work entries by employee country
- **FR-013**: System MUST report has_work_entries flag indicating whether employee has any generated entries
- **FR-014**: System MUST support configuration of work entry types with unique codes
- **FR-015**: System MUST enforce code uniqueness across work entry types
- **FR-016**: System MUST enforce country constraints on work entry types
- **FR-017**: System MUST maintain consistency between work flag and is_work property on work entry types
- **FR-018**: System MUST automatically assign default work entry type to resource calendar attendance
- **FR-019**: System MUST copy and preserve work entry field values from resource calendar leave intervals
- **FR-020**: System MUST support scheduled (cron-based) automatic generation of missing work entries
- **FR-021**: System MUST prevent deletion of work entries in protected states (validated, payslip-included)
- **FR-022**: System MUST allow deletion of work entries in draft state (when not linked to payslip)
- **FR-023**: System MUST track work entry type relationships including country constraints
- **FR-024**: System MUST handle retroactive work entry generation for past periods with confirmation

### Key Entities

- **Work Entry**: Represents recorded/generated employee work activity for a day. Includes generated flag indicating automatic creation, display name, split status, conflict status.
- **Work Entry Type**: Configuration of work types (Normal Work, Sick Leave, Paid Leave, etc.) with unique codes, country constraints, work/non-work flag (mirrored by is_work). Used for categorizing work entries.
- **Resource Calendar Attendance**: Calendar-based attendance record linked to employee. Has default work entry type and triggers automatic work entry creation.
- **Resource Calendar Leave**: Calendar-based leave record. Values are copied to work entry fields for preservation.
- **Contract**: Employee employment contract defining work rules. Used as basis for work entry generation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Work entry generation for 1000 employees for a month completes in under 5 minutes with 100% data accuracy
- **SC-002**: Duration validation catches 100% of invalid entries (duration <= 0 or > 24 hours) with clear error messages
- **SC-003**: Work entry splitting correctly divides entries spanning midnight with 100% accuracy and no duration loss
- **SC-004**: Conflict detection identifies 100% of overlapping entries for the same employee-date combination
- **SC-005**: Display name computation shows readable, consistent format for all work entry types
- **SC-006**: Search and filter operations on 10,000 work entries complete in under 1 second
- **SC-007**: Force regeneration correctly replaces 100% of entries in target period
- **SC-008**: Country-based search resolves employee country relation with 100% accuracy
- **SC-009**: Automated cron-based generation identifies and fills 100% of entry gaps

## Assumptions

- **Generation Basis**: Work entry generation assumes contracts and attendance data are pre-populated; doesn't include attendance import or contract sync
- **Timezone Handling**: All date-based operations use organization's primary timezone; multi-timezone support is out of scope
- **Retroactive Generation**: Retroactive generation (past periods) requires explicit user confirmation; prevents accidental data overwrite
- **Type Codes**: Work entry type codes are unique per organization; multi-tenant uniqueness constraints are assumed
- **Resource Calendar**: Resource calendar integration assumes attendance/leave data is pre-populated; integration assumes standard calendar structure
- **Deletion Policy**: Entries in payslip-included state cannot be deleted; can only be cancelled or corrected via adjustment
- **Batch Performance**: Batch generation assumes standard IT infrastructure; extreme scale (1M+ entries) may require database optimization
- **Default Type Assignment**: Resource calendar attendance auto-assignment uses a configurable default work entry type per organization
- **Leave Value Copying**: Leave values copied from resource calendar are exact copies; no transformation or calculation applied
- **Cron Scheduling**: Scheduled generation runs per organization's configured timezone and business rules; frequency is configurable
- **Force Regeneration**: Force regeneration allowed only for draft entries; cannot overwrite validated/payslip-included entries
