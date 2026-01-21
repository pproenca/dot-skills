---
title: Prop Validation Timing
impact: MEDIUM
impactDescription: catches issues early without blocking initial render
tags: err, validation, timing, useIsoLayoutEffect
---

## Prop Validation Timing

Run prop validation in `useIsoLayoutEffect` to catch issues early without blocking the initial render.

**Incorrect (in render body):**

```typescript
function Accordion(props) {
  const { value, defaultValue, disabled } = props

  // Blocks render
  if (value !== undefined && defaultValue !== undefined) {
    warn('Accordion: Providing both value and defaultValue is not supported.')
  }

  return ...
}
```

**Correct (in effect):**

```typescript
import { useIsoLayoutEffect } from '../utils/useIsoLayoutEffect'

function Accordion(props: Accordion.Props) {
  const { value, defaultValue, disabled } = props

  useIsoLayoutEffect(() => {
    if (process.env.NODE_ENV !== 'production') {
      if (value !== undefined && defaultValue !== undefined) {
        warn(
          'Accordion: Providing both value and defaultValue is not supported.',
          'Use value for controlled or defaultValue for uncontrolled, but not both.'
        )
      }
    }
  }, [value, defaultValue])

  return ...
}
```

**useIsoLayoutEffect:**

```typescript
// Works in both SSR and browser environments
export const useIsoLayoutEffect =
  typeof window !== 'undefined' ? React.useLayoutEffect : React.useEffect
```

**When to use:**
- Prop combination validation
- Runtime checks that don't affect render output
- Keeps React strict mode happy
