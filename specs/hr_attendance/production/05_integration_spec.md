# HR Attendance Integration Spec

## Integration Goals
- Connect attendance with employee presence, overtime, leave, work entry, and payroll flows.
- Ensure configuration changes can safely trigger recomputation.
- Keep attendance aggregates consistent across related modules.

## Integrations

### hr.employee
- Attendance requires employee context.
- Presence and last activity should reflect attendance usage.
- Overtime status should be visible on employee-linked records.

### hr.version / contract data
- Overtime and attendance can depend on the employee's contract schedule.
- Rules may use expected hours from contract.
- Regeneration must respect the current contract/version range.

### hr.leave and hr_holidays
- Leave status may affect timing-based overtime rules.
- Approved leave can change whether an interval is overtime or not.
- Work/leave balance scenarios must remain consistent.

### hr_work_entry / payroll
- Attendance feeds work entry generation.
- Approved overtime may affect payroll calculations or compensation.
- Overtime rulesets should remain compatible with downstream salary logic.

### res.company and res.config.settings
- Company-wide overtime validation mode must be configurable.
- Settings changes should be reflected in new overtime line defaults.

### mail / activities
- Overtime approvals and refusals can generate notifications or activity updates.

## Event Contracts
- Attendance creation should recompute overtime aggregates.
- Overtime line write should recompute linked attendance fields.
- Ruleset regeneration should trigger work entry or overtime recalculation as needed.
- Policy configuration changes must not corrupt existing validated overtime.

## Cron and Batch Expectations
- Overtime regeneration must handle batches of attendances.
- Calculation should remain deterministic across timezone boundaries.
- Batch recompute should be safe under multi-company scope.

## Production Readiness Checks
- Confirm overtime approval states update attendance summaries.
- Confirm ruleset regeneration leaves validated records safe.
- Confirm attendance and overtime computations respect timezone and schedule boundaries.
- Confirm integration points with downstream payroll and work-entry flows stay consistent.
