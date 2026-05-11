Feature: Recruitment Operations, Jobs, and Talent Pools
  As an HR Recruiter
  I want to manage jobs, sources, stages, and talent pools
  So that recruitment can be tracked beyond the applicant record

  Background:
    Given I am logged in as a recruiter
    And the company "Tech Corp" exists
    And the job position "Senior Developer" exists

  Scenario: Job default address is derived from the company
    When I create a recruitment job
    Then the address_id should default to the company address

  Scenario: Job address domain is constrained to company addresses
    When I open the job address selector
    Then only allowed company addresses should be available

  Scenario: Job default favorite users are the current user and recruiter managers
    When I create a recruitment job
    Then favorite_user_ids should be prefilled

  Scenario: Job employee counters are computed
    Given a job with hired and open applicants
    When I compute the job counters
    Then employee_count, application_count, and open_application_count should be updated

  Scenario: Job new and old application counts are computed
    Given a job with recent and old applicants
    When I compute the job analytics
    Then new_application_count and old_application_count should be available

  Scenario: Open job attachments action returns the attachment view
    Given a job with documents attached
    When I open job attachments
    Then the action should show hr.attachments for the job

  Scenario: Open job activities action returns the activity view
    Given a job with scheduled activities
    When I open job activities
    Then the action should show the related activities

  Scenario: Load recruitment scenario populates the job pipeline
    Given a job with a recruitment scenario
    When I load the recruitment scenario
    Then the pipeline should be populated with the scenario stages

  Scenario: Open employees from job returns hired employees
    Given a job with hired employees
    When I open employees from the job
    Then the action should open the hired employees list

  Scenario: Recruitment stage default values are prepared
    When I create a recruitment stage
    Then default_get should prepare the expected stage values

  Scenario: Recruitment stage warning visibility depends on configuration
    Given a recruitment stage with warning enabled
    When I compute warning visibility
    Then the warning should be visible

  Scenario: Recruitment source can create a mail alias
    Given a recruitment source named "Website"
    When I create its alias
    Then a mail alias should be created for the source

  Scenario: Recruitment source can be created with alias helper
    Given a recruitment source without alias
    When I call create_and_get_alias
    Then the source and alias should be returned together

  Scenario: Linked recruitment sources cannot be unlinked freely
    Given a recruitment source already linked to jobs or applicants
    When I try to delete it
    Then a constraint should prevent unlinking if it is still referenced

  Scenario: Talent pool counts linked talents
    Given a talent pool with 5 linked talents
    When I compute talent_count
    Then talent_count should be 5

  Scenario: Add talents to a talent pool
    Given a talent pool and a set of applicants
    When I add applicants to the talent pool
    Then the talent pool should contain those applicants

  Scenario: Calendar interview event highlights recruitment context
    Given an applicant has an interview event
    When the calendar event is created
    Then it should be highlighted for recruitment usage

  Scenario: Recruiter users are added and removed as interviewers
    Given a recruiter user is connected to the recruitment module
    When I enable recruitment interviewers for that user
    Then the user should be added to the recruitment interviewer set
    When I remove recruitment interviewers
    Then the user should be removed from the set
