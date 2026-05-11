# HR Payroll Integration Spec

## Integration Points

### 1. HR Work Entry → Payroll
**Data flow**: Work entries → Payslip lines
- **Input**: Work entries for the payroll period (by employee, date range)
- **Processing**: 
  - Group work entries by work entry type
  - Calculate hours/days
  - Map to salary rules
- **Output**: Payslip lines with calculated amounts
- **Frequency**: On-demand (payslip generation) or batch (payroll run)

### 2. Payroll → Finance
**Data flow**: Approved payslips → Bank transfer file / Finance voucher
- **Input**: Approved payslips (from payslip.run)
- **Processing**:
  - Format salary data per Finance requirements
  - Generate bank transfer file (CSV/XML)
  - Create journal entries for payroll expense
- **Output**: Bank file, finance journal entries
- **Frequency**: After payslip approval (monthly)
- **Format**: CSV (bank name, account, amount, employee ID)

### 3. Leave → Payroll
**Data flow**: Approved leave → Payslip deductions or additions
- **Input**: Approved leave records for the period
- **Processing**:
  - Calculate unpaid leave deduction
  - Calculate leave encashment (if applicable)
  - Map to salary rules
- **Output**: Payslip lines for leave-related items
- **Frequency**: On payslip generation

### 4. Attendance → Work Entry → Payroll
**Data flow**: Attendance check-in/out → Work entry → Payslip
- **Input**: Approved attendance records
- **Processing**:
  - Generate work entries (via HR Work Entry module)
  - Calculate overtime
  - Feed into payslip calculation
- **Output**: Payslip with overtime calculations
- **Frequency**: Before payslip generation

### 5. Employee Data → Payroll
**Data flow**: Employee contract, bank account, tax dependents → Payslip
- **Input**: Employee contract, bank account, tax deduction info
- **Processing**:
  - Validate contract is active for period
  - Apply tax rates and deduction rules
  - Verify bank account is active
- **Output**: Payslip with correct rates and payment routing
- **Frequency**: On payslip generation (validation)

### 6. Department Transfer → Payroll
**Data flow**: Department transfer mid-period → Split payslip
- **Input**: Department transfer date
- **Processing**:
  - Split work entries by department
  - Calculate pro-rata salary
  - Assign to correct cost center
- **Output**: Payslip with department attribution
- **Frequency**: If transfer occurs during payroll period

## APIs and Webhooks

### Internal APIs
- `hr_payslip.generate_payslips(period_id, employee_ids=None)`
  - Generate payslips for period and employees
  - Returns: List of created payslip IDs
  
- `hr_payslip.calculate_salary_lines(employee_id, date_from, date_to, structure_id)`
  - Calculate salary lines for specific period
  - Returns: Dict of {category: amount}
  
- `hr_payslip.export_to_finance(payslip_run_id, format='csv')`
  - Export approved payslips for finance
  - Returns: File binary data

### External Integrations (Out of Scope in Phase 1)
- Bank file generation API (future)
- Tax authority reporting API (future)
- Accounting software sync (future)

## Data Format Specifications

### Finance Export Format (CSV)
```
employee_id,employee_name,department,gross_salary,bhxh,bhyt,bhtn,pit,total_deduction,net_salary,bank_account,transfer_date
E001,Nguyễn Văn A,Nhân Sự,10000000,800000,150000,30000,500000,1480000,8520000,1234567890,2025-01-31
```

### Payslip JSON Format
```json
{
  "id": "payslip_123",
  "employee_id": "E001",
  "period": "2025-01",
  "date_from": "2025-01-01",
  "date_to": "2025-01-31",
  "gross_salary": 10000000,
  "deductions": {
    "bhxh": 800000,
    "loan": 500000
  },
  "tax": {
    "pit": 500000
  },
  "net_salary": 8200000,
  "lines": [...]
}
```

## Audit and Logging

- All payslip modifications logged in ir.logging
- Finance exports logged with timestamp and user
- Bank file generation logged with file ID and confirmation
- Reconciliation status tracked (sent to bank, confirmed, paid)

## Error Handling

- Invalid contract for period: Prevent payslip creation
- Missing bank account: Warn but allow (manual payment)
- Invalid tax rates: Block calculation until corrected
- Negative net salary: Warn (may indicate error)
- Duplicate payslip: Prevent or merge

## System Constraints

- Payroll calculation must complete within 5 minutes for 100 employees
- File export must handle up to 10,000 payslips
- Timezone handling: All dates in Vietnam timezone (UTC+7)
- Salary components must be modular (add/remove without code changes)
