# Phase 1: Data Model Design

**Feature**: Employee Attendance Check-In and Check-Out  
**Date**: 2026-05-11  
**Status**: In Progress  
**Basis**: Research decisions from research.md

---

## Entities & Data Model

### 1. Entity: `hr.attendance` (Extended via _inherit)

**Odoo Model**: `hr.attendance`  
**Module Scope**: `hrm_attendance_extension`  
**Inheritance**: `_inherit = 'hr.attendance'`

#### Existing Fields (from Odoo core)
| Field | Type | Description | Business Rule |
|-------|------|-------------|-----------------|
| `employee_id` | many2one (hr.employee) | Employee reference | Required; unique active employee |
| `check_in` | datetime | Check-in timestamp (UTC) | Required; must be before check_out if filled |
| `check_out` | datetime | Check-out timestamp (UTC) | Optional; NULL = open attendance |
| `worked_hours` | float | Computed: (check_out - check_in) / 3600 | Automatic; recomputed on write |

#### New Fields (Extension)

| Field | Type | Mandatory | Default | Description | Validation |
|-------|------|-----------|---------|-------------|------------|
| **overtime_hours** | Float | N | 0.0 | Computed: worked_hours adjusted for OT rate (Formula: max(0, worked_hours - baseline_hours) * ot_multiplier) | ≥ 0 |
| **expected_hours** | Float | N | 8.0 | Daily baseline (from attendance_policy); can be overridden per employee or date | > 0 |
| **event_mode** | Selection | Y | 'manual' | How check-in was triggered: manual (user), automatic (batch job), kiosk (kiosk device) | IN: manual/automatic/kiosk |
| **event_source** | Selection | Y | 'web' | Where check-in originated: web (portal), mobile (app), kiosk, api | IN: web/mobile/kiosk/api |
| **quality_indicator** | Selection | N | 'normal' | Anomaly flag: normal, anomaly (exceeds threshold), stale_checkout (auto-closed), extreme_duration | IN: normal/anomaly/stale_checkout/extreme_duration |
| **employee_timezone** | Char (32) | Y | 'Asia/Ho_Chi_Minh' | Employee local timezone for date attribution and cross-midnight handling | Must be valid pytz timezone |
| **attendance_date** | Date | Y | Computed | Attendance date in employee's local timezone (derived from check_in local time) | Auto-computed from check_in + employee_timezone |
| **ot_multiplier** | Float | N | 1.5 | OT rate multiplier based on day type (weekday/weekend/holiday) | ≥ 1.0 |
| **last_corrected_by** | many2one (hr.employee) | N | NULL | HR officer who last modified this record (for audit) | Only set on manual update |
| **last_corrected_on** | Datetime | N | NULL | Timestamp of last manual correction | Auto-set on write if corrected_by changed |
| **context_metadata_ids** | one2many (hr.attendance.context) | N | [] | Collection of check-in/out event contexts (location, IP, device) | Cascade delete disabled; audit trail preserved |

#### Computed Methods

```python
@api.depends('check_in', 'check_out', 'expected_hours')
def _compute_overtime_hours(self) -> None:
    """
    Calculate overtime hours based on worked duration and policy baseline.
    
    Formula:
      - worked_hours = (check_out - check_in) in hours
      - ot_hours = max(0, worked_hours - expected_hours) * ot_multiplier
      - ot_multiplier derived from day_type (weekday 1.5, weekend 2.0, holiday 3.0) + night bonus (0.3)
    
    Returns: None (writes to overtime_hours field)
    """

@api.depends('check_in', 'employee_timezone')
def _compute_attendance_date(self) -> None:
    """
    Determine attendance date based on employee's local timezone.
    
    Handles cross-midnight case: if check_in local time is before midnight,
    attendance_date = check_in date in employee timezone.
    If check_out exists and is after midnight, same attendance_date.
    
    Returns: None (writes to attendance_date field)
    """

@api.depends('worked_hours', 'expected_hours')
def _compute_quality_indicator(self) -> None:
    """
    Flag records exceeding anomaly thresholds.
    
    Rules:
      - worked_hours > 24h → extreme_duration
      - worked_hours > 20h AND (weekend OR holiday) → anomaly
      - check_out IS NULL AND created_at > 24h ago → stale_checkout (set by batch job)
      - else → normal
    
    Returns: None (writes to quality_indicator field)
    """
```

#### Constraints & Validation

```python
@api.constrains('check_in', 'check_out')
def _check_chronological_order(self) -> None:
    """
    FR-004: Reject any check-out earlier than check-in.
    """
    for record in self:
        if record.check_out and record.check_in:
            if record.check_out < record.check_in:
                raise ValidationError(
                    f"Check-out time ({record.check_out}) cannot be before "
                    f"check-in time ({record.check_in})."
                )

@api.constrains('employee_id', 'check_in')
def _check_no_overlapping_attendance(self) -> None:
    """
    FR-003: Prevent overlapping or duplicate active attendance windows for same employee.
    
    Rule: For each open attendance (check_out IS NULL), only one per employee allowed.
    Closed attendances can overlap (same employee on same day = multiple sessions OK).
    """
    for record in self:
        if not record.check_out:  # Open attendance
            existing = self.search([
                ('employee_id', '=', record.employee_id.id),
                ('check_out', '=', False),
                ('id', '!=', record.id)  # Exclude self
            ])
            if existing:
                raise ValidationError(
                    f"Employee {record.employee_id.name} already has an open attendance. "
                    f"Please check out first."
                )

@api.constrains('employee_timezone')
def _check_valid_timezone(self) -> None:
    """
    Validate employee_timezone is a valid pytz timezone string.
    """
    import pytz
    for record in self:
        try:
            pytz.timezone(record.employee_timezone)
        except pytz.exceptions.UnknownTimeZoneError:
            raise ValidationError(f"Invalid timezone: {record.employee_timezone}")
```

#### Key Methods (Business Logic)

```python
def action_checkin(self) -> dict:
    """
    FR-001: Create new attendance record for check-in.
    
    Called when employee clicks "Check In" button.
    Sets: check_in = NOW(), event_mode = 'manual', event_source from context
    Captures: IP, user-agent, location (if provided)
    
    Returns: Action or success notification
    Raises: ValidationError if employee already has open attendance
    """

def action_checkout(self) -> dict:
    """
    FR-002: Complete active attendance with check-out time.
    
    Called when employee clicks "Check Out" button.
    Finds open attendance (check_out IS NULL), sets check_out = NOW()
    Triggers: compute worked_hours, overtime_hours, quality_indicator
    Captures: context metadata for checkout event
    
    Returns: Action or success notification
    Raises: ValidationError if check-out < check-in (FR-004)
    """

def action_auto_checkout(self) -> None:
    """
    FR-008: Automatic checkout for stale open attendances.
    
    Called by daily batch job (02:00 cron).
    For all open attendances where NOW() - check_in > 24h:
      - Set check_out = NOW()
      - Set event_mode = 'automatic'
      - Set quality_indicator = 'stale_checkout'
      - Create system log entry
    
    Returns: None
    """

def action_correct_time(self, new_check_in: datetime, new_check_out: datetime) -> None:
    """
    FR-007: Manual time correction by HR users.
    
    Updates check_in/check_out to manually corrected values.
    Sets: last_corrected_by = current user, last_corrected_on = NOW()
    Recomputes: worked_hours, overtime_hours, attendance_date
    
    Returns: None
    Raises: ValidationError if correction violates constraints
    """

def _prepare_context_metadata(self) -> dict:
    """
    Prepare context metadata for capture (IP, user-agent, timezone, location).
    
    Called during check-in/check-out to gather contextual data.
    Returns dict with fields: event_source, ip_address, user_agent, gps_lat/lng (if available)
    """
```

---

### 2. Entity: `hr.attendance.context`

**Odoo Model**: `hr.attendance.context`  
**Module Scope**: `hrm_attendance_extension`  
**Inheritance**: models.Model (new)  
**Purpose**: Audit trail for all context data captured during each check-in/out event

#### Fields

| Field | Type | Mandatory | Default | Description | Validation |
|-------|------|-----------|---------|-------------|------------|
| **attendance_id** | many2one (hr.attendance) | Y | - | Reference to parent attendance record | Foreign key |
| **event_type** | Selection | Y | - | Whether this is check_in or check_out context | IN: checkin/checkout |
| **event_timestamp** | Datetime | Y | NOW() | Server timestamp when context was captured (UTC) | Immutable (readonly after create) |
| **event_mode** | Selection | Y | 'manual' | How event was triggered: manual, automatic, kiosk | IN: manual/automatic/kiosk |
| **event_source** | Selection | Y | 'web' | Source of event: web, mobile, kiosk, api | IN: web/mobile/kiosk/api |
| **ip_address** | Char (45) | Y | - | Source IP address (IPv4 or IPv6) | Validated via regex |
| **user_agent** | Text | Y | - | Browser/device User-Agent string | Immutable |
| **gps_latitude** | Float | N | NULL | GPS latitude (if location tracking enabled) | Range: -90 to 90 |
| **gps_longitude** | Float | N | NULL | GPS longitude (if location tracking enabled) | Range: -180 to 180 |
| **location_name** | Char (128) | N | NULL | Human-readable location (e.g., "Hanoi HQ") | HR can tag manually |
| **timezone** | Char (32) | Y | 'Asia/Ho_Chi_Minh' | Employee timezone at time of event | Valid pytz timezone |
| **notes** | Text | N | NULL | Additional context notes (e.g., "Manual correction: time adjusted") | For audit comments |
| **create_date** | Datetime | Automatic | NOW() | Record creation timestamp | Auto |
| **create_uid** | many2one (res.users) | Automatic | Current user | Who created this context record | Auto |

#### Constraints & Validation

```python
@api.constrains('gps_latitude', 'gps_longitude')
def _check_gps_coordinates(self) -> None:
    """
    If GPS data provided, BOTH latitude AND longitude required.
    Partial GPS data rejected.
    """
    for record in self:
        has_lat = record.gps_latitude is not None
        has_lng = record.gps_longitude is not None
        if has_lat != has_lng:  # One set, one not
            raise ValidationError(
                "Both GPS latitude and longitude must be provided together. "
                "Partial GPS data is not allowed."
            )

@api.constrains('ip_address')
def _check_ip_format(self) -> None:
    """
    Validate IP address format (IPv4 or IPv6).
    """
    import re
    ipv4_pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
    ipv6_pattern = r'^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}$'
    for record in self:
        if not (re.match(ipv4_pattern, record.ip_address) or 
                re.match(ipv6_pattern, record.ip_address)):
            raise ValidationError(f"Invalid IP address format: {record.ip_address}")
```

#### Key Methods

```python
@staticmethod
def capture_context_from_request(attendance_record, event_type: str) -> 'hr.attendance.context':
    """
    Create context record from HTTP request (check-in/check-out action).
    
    Automatically extracts:
      - IP address from request
      - User-Agent from request headers
      - Timezone from employee record or request header
      - GPS (if available in request body)
    
    Args:
        attendance_record: hr.attendance instance
        event_type: 'checkin' or 'checkout'
    
    Returns: hr.attendance.context instance (created and saved)
    """
```

---

### 3. New Model: `hr.attendance.policy`

**Odoo Model**: `hr.attendance.policy`  
**Module Scope**: `hrm_attendance_extension`  
**Inheritance**: models.Model (new)  
**Purpose**: Configurable attendance policies (OT rates, baseline hours, auto-checkout threshold)

#### Fields

| Field | Type | Mandatory | Default | Description |
|-------|------|-----------|---------|-------------|
| **name** | Char (64) | Y | - | Policy name (e.g., "Office Staff", "Teaching Staff") |
| **description** | Text | N | - | Policy description for HR reference |
| **baseline_hours** | Float | Y | 8.0 | Standard daily work hours | > 0 |
| **ot_weekday_multiplier** | Float | Y | 1.5 | OT rate for weekday overtime | ≥ 1.0 |
| **ot_weekend_multiplier** | Float | Y | 2.0 | OT rate for weekend work | ≥ 1.0 |
| **ot_holiday_multiplier** | Float | Y | 3.0 | OT rate for public holiday work | ≥ 1.0 |
| **ot_night_bonus** | Float | Y | 0.3 | Night work bonus (22:00-06:00 adds this to multiplier) | ≥ 0 |
| **max_open_duration_hours** | Float | Y | 24.0 | Max allowed open attendance duration before auto-checkout | > 0 |
| **anomaly_threshold_hours** | Float | Y | 20.0 | Worked hours threshold for anomaly flag | > 0 |
| **auto_checkout_enabled** | Boolean | Y | True | Enable automatic checkout of stale records |  |
| **apply_to_employee_ids** | many2many (hr.employee) | N | [] | Employees to apply this policy; if empty, applies as default |  |
| **active** | Boolean | Y | True | Archive this policy |  |

#### Constraints & Validation

```python
@api.constrains('baseline_hours', 'ot_weekday_multiplier', 'max_open_duration_hours')
def _check_positive_values(self) -> None:
    """
    Ensure all numeric thresholds are positive.
    """
    for policy in self:
        if policy.baseline_hours <= 0 or policy.max_open_duration_hours <= 0:
            raise ValidationError("Baseline hours and max open duration must be positive.")
        if policy.ot_weekday_multiplier < 1.0:
            raise ValidationError("OT multiplier must be ≥ 1.0 (no discount).")
```

---

## Relationships & Workflows

### Attendance Lifecycle

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. Employee Click "Check In" (web/mobile)                          │
├─────────────────────────────────────────────────────────────────────┤
│  → action_checkin() called                                           │
│  → Validate: No open attendance exists for employee                 │
│  → Create hr.attendance: check_in = NOW(), event_mode = 'manual'    │
│  → Capture hr.attendance.context (event_type='checkin', IP, GPS...)  │
│  → Return success notification                                      │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 2. Employee works... (time passes)                                  │
├─────────────────────────────────────────────────────────────────────┤
│  Attendance record remains open (check_out IS NULL)                 │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 3a. Employee Click "Check Out" (Normal Case)                        │
├─────────────────────────────────────────────────────────────────────┤
│  → action_checkout() called                                         │
│  → Find open attendance, set check_out = NOW()                      │
│  → Compute: worked_hours, overtime_hours, attendance_date          │
│  → Compute: quality_indicator (normal/anomaly/extreme_duration)    │
│  → Capture hr.attendance.context (event_type='checkout', ...)      │
│  → Trigger payroll recalculation (Phase 2)                          │
│  → Return success notification                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 3b. Automatic Checkout (Stale Record Case)                          │
├─────────────────────────────────────────────────────────────────────┤
│  Daily Cron Job (02:00):                                             │
│  → For all open attendance records:                                  │
│    IF (NOW() - check_in) > max_open_duration_hours:                │
│      • Set check_out = NOW()                                        │
│      • Set event_mode = 'automatic'                                 │
│      • Set quality_indicator = 'stale_checkout'                     │
│      • Create system log entry                                      │
│      • Send HR notification                                         │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 4. HR Officer Manual Correction (Optional)                          │
├─────────────────────────────────────────────────────────────────────┤
│  → HR opens attendance record, edits check_in/check_out times      │
│  → action_correct_time() called                                     │
│  → Validate: corrected check_out >= check_in                        │
│  → Set: last_corrected_by, last_corrected_on                       │
│  → Recompute: worked_hours, overtime, quality_indicator            │
│  → Create audit trail context record                                │
│  → Trigger payroll recalculation                                    │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 5. Payroll Integration (Phase 2)                                    │
├─────────────────────────────────────────────────────────────────────┤
│  → Payroll module reads hr.attendance records                       │
│  → Uses overtime_hours, expected_hours for salary rules             │
│  → Applies BHXH treatment (OT hours count in contribution base)     │
│  → Generates payslip                                                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## ACL & Security Model

**Security Access Matrix** (per research.md RT-003):

| Model | Group | Create | Read | Write | Delete | Notes |
|-------|-------|--------|------|-------|--------|-------|
| **hr.attendance** | Employee | ✓ (own) | ✓ (own) | ✗ | ✗ | Via portal; row-level check on employee_id |
| **hr.attendance** | HR Officer | ✓ (any) | ✓ (any) | ✓ (any) | ✗ | Full operational access; no delete |
| **hr.attendance** | HR Manager | ✓ (any) | ✓ (any) | ✓ (any) | ✓ (any) | Can delete for data cleanup (rare) |
| **hr.attendance.context** | Employee | ✗ | ✓ (own) | ✗ | ✗ | Read-only audit trail |
| **hr.attendance.context** | HR Officer | ✗ | ✓ (any) | ✗ | ✗ | Read-only audit trail |
| **hr.attendance.policy** | HR Officer | ✓ | ✓ | ✓ | ✓ | Manage policies |
| **hr.attendance.policy** | HR Manager | ✓ | ✓ | ✓ | ✓ | Manage policies |
| **hr.attendance.policy** | Employee | ✗ | ✓ | ✗ | ✗ | View current policy |

**Groups to Create**:
1. `group_hr_attendance_employee`: Employees (check-in/out via portal)
2. `group_hr_attendance_officer`: HR officers (corrections, audit)
3. `group_hr_attendance_manager`: HR manager (full control)

---

## Integration Points

### Upstream Dependencies
- **hr.employee**: Reference to employee; used for timezone, contract, department
- **hr.department**: For department-level reporting, manager approvals
- **resource.calendar**: For public holiday detection, shift schedules (Phase 2)

### Downstream Integration (Phase 2+)
- **hr.payroll.structure** + **hr.salary.rule**: OT hours passed to payroll calculation
- **hr.leave**: Cross-check with leave records (no check-in expected on leave day)
- **hr.contract**: Current contract determines OT eligibility, policy applicability
- **account.move / account.invoice**: Payroll output exported to Finance

---

## Phase 1 Complete ✓

Data model defined with:
- ✓ 3 models: hr.attendance (extended), hr.attendance.context (new), hr.attendance.policy (new)
- ✓ Computed fields: overtime_hours, expected_hours, attendance_date, quality_indicator
- ✓ Constraints: chronological validation, overlap prevention, GPS validation
- ✓ ACL matrix: 3 user groups with role-based access
- ✓ Audit trail: context metadata captured per event
- ✓ Business logic methods: check-in, check-out, auto-checkout, manual correction

Ready for **Phase 2: Contract Definitions** and **Phase 3: Task Generation**.
