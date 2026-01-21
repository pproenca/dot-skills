---
title: Memoize Context Provider Values
impact: HIGH
impactDescription: prevents all context consumers from re-rendering when provider re-renders
tags: comp, context, memoization, useMemo
---

## Memoize Context Provider Values

Always memoize context provider values to prevent unnecessary re-renders of all consumers when the provider component re-renders.

**Incorrect (new value object every render):**

```typescript
function AccordionRoot({ children, value, setValue, disabled }) {
  return (
    <AccordionRootContext.Provider value={{ value, setValue, disabled }}>
      {children}
    </AccordionRootContext.Provider>
  )
}
// All consumers re-render on any AccordionRoot re-render
```

**Correct (memoized context value):**

```typescript
function AccordionRoot(props: AccordionRoot.Props) {
  const { children, value, onValueChange, disabled = false } = props

  const [valueState, setValueState] = useControlled({
    controlled: value,
    default: [],
    name: 'Accordion',
    state: 'value',
  })

  const contextValue = React.useMemo(
    () => ({
      value: valueState,
      setValue: setValueState,
      disabled,
    }),
    [valueState, setValueState, disabled]
  )

  return (
    <AccordionRootContext.Provider value={contextValue}>
      {children}
    </AccordionRootContext.Provider>
  )
}
```

**When to use:**
- All context provider components
- Any object passed to Context.Provider value prop
