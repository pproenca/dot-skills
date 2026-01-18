---
title: Avoid Duplicate Import Statements
impact: HIGH
impactDescription: reduces confusion and bundle overhead
tags: module, imports, duplicates, organization
---

## Avoid Duplicate Import Statements

Import from the same file only once. Multiple import statements for the same module create confusion and may cause subtle ordering issues with side effects.

**Incorrect (multiple imports from same module):**

```javascript
import { fetchUser } from './api/userApi.js';
import { UserRole } from './api/userApi.js';
import { validatePermissions } from './api/userApi.js';

export async function loadAdminUser(userId) {
  const user = await fetchUser(userId);
  if (user.role !== UserRole.ADMIN) {
    throw new Error('Not an admin');
  }
  validatePermissions(user);
  return user;
}
```

**Correct (single consolidated import):**

```javascript
import { fetchUser, UserRole, validatePermissions } from './api/userApi.js';

export async function loadAdminUser(userId) {
  const user = await fetchUser(userId);
  if (user.role !== UserRole.ADMIN) {
    throw new Error('Not an admin');
  }
  validatePermissions(user);
  return user;
}
```

**Alternative (namespace import for many exports):**

```javascript
import * as userApi from './api/userApi.js';

export async function loadAdminUser(userId) {
  const user = await userApi.fetchUser(userId);
  if (user.role !== userApi.UserRole.ADMIN) {
    throw new Error('Not an admin');
  }
  userApi.validatePermissions(user);
  return user;
}
```

Reference: [Google JavaScript Style Guide - ES module imports](https://google.github.io/styleguide/jsguide.html#es-module-imports)
