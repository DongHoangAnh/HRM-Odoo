Feature: Job Platforms and Interviewer Group Synchronization
  As an HR Recruiter
  I want to manage job platforms and interviewer permissions
  So that incoming applications and interviewer access stay consistent

  Background:
    Given I am logged in as a recruiter
    And the company "Tech Corp" exists

  Scenario: Create job platform normalizes email
    When I create a job platform with email "Recruit@Example.com"
    Then the stored email should be normalized

  Scenario: Update job platform email is normalized on write
    Given an existing job platform
    When I change its email to "Hiring@Example.com"
    Then the stored email should be normalized

  Scenario: Job platform email must be unique
    Given a job platform with email "jobs@example.com"
    When I create another job platform with the same email
    Then a validation error should be raised

  Scenario: Job platform regex can be stored for parsing incoming mail
    When I create a job platform with a regex pattern
    Then the regex should be saved for future applicant parsing

  Scenario: Job default alias creation points to hr.applicant
    Given a recruitment job exists
    When the alias is created
    Then the alias should create hr.applicant records

  Scenario: Job alias defaults are refreshed when department or user changes
    Given a job with an existing alias
    When I update department_id or user_id
    Then alias defaults should be rewritten to match the current job

  Scenario: Job interviewers are added on creation
    When I create a job with interviewer users
    Then the users should be added to the recruitment interviewer group

  Scenario: Removing interviewers drops the group only when no longer referenced
    Given a user is removed from all jobs and applicants as interviewer
    When the job is updated
    Then the user should be removed from the interviewer group

  Scenario: Job open activities action exposes active applicant activities
    Given a job with running applicant activities
    When I open job activities
    Then the action should open activity view first
    And the context should filter by the job id

  Scenario: Job source relation is tracked on the job form
    Given a job with recruitment sources
    When I open the job record
    Then source records should be available from job_source_ids

  Scenario: Favorite jobs can be toggled per user
    Given a job in my favorites
    When I toggle the favorite flag
    Then the job should be removed from my favorites

  Scenario: Job metrics include hired employees and open applications
    Given a job with hired and open applicants
    When I view the job metrics
    Then hired employees and open application counts should be shown

  Scenario: Recruiters can open related employees from a job
    Given a job with hired employees
    When I open related employees from the job
    Then the employee action should be returned for the current access level
