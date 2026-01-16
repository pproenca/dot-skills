---
title: Use RICE Scoring for Data-Driven Prioritization
impact: HIGH
impactDescription: reduces priority disputes by 65%
tags: prio, rice, scoring, quantitative
---

## Use RICE Scoring for Data-Driven Prioritization

When you have multiple competing features, use RICE (Reach × Impact × Confidence ÷ Effort) to score them objectively. This removes gut-feel bias and creates defensible prioritization decisions.

**Incorrect (opinion-based prioritization):**

```markdown
## Feature Backlog

| Feature | Priority |
|---------|----------|
| Dark mode | High (CEO wants it) |
| Search improvement | Medium |
| Bulk export | Low |
| Performance optimization | Medium |

// Priorities based on who asked loudest
// No data to justify decisions
// Changes with every meeting
```

**Correct (RICE scoring):**

```markdown
## Feature Backlog - RICE Scoring

**Formula:** RICE = (Reach × Impact × Confidence) ÷ Effort

| Feature | Reach | Impact | Confidence | Effort | RICE Score |
|---------|-------|--------|------------|--------|------------|
| Search improvement | 5000 users/qtr | 2 (high) | 80% | 3 weeks | **2,667** |
| Performance optimization | 8000 users/qtr | 1 (medium) | 90% | 2 weeks | **3,600** |
| Bulk export | 500 users/qtr | 2 (high) | 70% | 1 week | **700** |
| Dark mode | 2000 users/qtr | 0.5 (low) | 100% | 2 weeks | **500** |

### Prioritized Roadmap
1. **Performance optimization** (RICE: 3,600) - Sprint 1
2. **Search improvement** (RICE: 2,667) - Sprint 2
3. **Bulk export** (RICE: 700) - Sprint 3
4. **Dark mode** (RICE: 500) - Backlog

### Scoring Definitions

**Reach:** Users affected per quarter
**Impact:** 3 = massive, 2 = high, 1 = medium, 0.5 = low, 0.25 = minimal
**Confidence:** Percentage certainty in estimates
**Effort:** Person-weeks required
```

**When to use RICE:**
- Multiple competing features
- Need to justify decisions to stakeholders
- Want to remove HiPPO (highest paid person's opinion) bias

Reference: [Fibery - RICE Prioritization Method](https://fibery.io/blog/product-management/rice/)
