# Data Model: Work Contacts & Bank Accounts

## Entities

- hr.work.contact
  - `id` (pk)
  - `employee_id` (m2o -> hr.employee)
  - `type` (selection: phone,email,address,bank)
  - `value` (char / text)
  - `is_shared` (bool)
  - `shared_with` (m2m -> hr.employee)  # optional convenience relation
  - `verified` (bool)
  - `verified_at` (datetime)
  - `created_by` (m2o -> res.users)

- hr.bank.account (or extend hr.work.contact type=bank)
  - `iban` (char)
  - `bank_name` (char)
  - `country_id` (m2o -> res.country)

## Relationships
- `hr.employee` 1..* `hr.work.contact`

## Validation Rules
- Phone numbers validated with `phonenumbers` when available.
- IBAN validation when `python-stdnum` or similar library available.
- Shared contacts must have explicit consent flag if privacy required.

## Notes
- Prefer storing normalized phone numbers (E.164) to avoid duplicates.
- Consider uniqueness index on `(type, value, employee_id)` for non-shared contacts.
