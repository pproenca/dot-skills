---
title: Use MoSCoW Method for Scope Prioritization
impact: HIGH
impactDescription: reduces scope disputes by 70%
tags: prio, moscow, prioritization, scope
---

## Use MoSCoW Method for Scope Prioritization

Categorize requirements into Must have, Should have, Could have, and Won't have. This framework forces explicit prioritization decisions and creates clear expectations about what's essential versus optional.

**Incorrect (flat priority list):**

```markdown
## Feature Requirements

1. User login
2. User registration
3. Social login
4. Two-factor authentication
5. Password reset
6. Remember me
7. Session timeout
8. Biometric login

// All items appear equal priority
// Team debates endlessly about what to build first
// Stakeholders expect everything in v1
```

**Correct (MoSCoW prioritization):**

```markdown
## Feature Requirements - MoSCoW Prioritization

### Must Have (Required for launch)
- User login with email/password
- User registration
- Password reset via email
- Session timeout after 24h inactivity

_Rationale: Core authentication required for any user access_

### Should Have (Important, not critical)
- Remember me functionality
- Account lockout after failed attempts
- Login activity notifications

_Rationale: Security and convenience features expected by users_

### Could Have (Nice to have if time permits)
- Social login (Google, GitHub)
- Two-factor authentication
- Login location tracking

_Rationale: Valuable but not blocking; can be added post-launch_

### Won't Have (This release)
- Biometric login (mobile-only feature)
- Single sign-on (enterprise tier)
- Passwordless email links

_Rationale: Requires additional infrastructure; scheduled for Q3_
```

**MoSCoW decision criteria:**
- **Must**: System doesn't work without it
- **Should**: Significant value but workarounds exist
- **Could**: Nice to have; users won't complain if missing
- **Won't**: Explicitly deferred (not forgotten)

Reference: [Aha! - PRD Templates](https://www.aha.io/roadmapping/guide/requirements-management/what-is-a-good-product-requirements-document-template)
