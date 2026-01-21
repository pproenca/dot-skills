---
title: State Attributes Mapping File
impact: MEDIUM
impactDescription: centralizes logic for converting state to data attributes
tags: org, state, attributes, mapping
---

## State Attributes Mapping File

Create `stateAttributesMapping.ts` files to map component state to data attributes. These are used by `useRenderElement`.

**Incorrect (inline mapping):**

```typescript
function AccordionTrigger(props) {
  const { open, disabled } = useAccordionItemContext()

  return (
    <button
      data-open={open || undefined}
      data-disabled={disabled || undefined}
    />
  )
}
```

**Correct (mapping file):**

```typescript
// accordion/trigger/stateAttributesMapping.ts
import type { StateAttributesMapping } from '../../utils/types'
import type { AccordionTrigger } from './AccordionTrigger'

export const accordionTriggerStateAttributesMapping: StateAttributesMapping<AccordionTrigger.State> = {
  open: (state) => state.open || undefined,
  disabled: (state) => state.disabled || undefined,
}

// accordion/trigger/AccordionTrigger.tsx
import { accordionTriggerStateAttributesMapping } from './stateAttributesMapping'

function AccordionTrigger(componentProps: AccordionTrigger.Props) {
  const state = React.useMemo(() => ({ open, disabled }), [open, disabled])

  return useRenderElement('button', componentProps, {
    state,
    stateAttributesMapping: accordionTriggerStateAttributesMapping,
  })
}
```

**When to use:**
- Components using useRenderElement with state attributes
- Keeps mapping logic testable and reusable
