# Feature Specification: Recruitment Operations, Jobs, and Talent Pools

**Feature Branch**: `002-recruitment-operations`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Recruitment Operations, Jobs, and Talent Pools. HR recruiters need to manage jobs, sources, stages, and talent pools so that recruitment can be tracked beyond the applicant record. Place the spec under hr_specs_recruitment."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure job recruitment defaults (Priority: P1)
An HR recruiter creates or reviews a recruitment job and expects the job to start with the correct address, favorites, counters, and related actions so the job record is ready for daily recruiting work.

**Why this priority**: Job setup is the operational anchor for the rest of the recruitment process, including sourcing, applicants, and reporting.

**Independent Test**: Create a recruitment job and verify the default address, favorite users, counters, and linked action views are prepared correctly.

**Acceptance Scenarios**:
1. Given a company exists, when a recruiter creates a recruitment job, then the job address defaults to the company address.
2. Given a recruiter opens the job address selector, when available addresses are shown, then only allowed company addresses are available.
3. Given a recruiter creates a recruitment job, when the record is saved, then favorite users are prefilled for the current user and recruiting managers.
4. Given a job has hired and open applicants, when the recruiter reviews job counters, then employee, application, and open application counts are available.
5. Given a job has documents or activities, when the recruiter opens the related actions, then the attachments and activities views show the job-related records.
6. Given a job has a recruitment scenario, when the recruiter loads it, then the recruiting pipeline is populated with the configured stages.
7. Given a job has hired employees, when the recruiter opens employees from the job, then the hired employee list is shown.

---

### User Story 2 - Manage recruitment stages and sources (Priority: P1)
An HR recruiter creates and maintains recruitment stages and sourcing records so the pipeline stays structured and sourcing links remain reliable.

**Why this priority**: Stages and sources define how candidates move through the funnel and how recruiting activity is attributed.

**Independent Test**: Create a stage and a source, check the stage defaults and warning visibility, generate a source alias, and confirm referenced sources cannot be removed freely.

**Acceptance Scenarios**:
1. Given a recruiter creates a recruitment stage, when default values are prepared, then the stage is created with the expected starter configuration.
2. Given a recruitment stage has warning visibility enabled, when the recruiter checks the stage, then the warning is visible.
3. Given a recruiter creates a recruitment source named Website, when the source alias is created, then a mail alias is created for that source.
4. Given a recruitment source is created without an alias, when the recruiter uses the alias helper, then the source and alias are returned together.
5. Given a recruitment source is already linked to jobs or applicants, when the recruiter tries to delete it, then the system prevents unlinking while references still exist.

---

### User Story 3 - Organize talent pools and interviewer access (Priority: P2)
An HR recruiter groups applicants into talent pools and manages recruiter interview access so future hiring and interview coordination stay organized.

**Why this priority**: Talent pools and interviewer access improve reuse and coordination, but they are secondary to the core job and source setup.

**Independent Test**: Create a talent pool, add applicants, verify the talent count, and enable or remove recruiter interviewer access for a user.

**Acceptance Scenarios**:
1. Given a talent pool contains linked talents, when the recruiter reviews it, then the talent count reflects the number of linked people.
2. Given a recruiter has a set of applicants to store, when applicants are added to the talent pool, then the pool contains those applicants.
3. Given a recruiter user is connected to the recruitment module, when interview access is enabled for that user, then the user is included in the interviewer set.
4. Given interviewer access is no longer needed, when recruitment interviewers are removed, then the user is removed from the interviewer set.
5. Given an applicant has an interview event, when the calendar event is created, then it is highlighted as recruitment-related.

---

### User Story 4 - Review operational reporting and summaries (Priority: P2)
An HR recruiter reviews job-level reporting so the team can understand application volume, open workload, and hiring progress across recruitment operations.

**Why this priority**: Reporting supports decision-making and capacity planning, but it depends on the operational structures defined above.

**Independent Test**: Review a job with active recruiting data and verify the counters and source-linked summaries are available for operational analysis.

**Acceptance Scenarios**:
1. Given a job with recent and older applicants, when the recruiter reviews analytics, then new and old application counts are available.
2. Given a job with hired and open applicants, when the recruiter reviews the job, then the relevant totals are updated for operational use.
3. Given recruitment sources are in use, when the recruiter reviews operational summaries, then source-linked recruiting activity can be compared across records.

---

### Edge Cases

- What happens when a recruiter opens job actions but there are no attachments, activities, or hired employees yet?
- How does the system behave when a recruitment source is still referenced by jobs or applicants and a user attempts to remove it?
- What happens if a recruiter adds applicants to a talent pool more than once?
- How are interviewer access changes handled when the user is no longer active in recruiting?
- What happens if a recruiter loads a recruitment scenario that does not contain any stages?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow a recruiter to create a recruitment job with a default address derived from the company.
- **FR-002**: The system MUST restrict the job address selector to allowed company addresses.
- **FR-003**: The system MUST prefill favorite users for recruitment jobs with the current user and recruiting managers.
- **FR-004**: The system MUST compute and expose employee, application, and open application counters for recruitment jobs.
- **FR-005**: The system MUST compute and expose new and old application counts for recruitment jobs.
- **FR-006**: The system MUST provide job actions that open the related attachments and activities views for the job.
- **FR-007**: The system MUST allow a recruiter to load a recruitment scenario into a job pipeline.
- **FR-008**: The system MUST allow a recruiter to open the list of hired employees from a job.
- **FR-009**: The system MUST prepare expected default values when a recruitment stage is created.
- **FR-010**: The system MUST show or hide recruitment stage warnings based on the stage configuration.
- **FR-011**: The system MUST allow a recruitment source to create and return a mail alias.
- **FR-012**: The system MUST support creating a recruitment source together with its alias through a helper action.
- **FR-013**: The system MUST prevent removal of recruitment sources that are still referenced by jobs or applicants.
- **FR-014**: The system MUST allow a recruiter to create and maintain talent pools with linked applicants.
- **FR-015**: The system MUST compute the number of talents linked to each talent pool.
- **FR-016**: The system MUST allow recruiter interview access to be enabled and removed for a user.
- **FR-017**: The system MUST highlight recruitment-related interview events in the calendar context.
- **FR-018**: The system MUST expose operational recruitment counts and summaries for job-level review.

### Key Entities

- **Recruitment Job**: A job opening used to track recruiting activity, applicants, counts, actions, and pipeline setup.
- **Recruitment Stage**: A structured step in the hiring pipeline with default settings and warning behavior.
- **Recruitment Source**: A source of applicants or recruiting activity, often linked to an alias and used for attribution.
- **Talent Pool**: A collection of applicants or talents maintained for future hiring opportunities.
- **Applicant**: A candidate that can be attached to a job, a source, or a talent pool.
- **Employee**: A hired person linked back to the recruitment job.
- **Interviewer Access**: A recruiter user permission state that determines whether the user can act as an interviewer.
- **Recruitment Scenario**: A predefined pipeline template used to populate job stages.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Recruiters can create a recruitment job with the correct default address and favorites on the first attempt in at least 95% of cases.
- **SC-002**: 100% of jobs with applicants display the expected applicant and employee counters.
- **SC-003**: 100% of recruitment sources linked to jobs or applicants are protected from accidental removal.
- **SC-004**: Recruiters can add applicants to a talent pool and see the updated pool size in under 1 minute for at least 90% of attempts.
- **SC-005**: 95% of recruiter interview access changes are reflected without requiring a follow-up correction.
- **SC-006**: 90% of operational job reviews expose the needed counts, actions, and summaries without manual reconciliation.

## Assumptions

- Recruiters have permission to manage jobs, stages, sources, and talent pools.
- The company address and allowed address rules are already defined by the organization.
- Recruitment scenarios and stage defaults exist as reusable business configurations.
- Source aliases are used for recruiting attribution and communication routing.
- Talent pools may contain applicants that are also used elsewhere in the recruiting process.
- Interviewer access is managed separately from applicant ownership.
