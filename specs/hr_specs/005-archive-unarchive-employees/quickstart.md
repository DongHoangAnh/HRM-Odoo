# Quickstart — Archive and Unarchive Employees

1. Create addon `addons/hrm_custom/hrm_employee_archive` with `__manifest__.py`.
2. Extend `hr.employee` in `models/employee.py` to override archive/unarchive flows.
3. Add a transient wizard model for departure capture when a single subordinate exists.
4. Add security rules and ACLs for HR managers.
5. Add tests for archive, bulk archive, unarchive, wizard display, and cycle prevention.

Developer commands (example):

```powershell
# from repo root
python -m pip install -r requirements.txt  # if project has pinned requirements
# Run the Odoo test suite for the addon once scaffolded
```
