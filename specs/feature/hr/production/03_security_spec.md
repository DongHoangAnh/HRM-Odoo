# HR Security Spec

## Security Goals
- Protect private employee data.
- Support public employee browsing without leaking HR-only fields.
- Enforce company isolation.
- Keep sensitive actions restricted to HR roles.
- Preserve safe self-service for the current user.

## Roles
- System Administrator
- HR User
- HR Manager
- HR Officer
- Employee Self-Service User
- Public / Non-HR User

## Access Matrix

### hr.employee
- HR User: full read access to HR-safe data.
- HR Manager: write access to sensitive HR fields and contract data.
- Employee: limited access to own data.
- Public user: no direct access to the private model.

### hr.employee.public
- Non-HR users: read-only access to public data.
- Managers: additional manager-only fields as allowed.
- Employees: access to their own public profile.

### hr.version
- HR Manager: manage contract, wage, and scheduling data.
- HR User: read employee version and allowed fields.
- Public user: no direct access.

### hr.department
- HR User: full department management.
- Non-HR user: limited access through public employee model when needed.

### Contacts and bank accounts
- HR User: manage salary allocation and work contacts.
- Non-HR user: masked bank account display only when applicable.
- Employee self-service: only own allowed bank/contact fields.

## Field Protection Rules
- Private phone, private email, birthday, permits, visa data, and similar fields are HR-only.
- Work contacts and bank allocations are HR-controlled.
- Badge IDs and PINs are HR-controlled.
- Sensitive contract dates and wage information are HR manager only.

## Record Rules
- Restrict employee visibility to allowed companies.
- Restrict public employee records to safe fields only.
- Prevent cross-company employee/user ambiguity.
- Restrict department and version searches based on access level.

## Action Security
- Create employee from user only if the user has access to the current company.
- Archive and unarchive only with the appropriate HR permissions.
- Related contact actions must not expose private contact data to non-authorized users.
- Department and employee open actions must switch between private and public models depending on access.

## Notification Security
- HR responsible notifications should go only to approved recipients.
- Sensitive update messages should include changed field names without exposing hidden data to unauthorized users.

## Audit Expectations
- Sensitive writes should be trackable through mail.thread when enabled.
- Changes to critical HR data should preserve traceability.
- No security rule should rely on client-side hiding only.

## Multi-Company Rules
- User-to-employee mapping must stay scoped to the active company.
- Public and private views must respect allowed_company_ids.
- Bank, department, and version data must not cross company boundaries unless explicitly shared.
