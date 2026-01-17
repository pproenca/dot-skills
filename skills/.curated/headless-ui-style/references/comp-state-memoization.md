---
title: Memoize State Objects
impact: HIGH
impactDescription: prevents unnecessary re-renders when passing state to render props and child components
tags: comp, state, memoization, useMemo
---

## Memoize State Objects

Create a memoized state object for render props and context values. This prevents new object references on every render.

**Incorrect (new object every render):**

```typescript
function AccordionTrigger(props) {
  const { open, disabled } = useAccordionItemContext()

  return useRenderElement('button', props, {
    // New object created every render
    state: { open, disabled },
  })
}
```

**Correct (memoized state object):**

```typescript
function AccordionTrigger(componentProps: AccordionTrigger.Props) {
  const { open, disabled, setOpen } = useAccordionItemContext()

  const state: AccordionTrigger.State = React.useMemo(
    () => ({ open, disabled }),
    [open, disabled]
  )

  return useRenderElement('button', componentProps, {
    state,
    ref: forwardedRef,
    props: [elementProps],
    stateAttributesMapping,
  })
}
```

**When to use:**
- All components exposing state via render props
- State objects passed to useRenderElement
- State values provided through context
