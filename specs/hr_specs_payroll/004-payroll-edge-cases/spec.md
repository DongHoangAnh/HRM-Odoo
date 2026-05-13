# Feature Specification: Payroll Edge Cases and Special Scenarios

**Feature Branch**: `004-payroll-edge-cases`
**Created**: 2026-05-12
**Status**: Draft
**Input**: Supplementary specification for special payroll scenarios — probation salary, net-to-gross, 13th month bonus, payslip inputs, multi-bank distribution, and period locking

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Calculate Probation Salary (Priority: P1)

Vietnamese labor law requires probation salary to be at least 85% of the official salary. The system must automatically apply the probation rate when the contract type is probation.

**Why this priority**: Probation is typically the first contract phase for new hires. Getting this wrong means incorrect pay from day one, creating a bad employee experience and potential legal issues.

**Independent Test**: This can be tested by: creating a probation contract with base salary and probation rate, generating a payslip, and verifying the effective salary is base × probation_rate%.

**Acceptance Scenarios**:

1. **Given** employee with base salary 20,000,000 and probation rate 85%, **When** generating payslip, **Then** effective base salary = 17,000,000 and all calculations (insurance, tax) use this amount.
2. **Given** employee with custom probation rate of 90%, **When** generating payslip, **Then** effective base = 15,000,000 × 90% = 13,500,000.
3. **Given** employee transitioning from probation (ending 2025-01-15) to official (starting 2025-01-16), **When** generating January payslip, **Then** salary should be prorated: probation rate for first 15 days, official rate for remaining 16 days.

---

### User Story 2 - Support Net-to-Gross Salary Calculation (Priority: P2)

Many Vietnamese companies negotiate "net salary" with employees — the employee receives a guaranteed net amount and the company absorbs insurance and tax costs. The system must reverse-calculate the gross from a given net.

**Why this priority**: Net salary agreements are very common in the Vietnamese market, especially for mid-to-senior employees. Without this, HR must manually calculate gross for every net-salary employee, which is error-prone and time-consuming.

**Independent Test**: This can be tested by: creating a contract with salary_type "net" and a net amount, generating a payslip, and verifying the computed gross produces the exact net after all deductions.

**Acceptance Scenarios**:

1. **Given** employee with net salary agreement of 20,000,000 and 1 dependent, **When** generating payslip, **Then** the system should compute gross such that after insurance (10.5%) and PIT (7-bracket), the net equals exactly 20,000,000.
2. **Given** employee with net salary 8,000,000 and 2 dependents (below tax threshold), **When** generating payslip, **Then** gross = 8,000,000 / (1 - 0.105) ≈ 8,938,547 and PIT = 0.
3. **Given** a net-to-gross payslip, **When** viewing the payslip, **Then** it should clearly show both the computed gross and the guaranteed net, with all deduction lines visible.

---

### User Story 3 - Calculate 13th Month Salary / Tet Bonus (Priority: P2)

Most Vietnamese companies pay a year-end bonus equivalent to one month's salary (tháng 13 / thưởng Tết). The system must calculate this with pro-rata for partial-year employees and apply correct tax treatment.

**Why this priority**: The 13th month bonus is a de facto standard in Vietnam. Employees expect it and companies budget for it. Incorrect calculation (especially pro-rata for partial-year employees) is a frequent payroll dispute.

**Independent Test**: This can be tested by: configuring a 13th month policy, generating bonus payslips for full-year and partial-year employees, and verifying amounts and tax treatment.

**Acceptance Scenarios**:

1. **Given** full-year employee with base salary 15,000,000, **When** processing year-end bonus, **Then** bonus = 15,000,000 (1 full month).
2. **Given** employee who started 2025-07-01 with base salary 15,000,000, **When** processing year-end bonus, **Then** bonus = 7,500,000 (15M × 6/12 pro-rata).
3. **Given** employee who left 2025-09-30, **When** processing year-end bonus, **Then** bonus = 11,250,000 (15M × 9/12).
4. **Given** a 13th month bonus of 15,000,000, **When** generating the bonus payslip, **Then** the bonus should be added to regular income for that month and PIT calculated on the combined total.
5. **Given** the bonus is paid in a separate payslip, **When** viewed, **Then** it should be linked to the same payroll period and clearly marked as "bonus" type.

---

### User Story 4 - Support Payslip Inputs for One-Time Items (Priority: P2)

HR needs to add one-time earnings or deductions to specific payslips (performance bonus, referral bonus, penalties, salary advances). These should not be recurring — they apply only to the payslip they're attached to.

**Why this priority**: Every payroll cycle has ad-hoc items that don't fit into regular salary rules. Without payslip inputs, HR must create custom workarounds or modify salary rules — both error-prone and non-auditable.

**Independent Test**: This can be tested by: adding various input types to a payslip, generating, and verifying each input appears as a separate line and correctly affects gross or deductions.

**Acceptance Scenarios**:

1. **Given** employee with regular salary 15,000,000 and a payslip input "Performance Bonus" of 3,000,000, **When** generating payslip, **Then** gross = 18,000,000 and PIT recalculated on new gross.
2. **Given** a payslip input "Penalty" of 500,000 (category: deduction), **When** generating payslip, **Then** penalty appears as deduction line and net is reduced by 500,000.
3. **Given** multiple inputs (referral bonus 2M, meal deduction 300K, salary advance 5M), **When** generating payslip, **Then** each appears as separate line, referral in gross, deductions in deductions section.
4. **Given** an HR manager creating a new input type "Project Bonus" with code PROJ_BONUS, **When** saved, **Then** it should be available for selection on any payslip.

---

### User Story 5 - Distribute Salary to Multiple Bank Accounts (Priority: P3)

Some employees want their salary split across multiple bank accounts (e.g., savings and spending). The system must support configurable salary distribution percentages.

**Why this priority**: While not critical for payroll calculation, multi-bank distribution is important for employee satisfaction and reduces manual work for finance teams processing bank transfers.

**Independent Test**: This can be tested by: configuring employee salary distribution across 2 accounts, generating a payslip, and verifying the bank transfer file splits the net salary correctly.

**Acceptance Scenarios**:

1. **Given** employee with net 16,000,000 and distribution: VCB 70%, TCB 30%, **When** processing payment, **Then** VCB receives 11,200,000 and TCB receives 4,800,000.
2. **Given** employee with single bank account, **When** processing payment, **Then** full net goes to that account.
3. **Given** distribution percentages totaling 90% (not 100%), **When** saving, **Then** system should reject with error.

---

### User Story 6 - Prorate Salary for Mid-Month Start or Termination (Priority: P1)

Employees who join or leave mid-month should receive prorated salary based on actual working days. The system must calculate pro-rata amounts correctly.

**Why this priority**: New hires and terminations happen every month. Without pro-rata, the company either overpays (full month for partial work) or underpays (no pay for partial month). Both create problems.

**Independent Test**: This can be tested by: creating employees with mid-month start/end dates, generating payslips, and verifying salary is prorated by working days.

**Acceptance Scenarios**:

1. **Given** employee starting 2025-01-16 with base salary 20,000,000 and 22 working days in January, employee works 12 days, **When** generating payslip, **Then** prorated salary ≈ 10,909,091 (20M / 22 × 12).
2. **Given** employee terminated 2025-01-20 with base salary 18,000,000, worked 14 of 22 days, **When** generating payslip, **Then** prorated salary ≈ 11,454,545.
3. **Given** prorated salary, **When** calculating insurance and tax, **Then** they should be based on the prorated gross, not the full monthly salary.

---

### User Story 7 - Handle Unpaid Leave Deductions (Priority: P1)

Days of unpaid leave must be deducted from the employee's salary. Paid leave (annual, sick within allowance) should not result in any deduction.

**Why this priority**: Leave deductions are part of every payroll cycle. Incorrectly deducting paid leave or failing to deduct unpaid leave are both immediate payroll errors visible to employees.

**Independent Test**: This can be tested by: generating payslips for employees with unpaid and paid leave, verifying deduction amounts and that paid leave has zero deduction.

**Acceptance Scenarios**:

1. **Given** employee with base 20,000,000, 22 working days, 3 days unpaid leave, **When** generating payslip, **Then** deduction = 20M / 22 × 3 ≈ 2,727,273.
2. **Given** employee who took 2 paid sick leave days (within allowance), **When** generating payslip, **Then** sick leave deduction = 0 and gross = full base salary.

---

### User Story 8 - Lock and Unlock Payroll Periods (Priority: P2)

After all payslips are approved and paid, the payroll period should be lockable to prevent accidental modifications. Authorized users can unlock for corrections.

**Why this priority**: Locking prevents accidental changes to finalized payroll data, which is important for audit compliance and data integrity. It's needed before any production deployment.

**Independent Test**: This can be tested by: approving all payslips, locking the period, attempting modifications (should fail), then unlocking and verifying modifications are possible again.

**Acceptance Scenarios**:

1. **Given** all payslips for January are "done", **When** I lock the period, **Then** state = "closed" and no modifications allowed.
2. **Given** draft payslips still exist, **When** trying to lock, **Then** system prevents with error listing unapproved payslips.
3. **Given** locked period and HR Manager role, **When** unlocking, **Then** period reopens and the unlock is logged in audit trail.

---

### Edge Cases

- What if an employee has both a regular payslip and a bonus payslip in the same month? (Both should exist as separate records, PIT considers cumulative income)
- What if net-to-gross calculation results in a fractional VND? (Round to nearest VND using standard rounding)
- What if probation rate is set below 85%? (System should warn that this violates Vietnamese labor law minimum)
- What happens to payslip inputs if the payslip is rejected? (Inputs remain attached; they are reused when payslip is regenerated)
- How to handle retroactive salary increases? (Create adjustment payslip for the difference; do not modify locked periods)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST apply probation_rate to base salary when contract_type = "probation"
- **FR-002**: System MUST warn when probation_rate < 85% (Vietnamese law minimum)
- **FR-003**: System MUST prorate salary when employee start/end date falls within payroll period
- **FR-004**: System MUST calculate pro-rata as (base_salary / working_days_in_month × actual_days_worked)
- **FR-005**: System MUST support salary_type "net" on contracts and reverse-calculate gross
- **FR-006**: System MUST ensure net-to-gross calculation produces the exact agreed net after all deductions
- **FR-007**: System MUST calculate 13th month bonus as (base_salary × months_worked / 12)
- **FR-008**: System MUST support 13th month bonus as a separate payslip linked to the same period
- **FR-009**: System MUST include bonus income in PIT calculation for the month it is paid
- **FR-010**: System MUST support hr.payslip.input records for one-time earnings and deductions
- **FR-011**: System MUST support configurable hr.payslip.input.type with category (earnings/deduction)
- **FR-012**: System MUST deduct unpaid leave as (base_salary / working_days × unpaid_days)
- **FR-013**: System MUST NOT deduct salary for paid leave types (annual, sick within allowance)
- **FR-014**: System MUST support salary distribution to multiple bank accounts with percentage split
- **FR-015**: System MUST validate salary distribution percentages total exactly 100%
- **FR-016**: System MUST support locking/closing a payroll period to prevent modifications
- **FR-017**: System MUST prevent closing a period with non-finalized payslips
- **FR-018**: System MUST support unlocking a period for authorized roles with audit logging
- **FR-019**: System MUST support adjustment payslips for retroactive corrections without modifying locked periods

### Key Entities

- **Contract Extensions**: probation_rate, salary_type (gross/net), fields on hr.contract
- **Payslip Input (hr.payslip.input)**: One-time earnings/deductions attached to a specific payslip
- **Payslip Input Type (hr.payslip.input.type)**: Configurable types (bonus, penalty, advance, referral)
- **Salary Distribution**: Employee bank account distribution rules with percentage splits
- **Payroll Period**: Extended with is_closed flag and lock/unlock workflow

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Probation salary calculated at correct rate in 100% of test cases
- **SC-002**: Pro-rata calculations for mid-month start/end accurate within 1 VND of hand-calculated values
- **SC-003**: Net-to-gross calculation produces exact agreed net salary (0 VND variance) in 100% of cases
- **SC-004**: 13th month bonus pro-rata correct for all employment duration scenarios (full year, partial, terminated)
- **SC-005**: Payslip inputs correctly increase gross (earnings) or increase deductions (deductions) in 100% of cases
- **SC-006**: Salary distribution splits net to correct bank accounts with correct amounts
- **SC-007**: Locked periods cannot be modified by any user role; unlock requires audit logging

## Assumptions

- **Probation Duration**: System does not enforce probation duration limits (2 months for normal, 6 months for management); HR manages this manually
- **Pro-rata Method**: Working days method used (salary / working_days × actual_days); calendar day method is not used
- **Net-to-Gross Algorithm**: Iterative calculation may be needed due to circular dependency (gross affects insurance affects tax affects net); convergence within 10 iterations
- **13th Month Policy**: Configurable; default is one month base salary; some companies may offer different multiples
- **Bonus Tax**: Bonus is taxed as regular income in the month paid; separate tax treatment for bonuses is not applicable in Vietnam
- **Adjustment Payslips**: Corrections create new adjustment payslips (positive or negative) rather than modifying existing finalized payslips
