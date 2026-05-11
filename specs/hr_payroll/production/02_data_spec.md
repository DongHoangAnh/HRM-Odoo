# HR Payroll Data Spec

## Project Context (Context Discovery alignment)

- Payroll must support both office staff and teaching payroll structures; teaching hours from `hr.attendance` or Operations must be consumable.
- Include Vietnamese statutory fields (insurance IDs, PIT flags, dependent counts) in data contracts; avoid hardcoding legal logic.
- Keep custom payroll fields and modules namespaced under `hrm_*` and avoid core changes.

## Aggregate Model Map

### Core entities
- hr.payslip
- hr.payroll.structure
- hr.salary.rule
- hr.payslip.run
- hr.payroll.period

### Related entities
- hr.employee
- hr.version
- hr.work.entry
- hr.leave
- hr.payslip.line
- res.company
- res.partner

## Key Relationships

- hr.payslip belongs to one employee and one payslip.run.
- hr.payroll.structure defines salary components for employee categories.
- hr.salary.rule applies rules to each payslip (gross, deductions, taxes).
- hr.payslip.run groups payslips for one or more employees in a period.
- hr.payslip.line contains individual salary components and amounts.
- hr.work.entry feeds hours and types into payslip calculation.

## Data Contracts

### Payslip data
- payslip_run_id, employee_id, date_from, date_to are immutable after creation.
- state reflects draft, submitted, approved, or done.
- line_ids contains all salary components and their calculated amounts.
- gross_salary, net_salary are computed from line_ids.
- paid_date tracks when payment actually occurred.

### Salary structure data
- name, code uniquely identify the structure.
- company_id specifies which company uses it.
- rule_ids linked to all applicable salary rules.
- in_xml_id tracks structure for quick lookup.

### Salary rule data
- name, code uniquely identify the rule.
- sequence determines calculation order.
- category_id groups related rules (gross, tax, deduction, etc.).
- amount_type defines how to calculate (fixed, percentage, code).
- python_compute allows complex logic for special cases.

### Payroll period data
- name, start_date, end_date define the period.
- company_id specifies jurisdiction.
- payslip_ids lists all payslips generated for the period.
- is_closed prevents modification after closure.

## Constraints

- Payslip date_to must be >= date_from.
- Payslip amount fields must be numeric (no negative gross without approval).
- Salary rule python_compute must be syntactically valid.
- No duplicate payslips for same employee+period.
- Payslip state transitions must follow workflow rules.

## Derived Fields

- gross_salary (sum of all lines in gross category)
- net_salary (gross - deductions)
- total_tax (sum of tax lines)
- total_deductions (sum of deduction lines)
- payslip display name (employee name + period)

## Persistence Expectations

- Payslip calculation must be deterministic (same input → same output).
- Approved payslips are immutable (except corrections via adjustment payslips).
- Salary rule history is maintained via date_effective fields.
- Teacher vs. office staff structures remain separate.
