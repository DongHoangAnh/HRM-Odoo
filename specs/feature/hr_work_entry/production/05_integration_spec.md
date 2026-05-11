# HR Work Entry Integration Spec

## Integration Goals
- Connect work-entry generation with attendance, leave, contracts, calendars, and payroll.
- Ensure contract or schedule changes propagate safely.
- Keep downstream payroll consumers working with stable data contracts.

## Integrations

### hr.employee and hr.version
- Work entries are generated from version and contract context.
- Employee actions should open work entries filtered by the employee.
- Version changes should trigger remove/recompute behavior.

### hr.attendance
- Attendance intervals can feed generated work entries.
- Attendance-based generation must preserve overtime or conflict logic where relevant.

### hr.leave and hr_holidays
- Approved leave can produce work-entry leave intervals.
- Leave timing and calendar rules must remain compatible.

### resource.calendar and resource.calendar.leaves
- Calendars and leave intervals are the backbone of generation.
- Timezone and lunch interval handling must remain stable.

### payroll / downstream consumers
- Work entries are the input contract for salary computation.
- Validated work entries should be safely consumable by payroll.

## Event Contracts
- Contract date changes should remove obsolete work entries.
- Calendar or source changes should trigger recompute of impacted entries.
- Cron generation should fill gaps without overwriting validated data.
- Generation post-processing must split and merge entries consistently.

## Cron and Batch Expectations
- Missing work entries should be generated in batches.
- Company and timezone grouping must be preserved.
- Batch generation must be safe to rerun.

## Production Readiness Checks
- Verify work entries remain aligned with versions and calendar changes.
- Verify validated entries are protected during recompute.
- Verify leave and attendance integrations produce deterministic intervals.
- Verify type and source configuration errors are surfaced before generation.
