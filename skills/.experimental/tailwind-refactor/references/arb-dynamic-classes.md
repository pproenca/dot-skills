---
title: Avoid Dynamic Class Name Construction
impact: MEDIUM-HIGH
impactDescription: prevents purge failures, 100% of dynamic classes missed
tags: arb, purge, build, javascript
---

## Avoid Dynamic Class Name Construction

Tailwind scans source files for complete class strings at build time. It does not execute JavaScript, so dynamically constructed class names are invisible to the compiler and 100% of those classes get purged from the production build. This is the single most common cause of "it works in dev but not production" bugs.

**Incorrect (what's wrong):**

```jsx
// Tailwind cannot detect these classes — they WILL be purged
function Badge({ color, size }) {
  return (
    <span className={`bg-${color}-500 text-${size}`}>
      Badge
    </span>
  );
}
```

**Correct (what's right):**

```jsx
// Complete literal strings that Tailwind can scan
const colorMap = {
  red: 'bg-red-500',
  blue: 'bg-blue-500',
  green: 'bg-green-500',
};

const sizeMap = {
  sm: 'text-sm',
  base: 'text-base',
  lg: 'text-lg',
};

function Badge({ color, size }) {
  return (
    <span className={`${colorMap[color]} ${sizeMap[size]}`}>
      Badge
    </span>
  );
}
```

For more complex variant logic, use CVA (Class Variance Authority) or a `cn` helper.
