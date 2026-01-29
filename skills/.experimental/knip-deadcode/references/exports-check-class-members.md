---
title: Check Class Members for Unused Code
impact: MEDIUM-HIGH
impactDescription: detects unused methods and properties in classes
tags: exports, classes, members, detection
---

## Check Class Members for Unused Code

Knip can detect unused class members (methods, properties). Enable with `--include classMembers` to catch dead code within classes.

**Incorrect (unused class members undetected):**

```typescript
// src/service.ts
export class UserService {
  private cache: Map<string, User> = new Map()

  getUser(id: string) { return this.cache.get(id) }
  setUser(id: string, user: User) { this.cache.set(id, user) }
  deleteUser(id: string) { this.cache.delete(id) }  // Never called
}
```

Default Knip run doesn't report `deleteUser` as unused.

**Correct (class members analyzed):**

```bash
knip --include classMembers
```

Now Knip reports: `deleteUser` is unused.

**Configuration:**

```json
{
  "rules": {
    "classMembers": "error"
  }
}
```

**Exclude enum members if too noisy:**

```bash
knip --include classMembers --exclude enumMembers
```

Reference: [Rules & Filters](https://knip.dev/features/rules-and-filters)
