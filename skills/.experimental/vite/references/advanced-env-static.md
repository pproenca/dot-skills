---
title: Use Static Environment Variables
impact: MEDIUM
impactDescription: enables tree-shaking of dev-only code
tags: advanced, env, import-meta, tree-shaking
---

## Use Static Environment Variables

Vite replaces `import.meta.env` values statically at build time. Use full static strings to enable dead code elimination.

**Incorrect (dynamic access prevents tree-shaking):**

```typescript
// Runtime check - not eliminated
const key = 'DEV'
if (import.meta.env[key]) {
  console.log('Development mode')
}

// Computed access
const envKey = 'VITE_API_URL'
const url = import.meta.env[envKey]
```

**Correct (static access enables tree-shaking):**

```typescript
// Compile-time elimination
if (import.meta.env.DEV) {
  console.log('Development mode')
}
// Entire block removed in production

// Static access
const url = import.meta.env.VITE_API_URL
// Replaced with actual value at build time
```

**Built-in env variables:**

```typescript
import.meta.env.MODE       // 'development' | 'production'
import.meta.env.DEV        // true in dev
import.meta.env.PROD       // true in prod
import.meta.env.SSR        // true in SSR
import.meta.env.BASE_URL   // base path
```

**Custom env variables:**

```env
# .env
VITE_API_URL=https://api.example.com
VITE_FEATURE_FLAG=true
```

```typescript
// Only VITE_ prefixed vars are exposed
const api = import.meta.env.VITE_API_URL
```

**Type declarations:**

```typescript
// env.d.ts
interface ImportMetaEnv {
  readonly VITE_API_URL: string
  readonly VITE_FEATURE_FLAG: string
}
```

Reference: [Env Variables and Modes](https://vite.dev/guide/env-and-mode)
