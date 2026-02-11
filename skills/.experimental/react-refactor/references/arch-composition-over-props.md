---
title: Prefer Composition Over Props Explosion
impact: CRITICAL
impactDescription: reduces prop count by 50-70%, enables independent extension
tags: arch, composition, children, slots, extensibility
---

## Prefer Composition Over Props Explosion

Components with 15+ configuration props become rigid — every new use case requires a new prop. Composition with children and slot props inverts control to the consumer, enabling extension without modifying the component source.

**Incorrect (config props — rigid and growing):**

```tsx
interface CardProps {
  title: string;
  subtitle?: string;
  headerIcon?: React.ReactNode;
  headerAction?: React.ReactNode;
  footer?: React.ReactNode;
  footerAlign?: "left" | "center" | "right";
  bordered?: boolean;
  elevated?: boolean;
  collapsible?: boolean;
  defaultCollapsed?: boolean;
  onCollapse?: (collapsed: boolean) => void;
  padding?: "none" | "sm" | "md" | "lg";
  className?: string;
}

// 13 props — adding "badge on header" means prop #14
function Card({ title, subtitle, headerIcon, headerAction, bordered, elevated, ...rest }: CardProps) {
  return (
    <div className={clsx("card", bordered && "card--bordered", elevated && "card--elevated")}>
      <div className="card__header">
        {headerIcon && <span className="card__icon">{headerIcon}</span>}
        <div>
          <h3>{title}</h3>
          {subtitle && <p>{subtitle}</p>}
        </div>
        {headerAction}
      </div>
      <div className="card__body">{rest.children}</div>
      {rest.footer && <div className="card__footer">{rest.footer}</div>}
    </div>
  );
}
```

**Correct (composition — consumer controls layout):**

```tsx
interface CardProps {
  children: React.ReactNode;
  variant?: "bordered" | "elevated" | "flat";
  padding?: "none" | "sm" | "md" | "lg";
}

function Card({ children, variant = "flat", padding = "md" }: CardProps) {
  return <div className={clsx("card", `card--${variant}`, `card--pad-${padding}`)}>{children}</div>;
}

function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="card__header">{children}</div>;
}

function CardBody({ children }: { children: React.ReactNode }) {
  return <div className="card__body">{children}</div>;
}

function CardFooter({ children }: { children: React.ReactNode }) {
  return <div className="card__footer">{children}</div>;
}

// Usage — consumer composes freely, no new props needed for badges
<Card variant="elevated">
  <CardHeader>
    <UserAvatar userId={owner.id} />
    <h3>{owner.name}</h3>
    <Badge count={notifications} /> {/* No prop needed — just compose */}
  </CardHeader>
  <CardBody><ProjectSummary project={project} /></CardBody>
  <CardFooter><EditButton projectId={project.id} /></CardFooter>
</Card>
```

Reference: [React Docs - Passing JSX as Children](https://react.dev/learn/passing-props-to-a-component#passing-jsx-as-children)
