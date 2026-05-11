# Feature Specification: Manage Employee Information

**Feature Branch**: `002-manage-employee-information`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Manage Employee Information\n  As a Human Resources Manager\n  I want to update and manage employee information\n  So that employee records remain current and accurate\n\n  Background:\n    Given I am logged in as an HR user\n    And the employee \"John Doe\" exists\n    And the employee has basic information filled in\n\n  Scenario: Update employee name\n    When I update the employee's name from \"John Doe\" to \"John D. Doe\"\n    Then the employee's name should be updated\n    And the resource record name should be synchronized\n    And a tracking log should record the name change\n\n  Scenario: Update employee work contact details\n    Given the employee has a work contact\n    When I update the employee's work phone to \"+1 (555) 123-4567\"\n    And I update the employee's work email to \"john.new@company.com\"\n    Then the work phone should be formatted to international format\n    And the work email should be stored\n    And if the work contact is unique to this employee, the contact should be updated\n\n  Scenario: Synchronize work contact details to multiple employees\n    Given multiple employees share the same work contact\n    When I update one employee's work phone\n    Then the update should not propagate to the shared work contact\n\n  Scenario: Create work contact if missing\n    Given the employee has no work contact\n    When I save the employee record\n    Then a work contact should be automatically created\n    And the work contact should be linked to the employee\n\n  Scenario: Update employee personal information\n    When I update the employee's personal information:\n      | Field               | Value              |\n      | legal_name          | John Paul Doe      |\n      | birthday            | 1990-05-15         |\n      | place_of_birth      | Los Angeles        |\n      | country_of_birth    | United States      |\n    Then all personal information should be stored\n    And the employee should have access to this private data\n\n  Scenario: Update employee timezone\n    When I update the employee's timezone to \"Europe/London\"\n    Then the employee's timezone should be updated\n    And if the employee has a linked user, the user's timezone should also be updated\n\n  Scenario: Update employee manager\n    Given another employee \"Jane Manager\" exists\n    When I set \"Jane Manager\" as the manager of \"John Doe\"\n    Then \"John Doe\" should have \"Jane Manager\" as parent_id\n    And \"John Doe\" should appear in \"Jane Manager's\" child_ids\n    And the manager field should be tracked\n\n  Scenario: Update employee coach\n    Given another employee \"Tom Coach\" exists\n    When I set \"Tom Coach\" as the coach of \"John Doe\"\n    Then \"John Doe\" should have \"Tom Coach\" as coach_id\n    And the coach should be from the same company or company-agnostic\n\n  Scenario: Automatically update coach when manager changes\n    Given the employee has manager \"Jane Manager\"\n    And the employee has no explicit coach set\n    When I change the manager to \"Tom Manager\"\n    Then the coach should automatically update to \"Tom Manager\"\n\n  Scenario: Update phone validation\n    When I update work_phone to \"invalid_phone\" for a company in US\n    Then the phone should be formatted based on the country\n    And if the format is invalid, the system should attempt international format\n\n  Scenario: Update employee company\n    Given the employee works in \"Company A\"\n    When I try to change the employee's company to \"Company B\"\n    Then a warning should be displayed about potential data loss\n    And the employee should not be moved automatically\n    And a recommendation to create a new employee should be shown\n\n  Scenario: Update employee contract dates\n    When I update the employee's contract_date_start to \"2024-01-01\"\n    And I update the contract_date_end to \"2024-12-31\"\n    Then the contract dates should be stored in the version\n    And the employee's is_in_contract status should be updated\n\n  Scenario: Prevent empty contract end date when start date exists\n    Given the employee has contract_date_start set\n    When I try to update contract_date_end to empty\n    Then the system should allow it for indefinite contracts\n    And is_in_contract should return False for dates after an empty date\n\n  Scenario: Update employee categories\n    Given the employee category \"Management\" and \"Remote\" exist\n    When I update the employee's categories to include both\n    Then the employee should have both categories\n    And the employee can be filtered by these categories\n\n  Scenario: Update employee with multiple company restrictions\n    Given the employee \"John Doe\" works in \"Company A\"\n    And \"Company B\" exists\n    When I try to set a manager from \"Company B\"\n    Then the system should only allow managers from \"Company A\" or company-agnostic managers\n    And the manager field domain should be validated\n\n  Scenario: Update employee departure information\n    When I update the employee's departure information:\n      | Field                   | Value              |\n      | departure_date          | 2025-03-31         |\n      | departure_reason_id     | Personal           |\n      | departure_description   | Resigned           |\n    Then the departure information should be stored\n    And a message post should be created in the employee's timeline\n\n  Scenario: Track employee information changes\n    When I update multiple fields:\n      | Field             | Value      |\n      | name              | New Name   |\n      | place_of_birth    | New City   |\n    Then each tracked field should have a log entry\n    And the modification history should be accessible\n\n  Scenario: Update employee image\n    When I upload a new profile image for the employee\n    Then the image_1920 field should be updated\n    And the work contact image should be synchronized\n    And other image sizes should be computed automatically"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Update core employee details (Priority: P1)

HR users must be able to update an employee's primary information (name, personal info, timezone, image) so that records remain accurate and downstream records (resource, contact, user) stay synchronized where appropriate.

**Why this priority**: Core HR data accuracy is critical for payroll, access control, and reporting.

**Independent Test**: Update the `name`, `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `timezone`, and `image_1920` fields and verify persistence, synchronization, and audit logs.

**Acceptance Scenarios**:

1. Given an HR user and an existing employee, When they change the employee name, Then the employee record and linked resource name update and an audit log is created.
2. Given an employee without a work contact, When the record is saved, Then a work contact is created and linked.

---

### User Story 2 - Manage contact information (Priority: P1)

HR users must be able to add and update work contact details (phone, email) with country-aware formatting and safeguards for shared contacts.

**Why this priority**: Correct contact details are required for communications and legal notices.

**Independent Test**: Update work phone/email for an employee that has a unique contact and for employees that share a contact; validate formatting and propagation rules.

**Acceptance Scenarios**:

1. Given the employee has a work contact, When phone/email updated, Then phone is normalized to international format and email stored.
2. Given multiple employees share a contact, When one employee's phone changes, Then shared contact is not modified.

---

### User Story 3 - Manager & coach relationships (Priority: P2)

HR users must set managers and coaches while enforcing company-domain constraints and automatic coach fallback when manager changes.

**Why this priority**: Reporting lines affect approvals and hierarchical workflows.

**Independent Test**: Set manager/coach from same company and from different company; change manager when coach unset and verify coach updates.

**Acceptance Scenarios**:

1. Given a manager exists in the same company, When assigned, Then `parent_id` and reverse `child_ids` reflect the relation and field is tracked.
2. Given a manager change and no explicit coach, When manager updated, Then coach auto-updates to new manager.

---

### User Story 4 - Contracts, company moves & categories (Priority: P2)

HR users must manage contract dates, categories, and be warned before moving employees between companies to prevent unintended data loss.

**Why this priority**: Contracts and company assignments affect legal & payroll obligations.

**Independent Test**: Update contract start/end, verify versioning and `is_in_contract`; attempt company change and confirm warning and recommendation flow.

**Acceptance Scenarios**:

1. Given contract start/end provided, When saved, Then contract stored in version and `is_in_contract` reflects status.
2. Given company change attempted, When confirmed negative, Then employee not moved and a recommendation to create a new employee is shown.

---

### Edge Cases

- Updating a shared work contact must not unintentionally update other employees' contact details.
- Empty contract end date = indefinite contract; `is_in_contract` calculation must handle open-ended ranges.
- Phone numbers from unknown country codes fallback to international formatting attempt.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow updating employee primary fields: `name`, `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `timezone`, `image_1920`.
- **FR-002**: System MUST synchronize the employee `name` to the related resource record and create an audit log entry for tracked fields.
- **FR-003**: System MUST create a work contact automatically when none exists and link it to the employee.
- **FR-004**: System MUST normalize phones to international format based on company country; if invalid, attempt international fallback.
- **FR-005**: System MUST store and validate work emails.
- **FR-006**: System MUST prevent propagation of updates to shared contacts when multiple employees reference the same contact.
- **FR-007**: System MUST allow assigning a manager and coach; manager assignments must respect company-domain constraints.
- **FR-008**: System MUST auto-update coach to match manager when no explicit coach set.
- **FR-009**: System MUST store contract dates within versions and compute `is_in_contract` accordingly, including open-ended contracts.
- **FR-010**: System MUST warn before changing an employee's company and prevent automatic move without explicit confirmation.
- **FR-011**: System MUST track changes to relevant fields and make modification history accessible.
- **FR-012**: System MUST update `image_1920` and derive other image sizes; synchronize contact image when applicable.

### Key Entities *(include if feature involves data)*

- **Employee**: core person record; attributes include `name`, `legal_name`, `birthday`, `place_of_birth`, `country_of_birth`, `timezone`, `company_id`, `parent_id`, `coach_id`, `image_1920`, categories, contract versions.
- **WorkContact**: contact record linked to employee; attributes include phone, email, image, uniqueness marker.
- **ContractVersion**: stores versioned contract dates and status; used to compute `is_in_contract`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Employee core updates (name, personal info, timezone) reflect in related records within 5 seconds of save in 95% of test runs.
- **SC-002**: Phone normalization succeeds for 95% of valid national numbers; invalid numbers fall back to international formatting attempt.
- **SC-003**: Work contact auto-creation occurs for 100% of employees saved without a contact.
- **SC-004**: Attempting to move an employee between companies displays a warning in 100% of test cases and prevents automatic move without confirmation.
- **SC-005**: Tracked field changes produce audit entries accessible in the employee modification history for 100% of updates.
- **SC-006**: Uploaded profile images update `image_1920` and derived sizes in 100% of test uploads.

## Assumptions

- HR user performing actions has the necessary ACL permissions to update employee records.
- Company and user timezone data are available and managed by existing systems.
- Phone formatting uses an existing library/service (e.g., libphonenumber) when available; otherwise, fallback is used.
- Shared contact detection is available via a uniqueness key on `WorkContact`.
- Data privacy: personal fields are accessible only to authorized roles; compliance (GDPR/etc.) is handled by project-wide policies.
