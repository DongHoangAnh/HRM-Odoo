# Feature Specification: Teaching Hours Work Entries, Public Holidays, and Seed Data

**Feature Branch**: `004-teaching-hours-holidays`
**Created**: 2026-05-12
**Status**: Draft
**Input**: Supplementary specification for education-company-specific work entries — teaching hour tracking, Vietnamese public holidays, default work entry types, and work entry to payroll mapping

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Install Default Work Entry Types (Priority: P1)

The system must provide a predefined set of work entry types upon module installation, covering standard work types, leave types, and education-specific types (teaching hours). These seed types ensure consistent data across the company.

**Why this priority**: Without standard types, every company would need to manually configure types before the system is usable. Seed data eliminates setup friction and ensures consistent codes across modules (work entry, payroll, leave).

**Independent Test**: This can be tested by: installing the module on a fresh database and verifying all expected work entry types exist with correct codes, names, and flags.

**Acceptance Scenarios**:

1. **Given** a fresh module installation for a Vietnamese company, **When** installation completes, **Then** the following types must exist:
   - WORK100 (Normal Working Day, is_work=true)
   - WORK110 (Overtime, is_work=true)
   - WORK200 (Teaching Hours, is_work=true)
   - LEAVE100 (Paid Time Off, is_leave=true)
   - LEAVE110 (Sick Leave, is_leave=true)
   - LEAVE120 (Unpaid Leave, is_leave=true)
   - LEAVE200 (Maternity Leave, is_leave=true)
   - LEAVE210 (Paternity Leave, is_leave=true)
   - LEAVE300 (Public Holiday, is_leave=true)
   - LEAVE310 (Compensatory Time Off, is_leave=true)
2. **Given** work entry type codes are unique, **When** trying to create a duplicate code, **Then** the system should reject with a uniqueness error.
3. **Given** a work entry type in use by 50 entries, **When** trying to delete it, **Then** deletion should be blocked and deactivation suggested instead.

---

### User Story 2 - Generate Teaching Hour Work Entries from Attendance (Priority: P1)

When teachers and TAs check in/out via the attendance system, their attendance records should generate work entries of type "Teaching Hours" (WORK200). This provides automatic data flow from attendance to payroll.

**Why this priority**: Automatic generation eliminates double-entry of teaching hours. Attendance is already tracked — converting it to work entries is the critical link to payroll calculation.

**Independent Test**: This can be tested by: creating attendance records for a teacher, triggering work entry generation, and verifying WORK200 entries are created with correct durations matching attendance check-in/out.

**Acceptance Scenarios**:

1. **Given** teacher with attendance records (08:00-12:00 and 13:00-15:00 on Jan 2, 09:00-12:00 on Jan 3), **When** work entries are generated, **Then** WORK200 entries should be created: 4h on Jan 2 AM, 2h on Jan 2 PM, 3h on Jan 3.
2. **Given** teacher with work entry source configured as "attendance", **When** generation runs for January, **Then** only attendance-based entries should be created (no calendar-based).
3. **Given** generated teaching hour entries, **When** viewing them, **Then** each should be in "draft" state and available for validation before payslip generation.

---

### User Story 3 - Support Manual Teaching Hour Entry (Priority: P1)

HR must be able to manually create teaching hour work entries for cases where attendance records are not available (e.g., off-site teaching, system downtime).

**Why this priority**: Not all teaching sessions are captured by the attendance system. Manual entry provides a fallback and ensures no teaching hours are lost for payroll.

**Independent Test**: This can be tested by: manually creating a WORK200 work entry with specified employee, date, and duration, then verifying it appears alongside auto-generated entries.

**Acceptance Scenarios**:

1. **Given** HR creates a manual work entry: employee "Jane Doe", date 2025-01-06, type WORK200, duration 6h, **When** saved, **Then** entry is created in "draft" state with import_source = "manual".
2. **Given** both manual and attendance-generated entries exist, **When** generating payslip, **Then** all validated entries of type WORK200 are included regardless of source.

---

### User Story 4 - Import Teaching Hours from Operations Department (Priority: P2)

The Operations department maintains teaching schedules and actual teaching records. HR needs to batch-import this data as work entries, tagged with the import source for audit.

**Why this priority**: In many education companies, Operations is the authoritative source for teaching hours. Batch import reduces manual data entry and ensures alignment between Operations and HR records.

**Independent Test**: This can be tested by: providing a batch of teaching hour records, running the import, and verifying work entries are created with correct employee, dates, hours, and import metadata.

**Acceptance Scenarios**:

1. **Given** Operations provides: John Smith 4h on Jan 2 (IELTS A1), John Smith 3h on Jan 3 (TOEFL B2), Jane Doe 6h on Jan 2 (English C1), **When** HR imports the data, **Then** WORK200 entries are created for each row in "draft" state with import_source = "operations_import".
2. **Given** imported entries, **When** viewing entry details, **Then** class_name and import_batch_id should be recorded for audit.
3. **Given** an import batch, **When** the import completes, **Then** a summary should show: X entries created, Y entries skipped (duplicates), Z errors.

---

### User Story 5 - Only Include Validated Teaching Hours in Payslip (Priority: P1)

The payslip generation must only include teaching hour work entries in "validated" state. Draft entries should be excluded with a warning to HR.

**Why this priority**: Including unvalidated entries in payslip calculations could result in incorrect pay. Validation is the quality gate between raw data and financial processing.

**Independent Test**: This can be tested by: creating a mix of validated and draft teaching entries, generating a payslip, and verifying only validated entries are counted.

**Acceptance Scenarios**:

1. **Given** 15 validated and 5 draft WORK200 entries, **When** generating payslip, **Then** only 15 entries' hours are included and a warning about 5 unvalidated entries is shown.
2. **Given** all entries validated, **When** generating payslip, **Then** all hours are included and no warning is shown.

---

### User Story 6 - Configure Vietnamese Public Holidays (Priority: P1)

The system must pre-configure Vietnamese standard public holidays (11 days/year) and generate LEAVE300 work entries on those days. Working on a public holiday should generate overtime entries at 300% rate.

**Why this priority**: Public holidays affect both work entry generation (no normal work expected) and payroll (paid days off, or 300% overtime if worked). Missing public holiday configuration leads to incorrect attendance and pay.

**Independent Test**: This can be tested by: verifying pre-configured holidays exist, running work entry generation covering a holiday, and checking LEAVE300 entries are created and paid leave balance is not affected.

**Acceptance Scenarios**:

1. **Given** Vietnamese company after module installation, **When** checking holidays, **Then** the following should be configured: Tet Duong Lich (1 day), Tet Nguyen Dan (5 days), Hung Kings (1 day), Reunification Day (1 day), Labour Day (1 day), National Day (2 days) — 11 days total.
2. **Given** employee with Mon-Fri calendar, **When** work entries generated for January 2025 (Tet 27-31), **Then** Jan 27-31 should have type LEAVE300 (Public Holiday) with 8h duration each.
3. **Given** public holiday entry, **When** generating payslip, **Then** it should count as paid day (no deduction from salary or leave balance).
4. **Given** employee attendance on a public holiday (2025-04-30), **When** work entries generated, **Then** an WORK110 (Overtime) entry should be created with holiday_overtime flag and 300% rate per Vietnamese labor law.
5. **Given** HR adds a company-specific holiday "Company Anniversary" on 2025-06-15, **When** work entries generated for June, **Then** that day should get LEAVE300 type.

---

### User Story 7 - Differentiate Office Staff vs Teacher Work Entry Generation (Priority: P2)

Office staff work entries are generated from their work calendar (Mon-Fri, 8h/day). Teacher work entries come from attendance records. The system must use the correct generation source based on the employee's configuration.

**Why this priority**: Using the wrong generation source would create incorrect work entries (e.g., generating 8h/day for a part-time teacher who only teaches 3h). Source configuration is essential for mixed workforces.

**Independent Test**: This can be tested by: configuring an office employee with calendar source and a teacher with attendance source, generating entries for both, and verifying each uses the correct source.

**Acceptance Scenarios**:

1. **Given** office staff with calendar source (Mon-Fri, 8h), **When** generating January entries, **Then** WORK100 entries created for each working day at 8h.
2. **Given** teacher with attendance source, **When** generating entries, **Then** WORK200 entries match actual attendance records.
3. **Given** mixed batch generation for all employees, **When** running, **Then** each employee's entries use their configured source.

---

### User Story 8 - Map Work Entry Types to Salary Rules (Priority: P2)

Each work entry type must map to a salary rule code so payroll knows how to process the hours. For example, WORK100 maps to BASE (normal pay), WORK200 maps to TEACH_HOURS (teaching pay), LEAVE120 maps to UNPAID_LEAVE (deduction).

**Why this priority**: Without explicit mapping, payroll cannot automatically determine how to treat different work entry types. This is the bridge between the work entry module and the payroll module.

**Independent Test**: This can be tested by: generating a payslip for an employee with multiple work entry types and verifying each type's hours feed into the correct salary rule.

**Acceptance Scenarios**:

1. **Given** the standard mapping (WORK100→BASE, WORK110→OT, WORK200→TEACH_HOURS, LEAVE100→PAID_LEAVE, LEAVE120→UNPAID_LEAVE, LEAVE300→PUBLIC_HOLIDAY), **When** payslip reads work entries, **Then** each entry's hours feed into the mapped salary rule.
2. **Given** validated work entries consumed by a payslip, **When** the payslip is approved, **Then** those entries transition to "payslip_included" state and cannot be modified.
3. **Given** a locked work entry (payslip_included), **When** someone tries to edit it, **Then** system shows "This entry is locked by payslip PS-2025-01-001".

---

### Edge Cases

- What if a public holiday falls on a weekend? (No work entry generated — already a non-working day)
- What if teaching hours overlap with a public holiday? (Priority: if teacher attended, create overtime entry; if not, public holiday entry)
- What if Operations import contains duplicate entries matching attendance records? (Flag as conflict; HR resolves manually)
- What if a work entry type is deactivated mid-month? (Existing entries retain the type; new entries cannot use it)
- What if there are no validated entries for a teacher in a month? (Payslip generated with 0 teaching hours; insurance still applies)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST create default work entry types on module installation (WORK100, WORK110, WORK200, LEAVE100, LEAVE110, LEAVE120, LEAVE200, LEAVE210, LEAVE300, LEAVE310)
- **FR-002**: System MUST enforce unique codes for work entry types
- **FR-003**: System MUST prevent deletion of work entry types that are in use
- **FR-004**: System MUST generate WORK200 (Teaching Hours) entries from teacher attendance records
- **FR-005**: System MUST support manual creation of WORK200 entries by HR
- **FR-006**: System MUST support batch import of teaching hours from Operations with import_source tracking
- **FR-007**: System MUST store class_name and import_batch_id on imported teaching hour entries
- **FR-008**: System MUST only include "validated" work entries in payslip generation
- **FR-009**: System MUST warn about unvalidated entries when generating payslip
- **FR-010**: System MUST pre-configure Vietnamese public holidays (11 days/year) for Vietnamese companies
- **FR-011**: System MUST generate LEAVE300 entries on public holiday dates
- **FR-012**: System MUST generate WORK110 (Overtime) with holiday_overtime flag when employee works on public holiday
- **FR-013**: System MUST apply 300% rate for public holiday overtime per Vietnamese labor law
- **FR-014**: System MUST NOT deduct public holidays from employee leave balance
- **FR-015**: System MUST support company-specific additional holidays
- **FR-016**: System MUST generate WORK100 from calendar for office staff and WORK200 from attendance for teachers
- **FR-017**: System MUST store salary_rule_code on each work entry type for payroll mapping
- **FR-018**: System MUST transition work entries to "payslip_included" state when consumed by approved payslip
- **FR-019**: System MUST prevent modification of work entries in "payslip_included" state
- **FR-020**: System MUST validate teaching hour duration (positive, max 24h per day)
- **FR-021**: System MUST detect overlapping teaching hour entries and flag as conflict

### Key Entities

- **Work Entry Type (hr.work.entry.type)**: Extended with salary_rule_code, is_leave (inverse of is_work), color, sequence. 10 default types seeded at install.
- **Work Entry Extensions**: class_name, import_source (attendance/manual/operations_import), import_batch_id for teaching context.
- **Public Holiday**: Configured via resource.calendar.leaves; 11 Vietnamese standard holidays pre-configured.
- **Work Entry ↔ Payslip Link**: payslip_id on work entry tracking which payslip consumed it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 10 default work entry types are available after module installation with correct codes and flags
- **SC-002**: Teaching hours from attendance generate correct WORK200 entries in 100% of test cases
- **SC-003**: Manual and imported teaching hours are correctly created and distinguishable by import_source
- **SC-004**: Only validated entries are included in payslip generation (0% inclusion of draft entries)
- **SC-005**: Vietnamese public holidays (11 days) are pre-configured and generate LEAVE300 entries on correct dates
- **SC-006**: Public holiday overtime correctly applies 300% rate flag
- **SC-007**: Work entry ↔ salary rule mapping correctly routes hours to payroll rules in 100% of cases
- **SC-008**: Payslip-included work entries are immutable (0% modification after payslip approval)

## Assumptions

- **Attendance System**: Teacher attendance records are available in hr.attendance before work entry generation runs
- **Operations Import Format**: CSV or structured data with columns: employee_id, date, hours, class_name (exact format to be agreed with Operations)
- **Public Holiday Dates**: Vietnamese holidays use Gregorian calendar dates; Lunar calendar dates (Tet, Hung Kings) must be updated annually by HR
- **Holiday Overtime Rate**: 300% rate is the legal minimum per Vietnamese Labor Code Article 98; configured as default but adjustable
- **Calendar Source**: Office staff use resource.calendar for work entry generation; teachers use hr.attendance
- **Payslip Inclusion Lock**: Once work entries are linked to an approved payslip, they cannot be unlinked unless the payslip is rejected/cancelled
