Feature: Recruitment Process and Applicant Tracking
  As a Recruiter
  I want to manage applicants and track their progress through recruitment stages
  So that I can efficiently hire qualified candidates

  Background:
    Given I am logged in as a recruiter
    And the job position "Senior Developer" exists
    And the company "Tech Corp" exists
    And recruitment stages are defined:
      | Stage         | Sequence |
      | New           | 1        |
      | Screening     | 2        |
      | Interview     | 3        |
      | Offer         | 4        |
      | Hired         | 5        |

  Scenario: Create applicant from job application
    When I create an applicant with:
      | Field        | Value              |
      | partner_name | Alice Johnson      |
      | email_from   | alice@email.com    |
      | job_id       | Senior Developer   |
      | company_id   | Tech Corp          |
    Then the applicant should be created
    And the stage should be set to "New"
    And the active status should be True
    And the application_status should be "ongoing"

  Scenario: Applicant initial data
    Given an applicant is created
    When I check the applicant record
    Then it should have:
      | Field        | Expected Value |
      | create_date  | Today          |
      | date_open    | Today          |
      | kanban_state | normal         |

  Scenario: Add applicant contact information
    When I create an applicant with:
      | Field              | Value           |
      | partner_name       | Bob Smith       |
      | email_from         | bob@email.com   |
      | partner_phone      | +1-555-123-4567 |
      | linkedin_profile   | linkedin.com/.. |
      | type_id            | Bachelor        |
      | availability       | 2025-02-01      |
    Then all information should be stored
    And the phone should be sanitized

  Scenario: Link contact to applicant
    Given a contact "Alice Johnson" already exists
    When I create an applicant and link the contact
    Then partner_id should be set to the contact
    And the contact details should be synchronized

  Scenario: Move applicant through recruitment stages
    Given an applicant in "New" stage
    When I move the applicant to "Screening" stage
    Then the stage_id should be updated
    And the date_last_stage_update should be set to now

  Scenario: Track stage transition time
    Given an applicant in "New" stage
    And the current date is "2025-01-15"
    When I move the applicant to "Screening" on "2025-01-18"
    Then day_open should be 3 days
    And delay_close should be calculated from stage change dates

  Scenario: Move applicant to Offer stage
    Given an applicant in "Interview" stage
    When I move them to "Offer" stage
    And set salary_proposed to 80000
    And set salary_proposed_extra "Health Insurance, 20% bonus"
    Then the offer details should be stored

  Scenario: Move applicant to Hired
    Given an applicant in "Offer" stage with acceptance
    When I move them to "Hired" stage
    Then application_status should be "hired"
    And date_closed should be set to today
    And day_close should be calculated

  Scenario: Refuse applicant
    Given an applicant in any stage
    When I refuse the applicant with reason "Not qualified"
    Then the application_status should be "refused"
    And refuse_reason_id should be set
    And refuse_date should be recorded

  Scenario: Archive applicant
    Given an applicant with status "refused"
    When I archive the applicant
    Then application_status should be "archived"
    And active should be False

  Scenario: Assign recruiter to applicant
    When I assign applicant to recruiter "John Manager"
    Then user_id should be set to "John Manager"
    And the recruiter should receive a notification

  Scenario: Add interview to applicant
    When I create a calendar event for interview
    And link it to the applicant
    Then meeting_ids should include this event
    And the event should appear in applicant timeline

  Scenario: Multiple interviews for single applicant
    Given an applicant has had 1st round interview
    When I add 2nd round interview event
    Then meeting_ids should contain both interviews
    And meeting_display_text should show latest meeting info

  Scenario: Add interviewer to applicant record
    When I add "Jane Recruiter" and "Tom Manager" as interviewers
    Then interviewer_ids should contain both
    And they should receive interview notifications

  Scenario: Set applicant priority
    When I set priority to "Very Good"
    Then the priority should be stored
    And the applicant should be sorted accordingly

  Scenario: Applicant with same email shows duplicate warning
    Given an applicant "Alice" with email "alice@company.com"
    When I create another applicant "Alice 2" with same email
    Then application_count should show 2
    And a warning should indicate duplicates

  Scenario: Kanban state management
    When I set kanban_state to "done" (ready for next stage)
    Then it indicates applicant is ready to move forward

  Scenario: Kanban state waiting
    When I set kanban_state to "waiting"
    And add notes "Waiting for background check"
    Then the state should indicate pending action needed

  Scenario: Applicant tags/categories
    When I add categories "Developer", "Remote", "Experienced"
    Then categ_ids should contain all three
    And applicants can be filtered by categories

  Scenario: Link applicant to employee after hiring
    Given an applicant in "Hired" stage
    When I create an employee from the applicant
    Then employee_id should be linked
    And the employee should inherit some data from applicant

  Scenario: Employee linked to applicant
    When I link an employee to the applicant
    Then employee_id should be set
    And emp_is_active should show True if employee is active

  Scenario: UTM tracking on applicant
    When I create an applicant from a LinkedIn campaign
    Then medium_id should show "LinkedIn"
    And source_id should track where applicant came from

  Scenario: Applicant source tracking
    Given different applicants from various sources:
      | Source   | Count |
      | LinkedIn | 5     |
      | Email    | 3     |
      | Referral | 2     |
    When I generate recruitment analytics
    Then I should see source breakdown

  Scenario: Applicant activity timeline
    When I add notes, interviews, and stage changes
    Then the timeline should show all activities
    And activity_ids should track all interactions

  Scenario: Attachment management
    When I upload CV and cover letter
    Then attachment_ids should contain both files
    And attachment_number should be 2

  Scenario: Create employee from applicant
    Given an applicant "Alice Johnson" in "Hired" stage
    When I click "Create Employee"
    Then a new employee should be created with:
      | Field | Value        |
      | name  | Alice Johnson|
    And the applicant should be linked to the new employee
