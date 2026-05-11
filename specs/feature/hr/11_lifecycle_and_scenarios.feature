Feature: Employee Lifecycle and Scenario Management
  As an HR System
  I want to manage employee lifecycle events and scenarios
  So that employee workflows are handled correctly and consistently

  Background:
    Given I am logged in as an HR user

  Scenario: Employee onboarding flow
    When I create a new employee "Alice Johnson"
    Then the employee should be created
    And an onboarding plan setup link should be provided
    And a congratulations message should appear
    And the message should include a link to onboarding wizard

  Scenario: Load demo scenario
    Given no HR demo data exists
    When I trigger load_demo_data
    Then the HR scenario XML should be converted
    And demo departments should be created
    And demo employees should be loaded

  Scenario: Demo data already exists
    Given HR demo department "Research" already exists
    When I trigger load_demo_data
    Then no duplicate data should be created
    And the system should recognize existing demo data

  Scenario: Get formview based on user access
    Given I am a non-HR user
    When I get the formview for an employee
    Then the public employee form should be returned
    And the form should restrict visible fields

  Scenario: Get formview action for HR user
    Given I am an HR user
    When I get the formview action
    Then the hr.employee model should be returned
    And the standard form action should be shown

  Scenario: Get formview action for non-HR user
    Given I am a non-HR user
    When I get the formview action
    Then the res_model should be changed to hr.employee.public
    And the action should redirect to public view

  Scenario: Load employee scenario data
    Given the HR app is just installed
    When I load the scenario
    Then demo categories should be created
    And sample employees should be loaded
    And department structure should be initialized

  Scenario: Subscribe to department channels on creation
    Given the department "Engineering" has auto-subscribe channels
    When I create an employee in "Engineering"
    Then the employee should be auto-subscribed to department channels
    And the user should receive channel notifications

  Scenario: Subscribe to department channels on update
    Given the employee was in "HR" department
    And the "Engineering" department has auto-subscribe channels
    When I move the employee to "Engineering"
    Then the employee should be auto-subscribed to new channels
    And the previous subscriptions might be adjusted

  Scenario: Generate avatar for new employee
    Given a new employee is created without an image
    And the user doesn't have an image
    When I save the employee
    Then an SVG avatar should be auto-generated
    And the avatar should be based on employee name
    And the same avatar should be set on work contact

  Scenario: Keep existing avatar
    Given the employee has an uploaded profile image
    When I save the employee
    Then the existing image should be preserved
    And a new SVG should not be generated

  Scenario: Track employee field changes
    When I update multiple employee fields
    Then each tracked field should have a log entry
    And the change history should be accessible
    And the modification history should show who changed what and when

  Scenario: Post departure notification
    Given the employee is being archived
    When I enter departure description "Accepted position elsewhere"
    Then a message post should be created
    And the message should include the departure description
    And the post should be visible in employee timeline

  Scenario: Create related contacts action
    Given the employee has work_contact_id and user.partner_id
    When I call action_related_contacts
    Then a kanban/list view of related contacts should be opened
    And the action should show both the work contact and user partner

  Scenario: Single related contact action
    Given the employee has only one related contact
    When I call action_related_contacts
    Then the form view of that contact should open directly
    And the kanban view should be skipped

  Scenario: Compute related partners count
    Given the employee has work_contact_id and linked user
    When I compute related_partners_count
    Then the count should be 2
    And the count should include user partner and work contact

  Scenario: No related partners count for new employee
    Given the employee has no work_contact_id and no user
    When I compute related_partners_count
    Then the count should be 0

  Scenario: Handle version context for field access
    Given I access employee fields with version_id in context
    When I access version_id field
    Then the correct version should be returned
    And the search should work with version context

  Scenario: New employee in draft mode
    When I create an employee in new() mode with version fields
    Then the employee should be created in draft
    And related version should be created in draft
    And both should be accessible as new records

  Scenario: Employee filtering by newly_hired status
    Given employees created at different times:
      | Name      | Created Ago |
      | Alice     | 30 days     |
      | Bob       | 100 days    |
    When I search for newly_hired=True
    Then only "Alice" should be returned
    And "Bob" should not be included

  Scenario: Birthday display configuration
    Given the employee has birthday "1990-05-15"
    When birthday_public_display is True
    Then birthday_public_display_string should be "15 May"
    And the birthday should be displayed to all employees

  Scenario: Birthday hidden configuration
    Given the employee has birthday "1990-05-15"
    When birthday_public_display is False
    Then birthday_public_display_string should be "hidden"
    And the birthday should not be visible to others
