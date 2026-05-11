Feature: Accrual Level Rules and Scheduling
  As an HR Manager
  I want to configure accrual plan levels precisely
  So that leave accrual happens on the correct schedule with the correct caps

  Background:
    Given I am logged in as an HR user
    And the accrual plan "Seniority Plan" exists

  Scenario: Level sequence is derived from start count and type
    Given a level starting after 2 months
    When I compute sequence
    Then sequence should be 60

  Scenario: Milestone date switches to creation when start count is zero
    Given a level with start_count 0
    When I compute milestone_date
    Then milestone_date should be "creation"

  Scenario: Milestone date uses after when start count is positive
    Given a level with start_count 3
    When I compute milestone_date
    Then milestone_date should be "after"

  Scenario: Inverse milestone date resets start count
    Given a level with milestone_date "creation"
    When I apply the inverse
    Then start_count should become 0

  Scenario: Added value type follows the leave type request unit
    Given the accrual plan is linked to a leave type using hours
    When I compute added_value_type
    Then added_value_type should be "hour"

  Scenario: Added value type is inherited from the first level
    Given an accrual plan with multiple levels
    And the first level uses day-based accrual
    When I compute added_value_type on the second level
    Then it should match the first level

  Scenario: First month day is clamped to the month length
    Given a level with first_month "2" and first_month_day "31"
    When I compute first_month_day
    Then first_month_day should become "29"

  Scenario: Second month day is clamped to the month length
    Given a level with second_month "8" and second_month_day "31"
    When I compute second_month_day
    Then second_month_day should stay valid for the month

  Scenario: Yearly day is clamped to the month length
    Given a level with yearly_month "2" and yearly_day "31"
    When I compute yearly_day
    Then yearly_day should become "29"

  Scenario: Weekly frequency requires a weekday
    Given a level with frequency "weekly"
    When I save the level without a week_day
    Then a validation error should be raised

  Scenario: Bimonthly frequency requires first day lower than second day
    Given a level with frequency "bimonthly"
    And first_day is 15
    And second_day is 10
    When I save the level
    Then a validation error should be raised
    And the message should explain the day ordering

  Scenario: Accrued time cap cannot be zero when enabled
    Given a level with cap_accrued_time enabled
    When I set maximum_leave to 0
    Then a UserError should be raised

  Scenario: Added value must be strictly positive
    Given a level with added_value 0
    When I save the level
    Then a validation error should be raised

  Scenario: Carryover maximum cannot be zero when carryover is limited
    Given a level with carryover_options "limited"
    And action_with_unused_accruals is "all"
    When I set postpone_max_days to 0
    Then a validation error should be raised

  Scenario: Accrual validity requires a positive duration
    Given a level with accrual_validity enabled
    When I set accrual_validity_count to 0
    Then a validation error should be raised

  Scenario: Yearly cap requires a positive maximum leave
    Given a level with cap_accrued_time_yearly enabled
    When I set maximum_leave_yearly to 0
    Then a validation error should be raised

  Scenario: Next date for weekly frequency advances to the next selected weekday
    Given a weekly level on Friday
    When I compute the next date from a Monday
    Then the result should be the following Friday

  Scenario: Next date for monthly frequency uses the configured day
    Given a monthly level with first_day 16
    When I compute the next date from the 10th
    Then the result should be the 16th

  Scenario: Previous date for yearly frequency returns the latest matching milestone
    Given a yearly level on January 1st
    When I compute the previous date from March 10th
    Then the result should be January 1st of the same year

  Scenario: Level transition date is based on the allocation start
    Given a level starting after 18 months
    When I compute the level transition date from 2025-01-01
    Then the transition date should be 2026-07-01

  Scenario: Save new milestone returns the accrual plan creation action
    Given an accrual plan level is being edited
    When I click save new
    Then the action should reopen milestone creation for the parent plan
