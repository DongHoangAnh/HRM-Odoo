# research.md - Applicant Tracking

## Resolved Technical Decisions

- Decision: Implement the feature as an Odoo add-on module.
  - Rationale: The workspace README identifies the repository as custom Odoo, and the feature maps cleanly to Odoo recruitment, mail, and employee extension points.
  - Alternatives considered: A standalone service or generic application layer. Rejected because the feature depends on Odoo-native models, chatter, attachments, and stage workflows.

- Decision: Use PostgreSQL through the Odoo ORM for all persistence.
  - Rationale: Odoo already centralizes model persistence in PostgreSQL and the feature needs transactional updates across applicant, interview, and employee linkage records.
  - Alternatives considered: Direct SQL or a secondary datastore. Rejected because they would bypass Odoo behavior and complicate audit/history handling.

- Decision: Normalize phone numbers with `python-phonenumbers` when the field is present.
  - Rationale: The spec requires a consistent readable format and the library handles international input more reliably than custom regex parsing.
  - Alternatives considered: Custom formatting rules. Rejected because they are brittle for international recruiter input.

- Decision: Use Odoo chatter/activity and linked records to represent applicant history.
  - Rationale: The spec requires a full interaction timeline, and Odoo already provides a durable message and activity model.
  - Alternatives considered: A custom timeline table. Rejected because it duplicates existing platform capabilities.

- Decision: Treat duplicate-email detection as a visible warning, not a hard block.
  - Rationale: The spec explicitly allows the record to be saved while warning the recruiter.
  - Alternatives considered: Hard validation on create. Rejected because it would prevent legitimate edge cases and contradict the feature wording.

- Decision: Restrict employee conversion to applicants in the hired state and copy core identity/contact data into the employee record.
  - Rationale: The hiring handoff must be explicit and deterministic, and the spec requires the employee to inherit the applicant's identity details.
  - Alternatives considered: Automatic conversion from any terminal state. Rejected because it would weaken lifecycle controls.

## Implementation Notes

- Applicant creation should initialize the first recruitment stage, active recruiting status, opening date, and timeline entries.
- Stage transitions should update last-stage timing and closure fields where applicable.
- Interviews and interviewer assignments should be linked records so the timeline can show full history without flattening data.
- Source reporting should use structured fields rather than free text so counts can be grouped reliably.

## Alternatives Considered

- Build a custom pipeline engine: rejected because Odoo already supplies recruitment stages and state management.
- Store activity history in a bespoke table: rejected because Odoo chatter already satisfies the audit and timeline requirement.