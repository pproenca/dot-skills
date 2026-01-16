---
title: Follow the Test Pyramid
impact: LOW
impactDescription: reduces test infrastructure cost by 10-100×
tags: strat, pyramid, distribution, balance
---

## Follow the Test Pyramid

Distribute tests according to the pyramid: many unit tests at the base, fewer integration tests in the middle, and minimal E2E tests at the top.

**Incorrect (inverted pyramid):**

```text
           ┌─────────────────────────────┐
           │      E2E Tests (500)        │  ← Slow, expensive, flaky
           ├─────────────────────────────┤
           │   Integration Tests (100)   │
           ├─────────────────────────────┤
           │    Unit Tests (50)          │  ← Fast, cheap, stable
           └─────────────────────────────┘

Test run time: 45 minutes
Maintenance cost: HIGH
Flakiness: FREQUENT
Infrastructure cost: $10,000/month
```

**Correct (proper pyramid):**

```text
                    ┌───────────┐
                    │ E2E (20)  │  ← Critical user journeys only
                ┌───┴───────────┴───┐
                │ Integration (100)  │  ← Component boundaries
            ┌───┴───────────────────┴───┐
            │     Unit Tests (500)       │  ← Business logic
            └───────────────────────────┘

Test run time: 5 minutes
Maintenance cost: LOW
Flakiness: RARE
Infrastructure cost: $100/month
```

**Distribution guidelines:**
| Layer | Count | Scope | Speed |
|-------|-------|-------|-------|
| Unit | 70-80% | Single function/class | <100ms |
| Integration | 15-25% | Multiple components | <5s |
| E2E | 5-10% | Full user journey | <30s |

**What to test at each level:**
- **Unit**: Business logic, calculations, transformations
- **Integration**: API contracts, database queries, service interactions
- **E2E**: Critical user paths, smoke tests, happy paths

Reference: [The Practical Test Pyramid - Martin Fowler](https://martinfowler.com/articles/practical-test-pyramid.html)
