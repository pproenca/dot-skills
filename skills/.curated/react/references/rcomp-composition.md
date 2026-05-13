---
title: When prop count climbs past ~6 with many optional slots, take `children` instead and let callers compose
impact: LOW-MEDIUM
impactDescription: collapses configuration-prop explosion into composition; each sub-component does one thing, callers control assembly
tags: rcomp, composition, prop-explosion, children-slot
---

## When prop count climbs past ~6 with many optional slots, take `children` instead and let callers compose

**Pattern intent:** a component with 8–15 optional configuration props is a sign that the abstraction is doing too much. The fix is usually to break it into pieces and let callers compose. The component's job becomes "give callers a frame to assemble inside," not "enumerate every variant by prop."

### Shapes to recognize

- A `<Card title subtitle icon actions footer headerBg bodyPadding showBorder ...>` API — 8+ optional props, most calls use 3.
- A `<Modal>` accepting `headerContent`, `bodyContent`, `footerContent` as separate ReactNode props — should be one `children` slot or named slots.
- A `<Layout>` accepting `topbar`, `sidebar`, `main`, `footer` as opaque props — better as named slots so each can independently be a Server Component (also helps with [`rsc-composition-pattern.md`](rsc-composition-pattern.md)).
- A wrapper that exists only to pre-fill 80% of a more general component's props — could be a thin compositional pattern instead.
- A boolean prop named `variant` / `mode` / `kind` that toggles three structural variants of the layout — usually a sign the variants want to be three distinct compositions.

The canonical resolution: extract sub-components for each section (`<CardHeader>`, `<CardBody>`, `<CardFooter>`); the outer component accepts `children` and provides only the cross-cutting shell (border, spacing). Each sub-component is single-purpose; callers compose freely. Note: with React Compiler v1.0, you don't need to worry as much about the prop-explosion render cost — but the *readability* and *flexibility* gain from composition still applies.

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
