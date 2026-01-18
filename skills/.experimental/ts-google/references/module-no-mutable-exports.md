---
title: Avoid Mutable Exports
impact: CRITICAL
impactDescription: prevents hard-to-track state mutations
tags: module, exports, immutability, state-management
---

## Avoid Mutable Exports

Mutable exports create hidden state that can be modified from anywhere, making code behavior unpredictable and bugs difficult to trace.

**Incorrect (mutable export):**

```typescript
// config.ts
export let currentUser: User | null = null
export let apiEndpoint = 'https://api.example.com'

// somewhere.ts
import { currentUser, apiEndpoint } from './config'
apiEndpoint = 'https://staging.example.com'  // Mutates global state
```

**Correct (immutable exports with explicit setters):**

```typescript
// config.ts
let _currentUser: User | null = null
const _apiEndpoint = 'https://api.example.com'

export function getCurrentUser(): User | null {
  return _currentUser
}

export function setCurrentUser(user: User | null): void {
  _currentUser = user
}

export const apiEndpoint = _apiEndpoint  // const export
```

**Alternative (readonly object):**

```typescript
export const config = {
  apiEndpoint: 'https://api.example.com',
  timeout: 5000,
} as const
```

Reference: [Google TypeScript Style Guide - Mutable exports](https://google.github.io/styleguide/tsguide.html#mutable-exports)
