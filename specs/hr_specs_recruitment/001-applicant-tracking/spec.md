# Feature Specification: Recruitment Process and Applicant Tracking

**Feature Branch**: `001-applicant-tracking`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Recruitment Process and Applicant Tracking. Recruiters need to manage applicants, move them through recruitment stages, coordinate interviews, track sources and attachments, and convert hired applicants into employees. Place the spec under hr_specs_recruitment."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create and capture applicant information (Priority: P1)
A recruiter creates a new applicant from a job application and records the candidate's core contact and job information so the hiring pipeline can begin with complete data.

**Why this priority**: This is the entry point for the entire recruitment flow; without applicant creation, the rest of the process cannot start.

**Independent Test**: Create an applicant with a candidate name, email, job position, and company, then verify the applicant is created with the expected initial status, stage, and active state.

**Acceptance Scenarios**:
1. Given a recruiter is signed in and the target job position and company exist, when they create an applicant with candidate name, email, job position, and company, then the applicant is created in the first recruitment stage with an active recruiting status.
2. Given an applicant is created, when the recruiter reviews the record, then the creation date, opening date, and default board state are present.
3. Given a recruiter enters phone number, linked profile, education, and availability details, when the applicant is saved, then the information is retained and the phone number is normalized.

---

### User Story 2 - Move applicants through hiring decisions (Priority: P1)
A recruiter updates an applicant's stage and outcome as the candidate progresses, is refused, archived, or accepted for hire so the pipeline always reflects the current hiring decision.

**Why this priority**: Stage movement and hiring outcomes are the core value of applicant tracking and drive day-to-day recruitment work.

**Independent Test**: Move an applicant from one stage to another, record a refusal or hire, and verify the stage, dates, and outcome fields reflect the latest decision.

**Acceptance Scenarios**:
1. Given an applicant is in an earlier recruitment stage, when the recruiter moves the applicant forward, then the new stage and last stage update time are recorded.
2. Given an applicant advances to an offer stage, when offer details are entered, then the offer information is retained with the application.
3. Given an applicant is accepted for hire, when the recruiter marks the applicant as hired, then the application is closed with the hire date and closure timing recorded.
4. Given an applicant is refused, when the recruiter records a refusal reason, then the applicant is marked refused and the refusal reason and date are stored.
5. Given a refused applicant needs to be removed from active processing, when the recruiter archives the applicant, then the applicant is no longer active and the archived state is reflected.

---

### User Story 3 - Coordinate recruiters and interviews (Priority: P1)
A recruiting team assigns owners, interviewers, and interview meetings to an applicant so everyone involved can see who is responsible and what happens next.

**Why this priority**: Interviews and ownership are central to collaboration and help the hiring team keep candidates moving.

**Independent Test**: Assign a recruiter, add interviewers, and create interview meetings for an applicant, then verify the assignments, notifications, and timeline entries are visible.

**Acceptance Scenarios**:
1. Given an applicant is under review, when a recruiter is assigned to the applicant, then the recruiter ownership is saved and the recruiter is notified.
2. Given interviewers are added to an applicant, when the record is saved, then all interviewers are associated with the applicant and receive interview-related notifications.
3. Given an interview meeting is created for an applicant, when it is linked to the record, then the meeting appears in the applicant's timeline.
4. Given an applicant has more than one interview, when a new interview is added, then the applicant keeps the full interview history and the latest interview information is shown first.
5. Given notes, interviews, and stage changes are added over time, when the recruiter views the applicant, then the activity timeline shows the full interaction history.

---

### User Story 4 - Organize and analyze the applicant pool (Priority: P2)
A recruiter classifies applicants with tags, priorities, sources, duplicate warnings, and attachments so the team can search, compare, and report on the candidate pipeline.

**Why this priority**: These tools improve efficiency and visibility across a larger applicant pool, but they are secondary to creating and progressing applicants.

**Independent Test**: Add tags, priority, source information, and attachments to applicants, then verify the records can be filtered, sorted, and summarized correctly.

**Acceptance Scenarios**:
1. Given an applicant needs categorization, when tags are added, then the applicant can be grouped and filtered by those tags.
2. Given an applicant needs prioritization, when a priority is assigned, then the applicant can be sorted according to that priority.
3. Given two applicants share the same email address, when the second applicant is created, then the system shows a duplicate warning and the duplicate count reflects both records.
4. Given an applicant comes from a sourcing campaign, when source information is captured, then the applicant can be reported by source.
5. Given CV and cover letter files are uploaded, when the recruiter reviews the applicant, then the attachments are available and the attachment count is correct.

---

### User Story 5 - Convert hired applicants into employees (Priority: P1)
A recruiter turns a successfully hired applicant into an employee record so the person can move from recruiting into workforce management without re-entering core data.

**Why this priority**: Hiring is the end of the recruitment journey and must hand off cleanly to employee management.

**Independent Test**: Convert a hired applicant into an employee and verify the employee record is created and linked back to the applicant.

**Acceptance Scenarios**:
1. Given an applicant has reached the hired stage, when the recruiter creates an employee from the applicant, then a new employee record is created and linked to the applicant.
2. Given an applicant is linked to a newly created employee, when the recruiter reviews the applicant, then the employee linkage is visible.
3. Given the new employee record is created, when the recruiter reviews the employee details, then the employee inherits the expected core identity information from the applicant.

---

### Edge Cases

- What happens when a recruiter tries to create a duplicate applicant using the same email as an existing candidate?
- How does the system handle moving an applicant out of order when a later stage has already been completed?
- What happens when interviewers or interview meetings are added before a recruiter is assigned?
- How are applicants handled if source information, attachments, or optional profile fields are missing?
- What happens if a recruiter attempts to convert an applicant who has not reached the hired stage?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow a recruiter to create an applicant with core candidate identity, job position, and company information.
- **FR-002**: When an applicant is created, the system MUST place the applicant in the initial recruitment stage with an active recruiting status.
- **FR-003**: The system MUST store applicant contact and profile details, including phone, linked profile, education, and availability information when provided.
- **FR-004**: The system MUST normalize stored phone numbers into a consistent readable format.
- **FR-005**: The system MUST allow a recruiter to move an applicant between recruitment stages and preserve the latest stage update time.
- **FR-006**: The system MUST record opening and closing dates, along with duration information, for applicant progress through the recruitment process.
- **FR-007**: The system MUST allow a recruiter to record offer details for applicants in the offer stage.
- **FR-008**: The system MUST allow a recruiter to mark an applicant as hired, refused, or archived and store the corresponding outcome details.
- **FR-009**: The system MUST allow assignment of a recruiter owner to an applicant and notify the assigned recruiter.
- **FR-010**: The system MUST allow multiple interviewers to be associated with an applicant and make interview-related notifications available to them.
- **FR-011**: The system MUST allow interview meetings to be linked to an applicant and shown in the applicant's activity timeline.
- **FR-012**: The system MUST preserve the full interaction history for an applicant, including notes, interviews, and stage changes.
- **FR-013**: The system MUST allow applicants to be classified with tags and priority values for filtering and sorting.
- **FR-014**: The system MUST warn recruiters when creating a new applicant that appears to duplicate an existing applicant based on email address.
- **FR-015**: The system MUST capture applicant source and campaign attribution so recruitment reporting can group applicants by source.
- **FR-016**: The system MUST support file attachments for applicant records and display the number of attached documents.
- **FR-017**: The system MUST allow a hired applicant to be converted into an employee record and preserve the linkage between the two records.
- **FR-018**: The system MUST support reporting on applicant sources and counts across the recruitment funnel.

### Key Entities

- **Applicant**: A person being considered for a job, with identity, contact, status, stage, priority, source, tags, activity history, and attachment information.
- **Recruitment Stage**: A named step in the hiring process such as New, Screening, Interview, Offer, or Hired.
- **Recruiter**: The team member responsible for owning and progressing an applicant.
- **Interviewer**: A participant who reviews an applicant during interviews.
- **Interview Meeting**: A scheduled interview event linked to an applicant.
- **Attachment**: A file associated with an applicant such as a CV or cover letter.
- **Source Attribution**: The origin of an applicant, such as a campaign, referral, or job platform.
- **Employee**: The workforce record created after a successful hire.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Recruiters can create a complete applicant record and place it into the pipeline in under 3 minutes for at least 90% of attempts.
- **SC-002**: 100% of successfully created applicants appear in the initial stage with an active recruiting status.
- **SC-003**: 95% of stage changes show the updated stage and timing information immediately to recruiters.
- **SC-004**: 100% of duplicate-email applicant attempts trigger a visible warning.
- **SC-005**: 90% of hired applicants can be converted into employee records without re-entering core identity data.
- **SC-006**: 95% of applicants with notes, interviews, or stage changes display a complete activity timeline.
- **SC-007**: Recruitment reporting can show applicant counts by source for every source captured in the system.

## Assumptions

- Recruiters are authorized to create, update, and convert applicants.
- The initial recruitment stage is a shared business rule and is already defined for the hiring pipeline.
- Duplicate detection uses applicant email as the primary signal and may show a warning even if the record is still saved.
- An applicant may have multiple interviews, interviewers, and attachments.
- Source attribution includes common recruiting channels such as job boards, referrals, and campaigns.
- Converting a hired applicant to an employee reuses the applicant's core identity and contact details.
