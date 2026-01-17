---
title: Dual Barrel Export Pattern
impact: HIGH
impactDescription: enables both namespaced and direct import patterns for flexibility
tags: org, exports, barrel, index
---

## Dual Barrel Export Pattern

Create `index.ts` for type exports and `index.parts.ts` for component exports with short aliases. This enables both `Accordion.Root` and direct `AccordionRoot` imports.

**Incorrect (single index file):**

```typescript
// index.ts - mixed exports
export { AccordionRoot } from './root/AccordionRoot'
export { AccordionTrigger } from './trigger/AccordionTrigger'
export type { AccordionRootProps } from './root/AccordionRoot'
```

**Correct (dual export files):**

```typescript
// index.ts - full component exports and types
export { AccordionRoot } from './root/AccordionRoot'
export { AccordionItem } from './item/AccordionItem'
export { AccordionTrigger } from './trigger/AccordionTrigger'
export { AccordionPanel } from './panel/AccordionPanel'
export { AccordionHeader } from './header/AccordionHeader'

// index.parts.ts - short aliases for namespaced usage
export { AccordionRoot as Root } from './root/AccordionRoot'
export { AccordionItem as Item } from './item/AccordionItem'
export { AccordionTrigger as Trigger } from './trigger/AccordionTrigger'
export { AccordionPanel as Panel } from './panel/AccordionPanel'
export { AccordionHeader as Header } from './header/AccordionHeader'
```

**Usage:**

```typescript
// Direct imports
import { AccordionRoot, AccordionTrigger } from '@base-ui/accordion'

// Namespaced imports
import * as Accordion from '@base-ui/accordion/index.parts'
<Accordion.Root>
  <Accordion.Trigger />
</Accordion.Root>
```

**When to use:**
- All compound components
- Allows consumers to choose their preferred import style
