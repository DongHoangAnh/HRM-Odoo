# Contract: Employee Create

This document describes the contract (model-level / API) for creating an employee.

## Model/ORM contract

- Operation: `env['hr.employee'].create(values)`
- Required fields: `name`, `company_id`
- Optional fields: `user_id`, `work_email`, `work_phone`, `mobile_phone`, `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `tz`, `barcode`, `pin`, `category_ids`

## API (HTTP) contract — optional

If exposing an HTTP endpoint, the JSON contract would be:

Request POST /api/hr/employee

```json
{
  "name": "John Doe",
  "company_id": 1,
  "user_id": 12,
  "work_email": "john@company.com",
  "work_phone": "+155512345",
  "mobile_phone": "+155556789",
  "legal_name": "John Paul Doe",
  "birthday": "1990-01-15",
  "place_of_birth": "New York",
  "country_of_birth": "US",
  "tz": "America/New_York",
  "barcode": "EMP001",
  "pin": "1234",
  "category_ids": [3]
}
```

Responses

- 201 Created: Returns created employee payload including `id` and `current_version_id`.
- 400 Bad Request: Validation error. Example errors:
  - `duplicate_user_link`: when `user_id` is already linked to another employee in same company.
  - `invalid_phone_format`: when phone normalization fails.

Error Example (400):

```json
{
  "error": "duplicate_user_link",
  "message": "The user jane@company.com is already linked to another employee in this company."
}
```
