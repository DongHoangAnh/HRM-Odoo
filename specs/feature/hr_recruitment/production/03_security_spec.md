# HR Recruitment Security Spec

## Security Goals
- Restrict applicant and job data to the right recruiting roles.
- Control who can see applicants, attachments, activities, and interviewer-only data.
- Keep interview permissions synchronized with actual assignment.
- Avoid exposing applicant PII to unauthorized users.

## Roles
- System Administrator
- HR User
- HR Recruiter
- Hiring Manager
- Interviewer
- Public / Non-recruiting user

## Access Rules

### hr.applicant
- Recruiters and hiring managers can manage applicants in their scope.
- Interviewers can access assigned applicant information where allowed.
- Public users should not access private applicant data.

### hr.job
- Recruitment managers can edit job configuration and view metrics.
- Interviewers may see job-related applicants and tasks.
- Non-recruiting users should not edit recruiting configuration.

### hr.recruitment.stage / source / talent pool
- Configuration should be restricted to authorized recruitment users.
- Source and alias management should be protected.
- Talent pool operations should be scoped to recruiters and managers.

### hr.job.platform
- Platform email and parsing configuration must be protected.
- Only recruiters/configuration users should manage intake channels.

### res.users interviewer sync
- Interviewer group grants must be derived from actual recruitment assignment.
- Removal from all jobs and applicants should remove the interviewer role when safe.

## Field Protection Rules
- Applicant private data, interview notes, and attachments must remain scoped.
- Applicant refusal and hiring metadata must not be editable by unauthorized users.
- Job alias and source configuration must be manager-only.

## Record Rule Expectations
- Job and applicant records must respect company boundaries.
- Interviewer access must only cover assigned recruiting scope.
- Talent pools and recruitment sources must stay within their owning company context.

## Action Security
- Create employee from applicant must check appropriate recruitment permissions.
- Archive/reset/refuse/hire actions must validate access.
- Job platform create/write must be restricted to setup roles.
- Interviewer group sync should not be user-driven beyond the allowed recruitment flow.

## Audit Expectations
- Applicant stage changes, interview assignment, and hiring decisions should remain traceable.
- Recruitment data should be safe for mail and activity collaboration.
