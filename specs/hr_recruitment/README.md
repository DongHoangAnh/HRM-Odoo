# HR Recruitment Specifications (Gherkin/BDD Format)

This directory contains comprehensive Gherkin-based BDD specifications for the HR Recruitment module (`hr.applicant` model in `hr_recruitment` addon).

## Specification Files

### 1. [01_applicant_tracking.feature](01_applicant_tracking.feature)
**Purpose**: Applicant lifecycle management and recruitment workflow
- Create applicants from job applications
- Add contact information (email, phone, LinkedIn)
- Move applicants through recruitment stages
- Track stage transition time
- Make offers to qualified applicants
- Hire and archive applicants
- Refuse applicants with reasons
- Assign recruiters
- Schedule and track interviews
- Add multiple interviewers
- Set applicant priority
- Detect duplicate applications
- Manage kanban state (workflow status)
- Apply tags/categories
- Link to employees after hiring
- Track UTM source (where applicant came from)
- Manage attachments (CV, cover letter)

**Key Scenarios**: 38 scenarios for full recruitment workflow

### 2. [02_recruitment_operations.feature](02_recruitment_operations.feature)
**Purpose**: Recruitment job, stage, source, and talent pool operations
- Job defaults and address constraints
- Job counters and analytics
- Attachment and activity actions
- Recruitment scenario loading
- Stage defaults and warning visibility
- Recruitment source alias creation and cleanup
- Talent pool counting and membership actions
- Interviewer management

**Key Scenarios**: 18 scenarios for recruitment operations

### 3. [03_job_platforms_and_interviewers.feature](03_job_platforms_and_interviewers.feature)
**Purpose**: Recruitment job platform and interviewer synchronization
- Email normalization and uniqueness on job platforms
- Regex storage for applicant parsing
- Alias defaults for jobs
- Interviewer group synchronization
- Job activity and metrics actions
- Favorite job toggling

**Key Scenarios**: 14 scenarios for job platforms and interviewers

---

## Statistics

- **Total Specification Files**: 3
- **Total Scenarios**: 70
- **Coverage Areas**: Applicant creation, Stage management, Interview tracking, Hiring process, Job Configuration, Talent Pools, Recruitment Sources, Job Platforms, Interviewer Sync

## Module Overview

The `hr_applicant` module manages the recruitment and hiring process including:
- **Applicant Records**: Store candidate information
- **Job Positions**: Link applicants to specific job openings
- **Stages**: Track progress through recruitment pipeline
- **Interviews**: Schedule and track interviews
- **Offers**: Make salary and benefits offers
- **Hiring**: Convert applicants to employees
- **Source Tracking**: Know where candidates came from
- **Skill Matching**: Match applicant skills to job requirements (with hr_recruitment_skills)

## Key Features

### Applicant Information
- **Basic Info**: Name, email, phone, LinkedIn profile
- **Education**: Degree, field of study
- **Availability**: Start date
- **Contact**: Partner link for CRM integration
- **Skills**: Qualifications and requirements matching

### Recruitment Stages
- **New**: Initial application
- **Screening**: CV/Application review
- **Interview**: Interview rounds
- **Offer**: Salary negotiation
- **Hired**: Job accepted, ready to start
- **Refused**: Application rejected
- **Archived**: Old applications

### Applicant Status
- **ongoing**: Currently being processed
- **hired**: Job accepted, employee created
- **refused**: Application rejected
- **archived**: Hidden from active list

### Kanban State (Workflow Status)
- **normal**: In Progress
- **done**: Ready for Next Stage
- **waiting**: Waiting for candidate response
- **blocked**: Issue preventing progress

### Interview Management
- **Schedule Events**: Link calendar events
- **Multiple Interviews**: Track each round
- **Interviewers**: Add team members involved
- **Interview Notes**: Timeline of interactions

### Salary Tracking
- **Expected**: What candidate wants
- **Proposed**: What company offers
- **Extra Benefits**: Additional compensation (health, bonus, etc.)

### UTM Tracking
- **Source**: Where candidate came from (LinkedIn, website, referral)
- **Medium**: How they found us (email, social media, etc.)
- **Campaign**: Marketing campaign tracking

## Workflows

### Standard Recruitment
1. Applicant submits application
2. Recruiter reviews (Screening stage)
3. Schedule interview (Interview stage)
4. Make offer (Offer stage)
5. Candidate accepts
6. Create employee

### Interview Process
1. Schedule first round with internal team
2. Conduct interview, add notes
3. Add to second round or reject
4. Multiple interviewers can be involved

### Hiring Process
1. Make salary offer
2. Candidate accepts
3. Move to "Hired" stage
4. Create employee record
5. Link applicant to employee

## Related Files

- Model: `/odoo/addons/hr_recruitment/models/hr_applicant.py`
- Job Model: `/odoo/addons/hr_recruitment/models/hr_job.py`
- Stage Model: `/odoo/addons/hr_recruitment/models/hr_recruitment_stage.py`
- Views: `/odoo/addons/hr_recruitment/views/`
- Tests: `/odoo/addons/hr_recruitment/tests/`

## Integration Points

- **HR Employee**: Link to create employees
- **Calendar**: Schedule interviews
- **CRM**: Track applicants as opportunities
- **Attachments**: Store resumes and documents
- **Skills**: Match applicant skills (with hr_recruitment_skills)
- **UTM Tracking**: Integration with marketing

---

**Created**: 2025-01-15
**Format**: Gherkin/BDD
**Scope**: HR Recruitment Module (hr_recruitment.hr_applicant)
