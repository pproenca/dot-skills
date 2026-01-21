---
title: Provide Screen Reader Labels for Icon Buttons
impact: CRITICAL
impactDescription: enables navigation for visually impaired users
tags: ally, sr-only, screen-readers, icons, labels
---

## Provide Screen Reader Labels for Icon Buttons

Icon-only buttons must have accessible labels. Without them, screen readers announce "button" with no context about the action.

**Incorrect (icon button without accessible name):**

```tsx
function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="outline"
      size="icon"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
    >
      <SunIcon className="h-4 w-4 dark:hidden" />
      <MoonIcon className="h-4 w-4 hidden dark:block" />
      {/* Screen reader announces: "button" - no context */}
    </Button>
  )
}
```

**Correct (sr-only text provides context):**

```tsx
function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="outline"
      size="icon"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
    >
      <SunIcon className="h-4 w-4 dark:hidden" />
      <MoonIcon className="h-4 w-4 hidden dark:block" />
      <span className="sr-only">Toggle theme</span>
      {/* Screen reader announces: "Toggle theme, button" */}
    </Button>
  )
}
```

**Alternative (using aria-label):**

```tsx
function CloseButton({ onClose }: { onClose: () => void }) {
  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={onClose}
      aria-label="Close dialog"
    >
      <XIcon className="h-4 w-4" />
    </Button>
  )
}
```

**Use sr-only when:**
- The label is longer or more descriptive
- Multiple icons need different labels in the same context
- You want visible fallback if CSS fails

Reference: [Tailwind Screen Reader](https://tailwindcss.com/docs/screen-readers)
