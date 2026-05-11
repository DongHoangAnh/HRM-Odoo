# HR Attendance Data Spec

## Project Context (Context Discovery alignment)

- Attendance must support teaching hours as an explicit data point that can be provided by Operations or computed from attendance events.
- Attendance records must remain usable as payroll input; ensure computed fields match payroll expectations (worked_hours, teaching_hours, validated_overtime_hours).
- Keep attendance customizations in `hrm_attendance` module and avoid changing Odoo core models.

## Aggregate Model Map

### Core entities
- hr.attendance
- hr.attendance.overtime.line
- hr.attendance.overtime.rule
- hr.attendance.overtime.ruleset

### Related entities
- hr.employee
- res.company
- res.config.settings
- resource.calendar
- resource.resource
- hr.version

## Key Relationships

- hr.attendance belongs to one employee.
- hr.attendance.overtime.line belongs to one employee and links back to attendance by check-in and employee.
- hr.attendance.overtime.rule belongs to one ruleset.
- hr.attendance.overtime.ruleset belongs to one company and one country.
- Company settings drive overtime validation mode.

## Data Contracts

### Attendance data
- check_in and check_out define the attendance window.
- worked_hours is derived from check_in and check_out.
- overtime_hours is derived from linked overtime lines.
- validated_overtime_hours counts only approved overtime lines.
- overtime_status reflects the aggregate state of linked overtime lines.

### Overtime line data
- date identifies the overtime day.
- time_start and time_stop define the overtime interval.
- duration and manual_duration represent overtime quantity.
- status can be to_approve, approved, or refused.
- amount_rate stores the overtime pay rate.
- rule_ids stores the applied rules.

### Rule data
- base_off selects quantity or timing.
- timing_type selects work days, non-work days, leave, or schedule.
- quantity_period selects day or week.
- timing_start and timing_stop must stay within day boundaries.
- resource_calendar_id is required for schedule-based timing rules.
- expected_hours and expected_hours_from_contract determine quantity-based logic.

### Ruleset data
- name is required.
- company_id and country_id scope the policy.
- rate_combination_mode controls rate aggregation.
- rules_count is derived from linked rules.
- active controls availability.

## Constraints

- Overtime line time_stop must be after time_start.
- Timing start/stop must be valid hours.
- Quantity rules must define required hours and periods.
- Schedule timing rules require a schedule.
- Negative or invalid configurations must raise validation errors.

## Derived Fields

- attendance display_name
- attendance color
- linked overtime ids
- overtime status
- overtime hours
- validated overtime hours
- overtime rule information display
- ruleset rule count

## Persistence Expectations

- All attendance/overtime aggregates must stay synchronized after overtime writes.
- Overtime line updates must recompute attendance aggregates immediately.
- Rule and ruleset changes must be safe to regenerate against existing attendance history.
