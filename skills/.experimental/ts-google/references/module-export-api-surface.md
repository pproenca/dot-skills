---
title: Minimize Exported API Surface
impact: HIGH
impactDescription: reduces coupling and maintenance burden
tags: module, exports, api-design, encapsulation
---

## Minimize Exported API Surface

Export only what consumers need. Internal implementation details should remain private to allow refactoring without breaking changes.

**Incorrect (over-exporting):**

```typescript
// user-service.ts
export const API_ENDPOINT = '/api/users'
export const MAX_RETRIES = 3

export function validateUser(user: User): boolean {
  return user.name.length > 0
}

export function formatUserForApi(user: User): ApiUser {
  return { userName: user.name, userId: user.id }
}

export async function createUser(name: string): Promise<User> {
  const user = { name, id: generateId() }
  if (!validateUser(user)) throw new Error('Invalid')
  const apiUser = formatUserForApi(user)
  return sendToApi(apiUser)
}
```

**Correct (minimal exports):**

```typescript
// user-service.ts
const API_ENDPOINT = '/api/users'
const MAX_RETRIES = 3

function validateUser(user: User): boolean {
  return user.name.length > 0
}

function formatUserForApi(user: User): ApiUser {
  return { userName: user.name, userId: user.id }
}

// Only export the public API
export async function createUser(name: string): Promise<User> {
  const user = { name, id: generateId() }
  if (!validateUser(user)) throw new Error('Invalid')
  const apiUser = formatUserForApi(user)
  return sendToApi(apiUser)
}
```

**Benefits:**
- Internal functions can be refactored freely
- Smaller public API is easier to document
- Clearer boundary between public and private code

Reference: [Google TypeScript Style Guide - Export visibility](https://google.github.io/styleguide/tsguide.html#export-visibility)
