---
title: Support Dark Mode with CSS Variables
impact: HIGH
impactDescription: provides user preference compliance and reduces eye strain
tags: style, dark-mode, theming, css-variables, accessibility
---

## Support Dark Mode with CSS Variables

Use the shadcn/ui dark mode pattern with CSS variables. Define both light and dark values; components automatically adapt.

**Incorrect (hardcoded mode-specific styles):**

```tsx
function NotificationCard({ message }: { message: string }) {
  return (
    <Card className="bg-white text-gray-900 border-gray-200">
      {/* No dark mode support - harsh white in dark environments */}
      <CardContent className="p-4">
        <p className="text-gray-600">{message}</p>
      </CardContent>
    </Card>
  )
}
```

**Correct (CSS variables with dark mode support):**

```css
/* globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
  }
}
```

```tsx
function NotificationCard({ message }: { message: string }) {
  return (
    <Card className="bg-card text-card-foreground border-border">
      {/* Automatically adapts to light/dark mode */}
      <CardContent className="p-4">
        <p className="text-muted-foreground">{message}</p>
      </CardContent>
    </Card>
  )
}
```

**Theme toggle implementation:**

```tsx
import { useTheme } from "next-themes"

function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button variant="outline" size="icon" onClick={() => setTheme(theme === "dark" ? "light" : "dark")}>
      <SunIcon className="h-4 w-4 rotate-0 scale-100 dark:-rotate-90 dark:scale-0" />
      <MoonIcon className="absolute h-4 w-4 rotate-90 scale-0 dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  )
}
```

Reference: [shadcn/ui Dark Mode](https://ui.shadcn.com/docs/dark-mode)
