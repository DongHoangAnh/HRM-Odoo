# Applicant Lifecycle Contract

## Create Applicant

- Input: applicant name, email, job, company, and optional contact/profile details.
- Output: applicant record created in the first recruitment stage with active status and opening timestamp.
- Warning behavior: if the email matches an existing applicant, show a duplicate warning but do not block save.

## Update Applicant

- Stage moves must update the current stage and last-stage timestamp.
- Notes, interviews, and stage changes must remain visible in the applicant activity timeline.
- Optional fields such as education, availability, source, tags, and attachments must be preserved when present.

## Hire Applicant

- Input: applicant already in hired state.
- Output: employee record created and linked back to the applicant.
- Data copy: preserve core identity and contact data during conversion.

## Refuse or Archive Applicant

- Refusal must record reason and closing date.
- Archive must mark the applicant inactive while keeping the history intact.

## Invariants

- Employee conversion is only valid from the hired state.
- Duplicate-email detection is advisory, not blocking.
- Timeline and audit history must be preserved for the full applicant lifecycle.