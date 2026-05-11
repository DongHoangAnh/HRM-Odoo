# data-model.md - Job Platforms and Interviewer Sync

## Entities

### Job Platform (`hr.recruitment.platform` or equivalent)

Fields:

- `name`: string, required
- `email`: string, required
- `parsing_pattern`: char/text, optional
- `company_id`: many2one(`res.company`), required
- `job_id`: many2one(`hr.job`), optional or required by implementation
- `active`: boolean, default true
- `alias_id`: many2one(`mail.alias`), optional

Relationships:

- A job platform may be associated with one recruitment job and may drive inbound message parsing.

Validation Rules:

- Email must be normalized before storage.
- Duplicate email addresses must raise a validation error.
- Parsing pattern is stored only when provided.

### Recruitment Job (`hr.job`, extended)

Fields:

- `department_id`: many2one(`hr.department`), used for alias defaults
- `user_id`: many2one(`res.users`), used for alias defaults
- `favorite_user_ids`: many2many(`res.users`), used for favorites behavior
- `source_ids`: many2many(source model), exposed from the job form
- `activity_count`: computed integer
- `employee_count`: computed integer
- `open_application_count`: computed integer
- `hired_employee_ids`: many2many(`hr.employee`), used for related employee actions
- `interviewer_ids`: many2many(`res.users`), used for interviewer sync

Validation Rules:

- Alias defaults should refresh when department or responsible user changes.
- Job actions must return filtered activity and related employee views.

### Recruitment Interviewer Group

Representation:

- Managed via Odoo security group membership for interviewer-capable users.

Validation Rules:

- Group membership should mirror active recruiting assignments.
- A user should be removed when they are no longer referenced as an interviewer anywhere.

### Recruitment Source

Fields:

- `name`: string, required
- `job_id`: many2one(`hr.job`), optional

Validation Rules:

- Sources should remain visible from the job record.

## State Transitions

- Job platform create/update: normalize email and validate uniqueness.
- Job change: refresh alias defaults and related job actions.
- Interviewer assignment change: add/remove the user from the recruitment interviewer group.