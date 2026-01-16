---
title: Avoid Large Union Types
impact: CRITICAL
impactDescription: quadratic O(n²) comparison cost
tags: type, unions, compilation, performance, discriminated-unions
---

## Avoid Large Union Types

Union type checking is quadratic—TypeScript compares each union member pairwise. Unions with more than 12 elements cause measurable compilation slowdowns. Use discriminated unions or base types instead.

**Incorrect (large union, O(n²) checks):**

```typescript
type HttpStatus =
  | 100 | 101 | 102 | 103
  | 200 | 201 | 202 | 203 | 204 | 205 | 206
  | 300 | 301 | 302 | 303 | 304 | 307 | 308
  | 400 | 401 | 402 | 403 | 404 | 405 | 406 | 407 | 408 | 409 | 410
  | 500 | 501 | 502 | 503 | 504 | 505
// 35+ members = 1000+ pairwise comparisons

type EventType = 'click' | 'hover' | 'focus' | /* ...50 more events... */
```

**Correct (discriminated union with base interface):**

```typescript
interface HttpStatusBase {
  code: number
  category: 'info' | 'success' | 'redirect' | 'clientError' | 'serverError'
}

interface SuccessStatus extends HttpStatusBase {
  category: 'success'
  code: 200 | 201 | 202 | 203 | 204
}

interface ClientErrorStatus extends HttpStatusBase {
  category: 'clientError'
  code: 400 | 401 | 403 | 404
}

type HttpStatus = SuccessStatus | ClientErrorStatus // Small union of interfaces
```

**Alternative (branded number type):**

```typescript
type HttpStatusCode = number & { readonly brand: unique symbol }

function isValidStatus(code: number): code is HttpStatusCode {
  return code >= 100 && code < 600
}
```

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#preferring-base-types-over-unions)
