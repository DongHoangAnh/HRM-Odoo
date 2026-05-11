# Data Model: Overtime Rules and Ruleset Configuration

## Entity: Overtime Ruleset

- Proposed model: `hr.attendance.overtime.ruleset`
- Purpose: Company/country policy container for overtime generation and rule aggregation.

### Fields

- `name` (Char, required): Human-readable ruleset name.
- `active` (Boolean, default `True`): Whether ruleset is currently active.
- `company_id` (Many2one -> `res.company`, required): Company scope.
- `country_id` (Many2one -> `res.country`, required): Country/legal scope.
- `combination_mode` (Selection, required, default `max_rate`): Rule aggregation strategy.
  - `max_rate`: Use highest applicable computed overtime output.
  - `sum_rate`: Add applicable overtime outputs.
- `rule_ids` (One2many -> `hr.attendance.overtime.rule`): Attached policy rules.
- `rule_count` (Integer, computed, stored): Number of linked rules.

### Validation Rules

- Ruleset must be scoped by both company and country.
- `combination_mode` must be one of the allowed enum values.

### State Transitions

- Active lifecycle: `active=True` (operational) <-> `active=False` (disabled/archive).

## Entity: Overtime Rule

- Proposed model: `hr.attendance.overtime.rule`
- Purpose: Defines overtime eligibility and calculation conditions.

### Fields

- `ruleset_id` (Many2one -> `hr.attendance.overtime.ruleset`, required, ondelete=`cascade`)
- `name` (Char, required)
- `active` (Boolean, default `True`)
- `rule_type` (Selection, required):
  - `quantity`: based on worked-vs-expected quantity
  - `timing`: based on schedule/time windows
- `timing_type` (Selection, required for timing rules):
  - `work_day`
  - `non_work_day`
  - `leave`
  - `schedule_window`
- `expected_hours_mode` (Selection, required for quantity rules):
  - `contract`
  - `fixed`
- `expected_hours` (Float, required if `expected_hours_mode=fixed`)
- `quantity_period` (Selection, required for quantity rules):
  - `day`
  - `week`
  - `month`
- `schedule_id` (Many2one -> `resource.calendar`, required for schedule-dependent timing rules)
- `start_hour` (Float, optional): lower boundary hour in day.
- `end_hour` (Float, optional): upper boundary hour in day.
- `rate_multiplier` (Float, required): multiplier used when rule applies.
- `sequence` (Integer, default `10`): deterministic evaluation ordering.
- `description` (Text): detailed rule information for display.

### Validation Rules

- Quantity rules require `quantity_period`.
- Quantity rules require expected-hours source:
  - if `expected_hours_mode=fixed`, `expected_hours > 0` is required.
  - if `expected_hours_mode=contract`, contract schedule data must be available at evaluation time.
- Timing rules requiring schedule context must have `schedule_id`.
- Hour boundaries must satisfy:
  - `0.0 <= start_hour <= 24.0`
  - `0.0 <= end_hour <= 24.0`
  - if both present, `end_hour >= start_hour`

## Entity: Rule Applicability Context (Derived)

- Nature: Transient evaluation input derived from linked records; not a standalone persistent business table.
- Source data:
  - Attendance interval (`check_in`, `check_out`, duration)
  - Employee contract/calendar context
  - Working-day classification
  - Approved leave intervals
  - Company timezone/date boundaries

### Derived Flags/Values

- `is_work_day`
- `is_non_work_day`
- `is_leave_interval`
- `within_schedule_window`
- `worked_hours`
- `expected_hours`

## Entity: Regeneration Job Result

- Proposed model: `hr.attendance.overtime.regeneration` (or wizard-backed transient + logs)
- Purpose: Track recomputation runs and audit outcomes.

### Fields

- `ruleset_id` (Many2one -> `hr.attendance.overtime.ruleset`, required)
- `requested_by` (Many2one -> `res.users`, required)
- `date_from` (Datetime, required)
- `date_to` (Datetime, required)
- `state` (Selection): `draft`, `running`, `done`, `failed`
- `eligible_count` (Integer)
- `processed_count` (Integer)
- `skipped_count` (Integer)
- `error_message` (Text)
- `executed_at` (Datetime)

### Validation Rules

- `date_to >= date_from`
- Only users with manager-level attendance permissions can execute regeneration.
- Eligible domain must exclude protected/history-exempt attendance records.

## Relationships

- One ruleset has many overtime rules.
- One regeneration run targets one ruleset and many eligible attendance records.
- Overtime outputs are computed against attendance records in scope and do not modify out-of-scope history.
