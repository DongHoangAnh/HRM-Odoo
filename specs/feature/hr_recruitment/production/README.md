# HR Recruitment Production Spec Pack

This folder contains the production-ready specification set for the HR Recruitment module, organized into 5 layers.

## Layers

1. [Business](01_business_spec.md)
2. [Data](02_data_spec.md)
3. [Security](03_security_spec.md)
4. [UI](04_ui_spec.md)
5. [Integration](05_integration_spec.md)

## Scope

This pack covers:
- hr.applicant
- hr.job
- hr.recruitment.stage
- hr.recruitment.source
- hr.applicant.category
- hr.applicant.refuse.reason
- hr.talent.pool
- hr.job.platform
- recruitment-related res.users behavior
- recruitment-related hr.department behavior
- recruitment-related calendar and attachment behavior

## Intended Use

Use this pack as the build contract for production implementation:
- define recruitment business outcomes
- define applicant/job/talent-source data behavior
- define access rules and privacy boundaries
- define views, actions, and management flows
- define integrations with employee creation, calendar, mail alias, and job pipelines

## Relationship to Feature Specs

The Gherkin feature specs in this folder remain the detailed scenario layer.
The files in this folder summarize the production architecture needed to build and ship the module safely.
