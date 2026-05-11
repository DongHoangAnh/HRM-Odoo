# Contract: Overtime Ruleset and Rule Management

## Scope

This contract defines the expected interface behavior for overtime policy configuration and regeneration in Odoo HR Attendance.

## Interface 1: Create Ruleset

- Entry point: Odoo model create on `hr.attendance.overtime.ruleset`
- Caller: HR Attendance Manager role

### Input Schema

- `name` (string, required)
- `company_id` (integer, required)
- `country_id` (integer, required)
- `combination_mode` (enum: `max_rate|sum_rate`, optional, default `max_rate`)
- `active` (boolean, optional, default `true`)

### Behavior

- Creates a new ruleset with default `active=true` if omitted.
- Computes and exposes `rule_count` from linked rules.

### Errors

- Missing company/country: validation error with field-specific message.
- Invalid combination mode: validation error.

## Interface 2: Create/Update Overtime Rule

- Entry point: Odoo model create/write on `hr.attendance.overtime.rule`
- Caller: HR Attendance Manager role

### Input Schema

- `ruleset_id` (integer, required)
- `name` (string, required)
- `rule_type` (enum: `quantity|timing`, required)
- `quantity_period` (enum: `day|week|month`, required for `quantity`)
- `expected_hours_mode` (enum: `contract|fixed`, required for `quantity`)
- `expected_hours` (number, required and > 0 for `fixed` mode)
- `timing_type` (enum: `work_day|non_work_day|leave|schedule_window`, required for `timing`)
- `schedule_id` (integer, required for schedule-dependent timing)
- `start_hour` (number 0..24, optional)
- `end_hour` (number 0..24, optional)
- `rate_multiplier` (number, required)

### Behavior

- Saves only valid policy configurations.
- Updates rule info display summary used by managers.
- Keeps inactive rules excluded from active evaluation.

### Errors

- Quantity rule missing period or expected-hours source.
- Quantity rule with fixed mode and missing/non-positive expected hours.
- Timing rule requiring schedule but missing `schedule_id`.
- Hour bounds outside `0..24` or end before start.

## Interface 3: Regenerate Overtime

- Entry point: wizard action or model method `action_regenerate_overtime` on ruleset
- Caller: HR Attendance Manager role

### Input Schema

- `ruleset_id` (integer, required)
- `date_from` (datetime, required)
- `date_to` (datetime, required)
- `employee_ids` (list[int], optional filter)
- `dry_run` (boolean, optional, default `false`)

### Behavior

- Resolves eligible attendances within scope.
- Recomputes overtime using active rules at execution time.
- Applies configured aggregation mode (`max_rate` or `sum_rate`).
- Preserves attendance records outside eligibility scope.
- Returns run summary metrics (`eligible_count`, `processed_count`, `skipped_count`).

### Errors

- Unauthorized caller: access error.
- Invalid date range (`date_to < date_from`): validation error.
- Ruleset not active or has no valid active rules: business error.

## Compatibility and Audit Expectations

- Regeneration is idempotent for unchanged inputs/ruleset state.
- Validation messages are user-facing and actionable.
- Runs must be auditable with requester, time range, and outcome counts.
