# data-model.md - Applicant Tracking

## Entities

### Applicant (`hr.applicant`, extended)

Fields:

- `name`: string, required
- `email_from`: string, required for duplicate detection and contact
- `phone`: string, optional; normalized before storage when provided
- `mobile`: string, optional; normalized before storage when provided
- `job_id`: many2one(`hr.job`), required
- `company_id`: many2one(`res.company`), required
- `stage_id`: many2one(`hr.recruitment.stage`), required
- `recruiter_id`: many2one(`res.users` or recruiter owner model), optional
- `interviewer_ids`: many2many(`res.users` or interview participant model), optional
- `source_id`: many2one(source model), optional
- `campaign_id`: many2one(campaign model), optional
- `tag_ids`: many2many(tag model), optional
- `priority`: selection or integer ranking, optional
- `opening_date`: datetime, set on creation
- `last_stage_update`: datetime, updated on each stage transition
- `closing_date`: datetime, set when hired/refused/archived
- `duration_days`: computed integer from opening to closing date
- `refuse_reason`: text, optional
- `offer_details`: text/json, optional
- `education`: text, optional
- `availability`: text/date text, optional
- `linked_profile_url`: char, optional
- `employee_id`: many2one(`hr.employee`), optional; set after hire conversion
- `duplicate_count`: computed integer
- `attachment_count`: computed integer from `ir.attachment`

Relationships:

- One applicant can have many interviews, attachments, notes, and stage history entries.
- One applicant may link to zero or one employee record after successful conversion.

Validation Rules:

- Required identity and job fields must be present before create succeeds.
- Email duplicates should raise a user-visible warning, not a create failure.
- Phone numbers should be normalized when stored and remain readable to recruiters.
- Employee conversion is only allowed when the applicant is in the hired state.

State Transitions:

- New applicant -> initial recruitment stage with active recruiting status.
- Stage move -> update `stage_id` and `last_stage_update`.
- Hired -> set `closing_date`, preserve final stage, and create/link employee.
- Refused -> set `closing_date`, store refusal reason, and mark inactive.
- Archived -> mark inactive and preserve timeline/history.

### Interview Meeting

Likely implemented with `calendar.event` or a dedicated linked interview model.

Fields:

- `applicant_id`: many2one(`hr.applicant`), required
- `scheduled_start`: datetime, required
- `scheduled_end`: datetime, required
- `interviewer_ids`: many2many participant model, optional
- `state`: selection, optional
- `notes`: text, optional

### Attachment (`ir.attachment`)

- Linked to applicant record via standard Odoo attachment relation.
- Used for CVs, cover letters, and supporting documents.

### Employee (`hr.employee`)

- Target record created during conversion.
- Linked back to applicant through `employee_id` or an applicant reference field.

## Data Integrity Notes

- Timeline fidelity should rely on Odoo chatter plus explicit linked interview records.
- Duplicate warning metrics should count by normalized email address when available.