---
title: Configure TypeScript for MSW v2
impact: CRITICAL
impactDescription: TypeScript 4.7+ required; incorrect config causes type errors
tags: setup, typescript, configuration, types, compiler
---

## Configure TypeScript for MSW v2

MSW v2 requires TypeScript 4.7+ for proper type inference. Incorrect TypeScript configuration causes confusing type errors and prevents proper handler typing.

**Incorrect (outdated TypeScript or missing config):**

```json
// tsconfig.json - missing moduleResolution
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext"
    // No moduleResolution - imports fail to resolve
  }
}
```

```typescript
// Type errors due to incorrect resolution
import { http, HttpResponse } from 'msw'
// Error: Cannot find module 'msw' or its corresponding type declarations
```

**Correct (proper TypeScript configuration):**

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler", // or "node16" / "nodenext"
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true
  }
}
```

**Typed handlers with proper inference:**

```typescript
import { http, HttpResponse } from 'msw'

interface User {
  id: string
  name: string
  email: string
}

export const handlers = [
  http.get<never, never, User>('/api/user/:id', ({ params }) => {
    // params.id is typed as string
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com',
    })
  }),
]
```

**When NOT to use this pattern:**
- JavaScript-only projects don't need TypeScript configuration
- Projects using older bundlers may need `moduleResolution: "node"`

Reference: [MSW v2 Migration - TypeScript](https://mswjs.io/docs/migrations/1.x-to-2.x/)
