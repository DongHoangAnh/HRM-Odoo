# HR Recruitment Integration Spec

## Integration Goals
- Connect recruitment with employee creation, calendar, mail alias, attachments, and analytics.
- Ensure job and applicant activity remains synchronized with other Odoo apps.

## Integrations

### hr.employee
- Applicants can be turned into employees.
- Hiring should preserve key onboarding data.
- Hired counts should reflect employee creation outcomes.

### hr.department and hr.job
- Jobs can inherit department context and manager context.
- Department manager changes should reflect in recruitment actions where appropriate.

### calendar.event and mail.activity
- Interview meetings and applicant activities must be linked.
- Job and applicant activity views should reflect actual scheduled work.

### ir.attachment
- Applicant and job attachments should be visible from the right records.
- Document views should be scoped to recruiter access.

### mail.alias / email intake
- Job platform email aliases and applicant intake aliases must create applicants safely.
- Alias defaults must point to the correct job and department context.

### UTM / marketing sources
- Sources and campaigns should remain compatible with acquisition tracking.

### res.users
- Interviewer group sync must follow actual job and applicant assignment.
- Recruitment-specific user permissions must be reversible when no longer needed.

## Event Contracts
- Applicant creation from mail or web intake must populate the correct job and source context.
- Interviewer assignment must update user group membership when required.
- Job alias configuration changes must update the alias defaults.
- Hiring a candidate must keep applicant and employee links consistent.
- Archiving or resetting applicants must preserve auditability and not break job metrics.

## Cron and Batch Expectations
- Recruitment analytics should remain stable as applicants move across stages.
- Talent pool and job counts should recompute safely in batch.
- Email intake and alias processing should be deterministic.

## Production Readiness Checks
- Verify applicant-to-employee flow works end to end.
- Verify job platform email normalization and uniqueness.
- Verify interviewer sync adds and removes access only when safe.
- Verify attachments and activities remain visible to the correct recruiting roles.
