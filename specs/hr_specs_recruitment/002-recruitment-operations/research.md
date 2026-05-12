# research.md - Recruitment Operations

## Resolved Technical Decisions

- Decision: Implement the feature as an Odoo add-on module.
  - Rationale: The feature extends recruitment jobs, stages, sources, and talent pools that already fit Odoo model extension patterns.
  - Alternatives considered: A standalone workflow service. Rejected because the behavior depends on recruitment, mail, and calendar integration.

- Decision: Persist operational data through the Odoo ORM on PostgreSQL.
  - Rationale: Job counters, source references, and talent-pool membership need transactional consistency with the existing recruitment models.
  - Alternatives considered: Direct SQL or a separate datastore. Rejected because they would bypass Odoo behavior and complicate referential checks.

- Decision: Use mail aliases for recruitment sources that require routed intake.
  - Rationale: The spec requires source alias creation and helper behavior; mail alias support is the standard Odoo mechanism.
  - Alternatives considered: Custom alias tables. Rejected because they duplicate platform capabilities.

- Decision: Model talent pools as linked collections of applicants/talents with computed counts.
  - Rationale: The feature requires pool membership, updated counts, and reuse across recruiting activity.
  - Alternatives considered: Free-form tags only. Rejected because tags do not provide explicit membership management.

- Decision: Represent interviewer access as a managed recruiter membership or access set rather than ad hoc flags.
  - Rationale: The feature requires enable/remove behavior that should remain auditable and reversible.
  - Alternatives considered: One-off boolean fields on users. Rejected because the access model needs clearer lifecycle control.

- Decision: Keep source deletion guarded by reference checks.
  - Rationale: The spec explicitly forbids removal when jobs or applicants still reference the source.
  - Alternatives considered: Cascade deletion. Rejected because it would destroy attribution history.

## Implementation Notes

- Recruitment jobs should expose computed counters for applicants, employees, open applicants, and recent activity.
- Recruitment scenarios should populate stage pipelines from stored templates or linked stage definitions.
- Calendar events marked as recruitment-related should stay visible from the job and applicant flows.
- Operational summaries should reuse existing recruitment models wherever possible instead of duplicating counts in a separate reporting store.

## Alternatives Considered

- Build a custom pipeline engine: rejected because Odoo recruitment already manages stage sequencing and job linkage.
- Store interviewer access in a separate access-control service: rejected because the feature is small enough to fit inside the recruitment module.