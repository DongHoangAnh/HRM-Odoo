Feature: Leave Allocation and Balance Management
  As an HR Manager
  I want to manage leave allocations for employees
  So that employees have proper leave balances throughout the year

  Background:
    Given I am logged in as an HR user
    And the employee "John Doe" exists
    And the leave type "Annual Leave" requires allocation

  Scenario: Create annual leave allocation
    When I create a leave allocation:
      | Field              | Value           |
      | employee_id        | John Doe        |
      | holiday_status_id  | Annual Leave    |
      | number_of_days     | 20              |
      | date_from          | 2025-01-01      |
      | date_to            | 2025-12-31      |
    Then the allocation should be created
    And the employee's leave balance should increase by 20 days

  Scenario: Employee has valid allocation to request leave
    Given the employee has 20 days annual leave allocation
    When I check if employee has valid allocation
    Then the domain should allow leave requests for this type

  Scenario: Allocation deducted on leave approval
    Given an allocation of 20 days
    And a leave request for 5 days in "confirm" state
    When the leave is approved (state = "validate")
    Then the allocation should be decreased by 5 days
    And the allocation remaining should be 15 days

  Scenario: Multiple allocations same employee same year
    Given the employee has two allocations:
      | Period      | Days |
      | Jan-Jun     | 10   |
      | Jul-Dec     | 10   |
    When I check total balance
    Then total available should be 20 days

  Scenario: Allocation expiry
    Given an allocation expiring on 2025-03-31
    And the employee hasn't used all days
    When I check on 2025-04-01
    Then the unused days should be marked as expired
    And should not be available for new requests

  Scenario: Carryover allocation to next year
    Given an allocation that supports carryover
    And 5 unused days as of 2025-12-31
    When I process year-end
    Then 5 days should carry over to 2026
    And new allocation for 2026 should include carryover

  Scenario: Carryover limit enforcement
    Given carryover maximum is set to 3 days
    And 5 unused days exist
    When I process carryover
    Then only 3 days should be carried over
    And 2 days should expire

  Scenario: Leave type with unlimited allocation
    Given a leave type with requires_allocation = False
    When I create a leave request for this type
    Then no allocation check should occur
    And the request should not affect balance

  Scenario: Compute remaining leaves
    Given:
      | Element                | Value |
      | Total Allocation       | 20    |
      | Approved Leave Used    | 5     |
      | Requested (Pending)    | 3     |
    When I compute virtual_remaining_leaves
    Then it should be 12 days (20 - 5 - 3)

  Scenario: Leave allocation request workflow
    Given an HR officer creates an allocation
    When it's in draft state
    Then the employee should not see any balance increase

  Scenario: Validate leave allocation
    Given a draft leave allocation
    When an HR manager validates it
    Then the state should be "validate"
    And the balance should be updated

  Scenario: Refuse leave allocation
    Given a draft leave allocation
    When an HR manager refuses it
    Then the state should be "refuse"
    And no balance change should occur

  Scenario: Allocation by department
    Given I want to allocate leaves to an entire department
    When I create allocations for all employees in HR department
    Then each employee should receive the allocation

  Scenario: Multiple allocations same employee same type
    Given an employee with allocation "20 days 2024"
    When I create another allocation "15 days 2025"
    Then both allocations should coexist
    And they should be tracked separately by year

  Scenario: Show has_valid_allocation on leave type
    Given an employee with valid allocation
    When I check has_valid_allocation field
    Then it should be True

  Scenario: Show no valid allocation
    Given an employee without allocation
    When I check has_valid_allocation field
    Then it should be False
    And the leave type should not be available for requests

  Scenario: Edit allocation before validation
    Given a draft allocation
    When I edit the number_of_days from 20 to 25
    Then the change should be saved
    And no balance update should occur until validation
