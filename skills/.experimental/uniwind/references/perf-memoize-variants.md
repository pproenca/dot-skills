---
title: Memoize Variant Style Objects
impact: MEDIUM-HIGH
impactDescription: prevents object recreation on every render
tags: perf, memoization, variants, useMemo
---

## Memoize Variant Style Objects

When using variant mapping objects, define them outside components or memoize them to prevent recreation on every render.

**Incorrect (object recreated every render):**

```tsx
function Button({ variant, children }: ButtonProps) {
  // New object created on every render
  const variants = {
    primary: 'bg-primary text-primary-foreground',
    secondary: 'bg-secondary text-secondary-foreground',
    destructive: 'bg-destructive text-destructive-foreground',
  }

  return (
    <Pressable className={`px-4 py-2 rounded ${variants[variant]}`}>
      <Text>{children}</Text>
    </Pressable>
  )
}
```

**Correct (object defined outside component):**

```tsx
const buttonVariants = {
  primary: 'bg-primary text-primary-foreground',
  secondary: 'bg-secondary text-secondary-foreground',
  destructive: 'bg-destructive text-destructive-foreground',
} as const

function Button({ variant, children }: ButtonProps) {
  return (
    <Pressable className={`px-4 py-2 rounded ${buttonVariants[variant]}`}>
      <Text>{children}</Text>
    </Pressable>
  )
}
```

**Alternative (useMemo for computed variants):**

```tsx
function Button({ variant, size, disabled, children }: ButtonProps) {
  const className = useMemo(() => {
    const base = 'rounded font-medium'
    const variantStyle = buttonVariants[variant]
    const sizeStyle = sizeVariants[size]
    const disabledStyle = disabled ? 'opacity-50' : ''
    return `${base} ${variantStyle} ${sizeStyle} ${disabledStyle}`
  }, [variant, size, disabled])

  return <Pressable className={className}>...</Pressable>
}
```
