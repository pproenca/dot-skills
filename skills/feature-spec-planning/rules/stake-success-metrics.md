---
title: Align on Success Metrics Before Building
impact: MEDIUM-HIGH
impactDescription: eliminates 90% of post-launch success disputes
tags: stake, metrics, success, kpi
---

## Align on Success Metrics Before Building

Define how success will be measured before development begins. Without agreed metrics, stakeholders will evaluate the feature by different criteria, leading to "success" debates after launch.

**Incorrect (undefined success):**

```markdown
## Feature: Search Improvements

Goal: Make search better

// Post-launch:
// PM: "Search is better—users can find things faster"
// Sales: "But conversion didn't improve"
// Exec: "Was this worth the investment?"
// Everyone has different definition of "better"
```

**Correct (defined success metrics):**

```markdown
## Feature: Search Improvements

### Success Metrics (Agreed by all stakeholders)

**Primary Metrics (Must achieve)**
| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| Search-to-click rate | 35% | 50% | Analytics event |
| Zero-result rate | 15% | < 5% | Search logs |
| Search latency p95 | 800ms | < 300ms | APM dashboard |

**Secondary Metrics (Monitor)**
| Metric | Baseline | Watch For |
|--------|----------|-----------|
| Conversion rate | 2.5% | Should not decrease |
| Page load time | 1.2s | Should not increase > 20% |
| Support tickets (search-related) | 50/week | Should decrease |

**Timeline for Measurement**
- Week 1-2 post-launch: Monitor for regressions
- Week 4: Initial success assessment
- Week 8: Full success evaluation

### Success Criteria Agreement

| Stakeholder | Primary Metric Focus | Sign-off |
|-------------|---------------------|----------|
| PM (Carol) | Search-to-click rate | ✓ |
| Eng (Dan) | Latency p95 | ✓ |
| Sales (Sarah) | Conversion rate | ✓ |
| Exec (Alice) | All metrics balanced | ✓ |

### Definition of Success
Feature is successful if:
- ALL primary metrics hit target
- NO secondary metric regresses significantly
- Measured 8 weeks post-launch with statistical significance
```

**Metric selection criteria:**
- Measurable with existing tools
- Attributable to this feature
- Meaningful to business outcomes
- Agreed by all stakeholders before development

Reference: [Product School - Acceptance Criteria in Practice](https://productschool.com/blog/product-fundamentals/acceptance-criteria)
