---
title: Data Attribute Naming lowercase
impact: HIGH
impactDescription: provides consistent attribute names for CSS selectors and testing
tags: name, data-attributes, lowercase, state
---

## Data Attribute Naming lowercase

Use lowercase data-* attributes derived from state keys. These attributes enable CSS-based styling without JavaScript.

**Incorrect (anti-pattern):**

```typescript
// Inconsistent naming
<button
  data-isOpen={open}
  data-accordion-disabled={disabled}
  data-EXPANDED={expanded}
/>
```

**Correct (recommended):**

```typescript
// Consistent lowercase naming
<button
  data-open={open || undefined}
  data-disabled={disabled || undefined}
  data-expanded={expanded || undefined}
/>

// Document in DataAttributes.ts
export enum AccordionItemDataAttributes {
  index = 'data-index',
  disabled = 'data-disabled',
  open = 'data-open',
}
```

**CSS usage:**

```css
[data-open] {
  /* styles when open */
}

[data-disabled] {
  opacity: 0.5;
  pointer-events: none;
}
```

**When to use:**
- All boolean state exposed to consumers
- Only render attribute when true (use `value || undefined`)
