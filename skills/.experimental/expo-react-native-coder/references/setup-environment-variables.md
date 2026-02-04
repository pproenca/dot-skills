---
title: Use EXPO_PUBLIC_ Prefix for Client Variables
impact: CRITICAL
impactDescription: prevents exposing secrets in client bundle
tags: setup, environment-variables, security, configuration
---

## Use EXPO_PUBLIC_ Prefix for Client Variables

Only variables prefixed with `EXPO_PUBLIC_` are inlined into the client bundle. Never prefix sensitive secrets with `EXPO_PUBLIC_` as end users can access all embedded environment variables.

**Incorrect (secret exposed in client bundle):**

```bash
# .env
EXPO_PUBLIC_API_KEY=sk-secret-key-12345
DATABASE_URL=postgres://user:pass@host/db
```

```typescript
// Accessible to end users - DANGEROUS!
const apiKey = process.env.EXPO_PUBLIC_API_KEY;
```

**Correct (public variables only, secrets in server/EAS):**

```bash
# .env
EXPO_PUBLIC_API_URL=https://api.myapp.com
EXPO_PUBLIC_ENVIRONMENT=development
```

```typescript
// app/api/data+api.ts (server-side only)
import { runTask } from 'expo-server';

export async function GET() {
  // Secret accessed only on server
  const dbUrl = process.env.DATABASE_URL;
  // ...
}

// Client-side component
const apiUrl = process.env.EXPO_PUBLIC_API_URL;
```

**Note:** Use EAS Secrets for sensitive values needed during builds. Server-side API routes can safely access non-public environment variables.

Reference: [Environment variables in Expo - Expo Documentation](https://docs.expo.dev/guides/environment-variables/)
