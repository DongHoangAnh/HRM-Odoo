Feature: Employee Leave Requests and Time Off Management
  As an Employee
  I want to request time off
  So that I can take breaks and manage my schedule

  Background:
    Given I am logged in as an employee
    And the employee "John Doe" exists
    And the leave type "Vacation" exists and requires allocation
    And the leave type "Sick Leave" exists and doesn't require allocation

  Scenario: Create vacation leave request
    When I create a leave request with:
      | Field             | Value       |
      | holiday_status_id | Vacation    |
      | request_date_from | 2025-02-01  |
      | request_date_to   | 2025-02-05  |
      | notes             | Family trip |
    Then the leave request should be created
    And the state should be "confirm" (pending approval)
    And a calendar event should be created automatically

  Scenario: Create half-day leave request
    Given the employee has scheduled working time
    When I create a leave request for half day (morning only)
    Then the number_of_days should be 0.5
    And the leave should be recognized as partial day

  Scenario: Create hourly leave request
    Given the leave type supports hourly requests
    When I create a leave request for 4 hours
    Then number_of_hours should be 4.0
    And request_unit_hours should be True

  Scenario: Leave balance validation on creation
    Given the employee has 5 days vacation balance
    When I request 10 days of vacation
    Then a validation warning should appear
    And the message should indicate insufficient balance

  Scenario: Leave balance sufficient
    Given the employee has 10 days vacation balance
    When I request 5 days of vacation
    Then the request should be created successfully
    And no validation error should occur

  Scenario: Sick leave without allocation requirement
    When I create a sick leave request
    Then no balance check should occur
    And the request should be created immediately

  Scenario: Submit leave for approval
    Given a leave request in "confirm" state
    When I submit it for approval
    Then the state should change to "confirm" (submitted)
    And approval notifications should be sent to managers

  Scenario: Manager approves leave request
    Given a leave request pending approval
    And I am the employee's manager
    When I approve the leave
    Then the state should change to "validate"
    And the first_approver_id should be set to me
    And the employee should be notified

  Scenario: Manager refuses leave request
    Given a leave request pending approval
    When I refuse the leave with reason "Business conflict"
    Then the state should change to "refuse"
    And the reason should be recorded
    And the employee should be notified

  Scenario: Two-level approval workflow
    Given the leave type requires both HR and Manager approval
    And I am the employee's manager
    When I approve the leave
    Then the state should change to "validate1" (first approval)
    And it should wait for second approval from HR

  Scenario: HR user completes two-level approval
    Given a leave in "validate1" state (awaiting HR approval)
    And I am an HR officer
    When I approve the leave
    Then the state should change to "validate" (fully approved)
    And the second_approver_id should be set to me

  Scenario: HR user refuses after first approval
    Given a leave in "validate1" state
    When I refuse the leave
    Then the state should change to "refuse"
    And the applicant should be notified

  Scenario: Deduct approved leave from balance
    Given an approved leave for 3 days
    And the employee has 10 days balance
    When the leave is in "validate" state
    Then virtual_remaining_leaves should be 7 days

  Scenario: Cancel approved leave request
    Given an approved leave (state = "validate")
    When I cancel it
    Then the state should change to "cancel"
    And the days should not be deducted from balance

  Scenario: Reset leave request to draft
    Given an approved leave request
    When I reset it to draft with appropriate permissions
    Then the state should change back to "confirm"
    And re-approval should be required

  Scenario: Cannot approve own leave request
    Given my own leave request
    When I try to approve it
    Then an error should occur
    And the message should indicate self-approval is not allowed

  Scenario: Leave duration computation
    Given a leave from Monday to Friday
    And the resource calendar defines 40-hour weeks
    When I compute number_of_days
    Then it should be 5.0 (excluding weekends)

  Scenario: Leave duration with holidays
    Given a leave that includes company holidays
    When I compute number_of_days
    Then the company holidays should not be counted

  Scenario: Create meeting on approved leave
    Given an approved leave request
    When a calendar event is created
    Then it should be linked to the leave via meeting_id
    And the event should show as "Busy"

  Scenario: Leave reason tracking
    When I create a leave request with private_name "Medical appointment"
    Then the private_name should be visible only to HR staff
    And regular employees should see generic "Time Off"

  Scenario: Compute leave balance at specific date
    Given the employee has:
      | Date       | Leave Type | Days |
      | 2025-01-01 | Vacation   | 20   |
      | 2025-02-01 | Vacation   | -5   |
      | 2025-02-15 | Vacation   | -3   |
    When I check max_leaves as of 2025-02-20
    Then it should show 20 days
    And virtual_remaining_leaves should show 12 days

  Scenario: Leave type color in calendar
    Given leaves have different colors
    When I view the calendar
    Then each leave type should be displayed in its assigned color
