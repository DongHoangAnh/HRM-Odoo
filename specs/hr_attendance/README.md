# HR Attendance Specifications (Gherkin/BDD Format)

This directory contains comprehensive Gherkin-based BDD specifications for the HR Attendance module (`hr.attendance` model).

## Specification Files

### 1. [01_attendance_checkin_checkout.feature](01_attendance_checkin_checkout.feature)
**Purpose**: Check-in and check-out functionality
- Employee check-in with various modes (kiosk, systray, manual)
- GPS location tracking
- IP address and browser tracking
- Check-out procedures and auto-checkout
- Worked hours calculation
- Overtime detection
- Multiple attendance records per day
- Duplicate prevention
- Timezone-aware date computation
- Color coding based on work duration

**Key Scenarios**: 23 scenarios covering check-in/out workflows

### 2. [02_overtime_management.feature](02_overtime_management.feature)
**Purpose**: Overtime tracking and management
- Overtime hours detection
- Overtime approval workflow (to_approve, approved, refused)
- Manual overtime entry
- Overtime compensation (time-off or money)
- Validated overtime hours computation
- Link overtime to attendance
- Multi-day overtime calculations

**Key Scenarios**: 25 scenarios for overtime management

### 3. [03_overtime_rules_and_rulesets.feature](03_overtime_rules_and_rulesets.feature)
**Purpose**: Overtime rule configuration and ruleset regeneration
- Overtime ruleset creation and counting
- Rate combination modes (max, sum)
- Quantity-based overtime rules
- Timing-based overtime rules
- Field validation for rule configuration
- Timing boundary constraints
- Rule information display
- Regenerate overtime records from a ruleset

**Key Scenarios**: 15 scenarios for overtime rules and rulesets

---

## Statistics

- **Total Specification Files**: 3
- **Total Scenarios**: 63
- **Coverage Areas**: Check-in/out, Overtime, Location Tracking, Duration Calculation

## Module Overview

The `hr.attendance` module tracks employee work attendance including:
- **Check-in/Check-out**: Recording when employees start and end work
- **Worked Hours**: Automatic calculation based on check-in and check-out times
- **Overtime Tracking**: Detection and management of hours beyond standard work
- **Location & Device Tracking**: Optional GPS coordinates, IP address, and browser info
- **Check-in Modes**: Support for multiple check-in methods (Kiosk, Systray, Manual, Technical)
- **Automatic Check-out**: Safety mechanism to automatically check out employees after 24 hours

## Key Features

### Check-In/Out Modes
- **Kiosk**: Employee uses kiosk device
- **Systray**: Check-in from system tray notification
- **Manual**: HR user manually enters check-in/out
- **Technical**: System-generated check-in
- **Auto Check-Out**: Automatic after 24 hours

### Location Tracking
- GPS Coordinates (latitude/longitude)
- IP Address recording
- Browser information
- Location name (GPS-based or IP-based)

### Overtime Management
- Automatic overtime detection when worked_hours > expected_hours
- Multi-level overtime approval
- Overtime compensation options (time-off or salary)
- Approved vs. refused overtime tracking

### Work Duration Calculation
- Automatic calculation from check-in/out times
- Timezone-aware date computation
- Expected hours based on working calendar
- Color-coded indicators for duration anomalies

## Related Files

- Model: `/odoo/addons/hr_attendance/models/hr_attendance.py`
- Overtime Models: `/odoo/addons/hr_attendance/models/hr_attendance_overtime*.py`
- Views: `/odoo/addons/hr_attendance/views/`
- Tests: `/odoo/addons/hr_attendance/tests/`

## How to Use These Specs

### For Development
1. Use these specs as requirements for implementing features
2. Each scenario represents a specific behavior that should be tested
3. Follow the Given-When-Then format for clarity

### For Testing
1. Convert scenarios to automated tests
2. Run against the actual `hr.attendance` model
3. Validate all edge cases and workflows

### For Documentation
1. Share specs with stakeholders
2. Use for training HR staff
3. Reference when implementing integrations

---

**Created**: 2025-01-15
**Format**: Gherkin/BDD
**Scope**: HR Attendance Module (hr.attendance)
