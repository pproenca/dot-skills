---
title: Depend in the Direction of Stability
impact: HIGH
impactDescription: prevents unstable components from destabilizing dependents
tags: comp, stability, dependencies, direction
---

## Depend in the Direction of Stability

Components should depend on components that are more stable than themselves. A stable component (many dependents, few dependencies) should not depend on an unstable component (few dependents, many dependencies).

**Incorrect (stable component depends on unstable):**

```text
┌─────────────────────────────────────────────────────┐
│                     core-domain                      │
│  (Used by 50 services, should be very stable)       │
│                                                      │
│  import { formatDate } from 'ui-helpers'  // WRONG! │
│  import { sendMetrics } from 'analytics'  // WRONG! │
└──────────────────────┬──────────────────────────────┘
                       │
       ┌───────────────┼───────────────┐
       ▼               ▼               ▼
  ui-helpers      analytics      reporting
  (Changes        (Changes       (Changes
   weekly)         monthly)       often)

# When ui-helpers changes, core-domain might break
# When core-domain breaks, all 50 services break
```

**Correct (depend toward stability):**

```text
┌─────────────────────────────────────────────────────┐
│                     core-domain                      │
│  (Used by 50 services, zero external dependencies)  │
│                                                      │
│  - Only depends on language primitives              │
│  - Defines interfaces, not implementations          │
└─────────────────────────────────────────────────────┘
                       ▲
                       │
       ┌───────────────┼───────────────┐
       │               │               │
  ui-helpers      analytics      reporting
  │               │               │
  │               │               │
  ▼               ▼               ▼
┌─────────────────────────────────────────────────────┐
│              external-dependencies                   │
│  (date-fns, axios, lodash - maintained externally)  │
└─────────────────────────────────────────────────────┘

# Unstable components depend on stable core
# Core never breaks due to UI changes
```

**Stability Metric:**
```text
Instability = Outgoing Dependencies / (Incoming + Outgoing)
```
- I = 0: Maximally stable (many dependents, no dependencies)
- I = 1: Maximally unstable (no dependents, many dependencies)

Dependencies should flow from high I to low I.

Reference: [Clean Architecture - Stable Dependencies Principle](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch14.xhtml)
