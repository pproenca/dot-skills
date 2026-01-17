---
title: Know Common MSW Issues and Fixes
impact: LOW
impactDescription: Quick reference for frequent problems; reduces debugging time
tags: debug, troubleshooting, issues, fixes, reference
---

## Know Common MSW Issues and Fixes

Reference this checklist when MSW behaves unexpectedly. Most issues fall into a few common categories that have well-known solutions.

**Incorrect (handler not matching due to relative URL):**

```typescript
// Node.js environment - handler never matches
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Relative URL doesn't match absolute request URLs
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]

// When fetch('http://localhost:3000/api/user') is called,
// the handler doesn't match because '/api/user' !== 'http://localhost:3000/api/user'
```

**Correct (handler matches with wildcard):**

```typescript
// Node.js environment - handler matches any origin
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Wildcard matches any origin prefix
  http.get('*/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]

// Now fetch('http://localhost:3000/api/user') matches correctly
```

## Common Issues Quick Reference

**Issue: "fetch is not defined"**
- Fix: Upgrade Node.js to 18+ (native fetch support)

**Issue: Body parsing hangs with fake timers**
```typescript
// Fix: Exclude queueMicrotask from fake timers
vi.useFakeTimers({
  toFake: ['setTimeout', 'setInterval', 'Date'],
  // queueMicrotask NOT faked
})
```

**Issue: Stale responses from cache**
```typescript
// Fix: Clear request library cache between tests
afterEach(() => {
  cache.clear()  // SWR
  queryClient.clear()  // TanStack Query
})
```

**Issue: MSW v1 code in v2 project**
```typescript
// v2 correct syntax:
http.get('/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})
```

**When NOT to use this pattern:**
- Reference only; not all issues apply to every project

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)
