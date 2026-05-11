# HR Work Entry Production Spec Pack

This folder contains the production-ready specification set for the HR Work Entry module, organized into 5 layers.

## Layers

1. [Business](01_business_spec.md)
2. [Data](02_data_spec.md)
3. [Security](03_security_spec.md)
4. [UI](04_ui_spec.md)
5. [Integration](05_integration_spec.md)

## Scope

This pack covers:
- hr.work.entry
- hr.work.entry.type
- hr.version work-entry generation behavior
- hr.employee work-entry generation behavior
- resource.calendar and attendance/leave generation helpers
- work-entry regeneration flows
- work-entry source configuration

## Intended Use

Use this pack as the build contract for production implementation:
- define work-entry business outcomes
- define generation and validation behavior
- define access rules and privacy boundaries
- define views, actions, and configuration flows
- define integrations with attendance, leave, and contract/version logic

Note: Payroll-specific specs are in the separate `hr_payroll` module.
