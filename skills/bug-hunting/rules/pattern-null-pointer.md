---
title: Recognize Null Pointer Patterns
impact: MEDIUM
impactDescription: prevents 20-30% of runtime errors
tags: pattern, null, undefined, defensive-coding
---

## Recognize Null Pointer Patterns

Null pointer dereferences occur when code assumes a value exists but it doesn't. Recognize the patterns: missing null checks, optional chaining neglected, uninitialized variables, and failed lookups assumed successful.

**Incorrect (assuming value exists):**

```typescript
function getUserEmail(userId: string): string {
  const user = userRepository.findById(userId)
  return user.email  // Crashes if user not found
}

function getFirstItem(items: Item[]): string {
  return items[0].name  // Crashes if array empty
}

function processConfig(config: Config): void {
  const timeout = config.settings.network.timeout  // Crashes if any level missing
}
```

**Correct (defensive null handling):**

```typescript
function getUserEmail(userId: string): string | null {
  const user = userRepository.findById(userId)
  if (!user) {
    logger.warn('user_not_found', { userId })
    return null
  }
  return user.email
}

function getFirstItem(items: Item[]): string | null {
  if (items.length === 0) {
    return null
  }
  return items[0].name
}

function processConfig(config: Config): void {
  const timeout = config?.settings?.network?.timeout ?? 30000
  // Uses optional chaining and default value
}
```

**Common null pointer sources:**
- Database/API lookups that return no results
- Array access with invalid index
- Object property access on undefined
- Map/dictionary lookups for missing keys
- Race conditions where value not yet initialized

Reference: [Krishna Gupta - Understanding CWE-476 NULL Pointer Dereference](https://krishnag.ceo/blog/understanding-cwe-476-null-pointer-dereference/)
