# Research: Notify Expiring Contracts and Work Permits

## Decision: Cron strategy
Use a daily cron that scans employee records per company and creates `mail.activity` records only when the current date falls within the configured notice window.

## Rationale
- Matches the spec's scheduled, company-specific behavior.
- Keeps the logic centralized and predictable.
- Allows duplicate prevention by checking existing activities before create.

## Alternatives considered
- Triggering from write/create on expiration fields: rejected because it would miss date-based transitions without a scheduler.
- Using reminders on `mail.thread` only: rejected because the feature needs company-specific windows and two independent notification streams.

## Open questions
- Confirm whether the implementation should rely on calendar days only or include working-day calendars.
- Confirm fallback behavior when company notice periods are unset or zero.
- Confirm whether deleted/archived employees should be excluded from scans by default.
