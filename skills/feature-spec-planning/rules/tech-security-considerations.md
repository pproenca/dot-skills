---
title: Document Security Considerations
impact: MEDIUM
impactDescription: prevents 90% of security review surprises
tags: tech, security, authentication, authorization
---

## Document Security Considerations

Identify security requirements and threats during planning, not during security review. Late-stage security findings cause significant rework. Every feature that handles data needs security analysis.

**Incorrect (security as afterthought):**

```markdown
## Feature: File Sharing

Users can share files with other users.

// Security review (week before launch):
// - "How do you prevent unauthorized access?"
// - "What about malicious file uploads?"
// - "Is there rate limiting?"
// Result: 3-week delay for security hardening
```

**Correct (security designed in):**

```markdown
## Feature: File Sharing - Security Specification

### Threat Model

**Assets to protect:**
- User files (confidentiality, integrity)
- User metadata (privacy)
- System resources (availability)

**Threat actors:**
| Actor | Motivation | Capability |
|-------|------------|------------|
| Malicious user | Data theft, abuse | Account access |
| External attacker | Data breach | Network access |
| Insider threat | Data exfiltration | System access |

### Attack Surface Analysis

| Attack Vector | Threat | Mitigation |
|---------------|--------|------------|
| Unauthorized file access | IDOR (Insecure Direct Object Reference) | Access control checks on every request |
| Malicious file upload | Malware distribution | File scanning, type validation |
| Path traversal | Server file access | Sanitize filenames, use UUIDs |
| Denial of service | Resource exhaustion | Rate limiting, file size limits |
| Share link enumeration | Unauthorized access | Cryptographic random tokens |

### Authentication & Authorization

**Authentication:**
- Required for: Upload, delete, manage shares
- Optional for: Access via share link (if public)
- Method: JWT with 15-minute expiry + refresh token

**Authorization Matrix:**

| Action | Owner | Shared User (Edit) | Shared User (View) | Public Link | Anonymous |
|--------|-------|-------------------|-------------------|-------------|-----------|
| View file | ✓ | ✓ | ✓ | ✓ | ✗ |
| Download | ✓ | ✓ | ✓ | Configurable | ✗ |
| Edit/Replace | ✓ | ✓ | ✗ | ✗ | ✗ |
| Delete | ✓ | ✗ | ✗ | ✗ | ✗ |
| Manage shares | ✓ | ✗ | ✗ | ✗ | ✗ |
| View share link | ✓ | ✓ | ✗ | N/A | ✗ |

**Implementation:**
```python
def check_file_access(user_id: str, file_id: str, action: str) -> bool:
    file = get_file(file_id)  # Raises 404 if not found

    # Owner has all permissions
    if file.owner_id == user_id:
        return True

    # Check share permissions
    share = get_share(file_id, user_id)
    if share and action in share.allowed_actions:
        return True

    # No access - return same error as "not found" to prevent enumeration
    raise NotFoundError("File not found")
```

### Input Validation

**File upload validation:**
```yaml
filename:
  max_length: 255
  allowed_chars: alphanumeric, dash, underscore, dot
  sanitization: strip path components, normalize unicode

file_content:
  max_size: 100MB
  allowed_types:
    - image/jpeg
    - image/png
    - application/pdf
    - text/plain
  validation: file signature check, not just extension

share_link_token:
  format: base64url
  length: 32 bytes (256 bits entropy)
  generation: cryptographically secure random
```

### Rate Limiting

| Endpoint | Limit | Window | Response |
|----------|-------|--------|----------|
| POST /files (upload) | 10 | 1 minute | 429 + Retry-After |
| GET /files/:id | 100 | 1 minute | 429 + Retry-After |
| POST /shares | 20 | 1 minute | 429 + Retry-After |
| GET /shares/:token | 50 | 1 minute | 429 + Retry-After |

### Data Protection

**At rest:**
- Files encrypted with AES-256-GCM
- Keys stored in AWS KMS
- Separate key per customer (enterprise)

**In transit:**
- TLS 1.3 required
- HSTS enabled
- Certificate pinning for mobile apps

**Retention:**
- Deleted files: Soft delete for 30 days
- Permanent delete: Overwrite + crypto erase
- Audit logs: 1 year retention

### Audit Logging

All security-relevant events logged:
```json
{
  "timestamp": "2024-03-15T10:30:00Z",
  "event": "file.accessed",
  "actor": {"type": "user", "id": "user_123"},
  "resource": {"type": "file", "id": "file_456"},
  "action": "download",
  "context": {
    "ip": "192.168.1.1",
    "user_agent": "Mozilla/5.0...",
    "share_token": "abc123"
  },
  "result": "success"
}
```
```

**Security checklist:**
- Threat model documented
- Authorization matrix defined
- Input validation specified
- Rate limits set
- Encryption requirements clear
- Audit logging planned

Reference: [OWASP Application Security Verification Standard](https://owasp.org/www-project-application-security-verification-standard/)
