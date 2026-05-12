# Feature Specification: Employee Time Off Dashboard and Status

**Feature Branch**: `004-employee-time-off-dashboard`  
**Created**: May 11, 2026  
**Status**: Draft  
**Input**: Employee Time Off Dashboard and Status - As an Employee or HR user I want to see my time off status and dashboard data So that I can understand leave balances and current absences

## User Scenarios & Testing

### User Story 1 - Display Current Leave Status (Priority: P1)

Employees and HR users need to view their current leave status, including which leave is active today, dates of the leave period, and relevant status information. The system computes current_leave_id, leave_date_from, leave_date_to, current_leave_state, and is_absent fields to populate dashboard views.

**Why this priority**: Critical for transparency. Employees must know if they're on leave and HR must see absence status for operational planning. Viewed in dashboard, mobile apps, and absence reports.

**Independent Test**: Can be tested by creating an approved leave spanning today's date, checking that current_leave_id points to that leave, and verifying leave dates are populated. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with a validated leave spanning today's date, **When** current_leave_id is computed, **Then** it is set to the ID of the validated leave covering today.

2. **Given** an employee with a validated leave, **When** leave status is computed, **Then** leave_date_from and leave_date_to are populated with the leave's start/end dates, current_leave_state shows "validate", and is_absent is True (for absence-type leaves).

3. **Given** multiple validated leaves for the same employee in different periods, **When** current_leave_id is computed at a specific date, **Then** the system returns the leave overlapping that date (only one if non-overlapping leaves are enforced, or the earliest if multiple).

4. **Given** an employee with no current leave, **When** current_leave_id is computed, **Then** it is null/empty.

---

### User Story 2 - Track Presence State Based on Leave Status (Priority: P1)

The system must automatically update the employee's presence state to "absent" when they have a validated absence-type leave active. This enables accurate attendance tracking and helps managers understand real-time employee availability without manual updates.

**Why this priority**: Essential for attendance accuracy and operational visibility. Prevents manual absence marking and ensures leave status drives presence state automatically.

**Independent Test**: Can be tested by creating absence leave, checking that hr_presence_state updates to "absent", ending leave, and verifying state reverts. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee on a validated absence-type leave (e.g., vacation, sick leave), **When** presence state is computed, **Then** hr_presence_state is set to "absent".

2. **Given** an employee not on any leave (or only on non-absence types), **When** presence state is computed, **Then** hr_presence_state is "present" (or default state).

3. **Given** a leave that ends today, **When** presence state is computed after the leave end time, **Then** the employee transitions back to "present" status.

4. **Given** multiple overlapping leaves where at least one is absence-type, **When** presence state is computed, **Then** hr_presence_state is "absent".

---

### User Story 3 - Display Leave Balance Information (Priority: P1)

Employees need to see their allocation balances and remaining leave days. The system computes allocation_display (total allocated days) and allocation_remaining_display (balance minus consumed) from the employee's allocations and approved leaves.

**Why this priority**: Critical for employees to plan time off and for HR to understand utilization. Most frequently viewed metric on employee leave dashboards.

**Independent Test**: Can be tested by creating allocation (20 days), approving leaves (5 days consumed), checking allocation_display (20) and allocation_remaining_display (15). Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with a validated allocation of 20 days and 5 days of approved leaves, **When** allocation_display and allocation_remaining_display are computed, **Then** allocation_display = 20 and allocation_remaining_display = 15.

2. **Given** an employee with multiple allocations (10 + 10 days), **When** allocation_display is computed, **Then** it shows the aggregate total (20 days).

3. **Given** an employee with allocations and pending leave requests, **When** allocation_remaining_display is computed, **Then** it reflects both approved deductions and pending projected usage (virtual remaining).

4. **Given** an employee with expired or invalid allocations, **When** allocation counters are computed, **Then** only active validated allocations are included in the total.

---

### User Story 4 - Count Valid Allocations (Priority: P2)

The system must compute allocation_count and allocations_count fields that show the number of distinct valid (non-expired, non-cancelled) allocations the employee has. This provides visibility into allocation complexity and is used in list views and dashboards.

**Why this priority**: Useful metric for dashboards and analytics. Less frequently viewed than remaining balance but important for HR reporting. Straightforward computation.

**Independent Test**: Can be tested by creating allocations (valid/expired/cancelled), computing count, and verifying only valid ones are included. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with 3 validated allocations and 2 expired allocations, **When** allocation_count is computed, **Then** it equals 3 (expired allocations excluded).

2. **Given** an employee with allocations in different states ("validate", "confirm", "refuse"), **When** allocation_count is computed, **Then** only "validate" state allocations are counted.

3. **Given** an employee with no allocations, **When** allocation_count is computed, **Then** it equals 0.

---

### User Story 5 - Control Dashboard Visibility by Role (Priority: P1)

The system must display leave information to authorized users only: HR users with hr_holidays group permission and the employee viewing their own record. The show_leaves computed field controls whether leave information is visible in dashboards and list views.

**Why this priority**: Security and privacy control. Must prevent employees from seeing colleagues' leave, and prevent non-HR from accessing aggregated leave reports.

**Independent Test**: Can be tested by logging in as different user roles (HR vs non-HR), checking show_leaves field, and verifying visibility. Works independently.

**Acceptance Scenarios**:

1. **Given** a user with hr_holidays group membership, **When** show_leaves is computed, **Then** it is True and all employee leave information is visible.

2. **Given** an employee viewing their own record, **When** show_leaves is computed, **Then** it is True and they see their personal leave information.

3. **Given** a non-HR user viewing another employee's record, **When** show_leaves is computed, **Then** it is False and leave information is hidden.

4. **Given** a manager viewing an employee report, **When** show_leaves is computed, **Then** it respects the delegation (if manager has leave approval rights, they can see delegated employee leaves).

---

### User Story 6 - Search for Absent Employees (Priority: P2)

HR users need to search for employees who are currently absent (on validated leaves) to understand who is unavailable for meetings, support, or operations. The system provides a search/filter mechanism that returns employees with active validated leaves covering the specified date.

**Why this priority**: Useful operational tool for HR and managers. Helps with scheduling and coverage planning. Moderately common use case.

**Independent Test**: Can be tested by creating leaves spanning today, running absent employee search, and verifying correct employees are returned. Works independently.

**Acceptance Scenarios**:

1. **Given** one employee on a validated absence leave today and another with no leave today, **When** "absent employees" search is executed for today, **Then** only the absent employee is returned.

2. **Given** multiple employees on leave, **When** absent employee search is filtered by date range, **Then** only employees with leaves overlapping that range are included.

3. **Given** an employee on a validated leave that is not absence-type (e.g., unpaid leave that doesn't affect presence), **When** absent employee search is executed, **Then** the behavior depends on whether unpaid leave counts as "absent" (configurable per leave type).

---

### User Story 7 - Link Leave Manager to Employee Manager (Priority: P2)

Leave manager relationships should follow organizational hierarchy: the employee's leave_manager_id should be automatically set based on their parent_id (manager) in the employee record. This ensures leave approval routes follow reporting lines.

**Why this priority**: Essential for consistent organizational structure. However, automatic derivation is relatively simple and can be configured via standard Odoo conventions.

**Independent Test**: Can be tested by setting employee's parent_id, verifying leave_manager_id auto-updates to match. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with no parent_id assigned, **When** the parent_id is set to a manager, **Then** leave_manager_id is automatically updated to that manager.

2. **Given** an employee with an existing leave_manager_id, **When** the parent_id is changed to a different manager, **Then** leave_manager_id updates to follow the new parent.

3. **Given** an employee record, **When** the parent_id is cleared (set to empty), **Then** leave_manager_id is also cleared.

4. **Given** a manager overriding the automatic leave_manager_id to a different user, **When** the parent_id changes, **Then** the manual override is respected and leave_manager_id does not auto-update (if override support is enabled).

---

### User Story 8 - Open Employee Time Off Dashboard (Priority: P3)

Employees should be able to open a dedicated time-off dashboard view showing their leave status, balance, current absence, and upcoming time off. The action opens a dashboard filtered to show only the current employee's information.

**Why this priority**: User experience enhancement. Provides a dedicated dashboard that could be embedded in employee portal or accessible via employee menu. Not critical for core functionality but improves usability.

**Independent Test**: Can be tested by opening own employee record dashboard, verifying it displays leave data, and confirming action returns the dashboard view. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee accessing their own profile, **When** the "Time Off Dashboard" action is clicked, **Then** the system opens an employee dashboard view showing their leave status and balance.

2. **Given** an HR user or manager accessing an employee's profile, **When** the "Time Off Dashboard" action is clicked, **Then** the dashboard shows that employee's information (if permission allows).

3. **Given** an employee with no leave history, **When** the dashboard is opened, **Then** it displays zero balance/allocation information clearly instead of errors.

---

### User Story 9 - Open Time Off Calendar View (Priority: P3)

Employees and HR users should be able to view their time off on a calendar, filtered by employee and optionally by date range. The action provides a calendar view of leave records for the selected employee, helping visualize leave distribution and plan around absences.

**Why this priority**: Useful visualization tool. Calendar views are standard in HR systems but not critical for core functionality. Enhances planning and visibility.

**Independent Test**: Can be tested by opening calendar action, verifying leaves are displayed, and checking that domain filters to correct employee. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with time off records, **When** the "Time Off Calendar" action is opened, **Then** all approved leaves for that employee are displayed on the calendar.

2. **Given** a calendar action for an employee, **When** the view is rendered, **Then** the calendar defaults to the current year and hides/minimizes the employee name field (since context is clear from filtered data).

3. **Given** the calendar action, **When** the domain is applied, **Then** only leaves for the selected employee are shown; other employees' leaves are not visible.

4. **Given** a calendar view with multiple leave types, **When** displayed, **Then** different leave types are color-coded (consistent with allocation display rules).

---

### Edge Cases

- What happens if an employee has overlapping validated leaves for the same date (should not occur but handle gracefully)?
- How should the system handle timezones when determining "current leave" near midnight?
- What occurs if leave dates span multiple calendar years (should reflect correctly in both years)?
- How are manager changes handled mid-leave if the manager is involved in approval?
- What is the behavior if an allocation is retroactively deleted after a leave has been deducted?

## Requirements

### Functional Requirements

- **FR-001**: System MUST compute current_leave_id by identifying any validated leave (state = "validate") whose date range includes the current date/time; if multiple leaves cover the same date (edge case), return the earliest or first created.

- **FR-002**: System MUST compute leave_date_from and leave_date_to from the current leave record (if current_leave_id is set); if no current leave, these are null.

- **FR-003**: System MUST compute current_leave_state as the state value of the current leave; typically "validate" if current_leave_id is set.

- **FR-004**: System MUST compute is_absent as True if the current leave is of type "absence" (boolean flag on leave type); False otherwise or if no current leave.

- **FR-005**: System MUST compute hr_presence_state as "absent" when the employee has a validated leave covering the current time and is_absent = True; otherwise "present" (or per custom presence states).

- **FR-006**: System MUST compute allocation_display as the sum of all validated (state = "validate") leave allocations for the employee, aggregating across different allocation periods and leave types.

- **FR-007**: System MUST compute allocation_remaining_display as total_allocations - approved_leaves_deducted, reflecting the employee's current available balance (virtual remaining leaves).

- **FR-008**: System MUST compute allocation_count as the number of distinct validated leave allocations; expired allocations are excluded, cancelled allocations are excluded.

- **FR-009**: System MUST compute show_leaves as True if the current user has hr_holidays group permission OR if the employee being viewed matches the current user (self-access); False otherwise.

- **FR-010**: System MUST restrict leave information visibility based on show_leaves: when False, all leave-related fields and tabs are hidden from view, inaccessible in list views, and excluded from reports.

- **FR-011**: System MUST provide a search/filter for absent employees that returns employees with validated leaves (state = "validate") covering a specified date, including only leaves marked as "absence" type.

- **FR-012**: System MUST link leave_manager_id to the employee's parent_id (manager) through an automatic computed field or formula; updates to parent_id automatically update leave_manager_id.

- **FR-013**: System MUST allow manual override of leave_manager_id if needed (e.g., delegated approval authority); manual override takes precedence over auto-derivation.

- **FR-014**: System MUST provide a "Time Off Dashboard" action that opens an employee-filtered dashboard view showing leave status, balance, current leave, and upcoming time off.

- **FR-015**: System MUST provide a "Time Off Calendar" action that displays a calendar view of the employee's validated leaves, filtered by employee_id and defaulting to the current year.

- **FR-016**: On time-off calendar action, system MUST apply a domain filter that restricts displayed leaves to the selected employee only (invisible to other employees).

- **FR-017**: On time-off calendar action, system MUST hide or minimize the employee name field in the context since the domain already filters by employee.

- **FR-018**: System MUST color-code leave types in calendar and dashboard views according to the leave type's assigned color (consistent with other leave displays).

- **FR-019**: System MUST handle leave date ranges that span calendar years; leave is correctly attributed to both years in annual reports and multi-year analysis.

- **FR-020**: System MUST compute all dashboard fields (current_leave_id, leave dates, allocation totals, presence state) in real-time; updates reflect within 1 second of leave approval state changes.

### Key Entities

- **Employee**: Enhanced with computed leave-status fields. Key computed attributes: current_leave_id, leave_date_from, leave_date_to, current_leave_state, is_absent, hr_presence_state, allocation_display, allocation_remaining_display, allocation_count, show_leaves, leave_manager_id (computed or manual).

- **Leave Request**: Linked to employee; state transitions and approval trigger dashboard recomputation.

- **Leave Allocation**: Linked to employee; used for balance display. Key attributes: number_of_days, state.

- **Leave Type / Holiday Status**: Defines leave properties. Key attributes: is_absent_type (boolean), color (for displays).

- **User**: Determines visibility (show_leaves) based on group permission (hr_holidays) and self-access.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Employees can open time-off dashboard in under 2 seconds and see accurate balance within 1 second of page load.

- **SC-002**: Current leave and presence state are computed accurately for 100% of employees, updating within 1 second of leave state changes.

- **SC-003**: Absence employee search returns correct results (employees with active leaves) for 100% of search queries, completing in under 2 seconds.

- **SC-004**: Leave balance display (allocation_display, allocation_remaining_display) is accurate for 100% of employees, accounting for all valid allocations and approved leaves.

- **SC-005**: Dashboard visibility (show_leaves) correctly enforces access control: leaves hidden from 100% of unauthorized users, visible to 100% of authorized users.

- **SC-006**: Leave manager linkage (leave_manager_id follows parent_id) is maintained for 100% of employees; manual overrides are respected.

- **SC-007**: Calendar view for time-off correctly displays leaves filtered by employee for 100% of employees, with no data leakage between employees.

- **SC-008**: Allocation count (allocation_count field) accurately reflects valid (non-expired, non-cancelled) allocations for 100% of employees.

- **SC-009**: Time-off actions (dashboard, calendar) are available and functional for 100% of eligible users (self-access and HR).

- **SC-010**: Leave status fields are updated in real-time for 100% of leave state transitions, with updates reflected in dashboards within 1 second.

## Assumptions

- **User & Data**: Employee records are linked to user accounts via user_id; leave approvals create/update leave request records; allocations are pre-computed and maintained.

- **Computed Fields**: Current leave determination assumes no overlapping validated leaves (or enforces unique per employee per date); if overlaps exist, system returns consistent result (earliest or first created).

- **Absence Definition**: Leave type has an is_absent_type boolean flag that determines whether it affects presence state; not all leaves mark employee as absent (e.g., unpaid leave might not if configured).

- **Allocation Scope**: Allocations are company-scoped and year-scoped; allocation_display aggregates within the current period or fiscal year (configuration-dependent).

- **Time Zone Handling**: Current date/time comparisons use the employee's or company's configured timezone; dashboard is displayed in user's local timezone.

- **Visibility Permissions**: show_leaves is determined by user group membership (hr_holidays) or self-access; no employee-specific visibility overrides are supported in MVP.

- **Leave Manager Default**: leave_manager_id auto-follows parent_id (manager) unless manually overridden; changing parent_id does not override manual assignment if that feature is enabled.

- **Calendar Display**: Calendar view uses standard leave color-coding; calendar defaults to current year (editable to other years); employee name is minimized since context is known.

- **Real-time Updates**: Dashboard fields are computed on-the-fly when accessed; no separate batch computation. For better performance, computed fields may be cached with short TTL (e.g., 5 seconds).

- **Integration Context**: Dashboard and calendar actions follow standard Odoo action patterns (returning action dict with view mode, model, domain, context); they integrate with existing leave request and allocation records without requiring schema changes.

- **Scope Boundaries**: Timezone complexity and multi-calendar support are simplified for MVP; HR tools like shift management are assumed separate. Custom dashboard widgets are out of scope (use builder or standard views).
