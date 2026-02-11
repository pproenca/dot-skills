---
title: Avoid the delete Operator on Objects
impact: MEDIUM
impactDescription: prevents V8 deoptimization from hidden class transitions
tags: perf, delete, v8, deoptimization
---

## Avoid the delete Operator on Objects

The `delete` operator triggers V8 hidden class transitions, converting the object from a fast "struct-like" representation to a slow dictionary mode. Use destructuring with rest or set the property to `undefined` instead.

**Incorrect (delete triggers deoptimization):**

```typescript
function sanitizeUser(user: User & { password?: string }) {
  delete user.password // V8 transitions object to dictionary mode
  return user
}
```

**Correct (destructure and omit):**

```typescript
function sanitizeUser(user: User & { password?: string }) {
  const { password, ...sanitized } = user
  return sanitized // New object, original unchanged, V8 stays optimized
}
```

**Alternative (set to undefined if mutation is acceptable):**

```typescript
function sanitizeUser(user: User & { password?: string }) {
  user.password = undefined // No hidden class change
  return user
}
```
