# HR Attendance Business Spec

## Goal
Build production attendance functionality that records employee work presence, detects overtime, and supports rule-based overtime approval and regeneration.

## Primary Users
- Employee
- HR User
- HR Manager
- HR Attendance Officer
- System Administrator

## Core Business Capabilities

### Attendance tracking
- Record check-in and check-out events.
- Calculate worked hours.
- Track presence state and last activity.
- Support kiosk, systray, manual, technical, and automatic check-out flows.

### Overtime management
- Detect overtime from attendance.
- Show overtime state on the attendance record.
- Support overtime approval and refusal.
- Keep validated overtime hours separate from raw overtime hours.
- Allow overtime conversion into time off or pay depending on policy.

### Overtime rules
- Configure rulesets per company and country.
- Combine multiple overtime rules using max or sum.
- Support quantity-based and timing-based rules.
- Regenerate overtime records for affected attendances.

### Operational outcomes
- Employees can check in and check out reliably.
- HR can understand who worked, for how long, and under what conditions.
- Overtime can be validated according to company policy.
- Recalculation can be triggered when configuration changes.

## Acceptance Criteria
- Attendance records must not overlap for the same employee.
- Check-out cannot be earlier than check-in.
- Overtime must be derivable from linked overtime lines.
- Approved and refused overtime must update attendance aggregates.
- Overtime ruleset regeneration must only touch eligible attendances.
- Manager validation logic must respect company policy and user role.
- Rules and rulesets must be configurable without corrupting existing attendance data.
