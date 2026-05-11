# quickstart.md — Create Employee (developer)

Prerequisites:

- Running Odoo instance with repository mounted in `addons` path.
- PostgreSQL available and `res.company`/`res.users` fixtures as needed.

Developer quick steps (example):

1. Update addons path and install module (adjust for your environment):

```powershell
# start Odoo (example, adapt to your project)
python3 -m odoo --addons-path=addons,./ --db-filter=mydb --dev=reload
```

2. From Odoo shell create an employee manually for quick verification:

```python
# use Odoo shell
from odoo import api, SUPERUSER_ID
env = api.Environment(cr, SUPERUSER_ID, {})
Employee = env['hr.employee']
employee = Employee.create({'name': 'John Doe', 'company_id': env.ref('base.main_company').id})
print(employee.id, employee.current_version_id)
```

3. Run tests (if using pytest integration) — adapt to project test runner:

```powershell
pytest tests/ -k create_employee
```

Notes:

- If `python-phonenumbers` is introduced, add it to the project's requirements.
- Ensure permissions for contact creation are available for the test user when verifying automatic contact creation.
