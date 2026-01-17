---
title: Compose with Compound Component Patterns
impact: MEDIUM
impactDescription: reduces prop count by 60-80% vs monolithic components
tags: comp, compound-components, composition, api-design, patterns
---

## Compose with Compound Component Patterns

Build custom components using compound component patterns like shadcn/ui. This creates flexible, composable APIs that fit naturally with existing components.

**Incorrect (monolithic component with many props):**

```tsx
interface SettingsCardProps {
  title: string
  description: string
  icon: LucideIcon
  switchLabel: string
  switchChecked: boolean
  onSwitchChange: (checked: boolean) => void
  badge?: string
  footer?: React.ReactNode
}

function SettingsCard({
  title,
  description,
  icon: Icon,
  switchLabel,
  switchChecked,
  onSwitchChange,
  badge,
  footer,
}: SettingsCardProps) {
  // Rigid API - hard to customize layout or add new elements
  return (
    <Card>
      <CardHeader>
        <Icon className="h-5 w-5" />
        <CardTitle>{title}</CardTitle>
        {badge && <Badge>{badge}</Badge>}
      </CardHeader>
      <CardContent>
        <p>{description}</p>
        <Switch checked={switchChecked} onCheckedChange={onSwitchChange} />
      </CardContent>
      {footer && <CardFooter>{footer}</CardFooter>}
    </Card>
  )
}
```

**Correct (compound component pattern):**

```tsx
const SettingsCardContext = createContext<{ disabled?: boolean }>({})

function SettingsCard({ children, disabled }: { children: React.ReactNode; disabled?: boolean }) {
  return (
    <SettingsCardContext.Provider value={{ disabled }}>
      <Card className={cn(disabled && "opacity-50")}>{children}</Card>
    </SettingsCardContext.Provider>
  )
}

function SettingsCardHeader({ children }: { children: React.ReactNode }) {
  return <CardHeader className="flex flex-row items-center gap-4">{children}</CardHeader>
}

function SettingsCardIcon({ icon: Icon }: { icon: LucideIcon }) {
  return <Icon className="h-5 w-5 text-muted-foreground" />
}

function SettingsCardTitle({ children }: { children: React.ReactNode }) {
  return <CardTitle className="text-base">{children}</CardTitle>
}

function SettingsCardContent({ children }: { children: React.ReactNode }) {
  return <CardContent>{children}</CardContent>
}

function SettingsCardAction({ children }: { children: React.ReactNode }) {
  const { disabled } = useContext(SettingsCardContext)
  return <div className={cn(disabled && "pointer-events-none")}>{children}</div>
}

// Usage - flexible composition
<SettingsCard>
  <SettingsCardHeader>
    <SettingsCardIcon icon={Bell} />
    <SettingsCardTitle>Notifications</SettingsCardTitle>
    <Badge>Beta</Badge>
  </SettingsCardHeader>
  <SettingsCardContent>
    <p className="text-muted-foreground">Receive alerts for important updates</p>
  </SettingsCardContent>
  <SettingsCardAction>
    <Switch checked={enabled} onCheckedChange={setEnabled} />
  </SettingsCardAction>
</SettingsCard>
```

Reference: [Compound Components Pattern](https://www.patterns.dev/react/compound-pattern/)
