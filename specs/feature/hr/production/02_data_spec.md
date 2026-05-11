# HR Data Spec

## Project Context (Context Discovery alignment)

- Scope limited to five HR modules: Employee, Attendance, Leave, Payroll, Recruitment.
- Teachers and TAs are stored in `hr.employee` and must include teaching-specific fields (for example, `teaching_hours`, `pay_rate_type`).
- Preserve contract/version history and prevent overlapping active versions for a single employee.
- Custom modules should follow naming convention `hrm_*` and avoid modifying Odoo core.

## Aggregate Model Map

### Core entities
- hr.employee
- hr.version
- hr.department
- hr.employee.public
- hr.employee.category
- hr.work.location
- hr.departure.reason
- hr.contract.type
- hr.payroll.structure.type

### Related external entities
- res.users
- res.partner
- res.partner.bank
- resource.resource
- resource.calendar
- mail.activity.plan
- mail.message
- ir.attachment

## Key Relationships

- hr.employee inherits hr.version through version_id.
- hr.employee has a required resource.resource.
- hr.employee may link to one res.users record per company.
- hr.employee belongs to one company and can have one parent manager and one coach.
- hr.employee may link to many bank accounts through res.partner.bank.
- hr.department has parent/child hierarchy and optional manager.
- hr.version tracks contract and personal data over time.
- hr.employee.public is a read-only projection of employee-safe fields.

## Data Contracts

### Employee identity
- name is stored on resource and reflected on employee.
- barcode must be unique.
- user_id must be unique per company.
- company_id is mandatory.
- active status is mirrored to resource.

### Version and contract data
- date_version is the effective record date.
- contract_date_start and contract_date_end define contract validity.
- current_version_id must reflect the active version at a point in time.
- date_start and date_end are derived from version and contract boundaries.
- contract_template_id may seed values for new versions.

### Private profile data
- legal_name, private phone, private email, birth data, nationality, and permits are private HR data.
- work fields such as work_phone and work_email are synchronized with user-facing data when allowed.

### Salary distribution
- salary_distribution is a JSON map keyed by bank account id.
- each entry must contain sequence, amount, and amount_is_percentage.
- the total percentage allocation must remain valid.
- bank account allocations must reflect employee bank relation changes.

### Department data
- complete_name is computed from parent hierarchy.
- master_department_id is derived from parent_path.
- recursive parent links are forbidden.

### Public model data
- hr.employee.public is read-only and derived from hr.employee.
- only allowed fields should be available on public records.
- manager-only fields must resolve conditionally based on access and reporting line.

## Constraints

- Unique barcode.
- Unique user/company employee link.
- No recursive department tree.
- No overlapping active versions for one employee.
- At least one active version per employee.
- Salary distribution percentages must remain valid.
- Bank allocation caps must stay consistent with account state.

## Derived Fields

- presence state and icon fields.
- last_activity and last_activity_time.
- newly_hired flag.
- work_location_name and work_location_type.
- company country code.
- has_multiple_bank_accounts.
- primary_bank_account_id.
- is_trusted_bank_account.
- member_of_department.

## Data Retention Rules

- Archive does not destroy employee history.
- Unlink of versions is blocked when it would remove all versions for an employee.
- Sensitive notifications and activities must remain linked to the correct responsible users.

## Persistence Expectations

- All computed fields that drive search or reporting must be stored when needed.
- Cross-model sync must be idempotent.
- Reads for public users must not depend on private model-only fields.
