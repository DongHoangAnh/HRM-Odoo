# HR Leave Production Spec Pack

This folder contains the production-ready specification set for the HR Leave module, organized into 5 layers.

## Layers

1. [Business](01_business_spec.md)
2. [Data](02_data_spec.md)
3. [Security](03_security_spec.md)
4. [UI](04_ui_spec.md)
5. [Integration](05_integration_spec.md)

## Scope

This pack covers:
- hr.leave
- hr.leave.type
- hr.leave.allocation
- hr.leave.accrual.plan
- hr.leave.accrual.level
- hr.employee leave extension fields
- hr.employee.public leave extension fields
- hr.department leave extension fields
- calendar leave behaviors tied to time off

## Intended Use

Use this pack as the build contract for production implementation:
- define leave request and allocation business outcomes
- define accrual plan and accrual level behavior
- define access rules and privacy boundaries
- define views, actions, and dashboard flows
- define integrations with attendance, employee presence, calendar, and payroll-related flows

## Relationship to Feature Specs

The Gherkin feature specs in this folder remain the detailed scenario layer.
The files in this folder summarize the production architecture needed to build and ship the module safely.
