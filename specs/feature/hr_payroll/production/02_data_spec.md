# HR Payroll Data Spec

## Project Context (Context Discovery alignment)

- Payroll must support both office staff and teaching payroll structures; teaching hours from `hr.attendance` or Operations must be consumable.
- Include Vietnamese statutory fields (insurance IDs, PIT flags, dependent counts) in data contracts; avoid hardcoding legal logic.
- Keep custom payroll fields and modules namespaced under `hrm_*` and avoid core changes.

## Aggregate Model Map

### Core entities
- hr.payslip
- hr.payroll.structure
- hr.payroll.structure.type
- hr.salary.rule
- hr.salary.rule.category
- hr.payslip.run
- hr.payslip.line
- hr.payslip.input
- hr.payslip.input.type
- hr.payroll.period

### Vietnamese statutory entities
- hrm.insurance.config (BHXH/BHYT/BHTN rates, caps, base salary reference)
- hrm.pit.bracket (7-bracket progressive tax table)

### Related entities
- hr.employee (extended with Vietnamese payroll fields)
- hr.version
- hr.contract (extended with pay_type, probation fields)
- hr.work.entry
- hr.leave
- res.company
- res.partner
- res.partner.bank (salary distribution)

## Key Relationships

- hr.payslip belongs to one employee and one payslip.run.
- hr.payroll.structure belongs to one hr.payroll.structure.type (e.g., "Worker", "Employee").
- hr.payroll.structure defines salary components for employee categories.
- hr.salary.rule belongs to one hr.salary.rule.category and one hr.payroll.structure.
- hr.salary.rule.category groups rules (BASIC, GROSS, ALW, DED, NET, etc.).
- hr.payslip.run groups payslips for one or more employees in a period.
- hr.payslip.line contains individual salary components and amounts.
- hr.payslip.input provides additional one-time inputs per payslip (bonuses, penalties).
- hr.payslip.input.type defines available input types (performance bonus, penalty, etc.).
- hr.work.entry feeds hours and types into payslip calculation.
- hrm.insurance.config belongs to res.company (one config per company).
- hrm.pit.bracket belongs to res.company (configurable per company).

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

### Salary rule category data (NEW — previously missing)
- name: display name (e.g., "Basic", "Gross", "Allowance", "Deduction", "Net").
- code: unique identifier (BASIC, GROSS, ALW, DED, COMP_DED, TAX, NET).
- parent_id: optional parent category for hierarchical grouping.
- Default categories required at install:
  - BASIC: Base salary
  - ALW: Allowances (position, seniority, etc.)
  - GROSS: Gross salary (sum of BASIC + ALW + earnings)
  - COMP_DED: Company deductions (employer insurance contributions)
  - DED: Employee deductions (BHXH, BHYT, BHTN employee portion)
  - TAX: Tax (PIT)
  - NET: Net salary (GROSS - DED - TAX)

### Payslip input data (NEW — previously missing)
- payslip_id: links to the payslip.
- input_type_id: links to hr.payslip.input.type.
- amount: the monetary value of the input.
- description: optional note explaining the input.

### Payslip input type data (NEW — previously missing)
- name: display name (e.g., "Performance Bonus", "Salary Advance", "Penalty").
- code: unique identifier (PERF_BONUS, SAL_ADV, PENALTY, REFERRAL, TEACH_HOURS_MANUAL).
- category: earnings or deduction (determines how it affects payslip).
- salary_rule_id: optional link to a salary rule for automatic computation.

### Vietnamese insurance configuration data (NEW — previously missing)
- company_id: one configuration per company.
- bhxh_employee_rate, bhxh_employer_rate: BHXH percentages (default 8%, 17.5%).
- bhyt_employee_rate, bhyt_employer_rate: BHYT percentages (default 1.5%, 3%).
- bhtn_employee_rate, bhtn_employer_rate: BHTN percentages (default 1%, 1%).
- luong_co_so: base salary reference for BHXH/BHYT cap (default 2,340,000).
- bhxh_cap_multiplier: multiplier for BHXH/BHYT cap (default 20).
- regional_minimum_wage: for BHTN cap calculation (default per region).
- bhtn_cap_multiplier: multiplier for BHTN cap (default 20).
- insurance_applicable_allowance_ids: list of allowance types that count toward insurance base.
- effective_date: when this configuration takes effect.

### PIT bracket data (NEW — previously missing)
- company_id: per company.
- bracket_number: 1-7.
- lower_bound: start of bracket (0, 5000000, 10000000, 18000000, 32000000, 52000000, 80000000).
- upper_bound: end of bracket (5000000, 10000000, 18000000, 32000000, 52000000, 80000000, unlimited).
- rate: tax rate for this bracket (5%, 10%, 15%, 20%, 25%, 30%, 35%).
- personal_deduction: monthly personal deduction (default 11,000,000).
- dependent_deduction: per-dependent monthly deduction (default 4,400,000).
- effective_date: when this bracket table takes effect.

### Employee payroll extensions (NEW — fields added to hr.employee)
- dependent_count: number of registered tax dependents (Integer, default 0).
- tax_id: personal tax code (Char).
- social_insurance_id: social insurance book number (Char).
- salary_type: "gross" or "net" — determines calculation direction.
- bank_distribution_ids: One2many to salary distribution records.

### Contract payroll extensions (NEW — fields added to hr.contract)
- pay_type: "fixed", "hourly", "fixed_plus_hourly" (Selection).
- hourly_rate: rate per hour for hourly/teaching pay (Monetary).
- base_salary_for_insurance: insurance base if different from base salary (Monetary).
- standard_teaching_hours: standard hours for fixed_plus_hourly type (Float).
- extra_hour_rate: rate for hours exceeding standard (Monetary).
- probation_rate: percentage of full salary during probation (Float, default 85).
- salary_structure_id: link to hr.payroll.structure.

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
