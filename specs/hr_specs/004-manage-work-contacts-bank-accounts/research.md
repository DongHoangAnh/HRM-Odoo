# Research: Work Contacts & Bank Accounts

## Decision candidates
- Use a dedicated `hr.work.contact` model with `type` (phone,email,address,bank), `is_shared` flag, and `owner_employee_id`.
- Phone validation: use `phonenumbers` library when available; fallback to regex.
- Bank account: validate IBAN using `stdnum` or `python-stdnum` if allowed, otherwise simple checksum.

## Rationale
- Dedicated model simplifies sharing and audit history.
- Using well-known libraries reduces edge-case bugs for number formats.

## Tasks
- Confirm allowed external libraries (`phonenumbers`, `python-stdnum`).
- Define sharing propagation: clone vs reference.
- Define retention and privacy for shared contacts.
