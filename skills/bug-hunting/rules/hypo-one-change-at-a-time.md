---
title: Change One Thing at a Time
impact: CRITICAL
impactDescription: prevents introducing new bugs while fixing
tags: hypo, isolation, control, scientific-method
---

## Change One Thing at a Time

When debugging, change only one variable between experiments. Multiple simultaneous changes make it impossible to know which change fixed (or broke) the behavior.

**Incorrect (multiple changes at once):**

```typescript
// Bug: API returns 500 error
// Attempt: Change several things hoping one fixes it

async function fetchUserData(userId: string) {
  // Changed: URL path, timeout, headers, and error handling all at once
  const response = await fetch(`/api/v2/users/${userId}`, {  // Was /api/v1/
    timeout: 10000,                                           // Was 5000
    headers: { 'Accept': 'application/json' },               // Was missing
  })
  if (!response.ok) {
    return null                                               // Was throwing
  }
  return response.json()
}
// Bug is fixed, but which change fixed it? Unknown.
```

**Correct (one change per experiment):**

```typescript
// Bug: API returns 500 error
// Approach: Test each hypothesis separately

async function fetchUserData(userId: string) {
  // Experiment 1: Just add Accept header
  const response = await fetch(`/api/v1/users/${userId}`, {
    timeout: 5000,
    headers: { 'Accept': 'application/json' },  // Only change
  })
  // Result: Still 500 → Header not the issue

  // Experiment 2: Just increase timeout (revert header)
  const response = await fetch(`/api/v1/users/${userId}`, {
    timeout: 10000,  // Only change
  })
  // Result: Success! Bug was timeout-related

  if (!response.ok) throw new Error('Fetch failed')
  return response.json()
}
```

**Benefits:**
- Know exactly what fixed the bug
- Avoid introducing new bugs from unnecessary changes
- Build understanding of the system

Reference: [MIT 6.031 - Reading 13: Debugging](http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)
