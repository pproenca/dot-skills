---
title: Separate Functional and Non-Functional Requirements
impact: CRITICAL
impactDescription: prevents 75% of late-stage NFR surprises
tags: req, functional, non-functional, nfr
---

## Separate Functional and Non-Functional Requirements

Functional requirements describe what the system does. Non-functional requirements describe how well it does it (performance, security, accessibility). Both are essential; non-functional requirements are often overlooked until too late.

**Incorrect (only functional requirements):**

```markdown
## Feature: File Upload

### Requirements
- User can upload files
- Files are stored in the system
- User can download uploaded files
- User can delete files

// No mention of: file size limits, upload speed, security,
// concurrent uploads, storage quotas, virus scanning
```

**Correct (functional + non-functional):**

```markdown
## Feature: File Upload

### Functional Requirements
- User can upload single or multiple files
- User can view list of uploaded files with metadata
- User can download files individually or as ZIP
- User can delete files they own
- Admin can delete any file

### Non-Functional Requirements

#### Performance
- Upload speed: Minimum 1MB/s on broadband
- Maximum file size: 100MB per file
- Concurrent uploads: Up to 5 files simultaneously
- Storage quota: 10GB per user (configurable)

#### Security
- Files scanned for malware before storage
- Direct URL access requires authentication token
- Files encrypted at rest (AES-256)
- Audit log of all file operations

#### Availability
- File service uptime: 99.9%
- Graceful degradation if storage is unavailable
- Upload resume capability for files >10MB

#### Accessibility
- Upload progress announced to screen readers
- Keyboard-accessible file picker
- Error messages include remediation steps
```

**Common NFR categories:**
- Performance (speed, throughput, latency)
- Security (authentication, encryption, audit)
- Scalability (users, data volume, growth)
- Availability (uptime, disaster recovery)
- Accessibility (WCAG compliance level)
- Compliance (GDPR, HIPAA, SOC2)

Reference: [Document360 - Technical Specification Document](https://document360.com/blog/technical-specification-document/)
