Feature: Work Entry Management and Payroll Integration
  As an HR Manager
  I want to manage work entries for employees
  So that payroll can be calculated accurately based on actual work

  Background:
    Given I am logged in as an HR manager
    And the employee "John Doe" exists
    And work entry types are configured:
      | Type              | Code | Display Code |
      | Normal Work       | 0    | W             |
      | Sick Leave        | 1    | S             |
      | Paid Leave        | 2    | PTO           |
      | Unpaid Leave      | 3    | UNPTO         |
      | Public Holiday    | 4    | PH            |

  Scenario: Create work entry for normal work day
    When I create a work entry:
      | Field                | Value       |
      | employee_id          | John Doe    |
      | date                 | 2025-01-15  |
      | work_entry_type_id   | Normal Work |
      | duration             | 8.0         |
    Then the work entry should be created
    And the state should be "draft"
    And the display_name should show "Normal Work - 8h00"

  Scenario: Work entry with half day
    When I create a work entry with duration 4.0
    Then display_name should show "4h00"
    And the system should recognize it as half day

  Scenario: Validate work entry
    Given a work entry in "draft" state
    When I validate it
    Then the state should change to "validated"
    And it should be included in payslip calculations

  Scenario: Cancel work entry
    Given a work entry in "validated" state
    When I cancel it
    Then the state should change to "cancelled"
    And it should be excluded from payroll

  Scenario: Duration validation
    When I try to create a work entry with duration 0
    Then a validation error should occur
    And the message should state "Duration must be positive"

  Scenario: Duration exceeds 24 hours validation
    When I try to create a work entry with duration 25
    Then a validation error should occur
    And the message should state "Duration cannot exceed 24 hours"

  Scenario: Auto-assign employee version
    Given the employee "John Doe" has a contract on 2025-01-15
    When I create a work entry for that date
    Then version_id should be automatically set
    And it should be the active contract for that date

  Scenario: Work entry conflict detection
    Given two overlapping work entries for the same employee same day
    When the system checks for conflicts
    Then both should have state "conflict"
    And they should be flagged for resolution

  Scenario: Resolve work entry conflict
    Given conflicting work entries
    When I delete the duplicate entry
    Then the remaining entry should have state "draft"
    And the conflict should be resolved

  Scenario: Work entry source tracking
    When a work entry is created from:
      | Source       |
      | Manual Entry |
      | Attendance   |
      | Contract     |
    Then work_entry_source should track the origin

  Scenario: Link work entry to contract/version
    Given an employee with multiple contracts
    When I create a work entry on contract transition date
    Then version_id should reference the correct contract

  Scenario: Batch create work entries
    When I generate work entries for all employees for month "January"
    Then work entries should be created for each employee
    And based on their attendance and contracts

  Scenario: Work entry overtime hours
    Given a work entry with 10 hours duration
    And standard work is 8 hours
    When payroll is calculated
    Then 2 hours should be flagged as overtime

  Scenario: Work entry with payment rate
    When I set amount_rate to 100 for a work entry
    Then the rate should be stored for payroll calculation

  Scenario: Work entry country context
    Given an employee in "France"
    When I create a work entry
    Then country_id should be "France"
    And localized labor laws should apply

  Scenario: Work entry department tracking
    Given an employee in "Engineering" department
    When I create a work entry
    Then department_id should be "Engineering"

  Scenario: Work entry company context
    Given an employee in "Company A"
    When I create a work entry
    Then company_id should be "Company A"

  Scenario: Compute work entry display name
    Given a work entry for "Sick Leave" with 8 hours
    When I compute display_name
    Then it should show "Sick Leave - 8h00"

  Scenario: Work entry index optimization
    When the system checks work entries for a date range
    Then the compound index should optimize query performance

  Scenario: Work entry state transitions
    Given a work entry in "draft" state
    When I validate it
    Then state should be "validated"
    When it's included in payslip
    Then state should change to "validated"
    When I cancel it
    Then state should be "cancelled"

  Scenario: Multiple work entry types same day
    When an employee has:
      | Time Slot | Type        | Duration |
      | 09-12     | Normal Work | 3        |
      | 13-17     | Normal Work | 4        |
      | 17-18     | Overtime    | 1        |
    Then total should be 8 hours normal + 1 overtime
    And both entries should be validated separately

  Scenario: Bulk validate work entries
    Given 10 draft work entries
    When I validate all at once
    Then all should have state "validated"
    And ready for payslip generation

  Scenario: Work entry deletion safeguard
    Given a work entry in "validated" state
    When I try to delete it
    Then a warning should appear
    And require confirmation

  Scenario: Work entry history tracking
    When a work entry is modified
    Then modifications should be tracked
    And history should show who changed what and when
