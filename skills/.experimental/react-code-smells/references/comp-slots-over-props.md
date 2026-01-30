---
title: Use Slots/Children Instead of Configuration Props
impact: CRITICAL
impactDescription: increases flexibility 3×, removes component modification for new use cases
tags: comp, slots, children, composition, flexibility
---

## Use Slots/Children Instead of Configuration Props

Components that accept content as configuration props become rigid. Use children/slots to accept composed elements instead.

**Code Smell Indicators:**
- Props like `title`, `subtitle`, `icon`, `leftElement`, `rightElement`
- Component has 10+ props for content variations
- New use case requires adding another prop
- Props for "is there a header?" combined with "what's in the header?"

**Incorrect (configuration props explosion):**

```tsx
interface CardProps {
  title: string
  titleSize?: 'sm' | 'md' | 'lg'
  subtitle?: string
  icon?: IconName
  iconPosition?: 'left' | 'right'
  headerAction?: () => void
  headerActionLabel?: string
  footer?: string
  footerAlign?: 'left' | 'center' | 'right'
  children: React.ReactNode
}

function Card({
  title, titleSize = 'md', subtitle, icon, iconPosition = 'left',
  headerAction, headerActionLabel, footer, footerAlign = 'left', children
}: CardProps) {
  return (
    <div className="card">
      <div className="card-header">
        {icon && iconPosition === 'left' && <Icon name={icon} />}
        <div>
          <h3 className={`title-${titleSize}`}>{title}</h3>
          {subtitle && <p className="subtitle">{subtitle}</p>}
        </div>
        {icon && iconPosition === 'right' && <Icon name={icon} />}
        {headerAction && (
          <button onClick={headerAction}>{headerActionLabel}</button>
        )}
      </div>
      <div className="card-body">{children}</div>
      {footer && <div className={`card-footer text-${footerAlign}`}>{footer}</div>}
    </div>
  )
}
```

**Correct (slots/composition pattern):**

```tsx
interface CardProps {
  children: React.ReactNode
}

function Card({ children }: CardProps) {
  return <div className="card">{children}</div>
}

function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="card-header">{children}</div>
}

function CardBody({ children }: { children: React.ReactNode }) {
  return <div className="card-body">{children}</div>
}

function CardFooter({ children, align = 'left' }: { children: React.ReactNode, align?: 'left' | 'center' | 'right' }) {
  return <div className={`card-footer text-${align}`}>{children}</div>
}

Card.Header = CardHeader
Card.Body = CardBody
Card.Footer = CardFooter

// Usage - infinitely flexible without modifying Card
<Card>
  <Card.Header>
    <Icon name="star" />
    <div>
      <h3>Custom Title</h3>
      <Badge>New</Badge>
    </div>
    <DropdownMenu />
  </Card.Header>
  <Card.Body>
    <ComplexContent />
  </Card.Body>
  <Card.Footer align="center">
    <Button>Action 1</Button>
    <Button>Action 2</Button>
  </Card.Footer>
</Card>
```

**Benefits:**
- New use cases don't require component changes
- Full control over composition
- TypeScript validates structure
- Self-documenting usage

**When configuration props are OK:**
- Small, fixed set of variations (variant='primary' | 'secondary')
- Boolean toggles (disabled, loading)
- Simple styling props (size, color)

**Transformation heuristic:**
```
For each content prop, ask:
├── Will users need to customize this? → Slot
├── Is this always the same structure? → Prop
└── Does it combine boolean + content? → Split into slot
```

Reference: [Passing JSX as children](https://react.dev/learn/passing-props-to-a-component#passing-jsx-as-children)
