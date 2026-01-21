---
title: Use useRenderElement for DOM Rendering
impact: CRITICAL
impactDescription: provides consistent render prop support, className callbacks, and state attributes across all components
tags: comp, render, useRenderElement, headless
---

## Use useRenderElement for DOM Rendering

Use the `useRenderElement` hook to handle DOM rendering. This hook provides consistent support for render props, className callbacks, and automatic state attribute mapping.

**Incorrect (manual DOM rendering):**

```typescript
export const Button = React.forwardRef(function Button(props, ref) {
  const { disabled, className, ...rest } = props

  return (
    <button
      {...rest}
      ref={ref}
      className={className}
      disabled={disabled}
      data-disabled={disabled || undefined}
    />
  )
})
```

**Correct (useRenderElement):**

```typescript
export const AccordionTrigger = React.forwardRef(function AccordionTrigger(
  componentProps: AccordionTrigger.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const { render, className, ...elementProps } = componentProps
  const { open, disabled, setOpen, triggerId, panelId } = useAccordionItemContext()

  const state: AccordionTrigger.State = React.useMemo(
    () => ({ open, disabled }),
    [open, disabled]
  )

  return useRenderElement('button', componentProps, {
    state,
    ref: forwardedRef,
    props: [{
      ...elementProps,
      id: triggerId,
      'aria-expanded': open,
      'aria-controls': panelId,
      onClick: () => setOpen(!open),
    }],
    stateAttributesMapping: triggerStateAttributesMapping,
  })
})
```

**When to use:**
- All components that render a DOM element
- Components supporting render props for custom element rendering
- Components that expose state via data-* attributes
