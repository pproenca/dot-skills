---
title: Use Class-Based Dark Mode Switching
impact: HIGH
impactDescription: enables instant theme switching without page reload
tags: style, dark-mode, theming, class, toggle
---

## Use Class-Based Dark Mode Switching

shadcn/ui uses class-based dark mode (`.dark` class on html/body) for instant switching. Media query-based dark mode cannot be toggled without OS settings.

**Incorrect (media query only):**

```css
/* globals.css */
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
}

@media (prefers-color-scheme: dark) {
  :root {
    --background: oklch(0.145 0 0);
    --foreground: oklch(0.985 0 0);
  }
}
/* User cannot override system preference */
```

**Correct (class-based with system fallback):**

```css
/* globals.css */
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
}
```

```tsx
// theme-provider.tsx
import { createContext, useContext, useEffect, useState } from "react"

type Theme = "dark" | "light" | "system"

function ThemeProvider({ children, defaultTheme = "system" }) {
  const [theme, setTheme] = useState<Theme>(defaultTheme)

  useEffect(() => {
    const root = window.document.documentElement
    root.classList.remove("light", "dark")

    if (theme === "system") {
      const systemTheme = window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light"
      root.classList.add(systemTheme)
    } else {
      root.classList.add(theme)
    }
  }, [theme])

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}
```

Reference: [shadcn/ui Dark Mode](https://ui.shadcn.com/docs/dark-mode)
