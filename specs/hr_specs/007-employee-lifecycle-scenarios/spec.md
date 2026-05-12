# Feature Specification: Employee Lifecycle and Scenario Management

**Feature Branch**: `007-employee-lifecycle-scenarios`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: User description: "Feature: Employee Lifecycle and Scenario Management\n  As an HR System\n  I want to manage employee lifecycle events and scenarios\n  So that employee workflows are handled correctly and consistently"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Guided onboarding for new employees (Priority: P1)

HR managers must see a supportive onboarding flow when creating new employees, with a congratulations message and quick access to onboarding setup wizard to streamline initial configuration.

**Why this priority**: Onboarding experience sets the tone for employee management and ensures no critical setup steps are skipped.

**Independent Test**: Create a new employee and verify congratulations message appears with onboarding wizard link; verify link navigates to onboarding setup.

**Acceptance Scenarios**:

1. **Given** a new employee is created, **When** the form displays, **Then** a congratulations message appears with a link to the onboarding wizard.
2. **Given** onboarding link is clicked, **When** the wizard opens, **Then** onboarding plan setup is initiated.

---

### User Story 2 - Demo and scenario data management (Priority: P2)

HR system must load demo scenario data (departments, employees, categories) on first install and recognize existing demo data to prevent duplicates.

**Why this priority**: Demo data accelerates testing and training workflows; duplicate prevention maintains data integrity.

**Independent Test**: Install HR app with no data; trigger load_demo_data and verify departments, employees, and categories created; run again and verify no duplicates.

**Acceptance Scenarios**:

1. **Given** HR app is freshly installed, **When** load_demo_data is triggered, **Then** demo scenario XML is converted and departments/employees/categories are created.
2. **Given** demo data already exists, **When** load_demo_data runs again, **Then** system recognizes existing data and no duplicates are created.

---

### User Story 3 - Role-based form views (Priority: P1)

HR system must provide different employee forms for HR users and non-HR (public) users, restricting visible fields in public view to protect privacy.

**Why this priority**: Different roles have different access needs; privacy and security require field-level access control.

**Independent Test**: Log in as HR user and non-HR user; access employee form and verify correct form is shown; check field visibility.

**Acceptance Scenarios**:

1. **Given** a non-HR user, **When** accessing employee form, **Then** public employee form (`hr.employee.public`) is shown with restricted fields.
2. **Given** an HR user, **When** accessing employee form, **Then** full `hr.employee` form is shown.

---

### User Story 4 - Auto-generated avatars for new employees (Priority: P2)

HR system must auto-generate SVG avatars for new employees without profile images and apply them to both employee and linked work contact for visual consistency.

**Why this priority**: Consistent avatars improve UI usability; auto-generation removes manual setup friction.

**Independent Test**: Create employee without image; verify SVG avatar is generated and applied to both employee and work contact; update with manual image and verify auto-generation stops.

**Acceptance Scenarios**:

1. **Given** a new employee without image and no linked user with image, **When** saved, **Then** SVG avatar is auto-generated based on employee name and applied to employee.
2. **Given** employee has work contact, **When** avatar is generated, **Then** same avatar is applied to work contact.
3. **Given** employee already has uploaded image, **When** saved, **Then** existing image is preserved and no new avatar generated.

---

### User Story 5 - Change tracking and modification history (Priority: P2)

HR system must automatically log all changes to tracked employee fields and provide accessible modification history showing who changed what and when.

**Why this priority**: Audit trail is required for compliance, dispute resolution, and management visibility.

**Independent Test**: Update tracked fields and verify log entries created; access modification history and confirm details (who, what, when).

**Acceptance Scenarios**:

1. **Given** an employee with tracked fields, **When** any tracked field is updated, **Then** a log entry is created with user, field, old value, new value, and timestamp.
2. **Given** modification history requested, **When** displayed, **Then** all changes are visible with full context.

---

### User Story 6 - Employee metadata and related contacts (Priority: P2)

HR system must compute and display employee metadata (birthday visibility, related contacts count) and provide quick access to related contacts (work contact, linked user partner).

**Why this priority**: Metadata and relationships improve employee management; quick navigation reduces clicks.

**Independent Test**: Set birthday and visibility flag; compute display string; access related contacts action and verify form/kanban display.

**Acceptance Scenarios**:

1. **Given** employee has birthday set with `birthday_public_display=True`, **When** computed, **Then** `birthday_public_display_string` shows "DD Month" format.
2. **Given** `birthday_public_display=False`, **When** computed, **Then** `birthday_public_display_string` shows "hidden".
3. **Given** employee with multiple related contacts (work contact, user partner), **When** action_related_contacts is called, **Then** kanban view shows all contacts; single contact opens form directly.

---

### User Story 7 - Employee filtering and lifecycle status (Priority: P2)

HR system must support searching for newly hired employees and maintain department channel subscriptions, subscribing new/moved employees to relevant channels.

**Why this priority**: Filtering supports HR reporting; channel subscriptions improve team communication.

**Independent Test**: Filter for `newly_hired=True` and verify correct employees returned; move employee between departments and verify channel subscriptions updated.

**Acceptance Scenarios**:

1. **Given** employees created at different times, **When** searching with `newly_hired=True`, **Then** only recently hired employees are returned.
2. **Given** employee moved to department with auto-subscribe channels, **When** saved, **Then** employee is auto-subscribed to those channels.

---

### Edge Cases

- New employee in draft mode: version fields should be accessible as new records without persisting until confirmed.
- Departure notification: message post with description must be created when employee archived.
- Version context: field access must respect version_id in context when searching/filtering.
- No related contacts: related_partners_count should be 0 when no work contact or user linked.
- Department without auto-subscribe channels: subscription logic should skip gracefully.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a congratulations message when a new employee is created.
- **FR-002**: System MUST provide a link to onboarding wizard in the congratulations message.
- **FR-003**: System MUST load demo scenario data (departments, employees, categories) when triggered and HR app has no data.
- **FR-004**: System MUST recognize existing demo data and prevent duplicate creation on subsequent load_demo_data calls.
- **FR-005**: System MUST return public employee form (`hr.employee.public`) with restricted fields for non-HR users.
- **FR-006**: System MUST return full employee form (`hr.employee`) with all fields for HR users.
- **FR-007**: System MUST auto-generate SVG avatar for new employees without images based on employee name.
- **FR-008**: System MUST apply auto-generated avatar to both employee and linked work contact.
- **FR-009**: System MUST preserve existing employee images and not generate new avatar if image already exists.
- **FR-010**: System MUST create audit log entries for all changes to tracked employee fields.
- **FR-011**: System MUST make modification history accessible with full context (who, what, when, old/new values).
- **FR-012**: System MUST post a message to employee timeline when departure description is entered during archival.
- **FR-013**: System MUST compute `related_partners_count` as the count of work contact and linked user partner.
- **FR-014**: System MUST open kanban/list view of related contacts when multiple exist.
- **FR-015**: System MUST open form view of single related contact directly when only one exists.
- **FR-016**: System MUST compute `birthday_public_display_string` as "DD Month" format when `birthday_public_display=True`.
- **FR-017**: System MUST compute `birthday_public_display_string` as "hidden" when `birthday_public_display=False`.
- **FR-018**: System MUST filter employees by `newly_hired=True` status based on creation date.
- **FR-019**: System MUST auto-subscribe employees to department channels when created in or moved to a department with auto-subscribe channels.
- **FR-020**: System MUST support version context in field access and search when version_id is provided in context.
- **FR-021**: System MUST handle new employees in draft mode with version fields accessible as new records.

### Key Entities *(include if feature involves data)*

- **hr.employee**: lifecycle fields include `active`, `created date`, `birthday`, `birthday_public_display`, `related_partners_count`, `version_id` (context); versioned access support.
- **department**: channels linked via `channel_ids` with auto-subscribe flag.
- **hr.version**: tracked field versions; accessible via context in employee queries.
- **mail.activity**: onboarding wizard link delivered via activity creation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Onboarding message displays in 100% of new employee creations.
- **SC-002**: Demo data loads correctly in 100% of fresh installs; no duplicates created in 100% of subsequent runs.
- **SC-003**: Form view access control works correctly in 100% of HR/non-HR user scenarios.
- **SC-004**: Auto-generated avatars are created in 100% of new employees without images and applied to both employee and work contact.
- **SC-005**: Audit log entries are created in 100% of tracked field updates with complete context.
- **SC-006**: Modification history is accessible and accurate in 100% of queries.
- **SC-007**: Department channel subscriptions occur in 100% of employee creation/move operations.
- **SC-008**: Newly hired filter returns correct employees based on creation date threshold in 100% of searches.
- **SC-009**: `birthday_public_display_string` computation is correct in 100% of cases.
- **SC-010**: Related contacts display and navigation work correctly in 100% of scenarios (0, 1, multiple).

## Assumptions

- Demo scenario data is stored in XML files and converted on load; duplicate detection uses department names/employee IDs.
- SVG avatar generation uses a deterministic algorithm based on employee name (e.g., initials + color hash).
- Auto-subscribe channels are marked on department records and subscribed via standard Odoo channel APIs.
- Newly hired threshold is configurable (e.g., last 30 days or 90 days) or uses system default.
- Modification history is populated via Odoo's built-in tracking mechanism (`_track_visibility`, `track_visibility`).
- Version context filtering assumes versions are ordered by date; context-aware access respects version date ranges.
- Birthday display is a user preference; defaults to hidden for privacy.
- Related contacts include work contact (res.partner) and linked user's partner_id; computation excludes null/false values.
