# Context Metadata Contract

**Module**: `hrm_attendance_extension`  
**Version**: 1.0.0  
**Stability**: Draft (Phase 1)  
**Consumers**: Audit Trail, Security Monitoring, Location Analytics, Compliance Reporting

---

## Overview

This contract defines the interface for capturing, storing, and retrieving attendance context metadata. Context includes event source, network information, GPS location, device details, and timezone. Each check-in/check-out event generates one context record for audit and compliance purposes.

---

## Context Data Model

### Context Metadata Fields

```python
hr.attendance.context {
    attendance_id: many2one('hr.attendance'),      # Parent attendance record
    event_type: selection,                          # 'checkin' or 'checkout'
    event_timestamp: datetime,                      # Server UTC timestamp
    event_mode: selection,                          # 'manual' | 'automatic' | 'kiosk'
    event_source: selection,                        # 'web' | 'mobile' | 'kiosk' | 'api'
    ip_address: char,                               # IPv4 or IPv6
    user_agent: text,                               # Browser/device User-Agent string
    gps_latitude: float,                            # Optional: latitude
    gps_longitude: float,                           # Optional: longitude
    location_name: char,                            # Optional: human-readable location
    timezone: char,                                 # Employee timezone at event time
    notes: text,                                    # Audit comments (e.g., "Manual correction")
    create_date: datetime,                          # Record creation timestamp (auto)
    create_uid: many2one('res.users')              # Who created context record (auto)
}
```

---

## Event Source Mapping

### Web Portal

**Origin**: Browser-based employee self-service portal  
**Mandatory Fields**:
- `event_source`: "web"
- `ip_address`: Extracted from HTTP request
- `user_agent`: Browser User-Agent from request headers
- `timezone`: Employee's configured timezone (or request header override)

**Optional Fields**:
- GPS (unlikely unless portal accessed from mobile browser; depends on browser permissions)

**Example Context**:
```json
{
    "event_type": "checkin",
    "event_source": "web",
    "event_mode": "manual",
    "ip_address": "203.162.1.100",
    "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "timezone": "Asia/Ho_Chi_Minh",
    "gps_latitude": null,
    "gps_longitude": null,
    "location_name": null
}
```

---

### Mobile Application

**Origin**: Native iOS/Android mobile app  
**Mandatory Fields**:
- `event_source`: "mobile"
- `ip_address`: Device's network interface IP
- `user_agent`: App identifier (e.g., "HRM-App/1.2.0 (Android)")
- `timezone`: Device local timezone

**Optional Fields**:
- `gps_latitude`: GPS from device (if permissions granted)
- `gps_longitude`: GPS from device (if permissions granted)
- `location_name`: HR can tag location post-hoc

**Example Context**:
```json
{
    "event_type": "checkin",
    "event_source": "mobile",
    "event_mode": "manual",
    "ip_address": "192.168.1.101",
    "user_agent": "HRM-App/1.2.0 (Android; Device: SM-G991B)",
    "timezone": "Asia/Ho_Chi_Minh",
    "gps_latitude": 21.028542,
    "gps_longitude": 105.854178,
    "location_name": "Hanoi HQ"
}
```

---

### Kiosk Device

**Origin**: Physical check-in kiosk (face recognition, badge reader, etc.)  
**Mandatory Fields**:
- `event_source`: "kiosk"
- `ip_address`: Kiosk's network IP address
- `user_agent`: Kiosk identifier (e.g., "Kiosk-Model-2000/v2.1")
- `event_mode`: "manual" (user triggered) or "automatic" (kiosk auto-triggered)
- `timezone`: Kiosk's configured timezone

**Optional Fields**:
- GPS (not applicable; kiosk is stationary)
- `location_name`: Physical kiosk location (e.g., "Hanoi HQ - Lobby")

**Example Context**:
```json
{
    "event_type": "checkin",
    "event_source": "kiosk",
    "event_mode": "manual",
    "ip_address": "10.0.1.50",
    "user_agent": "FaceRecognitionKiosk-FR3000/v2.1",
    "timezone": "Asia/Ho_Chi_Minh",
    "location_name": "Hanoi HQ - Lobby",
    "gps_latitude": null,
    "gps_longitude": null
}
```

---

### System Automation (Batch Job)

**Origin**: Automatic checkout cron job (24h+ stale record detection)  
**Mandatory Fields**:
- `event_source`: "api"
- `event_mode`: "automatic"
- `ip_address`: Server IP address
- `user_agent`: "System/AutoCheckout/v1.0"
- `timezone`: Employee's timezone (from hr.attendance record)

**Optional Fields**:
- GPS (not applicable)
- `notes`: "Automatic checkout due to stale record (24h+ open duration)"

**Example Context**:
```json
{
    "event_type": "checkout",
    "event_source": "api",
    "event_mode": "automatic",
    "ip_address": "10.0.0.1",
    "user_agent": "System/AutoCheckout/v1.0",
    "timezone": "Asia/Ho_Chi_Minh",
    "notes": "Automatic checkout: open duration exceeded 24 hours",
    "gps_latitude": null,
    "gps_longitude": null
}
```

---

## GPS Coordinate Validation

### Requirement: Complete Data or None

GPS coordinates must be provided as a complete pair (latitude + longitude). Partial GPS (only one coordinate) is rejected.

### Latitude Validation

- Range: -90° to 90°
- Format: Decimal degrees (e.g., 21.028542)
- Example Valid Values:
  - Hanoi HQ: 21.028542°N = 21.028542
  - Ho Chi Minh: 10.762622°N = 10.762622
  - Singapore: 1.352083°N = 1.352083

### Longitude Validation

- Range: -180° to 180°
- Format: Decimal degrees (e.g., 105.854178)
- Example Valid Values:
  - Hanoi HQ: 105.854178°E = 105.854178
  - Ho Chi Minh: 106.660172°E = 106.660172
  - Singapore: 103.819836°E = 103.819836

### Rejection Logic

```python
if (gps_latitude is not None) XOR (gps_longitude is not None):
    # One is set, one is not → REJECT
    raise ValidationError("Both GPS latitude and longitude must be provided together.")

if gps_latitude is not None and gps_longitude is not None:
    # Both set → VALIDATE ranges
    if not (-90 <= gps_latitude <= 90):
        raise ValidationError(f"Invalid latitude: {gps_latitude}")
    if not (-180 <= gps_longitude <= 180):
        raise ValidationError(f"Invalid longitude: {gps_longitude}")
```

---

## IP Address Validation

### IPv4 Format

- Pattern: `\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`
- Valid Examples: 203.162.1.100, 192.168.1.1, 10.0.0.50

### IPv6 Format

- Pattern: Hexadecimal colon-separated groups
- Valid Examples: 2001:db8::1, fe80::1, ::1

### Special Cases

- **Private IP** (mobile/office network): 192.168.x.x, 10.x.x.x, 172.16-31.x.x → ACCEPTED
- **Loopback** (if system testing): 127.0.0.1, ::1 → ACCEPTED (for testing only; flagged for audit)
- **Masked/Proxy IP**: Forwarded via `X-Forwarded-For` header → ACCEPTED (record with note)

---

## User-Agent Parsing

### Web Browser Example

```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36
→ Parsed as: Chrome 91.0, Windows 10, 64-bit
```

### Mobile App Example

```
HRM-App/1.2.0 (Android; Device: SM-G991B)
→ Parsed as: HRM-App v1.2.0, Android, Samsung Galaxy S21
```

### Kiosk Example

```
FaceRecognitionKiosk-FR3000/v2.1
→ Parsed as: FR3000 Kiosk, v2.1
```

---

## Audit Trail & Access

### Who Can Create Context Records

- **Employee**: Implicitly when checking in/out via portal or mobile (context auto-captured)
- **HR Officer**: When manually correcting attendance (context created with reason note)
- **System**: Automatic checkout job (context auto-created)

### Who Can Read Context Records

- **Employee**: Read-only access to own context records (own attendance only)
- **HR Officer**: Read-only access to all context records (audit trail review)
- **HR Manager**: Read-only access to all context records
- **Compliance/Security Team**: Potential read-only access (TBD in Phase 2)

### Context Record Immutability

- Once created, context records **cannot be modified or deleted**
- Preserves complete audit trail
- If correction needed, create new context record with note explaining correction

---

## Integration with Audit Logging

### Event Trail Example

**Scenario**: Employee checks in at 8:30, then corrected by HR to 8:00, then corrected again to 8:05

```
Attendance Record: ID 5678, Employee: Nguyen Van A

Context Record 1:
  ID: 9101
  event_type: checkin
  event_timestamp: 2026-05-11 08:30:00 UTC
  event_source: mobile
  ip_address: 203.162.1.100
  gps_latitude: 21.0285, gps_longitude: 105.8542
  created_by: Employee (Nguyen Van A)

Context Record 2 (HR Correction #1):
  ID: 9103
  event_type: correction
  event_timestamp: 2026-05-11 09:00:00 UTC
  event_source: web
  ip_address: 10.0.1.50
  notes: "Time correction: Employee's clock was slow. Adjusted to 8:00 based on badge swipe."
  created_by: HR Officer (Tran Thi B)

Context Record 3 (HR Correction #2):
  ID: 9104
  event_timestamp: 2026-05-11 10:00:00 UTC
  event_source: web
  ip_address: 10.0.1.50
  notes: "Adjustment: corrected to 8:05 after employee appeal. Confirmed by badge system."
  created_by: HR Manager (Le Van C)
```

---

## Timezone Handling in Context

### Storage Policy

- **Context Timestamp** (`event_timestamp`): Always UTC (e.g., "2026-05-11T01:30:00Z")
- **Context Timezone** (`timezone`): Employee's local timezone at event time (e.g., "Asia/Ho_Chi_Minh")

### Display Policy

- When displaying context to HR officer: Convert event_timestamp to employee timezone
- Display format: `2026-05-11 08:30:00 (Asia/Ho_Chi_Minh)` 

### Cross-Midnight Scenario

```
Employee checks in at 23:50 Vietnam time (16:50 UTC)
Employee checks out at 00:10 next day Vietnam time (17:10 UTC)

Attendance Record:
  attendance_date: 2026-05-11 (based on check-in local time)
  check_in: 2026-05-11 16:50:00 UTC
  check_out: 2026-05-12 17:10:00 UTC
  worked_hours: 24.33 hours (exceeds anomaly threshold → flagged)

Context Records:
  Check-in context: timezone = Asia/Ho_Chi_Minh, local time = 23:50 on 2026-05-11
  Check-out context: timezone = Asia/Ho_Chi_Minh, local time = 00:10 on 2026-05-12
```

---

## Compliance & Legal Requirements

### Vietnamese Data Protection

- Context metadata is subject to Vietnamese data protection law (Bộ luật Bảo vệ dữ liệu cá nhân)
- GPS coordinates are sensitive PII; retention policy TBD (Phase 2 security review)
- Audit trail must be preserved for 10 years (per rules.md)
- Employee has right to access their own context data

### Retention Policy

- **Mandatory Retention**: All context records archived 10 years minimum (per labor law)
- **Deletion**: Only after 10-year period + HR Manager approval
- **Anonymization**: Not applicable; audit trail requires full data preservation

---

## Phase 1 Complete ✓

Context metadata contract defined with:
- ✓ Complete field specification
- ✓ Event source mapping (web, mobile, kiosk, API)
- ✓ GPS validation rules
- ✓ IP address validation (IPv4/IPv6)
- ✓ Immutable audit trail policy
- ✓ Timezone handling
- ✓ Compliance requirements (Vietnamese law)
