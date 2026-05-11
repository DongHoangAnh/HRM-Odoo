Feature: Employee Overtime Management and Tracking
  As an HR Manager
  I want to track and manage employee overtime
  So that I can monitor extra working hours and ensure compliance

  Background:
    Given I am logged in as an HR user
    And the employee "John Doe" works 8 hours per day
    And the overtime tracking system is enabled

  Scenario: Detect overtime from attendance
    Given the employee worked 10 hours (9:00 AM to 7:00 PM)
    When I compute overtime hours
    Then overtime_hours should be 2.0

  Scenario: Overtime status to approve
    Given an attendance record has overtime hours
    And no overtime approval exists yet
    When I check the overtime_status
    Then it should be "to_approve"

  Scenario: Overtime status approved
    Given an attendance record has overtime with status "approved"
    When I check the overtime_status
    Then it should be "approved"

  Scenario: Overtime status refused
    Given an attendance record has overtime with status "refused"
    When I check the overtime_status
    Then it should be "refused"

  Scenario: Overtime status mixed (some approved, some refused)
    Given an attendance record has multiple overtimes:
      | Duration | Status   |
      | 1.0      | approved |
      | 0.5      | refused  |
    When I check the overtime_status
    Then it should be "to_approve" (mixed status)

  Scenario: Approve overtime hours
    Given an overtime record with status "to_approve"
    When I approve the overtime
    Then the status should be updated to "approved"
    And validated_overtime_hours should include this duration

  Scenario: Refuse overtime hours
    Given an overtime record with status "to_approve"
    When I refuse the overtime
    Then the status should be updated to "refused"
    And validated_overtime_hours should not include this duration

  Scenario: Manual overtime entry
    Given an employee worked without overtime recorded
    When I manually add overtime of 2 hours for the day
    Then an overtime record should be created
    And overtime_status should be "to_approve"

  Scenario: Overtime calculations with multiple days
    Given:
      | Day | Worked Hours | Overtime |
      | Mon | 10           | 2        |
      | Tue | 9            | 1        |
      | Wed | 8            | 0        |
    When I sum overtime for the week
    Then total overtime should be 3 hours

  Scenario: Approved overtime contributes to validated_overtime_hours
    Given an overtime of 2 hours with status "approved"
    When I compute validated_overtime_hours
    Then it should include 2 hours

  Scenario: Refused overtime doesn't contribute to validated_overtime_hours
    Given an overtime of 1 hour with status "refused"
    When I compute validated_overtime_hours
    Then it should not include this 1 hour

  Scenario: Link overtime to attendance record
    Given an overtime record exists
    And an attendance record exists for the same date
    When I link them together
    Then linked_overtime_ids should be populated
    And the attendance record should display overtime information

  Scenario: Overtime ruleset application
    Given overtime ruleset defines maximum weekly overtime as 10 hours
    And the employee has 12 hours of overtime this week
    When the ruleset check runs
    Then a validation warning should appear
    And the excess should be flagged

  Scenario: Overtime rule with time boundaries
    Given an overtime rule applies only on weekends
    And the employee worked overtime on Monday
    When the rule is applied
    Then the overtime should not be counted

  Scenario: Overtime compensation type
    Given an overtime record can be compensated as:
      | Type    |
      | Time Off|
      | Money   |
    When I set compensation to "Time Off"
    Then the overtime should be convertible to leave balance

  Scenario: Convert overtime to time off
    Given 8 hours of approved overtime
    When I convert it to time off
    Then the employee's leave balance should increase by 8 hours

  Scenario: Overtime display in attendance record
    Given an attendance with 2 hours overtime
    When I view the attendance record
    Then the overtime_hours field should show 2.0
    And the overtime_status should be visible

  Scenario: Default overtime status is to_approve when company requires manager validation
    Given the employee belongs to a company with overtime validation "by_manager"
    When I create a new overtime line
    Then the status should default to "to_approve"

  Scenario: Default overtime status is approved when company does not require manager validation
    Given the employee belongs to a company with overtime validation "auto_approve"
    When I create a new overtime line
    Then the status should default to "approved"

  Scenario: Manual duration mirrors computed duration
    Given an overtime line with duration 3.5
    When I open the overtime line form
    Then manual_duration should be 3.5

  Scenario: Manager flag is true for attendance manager
    Given the current user is the employee attendance manager
    When I view the overtime line
    Then is_manager should be True

  Scenario: Manager flag is true for HR attendance manager group
    Given the current user has the "hr_attendance.group_hr_attendance_manager" group
    When I view the overtime line
    Then is_manager should be True

  Scenario: Approve overtime updates linked attendance overtime status
    Given an attendance linked to an overtime line with status "to_approve"
    When I approve the overtime line
    Then the overtime line status should be "approved"
    And the linked attendance overtime_status should recompute to "approved"
    And the linked attendance validated_overtime_hours should recompute

  Scenario: Refuse overtime updates linked attendance overtime status
    Given an attendance linked to an overtime line with status "to_approve"
    When I refuse the overtime line
    Then the overtime line status should be "refused"
    And the linked attendance overtime_status should recompute to "refused"
    And the linked attendance validated_overtime_hours should recompute to 0

  Scenario: Time stop must be after time start
    When I create an overtime line with start "2025-01-15 18:00:00" and stop "2025-01-15 17:00:00"
    Then a validation error should be raised
    And the message should state "Starting time should be before end time."

  Scenario: Linked attendances are found by check-in and employee
    Given an overtime line with time_start matching an attendance check_in
    When the system resolves linked attendances
    Then the attendance should be included in linked attendance computation

  Scenario: Changing overtime duration recomputes attendance overtime hours
    Given an attendance linked to one overtime line of 2 hours
    When I change the overtime duration to 4 hours
    Then the attendance overtime_hours should recompute to 4
    And the attendance expected_hours should recompute accordingly
