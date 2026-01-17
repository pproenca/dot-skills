---
title: React Import as Namespace
impact: HIGH
impactDescription: enables consistent React.* usage and better tree-shaking
tags: style, imports, React, namespace
---

## React Import as Namespace

Import React as namespace (`import * as React from 'react'`) rather than default import with destructuring.

**Incorrect (anti-pattern):**

```typescript
import React, { useState, useEffect, useCallback, forwardRef } from 'react'

const Button = forwardRef((props, ref) => {
  const [pressed, setPressed] = useState(false)
  useEffect(() => { ... }, [])
  const handleClick = useCallback(() => { ... }, [])
})
```

**Correct (recommended):**

```typescript
import * as React from 'react'

const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const [pressed, setPressed] = React.useState(false)
  React.useEffect(() => { ... }, [])
  const handleClick = React.useCallback(() => { ... }, [])
})
```

**When to use:**
- All React component and hook files
- Provides consistent `React.` prefix throughout codebase
- Makes it clear which APIs are from React vs local
