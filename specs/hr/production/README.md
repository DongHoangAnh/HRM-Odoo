# HR Production Spec Pack

This folder contains the production-ready specification set for the HR module, organized into 5 layers.

## Layers

1. [Business](01_business_spec.md)
2. [Data](02_data_spec.md)
3. [Security](03_security_spec.md)
4. [UI](04_ui_spec.md)
5. [Integration](05_integration_spec.md)

## Scope

This pack covers the core HR module and its main related objects:
- hr.employee
- hr.version
- hr.department
- hr.employee.public
- hr.work.location
- hr.employee.category
- res.users HR sync behavior
- res.partner and res.partner.bank HR extensions
- hr.departure.reason
- hr.contract.type
- hr.payroll.structure.type

## Intended Use

Use this pack as the build contract for production implementation:
- define the business outcomes
- define the data model and constraints
- define access rules and privacy boundaries
- define views, actions, and wizards
- define cross-module contracts and event flows

## Relationship to Feature Specs

The existing Gherkin feature specs in this module remain the detailed scenario layer.
The files in this folder summarize the production architecture needed to build and ship the module safely.
