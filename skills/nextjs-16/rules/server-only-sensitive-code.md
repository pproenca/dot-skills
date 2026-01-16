---
title: Use 'server-only' for Sensitive Code
impact: HIGH
impactDescription: Build-time error prevents secrets from leaking to client bundle; catches accidental imports before deployment
tags: server, server-only, security, secrets
---

## Use 'server-only' for Sensitive Code

The `server-only` package marks modules as server-exclusive. If accidentally imported in a Client Component, the build fails immediately. This prevents API keys, database credentials, and sensitive logic from reaching the client bundle.

**Incorrect (accidental client exposure risk):**

```typescript
// lib/db.ts
// Nothing prevents this from being imported in a Client Component
export async function getUser(id: string) {
  return db.query(
    'SELECT * FROM users WHERE id = ?',
    [id],
    { connectionString: process.env.DATABASE_URL }  // Could leak!
  )
}
```

```typescript
'use client'

// Accidentally importing server code
import { getUser } from '@/lib/db'  // DATABASE_URL exposed in bundle!

export default function UserProfile() {
  // ...
}
```

**Correct (with server-only guard):**

```bash
npm install server-only
```

```typescript
// lib/db.ts
import 'server-only'  // Build fails if imported in Client Component

export async function getUser(id: string) {
  return db.query(
    'SELECT * FROM users WHERE id = ?',
    [id],
    { connectionString: process.env.DATABASE_URL }  // Safe - server only
  )
}
```

```typescript
'use client'

import { getUser } from '@/lib/db'
// ❌ Build error: You're importing a component that imports 'server-only'.
// This error is thrown during the build - no accidental deployment
```

**Apply to sensitive modules:**

```typescript
// lib/auth.ts
import 'server-only'

export async function verifySession(token: string) {
  return jwt.verify(token, process.env.JWT_SECRET)  // Secret protected
}

export async function getSessionUser() {
  const token = cookies().get('session')?.value
  return verifySession(token)
}
```

```typescript
// lib/analytics.ts
import 'server-only'

export async function trackServerEvent(event: string, data: object) {
  await fetch('https://analytics.internal/track', {
    method: 'POST',
    headers: { 'X-API-Key': process.env.ANALYTICS_API_KEY },  // Protected
    body: JSON.stringify({ event, ...data }),
  })
}
```

**When NOT to use this pattern:**
- Utility functions that are safe for client (formatting, validation)
- Shared types and interfaces
- Constants without sensitive values

Reference: [Next.js server-only Package](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#keeping-server-only-code-out-of-the-client-environment)
