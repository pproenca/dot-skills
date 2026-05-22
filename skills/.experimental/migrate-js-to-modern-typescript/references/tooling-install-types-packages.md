---
title: Install types Packages Before Casting Library Returns
impact: LOW-MEDIUM
impactDescription: enables free library type coverage
tags: tooling, definitelytyped, types, dependencies
---

## Install types Packages Before Casting Library Returns

A large share of JavaScript libraries ship community type definitions on DefinitelyTyped as `@types/*` packages that provide full signatures for free. Reaching for `as` or `any` to silence a missing-types error throws away type information you could install in one command — and the cast then hides real misuse the signatures would have caught.

**Incorrect (casting around types that actually exist):**

```typescript
const lodash = require("lodash") as any
const unique = lodash.uniqBy(orders, "customerId") // unique is any
```

**Correct (install the @types package, get full signatures):**

```typescript
// npm install -D @types/lodash
import { uniqBy } from "lodash"

const unique = uniqBy(orders, (order) => order.customerId) // fully typed
```

Check for types with `npm view @types/<package>` before writing any cast.

Reference: [DefinitelyTyped](https://github.com/DefinitelyTyped/DefinitelyTyped)
