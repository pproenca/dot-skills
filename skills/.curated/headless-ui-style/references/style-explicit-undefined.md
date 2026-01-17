---
title: Explicit Undefined in Prop Types
impact: MEDIUM
impactDescription: makes optional prop handling explicit and improves type inference
tags: style, types, undefined, props
---

## Explicit Undefined in Prop Types

Include `| undefined` in optional prop types for clarity. This makes it explicit that the prop can be omitted.

**Incorrect (anti-pattern):**

```typescript
interface ButtonProps {
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
  onClick?: () => void
}
```

**Correct (recommended):**

```typescript
interface ButtonProps {
  disabled?: boolean | undefined
  type?: 'button' | 'submit' | 'reset' | undefined
  onClick?: (() => void) | undefined
}

interface AccordionRootProps {
  value?: string[] | undefined
  defaultValue?: string[] | undefined
  onValueChange?: ((value: string[]) => void) | undefined
  disabled?: boolean | undefined
  children?: React.ReactNode
}
```

**When to use:**
- All optional props in interface definitions
- Makes `exactOptionalPropertyTypes` TypeScript config work correctly
