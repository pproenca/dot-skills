---
title: Component Naming as ParentPart
impact: CRITICAL
impactDescription: enables predictable API surface and clear component relationships
tags: name, component, PascalCase, compound
---

## Component Naming as ParentPart

Name components as [Parent][Part] using PascalCase. This makes the component hierarchy explicit in the name.

**Incorrect (anti-pattern):**

```typescript
// Generic names lose context
export const Root = React.forwardRef(...)
export const Trigger = React.forwardRef(...)
export const Panel = React.forwardRef(...)

// Usage is ambiguous
<Root>
  <Trigger />
  <Panel />
</Root>
```

**Correct (recommended):**

```typescript
// Full names include parent context
export const AccordionRoot = React.forwardRef(...)
export const AccordionItem = React.forwardRef(...)
export const AccordionTrigger = React.forwardRef(...)
export const AccordionPanel = React.forwardRef(...)

// Clear what each component belongs to
<AccordionRoot>
  <AccordionItem>
    <AccordionTrigger />
    <AccordionPanel />
  </AccordionItem>
</AccordionRoot>

// Re-exported with short aliases for namespaced usage
export { AccordionRoot as Root } from './root/AccordionRoot'
// Allows: <Accordion.Root>
```

**When to use:**
- All component definitions
- Short aliases only in barrel exports for namespace patterns
