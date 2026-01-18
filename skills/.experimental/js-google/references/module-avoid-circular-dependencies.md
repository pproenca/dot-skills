---
title: Avoid Circular Dependencies
impact: CRITICAL
impactDescription: prevents loading failures and undefined imports
tags: module, circular-dependency, imports, es-modules
---

## Avoid Circular Dependencies

Circular dependencies between ES modules cause one module to receive an incomplete export object, leading to undefined values and runtime errors that are difficult to debug.

**Incorrect (circular dependency causes undefined):**

```javascript
// userService.js
import { formatUser } from './userFormatter.js';

export function getUser(userId) {
  const user = database.findUser(userId);
  return formatUser(user);
}

// userFormatter.js
import { getUser } from './userService.js';  // Circular!

export function formatUser(user) {
  const manager = getUser(user.managerId);  // getUser is undefined here
  return { ...user, managerName: manager?.name };
}
```

**Correct (dependency extracted to shared module):**

```javascript
// userService.js
import { formatUser } from './userFormatter.js';

export function getUser(userId) {
  const user = database.findUser(userId);
  return formatUser(user);
}

// userFormatter.js
import { findUser } from './database.js';  // Direct dependency

export function formatUser(user) {
  const manager = findUser(user.managerId);
  return { ...user, managerName: manager?.name };
}
```

**When NOT to use this pattern:**
- CommonJS modules with dynamic `require()` may tolerate some circular refs
- Type-only imports in TypeScript don't cause runtime circular deps

Reference: [Google JavaScript Style Guide - ES modules](https://google.github.io/styleguide/jsguide.html#source-file-structure)
