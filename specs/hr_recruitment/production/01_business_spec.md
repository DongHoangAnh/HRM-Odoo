# HR Recruitment Business Spec

## Goal
Build production recruitment functionality that manages jobs, applicants, stages, sources, talent pools, interviewers, and employee handoff in a way that matches Odoo-style hiring workflows.

## Project Context (Context Discovery alignment)

- Scope limited to Employee, Attendance, Leave, Payroll, Recruitment.
- Applicant-to-employee handoff must preserve recruitment context and create `hr.employee` records (teachers/TAs remain `hr.employee`).
- Do not modify Odoo core; implement recruitment customizations in `hrm_recruitment` modules and ensure company-scoped behavior.

## Primary Users
- Recruiter
- Hiring Manager
- Interviewer
- HR User
- HR Manager
- System Administrator

## Core Business Capabilities

### Applicant lifecycle
- Capture applicants from job applications and email aliases.
- Track stage progression, interview flow, and hiring outcomes.
- Support refusal, archive, reset, and employee creation.
- Keep applicant attachments and activity history available.

### Job management
- Configure jobs with address, interviewers, favorite users, and recruiter assignments.
- Track application counts, hired counts, and activity counts.
- Support job-specific applicant pipelines and stages.

### Sources and talent pools
- Track applicant sources and aliases.
- Manage recruitment sources and talent pools.
- Keep source and talent analytics usable for reporting.

### Interview management
- Add interviewers and synchronize interviewer permissions.
- Schedule interview meetings from applicant and job flows.
- Keep job activity views tied to applicant activity.

### Hiring handoff
- Convert hired applicants to employees.
- Preserve recruiting context during the transition.
- Link applicant and employee records for continuity.

## Production Outcomes
- Recruiters can manage end-to-end hiring without leaving the module.
- Hiring managers can see the right applicants and job analytics.
- Interviewers gain permissions only when they are assigned.
- Applicant-to-employee conversion is traceable and safe.

## Acceptance Criteria
- Applicant status and stage must reflect hiring decisions.
- Job metrics must update from applicant and employee activity.
- Recruitment sources and job platforms must support unique, reliable email-based intake.
- Talent pool operations must not leak applicants outside the pool.
- Interviewer permissions must be synchronized with actual assignment.
- Employee creation from applicant must preserve the recruitment context.
