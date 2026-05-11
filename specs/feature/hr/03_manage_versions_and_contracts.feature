Feature: Manage Employee Versions and Contract Management
  As a Human Resources Manager
  I want to create and manage employee versions with contract dates
  So that I can track employee history and contract changes

  Background:
    Given I am logged in as an HR user
    And the employee "John Doe" exists
    And the resource calendar "Standard 40h" is available

  Scenario: Create initial employee version
    When I create an employee "Alice Smith"
    Then an initial hr.version record should be created automatically
    And the version should have date_version set to today
    And the employee's current_version_id should reference this version

  Scenario: Create new employee version at specific date
    Given the employee "John Doe" exists
    When I create a new version for the employee with date_version "2025-02-01"
    Then a new hr.version record should be created
    And the new version should have date_version "2025-02-01"
    And the new version should copy data from the previous version

  Scenario: Create contract on new version date
    Given the employee "John Doe" has a version on 2025-01-01
    When I create a new version with contract_date_start "2025-03-01"
    Then the new version should be created
    And the version's contract_date_start should be "2025-03-01"

  Scenario: Get employee version for specific date
    Given the employee "John Doe" has versions on:
      | date_version | 2024-01-01 |
      | date_version | 2024-06-01 |
      | date_version | 2025-01-01 |
    When I get the version for date "2024-08-15"
    Then the version with date_version "2024-06-01" should be returned

  Scenario: Get current employee version
    Given the employee "John Doe" has versions on:
      | date_version | 2024-01-01 |
      | date_version | 2025-01-01 |
    When I get the current version
    Then the version with the most recent date_version should be returned

  Scenario: Compute current version automatically
    Given the employee "John Doe" has versions with different date_versions
    When the date changes to 2025-06-01
    Then the employee's current_version_id should be computed to the appropriate version
    And the computed version should be stored for performance

  Scenario: Update version fields
    Given the employee "John Doe" has a current version
    When I update the version's contract_wage to 5000
    And I update the resource_calendar_id to "Extended 45h"
    Then the changes should be written to the version
    And the employee's inherited fields should reflect the new values

  Scenario: Create contract for employee without existing contract
    Given the employee "John Doe" has no contract on 2025-03-15
    When I create a contract starting on 2025-03-15
    Then a contract should be created with contract_date_start "2025-03-15"
    And the contract_date_end should be set to the start of next contract or False

  Scenario: Check if employee is in contract at specific date
    Given the employee "John Doe" has contract from 2024-01-01 to 2024-12-31
    When I check if employee is in contract on 2024-06-15
    Then the result should be True
    When I check if employee is in contract on 2025-01-15
    Then the result should be False

  Scenario: Get all contract date ranges for employee
    Given the employee "John Doe" has contracts:
      | contract_date_start | contract_date_end |
      | 2024-01-01          | 2024-06-30        |
      | 2024-07-01          | False             |
    When I get all contract dates
    Then a list of (start_date, end_date) tuples should be returned
    And the list should have two entries

  Scenario: Get contract for specific date
    Given the employee "John Doe" has contracts:
      | contract_date_start | contract_date_end |
      | 2024-01-01          | 2024-06-30        |
      | 2024-07-01          | False             |
    When I get contract for date 2024-05-15
    Then (2024-01-01, 2024-06-30) should be returned
    When I get contract for date 2024-07-15
    Then (2024-07-01, False) should be returned

  Scenario: Create version with same date as existing version
    Given the employee has a version with date_version "2025-01-01"
    When I try to create a version with date_version "2025-01-01"
    Then the existing version should be returned without creating a duplicate

  Scenario: Update contract date end when creating new version
    Given the employee has multiple contracts with same start date
    When I create a new version with a different contract_date_end
    Then all versions with the same contract_date_start should be synchronized
    And all should have the updated contract_date_end

  Scenario: Get first version date of employee
    Given the employee has versions starting from:
      | date_version |
      | 2023-01-15   |
      | 2024-01-01   |
      | 2025-01-01   |
    When I get the first version date with no_gap=True
    Then the date 2023-01-15 should be returned

  Scenario: Get first contract date with gap checking
    Given the employee has contracts with gaps:
      | contract_date_start | contract_date_end |
      | 2022-01-01          | 2022-06-30        |
      | 2023-01-01          | 2023-12-31        |
    When I get first contract date with no_gap=True
    Then the date with gap > 4 days should stop the search

  Scenario: Handle permanent contracts
    Given the employee has a permanent contract
    When I check contract dates
    Then the contract_date_end should be False
    And the employee should be considered always in contract
