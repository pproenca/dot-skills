---
title: Use @variant Blocks for Theme Definitions
impact: CRITICAL
impactDescription: enables dark mode and custom themes without JavaScript
tags: theme, variant, dark-mode, light-mode
---

## Use @variant Blocks for Theme Definitions

Each theme requires an `@variant` block defining its CSS variables. Themes switch by changing CSS variables, not JavaScript state.

**Incorrect (JavaScript-based theming):**

```tsx
// Requires context, re-renders, and manual color mapping
const ThemeProvider = ({ children }) => {
  const [theme, setTheme] = useState('light')
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}
```

**Correct (CSS-based theming):**

```css
/* global.css */
@import 'tailwindcss';
@import 'uniwind';

@layer theme {
  :root {
    @variant light {
      --color-background: #ffffff;
      --color-foreground: #0a0a0a;
      --color-primary: #3b82f6;
    }

    @variant dark {
      --color-background: #0a0a0a;
      --color-foreground: #fafafa;
      --color-primary: #60a5fa;
    }
  }
}
```

```tsx
// No ThemeProvider needed!
<View className="bg-background">
  <Text className="text-foreground">Adapts to system theme</Text>
</View>
```

**Switch themes programmatically:**

```typescript
import { Uniwind } from 'uniwind'

Uniwind.setTheme('dark')
```

Reference: [Uniwind Custom Themes](https://docs.uniwind.dev/theming/custom-themes)
