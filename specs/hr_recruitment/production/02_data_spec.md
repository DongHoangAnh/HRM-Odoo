# HR Recruitment Data Spec

## Aggregate Model Map

### Core entities
- hr.applicant
- hr.job
- hr.recruitment.stage
- hr.recruitment.source
- hr.applicant.category
- hr.applicant.refuse.reason
- hr.talent.pool
- hr.job.platform

## Project Context (Context Discovery alignment)

- Recruitment must support clean handoff to `hr.employee` and preserve job/department/contract context for downstream payroll and onboarding.
- Ensure recruitment modules follow `hrm_*` naming and respect Vietnamese data handling rules for applicant PII.

### Related entities
- hr.employee
- hr.department
- res.users
- res.partner
- ir.attachment
- calendar.event
- mail.activity
- utm.source
- utm.campaign

## Key Relationships

- hr.applicant belongs to one job and one company.
- hr.applicant can link to interviewers, attachments, meetings, and an eventual employee.
- hr.job belongs to one department and may have recruiters, interviewers, and sources.
- hr.recruitment.stage controls applicant flow and hired-stage meaning.
- hr.recruitment.source links to UTM and mail alias behaviors.
- hr.talent.pool groups talent records and pool metrics.
- hr.job.platform normalizes intake email addresses.

## Data Contracts

### Applicant data
- partner_name, email_from, partner_phone, and related contact fields must be normalized.
- stage_id and application_status must remain consistent.
- date_open, date_closed, day_open, and day_close must reflect lifecycle timing.
- categ_ids, interviewer_ids, meeting_ids, attachment_ids, source_id, medium_id, and job_id must stay synced.

### Job data
- address_id must satisfy job address domain rules.
- favorite_user_ids must stay consistent with the current user selection.
- interviewer_ids and extended_interviewer_ids must remain coherent.
- application_count, open_application_count, new_application_count, old_application_count, and applicant_hired are derived metrics.

### Source and platform data
- recruitment source and job platform emails must be normalized.
- source aliases must create hr.applicant records safely.
- linked sources and campaigns must not be deleted while in use.

### Talent pool data
- pool membership and counts must reflect linked applicants.
- pool-related actions must preserve the correct applicant subset.

## Constraints

- Job platform email must be unique.
- Applicant parsing and alias creation must remain safe.
- Stage / application status / hired-state consistency must be preserved.
- Interviewer permission groups must follow assignment.
- Linked sources and campaigns must not be unlinked when still referenced.

## Derived Fields

- job application counters
- job employee counts
- job document counts
- applicant application status
- applicant counts and delay metrics
- stage warning visibility
- talent pool counts
- extended interviewer ids

## Persistence Expectations

- Changes to job or applicant data must update analytics consistently.
- Permission changes on interviewers must be synchronized to groups.
- Employee creation from applicants must keep the link to the source applicant.
