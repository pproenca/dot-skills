---
title: Separate Severity from Priority
impact: MEDIUM
impactDescription: enables correct resource allocation
tags: triage, severity, priority, classification
---

## Separate Severity from Priority

Severity measures technical impact (how broken). Priority measures business urgency (how soon to fix). A minor visual bug on a high-traffic landing page may be low severity but high priority. Keep these distinct for proper triage.

**Incorrect (conflating severity and priority):**

```markdown
## Bug Report: Typo in Terms of Service
Severity: LOW
Priority: LOW

Decision: Fix when convenient

## Bug Report: Crash on checkout for users with emojis in name
Severity: HIGH
Priority: HIGH

Decision: Fix immediately
```

**Correct (separate severity from priority):**

```markdown
## Bug Report: Typo in Terms of Service
Severity: LOW (cosmetic issue, no functional impact)
Priority: HIGH (legal team says must fix before audit next week)

Decision: Schedule for immediate sprint

## Bug Report: Crash on checkout for users with emojis in name
Severity: HIGH (complete feature failure)
Priority: LOW (affects 0.01% of users, workaround exists)

Decision: Schedule for next sprint, document workaround

## Severity/Priority Matrix:

|                | High Priority | Low Priority |
|----------------|--------------|--------------|
| High Severity  | Fix NOW      | Fix soon     |
| Low Severity   | Fix soon     | Backlog      |
```

**Classification guidelines:**
| Severity | Definition |
|----------|------------|
| CRITICAL | System down, data loss, security breach |
| HIGH | Major feature broken, no workaround |
| MEDIUM | Feature impaired, workaround exists |
| LOW | Cosmetic, minor inconvenience |

Reference: [Atlassian - Bug Triage](https://www.atlassian.com/agile/software-development/bug-triage)
