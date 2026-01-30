---
title: Use Polymorphic 'as' Prop for Flexible Elements
impact: MEDIUM-HIGH
impactDescription: enables component reuse across element types, maintains type safety
tags: comp, polymorphic, as-prop, flexibility, typescript
---

## Use Polymorphic 'as' Prop for Flexible Elements

Components that render a fixed element type limit reuse. The 'as' prop pattern lets consumers choose the underlying element.

**Code Smell Indicators:**
- Wrapper components that render the wrong semantic element
- `<div onClick>` when it should be `<button>`
- Duplicate components: `ButtonLink`, `ButtonDiv`, `ButtonSpan`
- Accessibility issues from wrong element types

**Incorrect (fixed element, wrong semantics):**

```tsx
function Card({ onClick, children }) {
  // Always a div, even when it's clickable (should be button)
  // or a link (should be anchor)
  return (
    <div className="card" onClick={onClick}>
      {children}
    </div>
  )
}

// Usage forces bad accessibility
<Card onClick={handleClick}> {/* div with onClick = bad a11y */}

// Duplicating components is wasteful
function CardButton({ onClick, children }) { /*...*/ }
function CardLink({ href, children }) { /*...*/ }
```

**Correct (polymorphic as prop):**

```tsx
type AsProp<C extends React.ElementType> = {
  as?: C
}

type PropsToOmit<C extends React.ElementType, P> = keyof (AsProp<C> & P)

type PolymorphicComponentProps<
  C extends React.ElementType,
  Props = {}
> = React.PropsWithChildren<Props & AsProp<C>> &
  Omit<React.ComponentPropsWithoutRef<C>, PropsToOmit<C, Props>>

type CardProps<C extends React.ElementType = 'div'> = PolymorphicComponentProps<
  C,
  { variant?: 'elevated' | 'outlined' }
>

function Card<C extends React.ElementType = 'div'>({
  as,
  variant = 'elevated',
  children,
  className,
  ...props
}: CardProps<C>) {
  const Component = as || 'div'

  return (
    <Component className={cn('card', `card-${variant}`, className)} {...props}>
      {children}
    </Component>
  )
}

// Usage - correct semantics, full type safety
<Card as="button" onClick={handleClick}>Clickable card</Card>
<Card as="a" href="/details">Link card</Card>
<Card as={Link} to="/details">Router link card</Card>
<Card>Default div card</Card>
```

**Simplified version without full type inference:**

```tsx
interface CardProps {
  as?: React.ElementType
  variant?: 'elevated' | 'outlined'
  children: React.ReactNode
  className?: string
  [key: string]: unknown // Allow any other props
}

function Card({ as: Component = 'div', variant = 'elevated', children, className, ...props }: CardProps) {
  return (
    <Component className={cn('card', `card-${variant}`, className)} {...props}>
      {children}
    </Component>
  )
}
```

**When to use polymorphic components:**
- Semantic element varies by use case (div/button/a)
- Component is a primitive building block
- You'd otherwise create CardDiv, CardButton, CardLink variants

**When NOT to use:**
- Component has complex behavior tied to element type
- The element type is truly fixed (e.g., form elements)
- Simpler explicit variants would be clearer

Reference: [Build strongly typed polymorphic components](https://blog.logrocket.com/build-strongly-typed-polymorphic-components-react-typescript/)
