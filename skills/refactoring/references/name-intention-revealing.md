---
title: Use Intention-Revealing Names
impact: HIGH
impactDescription: reduces code comprehension time by 40-60%
tags: name, intention, readability, self-documenting
---

## Use Intention-Revealing Names

Names should reveal why something exists, what it does, and how it is used. A reader should understand the purpose without reading the implementation.

**Incorrect (cryptic or generic names):**

```typescript
function proc(lst: number[]): number {
  let t = 0
  for (const x of lst) {
    if (x > 0) {
      t += x
    }
  }
  return t
}

const d = getD()
const flag = checkFlag(d)
if (flag) {
  proc(d.n)
}
```

**Correct (intention-revealing names):**

```typescript
function sumPositiveValues(values: number[]): number {
  let total = 0
  for (const value of values) {
    if (value > 0) {
      total += value
    }
  }
  return total
}

const transaction = getTransaction()
const isApproved = isTransactionApproved(transaction)
if (isApproved) {
  sumPositiveValues(transaction.amounts)
}
```

**Naming guidelines:**
- Variables: Describe what they hold (`customerEmail`, not `str` or `data`)
- Functions: Describe what they do (`calculateShippingCost`, not `calc`)
- Booleans: Use `is`, `has`, `can`, `should` prefixes (`isValid`, `hasPermission`)
- Collections: Use plural nouns (`users`, `orderItems`)

Reference: [Clean Code - Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
