# research.md - Job Platforms and Interviewer Sync

## Resolved Technical Decisions

- Decision: Implement the feature as an Odoo add-on module.
  - Rationale: The feature extends recruitment jobs, aliases, and interviewer access, which are all standard Odoo extension points.
  - Alternatives considered: A standalone synchronization service. Rejected because it would duplicate Odoo model and access behavior.

- Decision: Persist all changes through the Odoo ORM on PostgreSQL.
  - Rationale: Job platform uniqueness, alias default refresh, and group membership updates need transactional consistency with recruitment records.
  - Alternatives considered: Raw SQL or a secondary datastore. Rejected because they would bypass Odoo validation and auditing.

- Decision: Normalize platform email addresses by trimming whitespace and applying case-insensitive comparison rules.
  - Rationale: The spec requires normalized stored email values and duplicate detection based on the email address.
  - Alternatives considered: Storing original casing only. Rejected because it would weaken duplicate detection.

- Decision: Enforce duplicate platform email prevention with a model-level validation error.
  - Rationale: The user story explicitly requires duplicate emails to be rejected.
  - Alternatives considered: Warning-only duplicate detection. Rejected because it would allow conflicting platform records.

- Decision: Use `mail.alias` defaults tied to job ownership fields for alias refresh behavior.
  - Rationale: Odoo alias support is the native mechanism for routing inbound messages and updating defaults when job metadata changes.
  - Alternatives considered: Custom alias tables. Rejected because they duplicate platform functionality.

- Decision: Sync interviewer access through the recruitment interviewer group based on active job and applicant assignments.
  - Rationale: The feature requires group membership to match current assignments and to drop when a user is no longer referenced anywhere.
  - Alternatives considered: Manually maintained role flags. Rejected because they are harder to keep in sync.

## Implementation Notes

- Job platform create/update should normalize email and store parsing patterns when provided.
- Job alias updates should recompute alias defaults whenever ownership fields change.
- Job records should expose related source records, activity access, employee access, and hiring counters from the form.
- Interviewer membership should be updated on job save and cleaned up when the user is no longer assigned as an interviewer anywhere.

## Alternatives Considered

- Build a separate sync daemon: rejected because the feature is small enough to remain inside the Odoo module.
- Store interviewer state on the user record only: rejected because group membership is the required operating model.