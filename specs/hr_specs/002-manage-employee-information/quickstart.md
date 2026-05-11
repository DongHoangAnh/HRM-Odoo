# Quickstart: Manage Employee Information (developer)

1. Create the addon at `addons/hrm_custom/hrm_employee_ext` with `__manifest__.py` depending on `hr`.
2. Implement model extensions in `models/hr_employee.py` using `_inherit = 'hr.employee'`.
3. Add `security/ir.model.access.csv` and include tests under `tests/`.
4. Start Odoo with the custom addons path and install `hrm_employee_ext`.

Commands (example):

```powershell
odoo-bin -c odoo.conf --addons-path=addons,addons/hrm_custom
python odoo-bin -i hrm_employee_ext --test-enable --stop-after-init
```

Notes:
- Wrap optional external dependencies (like `phonenumbers`) to avoid hard failures if not installed.
- Follow `rules.md` for code style, ACL, and non-destructive DB changes.

***
