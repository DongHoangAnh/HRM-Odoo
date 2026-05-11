# HR Work Entry Business Spec

## Goal
Build production work-entry functionality that generates, validates, and maintains work entries for payroll from contracts, attendance, and leave data.

## Project Context (Context Discovery alignment)

- Scope limited to Employee, Attendance, Leave, Payroll, Recruitment.
- Work entries are a primary input to payroll; ensure generation supports teaching-hours and contract-version contexts and does not overwrite validated payroll data.
- Implement work-entry customizations in `hrm_work_entry` modules and avoid Odoo core changes.

## Primary Users
- HR Manager
- Payroll Manager
- Accountant
- Employee
- System Administrator

## Core Business Capabilities

### Work-entry lifecycle
- Generate work entries from contract versions.
- Validate, cancel, split, and delete work entries according to state.
- Detect conflicts and preserve validated records.
- Track the generation period for each version.

### Work entry source behavior
- Support calendar-based generation as the main source.
- Preserve source configuration across template and version flows.
- Recompute work entries when relevant contract data changes.

### Work entry types
- Maintain work entry types and their codes.
- Distinguish work and leave work-entry types.
- Apply country-specific and scheduling constraints where needed.

### Generation and recompute
- Generate missing work entries via batch and cron.
- Recompute entries when calendars or source settings change.
- Remove obsolete entries when contract boundaries change.

## Production Outcomes
- Payroll receives reliable work-entry data.
- Attendance and leave data can flow into work-entry generation.
- Contract or schedule changes can be propagated safely.
- Conflicts are visible and handled instead of silently ignored.

## Acceptance Criteria
- Work entries must reflect the contract period and generated boundaries.
- Validated work entries must be protected from accidental removal.
- Work entry type and source configuration must remain consistent.
- Generation and recompute flows must be deterministic.
- Missing entries should be fillable by cron or manual batch generation.
