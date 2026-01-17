---
title: Use Slot Pattern for Flexible Content Areas
impact: MEDIUM
impactDescription: enables custom content injection without prop explosion
tags: comp, slot, composition, flexibility, children
---

## Use Slot Pattern for Flexible Content Areas

For components with multiple content areas (header, footer, actions), use named slot patterns instead of render props or excessive boolean props.

**Incorrect (render props and booleans):**

```tsx
interface NotificationProps {
  title: string
  message: string
  showIcon?: boolean
  icon?: React.ReactNode
  showDismiss?: boolean
  onDismiss?: () => void
  showAction?: boolean
  actionLabel?: string
  onAction?: () => void
  renderFooter?: () => React.ReactNode
}

function Notification({
  title,
  message,
  showIcon,
  icon,
  showDismiss,
  onDismiss,
  showAction,
  actionLabel,
  onAction,
  renderFooter,
}: NotificationProps) {
  // Props explosion - hard to extend, confusing API
  return (
    <div className="rounded-lg border p-4">
      {showIcon && icon}
      <div>
        <h4>{title}</h4>
        <p>{message}</p>
      </div>
      {showDismiss && <button onClick={onDismiss}>×</button>}
      {showAction && <button onClick={onAction}>{actionLabel}</button>}
      {renderFooter?.()}
    </div>
  )
}
```

**Correct (slot-based composition):**

```tsx
interface NotificationProps {
  children: React.ReactNode
  className?: string
}

function Notification({ children, className }: NotificationProps) {
  return (
    <div className={cn("rounded-lg border p-4", className)}>
      {children}
    </div>
  )
}

function NotificationIcon({ children }: { children: React.ReactNode }) {
  return <div className="flex-shrink-0">{children}</div>
}

function NotificationContent({ children }: { children: React.ReactNode }) {
  return <div className="flex-1 ml-3">{children}</div>
}

function NotificationTitle({ children }: { children: React.ReactNode }) {
  return <h4 className="font-medium">{children}</h4>
}

function NotificationDescription({ children }: { children: React.ReactNode }) {
  return <p className="text-sm text-muted-foreground mt-1">{children}</p>
}

function NotificationActions({ children }: { children: React.ReactNode }) {
  return <div className="flex gap-2 mt-3">{children}</div>
}

function NotificationDismiss({ onDismiss }: { onDismiss: () => void }) {
  return (
    <Button variant="ghost" size="icon" onClick={onDismiss} className="absolute top-2 right-2">
      <X className="h-4 w-4" />
      <span className="sr-only">Dismiss</span>
    </Button>
  )
}

// Usage - compose exactly what you need
<Notification className="relative">
  <NotificationIcon>
    <CheckCircle className="h-5 w-5 text-green-500" />
  </NotificationIcon>
  <NotificationContent>
    <NotificationTitle>Success!</NotificationTitle>
    <NotificationDescription>Your changes have been saved.</NotificationDescription>
    <NotificationActions>
      <Button size="sm">View</Button>
      <Button size="sm" variant="outline">Undo</Button>
    </NotificationActions>
  </NotificationContent>
  <NotificationDismiss onDismiss={() => setVisible(false)} />
</Notification>
```

Reference: [Composition vs Inheritance](https://react.dev/learn/passing-props-to-a-component)
