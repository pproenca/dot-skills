---
title: Avoid Untyped Props Spreading
impact: HIGH
impactDescription: prevents prop collision bugs, improves TypeScript inference
tags: comp, props-spreading, typescript, type-safety, api-design
---

## Avoid Untyped Props Spreading

Spreading unknown props hides component APIs and creates collision bugs. Be explicit about which props are forwarded.

**Code Smell Indicators:**
- `...props` or `...rest` spread onto elements
- TypeScript errors about incompatible props
- Props intended for wrapper applied to inner element
- Debugging "where did this prop come from?"

**Incorrect (spreading hides API and causes bugs):**

```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
}

function Button({ variant = 'primary', size = 'md', ...props }: ButtonProps & React.HTMLAttributes<HTMLButtonElement>) {
  return (
    <button className={`btn-${variant} btn-${size}`} {...props}>
      {props.children}
    </button>
  )
}

// Problem 1: className collision
<Button variant="primary" className="custom"> {/* custom overwrites btn-primary! */}

// Problem 2: Unintended props forwarded
<Button variant="primary" formAction="/api/submit"> {/* formAction goes to <button>? */}

// Problem 3: TypeScript doesn't catch typos
<Button varient="primary"> {/* typo becomes HTML attribute */}
```

**Correct (explicit prop handling):**

```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
  className?: string
  children: React.ReactNode
  onClick?: React.MouseEventHandler<HTMLButtonElement>
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
}

function Button({
  variant = 'primary',
  size = 'md',
  className,
  children,
  onClick,
  disabled,
  type = 'button',
}: ButtonProps) {
  return (
    <button
      type={type}
      className={cn(`btn-${variant} btn-${size}`, className)}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  )
}

// Clear API, TypeScript catches typos, no collision bugs
<Button variant="primary" className="custom">Click</Button>
```

**When props forwarding is needed (use ComponentPropsWithRef):**

```tsx
interface InputProps extends Omit<React.ComponentPropsWithRef<'input'>, 'size'> {
  label: string
  size?: 'sm' | 'md' | 'lg' // Our size, not HTML size
  error?: string
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, size = 'md', error, className, ...inputProps }, ref) => {
    // Explicitly forward only input-appropriate props
    return (
      <div className={`input-wrapper input-${size}`}>
        <label>{label}</label>
        <input
          ref={ref}
          className={cn('input', error && 'input-error', className)}
          {...inputProps}
        />
        {error && <span className="error">{error}</span>}
      </div>
    )
  }
)
```

**Pattern: Explicit prop groups:**

```tsx
interface CardProps {
  // Card-specific props
  variant?: 'elevated' | 'outlined'
  padding?: 'none' | 'sm' | 'md' | 'lg'

  // Explicitly forwarded
  className?: string
  style?: React.CSSProperties
  onClick?: React.MouseEventHandler<HTMLDivElement>
  role?: string
  'aria-label'?: string

  children: React.ReactNode
}

// Each prop is documented, typed, and intentional
```

**Decision framework:**
```
Should this prop be forwarded?
├── It's for the wrapper element → Explicit prop
├── It's for the inner element → Explicit prop on inner
├── User might need any HTML attr → ComponentPropsWithRef + Omit collisions
└── Unsure → Don't forward it
```

Reference: [TypeScript and React](https://react.dev/learn/typescript)
