Feature: Overtime Rules and Ruleset Configuration
  As an HR Attendance Manager
  I want to configure overtime rules and rulesets
  So that overtime can be generated according to company policy

  Background:
    Given I am logged in as an HR attendance manager
    And the company "Tech Corp" exists
    And the country "Belgium" exists

  Scenario: Create overtime ruleset with company and country
    When I create a ruleset with:
      | Field      | Value     |
      | name       | Standard  |
      | company_id | Tech Corp |
      | country_id | Belgium   |
    Then the ruleset should be created
    And active should be True
    And rules_count should be 0

  Scenario: Ruleset counts the number of rules
    Given a ruleset with 3 overtime rules
    When I open the ruleset
    Then rules_count should be 3

  Scenario: Ruleset defaults to maximum rate combination mode
    When I create a new ruleset
    Then rate_combination_mode should default to "max"

  Scenario: Ruleset can sum rates when configured
    Given a ruleset with rate_combination_mode "sum"
    When multiple overtime rules apply
    Then the combined pay rate should sum the extra portions above 100 percent

  Scenario: Create quantity-based overtime rule with expected hours from contract
    When I create an overtime rule with:
      | Field                       | Value    |
      | name                        | Weekly   |
      | base_off                    | quantity |
      | quantity_period             | week     |
      | expected_hours_from_contract | True     |
    Then the rule should be valid

  Scenario: Quantity-based overtime rule requires expected hours when not using contract schedule
    When I create a quantity-based rule without expected_hours and expected_hours_from_contract is False
    Then a validation error should be raised
    And the message should explain that usual work hours are required

  Scenario: Quantity-based overtime rule requires a period
    When I create a quantity-based rule without quantity_period
    Then a validation error should be raised
    And the message should explain that the period is required

  Scenario: Create timing-based overtime rule for schedule
    When I create an overtime rule with:
      | Field               | Value             |
      | name                | Night Shift       |
      | base_off            | timing            |
      | timing_type         | schedule          |
      | resource_calendar_id | Standard Schedule |
    Then the rule should be valid

  Scenario: Timing-based schedule rule requires a work schedule
    When I create a timing-based rule with timing_type "schedule" without a calendar
    Then a validation error should be raised
    And the message should explain that the work schedule is required

  Scenario: Timing start must be within the day
    When I create an overtime rule with timing_start 24
    Then a validation error should be raised
    And the message should state that timing start is an hour of the day

  Scenario: Timing stop must be within the day
    When I create an overtime rule with timing_stop 25
    Then a validation error should be raised
    And the message should state that timing stop is an hour of the day

  Scenario: Rule information display summarizes the configured rule
    Given a timing rule from 18 to 22 on working days with rate 1.5
    When I view the information display
    Then it should summarize the rule configuration

  Scenario: Work-day timing rule only applies on working days
    Given a timing rule with timing_type "work_days"
    And the employee works on a working day
    When overtime is generated
    Then the rule should apply

  Scenario: Non-work-day timing rule only applies on non-working days
    Given a timing rule with timing_type "non_work_days"
    And the employee works on a weekend
    When overtime is generated
    Then the rule should apply

  Scenario: Leave timing rule applies when employee is off
    Given a timing rule with timing_type "leave"
    And the employee is on approved leave
    When overtime is generated
    Then the rule should apply to the leave interval

  Scenario: Regenerate overtimes from a ruleset updates eligible attendances
    Given a ruleset linked to employee versions
    When I click "Regenerate overtimes"
    Then overtime records should be recomputed for eligible attendances
    And the result should follow the active overtime rules