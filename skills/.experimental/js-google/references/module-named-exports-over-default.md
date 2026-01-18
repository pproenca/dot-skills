---
title: Prefer Named Exports Over Default Exports
impact: CRITICAL
impactDescription: enables better refactoring and prevents import inconsistencies
tags: module, exports, named-export, default-export
---

## Prefer Named Exports Over Default Exports

Named exports enforce consistent import names across the codebase, enable IDE auto-imports, and make refactoring safer. Default exports allow arbitrary local names that diverge over time.

**Incorrect (default export allows naming drift):**

```javascript
// userService.js
export default class UserService {
  async fetchUser(userId) {
    return await api.get(`/users/${userId}`);
  }
}

// component.js
import UserSvc from './userService.js';  // Arbitrary name

// anotherFile.js
import UsrService from './userService.js';  // Different name, same thing
```

**Correct (named export enforces consistency):**

```javascript
// userService.js
export class UserService {
  async fetchUser(userId) {
    return await api.get(`/users/${userId}`);
  }
}

// component.js
import { UserService } from './userService.js';

// anotherFile.js
import { UserService } from './userService.js';  // Same name everywhere
```

**Alternative (aliasing when needed):**

```javascript
import { UserService as AdminUserService } from './userService.js';
```

**When to use default exports:**
- When interoperating with libraries that expect default exports
- Single-export modules where the filename is descriptive (e.g., `Button.js`)

Reference: [Google JavaScript Style Guide - Named vs default exports](https://google.github.io/styleguide/jsguide.html#es-module-exports)
