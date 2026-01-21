---
title: File Name Matches Primary Export
impact: HIGH
impactDescription: enables quick file discovery and consistent import paths
tags: name, file, export, consistency
---

## File Name Matches Primary Export

File name must exactly match the primary export name using PascalCase.

**Incorrect (anti-pattern):**

```typescript
// accordion-root.tsx
export const AccordionRoot = React.forwardRef(...)

// trigger.tsx
export const AccordionTrigger = React.forwardRef(...)

// index.tsx
export const Panel = React.forwardRef(...)
```

**Correct (recommended):**

```typescript
// AccordionRoot.tsx
export const AccordionRoot = React.forwardRef(...)

// AccordionTrigger.tsx
export const AccordionTrigger = React.forwardRef(...)

// AccordionPanel.tsx
export const AccordionPanel = React.forwardRef(...)
```

**When to use:**
- All component files
- All hook files (useButton.ts exports useButton)
- Makes imports predictable: `import { AccordionRoot } from './AccordionRoot'`
