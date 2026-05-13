# Feature Specification: Teacher and Teaching Assistant Payroll

**Feature Branch**: `003-teacher-payroll`
**Created**: 2026-05-12
**Status**: Draft
**Input**: Supplementary specification for education-company-specific payroll — teacher hourly pay, TA compensation, and salary structure selection

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Calculate Teacher Salary by Teaching Hours (Priority: P1)

Teachers may be paid based on actual teaching hours rather than a fixed monthly salary. The system must calculate their pay as (teaching_hours × hourly_rate) using validated work entries of type "teaching_hours".

**Why this priority**: This is the core differentiation between teacher and office staff payroll. Without hourly pay support, the payroll system cannot handle the education company's primary workforce correctly.

**Independent Test**: This can be tested by: creating a teacher contract with hourly rate, adding teaching hour work entries, generating a payslip, and verifying pay = hours × rate.

**Acceptance Scenarios**:

1. **Given** teacher "John Smith" with hourly rate 300,000 and 80 validated teaching hours in January, **When** I generate a payslip, **Then** teaching_hours_pay should be 24,000,000 (80 × 300,000).
2. **Given** a part-time teacher with hourly rate 250,000 and 30 hours, **When** I generate a payslip, **Then** pay should be 7,500,000 and gross salary should equal this amount.
3. **Given** a teacher with 0 teaching hours in a month, **When** I generate a payslip, **Then** teaching_hours_pay should be 0 and insurance deductions should still be calculated on the contract's base_salary_for_insurance.

---

### User Story 2 - Calculate Teacher Salary with Fixed Plus Extra Hours (Priority: P1)

Some teachers have a hybrid arrangement: a fixed monthly base salary plus bonus pay for teaching hours exceeding a standard threshold. The system must support this mixed compensation model.

**Why this priority**: Many experienced or senior teachers receive a guaranteed base salary but earn extra for additional classes. This is a common compensation model in language centers that retains experienced staff while incentivizing extra work.

**Independent Test**: This can be tested by: creating a contract with fixed base, standard hours, and extra hour rate, then generating payslips with hours above and below the standard threshold.

**Acceptance Scenarios**:

1. **Given** teacher with base 15,000,000, standard hours 60, extra rate 200,000, and 75 actual hours, **When** I generate a payslip, **Then** base pay = 15,000,000, extra hours = 15, extra_hours_pay = 3,000,000, gross = 18,000,000.
2. **Given** same teacher with only 50 actual hours (below standard), **When** I generate a payslip, **Then** base pay = 15,000,000, extra_hours_pay = 0 (no penalty for fewer hours), gross = 15,000,000.
3. **Given** a teacher with exactly 60 hours (equals standard), **When** I generate a payslip, **Then** extra_hours_pay = 0 and gross = base salary only.

---

### User Story 3 - Calculate Teaching Assistant Compensation (Priority: P1)

Teaching assistants (TAs) are typically paid hourly at a lower rate than teachers. The system must support TA-specific hourly rates using the same Teacher Structure.

**Why this priority**: TAs are a significant portion of the education company's workforce. They share the same hourly pay model as teachers but at different rates.

**Independent Test**: This can be tested by: creating a TA contract with hourly rate and teaching hours, generating a payslip, and verifying calculations match teacher logic with TA-specific rates.

**Acceptance Scenarios**:

1. **Given** TA "Nguyen Thi K" with hourly rate 150,000, base_salary_for_insurance 5,000,000, and 60 teaching hours, **When** I generate a payslip, **Then** pay should be 9,000,000 and insurance base should be 5,000,000.

---

### User Story 4 - Support Multiple Teaching Hour Sources (Priority: P2)

Teaching hours may come from three sources: automatic generation from attendance records, manual entry by HR, or batch import from the Operations department. The payslip must consume hours regardless of source.

**Why this priority**: In practice, different schools/departments may track teaching hours differently. The Operations department often maintains their own teaching schedule that HR needs to import. Flexibility in sourcing is essential for adoption.

**Independent Test**: This can be tested by: creating teaching hour work entries from each source, generating a payslip, and verifying all validated entries are included regardless of origin.

**Acceptance Scenarios**:

1. **Given** teacher with work entries from attendance (10h) and manual entry (5h), **When** generating payslip, **Then** total teaching hours = 15h and pay calculated accordingly.
2. **Given** HR imports 85 teaching hours from Operations department via batch input, **When** generating payslip, **Then** the imported hours should be used for salary calculation at the teacher's hourly rate.
3. **Given** a payslip input of type "teaching_hours_manual" with value 85, **When** generating payslip for an hourly teacher, **Then** pay = 85 × hourly_rate.

---

### User Story 5 - Select Correct Salary Structure Automatically (Priority: P2)

The system must use the salary structure defined on the employee's contract. Office staff use "Office Staff Structure" and teachers/TAs use "Teacher Structure". The correct structure determines which salary rules are applied.

**Why this priority**: Applying the wrong structure (e.g., hourly rules to a fixed-salary employee) would produce completely wrong payslips. Automatic structure selection eliminates human error in batch processing.

**Independent Test**: This can be tested by: batch generating payslips for mixed employees (office + teachers) and verifying each payslip uses the structure from their contract.

**Acceptance Scenarios**:

1. **Given** office employee with "Office Staff Structure" and teacher with "Teacher Structure", **When** batch generating payslips, **Then** each payslip should use the correct structure from their contract.
2. **Given** "Teacher Structure" has rules TEACH_HOURS, EXTRA_HOURS, BASE and "Office Staff Structure" has rules BASE, POS_ALW, **When** generating a teacher's payslip, **Then** only Teacher Structure rules should be applied.

---

### User Story 6 - Apply Vietnamese Tax and Insurance to Teacher Payroll (Priority: P1)

Teacher payslips must apply BHXH/BHYT/BHTN and PIT just like office staff, but insurance is calculated on base_salary_for_insurance (from contract), not on actual teaching earnings.

**Why this priority**: Teachers are employees under Vietnamese law and must have insurance and tax deductions. The distinction is that insurance base is the contracted amount, not the variable hourly earnings.

**Independent Test**: This can be tested by: generating a teacher payslip with hourly earnings different from insurance base, and verifying insurance is on the contract base while PIT is on actual gross.

**Acceptance Scenarios**:

1. **Given** teacher with hourly rate 300,000, 80 hours (gross 24,000,000), base_salary_for_insurance 10,000,000, 1 dependent, **When** generating payslip, **Then**:
   - Insurance deductions calculated on 10,000,000 (not 24,000,000)
   - BHXH = 800,000, BHYT = 150,000, BHTN = 100,000
   - Taxable income = 24,000,000 - 1,050,000 - 11,000,000 - 4,400,000 = 7,550,000
   - PIT calculated on 7,550,000 using progressive brackets
   - Net = 24,000,000 - 1,050,000 - PIT

---

### Edge Cases

- What if a teacher changes from hourly to fixed mid-month? (Prorate: hourly for days before change, fixed for days after — or create two payslips)
- What if Operations provides hours that differ from attendance records? (HR validates and uses the authoritative source; system should flag discrepancies)
- What about substitute teachers with one-off classes? (Create as hourly contract, even if only for one month)
- How to handle teacher on leave? (Teaching hours = 0 for leave days; if paid leave, base salary may still apply depending on contract type)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support pay_type "hourly" on contracts where salary = teaching_hours × hourly_rate
- **FR-002**: System MUST support pay_type "fixed" where salary = monthly base salary regardless of teaching hours
- **FR-003**: System MUST support pay_type "fixed_plus_hourly" where salary = base + (max(0, actual_hours - standard_hours) × extra_hour_rate)
- **FR-004**: System MUST use validated work entries of type "teaching_hours" (WORK200) as the source for teaching hour count
- **FR-005**: System MUST support payslip inputs of type "teaching_hours_manual" for manually entered hours from Operations
- **FR-006**: System MUST calculate insurance on base_salary_for_insurance (from contract), not on actual hourly earnings
- **FR-007**: System MUST calculate PIT on actual gross salary (including hourly earnings), not on insurance base
- **FR-008**: System MUST select salary structure from employee contract (salary_structure_id) during payslip generation
- **FR-009**: System MUST prevent applying wrong structure rules (e.g., teaching rules on office staff or vice versa)
- **FR-010**: System MUST support different hourly rates for teachers vs. TAs via separate contracts
- **FR-011**: System MUST handle zero teaching hours gracefully (pay = 0 for hourly, insurance still deducted)
- **FR-012**: System MUST support batch payslip generation for mixed employee types (office + teachers + TAs) in a single operation

### Key Entities

- **Contract Extensions**: pay_type (fixed/hourly/fixed_plus_hourly), hourly_rate, base_salary_for_insurance, standard_teaching_hours, extra_hour_rate, salary_structure_id
- **Salary Structure**: "Teacher Structure" and "Office Staff Structure" with different rule sets
- **Work Entry Type WORK200**: Teaching Hours — used specifically for teacher/TA time tracking
- **Payslip Input Type**: teaching_hours_manual — for Operations department imported hours

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Hourly teacher payslip correctly calculates pay = hours × rate for 100% of test cases
- **SC-002**: Fixed-plus-hourly teacher payslip correctly identifies extra hours and calculates bonus for 100% of test cases
- **SC-003**: Insurance is calculated on contract base (not earnings) for hourly teachers in 100% of cases
- **SC-004**: Batch generation correctly applies different structures to office staff vs. teachers in 100% of cases
- **SC-005**: Teaching hours from all sources (attendance, manual, import) are consumed correctly by payslip

## Assumptions

- **Teaching Hours Source**: Work entries of type WORK200 or payslip inputs of type teaching_hours_manual are the authoritative source for teaching hours
- **Insurance Base**: For hourly teachers, insurance base is defined on the contract (base_salary_for_insurance), not derived from actual earnings
- **Structure Assignment**: Each contract has exactly one salary_structure_id; no employee uses multiple structures simultaneously
- **TA vs Teacher**: Both use "Teacher Structure" but with different hourly_rate values on their contracts
- **Standard Hours**: The standard_teaching_hours field only applies to fixed_plus_hourly pay type; it is ignored for pure hourly or pure fixed
