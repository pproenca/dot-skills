---
title: Use forwardRef with Named Function
impact: CRITICAL
impactDescription: improves debugging with meaningful stack traces and component names in React DevTools
tags: comp, forwardRef, debugging, devtools
---

## Use forwardRef with Named Function

Use React.forwardRef with a named function callback instead of an arrow function. This provides better debugging experience with meaningful component names in stack traces and React DevTools.

**Incorrect (anonymous function):**

```typescript
export const Button = React.forwardRef((props, ref) => {
  return <button {...props} ref={ref} />
})
// DevTools shows: ForwardRef or Anonymous
```

**Correct (named function):**

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
// DevTools shows: Button
```

**When to use:**
- All components that need to expose a ref to parent components
- Components that render DOM elements directly
- Child components in compound component patterns
