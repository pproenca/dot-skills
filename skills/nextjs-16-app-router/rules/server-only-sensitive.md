---
title: Use server-only for Sensitive Code
impact: HIGH
impactDescription: prevents accidental exposure of API keys, database credentials, and business logic to client bundles
tags: server, security, server-only, secrets
---

## Use server-only for Sensitive Code

Mark modules containing sensitive logic with the `server-only` package to trigger a build-time error if accidentally imported into a Client Component. This prevents API keys, database connections, and proprietary algorithms from leaking into the client bundle.

**Incorrect (sensitive code without protection):**

```typescript
// lib/analytics.ts
const INTERNAL_API_KEY = process.env.ANALYTICS_SECRET_KEY

export async function trackRevenue(amount: number, userId: string) {
  await fetch('https://internal-analytics.company.com/track', {
    headers: { 'X-API-Key': INTERNAL_API_KEY },  // Could leak to client
    body: JSON.stringify({ amount, userId, timestamp: Date.now() }),
  })
}

export function calculateCommission(revenue: number): number {
  // Proprietary business logic - should stay server-side
  return revenue * 0.15 + Math.min(revenue * 0.05, 1000)
}
```

**Correct (protected with server-only):**

```typescript
// lib/analytics.ts
import 'server-only'  // Build error if imported in Client Component

const INTERNAL_API_KEY = process.env.ANALYTICS_SECRET_KEY

export async function trackRevenue(amount: number, userId: string) {
  await fetch('https://internal-analytics.company.com/track', {
    headers: { 'X-API-Key': INTERNAL_API_KEY },
    body: JSON.stringify({ amount, userId, timestamp: Date.now() }),
  })
}

export function calculateCommission(revenue: number): number {
  return revenue * 0.15 + Math.min(revenue * 0.05, 1000)
}
// Importing in 'use client' component now fails at build time
```

**Installation:**

```bash
npm install server-only
```

**When to use server-only:**
- Database connection modules
- API route handlers with secrets
- Payment processing logic
- Authentication/authorization helpers
- Proprietary algorithms

**Alternative - client-only package:**

```typescript
import 'client-only'  // Ensures module only runs in browser

export function useLocalStorage(key: string) {
  // Browser-only code that would crash on server
  return window.localStorage.getItem(key)
}
```

Reference: [server-only Package](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#keeping-server-only-code-out-of-the-client-environment)
