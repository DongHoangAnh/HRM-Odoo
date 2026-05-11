# Research: Archive and Unarchive Employees

## Decision: Archive flow
Use the employee model's archive/unarchive methods with Odoo ORM overrides, preserving contract data and clearing only relationship fields required by the spec.

## Rationale
- Matches Odoo's built-in active/inactive semantics.
- Minimizes data loss by keeping historical records intact.
- Keeps the change localized to HR employee behavior.

## Alternatives considered
- Hard delete of employees: rejected because it destroys historical data and breaks references.
- Separate archival table: more complex and unnecessary for the current scope.

## Open questions
- Confirm whether linked `res.resource` should be archived through a direct relation or via existing Odoo hooks.
- Determine the exact UI for the departure wizard and whether it should be a modal or a transient model page.
- Confirm if imports/bulk writes should always bypass the wizard when `no_wizard=True` is set.
