# Implementation Plan: Employee Attendance Check-In and Check-Out

**Branch**: `004-overtime-rules` | **Date**: 2026-05-11 | **Spec**: [001-attendance-checkin-checkout/spec.md](001-attendance-checkin-checkout/spec.md)
**Input**: Feature specification from `/specs/hr_attendance_specs/001-attendance-checkin-checkout/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Design and implement a reliable employee attendance check-in/check-out system for Odoo 19 HRM module that captures attendance windows, calculates worked hours, detects overtime, and preserves context metadata (location, network, device info) for audit compliance. The system must prevent overlapping attendance records, support multiple daily sessions, enforce chronological validity, flag anomalies, and handle automatic checkout for stale records. Implementation uses Odoo ORM with Python 3.10+, extends hr.attendance model without core override, and follows Vietnamese labor law (Bộ luật Lao động 2019) with timezone-aware date attribution.

## Technical Context

**Language/Version**: Python 3.10 – 3.14 (per rules.md)  
**Primary Dependencies**: Odoo 19, hr module, resource module for calendar/scheduling  
**Storage**: PostgreSQL via Odoo ORM (models.Model)  
**Testing**: Python unittest/pytest, BDD feature tests (Behave), Odoo test cases  
**Target Platform**: Odoo 19 server, web-based (Vietnam-deployed)  
**Project Type**: Odoo custom module (`hrm_attendance_extension` or similar)  
**Performance Goals**: Sub-second check-in/check-out API response; support 1000+ daily check-in events without performance degradation  
**Constraints**: 
- No core Odoo override; use `_inherit` for model extension
- All code must follow rules.md standards (Python 3.10+ type hints, docstrings, logging)
- Vietnamese timezone context required (UTC+7); cross-midnight attendance attribution via employee timezone
- Compliance: Bộ luật Lao động 2019, BHXH integration ready (not in scope but architecture must support)
- ACL required per rule; ACL matrix TBD in Phase 1
**Scale/Scope**: 
- 4 departments (HR, Business, Operations, Finance)
- Multiple employee types: office staff, teachers (full/part-time), teaching assistants
- Assume ~200 employees in pilot phase; scale to 1000+ with performance review
- Support multiple check-in/checkout sessions per day per employee



## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Interim Operational Gates (from rules.md & Context Discovery.md)

| Gate | Requirement | Status | Notes |
|------|-------------|--------|-------|
| **Odoo Standards** | No core override; use `_inherit` pattern for model extension | ✓ PASS | Follow rule 2 from rules.md |
| **Python Standards** | Python 3.10+ type hints, proper decorator use, docstrings, logging | ✓ PASS | Follow chuẩn code Python section in rules.md |
| **Security/ACL** | All new models MUST have ACL records in `security/ir.model.access.csv` | ⏳ GATE | TBD in Phase 1 design; ACL matrix required before code |
| **Module Structure** | Follow module layout (models/, views/, security/, data/) | ✓ PASS | Tách feature mô-đun riêng per rules.md |
| **Vietnamese Law** | Bộ luật Lao động 2019 compliance; timezone UTC+7; cross-midnight handling | ⏳ GATE | Research Phase 0 must confirm OT calculation method & date attribution rules |
| **Payroll Integration** | Architecture must support BHXH/BHYT/BHTN and salary rule integration (scope Phase 2+) | ⏳ GATE | Research Phase 0 must confirm data contract with payroll module |
| **Field Documentation** | Docstrings required for all compute/onchange/constraint methods | ✓ PASS | Per rules.md section Chất lượng & logging |
| **Testing** | Unit tests + integration tests for all public methods | ⏳ GATE | Test-first approach per Context Discovery section 6 |

**Status**: 6/8 gates pass; 2 gates have dependencies on Phase 0 research → proceed to Phase 0 with focus on clarifying ACL/payroll contract and Vietnamese OT rules.



## Project Structure

### Documentation (this feature)

```text
specs/hr_attendance_specs/001-attendance-checkin-checkout/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command) - NEEDS CLARIFICATION → research items
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── attendance-api.md        # Attendance record contract (create/update/read)
│   ├── context-metadata.md      # Context capture contract (location, network, device)
│   └── overtime-calculation.md  # Overtime calculation contract
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root, Odoo custom module)

```text
# Option: Odoo Custom Module (selected)
hrm_attendance_extension/              # Custom module for check-in/check-out
├── __init__.py
├── __manifest__.py                    # Manifest with dependencies (hr, resource)
├── models/
│   ├── __init__.py
│   ├── hr_attendance_checkin.py       # Check-in/Check-out record model & extensions
│   ├── hr_attendance_context.py       # Context metadata (location, network, device)
│   └── hr_attendance_quality.py       # Quality indicator & anomaly detection
├── views/
│   ├── hr_attendance_checkin_views.xml
│   ├── hr_attendance_context_views.xml
│   └── hr_attendance_quality_views.xml
├── security/
│   ├── ir.model.access.csv            # ACL matrix (user roles TBD)
│   └── hr_attendance_security.xml     # Row-level security if needed
├── data/
│   └── attendance_defaults.xml        # Default policies, calendar setup
├── wizard/
│   └── __init__.py
├── report/
│   └── __init__.py
└── static/
    └── description/
        └── icon.png

tests/
├── __init__.py
├── unit/
│   ├── test_check_in_out.py
│   ├── test_context_capture.py
│   ├── test_overtime_calculation.py
│   └── test_anomaly_detection.py
└── integration/
    ├── test_payroll_integration.py      # Prepare for payroll Phase 2
    └── test_attendance_workflow.py

# BDD Feature tests (leverage existing .feature files)
specs/feature/hr_attendance/
├── 01_attendance_checkin_checkout.feature  (already present)
└── automated test runner via Behave
```

**Structure Decision**: Modular Odoo custom module (`hrm_attendance_extension`) following Odoo 19 conventions. Separates models by concern (checkin records, context metadata, quality signals). Security layer via ACL (TBD Phase 1). Tests split between unit (model logic) and integration (workflow + payroll readiness). BDD tests leverage existing `.feature` files. No core override; all extensions via `_inherit`.



## Complexity Tracking

> **Tracking Phase 0 research dependencies to unlock gates**

| Gate Dependency | Research Task | Success Criteria |
|---|---|---|
| **Payroll Integration Contract** | Research OT calculation method (Bộ luật Lao động 2019 + Odoo payroll rules) | Document OT formula, BHXH treatment, integration point with hr.salary.rule |
| **Vietnamese Date Attribution** | Clarify timezone handling for cross-midnight attendance | Confirm UTC+7 offset, employee timezone fallback, test case for 23:00-01:00 boundary |
| **ACL Matrix** | Define user roles for check-in/check-out (employee self-service vs. HR correction vs. manager audit) | ACL records ready before code phase; document role breakdown |
| **Automatic Checkout Policy** | Confirm max open duration threshold for stale record detection | Define threshold (e.g., 24 hours) and system behavior (auto-close vs. flag for manual review) |

**No unjustified complexity**: All 3-model design (checkin, context, quality) is justified by feature requirements. Modular structure supports future payroll integration without redesign.


