# Phase 0 Research: Manage Employee Information

Decisions:
- Implement as an addon `hrm_employee_ext` under `addons/hrm_custom` to avoid touching Odoo core.
- Use Odoo ORM and standard hooks (`write`, `create`, `@api.onchange`, computed fields, `_track_visibility`) for audit and synchronization.

Unknowns / NEEDS CLARIFICATION:
- Confirm whether `phonenumbers` library can be added as dependency for phone normalization.
- Confirm the exact uniqueness rule for `WorkContact` that defines a "shared" contact (e.g., same partner record vs. dedup by email/phone).

Best practices:
- Use `_inherit = 'hr.employee'` and keep logic isolated in the addon.
- Add unit tests for each scenario (name sync, contact creation, shared contact protection, coach fallback).

Alternatives:
- In-core modifications (rejected per constitution): avoid.

***
