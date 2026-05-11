Feature: Create Employee
  As a Human Resources Manager
  I want to create new employees in the system
  So that I can manage the workforce

  Background:
    Given I am logged in as an HR user
    And the company "My Company" exists
    And the resource calendar "Standard 40h" exists

  Scenario: Create basic employee with required information
    When I create an employee with the following information:
      | Field      | Value           |
      | name       | John Doe        |
      | company_id | My Company      |
    Then the employee "John Doe" should be created successfully
    And the employee should have an active status
    And a resource record should be created for the employee
    And the employee should have a default category color

  Scenario: Create employee with user link
    Given the user "john.doe@company.com" exists
    When I create an employee with the following information:
      | Field   | Value                    |
      | name    | John Doe                 |
      | user_id | john.doe@company.com     |
    Then the employee "John Doe" should be created successfully
    And the employee should be linked to the user
    And the employee's work_contact_id should be set to the user's partner

  Scenario: Create employee with phone information
    When I create an employee with the following information:
      | Field         | Value           |
      | name          | John Doe        |
      | work_phone    | +1 (555) 123-45 |
      | mobile_phone  | +1 (555) 567-89 |
      | company_id    | My Company      |
    Then the employee "John Doe" should be created successfully
    And the work phone should be formatted as international format
    And the mobile phone should be formatted as international format

  Scenario: Create employee with personal information
    When I create an employee with the following information:
      | Field               | Value           |
      | name                | John Doe        |
      | legal_name          | John Paul Doe   |
      | birthday            | 1990-01-15      |
      | place_of_birth      | New York        |
      | country_of_birth    | United States   |
    Then the employee "John Doe" should be created successfully
    And the employee should have the legal name "John Paul Doe"
    And the employee should have birthday tracking enabled

  Scenario: Create employee generates initial version
    When I create an employee with the following information:
      | Field      | Value      |
      | name       | John Doe   |
      | company_id | My Company |
    Then the employee "John Doe" should be created successfully
    And an initial hr.version record should be created
    And the employee's current_version_id should point to the initial version

  Scenario: Multiple employees created maintain correct order
    When I create the following employees:
      | name       |
      | Alice      |
      | Bob        |
      | Charlie    |
    Then all employees should be created in the specified order
    And each employee should have a unique resource record

  Scenario: Create employee with work contact
    Given I have permission to create contacts
    When I create an employee with the following information:
      | Field      | Value           |
      | name       | John Doe        |
      | work_email | john@company.com|
      | company_id | My Company      |
    Then the employee "John Doe" should be created successfully
    And a work contact should be automatically created
    And the work contact should have the employee's name
    And the work contact should be associated with the employee

  Scenario: Prevent duplicate user linking
    Given the employee "Jane Doe" is linked to user "jane@company.com"
    When I try to create another employee with the same user "jane@company.com" in the same company
    Then the creation should fail
    And an error message should indicate duplicate user linking

  Scenario: Create employee with category tags
    Given the employee category "Management" exists
    When I create an employee with the following information:
      | Field         | Value           |
      | name          | John Doe        |
      | category_ids  | Management      |
    Then the employee "John Doe" should be created successfully
    And the employee should have the "Management" category tag

  Scenario: Create employee with timezone
    When I create an employee with the following information:
      | Field      | Value           |
      | name       | John Doe        |
      | tz         | America/New_York|
    Then the employee "John Doe" should be created successfully
    And the employee's timezone should be set to "America/New_York"

  Scenario: Create employee with badge ID
    When I create an employee with the following information:
      | Field      | Value           |
      | name       | John Doe        |
      | barcode    | EMP001          |
    Then the employee "John Doe" should be created successfully
    And the employee should have barcode "EMP001"

  Scenario: Create employee with PIN
    When I create an employee with the following information:
      | Field      | Value           |
      | name       | John Doe        |
      | pin        | 1234            |
    Then the employee "John Doe" should be created successfully
    And the employee should have PIN "1234"

  Scenario: Multiple employees with different companies
    Given the company "Company A" and "Company B" both exist
    When I create an employee in "Company A" named "John" with user "john@company.com"
    And I create another employee in "Company B" with the same user "john@company.com"
    Then both employees should be created successfully
    And no constraint violation should occur
