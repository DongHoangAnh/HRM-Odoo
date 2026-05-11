# HR Recruitment UI Spec

## UI Goals
- Make applicant progression obvious.
- Make job metrics and recruiter actions visible.
- Keep interviews, attachments, and hiring decisions easy to manage.

## Required Screens
- Applicant kanban, list, and form views.
- Job list, kanban, and form views.
- Recruitment stage and source configuration views.
- Talent pool views.
- Job platform configuration views.
- Interview and activity views.

## Applicant UI Requirements
- Show stage, status, priority, delay, and hiring state clearly.
- Expose approve, refuse, archive, reset, hire, and employee creation actions where allowed.
- Show interviewers, meetings, attachments, and source information.
- Keep contact fields easy to inspect but not overexposed.

## Job UI Requirements
- Show counts for applications, hires, open applications, new applications, old applications, documents, and activities.
- Provide shortcuts for attachments, activities, and related employees.
- Show favorite state and interviewer assignment clearly.

## Configuration UI Requirements
- Stage forms must make warning visibility and job association understandable.
- Source and platform forms must make alias/email behavior explicit.
- Talent pools must show linked counts and quick add actions.

## Search and Filter Requirements
- Filter by job, stage, status, hired state, interviewer, source, and company.
- Search by application lifecycle timing where useful.
- Search for jobs by recruiter, interviewer, and favorites.

## UX Acceptance Criteria
- Recruiters should be able to move an applicant through the pipeline without leaving the record.
- Job metrics should be visible in list/kanban summaries.
- Creation of aliases and interviewers should feel like configuration, not hidden automation.
- Handoff to employee creation should be a direct and understandable action.
