# Data Model: Notify Expiring Contracts and Work Permits

## Entities

- hr.employee
  - `contract_date_end` (date)
  - `work_permit_expiration_date` (date)
  - `hr_responsible_id` (m2o -> res.users)
  - `active` (boolean)

- res.company
  - `contract_expiration_notice_period` (integer, days)
  - `work_permit_expiration_notice_period` (integer, days)

- mail.activity
  - `res_model` / `res_id` links to `hr.employee`
  - `activity_type_id` = `mail.mail_activity_data_todo`
  - `summary`/`note` indicates contract or permit expiration
  - `date_deadline` = expiration date
  - assigned user = `hr_responsible_id` or fallback user

## Relationships
- One company configures independent notice periods for contract and permit expirations.
- Each employee can generate zero, one, or two activities per cron run.

## Validation Rules
- Skip records with expired dates.
- Skip permanent contracts where `contract_date_end` is empty.
- Avoid duplicates by matching employee, expiration date, and notification type.

## State / Flow
- Cron scan -> eligibility check -> duplicate check -> activity create.
- Contract and permit flows are independent and can both fire for the same employee.
