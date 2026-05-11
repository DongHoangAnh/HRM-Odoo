# Feature Specification: Create Employee

**Feature Branch**: `001-create-employee`
**Created**: 2026-05-11
**Status**: Draft
**Input**: User description: "Feature: Create Employee
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
    And no constraint violation should occur" 

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create employee (Priority: P1)
An HR user creates a new employee with required information so the organization can track and manage headcount and assignments.

**Why this priority**: Core HR workflow — enables all downstream HR processes (payroll, attendance, contracts).

**Independent Test**: Create an employee with `name` and `company_id`; verify employee record, active status, resource created, and default category color.

**Acceptance Scenarios**:
1. Given an HR user and an existing company, When they create an employee with `name` and `company_id`, Then the employee record is created and active, a resource is created, and a default category color is assigned.

---

### User Story 2 - Link user to employee (Priority: P1)
An HR user links an existing system user to the employee to enable calendar and user-specific flows.

**Why this priority**: Necessary for connecting HR records to system users (permissions, contacts).

**Independent Test**: Create employee with `user_id` pointing to an existing user; verify employee.user_id, employee.work_contact_id == user's partner.

**Acceptance Scenarios**:
1. Given user `john.doe@company.com` exists, When creating an employee with `user_id` set to that user, Then the employee is linked and the work_contact_id references the user's partner.

---

### User Story 3 - Employee contact and phones (Priority: P2)
HR creates an employee with work contact details and phone numbers which must be normalized.

**Why this priority**: Improves communications and integrations with telephony/attendance.

**Independent Test**: Create employee with `work_phone` and `mobile_phone`; verify creation of work contact (if permission), association, and that phone values are stored in international (E.164) format.

**Acceptance Scenarios**:
1. Given permission to create contacts, When creating an employee with `work_email`, Then a contact is created, associated to the employee, and contact name matches employee name.
2. Given phone inputs, When creating employee, Then stored phone values are normalized to international format.

---

### User Story 4 - Personal and identification info (Priority: P2)
HR records personal details (legal name, birthday, birthplace, country) and identifiers (barcode, PIN).

**Why this priority**: Required for payroll, legal records, and physical access.

**Independent Test**: Create employee including `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `barcode`, `pin`; verify fields persisted and birthday tracking enabled.

**Acceptance Scenarios**:
1. When creating employee with `legal_name` and `birthday`, Then fields are saved and birthday tracking is enabled.
2. When creating employee with `barcode` or `pin`, Then those identifiers are persisted on the employee record.

---

### User Story 5 - Versioning and ordering (Priority: P2)
Creating an employee generates an initial version record and insertion order is preserved for bulk creates.

**Why this priority**: Version history and deterministic ordering are required for audits and reproducible imports.

**Independent Test**: Create single employee and verify `hr.version` initial record exists and `current_version_id` points to it. Create multiple employees in bulk and verify the created order matches input order and each has unique resource.

**Acceptance Scenarios**:
1. After creating an employee, an initial `hr.version` must exist and be referenced by `current_version_id`.
2. When creating multiple employees in a single operation, the order of created employees matches the input order and resource records are unique.

---

### User Story 6 - Prevent duplicate user linking (Priority: P1)
Prevent linking the same system user to multiple employees within the same company.

**Why this priority**: Prevent data integrity issues and unexpected permission/communication routing.

**Independent Test**: Given employee A is linked to user U, When attempting to create employee B in the same company linking to user U, Then creation fails with a clear duplicate-linking error.

**Acceptance Scenarios**:
1. Duplicate link attempt fails and returns a human-readable error indicating duplicate user linking.

---

### User Story 7 - Multi-company user reuse (Priority: P2)
Allow the same system user to be linked to employees in different companies.

**Why this priority**: Multi-company setups require independent employee profiles per company.

**Independent Test**: Create employee in Company A with user U and create another in Company B with same user U; both succeed.

**Acceptance Scenarios**:
1. Same user can be linked across employees if companies differ; no constraint violation occurs.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow an HR user to create an employee with at least `name` and `company_id`.
- **FR-002**: Creating an employee MUST set the employee status to active by default.
- **FR-003**: Creating an employee MUST create a corresponding resource record and link it to the employee.
- **FR-004**: The system MUST allow linking an existing system user to an employee via `user_id` and set `work_contact_id` to the user's partner.
- **FR-005**: The system MUST normalize phone numbers to international (E.164) format on save.
- **FR-006**: Employee personal fields (`legal_name`, `birthday`, `place_of_birth`, `country_of_birth`) MUST be stored and `birthday` must enable tracking for reminders/notifications.
- **FR-007**: Creating an employee MUST generate an initial `hr.version` record and set `current_version_id`.
- **FR-008**: Bulk employee creation MUST preserve the input order of employees.
- **FR-009**: When permitted, creating an employee with `work_email` MUST create an associated work contact and link it to the employee.
- **FR-010**: The system MUST prevent creating a second employee in the same company linked to an already-linked system user and return a clear validation error.
- **FR-011**: The system MUST support assigning categories/tags (`category_ids`) to employees.
- **FR-012**: The system MUST persist timezone (`tz`), barcode (`barcode`), and PIN (`pin`) fields when provided.
- **FR-013**: The same system user MAY be linked to employees in different companies (no cross-company uniqueness constraint).

### Key Entities

- **Employee**: Core HR record with attributes: `name`, `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `company_id`, `user_id`, `work_contact_id`, `work_phone`, `mobile_phone`, `tz`, `barcode`, `pin`, `category_ids`, `current_version_id`.
- **Company**: Organization context for the employee.
- **User**: System user that can be linked to an employee; has `partner` representing contact.
- **Contact**: Work contact associated with employee (may be created automatically).
- **Resource**: Calendar/resource record created per employee.
- **HR Version**: Version record (`hr.version`) created at employee creation for audit/history.
- **Category**: Employee categories/tags (e.g., Management).

## Success Criteria *(mandatory)*

### Measurable Outcomes
- **SC-001**: HR users can create a basic employee (name + company) in under 2 minutes, verified by manual test.
- **SC-002**: 100% of employee creations with valid input create an employee record, a resource record, and an initial `hr.version`.
- **SC-003**: Phone numbers are stored in international format for 95% of valid phone inputs after normalization.
- **SC-004**: Attempts to link an already-linked user within the same company are rejected with a clear error message 100% of the time.
- **SC-005**: Bulk create operations preserve input order for 100% of tested inputs (sampled tests).

## Assumptions

- HR users have necessary permissions to create employees and, when relevant, contacts.
- The `company` and `resource calendar` preconditions exist for the actor (as per Background).
- Phone normalization will use an agreed standard (E.164) and best-effort parsing; invalid numbers surface validation errors.
- Existing user and partner models are available and stable; linking uses `user_id` referencing system users.
- Birthday tracking means the system flags/records the birthday date for future notifications; implementation details are out of scope for this spec.
- No UI/implementation details are specified; this spec focuses on what and why, not how.

## Notes and Open Questions

- No critical clarifications required. Reasonable defaults applied: sequential numbering, E.164 phone format, birthday tracking enabled by default.
