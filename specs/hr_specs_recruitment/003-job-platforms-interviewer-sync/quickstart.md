# quickstart.md - Job Platforms and Interviewer Sync

## Prerequisites

- Odoo development environment available for the repository.
- PostgreSQL database configured for the local Odoo instance.
- Recruitment modules mounted in the Odoo addons path.

## Setup

1. Start Odoo with the repository addons path and a test database.

```powershell
python3 -m odoo --addons-path=addons,./ --db-filter=job_platform_sync --dev=reload
```

2. Install the job platform and interviewer sync module from the Apps menu or via the Odoo shell.

3. Ensure at least one company, one recruiter, and one recruitment job exist.

## Smoke Test

1. Create a job platform with an email address and confirm the stored email is normalized.
2. Attempt to create a second platform with the same email and confirm the duplicate is rejected.
3. Save a job with a department or responsible user change and confirm alias defaults refresh.
4. Open the job form and verify source records, activities, and employee actions are exposed.
5. Add and remove interviewer assignments, then confirm group membership follows the active assignments.

## Validation Command

```powershell
python3 -m odoo --addons-path=addons,./ --db-filter=job_platform_sync --test-enable --stop-after-init -i hr_recruitment_platform_sync
```

## Notes

- If the final module name differs, update the install and validation commands to match the manifest.
- The email normalization rule should be consistent across create and update paths.