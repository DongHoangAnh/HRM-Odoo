Feature: Archive and Unarchive Employees
  As a Human Resources Manager
  I want to archive and unarchive employees
  So that I can manage active workforce and maintain historical records

  Background:
    Given I am logged in as an HR user
    And the employee "John Doe" exists and is active

  Scenario: Archive active employee
    When I archive the employee "John Doe"
    Then the employee's active status should be False
    And the resource record should be archived
    And the employee's presence state should show "archive"

  Scenario: Archive employee with manager relationships
    Given the employee "John Doe" has manager "Jane Manager"
    And the employee has subordinate "Bob Subordinate"
    When I archive "John Doe"
    Then "Bob Subordinate's" parent_id should be cleared
    And the manager relationship should remain intact

  Scenario: Archive employee with coach relationship
    Given the employee "John Doe" has coach "Tom Coach"
    When I archive "John Doe"
    Then other employees should have their coach cleared if they are "John Doe"

  Scenario: Archive employee as manager
    Given "John Doe" is the manager of 3 employees
    When I archive "John Doe"
    Then all subordinates should have parent_id cleared
    And the employees should no longer report to "John Doe"

  Scenario: Archive employee with one subordinate shows wizard
    Given "John Doe" has one subordinate
    When I archive "John Doe"
    Then the departure wizard should be displayed
    And user can enter departure reason and description

  Scenario: Archive multiple employees without wizard
    Given I select multiple employees for archival
    When I archive them
    Then no wizard should be displayed
    And all employees should be archived
    And the no_wizard context should suppress the wizard

  Scenario: Archive employee stores departure information
    Given the departure wizard is displayed
    When I enter:
      | Field                | Value                    |
      | departure_date       | 2025-03-31               |
      | departure_reason_id  | Personal Reasons         |
      | departure_description| Accepted another offer   |
    And I confirm the archival
    Then the employee should be archived
    And the departure information should be stored
    And a message post should be created

  Scenario: Unarchive archived employee
    Given the employee "John Doe" is archived
    And has departure information filled
    When I unarchive "John Doe"
    Then the employee's active status should be True
    And the departure_date should be cleared
    And the departure_reason_id should be cleared
    And the departure_description should be cleared

  Scenario: Cannot archive employee with pending contracts
    Given the employee has an active contract
    When I try to archive the employee
    Then the employee should still be archived
    And the contract remains unchanged

  Scenario: Archive employee clears relationships
    Given:
      | Field            | Value    |
      | parent_id        | Manager  |
      | coach_id         | Coach    |
    When I archive the employee
    Then the relationships should be cleared for other employees pointing here

  Scenario: Prevent circular manager relationships
    Given employee "A" has no manager
    When I try to set "A" as manager of "B"
    And then set "B" as manager of "A"
    Then the system should prevent circular relationships

  Scenario: Get fields to empty on archive
    When I get the employee fields to empty
    Then it should return:
      | Field     |
      | parent_id |
      | coach_id  |

  Scenario: Handle departure reason selection
    Given the employee is being archived
    When I select a departure reason
    Then the reason should be stored with the employee
    And the reason should be visible in the departure wizard

  Scenario: Handle departure description
    Given the employee is being archived
    When I enter a departure description
    Then the description should be posted as a message
    And it should be visible in the employee's message thread

  Scenario: Re-archive already archived employee
    Given the employee is already archived
    When I try to archive again
    Then no error should occur
    And the archive status should remain unchanged

  Scenario: Unarchive with reactivation
    Given the employee is archived for 6 months
    When I unarchive the employee
    Then the employee should be active
    And all departure information should be cleared
    And the employee should appear in active employee lists
