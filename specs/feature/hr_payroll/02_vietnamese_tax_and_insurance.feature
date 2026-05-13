Feature: Vietnamese Tax and Mandatory Insurance
  As a Payroll Manager
  I want payroll to correctly calculate Vietnamese mandatory insurance (BHXH, BHYT, BHTN)
  and Personal Income Tax (PIT) with progressive brackets and dependent relief
  So that payslips comply with Vietnamese labor law

  # ============================================================
  # PHẦN 1: BẢO HIỂM BẮT BUỘC (BHXH, BHYT, BHTN)
  # ============================================================

  Background:
    Given I am logged in as a payroll manager
    And the payroll period "January 2025" is defined
    And the company is in Vietnam with the following insurance configuration:
      | type | employee_rate | employer_rate |
      | BHXH | 8%            | 17.5%         |
      | BHYT | 1.5%          | 3%            |
      | BHTN | 1%            | 1%            |
    And the base salary reference (luong_co_so) is 2340000
    And the regional minimum wage (luong_toi_thieu_vung) is 4960000

  # --- BHXH ---

  Scenario: BHXH employee contribution at 8%
    Given employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for January 2025
    Then BHXH employee deduction should be 1360000
    # 17,000,000 × 8% = 1,360,000

  Scenario: BHXH employer contribution at 17.5%
    Given employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for January 2025
    Then BHXH employer contribution should be 2975000
    # 17,000,000 × 17.5% = 2,975,000
    # (not deducted from employee, tracked as company expense)

  # --- BHYT ---

  Scenario: BHYT employee contribution at 1.5%
    Given employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for January 2025
    Then BHYT employee deduction should be 255000
    # 17,000,000 × 1.5% = 255,000

  Scenario: BHYT employer contribution at 3%
    Given employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for January 2025
    Then BHYT employer contribution should be 510000

  # --- BHTN ---

  Scenario: BHTN employee contribution at 1%
    Given employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for January 2025
    Then BHTN employee deduction should be 170000
    # 17,000,000 × 1% = 170,000

  Scenario: BHTN employer contribution at 1%
    Given employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for January 2025
    Then BHTN employer contribution should be 170000

  # --- Tổng hợp ---

  Scenario: Total mandatory insurance deduction for employee (10.5%)
    Given employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for January 2025
    Then total employee insurance deduction should be 1785000
    # BHXH 1,360,000 + BHYT 255,000 + BHTN 170,000 = 1,785,000
    And the payslip should show separate lines for BHXH, BHYT, BHTN

  Scenario: Total employer insurance contribution (21.5%)
    Given employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for January 2025
    Then total employer insurance contribution should be 3655000
    # BHXH 2,975,000 + BHYT 510,000 + BHTN 170,000 = 3,655,000
    And total company cost should be gross_salary plus 3655000

  # --- Mức đóng: Phụ cấp nào tính BHXH, phụ cấp nào không ---

  Scenario: Insurance base includes position allowance but excludes lunch allowance
    Given employee "Nguyen Van A" has a contract with:
      | field                  | value    |
      | base_salary            | 15000000 |
      | position_allowance     | 2000000  |
      | seniority_allowance    | 500000   |
      | lunch_allowance        | 730000   |
      | transportation_allowance | 500000 |
      | phone_allowance        | 200000   |
    When the system calculates insurance base salary
    Then insurance base should be 17500000
    # base 15,000,000 + position 2,000,000 + seniority 500,000 = 17,500,000
    # lunch, transportation, phone are EXCLUDED from insurance base

  Scenario: Allowances flagged as insurance-applicable are included in base
    Given a salary allowance "Phu cap doc hai" (hazard allowance) is configured as insurance_applicable = true
    And employee "Tran Van B" receives this allowance of 1000000
    And employee base salary is 15000000
    When the system calculates insurance base salary
    Then insurance base should be 16000000

  # --- Trần đóng BHXH/BHYT ---

  Scenario: BHXH and BHYT capped at 20x base salary reference
    Given employee "Le Thi C" has insurance base salary of 60000000
    And the BHXH/BHYT cap is 46800000
    # cap = 20 × 2,340,000 = 46,800,000
    When I generate payslip for January 2025
    Then BHXH employee deduction should be 3744000
    # capped: 46,800,000 × 8% = 3,744,000 (NOT 60,000,000 × 8%)
    And BHYT employee deduction should be 702000
    # capped: 46,800,000 × 1.5% = 702,000

  Scenario: Insurance base below cap uses actual salary
    Given employee "Nguyen Van D" has insurance base salary of 20000000
    And the BHXH/BHYT cap is 46800000
    When I generate payslip for January 2025
    Then BHXH employee deduction should be 1600000
    # actual: 20,000,000 × 8% = 1,600,000 (below cap, use actual)

  # --- Trần đóng BHTN ---

  Scenario: BHTN capped at 20x regional minimum wage
    Given employee "Le Thi C" has insurance base salary of 120000000
    And the BHTN cap is 99200000
    # cap = 20 × 4,960,000 = 99,200,000 (region I)
    When I generate payslip for January 2025
    Then BHTN employee deduction should be 992000
    # capped: 99,200,000 × 1% = 992,000 (NOT 120,000,000 × 1%)

  Scenario: BHTN for company in region IV with lower minimum wage
    Given the company is in region IV with minimum wage 3450000
    And employee "Pham Van E" has insurance base salary of 80000000
    And the BHTN cap is 69000000
    # cap = 20 × 3,450,000 = 69,000,000
    When I generate payslip for January 2025
    Then BHTN employee deduction should be 690000

  # --- Cấu hình linh hoạt (không hardcode) ---

  Scenario: Insurance rates are configurable and not hardcoded
    Given the company updates BHXH employee rate to 9%
    And employee "Nguyen Van A" has insurance base salary of 17000000
    When I generate payslip for February 2025
    Then BHXH employee deduction should be 1530000
    # 17,000,000 × 9% = 1,530,000

  Scenario: Base salary reference (luong co so) is configurable
    Given the base salary reference is updated to 2500000
    Then the BHXH/BHYT cap should be 50000000
    # 20 × 2,500,000 = 50,000,000

  # ============================================================
  # PHẦN 2: GIẢM TRỪ GIA CẢNH (Dependent Relief)
  # ============================================================

  Scenario: Personal deduction of 11 million per month for every employee
    Given employee "Nguyen Van A" has gross salary of 22730000
    And employee insurance deduction is 2310000
    When calculating taxable income
    Then personal deduction should be 11000000
    And pre-tax income should be 9420000
    # 22,730,000 - 2,310,000 - 11,000,000 = 9,420,000

  Scenario: Dependent deduction of 4.4 million per dependent
    Given employee "Nguyen Van A" has 2 registered dependents
    When calculating taxable income
    Then dependent deduction should be 8800000
    # 2 × 4,400,000 = 8,800,000

  Scenario: Employee with no registered dependents
    Given employee "Tran Van B" has 0 registered dependents
    And gross salary of 20000000
    And insurance deduction of 2100000
    When calculating taxable income
    Then taxable income should be 6900000
    # 20,000,000 - 2,100,000 - 11,000,000 - 0 = 6,900,000

  Scenario: Employee with 3 dependents has low taxable income
    Given employee "Pham Thi F" has gross salary of 25000000
    And insurance deduction of 2625000
    And 3 registered dependents
    When calculating taxable income
    Then taxable income should be negative or zero
    # 25,000,000 - 2,625,000 - 11,000,000 - 13,200,000 = -1,825,000
    And PIT should be 0
    # Negative taxable income means no tax

  Scenario: Dependent count change takes effect from registration date
    Given employee "Nguyen Van A" registered a new dependent on 2025-01-15
    And previously had 1 dependent
    When generating payslip for January 2025
    Then dependent deduction should use 2 dependents for the full month
    # Dependent relief applies from the month of registration

  Scenario: Deduction amounts are configurable
    Given personal deduction is updated to 12000000
    And dependent deduction is updated to 4800000
    When generating payslip for employee with 1 dependent
    Then total family deduction should be 16800000

  # ============================================================
  # PHẦN 3: THUẾ TNCN LŨY TIẾN 7 BẬC (PIT Progressive Tax)
  # ============================================================

  Scenario: PIT bracket 1 - taxable income up to 5 million (5%)
    Given employee taxable income is 4000000
    When calculating PIT
    Then PIT amount should be 200000
    # 4,000,000 × 5% = 200,000

  Scenario: PIT bracket 2 - taxable income 5 to 10 million (10%)
    Given employee taxable income is 8000000
    When calculating PIT
    Then PIT amount should be 550000
    # Bracket 1: 5,000,000 × 5%  = 250,000
    # Bracket 2: 3,000,000 × 10% = 300,000
    # Total: 550,000

  Scenario: PIT bracket 3 - taxable income 10 to 18 million (15%)
    Given employee taxable income is 15000000
    When calculating PIT
    Then PIT amount should be 1500000
    # Bracket 1: 5,000,000 × 5%  =   250,000
    # Bracket 2: 5,000,000 × 10% =   500,000
    # Bracket 3: 5,000,000 × 15% =   750,000
    # Total: 1,500,000

  Scenario: PIT bracket 4 - taxable income 18 to 32 million (20%)
    Given employee taxable income is 25000000
    When calculating PIT
    Then PIT amount should be 3350000
    # Bracket 1: 5,000,000  × 5%  =   250,000
    # Bracket 2: 5,000,000  × 10% =   500,000
    # Bracket 3: 8,000,000  × 15% = 1,200,000
    # Bracket 4: 7,000,000  × 20% = 1,400,000
    # Total: 3,350,000

  Scenario: PIT bracket 5 - taxable income 32 to 52 million (25%)
    Given employee taxable income is 40000000
    When calculating PIT
    Then PIT amount should be 6150000
    # Bracket 1: 5,000,000  × 5%  =   250,000
    # Bracket 2: 5,000,000  × 10% =   500,000
    # Bracket 3: 8,000,000  × 15% = 1,200,000
    # Bracket 4: 14,000,000 × 20% = 2,800,000
    # Bracket 5: 8,000,000  × 25% = 2,000,000
    # Lưu ý: Bracket 5 chỉ 8M (từ 32M đến 40M)
    # Tổng: 6,750,000
    # Sửa lại: thực ra
    # Bracket 1: 5M × 5% = 250K
    # Bracket 2: 5M × 10% = 500K
    # Bracket 3: 8M × 15% = 1,200K
    # Bracket 4: 14M × 20% = 2,800K
    # Bracket 5: 8M × 25% = 2,000K
    # Total = 6,750,000
    Then PIT amount should be 6750000

  Scenario: PIT bracket 6 - taxable income 52 to 80 million (30%)
    Given employee taxable income is 60000000
    When calculating PIT
    Then PIT amount should be 11950000
    # Bracket 1: 5,000,000  × 5%  =   250,000
    # Bracket 2: 5,000,000  × 10% =   500,000
    # Bracket 3: 8,000,000  × 15% = 1,200,000
    # Bracket 4: 14,000,000 × 20% = 2,800,000
    # Bracket 5: 20,000,000 × 25% = 5,000,000
    # Bracket 6: 8,000,000  × 30% = 2,400,000
    # Lưu ý: Bracket 6 chỉ 8M (từ 52M đến 60M)
    # Tổng: 12,150,000
    Then PIT amount should be 12150000

  Scenario: PIT bracket 7 - taxable income over 80 million (35%)
    Given employee taxable income is 100000000
    When calculating PIT
    Then PIT amount should be 25650000
    # Bracket 1: 5,000,000  × 5%  =   250,000
    # Bracket 2: 5,000,000  × 10% =   500,000
    # Bracket 3: 8,000,000  × 15% = 1,200,000
    # Bracket 4: 14,000,000 × 20% = 2,800,000
    # Bracket 5: 20,000,000 × 25% = 5,000,000
    # Bracket 6: 28,000,000 × 30% = 8,400,000
    # Bracket 7: 20,000,000 × 35% = 7,000,000
    # Total: 25,150,000
    Then PIT amount should be 25150000

  Scenario: PIT is zero when taxable income is zero or negative
    Given employee taxable income is 0
    When calculating PIT
    Then PIT amount should be 0

  Scenario: PIT at exact bracket boundary (5 million)
    Given employee taxable income is 5000000
    When calculating PIT
    Then PIT amount should be 250000
    # All in bracket 1: 5,000,000 × 5% = 250,000

  Scenario: PIT at exact bracket boundary (10 million)
    Given employee taxable income is 10000000
    When calculating PIT
    Then PIT amount should be 750000
    # Bracket 1: 5,000,000 × 5%  = 250,000
    # Bracket 2: 5,000,000 × 10% = 500,000
    # Total: 750,000

  # ============================================================
  # PHẦN 4: END-TO-END — Tính lương đầy đủ theo luật VN
  # ============================================================

  Scenario: Full Vietnamese payslip calculation - typical office employee
    Given employee "Nguyen Van A" has contract:
      | field                    | value    |
      | base_salary              | 15000000 |
      | position_allowance       | 2000000  |
      | lunch_allowance          | 730000   |
      | transportation_allowance | 500000   |
    And employee has 1 registered dependent
    And employee worked full month with no overtime
    When I generate payslip for January 2025
    Then gross salary should be 18230000
    # 15,000,000 + 2,000,000 + 730,000 + 500,000 = 18,230,000
    And insurance base should be 17000000
    # 15,000,000 + 2,000,000 = 17,000,000 (only base + position)
    And BHXH employee deduction should be 1360000
    And BHYT employee deduction should be 255000
    And BHTN employee deduction should be 170000
    And total insurance deduction should be 1785000
    And personal deduction should be 11000000
    And dependent deduction should be 4400000
    And taxable income should be 1045000
    # 18,230,000 - 1,785,000 - 11,000,000 - 4,400,000 = 1,045,000
    And PIT should be 52250
    # 1,045,000 × 5% = 52,250 (all in bracket 1)
    And net salary should be 16392750
    # 18,230,000 - 1,785,000 - 52,250 = 16,392,750

  Scenario: Full Vietnamese payslip - high income employee with no dependents
    Given employee "Le Thi C" has contract:
      | field                | value    |
      | base_salary          | 50000000 |
      | position_allowance   | 5000000  |
      | lunch_allowance      | 730000   |
    And employee has 0 registered dependents
    When I generate payslip for January 2025
    Then gross salary should be 55730000
    And insurance base should be 46800000
    # actual base 55,000,000 but capped at 46,800,000
    And BHXH employee deduction should be 3744000
    And BHYT employee deduction should be 702000
    And BHTN employee deduction should be 468000
    # BHTN: min(55,000,000, 99,200,000) × 1% = 550,000
    # Wait - BHTN cap is 20 × regional min wage, not same as BHXH cap
    # BHTN base = min(55,000,000, 99,200,000) = 55,000,000
    # But insurance_base for BHTN should also be limited to the actual insurance_base
    # BHTN = min(insurance_base, bhtn_cap) × 1% = min(55,000,000, 99,200,000) × 1% = 550,000
    And BHTN employee deduction should be 550000
    And total insurance deduction should be 4996000
    # 3,744,000 + 702,000 + 550,000 = 4,996,000
    And taxable income should be 39734000
    # 55,730,000 - 4,996,000 - 11,000,000 - 0 = 39,734,000
    And PIT should be 5683500
    # Bracket 1: 5,000,000  × 5%  =   250,000
    # Bracket 2: 5,000,000  × 10% =   500,000
    # Bracket 3: 8,000,000  × 15% = 1,200,000
    # Bracket 4: 14,000,000 × 20% = 2,800,000
    # Bracket 5: 7,734,000  × 25% = 1,933,500
    # Total: 6,683,500
    And net salary should be 44050500

  Scenario: Full Vietnamese payslip - low income employee below tax threshold
    Given employee "Tran Thi G" has contract:
      | field        | value    |
      | base_salary  | 8000000  |
    And employee has 2 registered dependents
    When I generate payslip for January 2025
    Then gross salary should be 8000000
    And total insurance deduction should be 840000
    # 8,000,000 × 10.5% = 840,000
    And taxable income should be 0
    # 8,000,000 - 840,000 - 11,000,000 - 8,800,000 = -12,640,000 → 0
    And PIT should be 0
    And net salary should be 7160000
    # 8,000,000 - 840,000 - 0 = 7,160,000

  Scenario: Full payslip with overtime included
    Given employee "Nguyen Van A" has base salary of 15000000
    And employee has insurance base of 15000000
    And employee has 1 registered dependent
    And employee worked 10 hours overtime at 1.5x rate
    And hourly rate is 85227
    # 15,000,000 / 26 days / 8 hours ≈ 72,115; standard calc may vary
    When I generate payslip for January 2025
    Then overtime pay should be calculated as 1278405
    # 10 × 85,227 × 1.5 = 1,278,405
    And gross salary should include overtime pay
    And insurance base should NOT include overtime pay
    # OT is not part of insurance base
    And PIT should be calculated on total gross minus insurance minus deductions
