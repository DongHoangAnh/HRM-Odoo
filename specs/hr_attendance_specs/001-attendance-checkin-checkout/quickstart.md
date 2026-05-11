# Quick Start Guide: Employee Attendance Check-In/Check-Out

**Module**: `hrm_attendance_extension`  
**Target Audience**: Developers, HR Users, System Administrators  
**Version**: 1.0.0 (Draft)

---

## Overview (30 seconds)

The attendance module enables employees to check in/out (record work hours), automatically calculates overtime per Vietnamese law (1.5x weekday, 2x weekend, 3x holiday), captures context metadata (location, device, IP), and provides HR tools for manual corrections and audit trails.

**Key Fact**: Overtime includes night work bonus (22:00-06:00 → +0.3 multiplier) and respects Vietnamese public holidays.

---

## For Employees: How to Check In/Out

### Web Portal

1. Open HR Portal (URL: https://hrm.local/hr)
2. Click **"Check In"** button (top-right dashboard)
3. Confirm location pop-up (if GPS enabled) or accept auto-detected IP
4. → Record created; system shows "Checked in at 08:30"

### Later: Check Out

1. Click **"Check Out"** button (top-right, replaces "Check In")
2. System calculates:
   - Worked hours: 9 hours 15 minutes
   - Overtime: 1.375 hours (1.5 hrs × 1.5 multiplier)
3. → Record closed; context metadata captured

### Mobile App

- Same flow as web, but with auto-detected GPS coordinates (if permission granted)
- Offline mode: Check-in queued and synced when online

---

## For HR Officers: Daily Workflow

### 1. Monitor Attendance Status

**Menu**: HR → Attendance → Attendance Records

- **View Open Records**: Filter by `Quality Indicator = stale_checkout` to find employees who forgot to check out
- **View Daily Summary**: Dashboard shows today's check-ins, no-shows, OT flagged
- **Auto-Closed Records**: Nightly batch job (02:00) closes records open > 24 hours; HR receives email summary

### 2. Correct Manually

**Scenario**: Employee's clock was slow; need to adjust

1. Open attendance record
2. Click **"Correct Time"** button
3. Enter new check-in/check-out times
4. **Mandatory**: Enter reason (e.g., "Clock malfunction per badge verification")
5. Save → System recomputes worked_hours, OT, sets `last_corrected_by` field

### 3. Review Context Metadata

1. Open attendance record
2. Expand **"Event Details"** section
3. See check-in/check-out context:
   - **IP Address**: Where from (office network, mobile 4G, etc.)
   - **GPS**: Geolocation if mobile app
   - **Device**: Browser or app type
   - **Timezone**: Employee's local timezone

### 4. Handle Anomalies

| Quality Indicator | Action |
|---|---|
| **normal** | No action needed ✓ |
| **anomaly** | Review (unusual hours); ask employee for explanation |
| **stale_checkout** | Auto-closed by system after 24h; verify if legitimate |
| **extreme_duration** | Likely data error; investigate and correct |

---

## For Managers: Reports & Analytics

### Overtime Report (Monthly)

**Menu**: HR → Attendance → Overtime Summary

```
Department: Engineering
Month: May 2026

Employee          | Worked Hours | Baseline | OT Hours | OT Rate | OT Cost
Nguyen Van A      | 162          | 160      | 3.0      | 1.5x    | 450,000 VND
Tran Thi B        | 175          | 160      | 22.5     | mixed   | 3,375,000 VND
...
Total OT for dept | 2,340 hours  |          | 127.5    |         | 19.1M VND
```

### Anomaly Dashboard

- Filter by Quality Indicator = "anomaly" or "extreme_duration"
- Drill-down to see employee's recent pattern
- Bulk action: "Request explanation from employee"

---

## For System Admins: Setup & Configuration

### 1. Create Attendance Policy

**Menu**: HR → Settings → Attendance Policies

```
Name: Office Staff
Baseline Hours: 8.0
OT Weekday Multiplier: 1.5
OT Weekend Multiplier: 2.0
OT Holiday Multiplier: 3.0
Night Work Bonus: 0.3
Max Open Duration: 24 hours
Anomaly Threshold: 20 hours
Auto-Checkout Enabled: Yes ✓
Apply To: [All employees using this office]
```

### 2. Set Up Access Groups

1. **Menu**: Settings → Users & Permissions → Groups
2. Create/update groups:
   - `group_hr_attendance_employee`: Self-service check-in/out
   - `group_hr_attendance_officer`: Full read/write, corrections
   - `group_hr_attendance_manager`: Full control + delete

3. **Assign to roles**:
   ```
   Employees → group_hr_attendance_employee
   HR Officers → group_hr_attendance_officer
   HR Managers → group_hr_attendance_manager
   ```

### 3. Configure Cron Job (Auto-Checkout)

**Menu**: Settings → Automation → Scheduled Jobs

```
Name: Attendance Auto-Checkout
Model: hr.attendance
Method: action_auto_checkout()
Schedule: Daily at 02:00 (early morning, low traffic)
Enabled: Yes ✓
```

**What it does at 02:00**:
- Finds all open attendance records (check_out IS NULL)
- For records where NOW() - check_in > 24 hours:
  - Sets check_out = NOW()
  - Sets event_mode = "automatic"
  - Flags quality_indicator = "stale_checkout"
  - Sends HR Officer summary email

### 4. Integrate with Payroll (Phase 2)

When payroll module is deployed:
- Payroll reads `overtime_hours` field from attendance
- Applies OT rates per salary rules (1.5x for weekday, 2x for weekend, etc.)
- OT hours included in BHXH contribution base

---

## Common Scenarios & Solutions

### Scenario 1: Employee Forgot to Check Out

**Problem**: Record open for 26 hours (stale)

**Solution**:
1. HR system auto-closes at 02:00 (marked "automatic")
2. HR Officer reviews flagged record
3. Opens context metadata to see last IP/GPS location (confirm employee was present)
4. If correct, leave as-is; if wrong, correct manually

### Scenario 2: Clock Malfunction

**Problem**: Employee checked in at 08:20 but clock was 20 min fast

**Solution**:
1. Employee or HR notices discrepancy
2. HR opens record → **Correct Time**
3. Change check_in from 08:20 to 08:00
4. Note: "Clock fast by 20 minutes"
5. System recalculates worked_hours and OT

### Scenario 3: Cross-Midnight Shift

**Problem**: Night shift: 22:00 (Monday) to 06:00 (Tuesday)

**Solution**:
- System uses **check-in date** (Monday) as attendance_date
- Worked hours: 8 hours
- Multiplier: weekday (1.5) + night bonus (0.3) = 1.8x
- OT: max(0, 8 - 8) × 1.8 = 0 hours OT
- But night work bonus applies to salary

### Scenario 4: Public Holiday OT

**Problem**: Employee works on Reunification Day (Apr 30), 9 hours, with night shift (21:00-06:00)

**Solution**:
- Day type: Public Holiday → multiplier = 3.0
- Night work bonus: +0.3
- Final multiplier: 3.3x
- OT: max(0, 9 - 8) × 3.3 = 3.3 hours OT
- Salary: 3.3 hrs × hourly_rate × 3.0 (holiday rate)

### Scenario 5: Anomaly Detection

**Problem**: Record shows 25 hours worked (data error?)

**Solution**:
- System flags quality_indicator = "extreme_duration"
- HR Manager alerted
- Review context metadata (IP, GPS, device) to validate
- If legitimate (employee actually worked long shift), approve
- If error, correct times

---

## Key Business Rules at a Glance

| Rule | Details | Business Impact |
|------|---------|-----------------|
| **No Overlap** | Max 1 open attendance per employee at any time | Prevents accidental duplicates; employee must check out before new check-in |
| **Chronological Validity** | Check-out time ≥ check-in time; no time travel | Prevents data corruption; enforced by system constraint |
| **24h Auto-Close** | Stale records auto-closed nightly; marked as automatic | Prevents indefinite open records; audit trail preserved |
| **OT Calculation** | Weekday 1.5x, Weekend 2x, Holiday 3x, Night +0.3x | Complies with Vietnamese law; supports payroll accuracy |
| **Timezone Attribution** | Attendance date based on employee's local timezone | Handles cross-midnight correctly; fair to employee in different timezone |
| **Immutable Context** | Context records never edited/deleted (audit trail) | Compliance: 10-year retention for labor disputes |

---

## Data Model Quick Ref

### hr.attendance (Extended)
```
- employee_id: Reference to employee
- check_in: Check-in timestamp (UTC)
- check_out: Check-out timestamp (UTC)  [NULL = open]
- worked_hours: Computed hours (check_out - check_in)
- overtime_hours: Computed OT (respects policy + day type + night bonus)
- quality_indicator: normal | anomaly | stale_checkout | extreme_duration
- event_mode: manual | automatic | kiosk
- last_corrected_by: HR person who corrected this record
- last_corrected_on: Timestamp of last correction
- context_metadata_ids: One2Many → context records (immutable audit trail)
```

### hr.attendance.context (Audit Trail)
```
- attendance_id: Parent attendance record
- event_type: checkin | checkout
- event_source: web | mobile | kiosk | api
- ip_address: Network IP
- user_agent: Device/browser identifier
- gps_latitude: Optional GPS
- gps_longitude: Optional GPS
- timezone: Employee's timezone
- notes: Correction reason or comments
[Immutable after creation; one record per check-in/out event]
```

### hr.attendance.policy (Configuration)
```
- baseline_hours: Standard daily hours (default 8)
- ot_weekday_multiplier: 1.5 (default)
- ot_weekend_multiplier: 2.0 (default)
- ot_holiday_multiplier: 3.0 (default)
- ot_night_bonus: 0.3 (default, adds to multiplier)
- max_open_duration_hours: 24 (default auto-close threshold)
- auto_checkout_enabled: True (default)
```

---

## Troubleshooting

### "Employee already has open attendance" error

**Cause**: Employee has an active check-in without check-out

**Solution**:
1. Find open record: HR → Attendance → Filter by employee + open_only=true
2. Either:
   - Employee checks out manually via portal
   - HR manually closes it via **Correct Time** → adjust check_out time

### Check-in button greyed out

**Cause**: Employee doesn't have `group_hr_attendance_employee` permission

**Solution**:
1. Go to Settings → Users & Permissions → Groups
2. Add employee to `group_hr_attendance_employee` group
3. Refresh page; button should activate

### OT calculation seems wrong

**Cause**: Day type classification or night work bonus not applied correctly

**Solution**:
1. Open attendance record
2. Check `quality_indicator` field (should be "normal" for regular shifts)
3. Verify `ot_multiplier` value matches expected:
   - Weekday no-night: 1.5
   - Weekday with night: 1.8
   - Weekend: 2.0
   - Holiday: 3.0
4. If multiplier wrong, verify:
   - Is `attendance_date` correctly classified as public holiday?
   - Does `event_timestamp` fall in night period (22:00-06:00)?

### Context metadata missing GPS

**Cause**: Employee used web portal (no GPS) or mobile GPS permission denied

**Solution**:
- GPS is optional; system doesn't require it
- If needed for location verification, ask employee to use mobile app with GPS enabled
- HR can manually tag `location_name` for reference

---

## Integration Examples

### Integrate with Payroll

```python
# In payroll module (Phase 2)
for attendance in hr.attendance.search([('employee_id', '=', emp), ('check_out', '!=', False)]):
    gross_ot_pay = attendance.overtime_hours * emp.hourly_rate * attendance.ot_multiplier
    payslip.line_ids.create({
        'name': f'OT - {attendance.attendance_date}',
        'salary_rule_id': salary_rule_ot.id,
        'amount': gross_ot_pay
    })
```

### Export for Finance

```python
# Export attendance summary for finance department
report = self.env['hr.attendance'].search([
    ('attendance_date', '>=', '2026-05-01'),
    ('attendance_date', '<=', '2026-05-31'),
    ('check_out', '!=', False)  # Only closed records
])
# Output: CSV with employee, date, hours, OT hours, amount payable
```

---

## Next Steps

### For HR Managers
- [ ] Review existing attendance policy; update multipliers if needed
- [ ] Assign employees to `group_hr_attendance_employee`
- [ ] Assign HR staff to `group_hr_attendance_officer`/`_manager`
- [ ] Test check-in/out on staging environment
- [ ] Plan communication to employees about new system

### For Developers (Phase 2)
- [ ] Implement payroll integration (read `overtime_hours`, apply to salary rules)
- [ ] Build attendance analytics dashboard
- [ ] Add mobile app support (currently web portal only)
- [ ] Integrate with Lark/Slack for notifications

### For Compliance
- [ ] Review context metadata retention policy (10-year archive required)
- [ ] Confirm GPS data handling complies with Vietnamese data protection law
- [ ] Document audit trail procedures for labor disputes

---

## Phase 1 Complete ✓

Quick Start Guide ready for:
- ✓ Employee check-in/out procedures
- ✓ HR daily workflow (monitoring, corrections, anomaly handling)
- ✓ Manager reports & analytics
- ✓ Admin setup & configuration
- ✓ Common scenarios & solutions
- ✓ Business rules summary
- ✓ Data model reference
- ✓ Troubleshooting guide
- ✓ Integration examples
- ✓ Next phase roadmap
