# Feature Specification: Job Platforms and Interviewer Group Synchronization

**Feature Branch**: `003-job-platforms-interviewer-sync`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Job Platforms and Interviewer Group Synchronization. HR recruiters need to manage job platforms and interviewer permissions so that incoming applications and interviewer access stay consistent. Place the spec under hr_specs_recruitment."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maintain job platform contact details (Priority: P1)
An HR recruiter creates and updates a job platform entry so inbound recruiting messages are captured consistently and duplicate platform records are avoided.

**Why this priority**: Accurate platform contact data is required for receiving applicant messages and preventing conflicting platform records.

**Independent Test**: Create and update a job platform email, then verify the stored email is normalized and duplicate emails are rejected.

**Acceptance Scenarios**:
1. Given a recruiter creates a job platform with an email address, when the platform is saved, then the stored email is normalized.
2. Given an existing job platform, when the recruiter updates the email address, then the stored email is normalized on save.
3. Given a job platform already uses a specific email address, when the recruiter creates another platform with the same email, then the system raises a validation error.
4. Given a recruiter defines a parsing pattern for inbound messages, when the job platform is saved, then the pattern is stored for future applicant parsing.

---

### User Story 2 - Keep job aliases aligned with job ownership (Priority: P1)
An HR recruiter manages job aliases so incoming messages create the correct applicant records and the alias settings stay aligned when the job owner or department changes.

**Why this priority**: Job aliases control how incoming messages become applicants, so they must remain synchronized with the current job setup.

**Independent Test**: Create or update a job alias, then verify it creates applicant records and refreshes its defaults when the job’s ownership details change.

**Acceptance Scenarios**:
1. Given a recruitment job exists, when the alias is created, then the alias creates applicant records for the job.
2. Given a job already has an alias, when the recruiter updates the department or responsible user, then the alias defaults are rewritten to match the current job.
3. Given a job has recruitment sources, when the recruiter opens the job record, then the related source records are available from the job.
4. Given a job is marked as a favorite by a user, when the user toggles the favorite state, then the job is removed from or restored to that user’s favorites.

---

### User Story 3 - Synchronize interviewer access with job assignments (Priority: P1)
An HR recruiter assigns interviewers to jobs so the recruitment interviewer group always reflects the people currently allowed to interview candidates.

**Why this priority**: Interviewer permissions must stay in sync with active recruiting assignments to avoid access gaps or stale permissions.

**Independent Test**: Add and remove interviewer users from a job, then verify the recruiter interviewer group reflects the current assignments.

**Acceptance Scenarios**:
1. Given a recruiter creates a job with interviewer users, when the job is saved, then the users are added to the recruitment interviewer group.
2. Given a user is removed from all jobs and applicants as an interviewer, when the job is updated, then the user is removed from the recruitment interviewer group.
3. Given a recruiter manages interviewer access, when the set changes, then the group membership matches the active recruiting assignments.

---

### User Story 4 - Review job activity and hiring metrics (Priority: P2)
An HR recruiter reviews job activity and hiring metrics so the team can monitor open workload, hired outcomes, and applicant activity from the job record.

**Why this priority**: These views support day-to-day recruiting oversight but depend on the platform, alias, and interviewer setup already being correct.

**Independent Test**: Open job activities, metrics, and related employees for a job with active recruiting data, then verify the actions and counts are correct.

**Acceptance Scenarios**:
1. Given a job has running applicant activities, when the recruiter opens job activities, then the activity view opens first and filters to the job.
2. Given a job has hired and open applicants, when the recruiter views the job metrics, then hired employee counts and open application counts are shown.
3. Given a job has hired employees, when the recruiter opens related employees from the job, then the employee action is returned for the current access level.
4. Given a job has hired and open applicants, when the recruiter reviews the job summary, then the counts reflect the current hiring state.

---

### Edge Cases

- What happens when a recruiter saves a job platform email with different letter casing or surrounding whitespace?
- What happens when a recruiter tries to reuse an email address already assigned to another job platform?
- How does the system behave if a job alias exists but the department or user is changed to a value with no current alias defaults?
- What happens when interviewer assignments are removed from the last job and the same user is still referenced elsewhere?
- How are job activity and employee actions handled when a job has no current applicants or hires?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST normalize job platform email addresses when a platform is created or updated.
- **FR-002**: The system MUST prevent duplicate job platform email addresses.
- **FR-003**: The system MUST store a job platform parsing pattern for incoming mail when provided.
- **FR-004**: The system MUST create job aliases that generate applicant records for the related recruitment job.
- **FR-005**: The system MUST refresh job alias defaults when the job department or responsible user changes.
- **FR-006**: The system MUST expose job-related source records from the job form.
- **FR-007**: The system MUST allow a user to toggle a job’s favorite status.
- **FR-008**: The system MUST add job-assigned interviewers to the recruitment interviewer group when the job is saved.
- **FR-009**: The system MUST remove a user from the recruitment interviewer group when the user is no longer assigned as an interviewer anywhere.
- **FR-010**: The system MUST open the job activity view with the job filter applied when the recruiter requests job activities.
- **FR-011**: The system MUST display job hiring metrics including hired employee counts and open application counts.
- **FR-012**: The system MUST provide an action to open related employees from a job according to the current access level.
- **FR-013**: The system MUST keep interviewer group membership consistent with active job and applicant interviewer assignments.
- **FR-014**: The system MUST expose job summary counts that reflect the current hiring state.

### Key Entities

- **Job Platform**: A recruiting contact point used to receive inbound applicant messages.
- **Recruitment Job**: A job opening that holds alias, source, activity, and interviewer information.
- **Job Alias**: The communication alias tied to a job and used to create applicant records.
- **Recruitment Source**: A source record associated with a job for tracking incoming applicants.
- **Interviewer User**: A user who may be granted interviewer permissions through job assignment.
- **Recruitment Interviewer Group**: The permission group that reflects who can act as an interviewer.
- **Applicant Activity**: A tracked activity linked to a job and its applicants.
- **Hiring Metrics**: Counts and summaries that show hired employees and open applications.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of newly saved job platform emails are stored in a normalized format.
- **SC-002**: 100% of duplicate job platform email attempts are rejected with a clear validation error.
- **SC-003**: 95% of job alias updates reflect current job ownership details without manual correction.
- **SC-004**: 100% of job saves with interviewer assignments update interviewer group membership correctly.
- **SC-005**: Recruiters can open job activities and see the job-filtered view in under 1 minute for at least 90% of attempts.
- **SC-006**: 100% of reviewed job summaries show hired employee and open application counts that match the current job state.

## Assumptions

- Recruiters are authorized to manage job platforms, aliases, sources, and interviewer assignments.
- Email normalization is applied consistently for both create and update actions.
- Job aliases are used to create applicant records from inbound communication.
- Interviewer group membership is derived from active recruiting assignments.
- Job activity and hiring metrics are already available as part of the recruitment workflow.
