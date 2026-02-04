---
title: Define Identical Variables Across All Themes
impact: CRITICAL
impactDescription: missing variables cause undefined colors and broken UI
tags: theme, css-variables, consistency, validation
---

## Define Identical Variables Across All Themes

Every theme must define the same CSS variables. Missing variables cause undefined colors and Uniwind will warn in development mode.

**Incorrect (inconsistent variables):**

```css
@layer theme {
  :root {
    @variant light {
      --color-background: #ffffff;
      --color-foreground: #000000;
      --color-primary: #3b82f6;
    }

    @variant dark {
      --color-background: #000000;
      --color-foreground: #ffffff;
      /* Missing --color-primary! Will be undefined in dark mode */
    }
  }
}
```

**Correct (all variables defined):**

```css
@layer theme {
  :root {
    @variant light {
      --color-background: #ffffff;
      --color-foreground: #000000;
      --color-primary: #3b82f6;
      --color-secondary: #6b7280;
      --color-accent: #f59e0b;
    }

    @variant dark {
      --color-background: #0a0a0a;
      --color-foreground: #fafafa;
      --color-primary: #60a5fa;
      --color-secondary: #9ca3af;
      --color-accent: #fbbf24;
    }
  }
}
```

**Uniwind validation:**
- Warns in `__DEV__` mode when variables are missing
- Enable `debug: true` for detailed variable reports

Reference: [Uniwind Custom Themes](https://docs.uniwind.dev/theming/custom-themes)
