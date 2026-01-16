---
title: Create Work Breakdown Structure for Complex Features
impact: CRITICAL
impactDescription: reduces estimation error by 50%
tags: scope, wbs, decomposition, estimation
---

## Create Work Breakdown Structure for Complex Features

Break large features into smaller, estimable work items using a Work Breakdown Structure (WBS). Large, monolithic features hide complexity and lead to underestimation. Decomposition reveals true scope.

**Incorrect (monolithic feature):**

```markdown
## Feature: User Dashboard

### Description
Build a dashboard showing user analytics and activity.

### Estimate
2 sprints (rough guess)

// Hidden complexity: API design, caching, charts, permissions, mobile
// Actual delivery: 5 sprints
```

**Correct (decomposed work breakdown):**

```markdown
## Feature: User Dashboard

### Work Breakdown Structure

1. **Data Layer** (Sprint 1)
   - 1.1 Define dashboard data models (2 pts)
   - 1.2 Create aggregation queries (3 pts)
   - 1.3 Implement caching layer (3 pts)
   - 1.4 Build REST API endpoints (5 pts)

2. **Visualization Components** (Sprint 2)
   - 2.1 Activity timeline component (3 pts)
   - 2.2 Analytics charts (bar, line, pie) (5 pts)
   - 2.3 Summary cards with KPIs (2 pts)
   - 2.4 Date range picker (2 pts)

3. **Dashboard Assembly** (Sprint 3)
   - 3.1 Layout and grid system (3 pts)
   - 3.2 Widget drag-and-drop (5 pts)
   - 3.3 Responsive design (3 pts)
   - 3.4 Loading states and skeletons (2 pts)

4. **Integration & Polish** (Sprint 4)
   - 4.1 Permission-based widget visibility (3 pts)
   - 4.2 Export to PDF/CSV (3 pts)
   - 4.3 Performance optimization (2 pts)
   - 4.4 E2E testing (3 pts)

### Total: 49 story points across 4 sprints
```

**WBS principles:**
- Each item should be independently estimable
- Aim for items under 8 story points
- Reveal dependencies between items
- Enable parallel work streams

Reference: [Planio - 7 Steps to Deal With Scope Creep](https://plan.io/blog/scope-creep/)
