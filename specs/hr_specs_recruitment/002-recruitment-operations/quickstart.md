# quickstart.md - Recruitment Operations

## Prerequisites

- Odoo development environment available for the repository.
- PostgreSQL database configured for the local Odoo instance.
- Recruitment modules mounted in the Odoo addons path.

## Setup

1. Start Odoo with the repository addons path and a test database.

```powershell
python3 -m odoo --addons-path=addons,./ --db-filter=recruitment_operations --dev=reload
```

2. Install the recruitment operations module from the Apps menu or via the Odoo shell.

3. Ensure at least one company, one recruiter, and one test job exist.

## Smoke Test

1. Create a recruitment job and confirm the address defaults from the company.
2. Verify favorite users, application counters, employee counters, and action links are present.
3. Create a recruitment stage and confirm its default configuration and warning visibility.
4. Create a recruitment source, generate its alias, and confirm delete protection while referenced.
5. Create a talent pool, add applicants, and confirm the talent count updates.
6. Enable and remove interviewer access for a recruiter user, then verify the change is reflected.

## Validation Command

```powershell
python3 -m odoo --addons-path=addons,./ --db-filter=recruitment_operations --test-enable --stop-after-init -i hr_recruitment_operations
```

## Notes

- If the final module name differs, update the install and validation commands to match the manifest.
- Source alias creation depends on whether the deployment uses mail alias routing for recruitment intake.