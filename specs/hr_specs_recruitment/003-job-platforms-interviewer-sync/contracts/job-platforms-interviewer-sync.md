# Job Platforms and Interviewer Sync Contract

## Job Platform Management

- Creating or updating a platform must normalize the stored email value.
- Duplicate platform emails must be rejected with a validation error.
- Parsing pattern values should be preserved when supplied.

## Alias and Job Synchronization

- Job aliases must refresh defaults when department or responsible user changes.
- Job records must expose related recruitment source records.
- Job actions must return activity and related employee views filtered to the current job.

## Interviewer Group Synchronization

- Interviewer assignments on a job must add the user to the recruitment interviewer group.
- Removing the last interviewer reference for a user must remove that user from the interviewer group.
- Group membership must stay aligned with active recruiting assignments.

## Invariants

- Email normalization is required on create and update.
- Alias defaults should follow the job ownership fields.
- Interviewer group state should never drift from active assignments.