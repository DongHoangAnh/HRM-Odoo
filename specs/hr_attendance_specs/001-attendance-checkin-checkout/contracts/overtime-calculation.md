# Overtime Calculation Contract

**Module**: `hrm_attendance_extension`  
**Version**: 1.0.0  
**Stability**: Draft (Phase 1)  
**Consumers**: Payroll Module, Attendance Reports, Compliance Audits

---

## Overview

This contract defines how overtime (OT) hours are calculated based on worked duration, employee policy baseline, day classification (weekday/weekend/holiday), and time-of-day (night work bonus). The calculation must comply with Vietnamese Labor Law 2019 (Bộ luật Lao động 2019, Articles 98-102) and support payroll integration.

---

## Calculation Formula

### Base Formula

```
overtime_hours = max(0, worked_hours - baseline_hours) × ot_multiplier
```

### Components

1. **worked_hours**: Decimal hours calculated from (check_out - check_in) in UTC
   - Example: 9 hours 15 minutes = 9.25 hours

2. **baseline_hours**: Standard daily work hours (default 8, configurable per attendance policy)
   - Office staff: typically 8 hours
   - Teaching staff: may vary per contract

3. **ot_multiplier**: Multiplier based on day type + time-of-day

---

## OT Multiplier Determination

### Day Classification

```
┌─────────────────────────────────────────────────────────────┐
│ Attendance Date Classification                              │
├─────────────────────────────────────────────────────────────┤
│ 1. Regular weekday (Mon-Fri, non-holiday)  → 1.5x          │
│ 2. Weekend (Sat-Sun)                        → 2.0x          │
│ 3. Public holiday (per Vietnamese calendar) → 3.0x          │
│ 4. Night work bonus (22:00-06:00)           → +0.3x         │
└─────────────────────────────────────────────────────────────┘
```

### Night Work Detection

- **Night Period**: 22:00 (10 PM) to 06:00 (6 AM) in employee's local timezone
- **Application**: If ANY part of worked duration falls during night period
- **Bonus**: Add 0.3 multiplier on top of day-type multiplier

### Combined Multiplier Examples

```
Weekday (8:00-18:00):
  Base multiplier = 1.5x
  No night work
  Final multiplier = 1.5x
  OT = (9 - 8) × 1.5 = 1.5 hours

Weekend with night work (22:00-06:00):
  Base multiplier = 2.0x
  Night work included = +0.3x
  Final multiplier = 2.3x
  OT = (8 - 8) × 2.3 = 0 hours (no OT if within baseline)

Holiday + night work (20:00-04:00):
  Base multiplier = 3.0x
  Night work included = +0.3x
  Final multiplier = 3.3x
  OT = (8 - 8) × 3.3 = 0 hours (if within baseline)

Weekday + night work (23:00-07:00 = 8 hours):
  Base multiplier = 1.5x
  Night work included = +0.3x
  Final multiplier = 1.8x
  OT = (8 - 8) × 1.8 = 0 hours (if exactly baseline)
```

---

## Vietnamese Public Holiday Calendar

**Integration**: System reads from Odoo `resource.calendar.leaves` model (holiday records)

### Major Vietnamese Holidays (Non-exhaustive)

```
Jan 1:          New Year's Day
Feb (lunar):    Lunar New Year (Tết) - 3-5 days off
Apr 30:         Reunification Day
May 1:          International Labor Day
Sep 2:          National Day
Varies:         Additional holidays per company policy or government announcement
```

### Holiday Determination Logic

```python
def is_public_holiday(attendance_date: date, company_id: int) -> bool:
    """
    Check if attendance_date is a public holiday.
    
    Looks up resource.calendar.leaves for company's calendar.
    If date falls on any leave record, return True.
    """
    leaves = self.env['resource.calendar.leaves'].search([
        ('calendar_id.company_id', '=', company_id),
        ('date_from', '<=', attendance_date),
        ('date_to', '>=', attendance_date)
    ])
    return bool(leaves)
```

---

## Calculation Algorithm (Pseudocode)

```python
def compute_overtime_hours(
    check_in: datetime,
    check_out: datetime,
    employee_timezone: str,
    baseline_hours: float,
    attendance_date: date
) -> float:
    """
    Compute overtime hours per Vietnamese Labor Law.
    
    Args:
        check_in: Check-in timestamp (UTC)
        check_out: Check-out timestamp (UTC)
        employee_timezone: Employee's local timezone (e.g., "Asia/Ho_Chi_Minh")
        baseline_hours: Standard daily work hours (default 8.0)
        attendance_date: Date of attendance (in employee's local timezone)
    
    Returns:
        overtime_hours: Decimal hours (≥0)
    """
    # Step 1: Calculate worked hours
    worked_hours = (check_out - check_in).total_seconds() / 3600
    
    # Step 2: Convert timestamps to employee's local timezone
    tz = pytz.timezone(employee_timezone)
    check_in_local = check_in.astimezone(tz)
    check_out_local = check_out.astimezone(tz)
    
    # Step 3: Determine day type
    if is_public_holiday(attendance_date):
        day_type = "holiday"
        base_multiplier = 3.0
    elif attendance_date.weekday() in [5, 6]:  # Saturday = 5, Sunday = 6
        day_type = "weekend"
        base_multiplier = 2.0
    else:
        day_type = "weekday"
        base_multiplier = 1.5
    
    # Step 4: Check for night work (22:00-06:00)
    night_start = time(22, 0)
    night_end = time(6, 0)
    
    has_night_work = False
    if check_in_local.time() >= night_start or check_out_local.time() <= night_end:
        has_night_work = True
    elif night_end < check_in_local.time() < night_start:
        # No night work if entirely between 06:00-22:00
        has_night_work = False
    else:
        has_night_work = True  # Spans across midnight into night period
    
    # Step 5: Apply night work bonus
    ot_multiplier = base_multiplier
    if has_night_work:
        ot_multiplier += 0.3
    
    # Step 6: Calculate OT hours
    overtime_hours = max(0, worked_hours - baseline_hours) * ot_multiplier
    
    return round(overtime_hours, 2)
```

---

## Example Calculations

### Example 1: Regular Weekday (No OT)

```
Date: 2026-05-11 (Monday)
Check-in: 08:00 (Asia/Ho_Chi_Minh)
Check-out: 16:00 (Asia/Ho_Chi_Minh)
Worked: 8 hours
Baseline: 8 hours

Day type: Weekday → base_multiplier = 1.5x
Night work: No (08:00-16:00 all in daylight)
Final multiplier: 1.5x

Calculation:
  overtime_hours = max(0, 8 - 8) × 1.5 = 0 hours
  
Result: 0 hours OT ✓
```

---

### Example 2: Weekday with Overtime

```
Date: 2026-05-11 (Monday)
Check-in: 08:00
Check-out: 18:30
Worked: 10.5 hours
Baseline: 8 hours

Day type: Weekday → base_multiplier = 1.5x
Night work: No (08:00-18:30 ends before 22:00)
Final multiplier: 1.5x

Calculation:
  overtime_hours = max(0, 10.5 - 8) × 1.5 = 2.5 × 1.5 = 3.75 hours
  
Result: 3.75 hours OT
Expected salary impact: 3.75 hrs × hourly_rate × 1.5 (OT premium) = overtime_pay
```

---

### Example 3: Weekday with Night Work

```
Date: 2026-05-11 (Monday)
Check-in: 20:00
Check-out: 04:00 (next day)
Worked: 8 hours
Baseline: 8 hours

Day type: Weekday (attendance date based on check-in date 2026-05-11)
         → base_multiplier = 1.5x
Night work: Yes (20:00-04:00 crosses night period 22:00-06:00)
         → night_bonus = +0.3x
Final multiplier: 1.5 + 0.3 = 1.8x

Calculation:
  overtime_hours = max(0, 8 - 8) × 1.8 = 0 hours
  
Result: 0 hours OT (exactly baseline), but night work bonus applies to salary
        Night bonus typically paid separately: 8 hrs × hourly_rate × 0.3 = night_bonus_pay
```

---

### Example 4: Weekend OT

```
Date: 2026-05-12 (Saturday)
Check-in: 09:00
Check-out: 18:00
Worked: 9 hours
Baseline: 8 hours

Day type: Weekend → base_multiplier = 2.0x
Night work: No (09:00-18:00 all daylight)
Final multiplier: 2.0x

Calculation:
  overtime_hours = max(0, 9 - 8) × 2.0 = 1 × 2.0 = 2.0 hours
  
Result: 2.0 hours OT
Salary impact: 2 hrs × hourly_rate × 2.0 = weekend_ot_pay
```

---

### Example 5: Public Holiday with Night Work

```
Date: 2026-04-30 (Reunification Day - public holiday in Vietnam)
Check-in: 21:00 on 2026-04-30
Check-out: 05:00 on 2026-05-01
Worked: 8 hours
Baseline: 8 hours

Day type: Public Holiday → base_multiplier = 3.0x
         (attendance date = 2026-04-30, despite check-out on 05-01)
Night work: Yes (21:00-05:00 crosses night period)
         → night_bonus = +0.3x
Final multiplier: 3.0 + 0.3 = 3.3x

Calculation:
  overtime_hours = max(0, 8 - 8) × 3.3 = 0 hours OT
  
But holiday rates apply: 8 hrs × hourly_rate × 3.0 (holiday premium)
Plus night bonus: 8 hrs × hourly_rate × 0.3 (night premium)
Total: 8 hrs × hourly_rate × 3.3

Result: 0 hours OT (no excess), but holiday + night rates applied to salary
```

---

### Example 6: Extreme Duration (Anomaly)

```
Date: 2026-05-11 (Monday)
Check-in: 08:00 on 2026-05-11
Check-out: 09:00 on 2026-05-12
Worked: 25 hours
Baseline: 8 hours

Day type: Weekday (based on check-in date 2026-05-11) → base_multiplier = 1.5x
Night work: Yes (spans 22:00-06:00 period) → night_bonus = +0.3x
Final multiplier: 1.8x

Calculation:
  overtime_hours = max(0, 25 - 8) × 1.8 = 17 × 1.8 = 30.6 hours
  
Quality indicator: EXTREME_DURATION (worked > 24h)
  
Result: 30.6 hours OT (flagged as anomaly)
Audit note: "Check if employee forgot to check out; system auto-closed after 24h"
```

---

## Integration with Payroll

### Payroll Data Contract

When payroll module processes an attendance record:

```python
{
    "attendance_id": 5678,
    "worked_hours": 9.25,
    "overtime_hours": 3.75,
    "expected_hours": 8.0,
    "ot_multiplier": 1.5,
    "day_type": "weekday",
    "has_night_work": False,
    "baseline_hours": 8.0
}
```

### Salary Rule Application

**Payroll Side** (Phase 2 implementation):

```python
# In hr.salary.rule for "OT Pay"
OT_hours = record['overtime_hours']                      # 3.75
OT_multiplier = record['ot_multiplier']                  # 1.5
hourly_rate = employee.hourly_rate                       # e.g., 100,000 VND
ot_pay = OT_hours × hourly_rate × (OT_multiplier - 1.0)  # 3.75 × 100k × 0.5 = 187,500 VND

# Night work bonus (if applicable)
if record['has_night_work']:
    night_bonus = record['worked_hours'] × hourly_rate × 0.3
```

### BHXH Treatment

- **OT hours count toward BHXH contribution base** per Vietnamese law
- `overtime_hours` included in gross income for BHXH calculation
- Contribution rate: ~17.5% (employee) + 17.5% (employer)

---

## Edge Cases & Special Handling

### Cross-Midnight Attendance

```
Check-in: 23:30 on 2026-05-11
Check-out: 00:30 on 2026-05-12

Attended hours: 1 hour
Attendance date: 2026-05-11 (based on check-in local time)
Day type: Weekday (2026-05-11 is Monday)

Even though check-out is on next day, attendance date remains 2026-05-11.
OT calculation uses day type of check-in date.
```

### Timezone Boundary

```
Company timezone: UTC (server)
Employee timezone: Asia/Ho_Chi_Minh (UTC+7)

UTC time:        2026-05-11 14:00:00 UTC
Local time:      2026-05-11 21:00:00 (Ho Chi Minh)

For OT calculation, use local time (21:00) to determine if night work applies.
```

### Zero-Duration Attendance

```
Check-in: 08:00
Check-out: 08:00
Worked: 0 hours

overtime_hours = max(0, 0 - 8) × 1.5 = 0 hours

Quality indicator: ANOMALY (likely data entry error)
```

---

## Recalculation Triggers

OT is recalculated automatically when:

1. **Check-out recorded**: After employee checks out, overtime_hours computed
2. **Manual time correction**: HR corrects check-in/check-out times
3. **Holiday calendar update**: If attendance date is reclassified as public holiday
4. **Policy change**: If baseline_hours or multipliers changed for employee (affects future periods)

**Never backdate OT recalculation** without explicit HR approval + audit trail entry.

---

## Precision & Rounding

- **Storage**: Decimal(10, 2) - allows up to 99999999.99 hours
- **Display**: 2 decimal places (e.g., 3.75 hours)
- **Calculation**: Use exact decimal arithmetic (not float) to avoid precision loss
- **Rounding Rule**: Round to 2 decimals (standard Vietnamese accounting practice)

---

## Validation & Constraints

### Before Calculation

```python
assert worked_hours >= 0, "Worked hours cannot be negative"
assert baseline_hours > 0, "Baseline hours must be positive"
assert ot_multiplier >= 1.0, "OT multiplier must be ≥ 1.0"
```

### Result Validation

```python
assert overtime_hours >= 0, "OT hours cannot be negative (use max() to ensure)"
assert overtime_hours <= worked_hours * 3.3, "OT hours implausible (max holiday night = 3.3x)"
```

---

## Compliance & Audit

### Legal References

- **Bộ luật Lao động 2019** (Vietnam Labor Code 2019)
  - Article 98: OT definition and compensation
  - Article 99: OT rates and limits
  - Article 100: Night work bonuses
  - Article 101: Time accumulation and compensation
- **BHXH Directive 595/2015**: OT hours count toward BHXH base

### Audit Trail

Every OT calculation must preserve:
- Original check-in/check-out times
- Baseline hours applied
- Day type classification
- Multiplier breakdown (day_type + night_bonus)
- Resulting OT hours

If corrected: Store both original and corrected OT values with timestamp of correction.

---

## Phase 1 Complete ✓

OT calculation contract defined with:
- ✓ Formula and components
- ✓ Day classification (weekday/weekend/holiday)
- ✓ Night work bonus (22:00-06:00)
- ✓ Multiplier combination logic
- ✓ Vietnamese public holiday integration
- ✓ Detailed calculation algorithm (pseudocode)
- ✓ 6 worked examples (normal, OT, night, weekend, holiday, extreme)
- ✓ Payroll integration contract
- ✓ BHXH treatment rules
- ✓ Edge cases (cross-midnight, timezone boundary)
- ✓ Recalculation triggers
- ✓ Legal compliance references
