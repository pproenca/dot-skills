---
title: Simplify Boolean Expressions
impact: LOW
impactDescription: improves readability and reduces cognitive load
tags: micro, boolean, simplification, expressions
---

## Simplify Boolean Expressions

Complex boolean expressions can often be simplified. Apply boolean algebra and use language features to make conditions clearer.

**Incorrect (overly complex boolean logic):**

```typescript
// Double negatives
if (!user.isNotActive) {
  activateFeatures()
}

// Redundant comparisons
if (isValid === true) {
  process()
}
if (count !== 0) {
  showItems()
}

// Unnecessarily complex conditions
if (status === 'active' || status === 'pending' || status === 'processing') {
  handleInProgress()
}

// Redundant else
function isEligible(user: User): boolean {
  if (user.age >= 18) {
    return true
  } else {
    return false
  }
}

// Nested ternaries
const label = isAdmin ? 'Admin' : isManager ? 'Manager' : isEmployee ? 'Employee' : 'Guest'
```

**Correct (simplified expressions):**

```typescript
// Remove double negative
if (user.isActive) {
  activateFeatures()
}

// Simplify comparisons
if (isValid) {
  process()
}
if (count) {  // Or: if (count > 0) for explicit intent
  showItems()
}

// Use includes for multiple equality checks
const inProgressStatuses = ['active', 'pending', 'processing']
if (inProgressStatuses.includes(status)) {
  handleInProgress()
}

// Return the expression directly
function isEligible(user: User): boolean {
  return user.age >= 18
}

// Use object lookup instead of nested ternaries
const roleLabels: Record<string, string> = {
  admin: 'Admin',
  manager: 'Manager',
  employee: 'Employee'
}
const label = roleLabels[user.role] ?? 'Guest'
```

**Common simplifications:**
- `if (x === true)` → `if (x)`
- `if (x === false)` → `if (!x)`
- `if (arr.length !== 0)` → `if (arr.length)`
- `x ? true : false` → `Boolean(x)` or `!!x`
- `!(!x)` → `x`

Reference: [Simplify Conditional Expression](https://refactoring.com/catalog/consolidateConditionalExpression.html)
