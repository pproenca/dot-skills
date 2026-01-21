---
title: Handler Naming Convention
impact: MEDIUM
impactDescription: clearly distinguishes internal handlers from callback props
tags: name, handlers, events, convention
---

## Handler Naming Convention

Name event handlers with `handle` prefix for internal handlers and `on` prefix for callback props.

**Incorrect (anti-pattern):**

```typescript
interface Props {
  // Inconsistent naming
  clickHandler?: () => void
  triggerClick?: () => void
  handleValueChange?: (value: string[]) => void
}

function AccordionTrigger(props) {
  // Internal handler without prefix
  const clickTrigger = () => { ... }
  const toggle = () => { ... }
}
```

**Correct (recommended):**

```typescript
interface AccordionRootProps {
  // Callback props use "on" prefix
  onValueChange?: (value: string[], details: ChangeEventDetails) => void
  onOpenChange?: (open: boolean) => void
}

function AccordionTrigger(componentProps: AccordionTrigger.Props) {
  const { setOpen, open } = useAccordionItemContext()

  // Internal handlers use "handle" prefix
  const handleClick = React.useCallback(() => {
    setOpen(!open)
  }, [setOpen, open])

  const handleKeyDown = React.useCallback((event: React.KeyboardEvent) => {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault()
      setOpen(!open)
    }
  }, [setOpen, open])

  return useRenderElement('button', componentProps, {
    props: [{
      onClick: handleClick,
      onKeyDown: handleKeyDown,
    }],
  })
}
```

**When to use:**
- `handle*` for functions defined inside components
- `on*` for props that accept callbacks
