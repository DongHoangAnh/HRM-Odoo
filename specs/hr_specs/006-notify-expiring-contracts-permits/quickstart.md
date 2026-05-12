# Quickstart — Notify Expiring Contracts and Work Permits

1. Create addon `addons/hrm_custom/hrm_expiration_notifications` with `__manifest__.py`.
2. Add cron helper logic in `models/employee.py` or a dedicated service model.
3. Add company fields for notice periods and expose them in settings if needed.
4. Add tests for contract-only, permit-only, both, duplicate suppression, and multi-company timing.
5. Run the Odoo test suite for the addon and verify cron behavior.

Developer commands (example):

```powershell
# from repo root
python -m pip install -r requirements.txt  # if project has pinned requirements
# Run Odoo tests once the addon is scaffolded
```
