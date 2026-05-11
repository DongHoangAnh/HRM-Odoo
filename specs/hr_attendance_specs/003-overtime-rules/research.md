# Phase 0 Research: Overtime Rules and Ruleset Configuration

## Decision 1: Use dedicated Odoo models for ruleset and rule policy data

- Decision: Represent overtime policy using `hr.attendance.overtime.ruleset` and `hr.attendance.overtime.rule` models in a custom `hrm_attendance_overtime` module.
- Rationale: Feature requirements need company/country scoping, default active behavior, rule counting, applicability filtering, and validation lifecycle. Odoo models provide ORM constraints, access control, and UI bindings naturally.
- Alternatives considered:
  - Extend all policy fields directly into existing attendance models: rejected because policy lifecycle is separate from attendance sessions and would create coupling.
  - Store policy as JSON settings: rejected because it weakens validation, ACL control, and queryability.

## Decision 2: Enforce rules with ORM constraints and business-level validation methods

- Decision: Implement hard validation in `@api.constrains` and create/write guards for required expected-hours inputs, schedule requirements, and timing boundary ranges.
- Rationale: FR-007, FR-009, FR-010, and FR-016 require invalid configurations to be blocked reliably with clear user-facing errors.
- Alternatives considered:
  - UI-only validation (onchange/view attrs): rejected because API/import/automation paths could bypass checks.
  - SQL constraints only: rejected because cross-field conditional validation is complex and less expressive.

## Decision 3: Support explicit ruleset aggregation modes (`max` and `sum`)

- Decision: Define a ruleset field `combination_mode` with values `max_rate` (default) and `sum_rate`, and centralize combination logic in a deterministic evaluator.
- Rationale: FR-004 and FR-015 require predictable combination of overlapping rule results and default behavior.
- Alternatives considered:
  - Hardcode maximum-only aggregation: rejected because additive mode is explicitly required.
  - Per-rule custom formulas: rejected for scope and complexity risk during first delivery.

## Decision 4: Model applicability context as a derived evaluation input, not persistent duplicated state

- Decision: Compute rule applicability from attendance date window, resource calendar, leave intervals, and working-day classification at evaluation time.
- Rationale: FR-012 requires multiple timing scopes, and deriving applicability from source records avoids stale duplicated context.
- Alternatives considered:
  - Persist all context flags on attendance rows: rejected due to synchronization burden and recomputation drift.
  - Recompute with unrestricted historical writes: rejected due to risk to protected history.

## Decision 5: Regeneration must be scoped to eligible attendance records

- Decision: Implement regeneration as an explicit action/wizard that identifies eligible attendances by ruleset linkage and date domain, then recomputes overtime in transactional batches.
- Rationale: FR-013, FR-014, and FR-017 require controlled recomputation without affecting records outside eligibility.
- Alternatives considered:
  - Full-table overtime rebuild: rejected due to high risk and unnecessary writes.
  - Immediate global recompute on every rule update: rejected due to performance and operational safety concerns.

## Decision 6: Use Odoo-native testing with BDD traceability

- Decision: Cover rule creation validation, applicability behavior, and regeneration with Odoo transactional tests mapped to acceptance scenarios.
- Rationale: Requirements are behavior-heavy and cross-domain; transactional tests validate ORM constraints and business methods consistently.
- Alternatives considered:
  - Manual-only QA: rejected because regression risk is too high for policy logic.
  - Pure unit mocks with no ORM: rejected because model constraints and security behavior are central.

## Clarification Resolution Summary

All `NEEDS CLARIFICATION` placeholders for this feature are resolved for planning purposes:
- Runtime and framework: Odoo 19 on Python 3.10-3.14.
- Persistence: PostgreSQL through Odoo ORM only.
- Interface shape: Odoo model methods + wizard action contracts.
- Safety constraints: no Odoo core modification and scoped regeneration only.
