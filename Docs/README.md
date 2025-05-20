# MyPath Guided Onboarding - Sprint 0 Deliverables

## Overview

This directory contains the deliverables for Sprint 0 of the MyPath Guided Onboarding feature. Sprint 0 focused on analyzing the existing codebase and planning for the implementation of the AI Assistant for guided onboarding.

## Deliverables

1. **refactor-plan.md**
   - Repository scan with all Swift files and their classifications
   - Current architecture structure
   - Open questions for the Product Owner and UX team

2. **onboarding-field-map.md**
   - Comprehensive mapping of all onboarding steps
   - Field IDs, data types, and validation rules for each step
   - Detailed documentation of selectable options and models

3. **openapi.yaml**
   - OpenAPI specification for the required AI endpoints
   - Detailed schemas for /ai/parse and /ai/commit endpoints
   - Request/response examples for common scenarios

4. **risk-checklist.md**
   - IAM roles and security considerations
   - Secret management recommendations
   - Rate limiting and token spend guards
   - Network security configuration
   - PII handling and log redaction plans

5. **gap-analysis.md** (Bonus)
   - Analysis of current vs. target architecture
   - Identification of required changes and their severity
   - Technical implementation requirements for new components
   - Risky areas and potential issues to address

## Next Steps (Sprint 1)

As outlined in the project brief, Sprint 1 will focus on implementing the `OnboardingStore` and migrating the card UI to use it. The deliverables from Sprint 0 will serve as the baseline specifications for that work.

Key tasks for Sprint 1:
1. Create the `OnboardingStore` as the centralized data store
2. Implement validation layer and change tracking
3. Modify existing views to use the new store
4. Begin implementing the AI integration components

## Note on File Format

The field map is provided in markdown format for version control, but it can be easily converted to Excel by copying the table content into a spreadsheet application.