---
title: Context Hook as useComponentContext
impact: HIGH
impactDescription: provides consistent API for accessing context across all components
tags: name, context, hook, use
---

## Context Hook as useComponentContext

Name context consumer hooks as `use[Component]Context` matching the context name.

**Incorrect (anti-pattern):**

```typescript
// Various inconsistent patterns
function useAccordion() {
  return React.useContext(AccordionRootContext)
}

function useAccordionCtx() {
  return React.useContext(AccordionRootContext)
}

function getAccordionContext() {
  return React.useContext(AccordionRootContext)
}
```

**Correct (recommended):**

```typescript
export function useAccordionRootContext(): AccordionRootContextType {
  const context = React.useContext(AccordionRootContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.'
    )
  }
  return context
}

export function useAccordionItemContext(): AccordionItemContextType {
  const context = React.useContext(AccordionItemContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionItemContext is missing. Accordion parts must be placed within <Accordion.Item>.'
    )
  }
  return context
}
```

**When to use:**
- All context consumer hooks
- Hook name = `use` + context name (without `Type` suffix)
