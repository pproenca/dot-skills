---
title: Name Tokens by Role, Not by Value
impact: CRITICAL
impactDescription: prevents rename churn when brand values change
tags: token, naming, semantics, theme
---

## Name Tokens by Role, Not by Value

A token named for its color (`green`, `red`) becomes a lie the moment design changes that color — the name says green but the value is teal. Naming tokens for their role (`statusConfirmed`) keeps the name accurate through any value change and tells the reader what the token is *for*, not just what it looks like today.

**Incorrect (value-named tokens that go stale):**

```typescript
const lightTheme = {
  colors: { green: '#16A34A', red: '#DC2626', blue: '#2563EB' },
}

// An appointment badge uses colors.green to mean "confirmed".
const styles = StyleSheet.create((theme) => ({
  badgeConfirmed: { backgroundColor: theme.colors.green },
}))
// When design recolors confirmed to teal, the token still reads "green" —
// the next engineer has no idea green now holds a teal value.
```

**Correct (role-named tokens that stay honest):**

```typescript
const lightTheme = {
  colors: { statusConfirmed: '#16A34A', statusCancelled: '#DC2626', statusPending: '#2563EB' },
}

const styles = StyleSheet.create((theme) => ({
  badgeConfirmed: { backgroundColor: theme.colors.statusConfirmed },
}))
// Recoloring confirmed to teal changes the value only; the name still describes intent.
```

Reference: [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
