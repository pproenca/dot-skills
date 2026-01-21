---
title: Part Directory Naming lowercase
impact: MEDIUM
impactDescription: distinguishes part directories from component directories at a glance
tags: name, directory, lowercase, parts
---

## Part Directory Naming lowercase

Use lowercase single words for component part directories within a compound component.

**Incorrect (anti-pattern):**

```text
accordion/
  Root/
    AccordionRoot.tsx
  trigger-button/
    AccordionTrigger.tsx
  PanelContent/
    AccordionPanel.tsx
```

**Correct (recommended):**

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRootContext.ts
  trigger/
    AccordionTrigger.tsx
  panel/
    AccordionPanel.tsx
  item/
    AccordionItem.tsx
```

**When to use:**
- All part directories within a compound component
- Keeps filesystem simple and scannable
- Part names should be single words when possible
