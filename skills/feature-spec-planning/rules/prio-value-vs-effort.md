---
title: Map Features by Value vs Effort
impact: HIGH
impactDescription: focuses 80% of effort on high-value work
tags: prio, value, effort, matrix
---

## Map Features by Value vs Effort

Plot features on a 2×2 matrix of value (user/business benefit) versus effort (development cost). This visualization immediately reveals quick wins (high value, low effort) and time sinks (low value, high effort).

**Incorrect (linear backlog):**

```markdown
## Backlog

1. Redesign homepage
2. Add export to PDF
3. Fix email typo
4. Build recommendation engine
5. Update footer links
6. Implement A/B testing framework

// No visibility into which items are quick wins
// Team might work on high-effort, low-value items first
```

**Correct (value/effort matrix):**

```markdown
## Feature Prioritization Matrix

                    HIGH VALUE
                        │
    ┌───────────────────┼───────────────────┐
    │                   │                   │
    │   QUICK WINS      │   BIG BETS        │
    │   Do First        │   Plan Carefully  │
    │                   │                   │
    │ • Fix email typo  │ • Recommendation  │
    │ • Update footer   │   engine          │
    │ • Add PDF export  │ • Redesign        │
    │                   │   homepage        │
LOW ├───────────────────┼───────────────────┤ HIGH
EFFORT                  │                   EFFORT
    │   FILL-INS        │   TIME SINKS      │
    │   Do If Idle      │   Avoid/Defer     │
    │                   │                   │
    │ • Minor UI tweaks │ • A/B testing     │
    │ • Doc updates     │   framework       │
    │                   │ • Legacy system   │
    │                   │   rewrite         │
    │                   │                   │
    └───────────────────┼───────────────────┘
                        │
                    LOW VALUE

## Prioritization Order
1. **Quick Wins** - Immediate, high ROI
2. **Big Bets** - Schedule with proper planning
3. **Fill-ins** - Use for sprint padding
4. **Time Sinks** - Avoid or significantly descope
```

**Estimation guidance:**
- Value: User feedback, revenue impact, strategic alignment
- Effort: T-shirt sizes (S/M/L/XL) or story points
- Re-evaluate quarterly as circumstances change

Reference: [ProductLift - Product Prioritization Frameworks](https://www.productlift.dev/blog/product-prioritization-framework)
