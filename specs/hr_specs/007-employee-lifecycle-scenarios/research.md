# Research: Employee Lifecycle and Scenario Management

## Decision: Onboarding guidance
Use a lightweight onboarding notification flow tied to employee creation, with a link or action that opens the onboarding setup wizard.

## Rationale
- Keeps the user-facing flow immediate after employee creation.
- Allows the onboarding setup to remain separate and reusable.
- Matches the spec's need for a congratulatory message and direct setup access.

## Alternatives considered
- Inline onboarding form sections: rejected because they mix creation and setup concerns.
- Background-only notification: rejected because the spec asks for visible guidance at creation time.

## Open questions
- Confirm whether the demo scenario loader should be exposed as a server action, wizard, or install hook.
- Confirm whether avatar generation and change tracking should be implemented together or split by addon boundary.
- Confirm what exact duplicate detection key should be used for demo data loading.
