Feature: Employee Attendance Check-In and Check-Out
  As an HR System
  I want to track employee attendance with check-in and check-out
  So that I can monitor employee working hours and presence

  Background:
    Given I am logged in as an HR user
    And the employee "John Doe" exists
    And today is "2025-01-15"

  Scenario: Employee checks in successfully
    When the employee "John Doe" checks in at "09:00 AM"
    Then an attendance record should be created
    And the check_in field should be set to "2025-01-15 09:00"
    And the check_out field should be empty
    And the employee's presence state should be updated to "present"

  Scenario: Check-in with GPS location
    Given GPS tracking is enabled
    When the employee checks in with location (40.7128, -74.0060)
    Then the attendance record should store:
      | Field        | Value       |
      | in_latitude  | 40.7128     |
      | in_longitude | -74.0060    |
      | in_location  | GPS Based   |

  Scenario: Check-in with IP address
    When the employee checks in from IP "192.168.1.100"
    Then the attendance record should store:
      | Field         | Value           |
      | in_ip_address | 192.168.1.100   |

  Scenario: Check-in from Kiosk mode
    Given the attendance kiosk is enabled
    When the employee checks in using the kiosk
    Then the attendance record should have in_mode = "kiosk"

  Scenario: Check-in from Systray
    Given the employee checks in via system tray
    Then the attendance record should have in_mode = "systray"

  Scenario: Manual check-in override
    Given a check-in record exists at "09:00 AM"
    When an HR user manually modifies it to "09:15 AM"
    Then the check_in time should be updated
    And the in_mode should be set to "manual"

  Scenario: Employee checks out
    Given the employee checked in at "09:00 AM"
    When the employee checks out at "05:00 PM"
    Then the attendance record should be updated with check_out "2025-01-15 17:00"
    And the worked_hours should be calculated as 8.0

  Scenario: Check-out with GPS location
    Given GPS tracking is enabled
    And the employee checked in at "09:00 AM"
    When the employee checks out with location (40.7128, -74.0060)
    Then the attendance record should store:
      | Field         | Value       |
      | out_latitude  | 40.7128     |
      | out_longitude | -74.0060    |
      | out_location  | GPS Based   |

  Scenario: Automatic check-out after 24 hours
    Given the employee checked in at "09:00 AM" yesterday
    When the system runs the auto-checkout routine today
    Then the attendance record should have out_mode = "auto_check_out"
    And the check_out should be set to approximately 24 hours after check_in

  Scenario: Calculate worked hours correctly
    Given the employee checks in at "09:00 AM"
    And the employee checks out at "05:30 PM"
    When I compute the worked_hours
    Then the worked_hours should be 8.5

  Scenario: Expected hours calculation
    Given the employee works 8 hours
    When overtime_hours is 1.5
    Then expected_hours should be 6.5 (worked_hours - overtime_hours)

  Scenario: Detect overtime hours
    Given the employee worked 10 hours (09:00 AM to 07:00 PM)
    When overtime detection runs
    Then overtime_hours should be 2.0 (10 - 8)

  Scenario: Multiple check-in/check-out on same day
    Given the employee checks in at "09:00 AM" and out at "01:00 PM"
    When the employee checks in again at "02:00 PM" and out at "06:00 PM"
    Then two separate attendance records should be created
    And total worked hours should be 8.0

  Scenario: Prevent duplicate check-in
    Given the employee has an active check-in without check-out
    When the employee tries to check in again
    Then an error should occur
    And the message should ask to check out first

  Scenario: Verify check-in date based on timezone
    Given the employee's timezone is "America/New_York"
    And the system timezone is "UTC"
    When the employee checks in at UTC "02:00 AM" (equivalent to "09:00 PM" EST yesterday)
    Then the attendance date should be the previous day in the employee's timezone

  Scenario: Check-in with browser information
    When the employee checks in from "Chrome" browser
    Then the attendance record should store:
      | Field      | Value  |
      | in_browser | Chrome |

  Scenario: Check-out with different browser
    Given the employee checked in using Chrome
    When the employee checks out using Firefox
    Then the attendance record should store:
      | Field       | Value   |
      | out_browser | Firefox |

  Scenario: Attendance color coding by duration
    Given the employee worked more than 16 hours
    When I compute the color field
    Then the color should be 1 (indicating excessive hours)

  Scenario: Attendance color for pending check-out
    Given the employee checked in more than 1 day ago without check-out
    When I compute the color field
    Then the color should be 1 (indicating stale check-in)

  Scenario: Attendance color normal
    Given the employee checked in and out normally today
    When I compute the color field
    Then the color should be 0 (normal)
