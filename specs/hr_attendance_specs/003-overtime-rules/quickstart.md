# Quickstart: Overtime Rules and Ruleset Configuration

## 1. Preconditions

- Odoo 19 environment is available.
- Custom module namespace follows `hrm_*` convention.
- User has HR Attendance Manager rights.

## 2. Implement module skeleton

Create module structure:

```text
addons/hrm_attendance_overtime/
  __init__.py
  __manifest__.py
  models/
  wizard/
  views/
  security/
  data/
  tests/
```

Update `__manifest__.py` with dependencies and data files:
- depends: `hr`, `hr_attendance`, `resource`
- data: security XML/CSV, views, wizard views, cron data

## 3. Add ruleset and rule models

- Implement `hr.attendance.overtime.ruleset` with:
  - company/country scope
  - active default true
  - combination mode default `max_rate`
  - computed `rule_count`
- Implement `hr.attendance.overtime.rule` with:
  - quantity and timing variants
  - constrains for required fields and hour bounds
  - manager-facing rule summary information

## 4. Add regeneration workflow

- Implement wizard/model action to regenerate overtime by date scope.
- Limit recomputation to eligible attendance domain.
- Apply active rules and configured aggregation mode.
- Store run results for audit visibility.

## 5. Add security and ACL

- Add model access entries in `security/ir.model.access.csv`.
- Restrict create/update/regeneration to manager-level roles.

## 6. Add tests mapped to acceptance scenarios

Create tests for:
- Ruleset defaults and scoping
- Quantity rule validation and expected-hours requirements
- Timing rule validation and schedule/hour boundaries
- Applicability behavior across work-day/non-work-day/leave/schedule contexts
- Regeneration correctness and scope preservation
- Aggregation behavior (`max_rate` vs `sum_rate`)

## 7. Validate in Odoo

Example flow to validate manually:

1. Create a ruleset with company/country.
2. Add one quantity rule and one timing rule.
3. Trigger regeneration for a limited date range.
4. Confirm overtime values are recomputed only for eligible records.
5. Confirm invalid configurations are blocked with clear messages.

## 8. Traceability checklist

- Every functional requirement FR-001..FR-017 has at least one test/assertion.
- Every acceptance scenario from spec is represented by either automated test or explicit QA step.
