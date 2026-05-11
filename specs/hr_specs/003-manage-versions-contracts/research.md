# Research: Versioning & Contracts

## Decision: Versioning approach
NEEDS CLARIFICATION — Options:
- Event-sourced / delta changes per field (more complex, smaller storage)
- Snapshot-per-change (simpler, easier to restore)

## Rationale (defer until research complete)
- Snapshot approach recommended for initial implementation: simpler, aligns with Odoo record-copy patterns, easier UI restore.

## Alternatives considered
- Use external revision module (e.g., `logup` or Odoo `mail.thread` history) vs internal version table.

## Tasks
- Research GDPR/retention best practices for employee contract history.
- Determine whether contract numbering and effective-date overlapping allowed.
- Identify Odoo native facilities to reuse (chatter, mail.message, ir.attachment storage costs).
