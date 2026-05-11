# data-model.md — Create Employee

## Entities

### Employee (`hr.employee`) — extended

Fields (name: type — notes):

- `name`: string — required
- `legal_name`: string — optional
- `birthday`: date — optional; supports birthday tracking
- `place_of_birth`: string — optional
- `country_of_birth`: many2one(country) — optional
- `company_id`: many2one(res.company) — required
- `user_id`: many2one(res.users) — optional; UNIQUE constraint per (`company_id`, `user_id`)
- `work_contact_id`: many2one(res.partner) — optional; created when `work_email` present and permission granted
- `work_phone`: string — store E.164 normalized value
- `mobile_phone`: string — store E.164 normalized value
- `tz`: string — timezone identifier (IANA)
- `barcode`: string — badge ID, optional, indexed
- `pin`: string — optional (consider hashing/encryption if sensitive)
- `category_ids`: many2many(hr.employee.category) — tags/categories
- `current_version_id`: many2one(hr.version) — points to latest version

Constraints & Indexes:

- Unique constraint on (`company_id`, `user_id`) when `user_id` is set.
- Index on `barcode` for quick lookup.
- Ensure `work_phone` and `mobile_phone` conform to E.164 format on write.

### HR Version (`hr.version`)

- `name`, `created_by`, `created_on`, `employee_id`, `data_snapshot` (json)
- Created automatically on new employee creation; `current_version_id` set to new version.

### Resource (`resource.resource`)

- Create a `resource.resource` record per employee and link it to the employee (field `resource_id` or equivalent).

## Validation Rules

- phone numbers: normalized and validated by `python-phonenumbers`; invalid numbers cause validation errors.
- duplicate user linking: creation raises `ValidationError` with explanatory message.

## State Transitions

- On create: set `active` = True, create `resource` record, create `hr.version` record, set `current_version_id`.
- On update: optionally create a new `hr.version` entry if significant fields change (out of scope for initial implementation).
