---
title: Props Destructuring Order
impact: MEDIUM
impactDescription: maintains consistent code structure across components for easier review
tags: comp, props, destructuring, consistency
---

## Props Destructuring Order

Destructure props in a consistent order: render, className, component-specific props with defaults, then rest spread to elementProps.

**Incorrect (inconsistent ordering):**

```typescript
function AccordionTrigger(componentProps) {
  const { disabled, render, className, onClick, ...rest } = componentProps
  // ...
}
```

**Correct (consistent ordering):**

```typescript
function AccordionTrigger(componentProps: AccordionTrigger.Props) {
  const {
    // 1. Render-related props
    render,
    className,
    // 2. Component-specific props with defaults
    disabled = false,
    // 3. Rest spread to elementProps
    ...elementProps
  } = componentProps

  // ...
}
```

**When to use:**
- All component definitions
- Helps maintain consistency during code review
- Makes it clear which props are consumed vs passed through
