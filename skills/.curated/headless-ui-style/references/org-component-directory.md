---
title: Component Directory Structure
impact: CRITICAL
impactDescription: enables scalable compound component organization with clear part boundaries
tags: org, directory, structure, compound
---

## Component Directory Structure

Organize compound components with a top-level directory containing sub-directories for each part (root, trigger, panel, etc.).

**Incorrect (flat structure):**

```text
accordion/
  AccordionRoot.tsx
  AccordionTrigger.tsx
  AccordionPanel.tsx
  AccordionItem.tsx
  AccordionRootContext.ts
  AccordionItemContext.ts
  index.ts
```

**Correct (nested structure):**

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRootContext.ts
  item/
    AccordionItem.tsx
    AccordionItemContext.ts
  trigger/
    AccordionTrigger.tsx
    stateAttributesMapping.ts
  panel/
    AccordionPanel.tsx
    AccordionPanelCssVars.ts
  header/
    AccordionHeader.tsx
  index.ts
  index.parts.ts
  DataAttributes.ts
```

**When to use:**
- All compound components with multiple parts
- Each part with its own logic, context, or styling concerns
- Keeps related files co-located
