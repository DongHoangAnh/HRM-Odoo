Feature: Payroll Calculation and Processing
  As a Payroll Manager
  I want to calculate and process employee payroll
  So that employees are paid accurately and on time

  Background:
    Given I am logged in as a payroll manager
    And the employee "John Doe" has a contract with salary 60000/year
    And the payroll period "January 2025" is defined

  Scenario: Generate payslip for employee
    Given the employee has work entries for January 2025
    When I generate a payslip for the employee
    Then a payslip should be created
    And it should include all work entries
    And salary should be calculated

  Scenario: Payslip calculation with basic salary
    Given employee monthly salary is 5000
    When I generate payslip for January
    Then gross_salary should include 5000

  Scenario: Payslip includes overtime pay
    Given the employee worked 10 hours overtime
    And overtime rate is 1.5x
    When I generate payslip
    Then overtime_pay should be calculated as (10 * hourly_rate * 1.5)

  Scenario: Payslip includes commissions
    Given the employee has commission structure
    When I generate payslip with sales data
    Then commission_amount should be included

  Scenario: Payslip deductions for tax
    Given employee has income tax rate 15%
    When I generate payslip
    Then tax_deduction should be (gross_salary * 0.15)
    And net_salary should reflect deduction

  Scenario: Payslip deductions for social security
    Given social security rate 8%
    When I generate payslip
    Then social_security_deduction should be calculated
    And included in total deductions

  Scenario: Payslip with loan deduction
    Given employee has outstanding loan with monthly payment 500
    When I generate payslip
    Then loan_deduction should be 500
    And included in deductions

  Scenario: Payslip with meal vouchers
    Given employee has meal voucher benefit 10/day
    When I generate payslip for 20 working days
    Then meal_voucher_value should be 200

  Scenario: Payslip approval workflow
    Given a draft payslip
    When an accountant reviews and approves it
    Then the state should be "approved"
    And employees should be able to see it

  Scenario: Payslip rejection
    Given an approved payslip
    When I find an error and reject it
    Then the state should go back to "draft"
    And corrections can be made

  Scenario: Batch payslip generation
    Given all employees for January 2025
    When I batch generate payslips
    Then payslips should be created for all employees
    And calculations should use correct work entries

  Scenario: Payslip variation report
    Given multiple employees' payslips
    When I generate variation report
    Then I should see salary differences compared to previous month

  Scenario: Payment method selection
    When employee has payment method "Bank Transfer"
    Then salary should be transferred to bank account

  Scenario: Payslip slip document generation
    Given an approved payslip
    When I generate PDF
    Then a professional payslip document should be created
    And ready to send to employee

  Scenario: Payslip employee portal access
    Given an employee accessing payroll portal
    When I view the payslip
    Then I should see gross/net salary
    And deductions breakdown
    And personal details should be masked

  Scenario: Year-end bonus inclusion
    Given a year-end bonus policy
    When I generate December payslip
    Then bonus_amount should be included
    And taxed appropriately

  Scenario: Salary advance deduction
    Given employee received salary advance 1000
    When I generate next payslip
    Then advance_deduction should be 1000
    And deducted from gross salary

  Scenario: Leave encashment
    Given employee has 5 unused vacation days
    And encashment is allowed
    When I process year-end
    Then encashment_amount should be (5 * daily_rate)
    And included in final payslip

  Scenario: Payslip with multiple departments
    Given employee transferred to different department mid-month
    When I generate payslip
    Then salary should reflect both periods
    And department attribution should be tracked

  Scenario: Payslip adjustment entry
    Given a mistake found in payslip
    When I create adjustment entry
    Then it should show in next payslip
    And correction should be transparent

  Scenario: Payslip withholding tax
    Given progressive tax structure
    When I calculate tax
    Then correct tax slab should be applied
    And withholding should be accurate

  Scenario: Payslip employee provident fund
    Given employee contributes 12% to EPF
    When I generate payslip
    Then epf_contribution should be 12% of basic salary
    And matched by employer
