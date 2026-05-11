# Data Model: Manage Employee Information

Extensions and key fields:

- `hr.employee` (extend)
  - behavior: name sync to resource, contact creation, coach/manager validation, contract/version helpers
  - fields used: `name`, `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `timezone`, `company_id`, `parent_id`, `coach_id`, `image_1920`, `bank_account_ids`, `categories`

- `res.partner` (work contact)
  - referenced as `work_contact_id` on employee
  - uniqueness detection: requires clarification (partner id vs. dedupe by email/phone)

- `hr.version` / `ContractVersion`
  - version records with `date_version`, `contract_date_start`, `contract_date_end`

Constraints:
- Do not alter core schema directly; add only module-level changes via ORM migrations.
- Respect ACLs and add `ir.model.access.csv` entries if new models/records or methods need protection.

***
