---
title: Version All Specification Documents
impact: MEDIUM
impactDescription: eliminates 95% of "which version is current" confusion
tags: change, versioning, documents, tracking
---

## Version All Specification Documents

Maintain version history for all specification documents. Without versioning, teams work from outdated specs, stakeholders reference different versions, and decisions lack audit trails.

**Incorrect (unversioned documents):**

```markdown
## PRD: User Dashboard

Last updated: March 2024

// Problems:
// - Which "March 2024" version?
// - What changed from last version?
// - Who approved changes?
// - Designer has v1, developer has v3
// Result: Features built to wrong spec
```

**Correct (versioned with change history):**

```markdown
## PRD: User Dashboard

| Version | Date | Author | Status |
|---------|------|--------|--------|
| 3.1 | 2024-03-20 | Carol Davis | **Current** |
| 3.0 | 2024-03-15 | Carol Davis | Superseded |
| 2.0 | 2024-02-28 | Carol Davis | Superseded |
| 1.0 | 2024-02-01 | Carol Davis | Superseded |

### Version History

#### v3.1 (2024-03-20) - Minor Update
**Approved by:** Engineering Lead
**Changes:**
- Clarified widget refresh behavior (CR-045)
- Fixed typo in acceptance criteria
- No scope change

#### v3.0 (2024-03-15) - Scope Change
**Approved by:** Product Director
**Changes:**
- Added: Excel export capability (CR-042)
- Removed: Real-time collaboration (deferred to v2)
- Modified: Dashboard layout (3 columns → 2 columns)

**Rationale:** Excel export required for enterprise deals. Real-time
collaboration descoped to meet deadline.

#### v2.0 (2024-02-28) - Requirements Refinement
**Approved by:** Product Director
**Changes:**
- Added: Performance requirements (p95 < 1s)
- Added: Accessibility requirements (WCAG 2.1 AA)
- Modified: Widget types expanded from 3 to 5

#### v1.0 (2024-02-01) - Initial Version
**Approved by:** Product Director
**Changes:**
- Initial PRD created from discovery research

---

### Document Control

**Canonical Location:** `https://docs.company.com/prd/user-dashboard`
**Source of Truth:** This document (not Slack, email, or verbal)

**Version Numbering:**
- Major (X.0): Scope changes
- Minor (X.Y): Clarifications, no scope impact

**Review Required For:**
- Any scope change: Product Director
- Technical changes: Engineering Lead
- Timeline changes: Project Manager

### Change Tracking Table

| Section | v2.0 | v3.0 | v3.1 |
|---------|------|------|------|
| 1. Overview | No change | No change | No change |
| 2. User Stories | Added US-5,6 | No change | No change |
| 3. Requirements | +Performance | -Real-time | No change |
| 4. Acceptance | Updated | +Excel export | Clarified |
| 5. Technical | No change | Updated | No change |

### Stakeholder Notification

When a new version is published:
1. Email sent to all stakeholders
2. Slack notification in #proj-dashboard
3. Meeting scheduled if scope changes
4. Acknowledgment required from leads

```yaml
# Notification Template
subject: "[Dashboard PRD] v3.1 Published"
to: stakeholder-list
body: |
  PRD v3.1 has been published.

  ## Summary of Changes
  - Clarified widget refresh behavior
  - No scope or timeline impact

  ## Action Required
  - Review changes by EOD Friday
  - Reply to confirm receipt

  ## Document Link
  https://docs.company.com/prd/user-dashboard
```
```

**Document versioning requirements:**
- Every spec document has version number
- Change history with dates and authors
- Approval recorded for each version
- Stakeholders notified of updates
- Single canonical location (no copies)

Reference: [IEEE 830-1998 - Software Requirements Specifications](https://ieeexplore.ieee.org/document/720574)
