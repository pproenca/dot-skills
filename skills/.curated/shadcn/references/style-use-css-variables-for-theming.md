---
title: Use CSS Variables for Theme Colors
impact: HIGH
impactDescription: enables runtime theme switching and consistency
tags: style, css-variables, theming, dark-mode, colors
---

## Use CSS Variables for Theme Colors

Reference theme colors via CSS variables (--primary, --background, etc.) rather than hardcoded Tailwind colors. This enables theme switching and maintains design consistency.

**Incorrect (hardcoded colors break theming):**

```tsx
function StatusCard({ status }: { status: "active" | "inactive" }) {
  return (
    <Card className="bg-white dark:bg-gray-800 border-gray-200">
      <CardHeader>
        <CardTitle className={status === "active" ? "text-green-600" : "text-gray-500"}>
          {/* Hardcoded colors don't adapt to theme changes */}
          Status: {status}
        </CardTitle>
      </CardHeader>
    </Card>
  )
}
```

**Correct (CSS variables adapt to theme):**

```tsx
function StatusCard({ status }: { status: "active" | "inactive" }) {
  return (
    <Card className="bg-card border-border">
      <CardHeader>
        <CardTitle
          className={status === "active" ? "text-primary" : "text-muted-foreground"}
        >
          {/* Colors automatically update with theme */}
          Status: {status}
        </CardTitle>
      </CardHeader>
    </Card>
  )
}
```

**shadcn/ui CSS variable naming:**
- `bg-background`, `text-foreground` - Base colors
- `bg-card`, `text-card-foreground` - Card surfaces
- `bg-primary`, `text-primary-foreground` - Primary actions
- `bg-muted`, `text-muted-foreground` - Subdued elements
- `bg-destructive`, `text-destructive` - Destructive actions
- `border-border`, `ring-ring` - Borders and focus rings

Reference: [shadcn/ui Theming](https://ui.shadcn.com/docs/theming)
