# Feature Specification: Payroll Calculation and Processing

**Feature Branch**: `001-payroll-calculation`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: Payroll Calculation and Processing feature with comprehensive scenarios

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate and Review Payslip (Priority: P1)

Payroll managers and employees need to generate payslips that accurately reflect all earnings components and deductions for a given payroll period. This is the core capability that enables the entire payroll system.

**Why this priority**: This is the foundational feature. Without the ability to generate accurate payslips, no other payroll capability is viable. It directly delivers business value by automating the payslip creation process.

**Independent Test**: This can be fully tested independently by: generating a payslip for an employee with a contract salary and work entries, verifying all components (gross salary, deductions, net salary) are calculated, and validating the payslip document is created.

**Acceptance Scenarios**:

1. **Given** an employee "John Doe" with a contract salary of 60000/year and work entries for January 2025, **When** I generate a payslip for the employee, **Then** a payslip should be created with gross salary calculated from the contract and work entries included.
2. **Given** an employee with monthly salary of 5000, **When** I generate a payslip for January, **Then** gross_salary should include 5000 and be properly documented.
3. **Given** an employee with an approved payslip, **When** I generate a PDF, **Then** a professional payslip document should be created and ready to send to employee.

---

### User Story 2 - Calculate Earnings with Multiple Components (Priority: P1)

The system must accurately calculate various earnings components including overtime, commissions, and bonuses to ensure comprehensive compensation.

**Why this priority**: Complex earning structures are critical for accurate payroll. Most organizations have multiple earnings components that need proper calculation. Incorrect calculations lead to compliance issues and employee dissatisfaction.

**Independent Test**: This can be tested by: creating payslips with overtime hours and commission sales data, verifying correct overtime_pay calculation (hours * hourly_rate * multiplier) and commission_amount inclusion, and validating totals.

**Acceptance Scenarios**:

1. **Given** an employee who worked 10 hours overtime at 1.5x rate with hourly_rate of 25, **When** I generate a payslip, **Then** overtime_pay should be calculated as (10 * 25 * 1.5) = 375.
2. **Given** an employee with commission structure and sales data, **When** I generate a payslip, **Then** commission_amount should be correctly calculated and included in gross salary.
3. **Given** a year-end payroll with bonus policy, **When** I generate December payslip, **Then** bonus_amount should be included and taxed appropriately.

---

### User Story 3 - Apply Deductions and Taxes (Priority: P1)

The system must accurately calculate and apply all required deductions including income tax, social security, and other statutory requirements to determine net salary.

**Why this priority**: Accurate deduction calculation is legally required and ensures employee trust in the payroll system. Incorrect tax or deduction amounts create compliance risks and payroll disputes.

**Independent Test**: This can be tested by: generating a payslip with defined tax rates and deductions, verifying tax_deduction = gross_salary * tax_rate, validating social_security_deduction calculation, and confirming net_salary reflects all deductions.

**Acceptance Scenarios**:

1. **Given** an employee with income tax rate 15%, **When** I generate a payslip with gross_salary 5000, **Then** tax_deduction should be 750 (5000 * 0.15) and net_salary should reflect the deduction.
2. **Given** social security rate of 8%, **When** I generate a payslip, **Then** social_security_deduction should be calculated and included in total deductions.
3. **Given** an employee with outstanding loan with monthly payment 500, **When** I generate a payslip, **Then** loan_deduction should be 500 and included in total deductions.

---

### User Story 4 - Handle Batch Payslip Generation (Priority: P2)

The system must efficiently generate payslips for multiple employees in a single operation to support high-volume payroll processing.

**Why this priority**: While individual payslip generation is essential, batch processing significantly improves operational efficiency for large organizations. This can be implemented after core payslip logic is working.

**Independent Test**: This can be tested by: running batch generation for all employees in a payroll period, verifying payslips are created for all employees with correct individual calculations and work entries used.

**Acceptance Scenarios**:

1. **Given** all employees in the system for January 2025, **When** I batch generate payslips, **Then** payslips should be created for all employees with calculations using correct work entries for each.

---

### User Story 5 - Support Approval and Rejection Workflow (Priority: P2)

Payslips must support a review workflow where accountants can approve or reject payslips, with rejected payslips returning to draft state for corrections.

**Why this priority**: Quality control is important for accuracy, but can be implemented after core generation. This allows for correction of errors before employees see final payslips.

**Independent Test**: This can be tested by: creating draft payslips, reviewing and approving them (state becomes "approved" and employees can see), then rejecting an approved payslip (state returns to "draft" for corrections).

**Acceptance Scenarios**:

1. **Given** a draft payslip, **When** an accountant reviews and approves it, **Then** the state should be "approved" and employees should be able to see it.
2. **Given** an approved payslip with an identified error, **When** I reject it, **Then** the state should return to "draft" and corrections can be made.

---

### User Story 6 - Provide Employee Portal Access (Priority: P2)

Employees need secure access to view their approved payslips with salary breakdowns while keeping sensitive data masked.

**Why this priority**: Employee self-service reduces support burden and improves transparency, but non-critical for initial payroll generation. Can be implemented after approval workflow.

**Independent Test**: This can be tested by: logging in as an employee, viewing an approved payslip, verifying gross/net salary and deductions breakdown are visible, and confirming personal details are appropriately masked.

**Acceptance Scenarios**:

1. **Given** an employee accessing the payroll portal, **When** I view the payslip, **Then** I should see gross/net salary breakdown and deductions details with personal details appropriately masked.

---

### User Story 7 - Support Additional Deductions and Benefits (Priority: P3)

The system must support various non-salary deductions and benefits such as meal vouchers and advance deductions.

**Why this priority**: While important for comprehensive payroll, these are secondary to core tax/deduction calculations and can be implemented after basic deduction logic is working.

**Independent Test**: This can be tested by: creating payslips with meal vouchers and salary advances, verifying meal_voucher_value calculation (daily_rate * working_days) and advance_deduction application.

**Acceptance Scenarios**:

1. **Given** an employee with meal voucher benefit of 10/day for 20 working days, **When** I generate a payslip, **Then** meal_voucher_value should be 200 and included appropriately.
2. **Given** an employee who received salary advance of 1000, **When** I generate the next payslip, **Then** advance_deduction should be 1000 and deducted from gross salary.

---

### User Story 8 - Support Leave Encashment (Priority: P3)

The system must calculate and include leave encashment for unused vacation days in final year-end payslips.

**Why this priority**: Leave encashment is important for year-end processing but not required for ongoing payroll. Can be implemented as an optional feature for year-end cycles.

**Independent Test**: This can be tested by: processing year-end with unused vacation days and encashment allowed, verifying encashment_amount = days * daily_rate and including in final payslip.

**Acceptance Scenarios**:

1. **Given** an employee with 5 unused vacation days and encashment allowed, **When** I process year-end, **Then** encashment_amount should be calculated as (5 * daily_rate) and included in final payslip.

---

### Edge Cases

- What happens when an employee transfers to a different department mid-month? (Salary should reflect both periods with department attribution tracked)
- How does the system handle multiple payslips in a single payroll period? (Adjustment entries should track corrections transparently)
- What occurs when payment method is changed after payslip generation? (Previous payslip method honored; next payslip uses new method)
- How are provisional vs. final payslips differentiated? (Provisional can be modified; final is locked after approval)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST calculate payslip with gross salary from employee contract and work entries
- **FR-002**: System MUST calculate overtime pay as (hours worked * hourly_rate * overtime_multiplier)
- **FR-003**: System MUST include commission amounts when commission structure exists
- **FR-004**: System MUST apply income tax as (gross_salary * tax_rate) and deduct from net salary
- **FR-005**: System MUST calculate social security deductions at configured rates and include in total deductions
- **FR-006**: System MUST support loan deductions with defined monthly payment amounts
- **FR-007**: System MUST calculate meal voucher benefits as (daily_rate * working_days)
- **FR-008**: System MUST support payslip approval workflow with states (draft, approved)
- **FR-009**: System MUST allow rejection of approved payslips to return to draft state
- **FR-010**: System MUST generate PDF payslip document ready for employee distribution
- **FR-011**: System MUST support batch generation of payslips for all employees in a period
- **FR-012**: System MUST generate variation reports showing salary differences month-to-month
- **FR-013**: System MUST support multiple payment methods (Bank Transfer, Cash, Cheque)
- **FR-014**: System MUST provide employee portal with payslip access, salary breakdown, and deductions visibility
- **FR-015**: System MUST mask personal employee details in employee portal view
- **FR-016**: System MUST include year-end bonus amounts with appropriate taxation
- **FR-017**: System MUST support salary advance deductions from subsequent payslips
- **FR-018**: System MUST calculate leave encashment as (unused_days * daily_rate)
- **FR-019**: System MUST track department attribution when employee transfers mid-month
- **FR-020**: System MUST create transparent adjustment entries for payslip corrections
- **FR-021**: System MUST apply progressive tax structures and correct tax slab application
- **FR-022**: System MUST calculate employee provident fund contributions at defined percentage (e.g., 12% of basic salary) and employer matching

### Key Entities

- **Payslip**: Represents calculated compensation for an employee in a payroll period. Includes gross salary, all earnings components, deductions, and net salary. States: draft, approved, rejected, processed.
- **Work Entry**: Records employee work activity (hours worked, overtime, department) for a payroll period. Linked to payslip generation.
- **Earnings Component**: Represents a type of earnings (basic salary, overtime, commission, bonus). Has calculation rules and rates.
- **Deduction Component**: Represents a type of deduction (tax, social security, loan, insurance). Has calculation formulas and thresholds.
- **Contract**: Employee employment contract specifying salary, benefits, deduction rates, and payroll rules.
- **Payroll Period**: Defined time interval (month, week) for which payslips are generated.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Payslip generation for a single employee completes in under 2 seconds with all components accurately calculated
- **SC-002**: Batch payslip generation for 1000 employees completes in under 5 minutes with 100% accuracy
- **SC-003**: Tax and deduction calculations achieve 100% accuracy against defined rules (verified by automated testing)
- **SC-004**: 95% of employees can access and view their payslips successfully within first week of deployment
- **SC-005**: Payslip PDF generation produces professional documents that render correctly on all common browsers and PDF readers
- **SC-006**: Variation reports identify salary differences month-over-month with 100% accuracy
- **SC-007**: Zero payslips approved that fail validation rules (approval workflow catches 100% of calculation errors flagged in validation)

## Assumptions

- **Payroll Period**: System assumes monthly payroll periods; weekly/bi-weekly can be configured but core logic designed for monthly processing
- **Tax Rates**: Fixed tax rates provided by administrators; progressive tax calculation rules will be pre-configured based on jurisdiction standards
- **Existing Contracts**: Employee contracts with salary, tax rates, and deduction percentages already exist in the system and remain stable during a payroll period
- **Work Entries**: Work entries (hours, overtime, department assignments) are pre-populated in the system before payslip generation
- **Exchange Rates**: Multi-currency support is out of scope; all payroll calculations assume single organization currency
- **Retroactive Payroll**: System supports correcting payslips in draft/approved state; retroactive payroll cycles are manually triggered and explicitly documented
- **Integration**: System integrates with existing employee records, contract management, and work entry systems; single sign-on (SSO) authentication is assumed for employee portal access
- **Performance**: Batch processing assumes standard IT infrastructure; extreme scale (10k+ employees) may require additional optimization
- **Privacy**: Personal details masked in portal view include: full SSN/ID number, home address, banking details; only necessary salary information displayed
