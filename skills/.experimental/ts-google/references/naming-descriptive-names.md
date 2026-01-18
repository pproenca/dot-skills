---
title: Use Descriptive Names
impact: MEDIUM
impactDescription: improves code maintainability
tags: naming, descriptive, readability, style
---

## Use Descriptive Names

Use descriptive names that clearly communicate purpose. Avoid ambiguous abbreviations. Short names are acceptable only in very limited scopes.

**Incorrect (ambiguous or abbreviated):**

```typescript
// Unclear abbreviations
const usr = getUser()
const cfg = loadConfig()
const btn = document.querySelector('button')

// Single letters in wide scope
function processData(d: Data) {
  const r = transform(d)
  return format(r)
}

// Meaningless names
const temp = calculateValue()
const data = fetchData()  // What kind of data?
```

**Correct (descriptive):**

```typescript
// Clear, full words
const currentUser = getUser()
const appConfig = loadConfig()
const submitButton = document.querySelector('button')

// Descriptive names
function processUserData(userData: UserData) {
  const transformedData = transform(userData)
  return format(transformedData)
}

// Specific names
const discountedPrice = calculateDiscountedPrice()
const userPreferences = fetchUserPreferences()
```

**When short names are acceptable:**

```typescript
// Very limited scope (≤10 lines)
users.map(u => u.name)
items.filter(x => x.active)

// Conventional loop variables
for (let i = 0; i < count; i++) {}

// Mathematical/domain conventions
const x = point.x
const y = point.y
```

Reference: [Google TypeScript Style Guide - Descriptive names](https://google.github.io/styleguide/tsguide.html#descriptive-names)
