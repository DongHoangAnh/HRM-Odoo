# Data Model — Overtime Management

## Entities

- **OvertimeLine**
  - `id` (PK)
  - `employee_id` (FK to employee)
  - `start_datetime` (UTC)
  - `end_datetime` (UTC)
  - `computed_duration` (hours)
  - `manual_duration` (hours, nullable)
  - `duration` (hours; authoritative: manual if present else computed)
  - `status` (enum: `pending`, `approved`, `refused`)
  - `attendance_id` (nullable FK to Attendance)
  - `compensation_outcome` (enum: `time_off`, `monetary`, `none`)
  - `created_by`, `approved_by`, `approval_date`, `notes`, `created_at`, `updated_at`

- **AttendanceOvertimeAggregate**
  - `attendance_id` (PK)
  - `overtime_hours` (sum of related overtime `duration`)
  - `validated_overtime_hours` (sum of `approved` durations)
  - `overtime_status` (enum: `none`, `pending`, `validated`, `mixed`)

- **OvertimeRule**
  - `id`, `name`, `threshold_hours`, `applicability_window` (time ranges), `priority`, `action` (flag/warn/convert)

- **OvertimeRuleset**
  - `id`, `company_id`, ordered list of `OvertimeRule` ids

## Validation rules
- `end_datetime` MUST be after `start_datetime`.
- `duration` computed as `manual_duration` if present, else `computed_duration`.
- Linking: prefer direct `attendance_id` when unique match by employee and time; otherwise mark as unlinked.
