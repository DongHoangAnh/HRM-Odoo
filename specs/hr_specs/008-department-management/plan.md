# Implementation Plan: Department Management and Hierarchy

**Branch**: `008-department-management` | **Date**: 2026-05-11 | **Spec**: specs/hr_specs/008-department-management/spec.md
**Input**: Feature specification from `specs/hr_specs/008-department-management/spec.md`

## Summary

Implement department creation and hierarchy management in the HR module: auto-populated company context, computed hierarchical `complete_name`, circular-hierarchy prevention with multi-level cycle detection, quick-create support returning department ID, role-aware employee open actions (hr.employee vs. hr.employee.public), child department navigation with employee counts, manager reassignment cascade to subordinates, and department-scoped activity plan actions with context defaults. Implement as enhancement to `addons/hr_department` (extend existing Odoo HR module) or as `addons/hr_department_management` addon.

## Technical Context

**Language/Version**: Python 3.11 (preferred; confirm patch level). Odoo 19 runtime supports 3.10+. (NEEDS CLARIFICATION on specific patch requirement)
**Primary Dependencies**: Odoo 19 core (hr, mail, web modules), PostgreSQL, standard ORM features.
**Storage**: PostgreSQL via Odoo ORM; no direct SQL allowed per project rules.
**Testing**: Odoo unit/integration tests; map Gherkin scenarios to test cases. (NEEDS CLARIFICATION on BDD runner availability)
**Project Type**: Odoo addon module (extend existing `hr.department` model or create new addon).
**Performance Goals**: UI actions and manager reassignment complete within ~2s for typical org sizes (100-1000 employees); hierarchy queries scale without deep recursion.
**Constraints**: No core modifications, ORM-only schema changes, use ACLs for role-based access control per project rules.md.

## Assumptions

- `hr.department` model exists in Odoo core; enhancements via inheritance (`_inherit`).
- `complete_name` is a computed field; can be stored or on-demand computed.
- Company inheritance: child department `company_id` matches parent (enforced via constraint).
- Quick-create uses standard Odoo `name_create()` mechanism returning tuple `(id, name)`.
- User access determined by `hr.employee` model ACL; non-HR users default to `hr.employee.public`.
- Manager reassignment: when department manager changes, all direct employees in that department have `parent_id` updated.
- Circular hierarchy detection uses depth-first or ancestor-path traversal (not recursive SQL) for safety.
- Hierarchy depth is unlimited in theory; typical orgs have 3-5 levels.

## Acceptance Criteria (mapped to feature scenarios)

1. **Create with company context**: Department creation defaults `company_id` to context company; `active=True`.
2. **Hierarchical name**: Child department shows `complete_name = "Parent / Child"` format.
3. **Quick-create returns ID**: `name_create()` returns created department ID matching saved record.
4. **Search by complete_name (ilike)**: Wildcard search returns all matching hierarchies.
5. **Search by complete_name (=ilike with wildcard)**: Exact pattern matching "Parent / %" returns matching descendants.
6. **Prevent recursive departments**: System raises validation error on circular hierarchy attempts.
7. **Company inheritance**: Child inherits `company_id` from parent.
8. **Manager reassignment cascade**: Changing department manager updates all employee managers in hierarchy.
9. **Employee action (HR user)**: Action targets `hr.employee` model with list/kanban/form views.
10. **Employee action (non-HR user)**: Action targets `hr.employee.public` model.
11. **Child departments action**: Returns all descendants in kanban/list view named "Child departments".
12. **Hierarchy with counts**: Department hierarchy includes parent, self, children nodes with employee counts.
13. **Activity plan context**: Activity plan action includes `default_department_id` in context.

## Implementation Plan (high level)

1. **Extend hr.department model**
   - Add/extend fields: `company_id` (ensure default to context), `parent_id`, `active` (default True), `manager_id`.
   - Add computed field `complete_name` concatenating parent path + name with " / " separator.
   - Add inverse field `child_ids` (one2many from parent_id).
   - Add constraints: prevent `company_id` mismatch between parent/child.

2. **Implement quick-create (name_create)**
   - Override `name_create()` method to return `(id, name)` tuple matching created department.
   - Set default `company_id` from context during creation.

3. **Compute complete_name**
   - Implement algorithm: recursively fetch parent chain up to root, concatenate names with " / ".
   - Use `@api.depends('name', 'parent_id.complete_name')` for computed field.
   - Cache or store in DB depending on performance requirements. (NEEDS CLARIFICATION on storage preference)

4. **Implement complete_name search**
   - Add custom search method on `complete_name` field supporting `ilike` and `=ilike` operators.
   - `ilike` "Sales" returns all hierarchies containing "Sales" (e.g., "Sales", "Sales/APAC", "Other/Sales/Team").
   - `=ilike` "Sales / %" returns all children of "Sales" with wildcard pattern matching.

5. **Prevent circular hierarchies**
   - Add constraint method `_check_parent_not_circular()` using ancestor traversal (depth-first).
   - Query ancestors up to root; raise `ValidationError` if cycle detected.
   - Test with 2-level (A→B→A) and multi-level cycles (A→B→C→A).

6. **Enforce company inheritance**
   - Add constraint `_check_company_consistency()` ensuring child `company_id == parent.company_id`.
   - Raise error if mismatch detected on create/write.

7. **Manager reassignment cascade**
   - Override `write()` to detect `manager_id` changes.
   - When manager changes, query all employees in this department and update their `parent_id` to new manager.
   - Use SQL domain: `department_id in (self.id + self.child_ids.ids)` to include child departments. (NEEDS CLARIFICATION on whether to include child department employees)
   - Perform update in batch for performance.

8. **Role-aware employee open action**
   - Create action method `action_open_employees()`:
     - Check user permission on `hr.employee` model using `model.check_access_rights('read', raise_exception=False)`.
     - If HR user: return action targeting `hr.employee` with list/kanban/form views.
     - If non-HR user: return action targeting `hr.employee.public`.
     - Set domain: `department_id in [self.id] + self.child_ids.ids` to include hierarchy.

9. **Child departments action**
   - Create action method `action_view_child_departments()`:
     - Return kanban/list view of `self.child_ids` (direct children or recursive descendants).
     - Set action name to "Child departments".
     - Handle empty case gracefully (show empty view).

10. **Hierarchy view with employee counts**
    - Create helper method `get_hierarchy_with_counts()` returning nested structure:
      - Structure: `{'id': dept_id, 'name': complete_name, 'employee_count': n, 'children': [...]}`
      - Recursively build from root or selected department.
      - Cache result if performance needed.

11. **Department activity plan action**
    - Create action method `action_activity_plans()`:
      - Set context with `default_department_id = self.id`.
      - Domain: filter by activity plans linked to department OR global plans (NEEDS CLARIFICATION on global plan scope).
      - Handle no plans case (show notification or empty view).

12. **Views & UI**
    - Create/extend form view for department with: name, parent_id, complete_name (readonly), company_id, manager_id, active, child_ids (one2many), employee_count (computed).
    - Create kanban/list views for department with complete_name search, filters by company, manager.
    - Add action buttons in department form: "Open Employees", "View Child Departments", "Activity Plans".

13. **Tests**
    - Unit tests for: company context default, complete_name computation (single/multi-level), quick-create, circular hierarchy detection (2-level and multi-level), company inheritance constraint, manager reassignment cascade, complete_name search (ilike and =ilike), employee action (HR vs. non-HR), child departments view, hierarchy with counts.
    - Integration tests for: create dept → set manager → add employees → reassign manager → verify employee parent_ids updated.
    - Edge case tests: empty complete_name search, deeply nested hierarchies (10+ levels), bulk manager reassignments, duplicate names in different branches.

14. **Security & ACL**
    - Define IR rules for department visibility based on user role (HR Manager → full access, HR User → company-scoped access, non-HR → no access).
    - Restrict field visibility: non-HR users cannot see `manager_id`, `employee_count`, sensitive department attributes.

## Testing Plan

- Map all 12 Gherkin scenarios to Odoo test methods.
- Include boundary tests: empty departments, single employee, multi-level hierarchies (5+ levels).
- Performance tests: bulk reassignment (100+ employees), complete_name computation on large hierarchies.
- Edge cases: special characters in names, duplicate department names in different branches, concurrent updates.

## Data Model Overview

**hr.department** (extended):
- `id` (int, auto)
- `name` (char, required)
- `complete_name` (char, computed, depends on parent_id + name)
- `parent_id` (many2one hr.department, optional)
- `child_ids` (one2many hr.department, inverse of parent_id)
- `company_id` (many2one res.company, default to context company, required)
- `manager_id` (many2one hr.employee, optional)
- `active` (boolean, default True)
- `employee_count` (integer, computed)

**Relationships**:
- `hr.department.parent_id` → `hr.department.id` (self-referential)
- `hr.department.manager_id` → `hr.employee.id`
- `hr.department.company_id` → `res.company.id`
- `hr.employee.department_id` → `hr.department.id` (update via manager reassignment cascade)

## Deliverables

- `addons/hr_department_management/` or extension to existing `hr` addon with models, views, tests, manifest
- `specs/hr_specs/008-department-management/{research.md, data-model.md, quickstart.md, contracts/}` (Phase 1 artifacts)
- Test suite covering all 12 scenarios and edge cases
- Security group definitions and IR rules

## Rollout & Migration Notes

- Deploy during low-traffic window if modifying existing departments.
- Data migration: backfill `complete_name` for existing departments if stored (not computed).
- Manager reassignment: test in sandbox with large employee base before production deployment.
- Documentation: provide admin guide on department hierarchy best practices, manager reassignment workflows.

## Open Questions (NEEDS CLARIFICATION)

- Should manager reassignment cascade include child department employees, or only direct children?
- Is `complete_name` stored in DB or computed on retrieval? (performance vs. storage tradeoff)
- What is the fallback behavior if circular hierarchy detection fails mid-transaction?
- Should activity plans have a "global" scope separate from department scope?
- Is there an existing activity plan model, or should we create a custom activity plan linking model?
- What is the maximum recommended department hierarchy depth?
- Should child departments automatically inherit manager from parent if no manager set?
- For manager reassignment, should we preserve employee-manager relationships if employee is not in the affected department?

---
