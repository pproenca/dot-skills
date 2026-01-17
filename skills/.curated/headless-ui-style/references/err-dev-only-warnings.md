---
title: Development-Only Warnings
impact: CRITICAL
impactDescription: ensures warnings don't affect production bundle size or performance
tags: err, warnings, development, NODE_ENV
---

## Development-Only Warnings

Wrap all console warnings and errors in `process.env.NODE_ENV !== 'production'` checks. This ensures warnings are tree-shaken in production builds.

**Incorrect (always runs):**

```typescript
function useControlled({ controlled, default: defaultValue, name, state }) {
  const isControlled = controlled !== undefined

  if (isControlledRef.current !== isControlled) {
    console.warn(
      `A component is changing from ${isControlled ? 'controlled' : 'uncontrolled'} to ${isControlled ? 'uncontrolled' : 'controlled'}.`
    )
  }
}
```

**Correct (development only):**

```typescript
import { warn } from '../utils/warn'

function useControlled({ controlled, default: defaultValue, name, state }) {
  const isControlled = controlled !== undefined

  if (process.env.NODE_ENV !== 'production') {
    if (isControlledRef.current !== isControlled) {
      warn(
        `A component is changing from ${isControlled ? 'controlled' : 'uncontrolled'} to ${isControlled ? 'uncontrolled' : 'controlled'}.`,
        `This is likely caused by the value changing from undefined to a defined value, which should not happen.`,
        `Decide between using a controlled or uncontrolled ${name} element for the lifetime of the component.`
      )
    }
  }
}
```

**When to use:**
- All console.warn and console.error calls
- Validation messages
- Development-only debugging
