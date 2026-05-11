Feature: Leave Type Configuration and Validation
  As an HR Manager
  I want to configure leave types correctly
  So that leave requests, balances, and accruals behave as intended

  Background:
    Given I am logged in as an HR manager
    And the company "Tech Corp" exists

  Scenario: Create leave type with default request settings
    When I create a leave type named "Annual Leave"
    Then the leave type should be active
    And the default request unit should be "day"
    And requires_allocation should default to True

  Scenario: Search valid leave types returns types with active allocations
    Given the employee has a valid allocation for "Annual Leave"
    When I search leave types with the valid allocation search
    Then the leave type should be included in the result

  Scenario: Leave type without allocation requirement is always valid
    Given a leave type with requires_allocation set to False
    When I check has_valid_allocation
    Then the result should be True

  Scenario: Leave type with allocation requirement becomes invalid without balance
    Given a leave type that requires allocation but has no valid allocation
    When I check has_valid_allocation
    Then the result should be False

  Scenario: Allow request on top is blocked for absence types
    When I enable allow_request_on_top on an absence type
    Then a validation error should be raised
    And the message should explain that absence types cannot stack requests

  Scenario: Worked time types must remain eligible for accrual rate
    Given a leave type with time_type "other"
    When I disable elligible_for_accrual_rate
    Then a validation error should be raised

  Scenario: Changing allocation requirement is blocked after leaves exist
    Given employees already took leaves for this leave type
    When I try to change requires_allocation
    Then a UserError should be raised

  Scenario: Public holiday duration setting cannot change when overlapping leaves exist
    Given existing leaves overlap public holidays for this type
    When I try to change include_public_holidays_in_duration
    Then a validation error should be raised

  Scenario: Company drives the leave type country
    Given the company country is "Belgium"
    When I compute country_id for the leave type
    Then country_id should be "Belgium"

  Scenario: Negative cap requires a positive maximum excess amount
    When I enable allows_negative and set max_allowed_negative to 0
    Then a validation error should be raised

  Scenario: Hide on dashboard keeps the type selectable
    Given a leave type with hide_on_dashboard enabled
    When I open the leave request form
    Then the leave type should still be selectable
    And it should not be shown on the dashboard list
