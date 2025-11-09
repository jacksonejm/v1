# MyPath AI Integration Risk Checklist

This document outlines important security and operational considerations for the Guided Onboarding AI feature. It covers Cloud Run deployment, IAM roles, API key management, rate limiting, logging, and compliance.

## 1. Identity and Access Management (IAM)

### Cloud Run Baseline IAM Roles

| Role | Purpose | Risk Level | Recommendation |
|------|---------|------------|----------------|
| `roles/run.invoker` | Allows invoking Cloud Run services | Medium | Restrict to API Gateway service account only |
| `roles/logging.logWriter` | Allows writing logs | Low | Required for logging service activities |
| `roles/monitoring.metricWriter` | Allows writing monitoring metrics | Low | Required for operational monitoring |
| `roles/secretmanager.secretAccessor` | Allows accessing secrets | High | Restrict to minimum required secrets, use key rotation |

### Service-to-Service Authentication

- ✅ Use service accounts with limited scope for each service
- ✅ Implement short-lived tokens for service-to-service communication
- ✅ Rotate service account keys automatically every 90 days
- ✅ Implement JWT verification for backend-to-backend communication

## 2. Secret Management

### API Keys and Credentials

| Secret | Storage | Rotation Frequency | Access Control |
|--------|---------|-------------------|----------------|
| OpenAI API Keys | Secret Manager | 90 days | Cloud Run service account only |
| Database Credentials | Secret Manager | 90 days | Database service account only |
| JWT Signing Keys | Secret Manager | 180 days | Authentication service only |

### Best Practices

- ✅ Never store secrets in code or environment variables
- ✅ Use Secret Manager for all sensitive credentials
- ✅ Implement automated secret rotation
- ✅ Audit secret access regularly
- ✅ Implement strict VPC Service Controls for secret access

## 3. Rate Limiting and Quotas

### API Rate Limits

| Endpoint | Rate Limit | Burst Limit | Per |
|----------|------------|-------------|-----|
| `/ai/parse` | 20 | 30 | User per minute |
| `/ai/commit` | 10 | 15 | User per minute |
| All endpoints | 1000 | 1500 | IP per hour |

### Token Spend Guards

- ✅ Implement token counting for all AI API calls
- ✅ Set hard limits on tokens per user session (max 10,000 tokens)
- ✅ Implement automatic shutdown if token usage exceeds 120% of projected daily budget
- ✅ Daily and monthly spend caps with alerting at 80% threshold
- ✅ Implement circuit breakers if costs exceed thresholds
- ✅ Track usage patterns to detect anomalies that might indicate abuse

## 4. Network Security

### IP Allow-list Configuration

- ✅ Restrict API access to known IP ranges for administrative functions
- ✅ Implement geo-fencing for initial release (US and Canada only)
- ✅ Rate limit by IP address to prevent distributed attacks
- ✅ Implement Web Application Firewall (WAF) rules to protect against common attacks

### Traffic Management

- ✅ All traffic must be HTTPS (TLS 1.2+)
- ✅ Implement proper CORS policies
- ✅ Use Cloud Armor for DDoS protection
- ✅ Implement network segregation between services

## 5. Data Protection and Privacy

### PII Handling

- ✅ Implement PII detection for all user inputs
- ✅ Redact PII from logs using Cloud DLP
- ✅ Encrypt all PII data at rest and in transit
- ✅ Implement data minimization principles - only collect what's needed
- ✅ Clear data retention policies (90 days for conversation data)

### Log PII Redaction Plan

1. Implement Cloud DLP integration for all logs
2. Define info types to be redacted: names, emails, phone numbers, addresses
3. Use tokenization for necessary correlation without exposing actual data
4. Regular audit of logs to ensure PII is not being inadvertently captured
5. Implement automated alerting for potential PII leakage

## 6. AI Safeguards

### AI Content Moderation

- ✅ Implement content filtering for all user inputs
- ✅ Build guardrails for AI responses to prevent harmful content
- ✅ Maintain human review process for flagged interactions
- ✅ Implement jailbreak detection for prompt injection attempts
- ✅ Regular audits of AI interactions to ensure proper functioning

### Trust & Safety

- ✅ Clear explanation to users about AI usage
- ✅ Provide opt-out mechanisms
- ✅ Implement feedback mechanisms for problematic AI responses
- ✅ Regular review of interaction patterns to identify potential misuse
- ✅ Transparency about data usage and storage

## 7. Operational Monitoring

### Alerting

- ✅ Set up alerts for abnormal API usage patterns
- ✅ Monitor error rates and latency with automated alerting
- ✅ Implement user feedback monitoring for AI quality issues
- ✅ Set up cost threshold alerts for AI API usage

### Auditing

- ✅ Regular audit of access logs
- ✅ Periodic penetration testing (quarterly)
- ✅ Regular review of IAM permissions for least privilege
- ✅ Compliance reviews for data handling practices

## 8. Incident Response

### Response Plan

1. Clearly defined severity levels for different types of incidents
2. Designated incident commander roles
3. Communication templates for different stakeholders
4. Runbooks for common incident types
5. Post-mortem and lessons learned process

### Emergency Controls

- ✅ Ability to disable AI features completely if critical issues arise
- ✅ Manual override capabilities for administrators
- ✅ Backup and restore procedures with regular testing
- ✅ Fallback to non-AI processes if necessary

## 9. Compliance Considerations

- COPPA compliance for educational app with potential minor users
- GDPR considerations for potential EU expansion
- CCPA compliance for California users
- Educational data protection (FERPA) considerations
- Regular privacy impact assessments

## 10. Documentation and Training

- ✅ Comprehensive documentation of all security controls
- ✅ Regular security training for development team
- ✅ Documented incident response procedures
- ✅ User-facing documentation about data usage and privacy practices