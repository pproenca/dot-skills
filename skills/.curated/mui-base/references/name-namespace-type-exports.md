---
title: Namespace Type Exports
impact: CRITICAL
impactDescription: provides clean API surface with Component.Props and Component.State patterns
tags: name, namespace, types, export
---

## Namespace Type Exports

Use TypeScript namespaces to export State, Props, and event types from components. This enables the `Component.Props` and `Component.State` access pattern.

**Incorrect (separate exports):**

```typescript
export interface AccordionRootProps { ... }
export interface AccordionRootState { ... }
export type { AccordionRootProps as Props }

// Usage requires knowing internal names
import type { AccordionRootProps } from './AccordionRoot'
```

**Correct (namespace exports):**

```typescript
interface AccordionRootProps { ... }
interface AccordionRootState { ... }

export const AccordionRoot = React.forwardRef(function AccordionRoot(...) { ... })

export namespace AccordionRoot {
  export type Props = AccordionRootProps
  export type State = AccordionRootState
}

// Clean usage pattern
import { AccordionRoot } from './AccordionRoot'

function MyComponent(props: AccordionRoot.Props) {
  const renderTrigger = (state: AccordionTrigger.State) => (
    <button data-open={state.open}>Toggle</button>
  )
}
```

**When to use:**
- All exported components
- Enables IDE autocomplete for `Component.` types
