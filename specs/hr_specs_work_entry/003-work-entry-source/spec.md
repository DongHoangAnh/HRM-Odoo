# Feature Specification: Work Entry Source Configuration and Recompute

**Feature Branch**: `003-work-entry-source`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: Work Entry Source Configuration and Recompute feature

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure Work Entry Sources (Priority: P1)

HR managers need to configure how work entries are generated for employees (calendar-based, attendance-based, or hybrid), ensuring generated entries align with organizational work tracking rules.

**Why this priority**: Source configuration is foundational. Without the ability to configure how work entries are generated, the system cannot adapt to different organizational needs. This directly determines which data feeds work entry generation.

**Independent Test**: This can be fully tested independently by: configuring a work entry source (calendar or attendance), validating the configuration, and verifying source-specific generation logic is applied correctly.

**Acceptance Scenarios**:

1. **Given** a contract version with work_entry_source "calendar", **When** I set a resource calendar, **Then** the calendar-based source should be valid and work_entry_source_calendar_invalid flag should be False.
2. **Given** a contract version with work_entry_source "calendar", **When** no resource calendar is set, **Then** the configuration should be invalid and work_entry_source_calendar_invalid flag should be True.
3. **Given** a contract template with work_entry_source field, **When** I copy values from the template, **Then** work_entry_source should be copied to the new version.

---

### User Story 2 - Generate Work Entries from Configured Sources (Priority: P1)

The system must generate work entries using the configured source (calendar attendance intervals or leave intervals), producing appropriate entries based on the selected generation strategy.

**Why this priority**: Source-based generation is essential. Without this, the configured sources are not utilized. This directly enables the different generation pathways (calendar vs. attendance).

**Independent Test**: This can be tested independently by: configuring a source, setting up source data (calendar or attendance intervals), running generation, and verifying entries are created from the correct source.

**Acceptance Scenarios**:

1. **Given** a version with work_entry_source "calendar" and a resource calendar configured, **When** I generate attendance intervals, **Then** calendar-based attendance intervals should be returned and used for work entry generation.
2. **Given** attendances and leave intervals existing for a version, **When** I compute version work entry values, **Then** both attendance entries and leave entries should be produced.
3. **Given** a fully flexible schedule with leave intervals, **When** I generate work entry values, **Then** the flexible schedule generation path should be used with both leave and worked leave entries.

---

### User Story 3 - Resolve Default Work Entry Types (Priority: P1)

The system must automatically resolve default work entry types for attendance and overtime from configured defaults, enabling consistent entry categorization without manual type assignment.

**Why this priority**: Type resolution is critical for consistent generation. Without proper default type resolution, entries would lack proper categorization.

**Independent Test**: This can be tested by: requesting default attendance and overtime work entry types and verifying correct types are returned from system configuration.

**Acceptance Scenarios**:

1. **Given** default work entry types configured in the system, **When** I request the default attendance work entry type, **Then** the attendance type should be returned when installed.
2. **Given** default work entry types configured, **When** I request the default overtime work entry type, **Then** the overtime type should be returned when installed.

---

### User Story 4 - Validate Leave and Attendance Data (Priority: P1)

The system must compute and apply leave domain constraints (employee resource, date range, company, calendar) to ensure only valid leave/attendance data is used for work entry generation.

**Why this priority**: Data validation is essential for accuracy. Invalid source data would produce incorrect work entries.

**Independent Test**: This can be tested by: computing leave domain for work entry generation and verifying all constraints (employee, date range, company, calendar) are applied correctly.

**Acceptance Scenarios**:

1. **Given** an employee and date range for work entry generation, **When** I compute the leave domain, **Then** it should include employee resource, date range, company, and calendar constraints.
2. **Given** a leave with a specific work entry type, **When** I map the leave interval to a work entry type, **Then** the leave's own work entry type should be used for that entry.

---

### User Story 5 - Process Generated Work Entries (Priority: P1)

The system must post-process generated work entries, including splitting multi-day entries into daily segments and updating generation boundaries to track coverage.

**Why this priority**: Post-processing is essential for data integrity. Without proper processing, entries could span multiple days incorrectly or tracking boundaries could be inaccurate.

**Independent Test**: This can be tested by: generating entries that span multiple local days, running post-processing, and verifying entries are split correctly with boundaries updated.

**Acceptance Scenarios**:

1. **Given** a generated work entry spanning two local days, **When** post-processing runs, **Then** it should be split into separate segments for each day.
2. **Given** generated work entries for a period, **When** work entries are created, **Then** date_generated_from and date_generated_to should be updated to reflect coverage range.

---

### User Story 6 - Maintain Generated Entry Boundaries (Priority: P1)

The system must track and maintain date_generated_from and date_generated_to boundaries, updating them when new entries extend coverage and enabling efficient recomputation of affected ranges.

**Why this priority**: Boundary tracking is critical for efficient incremental updates and for knowing the coverage scope of generated entries.

**Independent Test**: This can be tested by: generating entries for different date ranges and verifying boundaries are correctly updated to encompass all entries.

**Acceptance Scenarios**:

1. **Given** generated work entries with existing boundaries, **When** new entries extend outside current boundaries, **Then** date_generated_from and date_generated_to should be updated to include the new range.

---

### User Story 7 - Clean Up Entries Outside Contract Period (Priority: P2)

The system must automatically remove generated work entries that fall outside the employee's contract period when the contract period changes, maintaining consistency with active employment.

**Why this priority**: Cleanup is important for data accuracy but can be implemented after core generation. Ensures entries don't exist for periods when employee wasn't employed.

**Independent Test**: This can be tested by: creating entries outside contract period, running cleanup, and verifying out-of-range entries are deleted.

**Acceptance Scenarios**:

1. **Given** generated work entries exist outside the contract period, **When** I call remove work entries, **Then** the out-of-range entries should be deleted.
2. **Given** a version with generated work entries, **When** I update contract_date_start to a later date, **Then** existing generated work entries outside the new period should be automatically removed.

---

### User Story 8 - Cancel Non-Validated Entries (Priority: P2)

The system must support cancelling non-validated work entries when needed, removing draft entries while preserving validated ones for audit trail integrity.

**Why this priority**: Cancellation is useful for cleanup but can be implemented after core generation. Allows removal of draft entries without affecting validated history.

**Independent Test**: This can be tested by: creating non-validated entries, running cancel operation, and verifying only non-validated entries are removed.

**Acceptance Scenarios**:

1. **Given** non-validated work entries existing for a version, **When** I call cancel work entries, **Then** the non-validated entries should be unlinked and removed.

---

### User Story 9 - Auto-Trigger Recomputation on Contract Changes (Priority: P2)

The system must automatically trigger work entry recomputation when contract fields affecting generation change (calendar, schedule type), ensuring entries stay aligned with updated contract rules.

**Why this priority**: Auto-recomputation is valuable for maintaining consistency, but can be implemented after manual generation works. Prevents stale entries after contract updates.

**Independent Test**: This can be tested by: creating entries, modifying contract generation-affecting fields, and verifying recomputation is triggered for affected date ranges.

**Acceptance Scenarios**:

1. **Given** a version with generated work entries, **When** I update resource_calendar_id, **Then** the work entries should be automatically recomputed for the affected date range.
2. **Given** work entries generated for a date range, **When** contract changes trigger recomputation, **Then** only affected date ranges should be recomputed (not entire history).

---

### User Story 10 - Support Flexible Schedule Generation (Priority: P2)

The system must support flexible schedule variations, generating work entries for flexible employees using leave and worked leave paths rather than fixed attendance.

**Why this priority**: Flexible schedule support is important for organizations with flexible workers, but can be implemented after standard generation. Requires different generation logic.

**Independent Test**: This can be tested by: configuring a flexible schedule version, running generation, and verifying both leave and worked leave entries are produced correctly.

**Acceptance Scenarios**:

1. **Given** a fully flexible schedule version with leave intervals, **When** I generate work entry values, **Then** the flexible schedule path should be used with appropriate entry types.

---

### User Story 11 - Normalize Dates to UTC (Priority: P2)

The system must normalize attendance and leave interval dates to UTC for storage consistency, handling timezone conversions from localized source data.

**Why this priority**: Date normalization is important for consistency across timezones, but can be implemented after core generation. Prevents timezone-related discrepancies.

**Independent Test**: This can be tested by: providing localized attendance intervals, building work entry values, and verifying dates are normalized to UTC naive form.

**Acceptance Scenarios**:

1. **Given** a localized attendance interval with timezone information, **When** I build real attendance work entry values, **Then** date_start and date_stop should be stored in UTC naive form.

---

### User Story 12 - Support Batch Recomputation via Scheduled Process (Priority: P3)

The system must support a scheduled (cron) process that automatically generates missing work entries for multiple versions in batches, with retry logic for failed batches.

**Why this priority**: Batch recomputation is useful for maintaining entry coverage but is optional for initial launch. Can be implemented as an enhancement after core functionality.

**Independent Test**: This can be tested by: creating gaps in work entries, running cron, and verifying missing entries are generated in batches with retries if needed.

**Acceptance Scenarios**:

1. **Given** multiple versions with missing work entries for the current month, **When** the cron runs, **Then** it should generate work entries in batches and retrigger if needed to fill all gaps.

---

### User Story 13 - Detect Static vs. Dynamic Entry Sources (Priority: P3)

The system must detect whether a version uses static work entries (calendar-based) vs. dynamic entries (attendance-based) to enable appropriate UI/processing logic.

**Why this priority**: Source type detection enables different UI behaviors, but is optional for initial functionality. Can be implemented as an optimization.

**Independent Test**: This can be tested by: configuring calendar vs. attendance sources and verifying has_static_work_entries flag correctly reflects source type.

**Acceptance Scenarios**:

1. **Given** a version with work_entry_source "calendar", **When** I check has_static_work_entries, **Then** the result should be True.

---

### User Story 14 - Support Force Regeneration (Priority: P2)

The system must support force regeneration of work entries for a date range, replacing existing non-validated entries while preserving validated ones for data integrity.

**Why this priority**: Force regeneration is useful when source data changes, but can be implemented after basic generation. Allows updating entries without manual deletion.

**Independent Test**: This can be tested by: creating existing entries, running force generation, and verifying non-validated entries are replaced while validated ones are preserved.

**Acceptance Scenarios**:

1. **Given** existing work entries for a date range, **When** I generate work entries with force=True, **Then** existing non-validated entries should be replaced with newly generated ones.

---

### Edge Cases

- What happens when contract_date_start changes mid-month? (Existing entries outside new period deleted; entries within period updated if calendar changes; boundaries recalculated)
- How are timezone changes handled during date normalization? (Dates stored in UTC naive form; localization applied during display using user/employee timezone)
- What occurs when resource calendar is removed after entries generated from calendar? (Entries remain but source becomes invalid; recomputation required if calendar restored or source changed)
- How does the system handle overlapping leave and attendance for same day? (Leave takes priority; attendance ignored for leave days; system detects and flags potential conflicts)
- What if cron retries fail repeatedly? (Failed batches logged; manual intervention required; retry threshold prevents infinite loops)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support configurable work entry sources (calendar, attendance, hybrid)
- **FR-002**: System MUST validate work entry source configuration (e.g., calendar exists if calendar source selected)
- **FR-003**: System MUST compute work_entry_source_calendar_invalid flag when calendar source lacks calendar
- **FR-004**: System MUST generate work entries using the configured source strategy
- **FR-005**: System MUST resolve default attendance work entry type from system configuration
- **FR-006**: System MUST resolve default overtime work entry type from system configuration
- **FR-007**: System MUST apply leave domain constraints (employee, date range, company, calendar) during generation
- **FR-008**: System MUST use specific work entry type when defined on leave records
- **FR-009**: System MUST compute attendance intervals based on work_entry_source (calendar or attendance)
- **FR-010**: System MUST split work entries spanning multiple local days into separate daily entries
- **FR-011**: System MUST update date_generated_from and date_generated_to when entries are created
- **FR-012**: System MUST extend boundaries when new entries fall outside current generation range
- **FR-013**: System MUST delete work entries falling outside the contract period when period changes
- **FR-014**: System MUST support removing work entries outside contract period
- **FR-015**: System MUST support cancelling non-validated work entries
- **FR-016**: System MUST automatically remove cancelled entries from linked contract
- **FR-017**: System MUST auto-trigger work entry recomputation when contract generation-affecting fields change
- **FR-018**: System MUST handle contract_date_start changes with automatic entry cleanup/update
- **FR-019**: System MUST handle resource_calendar_id changes with automatic entry recomputation
- **FR-020**: System MUST support flexible schedule generation with leave and worked leave paths
- **FR-021**: System MUST normalize localized dates to UTC naive form for storage
- **FR-022**: System MUST normalize attendance interval dates to UTC
- **FR-023**: System MUST normalize leave interval dates to UTC
- **FR-024**: System MUST support force regeneration replacing non-validated entries
- **FR-025**: System MUST preserve validated entries during force regeneration
- **FR-026**: System MUST detect static work entries (calendar-based) via has_static_work_entries flag
- **FR-027**: System MUST support batch recomputation via scheduled (cron) process
- **FR-028**: System MUST implement retry logic for failed batch generations
- **FR-029**: System MUST copy work_entry_source from contract templates to new versions
- **FR-030**: System MUST track work entry generation boundaries per version

### Key Entities

- **Contract Version**: Employee contract version with work_entry_source configuration (calendar, attendance), linked resource calendar, schedule type (flexible, fixed), and generation boundaries (date_generated_from, date_generated_to).
- **Work Entry Source**: Enumeration indicating generation strategy (calendar-based, attendance-based, hybrid). Determines which data feeds generation.
- **Work Entry Type**: Categorizes work entries (attendance, overtime, leave). Default types resolved from system configuration.
- **Attendance Interval**: Calendar-based attendance data linked to resource calendar. Processed into work entries when calendar source configured.
- **Leave Interval**: Leave record linked to employee. Includes work entry type to be applied. Processed into work entries during generation.
- **Generation Boundary**: Tracks date_generated_from and date_generated_to for each version to enable efficient incremental recomputation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Work entry source configuration validation prevents 100% of invalid configurations (missing calendar for calendar source)
- **SC-002**: Work entry generation from configured sources produces 100% accurate entries matching source data
- **SC-003**: Default type resolution correctly identifies and applies default work entry types with 100% accuracy
- **SC-004**: Multi-day entry splitting correctly divides entries across calendar days with zero duration loss
- **SC-005**: Generation boundary updates accurately track coverage range for efficient recomputation
- **SC-006**: Contract period cleanup removes 100% of entries outside contract period
- **SC-007**: Auto-triggered recomputation completes within 2 seconds for typical date ranges (1 month)
- **SC-008**: Force regeneration processes 1000 entries with correct non-validated replacement in under 5 seconds
- **SC-009**: Batch cron job generates missing entries for 100+ versions in under 10 minutes with automatic retry
- **SC-010**: Date normalization to UTC maintains 100% accuracy across timezone conversions

## Assumptions

- **Source Configuration**: Work entry source is configured at contract version level; cannot change mid-version without recomputation
- **Calendar Existence**: Calendar source requires resource calendar to be configured; validation prevents invalid configurations
- **Default Types**: Default work entry types for attendance and overtime are configured at system level; assumed to be installed/available
- **Template Copying**: Contract templates support work_entry_source as a whitelisted field; copying preserves the value
- **Timezone Handling**: All dates normalized to UTC naive form; localization applied during display using employee/user timezone setting
- **Flexible Schedules**: Flexible schedule support assumes leave intervals are pre-configured; system generates leave + worked leave entries
- **Attendance Data**: Attendance interval data is pre-populated; system doesn't import or sync attendance (separate integration)
- **Leave Data**: Leave intervals are pre-populated from time off requests/calendar; system processes existing data
- **Batch Size**: Cron batch processing uses configurable batch size (default 100 versions per batch)
- **Retry Logic**: Failed cron batches retry up to 3 times before requiring manual intervention; prevents infinite retry loops
- **Boundary Tracking**: Generation boundaries tracked per version; reset when contract period changes significantly
- **Non-Validated Only**: Force regeneration only replaces draft/non-validated entries; validated entries preserved to maintain audit trail
- **Contract Validity**: Entries only generated for dates within contract_date_start and contract_date_end range
