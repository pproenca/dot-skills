---
title: Plain Function for Non-DOM Roots
impact: MEDIUM
impactDescription: avoids unnecessary forwardRef overhead for components that don't render DOM elements
tags: comp, root, function, forwardRef
---

## Plain Function for Non-DOM Roots

Use plain function components (not forwardRef) for Root components that don't render their own DOM element. These components only provide context and orchestration.

**Incorrect (forwardRef for context-only component):**

```typescript
export const DialogRoot = React.forwardRef(function DialogRoot(
  props: DialogRoot.Props,
  ref: React.ForwardedRef<HTMLElement>
) {
  // Component doesn't render a DOM element, ref is unused
  return (
    <DialogRootContext.Provider value={contextValue}>
      {props.children}
    </DialogRootContext.Provider>
  )
})
```

**Correct (plain function):**

```typescript
export function DialogRoot<Payload>(props: DialogRoot.Props<Payload>) {
  const {
    open: openProp,
    defaultOpen = false,
    onOpenChange,
    children,
    ...otherProps
  } = props

  const [open, setOpen] = useControlled({
    controlled: openProp,
    default: defaultOpen,
    name: 'Dialog',
    state: 'open',
  })

  const contextValue = React.useMemo(
    () => ({ open, setOpen }),
    [open, setOpen]
  )

  return (
    <DialogRootContext.Provider value={contextValue}>
      {children}
    </DialogRootContext.Provider>
  )
}
```

**When to use:**
- Root components that only provide context (Dialog.Root, Accordion.Root)
- Components that don't render their own DOM element
- Use forwardRef for components that DO render DOM (Trigger, Panel, etc.)
