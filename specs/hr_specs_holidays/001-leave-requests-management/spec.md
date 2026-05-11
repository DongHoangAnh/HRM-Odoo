# Feature Specification: Leave Requests Management

**Feature Branch**: `001-leave-requests-management`  
**Created**: May 11, 2026  
**Status**: Draft  
**Input**: Employee Leave Requests and Time Off Management - As an Employee I want to request time off So that I can take breaks and manage my schedule

## User Scenarios & Testing

### User Story 1 - Create and Submit Leave Request (Priority: P1)

An employee needs to request time off by specifying the dates and type of leave. The system should accept the request, validate it against leave balance rules, and prepare it for manager approval. This is the core MVP feature that enables the entire leave management workflow.

**Why this priority**: Without the ability to create leave requests, no other feature in the system works. This is the entry point for all employees and provides immediate value by enabling self-service time-off management.

**Independent Test**: Can be fully tested by creating a leave request with valid dates, verifying it enters "confirm" (draft) state, and confirming it can be submitted for approval. This works independently and delivers the core value of letting employees request time off.

**Acceptance Scenarios**:

1. **Given** an employee with sufficient vacation balance, **When** they create a leave request from 2025-02-01 to 2025-02-05 for "Vacation" type, **Then** the request is created in "confirm" state (draft), a calendar event is automatically created, and the employee can see the request in their list.

2. **Given** a leave request in "confirm" state, **When** the employee submits it for approval, **Then** the state changes to "confirm" (submitted) and approval notifications are sent to the assigned manager(s).

3. **Given** an employee requesting sick leave (which doesn't require allocation), **When** they create the request, **Then** no balance validation occurs and the request is created immediately without checking available days.

4. **Given** a leave request in "confirm" state, **When** the employee attempts to submit it while the dates are in the past, **Then** the system prevents submission with an appropriate error message.

---

### User Story 2 - Manager Approve/Reject Leave Requests (Priority: P1)

Managers need to review and approve or reject employee leave requests with appropriate notifications. This single-level approval workflow handles the majority of leave types and is essential for management oversight.

**Why this priority**: Management approval is a critical control point. Without it, employees could take unlimited time off. This is required for any real-world leave management system and is heavily used daily.

**Independent Test**: Can be tested independently by having a manager receive a pending leave request, approve it (verifying state changes to "validate" and approver is recorded), and confirming the employee receives notification. Works standalone and delivers core management control.

**Acceptance Scenarios**:

1. **Given** a leave request pending manager approval, **When** the manager approves it, **Then** the state changes to "validate" (approved), first_approver_id is set to the manager, and the employee receives a notification.

2. **Given** a leave request pending manager approval, **When** the manager rejects it with reason "Business conflict", **Then** the state changes to "refuse", the reason is recorded, and the employee is notified.

3. **Given** an employee's own leave request pending approval, **When** they attempt to approve it themselves, **Then** the system prevents self-approval with an error message indicating this is not allowed.

4. **Given** a leave request from an employee in a different department, **When** a manager who is not their assigned manager attempts to approve it, **Then** the system prevents approval due to authorization.

---

### User Story 3 - Support Multiple Leave Units (Days, Half-Days, Hours) (Priority: P1)

Employees should be able to request leave in different units depending on leave type capabilities: full days, half-days (morning/afternoon), or specific hours. The system must correctly compute the duration in each unit.

**Why this priority**: Different organization needs require flexibility in how leave is measured. Some employees work hourly shifts, some work standard 8-hour days. Supporting multiple units is essential for systems serving diverse workforces and is expected by modern HR systems.

**Independent Test**: Can be tested by creating three separate leave requests (full-day, half-day, hourly), verifying each computes correctly with the appropriate number_of_days or number_of_hours field set, and confirming each can be approved independently. Works standalone.

**Acceptance Scenarios**:

1. **Given** a leave type that supports daily requests, **When** an employee requests 5 consecutive business days, **Then** number_of_days is set to 5.0 and weekends are automatically excluded.

2. **Given** a leave type that supports half-day requests and the employee has working time scheduled, **When** they request half day (morning only), **Then** number_of_days is set to 0.5 and the system recognizes it as a partial day.

3. **Given** a leave type that supports hourly requests, **When** an employee requests 4 hours, **Then** number_of_hours is set to 4.0 and request_unit_hours flag is set to True.

4. **Given** an approved leave request for 3 days and the employee has 10 days vacation balance, **When** the leave is in "validate" state, **Then** virtual_remaining_leaves is calculated as 7 days.

---

### User Story 4 - Default Leave Balance Validation (Priority: P1)

For leave types that require allocation (vacation, PTO), the system must validate that the employee has sufficient balance before creating the request. This prevents over-allocation and provides transparency to employees.

**Why this priority**: Balance validation is a hard business rule that must be enforced to prevent abuse. Even though some leave types are exempt (sick leave), most require validation. This is non-negotiable from a business perspective.

**Independent Test**: Can be tested by attempting to create a request that exceeds balance (should accept but warn) and verifying a request within balance succeeds without warning. Works independently.

**Acceptance Scenarios**:

1. **Given** an employee with 5 days vacation balance, **When** they request 10 days of vacation (allocation-required type), **Then** a validation warning appears indicating insufficient balance and the message is clear about the shortfall.

2. **Given** an employee with 10 days vacation balance, **When** they request 5 days of vacation, **Then** the request is created successfully with no validation errors.

3. **Given** a leave type marked as "doesn't require allocation" (e.g., Sick Leave), **When** an employee creates a request, **Then** no balance check occurs regardless of their available balance.

---

### User Story 5 - Two-Level Approval Workflow (Priority: P2)

Certain strategic leave types (e.g., sabbaticals, unpaid leave) require approval from both the employee's manager AND an HR officer. The system must enforce sequential approval and prevent skipping levels.

**Why this priority**: Essential for enterprise compliance and high-impact leave decisions, but less frequently used than single-level approval. Enables more rigorous control over sensitive leave types without slowing down routine vacation requests.

**Independent Test**: Can be tested by submitting a two-level leave, having manager approve (transitions to "validate1"), then having HR officer approve (transitions to "validate"). Works independently from single-level workflow.

**Acceptance Scenarios**:

1. **Given** a leave type requiring both Manager and HR approval, **When** an employee submits a leave request, **Then** it initially enters "confirm" (draft) state, awaiting manager review.

2. **Given** a leave request pending manager approval for a two-level leave type, **When** the manager approves it, **Then** the state changes to "validate1" (manager approved) and the system notifies HR for second approval.

3. **Given** a leave in "validate1" state awaiting HR approval, **When** an HR officer approves it, **Then** the state changes to "validate" (fully approved) and second_approver_id is set to the HR officer.

4. **Given** a leave in "validate1" state, **When** an HR officer rejects it, **Then** the state changes to "refuse" regardless of manager's prior approval.

---

### User Story 6 - Compute Leave Duration with Calendar Rules (Priority: P2)

The system must correctly compute leave duration by excluding weekends and company holidays. This ensures employees only use allocated days for actual working days they'll be absent.

**Why this priority**: Accurate calculation is essential for fair leave allocation. Business-critical but depends on having company calendar data. Most organizations have established holiday schedules that can be leveraged.

**Independent Test**: Can be tested by creating leaves that span weekends and/or holidays, verifying computed days exclude non-working days. Works independently.

**Acceptance Scenarios**:

1. **Given** a leave from Monday to Friday (Feb 3-7, 2025), **When** the system computes number_of_days, **Then** it returns 5.0 (excluding the weekend Feb 8-9).

2. **Given** a leave that includes a company holiday (e.g., Feb 17 is Independence Day), **When** the system computes number_of_days for Feb 16-18, **Then** the holiday is not counted in the working days calculation.

3. **Given** a leave request with specific start and end times (hourly unit), **When** the system computes hours, **Then** only hours during the company's standard operating hours are counted.

---

### User Story 7 - Cancel and Reset Approved Leaves (Priority: P2)

Employees with appropriate permissions should be able to cancel approved leaves, and authorized users should be able to reset requests back to draft for re-approval. These actions must handle ledger adjustments correctly.

**Why this priority**: Essential for operational flexibility. Plans change, and employees need to be able to cancel approved leave. Authorized users (managers/HR) need to reset requests for corrections. Moderately common operations.

**Independent Test**: Can be tested by canceling an approved leave (verify state -> "cancel" and balance not deducted) and resetting to draft (verify state -> "confirm" and re-approval required). Works independently.

**Acceptance Scenarios**:

1. **Given** an approved leave (state = "validate"), **When** an employee cancels it, **Then** the state changes to "cancel" and the days are not deducted from the virtual remaining balance.

2. **Given** an approved leave request, **When** an HR officer with reset permissions modifies it and resets it to draft, **Then** the state changes back to "confirm" and re-approval is required.

3. **Given** a canceled leave, **When** the employee's balance is recalculated, **Then** the canceled leave days are restored to their available balance.

---

### User Story 8 - Calendar Integration and Privacy Controls (Priority: P3)

Approved leaves should create calendar events visible to relevant users, and the system should support private leave reasons (e.g., medical details) visible only to HR staff while showing generic labels to others.

**Why this priority**: Enhances user experience and privacy. Calendar integration makes scheduling visible to colleagues. Privacy controls protect sensitive health information. Not critical for MVP but important for production maturity.

**Independent Test**: Can be tested by creating approved leave, checking for calendar event, and verifying private reasons are hidden from non-HR users. Works independently.

**Acceptance Scenarios**:

1. **Given** an approved leave request, **When** a calendar event is created, **Then** it is linked to the leave via meeting_id and displays as "Busy" to protect scheduling availability.

2. **Given** a leave request with private_name "Medical appointment" created by HR staff, **When** an HR officer views it, **Then** the full private_name is visible in reports and records.

3. **Given** the same leave request, **When** a regular employee views the calendar, **Then** they see generic "Time Off" instead of the specific reason.

4. **Given** leaves of different types, **When** displayed in a calendar view, **Then** each leave type is shown in its assigned color for quick visual identification.

---

### Edge Cases

- What happens when an employee requests leave that spans multiple leave allocation cycles or fiscal years?
- How does the system handle weekend-only leave requests (e.g., Friday-Sunday)?
- What occurs when a leave request is created but the leave type is deactivated before approval?
- How should the system behave if multiple managers are assigned to an employee and only one approves?
- What is the state if an employee is terminated while their leave request is pending approval?

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow authenticated employees to create leave requests by specifying leave type, start/end dates or hours, and optional notes.

- **FR-002**: System MUST support multiple leave request units: days (full day, 8 hours), half-days (4 hours), and hourly (specific hour count).

- **FR-003**: For leave types marked as "requires allocation", system MUST validate that the employee has sufficient available balance before creating the request.

- **FR-004**: For leave types marked as "doesn't require allocation" (e.g., Sick Leave), system MUST NOT perform balance validation.

- **FR-005**: System MUST automatically create a calendar event linked to the leave request when the request is created.

- **FR-006**: System MUST compute the number_of_days by excluding weekends based on the employee's working schedule or company-wide resource calendar.

- **FR-007**: System MUST compute the number_of_days by excluding company holidays defined in the resource calendar.

- **FR-008**: System MUST support single-level approval workflow where leave type specifies a required approver and transitions from "confirm" → "validate" upon approval or "confirm" → "refuse" upon rejection.

- **FR-009**: System MUST support two-level approval workflow where leave type specifies two required approvers, enforcing sequential approval: "confirm" → "validate1" (first approver) → "validate" (second approver), or → "refuse" at any level.

- **FR-010**: System MUST prevent employees from approving their own leave requests; approval attempts by the employee in question MUST return an authorization error.

- **FR-011**: System MUST track the first_approver_id and second_approver_id when respective approvers approve the request.

- **FR-012**: System MUST automatically deduct approved leave days (when in "validate" state) from the employee's leave balance, reflected in virtual_remaining_leaves calculation.

- **FR-013**: System MUST allow employees to cancel approved leave requests (state "validate" → "cancel"), preventing deduction from balance.

- **FR-014**: System MUST allow authorized users (HR/managers) to reset approved leave requests back to draft state ("confirm") to require re-approval.

- **FR-015**: System MUST support private_name field on leave requests; if set, HR staff MUST see the actual reason while other employees MUST see only a generic "Time Off" label.

- **FR-016**: System MUST compute virtual_remaining_leaves (max_leaves minus approved leave deductions) for any date or current date.

- **FR-017**: System MUST send notifications to approvers when a leave request is submitted for approval.

- **FR-018**: System MUST send notifications to the employee when their leave request is approved, rejected, or canceled.

- **FR-019**: System MUST support color-coding for different leave types in calendar views to improve visual identification.

- **FR-020**: System MUST allow employees to submit a leave request in draft state ("confirm") for managerial review.

### Key Entities

- **Leave Request**: Core entity representing an employee's time-off request. Key attributes: employee_id, holiday_status_id (leave type), request_date_from, request_date_to, number_of_days, number_of_hours, request_unit_hours (boolean), state (confirm/validate/validate1/refuse/cancel), first_approver_id, second_approver_id, notes, private_name, meeting_id (calendar linkage).

- **Leave Type / Holiday Status**: Defines properties of different leave categories. Key attributes: name (e.g., "Vacation", "Sick Leave"), requires_allocation (boolean), approval_levels (1 or 2), color (for calendar display), pay_frequency.

- **Leave Allocation / Employee Leave Balance**: Tracks how many leave days an employee has for each leave type. Key attributes: employee_id, holiday_status_id, number_of_days (allocated days), date_from, date_to (allocation period). Used to compute available balance.

- **Resource Calendar**: Defines working schedule and company holidays. Key attributes: company-level holidays (dates), employee-level working time schedule (hours per day, week structure).

- **Approver Assignment**: Defines who approves leave requests for a given employee. Key attributes: employee_id, leave_type_id, first_approver_id, second_approver_id (if two-level).

- **Calendar Event**: System record linking leave request to a calendar meeting. Key attributes: leave_request_id, is_busy (true for time-off), event_date_from, event_date_to.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Employees can create a leave request without errors in under 2 minutes (from login to submission).

- **SC-002**: Leave balance validation prevents over-allocation for 100% of leave types requiring allocation—no employee can approve leave exceeding their available balance.

- **SC-003**: 95% of submitted leave requests receive a first-level approval decision within 24 hours of submission.

- **SC-004**: Managers can approve or reject a leave request, with full audit trail (approver ID, timestamp, reason if rejected) recorded for 100% of approvals.

- **SC-005**: Calendar events are created for approved leaves within 1 minute of approval, with 99.5% success rate.

- **SC-006**: Leave duration calculations correctly account for weekends and holidays with 100% accuracy for all leave types.

- **SC-007**: Two-level approval enforces sequential reviews: no second-level approval may occur before first-level approval for 100% of two-level leaves.

- **SC-008**: Private leave reasons ("private_name") are visible to HR staff and hidden from regular employees for 100% of flagged requests.

- **SC-009**: Self-approval prevention blocks employee approval attempts for their own leaves 100% of the time.

- **SC-010**: Canceled leaves correctly restore days to virtual_remaining_leaves calculation with zero financial impact for 100% of cancellations.

## Assumptions

- **User & Data**: Employee records and leave type records already exist in the system; authentication and authorization are managed by the existing Odoo system.

- **Calendar System**: A calendar system (meetings module) is available for integration and can be linked via meeting_id; company resource calendar defining holidays and working hours is maintained separately.

- **Approval Structure**: Each leave type has a defined approval structure (single or two-level) configured in the leave type master; manager-employee relationships are maintained in the organization structure.

- **Leave Allocation**: Employee leave allocations are managed separately and available for balance validation; multi-year or multi-cycle allocations are pre-loaded and accessible.

- **Scope Boundaries**: Leave request modifications (e.g., changing dates) after creation are out of scope for MVP; bulk leave operations or manager-initiated leaves are out of scope for MVP.

- **Timeframe**: Leave requests are assumed to be within a reasonable future window (no backdated requests beyond a configurable threshold); leave requests more than one year in the future may be rejected or flagged.

- **Integration Context**: The system integrates with Odoo's existing leave allocation, resource calendar, and notification modules; external calendar systems (Google Calendar, Outlook) may be supported in future versions but are not in scope for MVP.
