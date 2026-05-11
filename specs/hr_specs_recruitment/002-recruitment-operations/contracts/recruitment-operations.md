# Recruitment Operations Contract

## Job Defaults

- Creating a recruitment job must assign the company address, favorite users, and operational counters.
- Allowed addresses must be constrained to the company address set.

## Stage and Source Management

- Stage creation must use the starter recruitment configuration.
- Stage warning visibility must reflect the stage configuration.
- Source creation must support alias creation and helper-based source-plus-alias setup.
- Source deletion must be blocked while jobs or applicants still reference the source.

## Talent Pools and Interviewer Access

- Talent pools must support applicant membership and a computed talent count.
- Interviewer access changes must be reversible and visible in the recruitment context.

## Operational Reporting

- Job-level summaries must expose applicant, employee, open applicant, new applicant, and old applicant counts.
- Recruitment-related calendar events must remain visible in the operational workflow.

## Invariants

- Counters must be derived from linked recruitment records.
- Source attribution must not be lost during deletes.
- Talent pool membership should remain consistent across repeated add/remove operations.