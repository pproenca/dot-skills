---
title: State Interface as ComponentState
impact: HIGH
impactDescription: enables consistent state type access for render props and styling
tags: name, state, interface, types
---

## State Interface as ComponentState

Name state interfaces as `[Component]State` with the full component name.

**Incorrect (anti-pattern):**

```typescript
interface AccordionRootData {
  expanded: boolean
}

interface RootState {
  value: string[]
}

interface State {
  open: boolean
  disabled: boolean
}
```

**Correct (recommended):**

```typescript
interface AccordionTriggerState {
  open: boolean
  disabled: boolean
}

interface AccordionPanelState {
  open: boolean
  hidden: boolean
}

// Usage in component
const state: AccordionTrigger.State = React.useMemo(
  () => ({ open, disabled }),
  [open, disabled]
)
```

**When to use:**
- All component state type definitions
- State is exposed via render props and data-* attributes
- Export via namespace: `export namespace AccordionTrigger { export type State = AccordionTriggerState }`
