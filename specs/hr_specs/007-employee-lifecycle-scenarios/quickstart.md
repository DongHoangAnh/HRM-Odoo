# Quickstart — Employee Lifecycle and Scenario Management

1. Create addon `addons/hrm_custom/hrm_employee_lifecycle` with `__manifest__.py`.
2. Extend `hr.employee` in `models/employee.py` for onboarding, metadata, and lifecycle helpers.
3. Add a transient wizard or action for onboarding guidance if needed.
4. Add history tracking models or leverage existing Odoo tracking where appropriate.
5. Add tests for onboarding message, demo data idempotency, public/HR form behavior, avatar handling, metadata, and subscriptions.

Developer commands (example):

```powershell
# from repo root
python -m pip install -r requirements.txt  # if project has pinned requirements
# Run the Odoo test suite for the addon once scaffolded
```
