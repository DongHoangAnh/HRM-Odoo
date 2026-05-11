Feature: Work Entry Source Configuration and Recompute
  As an HR Manager
  I want to configure work entry sources and recompute them when contracts change
  So that generated work entries stay aligned with the employee's setup

  Background:
    Given I am logged in as an HR manager
    And the employee "John Doe" has an active contract

  Scenario: Work entry source calendar invalid when calendar is missing
    Given a version with work_entry_source "calendar"
    And no resource calendar is set
    When I compute work_entry_source_calendar_invalid
    Then the flag should be True

  Scenario: Work entry source calendar valid when calendar exists
    Given a version with work_entry_source "calendar"
    And a resource calendar is set
    When I compute work_entry_source_calendar_invalid
    Then the flag should be False

  Scenario: Default attendance work entry type is resolved from xmlid
    When I request the default work entry type
    Then the attendance type should be returned when installed

  Scenario: Default overtime work entry type is resolved from xmlid
    When I request the default overtime work entry type
    Then the overtime type should be returned when installed

  Scenario: Whitelisted template fields include work entry source
    When I copy values from a contract template
    Then work_entry_source should be copied when present

  Scenario: Attendance interval generation respects the work entry source
    Given a version with work_entry_source "calendar"
    When I generate attendance intervals
    Then the calendar-based attendance intervals should be returned

  Scenario: Leave domain includes company and resource calendar rules
    When I compute the leave domain for work entry generation
    Then it should include employee resource, date range, company, and calendar constraints

  Scenario: Leave intervals resolve work entry type from the leave
    Given a leave with a specific work entry type
    When I map the leave interval to a work entry type
    Then the leave's own work entry type should be used

  Scenario: Real attendance work entry values use UTC normalized dates
    Given a localized attendance interval
    When I build real attendance work entry values
    Then date_start and date_stop should be stored in UTC naive form

  Scenario: Work entries are generated for attendance and leave intervals
    Given attendances and leave intervals exist for a version
    When I compute version work entry values
    Then attendance entries and leave entries should be produced

  Scenario: Flexible schedules generate leave and worked leave correctly
    Given a fully flexible version with leave intervals
    When I generate work entry values
    Then the flexible schedule path should be used

  Scenario: Static work entries are detected by calendar source
    Given a version with work_entry_source "calendar"
    When I check has_static_work_entries
    Then the result should be True

  Scenario: Generate work entries for a date range creates records
    Given a version with contract dates in January
    When I generate work entries for the month
    Then hr.work.entry records should be created

  Scenario: Force generation regenerates existing work entries
    Given existing work entries already exist for the range
    When I generate work entries with force=True
    Then existing non-validated entries should be replaced

  Scenario: Post-processing splits multi-day entries across local days
    Given a generated work entry spans two local days
    When post-processing runs
    Then it should be split into separate day segments

  Scenario: Generated work entries update generated boundaries
    Given generated work entries extend outside current boundaries
    When work entries are created
    Then date_generated_from and date_generated_to should be updated

  Scenario: Removing work entries deletes those outside contract period
    Given generated work entries exist outside the contract period
    When I call remove work entries
    Then the out-of-range entries should be deleted

  Scenario: Canceling work entries removes non-validated records
    Given non-validated work entries exist for a version
    When I call cancel work entries
    Then the non-validated entries should be unlinked

  Scenario: Contract field changes trigger work entry removal
    Given a version with generated work entries
    When I update contract_date_start
    Then existing generated work entries outside the new period should be removed

  Scenario: Contract field changes trigger recompute on dependent fields
    Given a version with generated work entries
    When I update resource_calendar_id
    Then the work entries should be recomputed for the affected date range

  Scenario: Cron generates missing work entries in batches
    Given multiple versions have missing work entries this month
    When the cron runs
    Then it should generate work entries in batches and retrigger if needed
