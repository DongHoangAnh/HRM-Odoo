# HR Employee Specifications (Gherkin/BDD Format)

This directory contains comprehensive Gherkin-based BDD specifications for all use cases in the Odoo HR Employee module (`hr.employee` model).

## Specification Files

### 1. [01_create_employee.feature](01_create_employee.feature)
**Purpose**: Covers all aspects of employee creation
- Basic employee creation with required information
- Employee creation with user links
- Phone information and formatting
- Personal information (birthday, place of birth, etc.)
- Initial version generation
- Work contact automatic creation
- Constraint handling (duplicate users)
- Employee categories and timezone
- Badge ID and PIN assignment

**Key Scenarios**: 13 scenarios covering basic to advanced creation workflows

---

### 2. [02_manage_employee_information.feature](02_manage_employee_information.feature)
**Purpose**: Specifications for updating and maintaining employee data
- Name updates and synchronization
- Work contact details management
- Personal information updates
- Timezone management
- Manager and coach relationships
- Phone validation and formatting
- Contract date management
- Employee categorization
- Company restrictions and validations
- Departure information management
- Image and profile management

**Key Scenarios**: 18 scenarios for information lifecycle

---

### 3. [03_manage_versions_and_contracts.feature](03_manage_versions_and_contracts.feature)
**Purpose**: Employee versioning and contract management
- Initial version creation
- New version creation at specific dates
- Contract creation and management
- Version date retrieval
- Current version computation
- Version field updates
- Contract date checking and validation
- First version/contract date retrieval
- Permanent contract handling
- Gap detection in employment

**Key Scenarios**: 17 scenarios for versioning and contracts

---

### 4. [04_presence_and_activity_tracking.feature](04_presence_and_activity_tracking.feature)
**Purpose**: Employee presence monitoring and activity tracking
- Presence state computation (present, absent, out of working hours, archived)
- Presence control validation
- Presence icon display
- Last activity tracking
- Timezone-aware activity timestamps
- Employee working hours detection
- Newly hired employee detection (90-day threshold)
- Calendar timezone computations
- Multi-timezone coordination

**Key Scenarios**: 18 scenarios for presence and activity

---

### 5. [05_user_creation_synchronization.feature](05_user_creation_synchronization.feature)
**Purpose**: User creation from employees and data synchronization
- Single user creation from employee
- User data population (phone, email, login)
- Batch user creation
- Email validation and uniqueness
- Duplicate email prevention
- User-employee synchronization
- Image synchronization
- Timezone synchronization
- Data conflicts resolution
- Notification and confirmation workflows

**Key Scenarios**: 18 scenarios for user management

---

### 6. [06_work_contacts_and_bank_accounts.feature](06_work_contacts_and_bank_accounts.feature)
**Purpose**: Work contact management and salary distribution
- Work contact auto-creation
- Phone and email synchronization with contacts
- Multi-employee contact sharing
- Bank account management
- Salary distribution across accounts
- Percentage and fixed amount allocation
- Distribution validation (100% total)
- Automatic redistribution on account changes
- Trusted account detection
- Account domain filtering

**Key Scenarios**: 20 scenarios for contacts and accounts

---

### 7. [07_archive_unarchive_employees.feature](07_archive_unarchive_employees.feature)
**Purpose**: Employee archival and reactivation workflows
- Basic employee archival
- Relationship clearing on archive (manager, coach, subordinates)
- Archival with and without wizard
- Departure information storage
- Employee unarchival with data cleanup
- Circular relationship prevention
- Multiple employee archival
- Manager and coach role handling

**Key Scenarios**: 14 scenarios for archival workflows

---

### 8. [08_validate_identification_credentials.feature](08_validate_identification_credentials.feature)
**Purpose**: Employee identification validation
- Barcode validation (alphanumeric, max 18 chars, uniqueness)
- Barcode generation
- PIN validation (digits only)
- Identification methods for POS and Kiosk
- Credential constraints and error handling
- Case sensitivity
- Combined barcode and PIN usage

**Key Scenarios**: 17 scenarios for credential validation

---

### 9. [09_notify_expiring_contracts_permits.feature](09_notify_expiring_contracts_permits.feature)
**Purpose**: Contract and work permit expiration notifications
- Contract expiration notifications
- Work permit expiration notifications
- Notification scheduling based on company notice periods
- Batch notifications across multiple employees
- HR responsible person assignment
- Activity creation with deadlines
- Multi-company notification handling
- Duplicate notification prevention
- Combined contract and permit notifications

**Key Scenarios**: 17 scenarios for notifications

---

### 10. [10_access_control_security.feature](10_access_control_security.feature)
**Purpose**: Access control and security for employee records
- HR user access to all fields
- Non-HR user restrictions
- Public employee data access
- Field group-based restrictions
- Prefetch limitations
- Cache management for access control
- Display name security
- Related contacts protection
- Archive operation access control

**Key Scenarios**: 15 scenarios for security

---

### 11. [11_lifecycle_and_scenarios.feature](11_lifecycle_and_scenarios.feature)
**Purpose**: Employee lifecycle events and special scenarios
- Onboarding flow
- Demo data loading
- Formview access control
- Department channel subscriptions
- Avatar generation and management
- Field change tracking
- Departure notifications
- Related contacts actions
- Birthday display configuration
- Newly hired status filtering

**Key Scenarios**: 15 scenarios for lifecycle management

### 12. [12_department_management.feature](12_department_management.feature)
**Purpose**: Department hierarchy and department actions
- Department creation and quick create
- Hierarchical naming
- Search on complete name
- Recursive department prevention
- Manager change propagates to employees
- Department employee and activity plan actions
- Department hierarchy payload

**Key Scenarios**: 13 scenarios for department management

### 13. [13_user_employee_sync_and_access.feature](13_user_employee_sync_and_access.feature)
**Purpose**: User and employee synchronization and access rules
- Employee domain filtering by company
- Current company employee resolution
- User creation with employee linking
- Synchronization of employee fields from user writes
- HR responsible notifications
- User preference view access
- Employee actions and self-access field sets

**Key Scenarios**: 19 scenarios for user synchronization

### 14. [14_version_and_contract_lifecycle.feature](14_version_and_contract_lifecycle.feature)
**Purpose**: Version and contract lifecycle management
- Contract template copying
- Contract date validation
- Overlap prevention
- Version archive/unlink safety
- Contract date synchronization across versions
- Contract form-view routing
- Current/past/future/in-contract flags
- Department membership and schedule fields

**Key Scenarios**: 25 scenarios for version and contract lifecycle

### 15. [15_partner_and_bank_access.feature](15_partner_and_bank_access.feature)
**Purpose**: Employee contact and bank-account handling
- Employee counts from related contacts
- Open related employees from partners
- Delete protection for employee-linked contacts
- Salary allocation on bank accounts
- Allocation wizard delegation
- Masked display names for non-HR users
- Employee bank account search and link resolution

**Key Scenarios**: 14 scenarios for contact and bank access

---

## Statistics

- **Total Specification Files**: 15
- **Total Scenarios**: 254
- **Coverage Areas**: Employee CRUD, versioning, contracts, presence, users, contacts, departments, bank accounts, archival, validation, notifications, security, and lifecycle

## How to Use These Specs

### For Development
1. Use these specs as requirements for implementing features
2. Each scenario represents a specific behavior that should be tested
3. Follow the Given-When-Then format for clarity

### For Testing
1. Convert scenarios to automated tests using BDD frameworks
   - Python: `behave` or `pytest-bdd`
   - JavaScript: `cucumber-js`
   - Java: `cucumber-java`
2. Each scenario should have corresponding test code

### For Documentation
1. Use these specs to document system behavior
2. Share with stakeholders for validation
3. Keep specs updated as features evolve

## Format: Gherkin/BDD

Each file follows the Gherkin syntax:
- **Feature**: Describes the overall functionality
- **Background**: Common setup for all scenarios
- **Scenario**: Individual test case with:
  - **Given**: Initial state/prerequisites
  - **When**: Action being tested
  - **Then**: Expected outcome
  - **And**: Additional steps for complex scenarios

## Next Steps

1. **Implement Tests**: Convert these specs to automated tests
2. **Validation**: Run tests against the actual `hr.employee` model
3. **Maintenance**: Update specs as new features are added
4. **Integration**: Integrate with CI/CD pipelines
5. **Documentation**: Generate documentation from these specs

## Related Files

- Model: `/odoo/addons/hr/models/hr_employee.py`
- Views: `/odoo/addons/hr/views/`
- Tests: `/odoo/addons/hr/tests/`

---

**Created**: 2025-01-11
**Format**: Gherkin/BDD
**Scope**: HR Employee Module (hr.employee)
