# Quickstart — 002-manage-overtime

1. Review the feature spec at `spec.md` and the plan at `plan.md`.
2. Generate plan template (already done by setup script):

```powershell
$env:SPECIFY_FEATURE_DIRECTORY = 'D:\odoo-dev\HRM-Odoo\specs\hr_attendance_specs\002-manage-overtime'
.\.specify\scripts\powershell\setup-plan.ps1 -Json
```

3. Implement model & tests using `data-model.md` as source of truth.
4. Use `research.md` for design rationale and open questions to resolve.
