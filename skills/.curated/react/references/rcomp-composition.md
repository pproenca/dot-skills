---
title: Prefer Composition Over Props Explosion
impact: LOW-MEDIUM
impactDescription: more flexible, reusable components
tags: comp, composition, children, flexibility
---

## Prefer Composition Over Props Explosion

Instead of passing many configuration props, accept children or render props. This makes components more flexible and reusable.

**Incorrect (props explosion):**

```typescript
function Card({
  title,
  subtitle,
  icon,
  actions,
  footer,
  headerBg,
  bodyPadding,
  showBorder
}: CardProps) {
  return (
    <div className={showBorder ? 'border' : ''}>
      <header style={{ background: headerBg }}>
        {icon}
        <h2>{title}</h2>
        <span>{subtitle}</span>
        {actions}
      </header>
      <div style={{ padding: bodyPadding }}>
        {/* Where's the content? */}
      </div>
      {footer}
    </div>
  )
}
// Hard to extend, many optional props
```

**Correct (composition with children):**

```typescript
function Card({ children }: { children: ReactNode }) {
  return <div className="card">{children}</div>
}

function CardHeader({ children }: { children: ReactNode }) {
  return <header className="card-header">{children}</header>
}

function CardBody({ children }: { children: ReactNode }) {
  return <div className="card-body">{children}</div>
}

// Usage - flexible composition
<Card>
  <CardHeader>
    <Icon name="user" />
    <h2>User Profile</h2>
    <Button>Edit</Button>
  </CardHeader>
  <CardBody>
    <ProfileForm />
  </CardBody>
</Card>
```

**Benefits:**
- Each component has single responsibility
- Easy to add new variants
- TypeScript infers children correctly
- No prop drilling through layers
