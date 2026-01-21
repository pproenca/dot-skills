---
title: Context Naming with Suffix
impact: HIGH
impactDescription: makes context purpose clear and distinguishes from components
tags: name, context, suffix, types
---

## Context Naming with Suffix

Name context types and files with `Context` suffix. Include the full component path for clarity.

**Incorrect (anti-pattern):**

```typescript
// AccordionCtx.ts
interface AccordionCtx { ... }
const AccordionCtx = React.createContext<AccordionCtx | undefined>(undefined)

// AccordionState.ts
interface AccordionState { ... }
const AccordionState = React.createContext<AccordionState | undefined>(undefined)
```

**Correct (recommended):**

```typescript
// AccordionRootContext.ts
interface AccordionRootContextType {
  value: string[]
  setValue: (value: string[]) => void
  disabled: boolean
}

const AccordionRootContext = React.createContext<AccordionRootContextType | undefined>(undefined)

// AccordionItemContext.ts
interface AccordionItemContextType {
  open: boolean
  setOpen: (open: boolean) => void
  triggerId: string
  panelId: string
}

const AccordionItemContext = React.createContext<AccordionItemContextType | undefined>(undefined)
```

**When to use:**
- All context definitions
- File name matches context name: `AccordionRootContext.ts`
