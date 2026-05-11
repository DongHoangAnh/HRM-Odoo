# Quickstart — Implement Work Contacts & Bank Accounts

1. Create addon `addons/hrm_custom/hrm_work_contacts` with `__manifest__.py`.
2. Add models under `models/`: `work_contact.py`, optionally `bank_account.py`, and extend `hr.employee`.
3. Add `security/ir.model.access.csv` and ACLs for HR roles.
4. Add views: form/tab in employee form to list/add contacts; a wizard to share contacts.
5. Add unit tests under `tests/test_contacts.py` covering create/share/validate flows.

Developer commands (example):

```powershell
# from repo root
python -m pip install -r requirements.txt  # if project has pinned requirements
# Start Odoo with the addon path including addons/hrm_custom
# Run tests via Odoo test runner or pytest configured for the project
```
