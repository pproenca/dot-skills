---
title: Add use client Directive
impact: HIGH
impactDescription: enables components to work in React Server Components environments like Next.js App Router
tags: comp, rsc, server-components, use-client
---

## Add use client Directive

Add the `'use client'` directive at the top of component files for React Server Components compatibility. This ensures components work correctly in Next.js App Router and other RSC environments.

**Incorrect (no directive):**

```typescript
import * as React from 'react'

export const Button = React.forwardRef(function Button(props, ref) {
  // Uses hooks - requires client environment
  const [pressed, setPressed] = React.useState(false)
  // ...
})
```

**Correct (with directive):**

```typescript
'use client'

import * as React from 'react'

export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const [pressed, setPressed] = React.useState(false)
  // ...
})
```

**When to use:**
- All component files that use React hooks
- All component files that use browser APIs
- NOT needed for pure utility functions or type definitions
