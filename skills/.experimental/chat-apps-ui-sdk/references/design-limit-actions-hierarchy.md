---
title: Limit Actions and Keep a Clear Hierarchy
impact: MEDIUM-HIGH
impactDescription: prevents overwhelming inline cards
tags: design, actions, hierarchy, cta
---

## Limit Actions and Keep a Clear Hierarchy

An inline card should offer one primary action and at most one secondary; piling five equal-weight buttons into a small card destroys hierarchy and makes the user hunt for the next step. Lead with a headline, then supporting detail, then a single primary call to action, and move the long tail of actions into fullscreen where there is room for them.

**Incorrect (five equal-weight buttons flatten the hierarchy):**

```tsx
<Card>
  {["Book", "Hold", "Share", "Compare", "Details"].map((label) => <button key={label}>{label}</button>)}
</Card>
```

**Correct (one primary, one secondary; extra actions move to fullscreen):**

```tsx
<Card>
  <h3>{flight.route}</h3>
  <p>{flight.times}</p>
  <button className="primary">Book</button>
  <button className="secondary" onClick={openDetails}>Details</button>
</Card>
```

Reference: [UI guidelines – Apps SDK](https://developers.openai.com/apps-sdk/concepts/ui-guidelines)
