---
title: Rename for Clarity
impact: LOW
impactDescription: makes code self-documenting and reduces need for comments
tags: micro, rename, clarity, refactoring
---

## Rename for Clarity

When a name doesn't clearly convey meaning, rename it. Good names eliminate the need for explanatory comments.

**Incorrect (unclear or misleading names):**

```typescript
// Single letters and abbreviations
function calc(a: number, b: number, t: string): number {
  if (t === 'add') return a + b
  if (t === 'sub') return a - b
  return 0
}

// Generic names
function processData(data: unknown[]): void {
  for (const item of data) {
    doStuff(item)
  }
}

// Names that don't match behavior
function validateUser(user: User): User {  // Doesn't just validate
  user.lastValidated = new Date()
  user.status = 'active'
  return user
}

// Misleading boolean names
const isReady = loadingComplete && !hasError && itemCount > 0
// Should processing continue if isReady is true or false?
```

**Correct (clear, intention-revealing names):**

```typescript
// Descriptive parameter names
function calculate(
  firstOperand: number,
  secondOperand: number,
  operation: 'add' | 'subtract'
): number {
  if (operation === 'add') return firstOperand + secondOperand
  if (operation === 'subtract') return firstOperand - secondOperand
  return 0
}

// Specific names for specific types
function sendNotifications(users: User[]): void {
  for (const user of users) {
    notifyUser(user)
  }
}

// Name matches behavior
function validateAndActivateUser(user: User): User {
  user.lastValidated = new Date()
  user.status = 'active'
  return user
}

// Boolean name answers "should we X?"
const shouldProcessItems = loadingComplete && !hasError && itemCount > 0
if (shouldProcessItems) {
  processItems()
}
```

**Rename method:**
1. Use IDE's rename refactoring (updates all references)
2. Run tests to verify nothing broke
3. If the name appears in logs/databases, plan migration

Reference: [Rename Variable](https://refactoring.com/catalog/renameVariable.html)
