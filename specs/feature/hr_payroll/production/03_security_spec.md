# HR Payroll Security Spec

## Access Control Model

### Group: HR Officer
- **Payslip read/write**: Own payslips only
- **Payroll structure read**: All
- **Salary rule read**: All
- **Payslip run read**: All

## Project Context (Context Discovery alignment)

- Payroll security must reflect Vietnamese legal constraints on payroll data and limit export of sensitive personal data to Finance only when necessary.
- Net salary, tax breakdowns, and bank account fields should be visible to HR Manager and Accountant only; teaching-hour pay details visible to HR/Payroll roles.

### Group: HR Manager
- **Payslip read/write/create**: All employees
- **Payroll structure read/write/create**: All
- **Salary rule read/write/create**: All
- **Payslip run read/write/create/delete**: All
- **Payroll period read/write/create**: All

### Group: Accountant
- **Payslip read**: All (for approval)
- **Payslip write**: Specific fields only (payment_date, payment_method)
- **Payroll structure read**: All
- **Salary rule read**: All
- **Payslip run read**: All
- Cannot create or delete payslips

### Group: Manager (non-HR)
- **Payslip read**: Own payslip only
- **Payroll structure read**: Own department structures only
- **Salary rule read**: All
- Cannot write or create payslips

### Group: Employee
- **Payslip read**: Own payslip only (via portal)
- No write/create permissions
- Cannot see other employees' payslips

## Field-Level Security

### Sensitive fields (visible only to HR Manager, Accountant):
- net_salary
- total_tax
- total_deductions
- tax_break_down
- bank_account_id

### Employee-visible fields:
- gross_salary
- net_salary
- date_from
- date_to
- line_ids (salary components only)

### HR/Finance only:
- Payroll structure code
- Salary rule python_compute
- Payment method details
- Bank transfer reference

## Record Rules

### All payslips
- Created by: HR Manager, Payroll Manager
- Viewed by: HR, Accountant, self (employees)
- Modified by: HR Manager, Payroll Manager (before approval)
- Deleted by: HR Manager only (before approval)

### Payroll structures
- Created/edited by: HR Manager only
- Viewed by: All HR staff
- Deletion blocked if in use

### Salary rules
- Created/edited by: HR Manager only
- Viewed by: All HR staff
- Deletion blocked if in use

## Workflow Security

### Payslip state transitions
- draft → submitted: HR Manager
- submitted → approved: Accountant (or Finance Manager)
- approved → done: Finance Manager (after payment)
- Any → draft: HR Manager (for corrections)

## Data Residency

- Payroll data must remain in Vietnam company scope.
- No export of personal data without approval.
- Payslip documents must be encrypted if sent via email.

## Audit Trail

- All payslip modifications logged with user, timestamp, old/new values.
- Salary structure changes tracked with effective dates.
- Approval history preserved in payslip state history.
