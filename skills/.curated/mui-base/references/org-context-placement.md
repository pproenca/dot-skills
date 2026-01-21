---
title: Context File Placement
impact: MEDIUM
impactDescription: keeps context definitions close to providing components
tags: org, context, colocation, files
---

## Context File Placement

Place context files in the same directory as the component that provides them.

**Incorrect (centralized contexts):**

```text
contexts/
  AccordionRootContext.ts
  AccordionItemContext.ts
  DialogContext.ts
accordion/
  AccordionRoot.tsx
  AccordionItem.tsx
```

**Correct (co-located contexts):**

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRootContext.ts
  item/
    AccordionItem.tsx
    AccordionItemContext.ts
```

**When to use:**
- All component contexts
- Context and provider are tightly coupled, should live together
- Makes it clear which component owns the context
