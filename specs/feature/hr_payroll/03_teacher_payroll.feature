Feature: Teacher and Teaching Assistant Payroll
  As a Payroll Manager at an education company
  I want to calculate salary for teachers and TAs based on teaching hours or fixed salary
  So that teaching staff are paid accurately according to their contract type

  # ============================================================
  # Bối cảnh:
  # - Giáo viên (GV) và Trợ giảng (TA) là hr.employee với job_id = "Teacher" / "TA"
  # - Có 2 cơ cấu lương riêng: "Office Staff Structure" và "Teacher Structure"
  # - GV có thể nhận lương theo giờ dạy (hourly) hoặc lương cố định (fixed)
  # - Giờ dạy đến từ work entries loại "teaching_hours"
  # ============================================================

  Background:
    Given I am logged in as a payroll manager
    And the payroll period "January 2025" is defined
    And salary structure "Teacher Structure" exists with teaching hour rules
    And salary structure "Office Staff Structure" exists with fixed salary rules

  # --- Giáo viên lương theo giờ dạy ---

  Scenario: Teacher paid by teaching hours - basic calculation
    Given teacher "John Smith" has contract with:
      | field              | value              |
      | salary_structure   | Teacher Structure  |
      | pay_type           | hourly             |
      | hourly_rate        | 300000             |
      | base_salary_for_insurance | 10000000    |
    And teacher has work entries of type "teaching_hours" totaling 80 hours in January 2025
    When I generate payslip for January 2025
    Then teaching_hours_pay should be 24000000
    # 80 hours × 300,000/hour = 24,000,000
    And gross salary should include teaching_hours_pay
    And insurance base should be 10000000
    # Insurance is based on contract base, not actual earnings

  Scenario: Teacher paid by teaching hours - part-time with fewer hours
    Given teacher "Jane Doe" has contract with:
      | field              | value              |
      | salary_structure   | Teacher Structure  |
      | pay_type           | hourly             |
      | hourly_rate        | 250000             |
      | base_salary_for_insurance | 6000000     |
    And teacher has work entries of type "teaching_hours" totaling 30 hours in January 2025
    When I generate payslip for January 2025
    Then teaching_hours_pay should be 7500000
    # 30 hours × 250,000/hour = 7,500,000
    And gross salary should be 7500000

  Scenario: Teacher with zero teaching hours in a month
    Given teacher "John Smith" has hourly pay contract at 300000/hour
    And teacher has 0 teaching hours work entries in January 2025
    When I generate payslip for January 2025
    Then teaching_hours_pay should be 0
    And gross salary should be 0
    And insurance deductions should still be calculated on base_salary_for_insurance

  # --- Giáo viên lương cố định ---

  Scenario: Teacher with fixed monthly salary
    Given teacher "Maria Garcia" has contract with:
      | field              | value              |
      | salary_structure   | Teacher Structure  |
      | pay_type           | fixed              |
      | base_salary        | 20000000           |
    When I generate payslip for January 2025
    Then gross salary should include base salary of 20000000
    And teaching hours should not affect salary calculation

  # --- Giáo viên lương cố định + thưởng giờ dạy vượt ---

  Scenario: Teacher with fixed salary plus bonus for extra teaching hours
    Given teacher "Tran Van H" has contract with:
      | field                    | value              |
      | salary_structure         | Teacher Structure  |
      | pay_type                 | fixed_plus_hourly  |
      | base_salary              | 15000000           |
      | standard_teaching_hours  | 60                 |
      | extra_hour_rate          | 200000             |
    And teacher has work entries of type "teaching_hours" totaling 75 hours in January 2025
    When I generate payslip for January 2025
    Then base pay should be 15000000
    And extra teaching hours should be 15
    # 75 total - 60 standard = 15 extra hours
    And extra_hours_pay should be 3000000
    # 15 × 200,000 = 3,000,000
    And gross salary should be 18000000

  Scenario: Teacher with fixed salary and teaching hours below standard (no penalty)
    Given teacher "Tran Van H" has contract with:
      | field                    | value              |
      | pay_type                 | fixed_plus_hourly  |
      | base_salary              | 15000000           |
      | standard_teaching_hours  | 60                 |
      | extra_hour_rate          | 200000             |
    And teacher has 50 teaching hours in January 2025
    When I generate payslip for January 2025
    Then base pay should be 15000000
    And extra_hours_pay should be 0
    # Below standard: no extra pay, but no deduction either (policy decision)

  # --- Trợ giảng (TA) ---

  Scenario: Teaching assistant paid by hourly rate
    Given TA "Nguyen Thi K" has contract with:
      | field              | value              |
      | salary_structure   | Teacher Structure  |
      | pay_type           | hourly             |
      | hourly_rate        | 150000             |
      | base_salary_for_insurance | 5000000     |
    And TA has work entries of type "teaching_hours" totaling 60 hours in January 2025
    When I generate payslip for January 2025
    Then teaching_hours_pay should be 9000000
    And insurance base should be 5000000

  # --- Nguồn dữ liệu giờ dạy ---

  Scenario: Teaching hours sourced from attendance work entries
    Given teacher "John Smith" has hourly contract at 300000/hour
    And the following work entries exist for January 2025:
      | date       | type           | duration |
      | 2025-01-02 | teaching_hours | 4        |
      | 2025-01-03 | teaching_hours | 6        |
      | 2025-01-06 | teaching_hours | 4        |
      | 2025-01-07 | teaching_hours | 3        |
    When I generate payslip for January 2025
    Then total teaching hours should be 17
    And teaching_hours_pay should be 5100000

  Scenario: Teaching hours sourced from manual payslip input
    Given teacher "John Smith" has hourly contract at 300000/hour
    And a payslip input of type "teaching_hours_manual" with value 85 is added
    # HR manually enters hours received from Operations department
    When I generate payslip for January 2025
    Then total teaching hours should be 85
    And teaching_hours_pay should be 25500000

  # --- Thuế và BH cho giáo viên ---

  Scenario: Full teacher payslip with Vietnamese tax and insurance
    Given teacher "Tran Van H" has contract with:
      | field                         | value     |
      | pay_type                      | hourly    |
      | hourly_rate                   | 300000    |
      | base_salary_for_insurance     | 10000000  |
    And teacher has 80 teaching hours in January 2025
    And teacher has 1 registered dependent
    When I generate payslip for January 2025
    Then gross salary should be 24000000
    # 80 × 300,000 = 24,000,000
    And insurance base should be 10000000
    # Insurance on contract base, not actual earnings
    And BHXH deduction should be 800000
    And BHYT deduction should be 150000
    And BHTN deduction should be 100000
    And total insurance should be 1050000
    And taxable income should be 7550000
    # 24,000,000 - 1,050,000 - 11,000,000 - 4,400,000 = 7,550,000
    And PIT should be 505000
    # Bracket 1: 5,000,000 × 5%  = 250,000
    # Bracket 2: 2,550,000 × 10% = 255,000
    # Total: 505,000
    And net salary should be 22445000

  # --- Cơ cấu lương: chọn đúng structure ---

  Scenario: System selects correct salary structure based on employee contract
    Given employee "Nguyen Van A" has contract with salary_structure "Office Staff Structure"
    And teacher "John Smith" has contract with salary_structure "Teacher Structure"
    When batch generating payslips for January 2025
    Then "Nguyen Van A" payslip should use "Office Staff Structure"
    And "John Smith" payslip should use "Teacher Structure"

  Scenario: Salary structure determines which rules are applied
    Given salary structure "Teacher Structure" has rules:
      | rule_name            | code         | category |
      | Teaching Hours Pay   | TEACH_HOURS  | GROSS    |
      | Extra Hours Bonus    | EXTRA_HOURS  | GROSS    |
      | Base Salary          | BASE         | GROSS    |
    And salary structure "Office Staff Structure" has rules:
      | rule_name            | code         | category |
      | Monthly Base Salary  | BASE         | GROSS    |
      | Position Allowance   | POS_ALW      | ALW      |
    When generating payslip for a teacher
    Then only "Teacher Structure" rules should be computed
    And "Office Staff Structure" rules should not be applied
