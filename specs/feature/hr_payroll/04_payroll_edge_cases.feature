Feature: Payroll Edge Cases and Special Scenarios
  As a Payroll Manager
  I want to handle special payroll scenarios correctly
  So that all employees are paid accurately regardless of their employment situation

  # ============================================================
  # PHẦN 1: LƯƠNG THỬ VIỆC (Probation Salary)
  # Luật VN: Lương thử việc >= 85% lương chính thức
  # ============================================================

  Background:
    Given I am logged in as a payroll manager
    And the payroll period "January 2025" is defined

  Scenario: Probation employee receives 85% of official salary
    Given employee "Nguyen Van M" has contract with:
      | field            | value      |
      | base_salary      | 20000000   |
      | contract_type    | probation  |
      | probation_rate   | 85         |
    When I generate payslip for January 2025
    Then effective base salary should be 17000000
    # 20,000,000 × 85% = 17,000,000
    And gross salary should use the probation salary
    And insurance base should be calculated on probation salary

  Scenario: Probation rate is configurable per contract
    Given employee "Tran Van N" has contract with:
      | field            | value      |
      | base_salary      | 15000000   |
      | contract_type    | probation  |
      | probation_rate   | 90         |
    When I generate payslip for January 2025
    Then effective base salary should be 13500000
    # 15,000,000 × 90% = 13,500,000

  Scenario: Employee transitions from probation to official mid-month
    Given employee "Nguyen Van M" had probation contract ending 2025-01-15
    And official contract starting 2025-01-16 with base salary 20000000
    And probation salary was 17000000
    When I generate payslip for January 2025
    Then salary should be prorated:
      | period          | days | salary   |
      | 2025-01-01 to 15 | 15  | probation |
      | 2025-01-16 to 31 | 16  | official  |
    And the payslip should reflect the blended amount

  # ============================================================
  # PHẦN 2: NET-TO-GROSS (Tính ngược từ lương Net)
  # Nhiều công ty VN thỏa thuận lương Net
  # ============================================================

  Scenario: Net-to-gross calculation for employee with net salary agreement
    Given employee "Le Van P" has contract with:
      | field            | value       |
      | salary_type      | net         |
      | net_salary       | 20000000    |
      | dependents       | 1           |
    When the system calculates gross salary from net
    Then gross salary should be reverse-calculated so that:
      | after deducting insurance    | at employee rate 10.5% |
      | after deducting PIT          | using 7-bracket table  |
      | the remaining net equals     | 20000000               |
    And the computed gross should be stored on the payslip
    And all deductions should be calculated on the computed gross

  Scenario: Net-to-gross where net is below tax threshold
    Given employee "Pham Thi Q" has contract with:
      | field            | value       |
      | salary_type      | net         |
      | net_salary       | 8000000     |
      | dependents       | 2           |
    When the system calculates gross salary from net
    Then gross salary should equal net_salary divided by (1 - 0.105)
    # No PIT applies, so gross = net / (1 - insurance_rate)
    # gross = 8,000,000 / 0.895 ≈ 8,938,547
    And PIT should be 0

  # ============================================================
  # PHẦN 3: THƯỞNG TẾT / THÁNG 13 (Year-end bonus / 13th month)
  # ============================================================

  Scenario: 13th month salary for full-year employee
    Given employee "Nguyen Van A" worked the full year 2025
    And base salary is 15000000
    And 13th month policy is "one month base salary"
    When I process year-end bonus for 2025
    Then bonus_amount should be 15000000

  Scenario: 13th month salary prorated for employee who joined mid-year
    Given employee "Tran Van R" started on 2025-07-01
    And base salary is 15000000
    And 13th month policy is "one month base salary prorated"
    When I process year-end bonus for 2025
    Then bonus_amount should be 7500000
    # 15,000,000 × (6 months / 12 months) = 7,500,000

  Scenario: 13th month salary prorated for employee who left mid-year
    Given employee "Pham Van S" worked from 2025-01-01 to 2025-09-30
    And base salary is 20000000
    When I process year-end bonus for 2025
    Then bonus_amount should be 15000000
    # 20,000,000 × (9 / 12) = 15,000,000

  Scenario: Tax on 13th month bonus
    Given employee "Nguyen Van A" receives 13th month bonus of 15000000
    When I generate the bonus payslip
    Then the bonus should be included in taxable income for that month
    And PIT should be calculated on (regular salary + bonus) combined
    # Bonus is taxed together with regular income in the month it is paid

  Scenario: 13th month bonus paid in separate payslip
    Given employee "Nguyen Van A" has regular January payslip already generated
    When I create a bonus payslip for January 2025 with:
      | type          | bonus       |
      | bonus_amount  | 15000000    |
    Then a separate payslip should be created
    And it should be linked to the same payroll period
    And PIT on the bonus payslip should consider cumulative income

  # ============================================================
  # PHẦN 4: PRO-RATA (Nhân viên vào/nghỉ giữa tháng)
  # ============================================================

  Scenario: New employee starting mid-month gets prorated salary
    Given employee "Hoang Van T" started on 2025-01-16
    And base salary is 20000000
    And January 2025 has 22 working days
    And employee worked 12 days (from 16th to 31st)
    When I generate payslip for January 2025
    Then prorated salary should be approximately 10909091
    # 20,000,000 / 22 × 12 ≈ 10,909,091
    And insurance should be prorated accordingly

  Scenario: Terminated employee gets prorated salary for last month
    Given employee "Do Van U" terminated on 2025-01-20
    And base salary is 18000000
    And January 2025 has 22 working days
    And employee worked 14 days (from 1st to 20th)
    When I generate payslip for January 2025
    Then prorated salary should be approximately 11454545
    # 18,000,000 / 22 × 14 ≈ 11,454,545

  # ============================================================
  # PHẦN 5: PAYSLIP INPUT (Khoản nhập thêm mỗi kỳ)
  # ============================================================

  Scenario: One-time bonus added via payslip input
    Given employee "Nguyen Van A" has regular salary of 15000000
    And a payslip input of type "performance_bonus" with amount 3000000 is added
    When I generate payslip for January 2025
    Then payslip should include a line for "Performance Bonus" of 3000000
    And gross salary should be 18000000
    And PIT should be recalculated on the new gross

  Scenario: Penalty deduction via payslip input
    Given employee "Tran Van B" has regular salary of 15000000
    And a payslip input of type "penalty" with amount 500000 is added
    When I generate payslip for January 2025
    Then payslip should include a deduction line "Penalty" of 500000
    And net salary should be reduced by 500000

  Scenario: Multiple payslip inputs in one period
    Given employee "Nguyen Van A" has the following payslip inputs:
      | type              | amount  |
      | referral_bonus    | 2000000 |
      | meal_deduction    | 300000  |
      | salary_advance    | 5000000 |
    When I generate payslip for January 2025
    Then all inputs should appear as separate lines on the payslip
    And gross should include referral_bonus
    And deductions should include meal_deduction and salary_advance

  Scenario: Payslip input types are configurable
    Given an HR manager creates a new payslip input type:
      | field     | value              |
      | name      | Project Bonus      |
      | code      | PROJ_BONUS         |
      | category  | earnings           |
    Then the input type should be available for payslip generation
    And it should map to the correct salary rule category

  # ============================================================
  # PHẦN 6: CHIA LƯƠNG NHIỀU TÀI KHOẢN (Multi-bank split)
  # ============================================================

  Scenario: Employee salary split to two bank accounts
    Given employee "Nguyen Van A" has salary distribution:
      | bank_account       | percentage |
      | 1234567890 (VCB)   | 70%        |
      | 0987654321 (TCB)   | 30%        |
    And net salary is 16000000
    When processing payment for the payslip
    Then bank transfer should be:
      | bank_account       | amount    |
      | 1234567890 (VCB)   | 11200000  |
      | 0987654321 (TCB)   | 4800000   |

  Scenario: Employee with single bank account receives full salary
    Given employee "Tran Van B" has one bank account "1111222233 (BIDV)"
    And net salary is 14000000
    When processing payment for the payslip
    Then full net salary should go to "1111222233 (BIDV)"

  Scenario: Salary distribution percentages must total 100%
    Given employee tries to set salary distribution:
      | bank_account | percentage |
      | Account A    | 60%        |
      | Account B    | 30%        |
    Then the system should reject with error "Distribution must total 100%"

  # ============================================================
  # PHẦN 7: NGHỈ KHÔNG LƯƠNG (Unpaid Leave Deduction)
  # ============================================================

  Scenario: Unpaid leave deducted from salary
    Given employee "Nguyen Van A" has base salary 20000000
    And January 2025 has 22 working days
    And employee took 3 days unpaid leave
    When I generate payslip for January 2025
    Then unpaid leave deduction should be 2727273
    # 20,000,000 / 22 × 3 ≈ 2,727,273
    And gross salary should be 17272727

  Scenario: Sick leave within allowance is not deducted
    Given employee "Tran Van B" has paid sick leave allocation of 10 days
    And employee took 2 sick leave days in January 2025
    When I generate payslip for January 2025
    Then sick leave deduction should be 0
    And gross salary should be full base salary

  # ============================================================
  # PHẦN 8: PAYROLL PERIOD LOCKING
  # ============================================================

  Scenario: Lock payroll period after all payslips are approved
    Given all payslips for January 2025 are in "done" state
    When I lock the payroll period
    Then the period state should be "closed"
    And no payslips can be created or modified for this period

  Scenario: Cannot lock payroll period with unapproved payslips
    Given some payslips for January 2025 are still in "draft" state
    When I try to lock the payroll period
    Then the system should prevent locking
    And show error "Cannot close period: X payslips are not finalized"

  Scenario: Unlock payroll period for corrections
    Given payroll period January 2025 is "closed"
    And I am an HR Manager
    When I unlock the payroll period
    Then the period state should be "open"
    And payslips can be modified again
    And the unlock action should be logged in audit trail
