Feature: Leave Accrual Plan Management
  As an HR Manager
  I want to configure leave accrual plans
  So that leave balances can grow automatically over time

  Background:
    Given I am logged in as an HR user
    And the company "Tech Corp" exists
    And the leave type "Annual Leave" exists

  Scenario: Create unnamed accrual plan uses default name
    When I create a leave accrual plan without a name
    Then the plan name should default to "Unnamed Plan"

  Scenario: Company is derived from the linked leave type
    Given a leave type tied to company "Tech Corp"
    When I create an accrual plan for that leave type
    Then company_id should be "Tech Corp"

  Scenario: Employee count reflects distinct employees on allocations
    Given an accrual plan with allocations for two employees
    When I compute employees_count
    Then employees_count should be 2

  Scenario: Level count reflects the number of milestones
    Given an accrual plan with 3 levels
    When I compute level_count
    Then level_count should be 3

  Scenario: Transition mode is only shown when more than one level exists
    Given an accrual plan with one level
    When I compute show_transition_mode
    Then show_transition_mode should be False
    Given an accrual plan with two levels
    When I compute show_transition_mode
    Then show_transition_mode should be True

  Scenario: Carryover day is clamped to the number of days in the month
    Given an accrual plan with carryover_month "2" and carryover_day "31"
    When I compute carryover_day
    Then carryover_day should become "29"

  Scenario: Open accrual plan employees action returns linked employees
    Given an accrual plan with employee allocations
    When I open accrual plan employees
    Then the action should open hr.employee records for allocated employees

  Scenario: Create accrual plan level action passes defaults in context
    Given an accrual plan that can be carried over
    When I create a new milestone
    Then the context should include defaults for carryover, gain time, and added value type

  Scenario: Open accrual plan level action opens the selected milestone
    Given an accrual plan level exists
    When I open that milestone for editing
    Then the action should target hr.leave.accrual.level with that res_id

  Scenario: Copying an accrual plan appends copy to the name
    Given an accrual plan named "Seniority Plan"
    When I duplicate the plan
    Then the copied name should be "Seniority Plan (copy)"

  Scenario: Prevent deleting an accrual plan linked to active allocations
    Given an accrual plan linked to a non-cancelled allocation
    When I try to delete the plan
    Then a validation error should be raised
    And the message should explain that linked allocations must be deleted or cancelled first
