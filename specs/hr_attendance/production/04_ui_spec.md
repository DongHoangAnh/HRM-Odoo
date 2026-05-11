# HR Attendance UI Spec

## Project Context (Context Discovery alignment)

- Default UI language: Vietnamese for HR users; labels for teaching-hours and pay-type must be clear.
- Provide a controlled input or import path for `teaching_hours` coming from Operations scheduling systems.
- Payroll-facing fields (validated overtime, teaching_hours) must be visible to HR/Finance roles in payroll preparation views.

## UI Goals
- Make check-in/out quick and unambiguous.
- Make overtime state and approval visible.
- Make overtime rules easy to configure without exposing technical complexity.

## Required Screens
- Employee attendance list and kanban.
- Kiosk, systray, and manual attendance entry flows.
- Overtime line form and list.
- Overtime rules list and form.
- Overtime ruleset list and form.
- Company attendance settings in configuration.

## Attendance UI Requirements
- Display worked hours and overtime summary on the record.
- Show check-in, check-out, device, GPS, and IP metadata where available.
- Expose color or state hints for anomalous records.
- Support record opening from employee context.

## Overtime UI Requirements
- Show overtime line status clearly.
- Provide approve and refuse actions.
- Show manual duration and computed duration side by side where useful.
- Show the manager flag only as contextual UI, not as a security shortcut.

## Rules UI Requirements
- Ruleset form must show company, country, and combination mode.
- Rules form must make quantity/timing base-off choices obvious.
- Validation errors should be understandable in the form flow.
- Regenerate action should be visible only to authorized users.

## Search and Filter Requirements
- Filter by employee, date, overtime state, and company.
- Filter rules by ruleset, company, and timing/quantity behavior.
- Allow searching attendance by status and overtime presence.

## Empty States
- No attendance: invite the employee to check in or HR to create a record.
- No overtime rules: guide the manager to configure a ruleset.
- No overtime lines: show that overtime is generated from attendance or manual entry.

## UX Acceptance Criteria
- Attendance check-in must be reachable in one action.
- Overtime approval must be reachable without navigating away from the record.
- Rule configuration should surface validation before save whenever possible.
- Users should be able to understand why overtime is approved, refused, or awaiting review.
