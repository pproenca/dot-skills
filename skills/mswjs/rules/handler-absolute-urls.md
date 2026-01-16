---
title: Use Absolute URLs in Handlers
impact: CRITICAL
impactDescription: Prevents URL mismatch failures; required for Node.js environments
tags: handler, url, absolute, node, matching
---

## Use Absolute URLs in Handlers

Use absolute URLs or URL patterns in request handlers. Node.js environments require absolute URLs for proper matching, and relative URLs cause silent handler failures.

**Incorrect (relative URLs in Node.js context):**

```typescript
// mocks/handlers.ts
export const handlers = [
  // Relative URL - may not match in Node.js tests
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]

// Test makes request to full URL
await fetch('http://localhost:3000/api/user')
// Handler doesn't match - request goes unhandled
```

**Correct (absolute URLs or wildcards):**

```typescript
// mocks/handlers.ts
export const handlers = [
  // Absolute URL - matches reliably
  http.get('http://localhost:3000/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Better (wildcard for any origin):**

```typescript
// mocks/handlers.ts
export const handlers = [
  // Wildcard matches any origin - most flexible
  http.get('*/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),

  // Or use path patterns that MSW resolves against baseURL
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Environment variable pitfall:**

```typescript
// AVOID: Environment variable not set in tests
const API_URL = process.env.API_URL // undefined in tests!

http.get(`${API_URL}/user`, () => { /* ... */ })
// Results in: http.get('undefined/user', ...) - never matches
```

**When NOT to use this pattern:**
- Browser environments with properly configured base URLs may use relative paths

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)
