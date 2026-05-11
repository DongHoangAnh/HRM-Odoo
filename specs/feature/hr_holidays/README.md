# HR Leave (Holiday) Specifications (Gherkin/BDD Format)

This directory contains comprehensive Gherkin-based BDD specifications for the HR Leave module (`hr.leave` model in `hr_holidays` addon).

## Specification Files

### 1. [01_leave_requests_management.feature](01_leave_requests_management.feature)
**Purpose**: Leave request creation and approval workflows
- Create vacation and sick leave requests
- Half-day and hourly leave requests
- Leave balance validation
- Single and multi-level approval workflows
- Manager and HR approval processes
- Refusal and cancellation
- Calendar integration
- Private leave notes
- Balance computation

**Key Scenarios**: 25 scenarios for leave request management

### 2. [02_leave_allocation_balance.feature](02_leave_allocation_balance.feature)
**Purpose**: Leave allocation and balance management
- Create annual leave allocations
- Valid allocation checks
- Allocation deduction on leave approval
- Multiple allocations per employee
- Allocation expiry dates
- Carryover to next year with limits
- Unlimited leave types
- Virtual remaining leaves computation
- Allocation validation workflow

**Key Scenarios**: 18 scenarios for allocation and balance management

### 3. [03_leave_accrual_plans.feature](03_leave_accrual_plans.feature)
**Purpose**: Accrual plan configuration and milestone actions
- Accrual plan creation and default naming
- Company and leave type linkage
- Employee and milestone counting
- Carryover date calculation
- Open employees and milestone actions
- Copy and deletion protection

**Key Scenarios**: 12 scenarios for accrual plan management

### 4. [04_employee_time_off_dashboard.feature](04_employee_time_off_dashboard.feature)
**Purpose**: Employee leave status and dashboard behavior
- Current leave detection
- Leave status computation
- Presence state on leave
- Allocation counters and balance display
- Leave manager sync from hierarchy
- Time off dashboard and calendar actions

**Key Scenarios**: 11 scenarios for dashboard and status

### 5. [05_leave_type_configuration.feature](05_leave_type_configuration.feature)
**Purpose**: Leave type configuration and validation
- Leave type defaults
- Valid allocation lookup
- Allocation requirement and negative cap checks
- Public holiday inclusion validation
- Accrual eligibility
- Dashboard visibility rules

**Key Scenarios**: 11 scenarios for leave type configuration

### 6. [06_accrual_level_rules.feature](06_accrual_level_rules.feature)
**Purpose**: Accrual level scheduling, caps, and transition dates
- Sequence computation from start count and unit
- Milestone creation vs after behavior
- Added value type propagation
- Monthly and yearly day clamping
- Frequency validation
- Carryover and accrual cap constraints
- Next and previous date calculations
- Level transition date computation

**Key Scenarios**: 19 scenarios for accrual level rules

---

## Statistics

- **Total Specification Files**: 6
- **Total Scenarios**: 96
- **Coverage Areas**: Leave requests, Approvals, Balance management, Allocations, Accrual Plans, Accrual Levels, Dashboard Status, Leave Type Validation

## Module Overview

The `hr_leave` module (part of `hr_holidays`) manages employee time off including:
- **Leave Types**: Different types (vacation, sick, personal, etc.) with different rules
- **Leave Requests**: Employees request time off, managers approve
- **Allocations**: HR assigns leave budgets to employees
- **Approval Workflows**: Single or multi-level approval based on configuration
- **Balance Tracking**: Virtual remaining leaves accounting for used and pending requests
- **Calendar Integration**: Automatic calendar events for approved leaves

## Key Features

### Leave Types
- **Requires Allocation**: Some types require pre-allocated days (vacation)
- **No Allocation Needed**: Some types unlimited (sick leave)
- **Validation Types**: Single approval, HR approval, or two-level approval
- **Units**: Days or hours

### Leave Request States
- **confirm**: Pending approval
- **validate1**: Waiting for second approval (in two-level workflow)
- **validate**: Fully approved
- **refuse**: Rejected by approver
- **cancel**: Cancelled by requester

### Approval Rules
- **Employees**: Can only manage own leaves
- **Managers**: Can approve leaves from their subordinates
- **HR Officers**: Can approve HR validation leaves
- **Cannot approve own leaves**: Self-approval is not allowed

### Balance Calculation
- **max_leaves**: Total allocated days
- **virtual_remaining_leaves**: Allocated - Used - Pending = Available
- **Deduction on approval**: Reduces available balance
- **No deduction for refused**: Refused leaves don't affect balance

## Access Control

Different roles have different permissions:
- **Regular Employee**: See all leaves (with name privacy), manage own
- **Officer/Manager**: Validate leaves from team members
- **HR Manager**: Full control over all leaves

## Related Files

- Model: `/odoo/addons/hr_holidays/models/hr_leave.py`
- Leave Type: `/odoo/addons/hr_holidays/models/hr_leave_type.py`
- Views: `/odoo/addons/hr_holidays/views/`
- Tests: `/odoo/addons/hr_holidays/tests/`

## Common Workflows

### Standard Leave Request
1. Employee creates leave request
2. Manager receives notification
3. Manager approves/refuses
4. Employee notified
5. Balance updated if approved

### Two-Level Approval
1. Employee creates leave request
2. Manager approves (state → validate1)
3. HR approves (state → validate)
4. Balance deducted

### Annual Leave Allocation
1. HR creates allocation (draft)
2. HR validates allocation
3. Employee sees balance increase
4. Employee can now request up to allocated days

---

**Created**: 2025-01-15
**Format**: Gherkin/BDD
**Scope**: HR Leave Module (hr_holidays.hr_leave)
