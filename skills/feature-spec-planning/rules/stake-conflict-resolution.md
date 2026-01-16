---
title: Resolve Stakeholder Conflicts Explicitly
impact: MEDIUM-HIGH
impactDescription: prevents passive-aggressive scope battles
tags: stake, conflict, resolution, alignment
---

## Resolve Stakeholder Conflicts Explicitly

When stakeholders disagree on requirements, resolve conflicts explicitly with documented decisions. Unresolved conflicts lead to passive scope creep as each party pushes their agenda during implementation.

**Incorrect (avoiding conflict):**

```markdown
## Requirements Meeting Notes

Sales wants: Bulk discount feature
Finance wants: No bulk discounts (margin concerns)

Resolution: "We'll figure it out later"

// What actually happens:
// Sales tells developers to add bulk discounts
// Finance tells developers discounts need approval
// Developers build both, neither fully works
// Feature launches with confused logic
```

**Correct (explicit conflict resolution):**

```markdown
## Conflict Resolution: Bulk Discounts

### Conflicting Positions

**Sales (represented by Sarah):**
- Wants: Automatic bulk discounts (10+ units = 10% off)
- Rationale: Competitive pressure, customer requests
- Impact if not included: Lost deals worth ~$50K/quarter

**Finance (represented by Frank):**
- Wants: No automatic discounts without approval
- Rationale: Margin protection, pricing integrity
- Impact if not included: 15% margin erosion risk

### Options Considered

| Option | Sales Impact | Finance Impact | Effort |
|--------|-------------|----------------|--------|
| A: Auto discounts | ✓ Full | ✗ High risk | Low |
| B: No discounts | ✗ Lost deals | ✓ Protected | None |
| C: Tiered approval | Partial | Partial | Medium |

### Decision

**Selected: Option C - Tiered Approval System**
- < 10%: Sales can approve directly
- 10-20%: Manager approval required
- > 20%: Finance approval required

**Decision maker:** VP of Product (tie-breaker)
**Date:** 2024-03-15
**Documented in:** PRD v2.1

### Commitment
Both parties agree to support this decision and not re-litigate during development.

| Stakeholder | Acceptance |
|-------------|------------|
| Sarah (Sales) | ✓ Accepted |
| Frank (Finance) | ✓ Accepted |
```

**Conflict resolution escalation:**
1. Direct discussion between parties
2. Facilitated meeting with PM
3. Escalation to shared manager
4. Executive tie-breaker (last resort)

Reference: [Project Manager Academy - Managing Scope Creep](https://projectmanagementacademy.net/articles/managing-scope-creep/)
