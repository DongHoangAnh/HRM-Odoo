Feature: Notify Expiring Contracts and Work Permits
  As an HR System
  I want to notify about expiring contracts and work permits
  So that HR managers can take timely action before expiration

  Background:
    Given I am logged in as an HR user
    And the company has contract_expiration_notice_period set to 30 days
    And the company has work_permit_expiration_notice_period set to 30 days

  Scenario: Notify contract expiring in 30 days
    Given the employee "John Doe" has contract ending on 2025-03-15
    And today is 2025-02-13 (30 days before expiration)
    When the notification cron job runs
    Then an activity should be created for the HR responsible
    And the activity should be titled "The contract of John Doe is about to expire"
    And the activity deadline should be 2025-03-15

  Scenario: Notify work permit expiring in 30 days
    Given the employee "Jane Smith" has work_permit_expiration_date 2025-03-20
    And today is 2025-02-18 (30 days before expiration)
    When the notification cron job runs
    Then an activity should be created
    And the activity should mention "The work permit of Jane Smith is about to expire"
    And the activity deadline should be 2025-03-20

  Scenario: Do not notify contract not yet expired
    Given the employee has contract ending on 2025-04-20
    And today is 2025-02-13
    When the notification cron job runs
    Then no activity should be created for this employee

  Scenario: Do not notify contract already expired
    Given the employee has contract ended on 2025-02-01
    And today is 2025-02-13
    When the notification cron job runs
    Then no activity should be created
    And the employee should not appear in expiring list

  Scenario: Notify multiple employees in batch
    Given multiple employees with contracts expiring on 2025-03-15
    When the notification cron job runs
    Then an activity should be created for each employee
    And all activities should have the correct deadline

  Scenario: Use HR responsible person for activity
    Given the employee has hr_responsible_id set to "Tom Manager"
    And the contract is expiring
    When the notification cron job runs
    Then the activity should be assigned to "Tom Manager"

  Scenario: Fallback to current user if no HR responsible
    Given the employee has no hr_responsible_id
    And the contract is expiring
    When the notification cron job runs
    Then the activity should be assigned to the current user

  Scenario: Notify across multiple companies
    Given:
      | Company    | Notice Period | Employee      | Contract End |
      | Company A  | 30 days       | John Doe      | 2025-03-15   |
      | Company B  | 60 days       | Jane Smith    | 2025-03-25   |
    When the notification cron job runs on 2025-02-13
    Then "John Doe's" activity should be created
    And "Jane Smith's" activity should NOT be created yet

  Scenario: Prevent duplicate activities
    Given an activity already exists for the employee's expiring contract
    When the notification cron job runs again
    Then no duplicate activity should be created

  Scenario: Work permit with no contract
    Given the employee has work_permit_expiration_date but no contract
    When the notification cron job runs on notification date
    Then an activity should be created for the work permit

  Scenario: Contract with no work permit
    Given the employee has contract expiring but no work_permit_expiration_date
    When the notification cron job runs on notification date
    Then only contract activity should be created

  Scenario: Both contract and work permit expiring
    Given the employee has:
      | Field                          | Value        |
      | contract_date_end              | 2025-03-15   |
      | work_permit_expiration_date    | 2025-03-10   |
    When the notification cron job runs on 2025-02-13
    Then two activities should be created
    And one for contract and one for work permit

  Scenario: Custom notice period per company
    Given:
      | Company    | Notice Period | Employee      | Contract End |
      | Company A  | 30 days       | John Doe      | 2025-03-15   |
    And today is 2025-02-14 (29 days before)
    When the notification cron job runs
    Then no activity should be created (less than 30 days)

  Scenario: Upcoming contract with no actual start date
    Given the employee has future contract with contract_date_start empty
    When the notification cron job runs
    Then the notification system should skip this
    And only check contracts with defined dates

  Scenario: Permanent contract notification
    Given the employee has permanent contract with contract_date_end = False
    When the notification cron job runs
    Then no expiration activity should be created

  Scenario: Activity scheduled with mail_activity_quick_update
    When an expiration activity is created
    Then it should use mail_activity_quick_update context
    And should use 'mail.mail_activity_data_todo' activity type

  Scenario: Notification includes employee name
    Given the employee "Robert Johnson" has expiring contract
    When the activity is created
    Then the activity title should include "Robert Johnson"
