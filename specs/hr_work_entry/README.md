# HR Work Entry Specifications (Gherkin/BDD Format)

This directory contains comprehensive Gherkin-based BDD specifications for the HR Work Entry module (`hr.work.entry` model in `hr_work_entry` addon).

## Specification Files

### 1. [01_work_entry_management.feature](01_work_entry_management.feature)
**Purpose**: Work entry creation and management for attendance/payroll integration
- Create work entries for different types (normal, sick, vacation, etc.)
- Duration validation (must be positive, max 24 hours)
- Work entry state transitions (draft → validated)
- Conflict detection and resolution
- Auto-assign employee version based on date
- Batch work entry generation
- Link to contracts and versions
- Track work entry source
- Compute display names
- Bulk operations

**Key Scenarios**: 28 scenarios for work entry management

### 2. [02_work_entry_generation_and_types.feature](02_work_entry_generation_and_types.feature)
**Purpose**: Work entry generation, validation, and type configuration
- Work entry existence and opening actions
- Generate and regenerate work entries
- Display name and name computation
- Duration validation and conflict handling
- Split and reset operations
- Work entry type constraints and defaults
- Cron-based missing work entry generation

**Key Scenarios**: 19 scenarios for work entry generation and types

### 3. [03_work_entry_source_and_recompute.feature](03_work_entry_source_and_recompute.feature)
**Purpose**: Work entry source configuration and recompute workflows
- Work entry source validation
- Default work entry type lookup
- Template value whitelisting
- Attendance and leave interval generation
- Flexible and static schedule handling
- Work entry generation post-processing
- Removal, cancelation, and recompute flows
- Cron regeneration of missing work entries

**Key Scenarios**: 19 scenarios for source and recompute workflows

---

## Statistics

- **Total Specification Files**: 3
- **Total Scenarios**: 66
- **Coverage Areas**: Work entries, Work Entry Types, Generation Jobs, Source Configuration, Recompute Flows

## Module Overview

The `hr_work_entry` module manages work entry generation and tracking for attendance and payroll integration:
- **Work Entries**: Record of what work employees did each day (hours, type, dates)
- **Work Entry Types**: Normal work, sick leave, vacation, unpaid leave, holidays
- **Generation**: Automatic generation from attendance and leave records
- **Validation**: Conflict detection and state management
- **Integration**: Feeds data to payroll module for salary calculation

## Key Features

### Work Entry Types
- **Normal Work**: Standard paid working hours
- **Sick Leave**: Paid sick time
- **Paid Leave**: Vacation and PTO
- **Unpaid Leave**: Unpaid absences
- **Public Holiday**: Company holidays
- Custom types based on company needs

### Work Entry States
- **draft**: New entry, not yet validated
- **conflict**: Overlapping entries with other work
- **validated**: Confirmed for payroll
- **cancelled**: Removed from payroll

### Work Entry Attributes
- **date**: The date of work
- **duration**: Hours worked (0 < duration ≤ 24)
- **employee_id**: Employee who worked
- **version_id**: Contract/version at that date
- **work_entry_type_id**: What type of work
- **amount_rate**: Pay rate for this entry
- **state**: Current state (draft/conflict/validated/cancelled)

### Work Entry Data Integration
- **date**: The date of work
- **duration**: Hours worked (0 < duration ≤ 24)
- **employee_id**: Employee who worked
- **version_id**: Contract/version at that date
- **work_entry_type_id**: What type of work
- **amount_rate**: Pay rate for this entry
- **state**: Current state (draft/conflict/validated)

## Workflows

### Standard Work Entry Generation
1. Attendance data collected (via check-in/check-out)
2. Leave records approved
3. Work entries generated automatically (calendar-based or attendance-based)
4. Work entries validated for conflicts
5. Validated work entries feed into payroll calculation

### Overtime Processing
1. Overtime hours detected from work entries
2. Work entries marked with overtime type
3. Payroll module applies overtime rate calculation

### Recompute Workflows
1. Contract date changes trigger work entry update
2. Calendar changes trigger work entry regeneration
3. Missing work entries filled by cron
4. Boundaries updated based on contract period
4. Generate final payslip
5. Adjust for salary advances

## Access Control

Different roles have permissions:
- **Employees**: View own payslips with masked details
- **HR Manager**: Create and manage work entries
- **Payroll Manager**: Generate and approve payslips
- **Accountant**: Review and process payments
- **Admin**: Full system access

## Integration Points

- **HR Attendance**: Auto-generate work entries from check-in/out
- **HR Leave**: Create work entries for approved leaves
- **HR Contracts**: Determine applicable salary rules
- **HR Department**: Department tracking for cost allocation
- **Accounting**: Journal entry posting for payroll

## Related Files

- Work Entry Model: `/odoo/addons/hr_work_entry/models/hr_work_entry.py`
- Work Entry Type: `/odoo/addons/hr_work_entry/models/hr_work_entry_type.py`
- Views: `/odoo/addons/hr_work_entry/views/`
- Tests: `/odoo/addons/hr_work_entry/tests/`

## Payroll Modules

- `hr_payroll`: Payslip generation and salary rules
- `hr_payroll_expense`: Expense handling in payroll
- `hr_work_entry`: Work entry management (foundation)
- `hr_work_entry_holidays`: Integration with leave

---

**Created**: 2025-01-15
**Format**: Gherkin/BDD
**Scope**: HR Work Entry Module (hr_work_entry) and Payroll System
