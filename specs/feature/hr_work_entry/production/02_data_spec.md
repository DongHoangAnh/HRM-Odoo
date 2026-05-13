# HR Work Entry Data Spec

## Aggregate Model Map

### Core entities
- hr.work.entry
- hr.work.entry.type
- hr.version work-entry extensions

## Project Context (Context Discovery alignment)

- Work-entry generation must accept inputs from attendance and leave and produce deterministic intervals for payroll; teaching-hours should be representable where relevant.
- Keep generation logic namespaced under `hrm_*` and do not change Odoo core models.

### Related entities
- hr.employee
- hr.version
- resource.calendar
- resource.calendar.attendance
- resource.calendar.leaves
- hr.leave
- hr.attendance
- res.company

## Key Relationships

- hr.work.entry belongs to one employee and one version.
- hr.work.entry.type defines the kind of generated interval.
- hr.version defines generation source, generated boundaries, and work-entry metadata.
- resource.calendar and related helpers provide attendance and leave intervals.
- hr.leave and hr.attendance feed generation logic.

## Data Contracts

### Work entry data
- date, duration, date_start, and date_stop must remain consistent.
- state must represent draft, conflict, validated, or cancelled behavior.
- company_id, employee_id, version_id, and work_entry_type_id are core links.
- generated work entries must preserve timezone-normalized dates.

### Work entry type data
- code must be unique.
- country constraints must be respected.
- is_work must reflect whether the type is a work type or leave type.
- is_leave must be the inverse of is_work (a type is either work or leave).
- salary_rule_code: optional mapping to a salary rule for payroll computation.
- color: display color for UI differentiation.
- sequence: ordering in lists and dropdowns.

### Default work entry types (Seed Data — NEW)
The following types must be created on module installation for Vietnamese companies:

| code     | name                   | is_work | is_leave | salary_rule_code | notes                        |
|----------|------------------------|---------|----------|------------------|------------------------------|
| WORK100  | Normal Working Day     | true    | false    | BASE             | Standard calendar work       |
| WORK110  | Overtime               | true    | false    | OT               | Hours beyond standard        |
| WORK200  | Teaching Hours         | true    | false    | TEACH_HOURS      | GV/TA teaching time          |
| LEAVE100 | Paid Time Off          | false   | true     | PAID_LEAVE       | Annual/personal leave        |
| LEAVE110 | Sick Leave             | false   | true     | SICK_LEAVE       | Within paid sick allowance   |
| LEAVE120 | Unpaid Leave           | false   | true     | UNPAID_LEAVE     | Deducted from salary         |
| LEAVE200 | Maternity Leave        | false   | true     | MATERNITY        | Vietnamese law: 6 months     |
| LEAVE210 | Paternity Leave        | false   | true     | PATERNITY        | Vietnamese law: 5-7 days     |
| LEAVE300 | Public Holiday         | false   | true     | PUBLIC_HOLIDAY   | Paid, not from leave balance |
| LEAVE310 | Compensatory Time Off  | false   | true     | COMP_OFF         | OT compensation as time-off  |

### Version generation data
- date_generated_from and date_generated_to track the generated range.
- last_generation_date tracks the last successful generation.
- work_entry_source defines generation source.
- work_entry_source_calendar_invalid indicates bad configuration.

## Constraints

- Work entry duration must be positive and within daily bounds.
- Work entry conflicts must be computed from overlaps.
- Work entry type codes must be unique.
- Work-entry generation must not run with missing timezone context.
- Removal/cancel flows must protect validated records.

## Derived Fields

- work entry display name
- conflict state
- has_work_entries on employee
- work_entry_source_calendar_invalid
- default work entry type ids
- generated boundary dates

### Work entry payroll link data (NEW)
- payslip_id: optional link to the payslip that consumed this work entry.
- When a payslip is generated, work entries used are linked to it.
- State transitions to "payslip_included" when linked to an approved payslip.
- Work entries in "payslip_included" state are immutable.

### Public holiday configuration (NEW)
- resource.calendar.leaves is used to define public holidays.
- Public holidays generate work entries of type LEAVE300.
- Vietnamese standard holidays (11 days/year) should be pre-configured:
  - Tet Duong Lich (1/1): 1 day
  - Tet Nguyen Dan (Lunar calendar): 5 days
  - Hung Kings Commemoration (10/3 lunar): 1 day
  - Reunification Day (30/4): 1 day
  - International Labour Day (1/5): 1 day
  - National Day (2/9): 2 days
- Company can add additional holidays via resource.calendar.leaves.
- Working on a public holiday generates WORK110 (Overtime) with holiday_overtime flag.

### Teaching hours extensions (NEW)
- hr.work.entry gains optional fields for teaching context:
  - class_name: name of the class taught (Char, optional).
  - import_source: "attendance", "manual", "operations_import" (Selection).
  - import_batch_id: reference to the import batch if imported (Char).
- These fields are only relevant for WORK200 type entries.

## Persistence Expectations

- Generation must be idempotent for the same contract/date scope.
- Recompute must keep boundaries aligned with generated data.
- Split and postprocess logic must preserve record integrity.
- Work entries linked to approved payslips must not be modified or deleted.
- Public holiday entries must be regenerated if the holiday calendar changes.
