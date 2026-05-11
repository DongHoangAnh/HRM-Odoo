# data-model.md - Recruitment Operations

## Entities

### Recruitment Job (`hr.job`, extended)

Fields:

- `name`: string, required
- `company_id`: many2one(`res.company`), required
- `address_id`: many2one(`res.partner`), defaults from company address
- `favorite_user_ids`: many2many(`res.users`), defaults current user and recruiting managers
- `scenario_id`: many2one(recruitment scenario model), optional
- `employee_count`: computed integer
- `application_count`: computed integer
- `open_application_count`: computed integer
- `new_application_count`: computed integer
- `old_application_count`: computed integer
- `attachment_count`: computed integer
- `activity_count`: computed integer
- `hired_employee_ids`: many2many(`hr.employee`), computed/related for navigation

Relationships:

- One job can have many applicants, stages, sources, activities, and hired employees.

Validation Rules:

- Job address must come from allowed company addresses.
- Job counters should update from linked recruitment records rather than manual entry.

### Recruitment Stage (`hr.recruitment.stage`, extended)

Fields:

- `name`: string, required
- `sequence`: integer
- `warning_visible`: boolean or equivalent starter configuration
- `fold`: boolean, optional for pipeline display
- `scenario_default`: boolean or template linkage, optional

Validation Rules:

- Default stage configuration should be created with starter values appropriate for recruitment workflows.

### Recruitment Source (`hr.recruitment.source`, extended)

Fields:

- `name`: string, required
- `alias_id`: many2one(`mail.alias`), optional/required by source behavior
- `job_ids`: many2many(`hr.job`), optional
- `applicant_ids`: many2many(applicant model), optional

Validation Rules:

- Cannot be deleted while jobs or applicants still reference it.
- Helper action must return both the source and created alias.

### Talent Pool (`hr.talent.pool` or equivalent)

Fields:

- `name`: string, required
- `applicant_ids`: many2many(applicant model), required or optional depending on implementation
- `talent_count`: computed integer
- `company_id`: many2one(`res.company`), optional

Validation Rules:

- Duplicate applicant membership should be idempotent or prevented by relation constraints.

### Interviewer Access

Possible representation:

- `res.users` membership or recruiter role flag tied to recruitment interview access.

Validation Rules:

- Access should be reversible and traceable when enabled or removed.

### Recruitment Scenario

Fields:

- `name`: string, required
- `stage_ids`: many2many or one2many to stage templates, required for pipeline population

Validation Rules:

- Loading an empty scenario should not corrupt the current pipeline state.

## State Transitions

- Job creation: set company address, favorites, and baseline counters.
- Source creation: optionally create alias and link it.
- Talent pool updates: recalculate pool counts when applicants are added or removed.
- Interviewer access updates: add or remove users from the interviewer set and preserve audit trail.