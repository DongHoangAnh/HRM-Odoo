# Feature Specification: Notify Expiring Contracts and Work Permits

**Feature Branch**: `006-notify-expiring-contracts-permits`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Notify Expiring Contracts and Work Permits\n  As an HR System\n  I want to notify about expiring contracts and work permits\n  So that HR managers can take timely action before expiration"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automated expiration notifications via cron (Priority: P1)

HR system must automatically generate notification activities when contracts or work permits approach expiration, alerting responsible persons within the configured notice period.

**Why this priority**: Timely notifications prevent missed renewals, legal compliance failures, and unplanned workforce disruptions.

**Independent Test**: Set contract/permit expiration dates; configure notice periods at company level; run cron job and verify activities created at correct notice thresholds; verify no activities created outside window.

**Acceptance Scenarios**:

1. **Given** employee has contract ending on 2025-03-15 and company notice period is 30 days, **When** cron runs on 2025-02-13 (30 days before), **Then** activity is created with title including employee name and deadline = 2025-03-15.
2. **Given** employee has work_permit_expiration_date set, **When** cron runs within notice period, **Then** activity is created mentioning permit expiration.
3. **Given** contract ends 2025-04-20 and today is 2025-02-13 (>30 days away), **When** cron runs, **Then** no activity created.

---

### User Story 2 - Multi-company notice periods (Priority: P1)

HR system must respect company-specific notice periods and evaluate expiration dates independently for each company.

**Why this priority**: Large organizations have different policies per company/region; incorrect timing risks compliance failures.

**Independent Test**: Configure different notice periods (30 days, 60 days) for multiple companies; set expiration dates; run cron and verify each company's threshold is honored.

**Acceptance Scenarios**:

1. **Given** Company A has 30-day notice period and Company B has 60-day period, **When** both have employees expiring on the same date, **Then** Company B's activity is created earlier (60 days before) while Company A's is created at 30 days.

---

### User Story 3 - Activity assignment and notification routing (Priority: P1)

HR system must assign expiration activities to the appropriate HR responsible person or fallback to current user, ensuring notification reaches decision-maker.

**Why this priority**: Notifications must reach the right person to ensure timely action.

**Independent Test**: Set `hr_responsible_id` on employee; create expiration activity and verify assignment; test fallback when no responsible person set.

**Acceptance Scenarios**:

1. **Given** employee has `hr_responsible_id` set, **When** expiration activity created, **Then** activity is assigned to that person.
2. **Given** employee has no `hr_responsible_id`, **When** expiration activity created, **Then** activity is assigned to current user.

---

### User Story 4 - Prevent duplicate activities and handle permanent contracts (Priority: P2)

HR system must not create duplicate notification activities for the same expiration event and must skip permanent contracts with no end date.

**Why this priority**: Duplicate activities clutter workflows; permanent contracts have no expiration to notify about.

**Independent Test**: Run cron multiple times for same employee; verify only one activity created; test permanent contracts (end = False) are not notified.

**Acceptance Scenarios**:

1. **Given** activity already exists for employee's expiring contract, **When** cron runs again, **Then** no duplicate activity created.
2. **Given** employee has permanent contract (contract_date_end = False), **When** cron runs, **Then** no expiration activity created.

---

### User Story 5 - Handle independent contract and permit notifications (Priority: P2)

HR system must create separate activities for contract and work permit expirations, supporting employees with only one, the other, or both.

**Why this priority**: Contracts and permits have independent renewal workflows; both must be tracked separately.

**Independent Test**: Create employee with only contract, only permit, and both; set expiration dates; run cron and verify correct number of activities.

**Acceptance Scenarios**:

1. **Given** employee has contract but no work permit, **When** contract expires, **Then** only contract activity created.
2. **Given** employee has both contract and permit expiring within notice period, **When** cron runs, **Then** two separate activities created, one for each.

---

### Edge Cases

- Expired contracts (end date in past): no activity created.
- Contract with no start date but future end date: system should validate and skip if start date missing.
- Multiple employees in single batch: all receive activities without race conditions.
- Company without notice period configured: use system default or skip.
- Work permit exists but no contract: permit expiration still notified independently.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST run a scheduled cron job to identify contracts expiring within company `contract_expiration_notice_period`.
- **FR-002**: System MUST run a scheduled cron job to identify work permits expiring within company `work_permit_expiration_notice_period`.
- **FR-003**: System MUST create a mail activity for each employee with expiring contract, using activity type `mail.mail_activity_data_todo`.
- **FR-004**: System MUST create a mail activity for each employee with expiring work permit, using activity type `mail.mail_activity_data_todo`.
- **FR-005**: System MUST set activity title to include employee name, e.g., "The contract of [Employee Name] is about to expire".
- **FR-006**: System MUST set activity title for work permit as "The work permit of [Employee Name] is about to expire".
- **FR-007**: System MUST set activity deadline to the expiration date (contract_date_end or work_permit_expiration_date).
- **FR-008**: System MUST assign activity to `hr_responsible_id` if set; otherwise assign to current/default user.
- **FR-009**: System MUST NOT create activities for contracts already expired (end date < today).
- **FR-010**: System MUST NOT create activities for work permits already expired.
- **FR-011**: System MUST NOT create duplicate activities for the same employee and expiration event.
- **FR-012**: System MUST skip permanent contracts (contract_date_end = False).
- **FR-013**: System MUST handle employees with both contract and work permit expiring independently, creating two activities when both are within notice periods.
- **FR-014**: System MUST respect company-specific notice periods; use `contract_expiration_notice_period` and `work_permit_expiration_notice_period` from the company.
- **FR-015**: System MUST skip contracts with no defined `contract_date_end` (contract not yet finalized).
- **FR-016**: System MUST use `mail_activity_quick_update` context when creating activities.

### Key Entities *(include if feature involves data)*

- **hr.employee**: attributes include `contract_date_end`, `work_permit_expiration_date`, `hr_responsible_id`.
- **company**: attributes include `contract_expiration_notice_period` (integer, days), `work_permit_expiration_notice_period` (integer, days).
- **mail.activity**: created for each expiration notification; linked to employee record.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Cron job completes in under 30 seconds for companies with 1000+ employees.
- **SC-002**: Contract expiration activities created in 100% of cases within correct notice period.
- **SC-003**: Work permit expiration activities created in 100% of cases within correct notice period.
- **SC-004**: Duplicate activity detection succeeds in 100% of repeated cron executions.
- **SC-005**: Activity assignment to correct `hr_responsible_id` succeeds in 100% of cases.
- **SC-006**: Permanent contracts (end = False) are skipped in 100% of cron runs.
- **SC-007**: Company-specific notice periods are respected in 100% of multi-company scenarios.
- **SC-008**: Independent contract and permit notifications create correct number of activities (1 or 2) in 100% of cases.
- **SC-009**: Expired contracts (end date < today) do not generate activities in 100% of cases.

## Assumptions

- Cron job is scheduled to run once daily (frequency configurable via settings).
- Notice periods are configured per company in working/calendar days.
- `hr_responsible_id` points to a valid user record; system handles missing/deleted users gracefully.
- Mail activities use standard Odoo mail activity type `mail.mail_activity_data_todo`.
- Duplicate detection compares employee + expiration date + type (contract vs. permit); no activity created if match exists.
- Company configuration includes default notice periods; missing values are treated as no notification for that type.
- Permanent contracts use `contract_date_end = False` or `contract_date_end = None`; both are treated as indefinite.
