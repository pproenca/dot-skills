---
title: Use CONSTANT_CASE for Deeply Immutable Values
impact: HIGH
impactDescription: signals immutability and prevents accidental modification
tags: naming, constants, immutable, constant-case
---

## Use CONSTANT_CASE for Deeply Immutable Values

Use CONSTANT_CASE (all caps with underscores) only for `@const` values that are deeply immutable. Regular `const` variables that hold mutable objects use lowerCamelCase.

**Incorrect (CONSTANT_CASE for mutable values):**

```javascript
// Array is mutable - wrong casing
const ALLOWED_ROLES = ['admin', 'editor', 'viewer'];
ALLOWED_ROLES.push('guest');  // Can still mutate!

// Object is mutable - wrong casing
const DEFAULT_CONFIG = {
  timeout: 5000,
  retries: 3,
};
DEFAULT_CONFIG.timeout = 10000;  // Can still mutate!

// Regular const binding - wrong casing
const USER_COUNT = users.length;  // Value computed at runtime
```

**Correct (CONSTANT_CASE only for truly immutable):**

```javascript
/** @const {number} */
const MAX_RETRY_COUNT = 3;

/** @const {string} */
const API_BASE_URL = 'https://api.example.com';

/** @const {!Object<string, number>} */
const HttpStatus = Object.freeze({
  OK: 200,
  NOT_FOUND: 404,
  SERVER_ERROR: 500,
});

// Mutable references use lowerCamelCase
const allowedRoles = ['admin', 'editor', 'viewer'];
const defaultConfig = { timeout: 5000, retries: 3 };
const userCount = users.length;
```

**Requirements for CONSTANT_CASE:**
- Value is a primitive literal, or
- Deeply immutable object (frozen or enum), and
- Annotated with `@const`

Reference: [Google JavaScript Style Guide - Constant names](https://google.github.io/styleguide/jsguide.html#naming-constant-names)
