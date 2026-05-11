# Attendance Record API Contract

**Module**: `hrm_attendance_extension`  
**Version**: 1.0.0  
**Stability**: Draft (Phase 1)  
**Consumers**: HR Portal, Payroll Module, Reporting System, Mobile App

---

## Overview

This contract defines the interface for creating, reading, updating, and deleting attendance records (check-in/check-out). The interface supports employee self-service check-in/out, HR corrections, automated checkout, and audit trail capture.

---

## Check-In Operation

### Request

```python
POST /api/attendance/checkin

{
    "employee_id": 1234,                          # Required: Odoo employee record ID
    "event_source": "mobile",                     # Required: web | mobile | kiosk | api
    "gps_latitude": 21.0285,                      # Optional: GPS latitude
    "gps_longitude": 105.8542,                    # Optional: GPS longitude
    "location_name": "Hanoi HQ",                  # Optional: human-readable location
}
```

### Response (Success: 201 Created)

```python
{
    "status": "success",
    "attendance_id": 5678,                        # New hr.attendance record ID
    "employee_name": "Nguyen Van A",
    "check_in": "2026-05-11T08:30:00+07:00",     # ISO 8601 with timezone
    "event_mode": "manual",
    "context_id": 9101,                           # hr.attendance.context ID
    "message": "Check-in recorded successfully."
}
```

### Response (Error: 400 Bad Request)

```python
{
    "status": "error",
    "error_code": "DUPLICATE_OPEN_ATTENDANCE",
    "message": "Employee already has an open attendance. Please check out first.",
    "details": {
        "existing_check_in": "2026-05-11T08:00:00+07:00",
        "suggested_action": "Call checkout first"
    }
}
```

### Error Codes

| Error Code | HTTP Status | Description | Resolution |
|------------|-------------|-------------|------------|
| `DUPLICATE_OPEN_ATTENDANCE` | 400 | Employee already has open check-in | Call checkout first |
| `INVALID_EMPLOYEE` | 404 | Employee ID not found or archived | Verify employee exists and is active |
| `INVALID_GPS_PARTIAL` | 400 | Only latitude or only longitude provided | Provide both or neither |
| `INVALID_TIMEZONE` | 400 | Invalid timezone in request | Use pytz timezone string (e.g., "Asia/Ho_Chi_Minh") |
| `PERMISSION_DENIED` | 403 | User not in group_hr_attendance_employee | Check user permissions |
| `INTERNAL_ERROR` | 500 | Server error during record creation | Check logs; retry after delay |

---

## Check-Out Operation

### Request

```python
POST /api/attendance/checkout

{
    "attendance_id": 5678,                        # Required: hr.attendance record ID
    "event_source": "mobile",                     # Required: web | mobile | kiosk | api
    "gps_latitude": 21.0285,                      # Optional: GPS latitude
    "gps_longitude": 105.8542,                    # Optional: GPS longitude
}
```

### Response (Success: 200 OK)

```python
{
    "status": "success",
    "attendance_id": 5678,
    "employee_name": "Nguyen Van A",
    "check_in": "2026-05-11T08:30:00+07:00",
    "check_out": "2026-05-11T17:45:00+07:00",
    "worked_hours": 9.25,
    "overtime_hours": 1.375,                      # (9.25 - 8) * 1.5
    "expected_hours": 8.0,
    "quality_indicator": "normal",
    "context_id": 9102,                           # hr.attendance.context ID for checkout
    "message": "Check-out recorded successfully."
}
```

### Response (Error: 400 Bad Request)

```python
{
    "status": "error",
    "error_code": "CHECKOUT_BEFORE_CHECKIN",
    "message": "Check-out time cannot be before check-in time.",
    "details": {
        "check_in": "2026-05-11T08:30:00+07:00",
        "check_out": "2026-05-11T08:15:00+07:00"
    }
}
```

### Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `ATTENDANCE_NOT_FOUND` | 404 | Attendance record ID not found |
| `NOT_OPEN_ATTENDANCE` | 400 | Record already has check-out (not open) |
| `CHECKOUT_BEFORE_CHECKIN` | 400 | Check-out time is before check-in time |
| `EMPLOYEE_MISMATCH` | 400 | Authenticated employee doesn't match attendance employee |
| `PERMISSION_DENIED` | 403 | User not authorized for this record |

---

## Read Attendance Record

### Request (Get Single Record)

```python
GET /api/attendance/{attendance_id}

# Optional query params:
# include_context=true  (include context_metadata_ids details)
```

### Response (Success: 200 OK)

```python
{
    "status": "success",
    "attendance": {
        "id": 5678,
        "employee_id": 1234,
        "employee_name": "Nguyen Van A",
        "check_in": "2026-05-11T08:30:00+07:00",
        "check_out": "2026-05-11T17:45:00+07:00",
        "worked_hours": 9.25,
        "overtime_hours": 1.375,
        "expected_hours": 8.0,
        "attendance_date": "2026-05-11",
        "quality_indicator": "normal",
        "event_mode": "manual",
        "employee_timezone": "Asia/Ho_Chi_Minh",
        "ot_multiplier": 1.5,
        "last_corrected_by": null,
        "last_corrected_on": null,
        "context_metadata_ids": [
            {
                "id": 9101,
                "event_type": "checkin",
                "event_timestamp": "2026-05-11T08:30:00+07:00",
                "event_source": "mobile",
                "ip_address": "203.162.1.100",
                "user_agent": "MobileApp/1.0 (Android)",
                "gps_latitude": 21.0285,
                "gps_longitude": 105.8542,
                "location_name": "Hanoi HQ"
            },
            {
                "id": 9102,
                "event_type": "checkout",
                "event_timestamp": "2026-05-11T17:45:00+07:00",
                "event_source": "mobile",
                "ip_address": "203.162.1.100",
                "user_agent": "MobileApp/1.0 (Android)",
                "gps_latitude": 21.0286,
                "gps_longitude": 105.8543,
                "location_name": "Hanoi HQ"
            }
        ]
    }
}
```

### Request (List with Filters)

```python
GET /api/attendance/list

# Query params:
# employee_id={id}           # Filter by employee
# start_date={YYYY-MM-DD}    # Filter attendance_date >= start_date
# end_date={YYYY-MM-DD}      # Filter attendance_date <= end_date
# open_only=true             # Only open records (check_out IS NULL)
# quality_indicator={normal|anomaly|stale_checkout}
# limit=100                  # Pagination
# offset=0
```

### Response (List: 200 OK)

```python
{
    "status": "success",
    "count": 150,
    "total": 500,              # Total matching records
    "records": [
        { ... },               # Attendance record 1
        { ... }                # Attendance record 2
    ]
}
```

---

## Update (Manual Correction)

### Request

```python
PUT /api/attendance/{attendance_id}

{
    "check_in": "2026-05-11T08:00:00+07:00",     # Optional: corrected check-in
    "check_out": "2026-05-11T18:00:00+07:00",    # Optional: corrected check-out
    "reason": "Clock malfunction; corrected based on badge swipes"  # Required for audit
}
```

### Response (Success: 200 OK)

```python
{
    "status": "success",
    "attendance_id": 5678,
    "corrected_fields": ["check_in", "check_out"],
    "new_worked_hours": 10.0,
    "new_overtime_hours": 2.0,
    "last_corrected_by": "HR Officer - Tran Thi B",
    "last_corrected_on": "2026-05-11T14:30:00+07:00",
    "message": "Attendance record corrected successfully."
}
```

### Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `INVALID_TIME_ORDER` | 400 | Corrected check-out < check-in |
| `PERMISSION_DENIED` | 403 | Only HR Officer/Manager can correct |
| `REASON_REQUIRED` | 400 | Audit reason must be provided |

---

## Delete Operation

**Policy**: Delete allowed only for HR Manager (rare data cleanup scenarios).

### Request

```python
DELETE /api/attendance/{attendance_id}

{
    "reason": "Duplicate record created by system error"  # Required reason
}
```

### Response (Success: 204 No Content)

### Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `PERMISSION_DENIED` | 403 | Only HR Manager can delete |
| `REASON_REQUIRED` | 400 | Deletion reason must be provided |

---

## Data Types & Validations

### Timezone String

- Format: pytz timezone identifier (e.g., "Asia/Ho_Chi_Minh", "UTC", "Asia/Bangkok")
- Default: "Asia/Ho_Chi_Minh" (Vietnam)
- Validation: Must be valid in pytz.all_timezones

### Datetime Format

- ISO 8601 with timezone offset: `2026-05-11T08:30:00+07:00`
- Always convert to employee's local timezone in response
- Internally stored in UTC (server timezone)

### Quality Indicator

| Value | Meaning | Threshold |
|-------|---------|-----------|
| `normal` | No anomalies detected | worked_hours ≤ threshold, record not stale |
| `anomaly` | Exceeds normal parameters | worked_hours > 20h AND (weekend OR holiday) |
| `stale_checkout` | Auto-closed after max open duration | NOW() - check_in > 24h |
| `extreme_duration` | Unusually long duration | worked_hours > 24h (likely data error or system glitch) |

---

## Integration Examples

### Example 1: Employee Mobile Check-In

```javascript
// Mobile app calls check-in
fetch('https://api.hrm.local/api/attendance/checkin', {
    method: 'POST',
    headers: {
        'Authorization': 'Bearer {token}',
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        employee_id: 1234,
        event_source: 'mobile',
        gps_latitude: 21.0285,
        gps_longitude: 105.8542
    })
})
.then(response => response.json())
.then(data => {
    if (data.status === 'success') {
        console.log(`Checked in at ${data.check_in}`);
    } else {
        console.error(data.message);
    }
});
```

### Example 2: HR Portal Manual Correction

```python
# HR officer corrects time via portal form
attendance = self.env['hr.attendance'].browse([5678])
attendance.action_correct_time(
    new_check_in=datetime(2026, 5, 11, 8, 0),
    new_check_out=datetime(2026, 5, 11, 18, 0)
)
# System automatically:
# - Updates check_in, check_out
# - Recomputes worked_hours, overtime_hours, attendance_date
# - Sets last_corrected_by, last_corrected_on
# - Triggers hr.attendance.context creation for audit
# - Notifies payroll module for recalculation
```

### Example 3: Payroll Module Integration

```python
# Payroll reads attendance for salary calculation
attendance_records = self.env['hr.attendance'].search([
    ('employee_id', '=', employee.id),
    ('attendance_date', '>=', payroll_start_date),
    ('attendance_date', '<=', payroll_end_date),
    ('check_out', '!=', False)  # Only closed records
])

for attendance in attendance_records:
    # Use worked_hours, overtime_hours, expected_hours in salary rule calculation
    gross_ot_amount = attendance.overtime_hours * employee.hourly_rate * ot_multiplier
```

---

## Versioning & Breaking Changes

**Current Version**: 1.0.0 (Draft)

**Future Compatibility**:
- New optional fields added → backward compatible (ignore unknown fields)
- New error codes → clients should handle `default` case
- Field removal → will increment MAJOR version; 6-month deprecation notice

---

## Phase 1 Complete ✓

Attendance API contract defined with:
- ✓ Check-in/check-out operations with validation
- ✓ Read operations (single + list with filters)
- ✓ Manual correction workflow
- ✓ Delete policy (HR Manager only)
- ✓ Error codes and resolution guidance
- ✓ Integration examples (mobile, HR portal, payroll)
