---
title: Define Theme Variables with @theme Directive
impact: CRITICAL
impactDescription: enables semantic color classes across entire app
tags: theme, css-variables, tailwind-4, design-tokens
---

## Define Theme Variables with @theme Directive

Uniwind uses Tailwind 4's @theme directive for CSS variables. This enables semantic classes like `bg-background` and `text-foreground`.

**Incorrect (hardcoded colors everywhere):**

```tsx
<View className="bg-white dark:bg-black">
  <Text className="text-gray-900 dark:text-white">
    {/* Repeated throughout app, hard to maintain */}
  </Text>
</View>
```

**Correct (semantic theme variables):**

```css
/* global.css */
@import 'tailwindcss';
@import 'uniwind';

@theme {
  --color-background: #ffffff;
  --color-foreground: #000000;
  --color-primary: #3b82f6;
  --color-muted: #6b7280;
}
```

```tsx
<View className="bg-background">
  <Text className="text-foreground">
    {/* Automatically adapts to theme */}
  </Text>
</View>
```

**Benefits:**
- Single source of truth for colors
- Easy theme switching
- Consistent design system
- No JavaScript theme provider needed

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)
