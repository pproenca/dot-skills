---
title: Package-Level Wildcard Exports
impact: HIGH
impactDescription: simplifies main entry point and ensures all components are exported
tags: org, exports, package, barrel
---

## Package-Level Wildcard Exports

Main package `index.ts` should use wildcard exports for each component module rather than explicit named exports.

**Incorrect (explicit exports):**

```typescript
// src/index.ts
export { Accordion } from './accordion'
export { AccordionRoot, AccordionTrigger } from './accordion'
export { Dialog } from './dialog'
export { DialogRoot, DialogTrigger } from './dialog'
// Easy to forget exports when adding new components
```

**Correct (wildcard exports):**

```typescript
// src/index.ts
export * from './accordion'
export * from './alert-dialog'
export * from './checkbox'
export * from './collapsible'
export * from './dialog'
export * from './menu'
export * from './popover'
export * from './progress'
export * from './radio'
export * from './select'
export * from './separator'
export * from './slider'
export * from './switch'
export * from './tabs'
export * from './toast'
export * from './toggle'
export * from './toggle-group'
export * from './tooltip'
```

**When to use:**
- Main package entry point (src/index.ts)
- Ensures new exports from component modules are automatically available
- Reduces maintenance burden
