# Quickstart — Implement Versions & Contracts

1. Create addon `addons/hrm_custom/hrm_versions_contracts` with `__manifest__.py`.
2. Add models under `models/`:
   - `employee_version.py`, `contract_version.py`, and extend `hr.employee` / `hr.contract`.
3. Add `security/ir.model.access.csv` and minimal ACLs.
4. Add views: form/tab to view version history and restore button.
5. Add unit tests under `tests/test_versions.py` covering create/restore/validation.
6. Run tests with `pytest` (or Odoo test runner) and iterate.

Developer commands (example):

```powershell
# from repo root
python -m pip install -r requirements.txt  # if project has pinned requirements
# Start Odoo with the addon path including addons/hrm_custom
# Run tests via Odoo test runner or pytest configured for the project
```
