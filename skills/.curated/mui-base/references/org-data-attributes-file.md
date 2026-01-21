---
title: Data Attributes Documentation File
impact: MEDIUM
impactDescription: provides single source of truth for data attribute names
tags: org, data-attributes, documentation
---

## Data Attributes Documentation File

Create dedicated `DataAttributes.ts` files with enums documenting each `data-*` attribute a component exposes.

**Incorrect (inline documentation):**

```typescript
// Scattered across component files
// AccordionTrigger.tsx
<button data-open={open} data-disabled={disabled} />

// No central documentation of what attributes exist
```

**Correct (dedicated file):**

```typescript
// accordion/DataAttributes.ts
export enum AccordionRootDataAttributes {
  /**
   * Present when the accordion is disabled.
   */
  disabled = 'data-disabled',
}

export enum AccordionItemDataAttributes {
  /**
   * The index of the item in the accordion.
   */
  index = 'data-index',
  /**
   * Present when the item is disabled.
   */
  disabled = 'data-disabled',
  /**
   * Present when the item is expanded/open.
   */
  open = 'data-open',
}

export enum AccordionTriggerDataAttributes {
  /**
   * Present when the panel controlled by this trigger is open.
   */
  open = 'data-open',
  /**
   * Present when the trigger is disabled.
   */
  disabled = 'data-disabled',
}
```

**When to use:**
- All compound components with data attributes
- Serves as documentation for consumers
- Enables type-safe attribute references
