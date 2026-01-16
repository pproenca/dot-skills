---
title: Define Explicit In-Scope and Out-of-Scope Boundaries
impact: CRITICAL
impactDescription: prevents 40% of project failures from scope creep
tags: scope, boundaries, scope-creep, planning
---

## Define Explicit In-Scope and Out-of-Scope Boundaries

Explicitly state what the feature will and will not do. Ambiguous boundaries lead to scope creep, where stakeholders assume capabilities that were never planned, causing timeline and budget overruns.

**Incorrect (implicit boundaries):**

```markdown
## Feature: User Authentication

### Description
Users should be able to log in to the application securely.

### Requirements
- Login form with email and password
- Session management
- Password reset functionality
```

**Correct (explicit boundaries):**

```markdown
## Feature: User Authentication

### In Scope
- Email/password login form
- Session management with 24-hour expiry
- Password reset via email link
- Failed login attempt limiting (5 attempts)

### Out of Scope (Future Phases)
- Social login (Google, GitHub) - Phase 2
- Two-factor authentication - Phase 2
- Single sign-on (SSO) - Enterprise tier
- Biometric authentication - Mobile app only

### Explicitly Excluded
- Username-based login (email only)
- "Remember me" functionality (security policy)
```

**Benefits:**
- Stakeholders know exactly what to expect
- Developers can push back on creep with documented boundaries
- Future phases are acknowledged but deferred

Reference: [Asana - What is Scope Creep](https://asana.com/resources/what-is-scope-creep)
