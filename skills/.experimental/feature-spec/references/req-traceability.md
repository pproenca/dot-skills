---
title: Maintain Requirements Traceability
impact: CRITICAL
impactDescription: catches 95% of missing requirements before launch
tags: req, traceability, verification, coverage
---

## Maintain Requirements Traceability

Track each requirement from origin through implementation to testing. Traceability ensures no requirement is forgotten, enables impact analysis for changes, and proves compliance for audits.

**Incorrect (disconnected artifacts):**

```markdown
## Somewhere in Confluence:
REQ-001: User authentication

## Somewhere in Jira:
FEAT-123: Login page
BUG-456: Password reset broken

## Somewhere in GitHub:
PR #789: Add auth middleware

// No way to verify:
// - Is REQ-001 fully implemented?
// - What tests cover REQ-001?
// - What code implements REQ-001?
```

**Correct (traceability matrix):**

```markdown
## Requirements Traceability Matrix

| Req ID | Requirement | User Stories | Code | Tests | Status |
|--------|-------------|--------------|------|-------|--------|
| REQ-001 | User can log in with email/password | US-101, US-102 | auth/login.ts | login.spec.ts | ✓ Done |
| REQ-002 | User can reset password via email | US-103 | auth/reset.ts | reset.spec.ts | ✓ Done |
| REQ-003 | Session expires after 24h inactivity | US-104 | auth/session.ts | session.spec.ts | In Progress |
| REQ-004 | Failed login locks account after 5 attempts | US-105 | - | - | Not Started |

---

## Detailed Trace: REQ-001

**Requirement:** User can log in with email/password

**Business Need:** Security team mandate, Compliance SOC2

**User Stories:**
- US-101: Basic login flow
- US-102: Login error handling

**Implementation:**
- `src/auth/login.ts` - Login logic
- `src/auth/middleware.ts` - Session validation
- `src/components/LoginForm.tsx` - UI component

**Tests:**
- `login.spec.ts` - Unit tests
- `auth.e2e.ts` - E2E login flow
- `security.test.ts` - Penetration test cases

**Verification:** QA sign-off 2024-03-15
```

**Traceability benefits:**
- Impact analysis: "If REQ-003 changes, what's affected?"
- Coverage verification: "Are all requirements tested?"
- Audit compliance: "Prove REQ-001 is implemented"
- Progress tracking: "What percentage complete?"

Reference: [Aha! - Requirements Management](https://www.aha.io/roadmapping/guide/requirements-management/what-is-a-prd-(product-requirements-document))
