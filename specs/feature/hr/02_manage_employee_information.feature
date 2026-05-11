Feature: Manage Employee Information
  As a Human Resources Manager
  I want to update and manage employee information
  So that employee records remain current and accurate

  Background:
    Given I am logged in as an HR user
    And the employee "John Doe" exists
    And the employee has basic information filled in

  Scenario: Update employee name
    When I update the employee's name from "John Doe" to "John D. Doe"
    Then the employee's name should be updated
    And the resource record name should be synchronized
    And a tracking log should record the name change

  Scenario: Update employee work contact details
    Given the employee has a work contact
    When I update the employee's work phone to "+1 (555) 123-4567"
    And I update the employee's work email to "john.new@company.com"
    Then the work phone should be formatted to international format
    And the work email should be stored
    And if the work contact is unique to this employee, the contact should be updated

  Scenario: Synchronize work contact details to multiple employees
    Given multiple employees share the same work contact
    When I update one employee's work phone
    Then the update should not propagate to the shared work contact

  Scenario: Create work contact if missing
    Given the employee has no work contact
    When I save the employee record
    Then a work contact should be automatically created
    And the work contact should be linked to the employee

  Scenario: Update employee personal information
    When I update the employee's personal information:
      | Field               | Value              |
      | legal_name          | John Paul Doe      |
      | birthday            | 1990-05-15         |
      | place_of_birth      | Los Angeles        |
      | country_of_birth    | United States      |
    Then all personal information should be stored
    And the employee should have access to this private data

  Scenario: Update employee timezone
    When I update the employee's timezone to "Europe/London"
    Then the employee's timezone should be updated
    And if the employee has a linked user, the user's timezone should also be updated

  Scenario: Update employee manager
    Given another employee "Jane Manager" exists
    When I set "Jane Manager" as the manager of "John Doe"
    Then "John Doe" should have "Jane Manager" as parent_id
    And "John Doe" should appear in "Jane Manager's" child_ids
    And the manager field should be tracked

  Scenario: Update employee coach
    Given another employee "Tom Coach" exists
    When I set "Tom Coach" as the coach of "John Doe"
    Then "John Doe" should have "Tom Coach" as coach_id
    And the coach should be from the same company or company-agnostic

  Scenario: Automatically update coach when manager changes
    Given the employee has manager "Jane Manager"
    And the employee has no explicit coach set
    When I change the manager to "Tom Manager"
    Then the coach should automatically update to "Tom Manager"

  Scenario: Update phone validation
    When I update work_phone to "invalid_phone" for a company in US
    Then the phone should be formatted based on the country
    And if the format is invalid, the system should attempt international format

  Scenario: Update employee company
    Given the employee works in "Company A"
    When I try to change the employee's company to "Company B"
    Then a warning should be displayed about potential data loss
    And the employee should not be moved automatically
    And a recommendation to create a new employee should be shown

  Scenario: Update employee contract dates
    When I update the employee's contract_date_start to "2024-01-01"
    And I update the contract_date_end to "2024-12-31"
    Then the contract dates should be stored in the version
    And the employee's is_in_contract status should be updated

  Scenario: Prevent empty contract end date when start date exists
    Given the employee has contract_date_start set
    When I try to update contract_date_end to empty
    Then the system should allow it for indefinite contracts
    And is_in_contract should return False for dates after an empty date

  Scenario: Update employee categories
    Given the employee category "Management" and "Remote" exist
    When I update the employee's categories to include both
    Then the employee should have both categories
    And the employee can be filtered by these categories

  Scenario: Update employee with multiple company restrictions
    Given the employee "John Doe" works in "Company A"
    And "Company B" exists
    When I try to set a manager from "Company B"
    Then the system should only allow managers from "Company A" or company-agnostic managers
    And the manager field domain should be validated

  Scenario: Update employee departure information
    When I update the employee's departure information:
      | Field                   | Value              |
      | departure_date          | 2025-03-31         |
      | departure_reason_id     | Personal           |
      | departure_description   | Resigned           |
    Then the departure information should be stored
    And a message post should be created in the employee's timeline

  Scenario: Track employee information changes
    When I update multiple fields:
      | Field             | Value      |
      | name              | New Name   |
      | place_of_birth    | New City   |
    Then each tracked field should have a log entry
    And the modification history should be accessible

  Scenario: Update employee image
    When I upload a new profile image for the employee
    Then the image_1920 field should be updated
    And the work contact image should be synchronized
    And other image sizes should be computed automatically
