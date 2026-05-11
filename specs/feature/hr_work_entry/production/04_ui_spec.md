# HR Work Entry UI Spec

## UI Goals
- Make generated work entries understandable to HR and payroll users.
- Make validation and regeneration actions accessible but controlled.
- Keep work-entry type configuration straightforward.

## Project Context (Context Discovery alignment)

- Default UI language: Vietnamese for HR users; make generation and regeneration actions explicit and show affected periods clearly for payroll reconciliation.
- Expose teaching-hour related generation options when applicable and ensure Finance-visible fields are present in payroll preparation views.

## Required Screens
- Work entry list, form, and conflict views.
- Work entry type list and form views.
- Employee work-entry shortcut action.
- Version work-entry generation settings.
- Regeneration wizard or action views if applicable.

## Work Entry UI Requirements
- Show employee, version, date, duration, type, state, and conflict indicators clearly.
- Support validate, cancel, split, and delete flows according to state.
- Surface generation period and source metadata where useful.

## Work Entry Type UI Requirements
- Expose code, country, work/leave flag, and validation constraints clearly.
- Prevent invalid combinations with immediate feedback.

## Version UI Requirements
- Show generation source and generated range fields.
- Warn when calendar-based generation lacks a valid calendar.
- Provide clear regeneration entry points.

## Search and Filter Requirements
- Filter by employee, date range, state, type, company, and conflict.
- Filter by generation source and version boundaries where needed.

## UX Acceptance Criteria
- HR users should be able to inspect work entries without deciphering generation internals.
- Payroll users should be able to identify validation and conflict issues quickly.
- Regeneration workflows should make it obvious what period will be affected.
- Invalid source configuration should be visible before generation is attempted.
