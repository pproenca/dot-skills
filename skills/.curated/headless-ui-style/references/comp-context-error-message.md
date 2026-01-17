---
title: Context Error Messages with Hierarchy
impact: HIGH
impactDescription: helps developers quickly fix component structure issues with clear guidance
tags: comp, context, error, hierarchy
---

## Context Error Messages with Hierarchy

Context error messages must specify the required component relationship and which component provides the context.

**Incorrect (vague error):**

```typescript
function useAccordionRootContext() {
  const context = React.useContext(AccordionRootContext)
  if (!context) {
    throw new Error('Context is missing')
  }
  return context
}
```

**Correct (descriptive error with hierarchy):**

```typescript
function useAccordionRootContext(): AccordionRootContextType {
  const context = React.useContext(AccordionRootContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.'
    )
  }
  return context
}

function useAccordionItemContext(): AccordionItemContextType {
  const context = React.useContext(AccordionItemContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionItemContext is missing. AccordionItem parts must be placed within <Accordion.Item>.'
    )
  }
  return context
}
```

**When to use:**
- All context consumer hooks
- Error messages should include: library prefix, context name, and required parent component
