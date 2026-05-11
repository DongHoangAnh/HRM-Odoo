# HR Payroll Production Specs

This directory contains the production specification layer for the Odoo HR Payroll module.

## Spec Files

### 1. [01_business_spec.md](01_business_spec.md)
**Focus**: Business objectives and capabilities
- Payslip generation and lifecycle
- Salary calculation (gross, net, deductions)
- Tax and deduction handling
- Payroll periods and workflows
- Approval and payment tracking

### 2. [02_data_spec.md](02_data_spec.md)
**Focus**: Data model and relationships
- Core entities (Payslip, Salary Rule, Payroll Structure)
- Data contracts and constraints
- Relationships with HR and Finance modules
- Derived fields and calculations
- Persistence and audit trail

### 3. [03_security_spec.md](03_security_spec.md)
**Focus**: Access control and compliance
- Group permissions (HR, Payroll, Accountant, Employee)
- Field-level security for sensitive data
- Record rules and workflow security
- Data residency and compliance
- Audit logging requirements

### 4. [04_ui_spec.md](04_ui_spec.md)
**Focus**: User interface and experience
- Views (list, form, calendar)
- Tabs and sections
- Wizards and dialogs
- Reports and exports
- Employee self-service portal

### 5. [05_integration_spec.md](05_integration_spec.md)
**Focus**: System integration and interfaces
- Integration with HR Work Entry, Leave, Attendance
- Finance export format
- External APIs and webhooks
- Data exchange protocols
- Error handling and constraints
