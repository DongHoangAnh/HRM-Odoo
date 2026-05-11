Feature: Employee Time Off Dashboard and Status
  As an Employee or HR user
  I want to see my time off status and dashboard data
  So that I can understand leave balances and current absences

  Background:
    Given I am logged in as an HR user
    And the employee "John Doe" exists

  Scenario: Compute current leave type for a validated leave
    Given the employee is currently on a validated vacation leave
    When I compute current_leave_id
    Then the current leave type should be set

  Scenario: Compute leave status from validated leave
    Given the employee is currently on a validated leave
    When I compute leave status
    Then leave_date_from and leave_date_to should be populated
    And current_leave_state should be "validate"
    And is_absent should be True for absence leaves

  Scenario: Presence state becomes absent when employee is on leave
    Given the employee is on a validated absence leave
    When I compute presence state
    Then hr_presence_state should be "absent"

  Scenario: Allocation counters only include active validated allocations
    Given the employee has active validated allocations and expired allocations
    When I compute allocation counters
    Then allocation_count should ignore expired allocations
    And allocations_count should count only valid allocations

  Scenario: Allocation remaining display shows current balance
    Given the employee has allocations and consumed leaves
    When I compute allocation remaining display
    Then allocation_display should show the allocated total
    And allocation_remaining_display should show the remaining balance

  Scenario: show_leaves is visible for HR users
    Given I have the hr_holidays user group
    When I compute show_leaves
    Then show_leaves should be True

  Scenario: show_leaves is visible for the employee themself
    Given I am the employee's linked user
    When I compute show_leaves
    Then show_leaves should be True

  Scenario: Absent employee search returns current validated leaves
    Given one employee is on a validated leave today
    When I search absent employees
    Then the absent employee should be included in the result

  Scenario: Leave manager follows the parent manager user
    Given the employee has a parent manager user
    When I update the parent_id
    Then leave_manager_id should follow the manager user

  Scenario: Time off dashboard action opens the employee dashboard for self
    Given I am the employee's linked user
    When I open the time off dashboard
    Then the employee dashboard action should be returned

  Scenario: Time off calendar action filters by employee
    Given the employee has time off records
    When I open the time off calendar
    Then the action domain should filter on the employee id
    And the context should hide the employee name and default to the current year
