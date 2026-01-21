---
title: Name Props Parameter componentProps
impact: HIGH
impactDescription: distinguishes component props from element props after destructuring
tags: comp, props, naming, forwardRef
---

## Name Props Parameter componentProps

Name the props parameter `componentProps` and the ref parameter `forwardedRef` in forwardRef callbacks. This distinguishes between the full component props and the element props that remain after destructuring.

**Incorrect (anti-pattern):**

```typescript
export const Button = React.forwardRef(function Button(props, ref) {
  const { disabled, ...rest } = props
  return <button {...rest} ref={ref} />
})
```

**Correct (recommended):**

```typescript
export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const { render, className, disabled = false, ...elementProps } = componentProps

  return useRenderElement('button', componentProps, {
    ref: forwardedRef,
    props: [elementProps],
  })
})
```

**When to use:**
- All forwardRef component definitions
- Maintains consistency across the codebase
- Makes code review easier by signaling intent
