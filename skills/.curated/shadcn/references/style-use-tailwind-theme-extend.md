---
title: Extend Tailwind Theme for Custom Design Tokens
impact: HIGH
impactDescription: maintains design system consistency
tags: style, tailwind, theme, design-tokens, configuration
---

## Extend Tailwind Theme for Custom Design Tokens

Add brand colors and custom design tokens by extending the Tailwind theme rather than using arbitrary values. This creates reusable tokens and enables autocomplete.

**Incorrect (arbitrary values scattered):**

```tsx
function BrandedCard() {
  return (
    <Card className="bg-[#1a365d] border-[#2a4a7f]">
      <CardHeader>
        <CardTitle className="text-[#e2e8f0]">
          {/* Arbitrary values: no autocomplete, hard to maintain */}
          Dashboard
        </CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-[#a0aec0]">Welcome to your dashboard</p>
      </CardContent>
    </Card>
  )
}
```

**Correct (extended Tailwind theme):**

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#e6f0ff",
          100: "#b3d1ff",
          500: "#1a365d",
          600: "#153050",
          700: "#102540",
          foreground: "#e2e8f0",
          muted: "#a0aec0",
        },
      },
    },
  },
}
```

```tsx
function BrandedCard() {
  return (
    <Card className="bg-brand-500 border-brand-600">
      <CardHeader>
        <CardTitle className="text-brand-foreground">
          {/* Autocomplete works, single source of truth */}
          Dashboard
        </CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-brand-muted">Welcome to your dashboard</p>
      </CardContent>
    </Card>
  )
}
```

**Benefits of theme extension:**
- IDE autocomplete for all custom values
- Single source of truth for brand colors
- Easy global updates when brand changes
- Works with opacity modifiers (bg-brand-500/50)

Reference: [Tailwind Theme Extension](https://tailwindcss.com/docs/theme#extending-the-default-theme)
