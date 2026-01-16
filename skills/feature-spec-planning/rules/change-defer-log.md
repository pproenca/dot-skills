---
title: Maintain a Deferred Items Log
impact: MEDIUM
impactDescription: captures 100% of good ideas for future consideration
tags: change, defer, backlog, tracking
---

## Maintain a Deferred Items Log

When you say "no" to a feature or change, capture it in a deferred items log. Good ideas that don't fit the current scope shouldn't be lost. A well-maintained log prevents re-litigation and provides a roadmap for future work.

**Incorrect (rejected ideas disappear):**

```markdown
## Meeting Notes

Discussed adding dark mode - decided not to include.
Discussed mobile app - too much scope.
Discussed SSO integration - deferred.

// 6 months later:
// "Why don't we have dark mode?"
// "We discussed this... when was that?"
// "What was the reason?"
// Result: Re-discuss from scratch, waste time
```

**Correct (structured deferred items log):**

```markdown
## Deferred Items Log - User Dashboard

### Purpose
This log captures features and changes that were considered but deferred
from the current release. Items here are not rejected—they're documented
for future consideration.

### How to Use This Log
1. Add items when descoping or rejecting features
2. Review during planning for future releases
3. Reference when stakeholders raise deferred items
4. Archive items after implementation or permanent rejection

---

### Active Deferred Items

#### DI-001: Dark Mode Support

| Field | Value |
|-------|-------|
| **Requested by** | Multiple users (Feature Request #234, #256, #289) |
| **Date deferred** | 2024-02-15 |
| **Original target** | v1.0 |
| **Deferred to** | v2.0 (tentative) |
| **Decision maker** | Product Director |

**Description:**
Add dark mode theme option to reduce eye strain and support
user preferences.

**Reason for deferral:**
Requires design system updates across all components. Estimated
3-week effort conflicts with Q1 launch deadline.

**Prerequisites for implementation:**
- Design system theme architecture
- Component audit for hardcoded colors
- Accessibility review for contrast ratios

**Estimated effort:** 3 weeks (1 designer, 2 developers)

**Business case:**
- 40% of users requested in feedback survey
- Competitive parity (competitors have it)
- Accessibility benefit

---

#### DI-002: Real-time Collaboration

| Field | Value |
|-------|-------|
| **Requested by** | Enterprise Customer Advisory Board |
| **Date deferred** | 2024-03-01 |
| **Original target** | v1.0 |
| **Deferred to** | v3.0+ (requires architecture change) |
| **Decision maker** | CTO |

**Description:**
Allow multiple users to view and edit dashboard simultaneously
with real-time cursor presence and live updates.

**Reason for deferral:**
Requires WebSocket infrastructure, conflict resolution system,
and presence service. Architectural complexity incompatible with
v1 timeline.

**Prerequisites for implementation:**
- WebSocket infrastructure
- Operational Transform or CRDT implementation
- Presence service
- Conflict resolution UX design

**Estimated effort:** 8-12 weeks (full team)

**Business case:**
- Top request from enterprise segment
- $500K ARR at risk without it
- Competitive differentiator

---

#### DI-003: SSO/SAML Integration

| Field | Value |
|-------|-------|
| **Requested by** | Sales (enterprise deals) |
| **Date deferred** | 2024-02-20 |
| **Original target** | v1.0 |
| **Deferred to** | v1.5 |
| **Decision maker** | Product Director |

**Description:**
Support enterprise single sign-on via SAML 2.0 and OIDC.

**Reason for deferral:**
Security review backlog - SSO requires 4-week security audit
that wouldn't complete before launch.

**Prerequisites for implementation:**
- Security team availability
- IdP test accounts (Okta, Azure AD, OneLogin)
- Enterprise customer beta testers

**Estimated effort:** 4 weeks (2 developers + security review)

**Business case:**
- Required for 80% of enterprise deals
- $200K pipeline blocked without it
- Standard enterprise expectation

---

### Deferred Items Summary

| ID | Item | Target | Effort | Business Value |
|----|------|--------|--------|----------------|
| DI-001 | Dark mode | v2.0 | 3w | Medium |
| DI-002 | Real-time collab | v3.0+ | 12w | High |
| DI-003 | SSO/SAML | v1.5 | 4w | High |
| DI-004 | Mobile app | v3.0+ | 16w | Medium |
| DI-005 | API webhooks | v2.0 | 2w | Medium |

### Recently Implemented (Archive)

| ID | Item | Implemented | Release |
|----|------|-------------|---------|
| DI-000 | CSV export | 2024-01-15 | v0.9 |

### Permanently Rejected

| ID | Item | Rejected | Reason |
|----|------|----------|--------|
| - | Blockchain integration | 2024-01-10 | No valid use case |
```

**Deferred log requirements:**
- Capture all descoped items
- Document reason for deferral
- Note prerequisites for future implementation
- Include business case for prioritization
- Review regularly during planning

Reference: [ProductPlan - Product Backlog Management](https://www.productplan.com/glossary/product-backlog/)
