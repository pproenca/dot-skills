---
title: Obtain Stakeholder Sign-off on Scope
impact: CRITICAL
impactDescription: prevents scope disputes and rejected deliverables
tags: scope, signoff, alignment, stakeholders
---

## Obtain Stakeholder Sign-off on Scope

Require explicit stakeholder approval of scope before development begins. Verbal agreements lead to "I thought it would include X" disputes. Written sign-off creates accountability and shared understanding.

**Incorrect (verbal agreement):**

```markdown
## Feature: Reporting Dashboard

Status: Discussed in meeting, ready to start

Meeting notes:
- Bob wants sales reports
- Sarah mentioned export functionality
- Everyone seemed aligned

// 4 weeks later:
// Bob: "Where are the predictive analytics?"
// Sarah: "I assumed PDF export, not just CSV"
// Result: Scope dispute, delayed delivery
```

**Correct (documented sign-off):**

```markdown
## Feature: Reporting Dashboard

### Scope Agreement

**Version:** 1.0
**Date:** 2024-03-15

#### Included in This Release
- Sales report with date filtering
- Revenue breakdown by product category
- CSV export functionality
- Weekly email digest option

#### Explicitly Excluded
- Predictive analytics (Phase 2)
- PDF export (requires design work)
- Real-time updates (polling every 5 min instead)
- Custom report builder

#### Sign-off

| Stakeholder | Role | Date | Signature |
|-------------|------|------|-----------|
| Bob Smith | Sales Director | 2024-03-15 | ✓ Approved |
| Sarah Jones | Product Manager | 2024-03-15 | ✓ Approved |
| Dev Lead | Engineering | 2024-03-15 | ✓ Feasible |

#### Change Process
Any scope changes after sign-off require:
1. Written change request
2. Impact analysis (timeline, cost)
3. Re-approval from all signatories
```

**Sign-off process:**
1. Document scope in writing
2. Review with all stakeholders
3. Address questions and concerns
4. Obtain explicit approval (email, signature)
5. Archive approved document

Reference: [Adobe - What is Scope Creep](https://business.adobe.com/blog/basics/scope-creep)
