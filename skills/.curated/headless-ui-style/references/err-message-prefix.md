---
title: Message Prefix Standard
impact: HIGH
impactDescription: makes it easy to identify which library produced an error
tags: err, prefix, messages, standard
---

## Message Prefix Standard

All user-facing error messages and warnings must be prefixed with the library name (e.g., "Base UI:").

**Incorrect (anti-pattern):**

```typescript
throw new Error('Context missing')

console.warn('Invalid prop combination')

throw new Error('useAccordionContext must be used within AccordionRoot')
```

**Correct (recommended):**

```typescript
throw new Error('Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.')

warn('Base UI: Invalid prop combination - disabled and loading cannot both be true.')

throw new Error('Base UI: useTooltip must be used within <Tooltip.Provider>.')
```

**When to use:**
- All thrown errors
- All console warnings
- Any user-facing messages
- Helps developers quickly identify the source of issues
