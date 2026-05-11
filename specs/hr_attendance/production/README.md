# HR Attendance Production Spec Pack

This folder contains the production-ready specification set for the HR Attendance module, organized into 5 layers.

## Layers

1. [Business](01_business_spec.md)
2. [Data](02_data_spec.md)
3. [Security](03_security_spec.md)
4. [UI](04_ui_spec.md)
5. [Integration](05_integration_spec.md)

## Scope

This pack covers:
- hr.attendance
- hr.attendance.overtime.line
- hr.attendance.overtime.rule
- hr.attendance.overtime.ruleset
- res.company attendance settings
- res.config.settings attendance settings

## Intended Use

Use this pack as the build contract for production implementation:
- define attendance business outcomes
- define overtime generation and approval behavior
- define access rules and privacy boundaries
- define views, actions, and configuration flows
- define integrations with HR, leave, work entry, and payroll flows

## Relationship to Feature Specs

The Gherkin feature specs in this folder remain the detailed scenario layer.
The files in this folder summarize the production architecture needed to build and ship the module safely.
