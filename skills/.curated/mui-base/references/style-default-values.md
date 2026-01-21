---
title: Default Values in Destructuring
impact: MEDIUM
impactDescription: keeps default values close to usage and visible in one place
tags: style, defaults, destructuring, props
---

## Default Values in Destructuring

Provide default values in destructuring, not in prop types or separate statements.

**Incorrect (defaults elsewhere):**

```typescript
interface ButtonProps {
  disabled: boolean  // default in component
  type: 'button' | 'submit' | 'reset'  // default in component
}

function Button(componentProps: ButtonProps) {
  const { disabled, type, ...rest } = componentProps
  const actualDisabled = disabled ?? false
  const actualType = type ?? 'button'
}
```

**Correct (defaults in destructuring):**

```typescript
interface ButtonProps {
  disabled?: boolean | undefined
  type?: 'button' | 'submit' | 'reset' | undefined
}

function Button(componentProps: ButtonProps) {
  const {
    render,
    className,
    disabled = false,
    type = 'button',
    ...elementProps
  } = componentProps

  // disabled and type are guaranteed to have values
}
```

**When to use:**
- All optional props with sensible defaults
- Keeps default values visible at the component's entry point
- Makes prop documentation accurate (optional means truly optional)
