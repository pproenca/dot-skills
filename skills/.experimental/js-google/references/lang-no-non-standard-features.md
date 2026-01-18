---
title: Use Only Standard ECMAScript Features
impact: HIGH
impactDescription: prevents runtime errors on 100% of non-supporting platforms
tags: lang, ecmascript, standards, compatibility
---

## Use Only Standard ECMAScript Features

Use only features defined in ECMA-262 or WHATWG standards. Avoid proprietary extensions, removed features, and unstable TC39 proposals that may change or break.

**Incorrect (non-standard or removed features):**

```javascript
// Non-standard Mozilla extension
const items = [1, 2, 3];
for each (let item in items) {  // Non-standard, Firefox-only
  console.log(item);
}

// Removed from spec
const cache = new WeakMap();
cache.clear();  // Removed method, doesn't exist

// Stage 2 proposal, may change
const value = obj.#privateField;  // Syntax may differ in final spec
```

**Correct (standard features only):**

```javascript
// Standard for-of loop
const items = [1, 2, 3];
for (const item of items) {
  console.log(item);
}

// Standard WeakMap usage (no clear method exists)
let cache = new WeakMap();
cache = new WeakMap();  // Create new map instead

// Use stable ES2022 private fields
class Counter {
  #count = 0;  // Standardized private field syntax

  increment() {
    this.#count++;
  }
}
```

**Exceptions:**
- Platform-specific APIs when targeting that platform (Node.js, Chrome extensions)
- Polyfilled features with stable TC39 Stage 4 status

Reference: [Google JavaScript Style Guide - Non-standard features](https://google.github.io/styleguide/jsguide.html#disallowed-features-non-standard-features)
