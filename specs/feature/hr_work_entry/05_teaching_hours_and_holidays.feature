Feature: Teaching Hours Work Entries and Public Holidays
  As an HR Manager at an education company
  I want work entries to correctly handle teaching hours and public holidays
  So that payroll receives accurate data for salary calculation

  # ============================================================
  # PHẦN 1: DEFAULT WORK ENTRY TYPES (Seed Data)
  # Hệ thống cần tạo sẵn các loại work entry mặc định
  # ============================================================

  Background:
    Given I am logged in as an HR manager
    And the company is configured for Vietnam

  Scenario: Default work entry types are available after module installation
    When the hr_work_entry module is installed
    Then the following work entry types should exist:
      | code              | name                    | is_work | is_leave |
      | WORK100           | Normal Working Day      | true    | false    |
      | WORK110           | Overtime                | true    | false    |
      | WORK200           | Teaching Hours          | true    | false    |
      | LEAVE100          | Paid Time Off           | false   | true     |
      | LEAVE110          | Sick Leave              | false   | true     |
      | LEAVE120          | Unpaid Leave            | false   | true     |
      | LEAVE200          | Maternity Leave         | false   | true     |
      | LEAVE210          | Paternity Leave         | false   | true     |
      | LEAVE300          | Public Holiday          | false   | true     |
      | LEAVE310          | Compensatory Time Off   | false   | true     |

  Scenario: Work entry types have unique codes
    When I try to create a work entry type with code "WORK100"
    Then the system should reject with error "Code must be unique"

  Scenario: Work entry type can be deactivated but not deleted if used
    Given work entry type "WORK100" is used in 50 work entries
    When I try to delete work entry type "WORK100"
    Then the system should prevent deletion
    And suggest deactivation instead

  # ============================================================
  # PHẦN 2: TEACHING HOURS WORK ENTRIES
  # Giờ dạy của giáo viên/TA trở thành work entries
  # ============================================================

  Scenario: Teaching hours generated from attendance records
    Given teacher "John Smith" has the following attendance records:
      | date       | check_in | check_out | mode    |
      | 2025-01-02 | 08:00    | 12:00     | kiosk   |
      | 2025-01-02 | 13:00    | 15:00     | kiosk   |
      | 2025-01-03 | 09:00    | 12:00     | kiosk   |
    And teacher has work entry source configured as "attendance"
    When work entries are generated for January 2025
    Then the following work entries should be created:
      | date       | type           | duration |
      | 2025-01-02 | teaching_hours | 4        |
      | 2025-01-02 | teaching_hours | 2        |
      | 2025-01-03 | teaching_hours | 3        |
    And total teaching hours should be 9

  Scenario: Teaching hours manually entered by HR
    Given teacher "Jane Doe" has work entry source configured as "manual"
    When an HR manager creates a work entry:
      | field      | value          |
      | employee   | Jane Doe       |
      | date       | 2025-01-06     |
      | type       | teaching_hours |
      | duration   | 6              |
    Then the work entry should be created in "draft" state
    And it should be available for payslip generation after validation

  Scenario: Teaching hours imported from Operations department
    Given the Operations department provides teaching hour data:
      | teacher      | date       | hours | class_name        |
      | John Smith   | 2025-01-02 | 4     | IELTS Advanced A1 |
      | John Smith   | 2025-01-03 | 3     | TOEFL Prep B2     |
      | Jane Doe     | 2025-01-02 | 6     | English Basic C1  |
    When HR imports the teaching hours as work entries
    Then work entries of type "teaching_hours" should be created for each row
    And they should be in "draft" state awaiting validation
    And the import should be logged for audit

  Scenario: Teaching hours work entries are validated before payslip generation
    Given teacher "John Smith" has 20 teaching hour work entries in January 2025
    And 15 entries are in "validated" state
    And 5 entries are in "draft" state
    When I generate payslip for January 2025
    Then payslip should only include the 15 validated entries
    And a warning should be shown about 5 unvalidated entries

  Scenario: Teaching hours cannot exceed 24 hours per day
    Given I try to create a work entry for teacher "John Smith":
      | date     | 2025-01-02     |
      | type     | teaching_hours |
      | duration | 25             |
    Then the system should reject with error "Duration cannot exceed 24 hours"

  Scenario: Conflict detection for overlapping teaching hours
    Given teacher "John Smith" has an existing work entry:
      | date       | 2025-01-02     |
      | type       | teaching_hours |
      | date_start | 2025-01-02 08:00 |
      | date_stop  | 2025-01-02 12:00 |
    When a new work entry is created:
      | date       | 2025-01-02     |
      | type       | teaching_hours |
      | date_start | 2025-01-02 10:00 |
      | date_stop  | 2025-01-02 14:00 |
    Then both entries should be marked as "conflict"
    And HR should resolve the conflict before validation

  # ============================================================
  # PHẦN 3: PUBLIC HOLIDAYS (Ngày lễ)
  # ============================================================

  Scenario: Public holiday generates leave-type work entry automatically
    Given the following public holidays are configured for 2025:
      | name                          | date_from  | date_to    |
      | Tet Holiday                   | 2025-01-27 | 2025-01-31 |
      | Reunification Day             | 2025-04-30 | 2025-04-30 |
      | International Labour Day      | 2025-05-01 | 2025-05-01 |
      | National Day                  | 2025-09-02 | 2025-09-02 |
    And employee "Nguyen Van A" has a standard work calendar (Mon-Fri)
    When work entries are generated for January 2025
    Then work entries on 2025-01-27 to 2025-01-31 should have type "public_holiday"
    And these entries should have is_leave = true
    And duration should follow the standard work hours (8h/day)
    And employee should not be marked as absent

  Scenario: Public holiday on weekend does not generate work entry
    Given "National Day" falls on 2025-09-02 (Tuesday)
    And employee "Nguyen Van A" works Mon-Fri
    When work entries are generated for September 2025
    Then a "public_holiday" work entry should exist for 2025-09-02
    But no work entry should be generated for weekends

  Scenario: Public holiday work entry is paid and not deducted from leave
    Given employee "Nguyen Van A" has a "public_holiday" work entry for 2025-04-30
    When generating payslip for April 2025
    Then the public holiday should count as a paid day
    And it should NOT reduce the employee leave balance
    And it should map to a "paid" salary rule

  Scenario: Employee working on public holiday gets overtime rate
    Given employee "Tran Van B" has attendance on 2025-04-30 (public holiday)
    And the employee checked in at 08:00 and checked out at 17:00
    When work entries are generated
    Then an "overtime" work entry should be created for 8 hours
    And it should be flagged with holiday_overtime = true
    And overtime rate should be 300% as per Vietnamese labor law
    # VN law: work on public holiday = 300% normal rate

  # ============================================================
  # PHẦN 4: VIETNAMESE PUBLIC HOLIDAYS LIST
  # ============================================================

  Scenario: Vietnamese public holidays are pre-configured
    When the module is installed for a Vietnamese company
    Then the following recurring holidays should be configured:
      | name                               | duration |
      | Tet Duong Lich (New Year)          | 1 day    |
      | Tet Nguyen Dan (Lunar New Year)    | 5 days   |
      | Hung Kings Commemoration           | 1 day    |
      | Reunification Day (30/4)           | 1 day    |
      | International Labour Day (1/5)     | 1 day    |
      | National Day (2/9)                 | 2 days   |
    # Total: 11 days per year as per Vietnamese labor law

  Scenario: HR can add extra company holidays
    Given the standard Vietnamese holidays are configured
    When HR adds a company-specific holiday:
      | name       | Company Anniversary |
      | date       | 2025-06-15          |
    Then a new public holiday should be created
    And work entries for that day should use "public_holiday" type

  # ============================================================
  # PHẦN 5: WORK ENTRY GENERATION — OFFICE STAFF VS TEACHER
  # ============================================================

  Scenario: Office staff work entries generated from calendar
    Given employee "Nguyen Van A" is office staff with standard calendar (Mon-Fri, 8h/day)
    And work entry source is "calendar"
    When work entries are generated for January 2025
    Then work entries should be created for each working day
    And each entry should have type "WORK100" (Normal Working Day)
    And each entry should have duration of 8 hours

  Scenario: Teacher work entries generated from attendance
    Given teacher "John Smith" has work entry source as "attendance"
    And teacher has attendance records for January 2025
    When work entries are generated
    Then work entries should match attendance check-in/check-out
    And each entry should have type "WORK200" (Teaching Hours)
    And duration should match actual attendance hours

  Scenario: Hybrid source - office hours from calendar, teaching from attendance
    Given teacher "Maria Garcia" has work entry source as "hybrid"
    And teacher has standard calendar (Mon-Fri, 8h)
    And teacher has teaching attendance records
    When work entries are generated
    Then calendar-based work entries should have type "WORK100"
    And attendance-based teaching entries should have type "WORK200"
    And conflicts between calendar and attendance entries should be detected

  # ============================================================
  # PHẦN 6: WORK ENTRY → PAYROLL MAPPING
  # ============================================================

  Scenario: Work entry types map to salary rule categories
    Given the following mapping is configured:
      | work_entry_type | salary_rule_code | description              |
      | WORK100         | BASE             | Normal pay               |
      | WORK110         | OT               | Overtime pay             |
      | WORK200         | TEACH_HOURS      | Teaching hours pay       |
      | LEAVE100        | PAID_LEAVE       | Paid leave (no deduction)|
      | LEAVE120        | UNPAID_LEAVE     | Unpaid leave deduction   |
      | LEAVE300        | PUBLIC_HOLIDAY   | Public holiday pay       |
    When payslip generation reads work entries
    Then each work entry should be mapped to the correct salary rule
    And hours from each type should feed into the rule calculation

  Scenario: Validated work entries are locked after payslip inclusion
    Given employee "Nguyen Van A" has 22 validated work entries for January 2025
    And a payslip is generated and approved using these entries
    When someone tries to modify a work entry used in the payslip
    Then the system should prevent modification
    And the work entry state should be "payslip_included"
    And a warning should show "This entry is locked by payslip PS-2025-01-001"
