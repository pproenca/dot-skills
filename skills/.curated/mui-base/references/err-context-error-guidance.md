---
title: Context Error Guidance
impact: HIGH
impactDescription: helps developers fix component hierarchy issues quickly
tags: err, context, error, hierarchy
---

## Context Error Guidance

Context errors must explain the required component hierarchy, not just state that the context is missing.

**Incorrect (anti-pattern):**

```typescript
function useAccordionRootContext() {
  const context = React.useContext(AccordionRootContext)
  if (!context) {
    throw new Error('Base UI: useAccordionRootContext must be used within a provider')
  }
  return context
}
```

**Correct (recommended):**

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

function useDialogPopupContext(): DialogPopupContextType {
  const context = React.useContext(DialogPopupContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: DialogPopupContext is missing. Dialog.Popup must be placed within <Dialog.Root>.'
    )
  }
  return context
}
```

**When to use:**
- All context consumer hooks
- Include: library prefix, which context is missing, which component to wrap with
