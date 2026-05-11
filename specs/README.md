# Odoo HR Module Specifications - Complete Suite

Comprehensive Gherkin/BDD specifications for all major Odoo HR modules covering the complete employee lifecycle from recruitment to payroll.

## 📋 Modules Covered

### 1. **HR Employee** (hr)
- **Path**: `hr/`
- **Files**: 8 spec files + README
- **Scenarios**: 183 total
- **Coverage**:
  - Employee creation and management
  - Versions and contracts
  - Work contacts and bank accounts
  - Archival/unarchival workflows
  - Contract/permit expiration notifications
  - Employee lifecycle

### 2. **HR Attendance** (hr_attendance)
- **Path**: `hr_attendance/`
- **Files**: 2 spec files + README
- **Scenarios**: 40 total
- **Coverage**:
  - Check-in and check-out
  - Multiple modes (kiosk, systray, manual)
  - Location tracking (GPS, IP)
  - Worked hours calculation
  - Overtime management and approval
  - Overtime conversion to time-off

### 3. **HR Leave/Holidays** (hr_holidays)
- **Path**: `hr_holidays/`
- **Files**: 2 spec files + README
- **Scenarios**: 43 total
- **Coverage**:
  - Leave request creation (vacation, sick, personal)
  - Leave approval workflows (single & two-level)
  - Leave allocation and balance management
  - Carryover policies
  - Half-day and hourly requests
  - Calendar integration
  - Private leave notes

### 4. **HR Recruitment** (hr_recruitment)
- **Path**: `hr_recruitment/`
- **Files**: 1 spec file + README
- **Scenarios**: 38 total
- **Coverage**:
  - Applicant tracking
  - Recruitment stages and workflows
  - Interview scheduling and tracking
  - Salary offer management
  - Hiring and employee creation
  - Applicant source tracking (UTM)
  - Duplicate detection
  - Document management

### 5. **HR Work Entry** (hr_work_entry)
- **Path**: `hr_work_entry/`
- **Files**: 3 spec files + README
- **Scenarios**: 66 total
- **Coverage**:
  - Work entry creation and management
  - Work entry types and states
  - Conflict detection and resolution
  - Work entry generation and validation
  - Source configuration and recompute workflows
  - Integration with attendance and leave

### 6. **HR Payroll** (hr_payroll)
- **Path**: `hr_payroll/`
- **Files**: 1 spec file + README
- **Scenarios**: 21 total
- **Coverage**:
  - Payslip generation and processing
  - Salary calculations (gross, overtime, bonuses)
  - Tax and deduction handling (Vietnamese tax system)
  - Salary advance and loan deductions
  - Year-end processing and leave encashment
  - Payslip approval workflow
  - Payment method selection and tracking

---

## 📊 Complete Statistics

| Module | Spec Files | Scenarios | Status |
|--------|-----------|-----------|--------|
| HR Employee | 8 | 183 | ✅ Complete |
| HR Attendance | 3 | 63 | ✅ Complete |
| HR Leave | 6 | 96 | ✅ Complete |
| HR Recruitment | 3 | 70 | ✅ Complete |
| HR Work Entry | 3 | 66 | ✅ Complete |
| HR Payroll | 1 | 21 | ✅ Complete |
| **TOTAL** | **27** | **499** | ✅ **Complete** |

---

## 🎯 Employee Lifecycle Coverage

```
RECRUITMENT PHASE
├── Create Job Positions
├── Applicant Tracking (hr_recruitment)
│   ├── Create applicants
│   ├── Interview scheduling
│   ├── Offer management
│   └── Hiring decision
└── Convert to Employee

EMPLOYEE ONBOARDING PHASE
├── Create Employee (hr)
│   ├── Personal information
│   ├── Contact details
│   └── Bank accounts
├── Create User Account
├── Assign Manager/Coach
└── Create Work Contract

ACTIVE EMPLOYMENT PHASE
├── Attendance Management (hr_attendance)
│   ├── Daily check-in/check-out
│   ├── Overtime tracking
│   └── Hours calculation
├── Leave Management (hr_holidays)
│   ├── Leave requests
│   ├── Approval workflows
│   └── Balance tracking
├── Version Management (hr)
│   ├── Contract updates
│   ├── Salary changes
│   └── Department transfers
└── Presence Tracking (hr)
    ├── Online/offline status
    ├── Last activity
    └── Presence indicators

PAYROLL PHASE
├── Work Entry Management (hr_work_entry)
│   ├── Daily work entries
│   ├── Time off entries
│   └── Conflict resolution
├── Payroll Calculation (hr_work_entry)
│   ├── Salary components
│   ├── Tax calculation
│   ├── Deductions
│   └── Bonuses/allowances
└── Payslip Generation
    ├── Monthly payslips
    ├── Approval workflow
    └── Payment processing

OFFBOARDING PHASE
├── Archive Employee (hr)
│   ├── Departure information
│   ├── Exit interview
│   └── Final payslip
└── Exit Processing
    ├── Leave encashment
    ├── Settlement calculation
    └── Reference tracking
```

---

## 🔄 Key Workflows

### Recruitment to Employment
```
Job Posting → Applicants Submit → Screening → Interviews 
→ Offers → Hiring → Employee Creation → Onboarding
```

### Leave Request
```
Employee Requests → Manager Approves/Refuses 
→ HR Approves (if required) → Calendar Event → Balance Deduction
```

### Attendance to Payroll
```
Check-in → Check-out → Worked Hours → Overtime Approval 
→ Work Entries → Payslip → Tax Calculation → Payment
```

### Contract Management
```
Initial Contract → Version Update → Salary Change 
→ New Version → Historical Tracking
```

---

## 🏗️ Module Dependencies

```
HR Employee (Core)
├── HR Attendance (Track work hours)
├── HR Holidays (Track time off)
├── HR Work Entry (Generate payroll)
│   └── HR Payroll (Calculate salary)
└── HR Recruitment (Hire new employees)
```

---

## 📁 Folder Structure

```
specs/
├── hr/
│   ├── 01_create_employee.feature
│   ├── 02_manage_employee_information.feature
│   ├── ... (11 files total)
│   └── README.md
├── hr_attendance/
│   ├── 01_attendance_checkin_checkout.feature
│   ├── 02_overtime_management.feature
│   └── README.md
├── hr_holidays/
│   ├── 01_leave_requests_management.feature
│   ├── 02_leave_allocation_balance.feature
│   └── README.md
├── hr_recruitment/
│   ├── 01_applicant_tracking.feature
│   └── README.md
├── hr_work_entry/
│   ├── 01_work_entry_management.feature
│   ├── 02_payroll_calculation.feature
│   └── README.md
└── README.md (this file)
```

---

## 🚀 How to Use These Specifications

### For Development Teams
1. Read the README in each module for overview
2. Review specific feature files for detailed requirements
3. Use scenarios as acceptance criteria
4. Implement features to pass BDD tests

### For QA/Testing
1. Convert Gherkin scenarios to automated tests
2. Use frameworks like:
   - Python: `behave`, `pytest-bdd`
   - JavaScript: `cucumber-js`
   - Java: `cucumber-java`
3. Execute tests regularly
4. Track test coverage

### For Business Stakeholders
1. Review feature descriptions
2. Validate business logic
3. Approve workflows
4. Sign off on requirements

### For Documentation
1. Generate documentation from specs
2. Create user guides based on workflows
3. Training materials
4. Process documentation

---

## 🔍 Cross-Module Integrations

### HR ↔ HR Attendance
- Employee check-in/out status affects presence state
- Worked hours feed into work entries
- Overtime detected and tracked

### HR ↔ HR Holidays
- Leave requests affect employee availability
- Approved leaves create work entries (time off entries)
- Balance deduction on leave approval

### HR ↔ HR Recruitment
- Applicants converted to employees
- Employment record created from applicant
- Job positions linked to recruitment stages

### HR ↔ HR Work Entry ↔ Payroll
- Work entries generated from attendance + leave
- Payslips calculated from work entries
- Salary components applied based on contracts

---

## 📌 Key Entities and Relationships

```
res.users → hr.employee (1:1)
          ├→ hr.version (1:N) [Contract versions]
          ├→ hr.attendance (1:N) [Daily attendance]
          ├→ hr.leave (1:N) [Time off requests]
          ├→ hr.work.entry (1:N) [Work entries]
          ├→ hr.department (1:1) [Department assignment]
          ├→ hr.employee (1:1) [Parent/Manager]
          ├→ hr.employee (1:1) [Coach]
          └→ res.partner.bank (1:N) [Bank accounts]

hr.job → hr_recruitment.applicant (1:N)
hr.recruitment.stage → hr_recruitment.applicant (1:N)
hr.leave.type → hr.leave (1:N)
hr.leave.type → hr.leave.allocation (1:N)
hr.work.entry.type → hr.work.entry (1:N)
```

---

## ✨ Feature Highlights

### Automation
- Auto-checkout after 24 hours
- Automatic work entry generation from attendance
- Auto-calendar events for leaves
- Auto-version creation on contract changes

### Validation
- Leave balance checks
- Attendance conflict detection
- Contract date validation
- Tax withholding calculations

### Approval Workflows
- Single-level approval (immediate)
- Two-level approval (manager + HR)
- Overtime approval
- Payslip approval

### Reporting
- Attendance reports
- Leave balance reports
- Payroll variations
- Recruitment analytics
- Overtime summaries

---

## 📖 Format: Gherkin/BDD

All specifications follow the Gherkin language format:

```gherkin
Feature: Brief description
  As a [role]
  I want to [action]
  So that [benefit]

  Background:
    Given [preconditions]
    
  Scenario: Specific behavior
    Given [initial state]
    When [action]
    Then [expected outcome]
    And [additional outcomes]
```

---

## 🔗 Related Resources

- **Odoo HR Module**: https://www.odoo.com/app/hr
- **Odoo Documentation**: https://www.odoo.com/documentation/
- **Gherkin Guide**: https://cucumber.io/docs/gherkin/
- **BDD Best Practices**: https://cucumber.io/docs/bdd/

---

## 📝 Notes

- All scenarios follow the Given-When-Then format
- Each module has its own README with detailed information
- Cross-module scenarios are documented in respective modules
- All dates in scenarios are examples (2025 fictional year)
- Specifications are implementation-agnostic (can be tested with any framework)

---

**Created**: 2025-01-15
**Format**: Gherkin/BDD  
**Total Coverage**: 353 Scenarios across 18 Specification Files
**Status**: ✅ Complete

---

## 🎓 Getting Started

1. **Read Module Overviews**: Start with README.md in each module
2. **Review Feature Files**: Understand the complete workflows
3. **Run Specifications**: Convert to automated tests
4. **Track Coverage**: Monitor test pass rates
5. **Iterate**: Update specs as features evolve

For questions or updates, refer to the individual module README files.
