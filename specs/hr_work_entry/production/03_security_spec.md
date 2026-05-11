# HR Work Entry Security Spec

## Security Goals
- Restrict work-entry creation and regeneration to the right payroll and HR roles.
- Protect validated entries from accidental or unauthorized deletion.
- Keep work-entry type configuration safe.
- Preserve company-level generation boundaries.

## Project Context (Context Discovery alignment)

- Work-entry security must protect validated entries consumed by payroll and allow trusted integrations (Operations, Attendance) to write teaching-hours or attendance-derived inputs while restricting general edits.

## Roles
- System Administrator
- HR Manager
- Payroll Manager
- Accountant
- Employee Self-Service User

## Access Rules

### hr.work.entry
- HR and payroll roles can create and manage work entries.
- Validated work entries should have stronger protection than draft ones.
- Employees should not manage unrelated payroll work entries.

### hr.work.entry.type
- Configuration is limited to admin or payroll setup roles.
- Country and code constraints must be enforced server-side.

### hr.version work-entry fields
- Work-entry generation fields should be writable only by authorized roles.
- Source and generation range fields should not be exposed to unauthorized users.

## Field Protection Rules
- date_generated_from and date_generated_to are internal generation fields.
- last_generation_date is internal and should not be user-editable directly.
- work_entry_source should be manager-only.

## Record Rule Expectations
- Users should only see work entries in companies they can access.
- Employee-linked data should not be cross-company unless explicitly permitted.
- Validated records must remain protected even if drafts can be edited.

## Action Security
- Validate, cancel, split, and regenerate actions must validate permissions.
- Cron generation should run as system context only.
- Type creation and edits must obey setup restrictions.

## Audit Expectations
- Generation runs should be traceable.
- State changes should remain visible in logs and chatter where enabled.
- Recompute operations must not silently override validated entries.
