---
title: Know Common MSW Issues and Fixes
impact: LOW
impactDescription: Quick reference for frequent problems; reduces debugging time
tags: debug, troubleshooting, issues, fixes, reference
---

## Know Common MSW Issues and Fixes

Reference this checklist when MSW behaves unexpectedly. Most issues fall into a few common categories.

**Issue: "fetch is not defined"**

```typescript
// Fix: Upgrade Node.js to 18+
// Or ensure test environment has fetch polyfill

// Check Node version
node -v  // Must be 18.0.0+

// For older Node, use node-fetch polyfill (not recommended)
```

**Issue: Handler not matching**

```typescript
// Check 1: URL is absolute in Node.js
// Wrong:
http.get('/api/user', () => { /* ... */ })
// Request URL: http://localhost:3000/api/user (doesn't match)

// Right:
http.get('*/api/user', () => { /* ... */ })  // Wildcard matches any origin

// Check 2: Environment variables are defined
const API_URL = process.env.API_URL  // undefined in tests!
http.get(`${API_URL}/user`, () => { /* ... */ })  // Becomes 'undefined/user'

// Check 3: Console.log in handler to verify it's reached
http.get('/api/user', () => {
  console.log('Handler hit!')  // If not logged, URL doesn't match
  return HttpResponse.json({ name: 'John' })
})
```

**Issue: Body parsing hangs with fake timers**

```typescript
// Fix: Exclude queueMicrotask from fake timers
vi.useFakeTimers({
  toFake: ['setTimeout', 'setInterval', 'Date'],
  // queueMicrotask NOT faked
})

// Or for Jest:
jest.useFakeTimers({ doNotFake: ['queueMicrotask'] })
```

**Issue: Stale responses from cache**

```typescript
// Fix: Clear request library cache between tests
import { cache } from 'swr'

afterEach(() => {
  cache.clear()  // SWR
  queryClient.clear()  // TanStack Query
})
```

**Issue: Tests pass locally, fail in CI**

```typescript
// Check 1: Node version matches
// Check 2: Environment variables set in CI
// Check 3: Worker script committed for browser tests
// Check 4: Async utilities used (findBy, waitFor)
```

**Issue: JSDOM conflicts in Jest**

```bash
# Fix: Use jest-fixed-jsdom
npm install -D jest-fixed-jsdom
```

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jest-fixed-jsdom',  // Not 'jsdom'
}
```

**Issue: MSW v1 code in v2 project**

```typescript
// v1 (wrong):
rest.get('/api/user', (req, res, ctx) => {
  return res(ctx.json({ name: 'John' }))
})

// v2 (correct):
http.get('/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})
```

**When NOT to use this pattern:**
- Reference only; not all issues apply to every project

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)
