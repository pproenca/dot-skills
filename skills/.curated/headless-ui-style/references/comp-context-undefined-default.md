---
title: Create Context with Undefined Default
impact: HIGH
impactDescription: ensures consumers get clear error messages when used outside provider instead of silent failures
tags: comp, context, provider, error-handling
---

## Create Context with Undefined Default

Create React contexts with `undefined` as the default value instead of an empty object or dummy values. Provide a custom hook that throws a descriptive error when the context is missing.

**Incorrect (empty object default):**

```typescript
interface AccordionContextType {
  value: string[]
  setValue: (value: string[]) => void
}

const AccordionContext = React.createContext<AccordionContextType>({} as AccordionContextType)

// Consumer silently gets undefined behavior
function useAccordion() {
  return React.useContext(AccordionContext)
}
```

**Correct (undefined default with throwing hook):**

```typescript
interface AccordionRootContextType {
  value: string[]
  setValue: (value: string[]) => void
  disabled: boolean
}

const AccordionRootContext = React.createContext<AccordionRootContextType | undefined>(undefined)

export function useAccordionRootContext(): AccordionRootContextType {
  const context = React.useContext(AccordionRootContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.'
    )
  }
  return context
}
```

**When to use:**
- All component contexts in compound component patterns
- Any context that requires a provider to function correctly
- Contexts where missing provider would cause runtime errors
