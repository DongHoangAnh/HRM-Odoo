# HR Payroll UI Spec

## Views

### Payroll Period (hr.payslip.run)
- **List View**: Show payroll period, date range, # of payslips, state
- **Form View**: 
  - Period name, start/end dates
  - Quick stats: Total gross, total net, # employees
  - Payslip list with inline preview
  - Action: Generate payslips, Approve all, Export to Finance
  - State indicator

### Payslip (hr.payslip)
- **List View**: Employee, period, gross, net, state, approval status
  - Filters by: period, department, approval state
  - Bulk actions: Approve, Print, Export
- **Form View**:
  - Employee info (name, ID, department, manager)
  - Period (from/to dates)
  - Salary components breakdown (sections: gross, deductions, net)
  - Tabs: Payslip lines, Work entries, Leave, Attachments
  - Buttons: Save, Approve, Reject, Print, Send to employee
  - State indicator with workflow badges

### Payroll Structure (hr.payroll.structure)
- **List View**: Structure name, company, # of rules, active status
- **Form View**:
  - Name, code, company
  - Salary rules list (filtered by category):
    - Gross section
    - Deductions section
    - Tax section
    - Net calculation
  - Default structure toggle

### Salary Rule (hr.salary.rule)
- **List View**: Rule name, code, category, amount type, sequence
- **Form View**:
  - Name, code, category, sequence
  - Amount type (fixed, percentage, code)
  - Amount expression or Python code
  - Active status
  - Preview: Calculate for sample inputs

## Tabs and Sections

### Payslip Form Tabs:
1. **Main**: Employee, period, basic info
2. **Salary Components**: 
   - Gross (base, allowances, overtime, bonuses)
   - Deductions (loans, advances, meals)
   - Tax (BHXH, BHYT, BHTN, PIT)
   - Net calculation
3. **Work Entries**: List of work entries used for calculation
4. **Leave**: Leave taken/balance during period
5. **Bank/Payment**: Payment method, bank account, reference
6. **Attachments**: Related documents (work entries, leave, etc.)

## Dialogs and Wizards

### Batch Payslip Generation:
- Select period, department (optional), employees (optional)
- Confirm: # of payslips to generate
- Generate and show progress

### Export to Finance:
- Select format: CSV, Excel, JSON
- Include fields: Employee ID, gross, net, bank account
- Confirm and download

### Payslip Approval:
- Show payslip summary
- Confirm gross/net amounts
- Optional comments
- Approve/Reject buttons

## Reports

### Payroll Summary Report:
- Period, total employees, total gross, total net, total tax
- Breakdown by department
- Comparison to previous period

### Payslip Variance Report:
- Employee, salary increase/decrease vs previous month
- Reason (promotion, leave taken, etc.)

### Tax Report:
- Total tax withheld
- Breakdown by employee category
- Compliance check with tax slabs

### Payment Report:
- Bank transfer details
- Cheques to print
- Cash payment list
- Reconciliation status

## Mobile/Portal (Employee Self-Service)

### Employee Payslip Portal:
- List of payslips (with filters by year/month)
- View payslip details:
  - Gross salary
  - Deductions breakdown
  - Net salary
  - Payment date
- Download payslip PDF
- View tax certificate (on demand)

## Print/Export

### Payslip Document:
- Professional layout with company logo
- Employee name, ID, period
- Salary components table
- Gross/Net summary
- Bank transfer details (if applicable)
- Signature block
- Remarks/notes section

### Excel Export:
- One row per employee
- Columns: ID, Name, Department, Gross, Tax, Deductions, Net, Payment Status
