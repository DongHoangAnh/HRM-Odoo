# quickstart.md - Applicant Tracking

## Prerequisites

- Odoo development environment available for the repository.
- PostgreSQL database configured for the local Odoo instance.
- The custom recruitment add-on mounted in the Odoo addons path.

## Setup

1. Start Odoo with the repository addons path and a test database.

```powershell
python3 -m odoo --addons-path=addons,./ --db-filter=applicant_tracking --dev=reload
```

2. Install the applicant tracking module from the Apps menu or via the Odoo shell.

3. Create a test company and job position if fixtures are not already present.

## Smoke Test

1. Create an applicant with name, email, job, and company.
2. Confirm the record opens in the initial recruitment stage with an active status.
3. Add a phone number, linked profile, education, and availability, then verify the stored values are preserved.
4. Move the applicant through at least one stage and confirm the update timestamp changes.
5. Add an interview meeting and confirm it appears in the activity/timeline feed.
6. Mark the applicant as hired and run the employee conversion flow.

## Validation Command

```powershell
python3 -m odoo --addons-path=addons,./ --db-filter=applicant_tracking --test-enable --stop-after-init -i hr_recruitment_applicant_tracking
```

## Notes

- Duplicate-email creation should show a warning while still allowing the recruiter to review the record.
- If the module name differs in the final implementation, update the install command and validation command to match the manifest.