# Research — Overtime Management (002-manage-overtime)

## Decision: Overtime computation source
- Chosen: Compute overtime from attendance duration relative to company-defined expected hours per day/week. Manual overtime lines supported for corrections.
- Rationale: Attendance is the canonical time source; manual lines allow exceptions and reconciliations.
- Alternatives considered: Relying only on manual entries (rejected — error-prone), or using external devices (out of scope).

## Decision: Linking overtime ↔ attendance
- Chosen: Link by employee + time overlap with optional tolerance window; store explicit `attendance_id` when resolved.
- Rationale: Robust for matching computed overtime and for UI traceability.

## Decision: Approval workflow
- Chosen states: `pending`, `approved`, `refused`. Company `validation_mode` determines default (auto-approve vs pending).
- Rationale: Matches acceptance criteria and preserves audit trail.

## Decision: Rules & rulesets
- Chosen: Ordered `OvertimeRule` objects evaluated by precedence; `OvertimeRuleset` applies per company.
- Rationale: Flexible policy expression, supports thresholds and time windows.

## Decision: Compensation outcomes
- Chosen: Two primary outcomes: `time_off` (converts to leave balance) and `monetary` (payout handled by payroll integration).

## Open questions (NEEDS CLARIFICATION)
- Exact shape of payroll integration for monetary payouts. (Research task)
- Tolerance window semantics for matching attendance (e.g., 5–30 minutes). (Research task)
