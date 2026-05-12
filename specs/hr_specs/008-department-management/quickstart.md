# Quickstart: Run & Test Department Management Feature Locally

1. Ensure Odoo 19 and Python 3.10–3.14 are installed and configured.
2. Place the addon under your addons path, e.g. `addons/hrm_custom/hrm_department_ext`.
3. Update `__manifest__.py` in the addon with name, dependencies (e.g., `hr`), data files (views, security).
4. Start Odoo server with the addons path including `addons/hrm_custom`:

```powershell
odoo-bin -c odoo.conf --addons-path=addons,addons/hrm_custom
```

5. Update apps in Odoo UI and install `hrm_department_ext`.
6. Run tests (from repository root) using Odoo test runner or a test command defined in the module:

```powershell
python odoo-bin -i hrm_department_ext --test-enable --stop-after-init
```

Notes:
- Follow `rules.md` constraints: do NOT modify Odoo core; use `_inherit` for extensions; add `ir.model.access.csv` if new models/records are introduced.
- Add unit/integration tests for circular detection, complete_name computation, quick-create, and manager reassignment.
