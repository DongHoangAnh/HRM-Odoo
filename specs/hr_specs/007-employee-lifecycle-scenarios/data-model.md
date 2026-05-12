# Data Model: Employee Lifecycle and Scenario Management

## Entities

- hr.employee
  - `birthday_public_display` (boolean)
  - `birthday_public_display_string` (computed char)
  - `related_partners_count` (computed integer)
  - `newly_hired` (computed boolean or search helper)
  - `avatar_svg` (binary/text, if stored)
  - `hr_history_line_ids` (one2many to history records)

- hr.employee.history.line
  - `employee_id` (m2o -> hr.employee)
  - `field_name` (char)
  - `old_value` (char/text)
  - `new_value` (char/text)
  - `changed_by_id` (m2o -> res.users)
  - `changed_at` (datetime)

- hr.employee.onboarding.log
  - `employee_id` (m2o -> hr.employee)
  - `message` (text)
  - `created_at` (datetime)

- hr.version
  - `employee_id` (m2o -> hr.employee)
  - `version_date` (date/datetime)
  - `context_data` (json/text)

- hr.department
  - `auto_subscribe_channel_ids` (m2m -> mail.channel)

## Relationships
- One employee can have many history lines and onboarding logs.
- Employee-related partner data is derived from linked work contacts and linked user partner.
- Department channel subscriptions affect employees on create/move.

## Validation Rules
- Demo data load must be idempotent.
- Public employee views must hide restricted fields.
- Auto-generated avatars must not override uploaded images.
- Lifecycle computations must respect privacy flags and existing contact data.

## Notes
- Some behaviors may map to existing Odoo mechanisms such as tracking, computed fields, or action windows rather than new stored entities.
