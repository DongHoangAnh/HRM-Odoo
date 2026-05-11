# HR Payroll Specifications (Gherkin/BDD Format)

This directory contains comprehensive Gherkin-based BDD specifications for the HR Payroll module (`hr.payslip` model and related payroll functionality).

## Specification Files

### 1. [01_payroll_calculation.feature](01_payroll_calculation.feature)
**Purpose**: Payroll calculation and processing
- Generate payslips for employees
- Calculate gross salary from work entries
- Include overtime pay with configurable rates
- Include commissions and bonuses
- Deduct taxes (income tax, social security)
- Deduct benefits (loans, advances, meal vouchers)
- Payslip approval and rejection workflow
- Batch payslip generation
- Payslip document generation (PDF)
- Employee portal access to payslips
- Year-end bonus and leave encashment
- Multi-department salary attribution
- Tax withholding and EPF contributions

**Key Scenarios**: 21 scenarios covering payroll calculation and approval

---

## Statistics

- **Total Specification Files**: 1
- **Total Scenarios**: 21
- **Coverage Areas**: Payslip generation, Salary calculation, Deductions, Approval workflow, Tax handling, Benefits, Document generation

## Module Overview

The `hr_payroll` module manages the salary calculation and payslip generation process based on:
- **Work Entries**: Hours worked by employees
- **Leave Records**: Approved leave for deduction or encashment
- **Salary Structures**: Rules defining gross salary components
- **Salary Rules**: Individual rules for calculating components (overtime, taxes, deductions)
- **Employee Contracts**: Active salary and benefits for each employee

## Key Features

### Payslip Generation
- **Manual**: Generate payslips individually or for a payroll period
- **Batch**: Generate all payslips for a period at once
- **Template-based**: Use salary structure templates for consistency

### Salary Components
- **Gross Salary**: Base salary + allowances + bonuses
- **Overtime Pay**: Calculated from work entry hours
- **Teaching Allowance**: For teacher/TA staff (hour-based)
- **Commissions**: Variable pay based on performance
- **Meal Vouchers**: Non-monetary benefit

### Deductions
- **Taxes**: BHXH, BHYT, BHTN (Vietnamese insurance), PIT (income tax)
- **Loans**: Monthly payment for employee loans
- **Advances**: Recovery of salary advances
- **Other**: Custom deductions per company policy

### Payslip States
- **draft**: New payslip, editable
- **submitted**: Submitted for approval
- **approved**: Approved by accountant/finance manager
- **done**: Paid out
- **cancel**: Rejected for correction

### Features by Role
- **HR Manager**: Create, edit, submit payslips; manage salary structures and rules
- **Accountant**: Review and approve payslips; verify calculations
- **Finance Manager**: Approve for payment; generate export files
- **Employee**: View own payslips; download documents
- **System**: Generate batch payslips; enforce tax rules; generate bank files

## Integration Points

### Inputs
- **HR Work Entry**: Provides work hours and overtime for calculation
- **HR Leave**: Provides leave records for deduction and encashment
- **HR Employee**: Provides salary, bank account, tax info
- **HR Department**: For multi-department salary tracking

### Outputs
- **Finance Module**: Bank transfer file, journal entries for payroll expense
- **Employee Portal**: Payslip document download
- **Reporting**: Payroll summary, variance, tax reports

## Production Readiness

See `production/` directory for:
- **01_business_spec.md**: Business objectives and capabilities
- **02_data_spec.md**: Data model and relationships
- **03_security_spec.md**: Access control and compliance
- **04_ui_spec.md**: User interface design
- **05_integration_spec.md**: System integration requirements
