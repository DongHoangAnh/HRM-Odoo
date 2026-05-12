# Feature Specification: Manage Work Contacts and Bank Accounts

**Feature Branch**: `004-manage-work-contacts-bank-accounts`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Manage Work Contacts and Bank Accounts\n  As a Human Resources Manager\n  I want to manage work contacts and salary distribution across bank accounts\n  So that I can ensure accurate payment processing and contact information"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Auto-create and sync work contacts (Priority: P1)

HR managers must have work contacts automatically created and kept in sync with employee phone/email to ensure communications are current and centralized.

**Why this priority**: Accurate contact information is critical for employee communication, payroll notifications, and compliance.

**Independent Test**: Create employee without contact and verify auto-creation; update phone/email and verify sync to shared vs. unique contacts.

**Acceptance Scenarios**:

1. **Given** an employee is saved without a work contact, **When** the save completes, **Then** a work contact is automatically created with the employee's name and linked via `work_contact_id`.
2. **Given** the work contact is unique to the employee, **When** employee phone/email is updated, **Then** the work contact phone/email is synchronized.
3. **Given** the work contact is shared by multiple employees, **When** one employee's phone changes, **Then** the shared contact is NOT updated; only the employee field changes.

---

### User Story 2 - Manage bank accounts and salary distribution (Priority: P1)

HR managers must add/remove bank accounts and configure how salary is split across accounts (by percentage or fixed amount) with automatic redistribution on account changes.

**Why this priority**: Accurate payroll distribution is mandatory for on-time, correct salary payments.

**Independent Test**: Add single, multiple, and mixed (fixed+percentage) bank accounts; remove accounts and verify redistribution; validate totals.

**Acceptance Scenarios**:

1. **Given** an employee and bank account exist, **When** the account is added to the employee, **Then** the account appears in `bank_account_ids` and `salary_distribution` is updated.
2. **Given** multiple bank accounts with percentage allocation, **When** a new account is added, **Then** distribution is auto-synchronized and the new account receives the remaining percentage.
3. **Given** distribution with percentages totaling less than 100%, **When** saved, **Then** a validation error occurs indicating total must be 100%.

---

### User Story 3 - Primary bank account and trust detection (Priority: P2)

HR managers must identify trusted bank accounts (those marked for outgoing payments) and select a primary account for payroll default.

**Why this priority**: Streamlines payroll configuration and reduces manual selection errors.

**Independent Test**: Set `allow_out_payment=True` on accounts; verify `is_trusted_bank_account` and `primary_bank_account_id` computations.

**Acceptance Scenarios**:

1. **Given** one or more bank accounts with `allow_out_payment=True`, **When** `is_trusted_bank_account` is computed, **Then** it returns True.
2. **Given** multiple trusted accounts, **When** `primary_bank_account_id` is computed, **Then** the first trusted account is returned.

---

### User Story 4 - Prevent duplicates and handle work contact changes (Priority: P2)

HR managers must be protected from adding duplicate bank accounts and have existing accounts updated when work contact changes.

**Why this priority**: Prevents payroll errors from duplicate allocations and ensures data consistency during contact updates.

**Independent Test**: Attempt to add same account twice; change work contact and verify all bank accounts reflect new contact.

**Acceptance Scenarios**:

1. **Given** an employee with the same bank account added twice, **When** saved, **Then** the system gracefully handles the duplicate and retains only one instance.
2. **Given** an employee changes `work_contact_id`, **When** saved, **Then** existing bank accounts are updated to link to the new work contact.

---

### Edge Cases

- Salary distribution with fixed amounts: validation should ignore fixed amounts and only check percentage totals.
- Empty salary distribution (no accounts or no allocation): system should allow without error.
- Removing a bank account with allocated percentage: remaining accounts must have their percentages recalculated to total 100%.
- Fixed amount + percentage mixing: fixed amounts should come first in sequence; percentages calculated on remainder.
- Bank account domain filtering: only accounts linked to the employee's work contact or from the employee's company should be available.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST automatically create a work contact when an employee is saved without one, naming it after the employee and linking via `work_contact_id`.
- **FR-002**: System MUST synchronize employee `work_phone` to the unique work contact's phone when the employee is updated (only if contact is not shared).
- **FR-003**: System MUST synchronize employee `work_email` to the unique work contact's email when the employee is updated (only if contact is not shared).
- **FR-004**: System MUST NOT propagate phone/email changes to shared work contacts; only the employee record updates.
- **FR-005**: System MUST allow adding bank accounts to an employee and maintain a list in `bank_account_ids`.
- **FR-006**: System MUST maintain a `salary_distribution` list with sequence, amount/percentage, and is_percentage flag.
- **FR-007**: System MUST automatically compute `is_trusted_bank_account` = True if any account has `allow_out_payment=True`.
- **FR-008**: System MUST automatically compute `has_multiple_bank_accounts` = True if two or more accounts exist.
- **FR-009**: System MUST automatically compute `primary_bank_account_id` as the first account with `allow_out_payment=True`.
- **FR-010**: System MUST validate percentage-based salary distributions total 100% and reject distributions that don't.
- **FR-011**: System MUST allow empty salary distributions (no validation error).
- **FR-012**: System MUST NOT validate fixed-amount salary distributions against the 100% rule; only percentages must sum to 100%.
- **FR-013**: System MUST automatically redistribute percentages when a bank account is removed, recalculating to total 100%.
- **FR-014**: System MUST automatically synchronize salary distribution when new accounts are added.
- **FR-015**: System MUST prevent duplicate bank accounts; when detected, retain only one instance.
- **FR-016**: System MUST update all existing bank accounts to link to a new work contact when `work_contact_id` changes.
- **FR-017**: System MUST filter available bank accounts by work contact and employee company.

### Key Entities *(include if feature involves data)*

- **hr.employee**: maintains `work_contact_id`, `bank_account_ids`, `salary_distribution`, computed fields `is_trusted_bank_account`, `has_multiple_bank_accounts`, `primary_bank_account_id`.
- **res.partner (Work Contact)**: contact record; attributes include phone, email, image, linked to one or more employees.
- **bank.account**: bank account record; attributes include `allow_out_payment`, linked to work contact and company.
- **salary.distribution**: line item; attributes include `sequence`, `amount`, `is_percentage` (boolean).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Work contact auto-creation occurs in 100% of employee saves without a contact.
- **SC-002**: Phone/email synchronization to unique work contacts completes within 1 second in 99% of updates.
- **SC-003**: Shared work contact protection prevents unintended updates in 100% of multi-employee contact scenarios.
- **SC-004**: Bank account duplicate detection and removal succeeds in 100% of duplicate-add attempts.
- **SC-005**: Salary distribution validation correctly rejects non-100% percentage totals in 100% of attempts.
- **SC-006**: Percentage redistribution after account removal recalculates to 100% in 100% of removals.
- **SC-007**: Primary bank account computation returns the first trusted account in 100% of queries.
- **SC-008**: Work contact migration (changing `work_contact_id`) updates all linked bank accounts within 2 seconds in 95% of updates.
- **SC-009**: Empty salary distributions are accepted without error in 100% of cases.

## Assumptions

- Bank accounts are pre-existing records managed by the accounting/banking module and linked to work contacts.
- Work contact uniqueness is tracked via a field or pattern (e.g., one employee has exclusive link).
- Salary distribution line items are stored as child records with sequence order preserved.
- Fixed-amount salary distributions are for gross salary splits; percentage remainder is calculated on net.
- Company filtering for bank accounts assumes employee has a company_id; if not, all company accounts are available.
- Duplicate detection compares bank account IDs; if the same account is added in one operation, only one is retained.
