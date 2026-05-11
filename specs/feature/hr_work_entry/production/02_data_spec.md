# HR Work Entry Data Spec

## Aggregate Model Map

### Core entities
- hr.work.entry
- hr.work.entry.type
- hr.version work-entry extensions

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

## Persistence Expectations

- Generation must be idempotent for the same contract/date scope.
- Recompute must keep boundaries aligned with generated data.
- Split and postprocess logic must preserve record integrity.
