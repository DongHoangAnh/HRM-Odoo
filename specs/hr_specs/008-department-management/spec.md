# Feature Specification: Department Management and Hierarchy

**Feature Branch**: `008-department-management`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Department Management and Hierarchy\n  As an HR Manager\n  I want to manage departments and department hierarchies\n  So that employees, jobs, and activities stay organized"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create and organize departments hierarchically (Priority: P1)

HR managers must create departments with automatic company context inheritance and build hierarchical structures (parent/child) with automatically computed display names.

**Why this priority**: Department hierarchy is fundamental to organizational structure; correct defaults minimize manual configuration.

**Independent Test**: Create department with and without explicit company; create child department; verify complete_name and hierarchy.

**Acceptance Scenarios**:

1. **Given** a user creates a department "Engineering" in company context "Tech Corp", **When** saved, **Then** company_id defaults to "Tech Corp" and active = True.
2. **Given** a parent department "Engineering", **When** a child "Platform" is created, **Then** complete_name shows "Engineering / Platform" and company_id is inherited from parent.

---

### User Story 2 - Search and filter departments by hierarchical name (Priority: P1)

HR managers must search departments by complete hierarchical name using both like and wildcard patterns to quickly locate organizational units.

**Why this priority**: Large organizations need efficient department discovery; hierarchical search prevents ambiguity.

**Independent Test**: Create multi-level departments; search by complete_name with ilike and =ilike patterns; verify correct results.

**Acceptance Scenarios**:

1. **Given** departments "Sales", "Sales / APAC", "Sales / EMEA" exist, **When** searching by complete_name ilike "Sales", **Then** all Sales departments are returned.
2. **Given** departments "North / Field" and "North / Inside" exist, **When** searching by complete_name =ilike "North / %", **Then** both departments are returned.

---

### User Story 3 - Prevent circular hierarchies and enable quick creation (Priority: P1)

HR system must prevent recursive department structures (A→B→A cycles) and support quick-create shortcut that returns the created department ID for inline workflows.

**Why this priority**: Circular hierarchies break organizational logic; quick-create streamlines bulk department setup.

**Independent Test**: Attempt to create circular hierarchy and verify prevention; quick-create department and verify returned ID.

**Acceptance Scenarios**:

1. **Given** department A is parent of B, **When** attempting to set A's parent to B, **Then** system raises validation error: "You cannot create recursive departments."
2. **Given** quick-create initiated with department name "Support", **When** completed, **Then** created department ID is returned and matches saved record.

---

### User Story 4 - Dynamic employee and activity plan access by role (Priority: P1)

HR system must show different employee models (hr.employee vs. hr.employee.public) based on user access and provide department-aware activity plan actions with context defaults.

**Why this priority**: Role-based access control ensures privacy; department context defaults speed up activity planning.

**Independent Test**: Access departments as HR user (full access) and non-HR user (public access); verify correct models and actions shown.

**Acceptance Scenarios**:

1. **Given** an HR user with hr.employee read access, **When** opening employees from department, **Then** action targets `hr.employee` with list/kanban/form views.
2. **Given** a non-HR user without hr.employee read access, **When** opening employees from department, **Then** action targets `hr.employee.public`.

---

### User Story 5 - Automatic manager reassignment and hierarchy navigation (Priority: P2)

HR managers must be able to change department manager and have subordinates automatically reassigned; view child departments and full hierarchy with employee counts.

**Why this priority**: Manager changes must cascade to maintain reporting lines; hierarchy views enable org planning.

**Independent Test**: Change department manager; verify employee manager assignments update; navigate child departments; view hierarchy with counts.

**Acceptance Scenarios**:

1. **Given** department "Engineering" with manager "Alice" and employees reporting to her, **When** manager changed to "Bob", **Then** employees in department hierarchy are reassigned to Bob.
2. **Given** department with child departments, **When** opening child departments action, **Then** kanban/list shows all descendants with name "Child departments".

---

### Edge Cases

- Circular hierarchy validation must catch multi-level cycles (A→B→C→A).
- Complete name search must handle special characters and slashes correctly.
- Company inheritance: child department company cannot differ from parent.
- Quick-create returns ID even if created in batch context.
- Manager reassignment only affects employees in that department hierarchy, not other departments.
- Department without explicit parent: no parent shown in hierarchy.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST default `company_id` to current company context when department is created without explicit company.
- **FR-002**: System MUST set `active = True` by default when department is created.
- **FR-003**: System MUST compute `complete_name` by concatenating parent path with department name using " / " separator.
- **FR-004**: System MUST automatically copy `company_id` from parent department to child department when child is created.
- **FR-005**: System MUST support `name_create()` method that returns the created department ID for quick-create workflows.
- **FR-006**: System MUST support searching departments by `complete_name` using `ilike` pattern matching.
- **FR-007**: System MUST support searching departments by `complete_name` using `=ilike` with wildcard patterns.
- **FR-008**: System MUST prevent creation of circular department hierarchies (A→B→A) and raise validation error "You cannot create recursive departments."
- **FR-009**: System MUST validate circular hierarchies across multi-level chains (A→B→C→A).
- **FR-010**: System MUST provide action to open employees of department; target model based on user access (`hr.employee` for HR users, `hr.employee.public` for non-HR).
- **FR-011**: System MUST provide action to view child departments with kanban/list views named "Child departments".
- **FR-012**: System MUST support returning full hierarchy (parent, self, children) with employee counts at each level.
- **FR-013**: System MUST provide activity plan action with `default_department_id` in context.
- **FR-014**: System MUST automatically reassign employees to new manager when department manager is changed.
- **FR-015**: System MUST ensure employee action domain filters to department and child departments when opened from department view.

### Key Entities *(include if feature involves data)*

- **hr.department**: attributes include `name`, `parent_id`, `complete_name` (computed), `company_id`, `manager_id`, `active`, `child_ids` (inverse).
- **hr.employee**: attributes include `department_id`, `parent_id` (manager), automatically updated when department manager changes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Department creation with automatic company context succeeds in 100% of cases where company is in context.
- **SC-002**: Complete name computation is correct for multi-level hierarchies in 100% of department creations.
- **SC-003**: Circular hierarchy detection succeeds in 100% of attempted cycles (both 2-level and multi-level).
- **SC-004**: Department quick-create returns correct ID in 100% of quick-create invocations.
- **SC-005**: Complete name search (ilike) returns correct results in 100% of queries.
- **SC-006**: Employee action targets correct model (`hr.employee` vs. `hr.employee.public`) in 100% of user scenarios.
- **SC-007**: Child departments action displays all descendants in 100% of queries.
- **SC-008**: Manager reassignment cascades to all employees in affected hierarchy within 2 seconds in 95% of updates.
- **SC-009**: Hierarchy view with employee counts is computed accurately in 100% of queries.

## Assumptions

- Parent/child relationships are managed via `parent_id` foreign key; Odoo handles inverse relationships via `child_ids`.
- Complete name is a computed field; database storage is optional (computed on retrieval).
- Company inheritance is enforced: child department company_id must match parent (constraint).
- Quick-create uses standard Odoo `name_create()` mechanism; returns tuple (id, name) or equivalent.
- User access is determined by ACL on `hr.employee` model; non-HR users default to `hr.employee.public`.
- Manager reassignment is a business rule: when department manager changes, all direct employees in that department have parent_id updated.
- Activity plans are optional; department may have zero, one, or many linked activity plans.
- Hierarchy depth is unlimited; system should handle recursion prevention at any level.
