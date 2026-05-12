# Data Model: Department Management

Entities and key fields (feature-scoped):

- `hr.department` (existing, extended)
  - `name`: string
  - `parent_id`: many2one -> `hr.department`
  - `complete_name`: computed string (parent path + name)
  - `company_id`: many2one -> `res.company` (default from context or parent)
  - `manager_id`: many2one -> `hr.employee` (department manager)
  - `active`: boolean

- `hr.employee` (existing, behavior changes)
  - `department_id`: many2one -> `hr.department`
  - `parent_id`: many2one -> `hr.employee` (manager)

Relationships:
- `hr.department.parent_id` → `child_ids` inverse
- Manager reassignment: when `department.manager_id` changes, update `parent_id` for employees in department hierarchy (domain: department and descendants)

Constraints & Indexes:
- Constraint to prevent recursive departments: raise ValidationError if a department is set as its own ancestor.
- Optional DB index on `complete_name` if search performance issues arise.

Validation rules:
- `company_id` of child must match `company_id` of parent (enforce via constraint)
- Prevent cycles: use ancestor traversal to detect recursion
