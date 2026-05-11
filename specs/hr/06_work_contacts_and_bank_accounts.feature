Feature: Manage Work Contacts and Bank Accounts
  As a Human Resources Manager
  I want to manage work contacts and salary distribution across bank accounts
  So that I can ensure accurate payment processing and contact information

  Background:
    Given I am logged in as an HR user
    And the employee "John Doe" exists

  Scenario: Create work contact for employee
    When I save the employee without a work contact
    Then a work contact should be automatically created
    And the work contact should be linked to the employee
    And the work contact should be named "John Doe"

  Scenario: Sync employee phone to work contact
    Given the employee has work_contact_id
    And the work contact is unique to this employee
    When I update the employee's work_phone to "+1-555-123-4567"
    Then the work contact's phone should be updated

  Scenario: Sync employee email to work contact
    Given the employee has work_contact_id
    And the work contact is unique to this employee
    When I update the employee's work_email to "john.doe@company.com"
    Then the work contact's email should be updated

  Scenario: Do not sync when work contact is shared
    Given the work contact is shared by multiple employees
    When I update one employee's work_phone
    Then the work contact should not be updated
    And only the employee field should change

  Scenario: Add bank account to employee
    Given a bank account "Account 123" exists for the work contact
    When I add the bank account to the employee
    Then the bank account should be in bank_account_ids
    And the salary_distribution should be updated

  Scenario: Remove bank account from employee
    Given the employee has bank account "Account 123"
    And salary_distribution has 100% allocated to "Account 123"
    When I remove the bank account
    Then the bank account should be removed from bank_account_ids
    And the percentage should be redistributed to remaining accounts

  Scenario: Salary distribution with single bank account
    Given the employee has one bank account
    When I view salary_distribution
    Then it should have 100% allocated to that account
    And sequence should be 1

  Scenario: Salary distribution with multiple bank accounts
    Given the employee has three bank accounts
    When I add them sequentially
    Then each should have 33.33% allocated
    And they should be ordered by sequence

  Scenario: Salary distribution with fixed amount and percentage
    Given the employee has two bank accounts
    When I set first account to 2000 (fixed amount)
    And I set second account to remaining percentage
    Then salary_distribution should preserve the order
    And fixed amounts should come before percentages

  Scenario: Validate salary distribution totals 100%
    Given the employee has two bank accounts
    When I set distribution:
      | Account | Amount | Is Percentage |
      | A       | 50     | Yes           |
      | B       | 40     | Yes           |
    Then a validation error should occur
    And the message should indicate total must be 100%

  Scenario: Allow empty salary distribution
    Given the employee has bank accounts but no distribution
    When I save the employee
    Then no error should occur

  Scenario: Sync salary distribution when adding accounts
    Given the employee has two bank accounts with distribution
    When I add a third bank account
    Then the distribution should be automatically synchronized
    And the new account should have remaining percentage

  Scenario: Redistribute percentages when removing account
    Given the employee has distribution:
      | Account | Amount | Is Percentage |
      | A       | 50     | Yes           |
      | B       | 30     | Yes           |
      | C       | 20     | Yes           |
    When I remove account B
    Then the distribution should be:
      | Account | Amount | Is Percentage |
      | A       | 50     | Yes           |
      | C       | 50     | Yes           |

  Scenario: Prevent distribution validation error on fixed amounts
    Given the employee has distribution with fixed amounts
    When I validate the distribution
    Then no validation error should occur for fixed amounts
    And validation should only check percentages

  Scenario: Trusted bank account detection
    Given the employee has bank accounts
    And one account has allow_out_payment=True
    When I compute is_trusted_bank_account
    Then it should return True

  Scenario: Multiple bank accounts detection
    Given the employee has two or more bank accounts
    When I compute has_multiple_bank_accounts
    Then it should return True

  Scenario: Primary bank account selection
    Given the employee has multiple bank accounts
    And the first account has allow_out_payment=True
    When I compute primary_bank_account_id
    Then the first trusted account should be returned

  Scenario: Bank account domain filtering
    Given the employee has work_contact_id
    When I create a bank account
    Then the domain should only show accounts linked to the work_contact_id
    And accounts from the employee's company

  Scenario: Remove duplicate bank accounts
    Given the employee has the same bank account added twice
    When I save the employee
    Then the system should handle the duplicate gracefully
    And only one instance should be kept

  Scenario: Sync work contact to bank accounts
    Given the employee changes work_contact_id
    When I save the employee
    Then existing bank accounts should be updated to the new contact
    And trusted accounts should be reset if changing contact
