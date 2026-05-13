# Feature Specification: Vietnamese Tax and Mandatory Insurance

**Feature Branch**: `002-vietnamese-tax-insurance`
**Created**: 2026-05-12
**Status**: Draft
**Input**: Supplementary specification for Vietnamese payroll compliance — BHXH/BHYT/BHTN insurance, PIT progressive tax, and dependent relief

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Calculate Mandatory Insurance Deductions Separately (Priority: P1)

The payroll system must calculate BHXH, BHYT, and BHTN as three separate deduction lines on the payslip, each at its own legally mandated rate. This is a core compliance requirement under Vietnamese labor law.

**Why this priority**: Without accurate, separated insurance deductions, the company violates Vietnamese labor law. Every payslip must show these three items distinctly. This is non-negotiable for legal compliance.

**Independent Test**: This can be tested by: configuring insurance rates for BHXH (8%), BHYT (1.5%), BHTN (1%), generating a payslip for an employee with a known insurance base salary, and verifying each deduction line is correctly calculated and displayed separately.

**Acceptance Scenarios**:

1. **Given** employee "Nguyen Van A" with insurance base salary of 17,000,000 and configured rates BHXH=8%, BHYT=1.5%, BHTN=1%, **When** I generate a payslip, **Then** BHXH deduction should be 1,360,000, BHYT should be 255,000, BHTN should be 170,000, totaling 1,785,000.
2. **Given** a generated payslip, **When** I view the salary components, **Then** BHXH, BHYT, and BHTN should appear as three separate deduction lines (not a single combined line).
3. **Given** insurance rates are updated from 8% to 9% for BHXH, **When** I generate a new payslip, **Then** BHXH should be calculated at the new 9% rate — rates must be configurable, not hardcoded.

---

### User Story 2 - Track Employer Insurance Contributions (Priority: P1)

The system must calculate and track the employer's share of insurance contributions (BHXH 17.5%, BHYT 3%, BHTN 1%) separately from the employee deduction. This is required for accurate company cost reporting and finance export.

**Why this priority**: Employer contributions represent a significant hidden cost of employment (21.5% of insurance base). Finance and accounting need this data for budgeting, tax filing, and cost-center analysis. Without this, the company cannot produce accurate financial reports.

**Independent Test**: This can be tested by: generating a payslip, verifying employer contributions are calculated and stored (but not deducted from employee net salary), and confirming they appear in company cost reports.

**Acceptance Scenarios**:

1. **Given** employee with insurance base of 17,000,000, **When** I generate a payslip, **Then** employer contributions should be: BHXH 2,975,000 (17.5%), BHYT 510,000 (3%), BHTN 170,000 (1%), totaling 3,655,000.
2. **Given** a payslip with employer contributions, **When** I view total company cost, **Then** it should be gross_salary + employer_insurance_total.
3. **Given** a finance export, **When** I export payroll data, **Then** employer contributions should be included as separate columns.

---

### User Story 3 - Determine Insurance Base from Allowances (Priority: P1)

Not all salary components count toward the insurance base. The system must correctly determine which allowances are insurance-applicable (e.g., position allowance, seniority) and which are not (e.g., lunch, transportation, phone).

**Why this priority**: Incorrect insurance base calculation leads to either overpayment (company loses money) or underpayment (legal violation). Vietnamese law specifies which allowances count — this must be configurable per allowance type.

**Independent Test**: This can be tested by: configuring allowances with insurance_applicable flag, creating a contract with mixed allowances, and verifying the computed insurance base only includes applicable ones.

**Acceptance Scenarios**:

1. **Given** employee with base salary 15,000,000, position allowance 2,000,000 (insurance-applicable), and lunch allowance 730,000 (not applicable), **When** the system calculates insurance base, **Then** it should be 17,000,000 (base + position only).
2. **Given** a new allowance type "Hazard Allowance" is created and flagged as insurance_applicable=true, **When** an employee receives this allowance, **Then** it should be included in insurance base calculation.
3. **Given** HR changes lunch_allowance from not-applicable to applicable, **When** the next payslip is generated, **Then** insurance base should increase by the lunch allowance amount.

---

### User Story 4 - Apply Insurance Salary Caps (Priority: P1)

Vietnamese law caps the amount on which insurance is calculated. BHXH and BHYT are capped at 20× the base salary reference (lương cơ sở). BHTN is capped at 20× the regional minimum wage. The system must enforce these caps.

**Why this priority**: High-income employees would have disproportionate insurance deductions without caps. Caps also differ between BHXH/BHYT and BHTN — using one single cap would be incorrect.

**Independent Test**: This can be tested by: configuring an employee with insurance base above the cap, generating a payslip, and verifying the capped amount is used for calculation.

**Acceptance Scenarios**:

1. **Given** employee with insurance base 60,000,000 and BHXH/BHYT cap of 46,800,000 (20 × 2,340,000), **When** I generate a payslip, **Then** BHXH should be 3,744,000 (46,800,000 × 8%) — not 4,800,000 (60M × 8%).
2. **Given** employee with insurance base 120,000,000 and BHTN cap of 99,200,000 (20 × 4,960,000 region I), **When** I generate a payslip, **Then** BHTN should be 992,000 (capped) — not 1,200,000.
3. **Given** the government updates lương cơ sở from 2,340,000 to 2,500,000, **When** an administrator updates the configuration, **Then** the new BHXH/BHYT cap should be 50,000,000 and all subsequent payslips should use the new cap.
4. **Given** a company in region IV with minimum wage 3,450,000, **When** generating payslips, **Then** BHTN cap should be 69,000,000 (20 × 3,450,000) — different from the BHXH/BHYT cap.

---

### User Story 5 - Calculate Dependent Relief (Giảm trừ gia cảnh) (Priority: P1)

Every employee receives a personal deduction of 11,000,000/month. Additionally, each registered dependent entitles the employee to an extra 4,400,000/month deduction. These deductions reduce the taxable income before PIT calculation.

**Why this priority**: Dependent relief directly determines how much tax an employee pays. An employee with 3 dependents might pay zero tax while the same salary with 0 dependents pays significant tax. Incorrect dependent handling is the most common payroll complaint.

**Independent Test**: This can be tested by: generating payslips for employees with different dependent counts and verifying the correct deduction amounts are applied to reduce taxable income.

**Acceptance Scenarios**:

1. **Given** any employee generating a payslip, **When** calculating taxable income, **Then** personal deduction of 11,000,000 should always be applied.
2. **Given** employee "Nguyen Van A" with 2 registered dependents, **When** calculating taxable income, **Then** dependent deduction should be 8,800,000 (2 × 4,400,000) and total family deduction should be 19,800,000.
3. **Given** employee with gross 25,000,000, insurance deduction 2,625,000, and 3 dependents, **When** calculating taxable income, **Then** result should be max(0, 25,000,000 - 2,625,000 - 11,000,000 - 13,200,000) = 0 — no tax owed.
4. **Given** employee registers a new dependent on 2025-01-15, **When** generating January payslip, **Then** the new dependent should be counted for the full month (relief applies from month of registration).
5. **Given** deduction amounts are updated (personal to 12,000,000, dependent to 4,800,000), **When** next payslip is generated, **Then** new amounts should be used — deductions must be configurable.

---

### User Story 6 - Calculate PIT Using 7-Bracket Progressive Tax (Priority: P1)

Vietnamese Personal Income Tax uses a 7-bracket progressive table. Each bracket of taxable income is taxed at its own rate. The system must apply this table correctly.

**Why this priority**: This is the core tax calculation. Getting any bracket boundary or rate wrong means every payslip for affected employees is incorrect. The progressive nature (not flat rate) means the calculation is non-trivial.

**Independent Test**: This can be tested by: generating payslips for employees with taxable income at various levels (within single bracket, crossing multiple brackets, at exact boundaries) and verifying PIT amounts against hand-calculated values.

**Acceptance Scenarios**:

1. **Given** taxable income of 4,000,000 (within bracket 1), **When** calculating PIT, **Then** PIT = 4,000,000 × 5% = 200,000.
2. **Given** taxable income of 8,000,000 (crosses brackets 1-2), **When** calculating PIT, **Then** PIT = (5,000,000 × 5%) + (3,000,000 × 10%) = 250,000 + 300,000 = 550,000.
3. **Given** taxable income of 25,000,000 (crosses brackets 1-4), **When** calculating PIT, **Then** PIT = (5M × 5%) + (5M × 10%) + (8M × 15%) + (7M × 20%) = 250,000 + 500,000 + 1,200,000 + 1,400,000 = 3,350,000.
4. **Given** taxable income of 100,000,000 (reaches bracket 7), **When** calculating PIT, **Then** PIT = 250K + 500K + 1,200K + 2,800K + 5,000K + 8,400K + (20M × 35%) = 25,150,000.
5. **Given** taxable income of exactly 5,000,000 (bracket 1 boundary), **When** calculating PIT, **Then** PIT = 250,000 (all at 5%, nothing at 10%).
6. **Given** taxable income of 0 or negative, **When** calculating PIT, **Then** PIT = 0.
7. **Given** the tax bracket table is updated (e.g., bracket 1 raised to 6,000,000), **When** subsequent payslips are generated, **Then** the new table should be used — tax brackets must be configurable.

---

### User Story 7 - Full End-to-End Vietnamese Payslip (Priority: P1)

The system must calculate a complete payslip from gross salary through insurance, dependent relief, PIT, to net salary — following the Vietnamese payroll flow in the correct order.

**Why this priority**: Individual components (insurance, PIT, deductions) are useless if they don't combine correctly. The order matters: insurance is deducted before calculating taxable income, and dependent relief is deducted before applying the tax table.

**Independent Test**: This can be tested by: generating a full payslip for an employee with known contract details and verifying each step of the calculation chain produces the expected intermediate and final values.

**Acceptance Scenarios**:

1. **Given** employee with base 15,000,000, position allowance 2,000,000, lunch 730,000, transport 500,000, 1 dependent, **When** I generate a full payslip, **Then**:
   - Gross = 18,230,000
   - Insurance base = 17,000,000 (base + position only)
   - BHXH = 1,360,000, BHYT = 255,000, BHTN = 170,000, total insurance = 1,785,000
   - Taxable income = 18,230,000 - 1,785,000 - 11,000,000 - 4,400,000 = 1,045,000
   - PIT = 1,045,000 × 5% = 52,250
   - Net = 18,230,000 - 1,785,000 - 52,250 = 16,392,750

2. **Given** a high-income employee with base 50,000,000, position 5,000,000, lunch 730,000, 0 dependents, **When** generating payslip, **Then** insurance caps should be applied, taxable income calculated after capped insurance, and PIT crosses multiple brackets.

3. **Given** a low-income employee with base 8,000,000 and 2 dependents, **When** generating payslip, **Then** taxable income should be 0 (negative before floor), PIT = 0, and net = gross - insurance only.

---

### Edge Cases

- What happens if lương cơ sở changes mid-month? (Use the rate effective at payslip generation date; do not retroactively recalculate previous months)
- What happens if an employee has no contract? (Block payslip generation with clear error message)
- What if dependent count is changed retroactively? (Current month uses current count; previous months are not recalculated unless adjustment payslip is created)
- What if insurance base is zero (e.g., unpaid leave entire month)? (Insurance deduction = 0; company still responsible for employer portion based on contract base)
- How to handle employees exempt from insurance? (Support insurance_exempt flag on contract for foreigners or special cases)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST calculate BHXH employee deduction as (insurance_base × bhxh_employee_rate), capped at (bhxh_cap × bhxh_employee_rate)
- **FR-002**: System MUST calculate BHYT employee deduction as (insurance_base × bhyt_employee_rate), capped at (bhxh_cap × bhyt_employee_rate)
- **FR-003**: System MUST calculate BHTN employee deduction as (insurance_base × bhtn_employee_rate), capped at (bhtn_cap × bhtn_employee_rate)
- **FR-004**: System MUST calculate employer contributions for BHXH (17.5%), BHYT (3%), BHTN (1%) and store them on the payslip without deducting from employee net
- **FR-005**: System MUST display BHXH, BHYT, BHTN as separate lines on payslip (not combined)
- **FR-006**: System MUST compute insurance base as sum of (base_salary + insurance-applicable allowances only)
- **FR-007**: System MUST support flagging each allowance type as insurance_applicable (true/false)
- **FR-008**: System MUST enforce BHXH/BHYT cap = bhxh_cap_multiplier × luong_co_so
- **FR-009**: System MUST enforce BHTN cap = bhtn_cap_multiplier × regional_minimum_wage (separate from BHXH cap)
- **FR-010**: System MUST apply personal deduction of 11,000,000/month to every employee
- **FR-011**: System MUST apply dependent deduction of 4,400,000/month per registered dependent
- **FR-012**: System MUST compute taxable_income = gross - employee_insurance - personal_deduction - dependent_deduction, floored at 0
- **FR-013**: System MUST calculate PIT using 7-bracket progressive table with correct bracket boundaries and rates
- **FR-014**: System MUST store PIT brackets as configurable data (not hardcoded) with effective dates
- **FR-015**: System MUST store insurance rates as configurable data with effective dates
- **FR-016**: System MUST store deduction amounts (personal, dependent) as configurable data with effective dates
- **FR-017**: System MUST compute net_salary = gross - employee_insurance - PIT - other_deductions
- **FR-018**: System MUST include employer insurance totals in finance export and company cost reports
- **FR-019**: System MUST support insurance exemption flag for special cases (foreign employees, interns)
- **FR-020**: System MUST support different regional minimum wages for BHTN cap (regions I-IV)

### Key Entities

- **Insurance Configuration (hrm.insurance.config)**: Stores company-specific insurance rates, caps, base salary reference, and regional minimum wage. One per company, with effective dates for rate changes.
- **PIT Bracket (hrm.pit.bracket)**: Stores the 7-bracket progressive tax table with lower/upper bounds and rates. Configurable per company with effective dates.
- **Employee Extensions**: dependent_count, tax_id, social_insurance_id fields added to hr.employee for Vietnamese payroll.
- **Allowance Type**: Each allowance type has an insurance_applicable flag determining inclusion in insurance base.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: BHXH, BHYT, BHTN calculations are 100% accurate against Vietnamese statutory rates for all test cases
- **SC-002**: Insurance cap logic correctly limits deductions for high-income employees in 100% of cases
- **SC-003**: PIT calculation matches hand-calculated values for all 7 brackets with 100% accuracy (VND precision)
- **SC-004**: Dependent relief correctly reduces taxable income for employees with 0-10 dependents
- **SC-005**: End-to-end payslip (gross → insurance → taxable → PIT → net) produces correct net salary in 100% of test cases
- **SC-006**: Insurance rate changes take effect on subsequent payslips without requiring code changes
- **SC-007**: Finance export includes all required Vietnamese statutory fields (BHXH, BHYT, BHTN, PIT, employer contributions)

## Assumptions

- **Rates**: Default rates follow current Vietnamese law (BHXH 8%/17.5%, BHYT 1.5%/3%, BHTN 1%/1%); all rates are configurable for future changes
- **Lương cơ sở**: Default 2,340,000 VND (as of July 2024); configurable when government updates
- **Regional minimum wage**: Default 4,960,000 VND for region I; configurable per company based on location
- **Dependent registration**: HR is responsible for maintaining accurate dependent counts; system does not validate dependent eligibility
- **Currency**: All calculations in VND; rounding follows standard VND rules (round to nearest VND)
- **Tax period**: Monthly PIT calculation (not cumulative annual); year-end reconciliation is separate
- **Insurance exemption**: Some employees (foreigners on certain visas, interns) may be exempt; system supports exemption flag
