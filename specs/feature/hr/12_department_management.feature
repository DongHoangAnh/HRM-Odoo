Feature: Department Management and Hierarchy
  As an HR Manager
  I want to manage departments and department hierarchies
  So that employees, jobs, and activities stay organized

  Background:
    Given I am logged in as an HR user
    And the company "Tech Corp" exists

  Scenario: Create department with default company context
    When I create a department named "Engineering"
    Then the department should be created
    And company_id should default to "Tech Corp"
    And active should be True

  Scenario: Create child department with hierarchical name
    Given a parent department "Engineering"
    When I create a child department named "Platform"
    Then complete_name should be "Engineering / Platform"

  Scenario: Name create returns the new department record
    When I quick create a department named "Support"
    Then the returned id should match the created department
    And the display name should be "Support"

  Scenario: Search complete name with ilike
    Given departments "Sales", "Sales / APAC", and "Marketing" exist
    When I search departments by complete_name ilike "Sales"
    Then only the Sales departments should be returned

  Scenario: Search complete name with =ilike wildcard
    Given departments "North / Field" and "North / Inside" exist
    When I search departments by complete_name =ilike "North / %"
    Then both North departments should be returned

  Scenario: Prevent recursive departments
    Given department A is parent of department B
    When I try to set department A parent to department B
    Then a validation error should be raised
    And the message should state "You cannot create recursive departments."

  Scenario: Child department inherits company from parent
    Given a parent department "Engineering" belongs to "Tech Corp"
    When I create a child department under it
    Then company_id should be copied from the parent department

  Scenario: Changing department manager updates employee managers
    Given a department "Engineering" with manager "Alice Manager"
    And employees report to "Alice Manager"
    When I change the department manager to "Bob Manager"
    Then employees in the department hierarchy should be reassigned to "Bob Manager"

  Scenario: Open employee action uses private employees for HR users
    Given I can read hr.employee
    When I open employees from the department
    Then the action should target model "hr.employee"
    And the view mode should include list, kanban, and form

  Scenario: Open employee action uses public employees for non-HR users
    Given I cannot read hr.employee
    When I open employees from the department
    Then the action should target model "hr.employee.public"

  Scenario: Open child departments action returns descendants
    Given a department with two child departments
    When I open child departments
    Then the action domain should include all child departments
    And the name should be "Child departments"

  Scenario: Department hierarchy includes parent self and children
    Given department "Engineering" has parent "Tech Corp" and child "Platform"
    When I request the department hierarchy
    Then the result should include parent, self, and children nodes
    And each node should include employee counts

  Scenario: Department activity plan action uses department context
    Given a department with one linked activity plan
    When I open activity plans from the department
    Then the action context should include default_department_id
    And the domain should include department-specific or global plans
