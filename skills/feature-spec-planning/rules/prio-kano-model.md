---
title: Use Kano Model for Customer Satisfaction Prioritization
impact: HIGH
impactDescription: avoids over-investing in features users expect
tags: prio, kano, satisfaction, customer-value
---

## Use Kano Model for Customer Satisfaction Prioritization

The Kano model categorizes features by how they affect customer satisfaction: Basic (expected), Performance (more is better), and Delighters (unexpected joy). This prevents over-investing in basics while missing delighters.

**Incorrect (treating all features equally):**

```markdown
## Feature Investment

Equal effort on:
- Bug-free login (users expect this)
- Faster search (users appreciate this)
- Confetti on milestones (users love this)

// Over-engineering login adds no satisfaction
// Under-investing in search frustrates users
// Missing delighters makes product forgettable
```

**Correct (Kano-informed prioritization):**

```markdown
## Feature Categorization - Kano Model

### Basic Needs (Must be present, no extra satisfaction)
_Users expect these; absence causes dissatisfaction_

| Feature | Investment Strategy |
|---------|---------------------|
| Login works reliably | Meet threshold, don't over-invest |
| Data doesn't get lost | Table stakes, not a differentiator |
| Pages load eventually | Basic functionality, not a selling point |

**Strategy:** Ensure quality, minimize excess investment

---

### Performance Needs (More is better, linear satisfaction)
_Users appreciate improvements proportionally_

| Feature | Investment Strategy |
|---------|---------------------|
| Search speed | Every 100ms improvement adds value |
| Storage space | More is always appreciated |
| Export formats | Each new format adds incremental value |

**Strategy:** Invest based on competitive positioning

---

### Delighters (Unexpected, exponential satisfaction)
_Users don't expect these; presence creates loyalty_

| Feature | Investment Strategy |
|---------|---------------------|
| Keyboard shortcuts | Power users will evangelize |
| Smart suggestions | "It read my mind!" moments |
| Celebration animations | Emotional connection |

**Strategy:** Small investment, high differentiation potential

---

### Investment Allocation
- 50% on Performance (competitive advantage)
- 30% on Basics (meet expectations)
- 20% on Delighters (create loyalty)
```

**Kano survey technique:**
Ask both: "How would you feel if we had X?" and "How would you feel if we didn't have X?"

Reference: [AltexSoft - Prioritization Techniques](https://www.altexsoft.com/blog/most-popular-prioritization-techniques-and-methods-moscow-rice-kano-model-walking-skeleton-and-others/)
