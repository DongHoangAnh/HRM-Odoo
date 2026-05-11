# Phase 0: Research & Clarification

**Feature**: Employee Attendance Check-In and Check-Out  
**Date**: 2026-05-11  
**Status**: In Progress

---

## Research Tasks

### RT-001: Vietnamese Labor Law OT Calculation

**Question**: How should overtime be calculated per Bộ luật Lao động 2019 (Vietnam Labor Law 2019) and what is the baseline expected daily work hours?

**Spec Reference**: FR-009 (compute overtime based on worked hours and configured baseline)

**Research Findings**:
- Vietnamese standard work week: 40 hours (per Labor Code 2019, Article 72)
- Standard daily work hours: 8 hours (40 / 5 days typical)
- Overtime Classification (Article 98, Labor Code 2019):
  - **Regular OT**: Work beyond 8 hours in a day → paid at 150% (1.5x) of hourly rate
  - **Weekend OT**: Work on weekend → paid at 200% (2x) of hourly rate
  - **Holiday OT**: Work on public holiday → paid at 300% (3x) of hourly rate
  - **Night OT** (22:00-06:00): Paid at 130% (1.3x) base rate
- Accumulation: OT hours accumulate weekly; if not worked that week, company must provide time-off equivalent
- BHXH Treatment: OT hours DO count toward BHXH contribution base (BHXH Directive 595/2015)

**Decision**: 
- **Daily baseline**: 8 hours (configurable per attendance policy, default 8)
- **OT Multiplier**: 
  - Standard weekday OT: 1.5x
  - Weekend: 2x
  - Public holiday: 3x
  - Night work (22:00-06:00): Add 0.3x bonus (1.3x total)
  - Night OT (beyond 8h + night): Combine multipliers (e.g., 1.5x + 0.3x = 1.8x on top base)
- **BHXH Integration**: OT hours included in payroll BHXH calculation (deferred to Phase 2 payroll design)
- **Configuration**: Baseline hours per employee via hr.attendance.policy record; multipliers as system constants (may become configurable later)

**Rationale**: Matches Vietnamese law and typical Odoo payroll practices; allows per-employee policy customization while maintaining legal compliance.

**Alternatives Considered**:
- Simple linear OT (worked_hours - 8) → rejected, doesn't match Vietnamese law requirements for different rates
- Hardcoded OT rates → rejected, company may need customization per employee type (office vs. teacher)

---

### RT-002: Timezone Handling & Cross-Midnight Attendance

**Question**: How should attendance date be attributed when check-in/check-out spans midnight or crosses timezone boundaries?

**Spec Reference**: FR-011 (use employee timezone when differs from system timezone); Edge case: "Employee checks in before midnight, checks out after midnight"

**Research Findings**:
- Odoo System Timezone: Server timezone (typically UTC for multi-country setup)
- Employee Timezone: Vietnamese employee → UTC+7 (Vietnam standard time, no DST)
- Attendance Date Definition: Should be employee's local date, not server date
- Example Scenario:
  - Employee in Vietnam (UTC+7) checks in at 23:50 local time on 2026-05-11
  - Employee checks out at 00:10 local time on 2026-05-12
  - System (UTC) records timestamps as: 2026-05-11 16:50 UTC → 2026-05-12 17:10 UTC
  - **Issue**: If date attribution uses system UTC, attendance would split across two days
  - **Solution**: Convert timestamps to employee timezone, determine date based on local time

**Decision**:
- **Attendance Date**: Determined by check-in local time in employee timezone (when check-in is before midnight locally, use that date; if check-out is after midnight, same date)
- **Worked Hours Calculation**: Use exact timestamps (check-out - check-in) in UTC for precision; convert to decimal hours
- **Timezone Storage**: Store employee timezone in hr.attendance record (denormalized for audit/historical accuracy)
- **Special Case**: Cross-midnight attendance (e.g., 23:50-00:10) counts as single session on check-in date if duration < 24h; flag if duration > 24h as anomaly

**Rationale**: Ensures attendance date aligns with employee's experience; audit trail preserves timezone for dispute resolution.

**Alternatives Considered**:
- Use system UTC date directly → rejected, doesn't match employee perspective; violates Bộ luật Labor law intent
- Store attendance in local time → rejected, loses precise audit trail; makes duration calculation ambiguous across DST boundaries

---

### RT-003: Access Control & User Roles for Check-In/Check-Out

**Question**: What user roles should have permission to create, read, update, or delete attendance records?

**Spec Reference**: FR-007 (manual time correction by authorized HR users); FR-008 (automated checkout)

**Research Findings** (from Context Discovery.md + typical HR workflows):
- **Employee**: Should create own check-in/check-out (attendance.action_hr_attendance_checkin)
- **HR Officer**: Should read all attendance, approve/correct times, resolve disputes
- **HR Manager**: Should audit attendance trends, run anomaly reports, authorize batch corrections
- **Attendance Officer**: (Optional) May manually record attendance if employee forgot to check in
- **System/Automation**: Automatic checkout job runs as system (no user context)
- **Department Manager**: (Optional) View own department's attendance for payroll verification

**ACL Matrix** (to be finalized in Phase 1 code implementation):

| Role | Create | Read | Update | Unlink | Notes |
|------|--------|------|--------|--------|-------|
| **Employee** | ✓ (own only) | ✓ (own only) | ✗ | ✗ | Creates check-in/out via portal/mobile |
| **HR Officer** | ✓ (any) | ✓ (any) | ✓ (any) | ✗ | Corrects times, flags anomalies, cannot delete |
| **HR Manager** | ✓ (any) | ✓ (any) | ✓ (any) | ✓ (any) | Full control, approval authority |
| **Manager (Dept)** | ✗ | ✓ (dept only) | ✗ | ✗ | View only, read-only access |
| **System (Job)** | ✓ | ✓ | ✓ | ✗ | Automated checkout, read for recalculation |

**Decision**:
- Implement 3 groups: `group_hr_attendance_employee`, `group_hr_attendance_officer`, `group_hr_attendance_manager`
- Group 1 (Employee): Read/create own attendance
- Group 2 (Officer): Full read/write/create access to all records
- Group 3 (Manager): Group 2 + delete permissions (if needed)
- System jobs run as `SUPERUSER_ID` in batch context
- Row-level security (RLS) via `_get_default_employee_ids()` for Group 1 to restrict "own only"

**Rationale**: Matches typical HR workflows; prevents unauthorized record deletion while allowing operational corrections.

**Alternatives Considered**:
- Single "HR" group → rejected, doesn't distinguish between read-only auditors and full-control managers
- No delete permission for anyone → rejected, necessary for data correction/cleanup (though rare)

---

### RT-004: Automatic Checkout Policy & Stale Record Detection

**Question**: What should be the maximum allowed open duration for an attendance record? When should automatic checkout occur?

**Spec Reference**: FR-008 (automated checkout of stale attendances per configured max duration); Acceptance Scenario: "Automatic checkout occurs for an open attendance after the maximum allowed open duration; the checkout mode is marked automatic"

**Research Findings**:
- Typical office work shift: 8 hours
- Teachers/TAs: May work longer due to marking, prep, or events
- Stale record risk: Employee forgets to check out; record stays open indefinitely
- Anomaly threshold: Usually 24 hours (considered suspicious; likely system error or employee forgot)

**Decision**:
- **Default Max Open Duration**: 24 hours (configurable per attendance policy)
- **Automatic Checkout Trigger**: Daily batch job runs at 02:00 (early morning, low traffic)
- **Checkout Logic**: 
  - For any open attendance record (check_out IS NULL) that was checked in > 24 hours ago
  - Automatically set check_out = NOW() (or last_activity_timestamp if available)
  - Mark mode = 'automatic'
  - Flag quality_indicator = 'stale_checkout' (anomaly)
  - Create system log entry for audit
- **Notification**: HR Officer receives summary email of auto-closed records daily

**Rationale**: Balances data integrity (prevent indefinite open records) with operational safety (don't close legitimate extended shifts too early).

**Alternatives Considered**:
- Immediate auto-checkout if > 12 hours → rejected, teachers may legitimately work longer
- Manual intervention only → rejected, stale records corrupt payroll calculations; automation necessary for data quality

---

### RT-005: Context Metadata Capture & Optional Fields

**Question**: Which context metadata should be mandatory vs. optional for check-in/check-out? What metadata can realistically be captured from different devices/networks?

**Spec Reference**: FR-006 (store attendance context: event mode, location, network, client/browser); Edge case: "Attendance event is submitted without optional metadata; record creation still succeeds"

**Research Findings**:
- **GPS/Location**: Requires permission on mobile devices; may not be available in corporate network (WiFi signal only)
- **Network IP**: Always available from server logs; can be captured automatically
- **Browser/Device Info**: Available via User-Agent header; auto-captured from request context
- **Event Mode**: Should be explicit user input (manual vs. automatic) or derived from action context
- **Timestamp**: Always captured by server

**Context Fields Decision**:

| Field | Type | Mandatory | Auto-Captured | Notes |
|-------|------|-----------|----------------|-------|
| **event_mode** | enum (manual/automatic/kiosk) | ✓ | ✓ | Derived from check-in action (user action vs. system job) |
| **event_source** | enum (mobile/web/kiosk/api) | ✓ | ✓ | Captured from request context (User-Agent, origin) |
| **gps_latitude** | float | ✗ | ✗ | Optional; employee may disable location |
| **gps_longitude** | float | ✗ | ✗ | Optional; paired with latitude |
| **location_name** | string (e.g., "Hanoi HQ", "Saigon Branch") | ✗ | - | HR can manually tag location if desired |
| **ip_address** | string | ✓ | ✓ | Captured from HTTP request |
| **user_agent** | string | ✓ | ✓ | Browser/device identifier |
| **timezone** | string (e.g., "Asia/Ho_Chi_Minh") | ✓ | ✓ | Captured from employee record or request header |

**Decision**:
- **Mandatory Capture**: event_mode, event_source, ip_address, user_agent, timezone (always have for audit trail)
- **Optional Capture**: GPS coordinates, location name (if provided; not required for record success)
- **Validation**: If GPS provided, BOTH latitude AND longitude required; partial coordinates rejected
- **Fallback**: If timezone not provided, use employee's configured timezone (in hr.employee record)

**Rationale**: Ensures audit trail completeness while not breaking workflow when location unavailable (e.g., corporate WiFi environment).

**Alternatives Considered**:
- Mandatory GPS → rejected, reduces adoption in non-mobile-friendly environments
- No metadata capture → rejected, violates audit and compliance requirements
- Capture-on-demand only → rejected, misses data when employee doesn't explicitly input; auto-capture ensures completeness

---

### RT-006: Extension vs. New Model for Attendance

**Question**: Should we extend Odoo's built-in `hr.attendance` model or create a new custom model for enhanced check-in/check-out?

**Research Findings**:
- **Odoo hr.attendance** (built-in):
  - Fields: `employee_id`, `check_in`, `check_out`, `worked_hours`
  - Minimal; no context metadata or quality indicators
  - Used by Time Off, Payroll modules
  - Extending via `_inherit` is standard Odoo practice
- **Custom model** (alternative):
  - Would duplicate hr.attendance; breaks integration with native modules
  - Payroll, reports would need custom adapters
- **Decision Approach**: Use `_inherit = 'hr.attendance'` to extend with new fields/methods

**Decision**:
- **Model**: `hr.attendance` extension (no new model; add fields and methods via inheritance)
- **New Fields**: 
  - `context_metadata_ids` (one2many to new `hr.attendance.context` model)
  - `overtime_hours` (computed float)
  - `expected_hours` (float, from attendance policy)
  - `quality_indicator` (selection: normal/anomaly/stale_checkout/extreme_duration)
  - `event_mode` (selection: manual/automatic/kiosk)
  - `last_corrected_by` (many2one hr.employee)
  - `last_corrected_on` (datetime)
- **New Related Model**: `hr.attendance.context` (one2many for audit trail of all context captures; one record per check-in/out event, not one per attendance)
- **Why Extend**: Maintains backward compatibility, ensures payroll module picks up new fields, reduces data duplication

**Rationale**: Aligns with Odoo best practices; enables smooth payroll integration (Phase 2).

**Alternatives Considered**:
- Create new `custom.attendance.checkin` model → rejected, breaks native Odoo integrations; redundant data
- Modify hr.attendance core → rejected, violates rules.md no-core-override principle

---

## Summary of Decisions

| Item | Decision | Rationale |
|------|----------|-----------|
| **OT Calculation** | Vietnamese law (1.5x weekday, 2x weekend, 3x holiday, 1.3x night) + configurable daily baseline | Legal compliance + flexibility |
| **Timezone Handling** | Employee local timezone for date attribution; store timezone in record | Matches employee experience; audit trail |
| **ACL** | 3 groups: Employee (own only), Officer (full read/write), Manager (+ delete) | Typical HR workflows; operational safety |
| **Auto-Checkout** | 24h max open duration; daily batch job; marked as automatic + flagged anomaly | Prevents data corruption; early warning |
| **Context Metadata** | Mandatory: mode/source/IP/user-agent/timezone; Optional: GPS/location | Audit completeness; operational usability |
| **Model Strategy** | Extend `hr.attendance` via `_inherit`; new `hr.attendance.context` for audit | Backward compatibility; payroll integration ready |

---

## Phase 0 Complete ✓

All NEEDS CLARIFICATION items resolved. Ready for **Phase 1: Data Model & Contracts Design**.
