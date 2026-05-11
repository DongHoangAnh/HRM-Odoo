# HR Payroll Business Spec

## Goal
Build production payroll functionality that calculates, processes, and manages employee salaries based on work entries, leave, and salary structures.

## Project Context (Context Discovery alignment)

- Scope limited to Employee, Attendance, Leave, Payroll, Recruitment.
- Support separate salary structures for office staff and teachers; teachers and TAs are managed in `hr.employee` and may be paid by teaching hours when configured.
- Must comply with Vietnamese payroll rules (BHXH, BHYT, BHTN, PIT, dependent relief) and provide export formats required by Finance.
- Technical constraints: Odoo 19; do not modify core; implement custom logic in namespaced modules like `hrm_payroll`.

## Primary Users
- Payroll Manager
- HR Manager
- Accountant
- Finance Manager
- Employee
- System Administrator

## Core Business Capabilities

### Payslip generation
- Generate payslips for employees based on work entries and contracts.
- Support batch payslip generation for all employees in a period.
- Track payslip state (draft, submitted, approved, done).
- Prevent manipulation of validated/approved payslips.

### Salary calculation
- Calculate gross salary from base salary and work hours.
- Support overtime payment with configurable multipliers.
- Support teaching-hour-based pay for teachers and TAs.
- Include bonuses, commissions, and allowances.

### Deductions and taxes
- Support Vietnamese tax system (BHXH, BHYT, BHTN, PIT).
- Calculate progressive income tax with dependents relief.
- Apply salary deductions (loans, advances, overpayment recovery).
- Track meal vouchers and non-monetary benefits.

### Salary structures
- Define separate structures for office staff and teachers.
- Support multiple salary components (base, allowance, bonus, etc.).
- Preserve salary structure history for audit trail.

### Payment and approval
- Track payment method (bank transfer, check, cash).
- Support approval workflow (HR → Finance → Payment).
- Generate payslip documents for employees and Finance.
- Provide employee self-service access to payslips.

### Payroll periods
- Define monthly payroll periods.
- Calculate leave encashment at year-end.
- Support mid-month changes (transfer, promotion, termination).

## Production Outcomes
- Finance receives consistent payroll output format.
- Employees can view their payslips with salary breakdown.
- HR has full audit trail of salary calculations and changes.
- Taxes and deductions comply with Vietnamese law.

## Acceptance Criteria
- A payslip reflects all work entries for the period.
- Gross and net salary are calculated correctly.
- All applicable deductions are applied.
- Payslip output can be exported for bank transfers.
- Payslips remain locked after approval.
- Year-end leave encashment is calculated separately.
