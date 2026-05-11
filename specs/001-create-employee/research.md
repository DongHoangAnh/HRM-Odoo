# research.md — Create Employee

## Unknowns / NEEDS CLARIFICATION

- Odoo major/minor version used by this repo (affects API and migrations).
- Exact Python version required by repository environment.
- Preferred test harness (native Odoo tests vs pytest integration).
- Permission model specifics for automatic contact creation.
- Expected production scale and performance targets for bulk imports.

## Decisions & Rationale

- Decision: Use Python 3.11 where possible.
  - Rationale: Modern Odoo versions are compatible with Python 3.10/3.11; 3.11 offers improvements.
- Decision: Store data via Odoo ORM on PostgreSQL.
  - Rationale: This repository is an Odoo module; Odoo uses PostgreSQL as primary storage.
- Decision: Use `python-phonenumbers` for phone normalization to E.164.
  - Rationale: Well-maintained library with robust parsing/formatting.
- Decision: Implement uniqueness constraint for `user_id` per `company_id` at the ORM/model level and return a clear validation error on conflict.
  - Rationale: Prevents duplicate user linking within same company; preserves multi-company reuse.
- Decision: Create an initial `hr.version` record during employee create and set `current_version_id`.
  - Rationale: Meets audit/versioning requirement in spec.

## Alternatives Considered

- Phone normalization via custom regex: rejected in favor of `python-phonenumbers` for international correctness.
- Enforce global uniqueness of user->employee mapping: rejected due to multi-company requirement in spec.

## Next Steps (Phase 1 inputs)

- Produce `data-model.md` with concrete fields and types.
- Draft `quickstart.md` with developer run steps and test commands.
- Create `contracts/employee-create.md` describing expected create contract and error cases.
