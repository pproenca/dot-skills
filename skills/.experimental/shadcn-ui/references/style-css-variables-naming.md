---
title: Follow CSS Variable Naming Convention
impact: HIGH
impactDescription: ensures consistent theme application across components
tags: style, css-variables, theming, naming, convention
---

## Follow CSS Variable Naming Convention

shadcn/ui uses a specific naming convention where background colors omit the "background" suffix. Breaking this convention causes theme inconsistencies.

**Incorrect (non-standard variable names):**

```css
:root {
  --primary-background: oklch(0.205 0 0);
  --primary-text: oklch(0.985 0 0);
  --card-bg: oklch(1 0 0);
  --card-fg: oklch(0.145 0 0);
}
```

```tsx
// Component can't use standard Tailwind classes
<div className="bg-[--primary-background] text-[--primary-text]">
  {/* Non-standard, verbose */}
</div>
```

**Correct (standard convention):**

```css
:root {
  --primary: oklch(0.205 0 0);
  --primary-foreground: oklch(0.985 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);
}
```

```tsx
// Component uses standard Tailwind classes
<div className="bg-primary text-primary-foreground">
  {/* Clean, consistent with all shadcn/ui components */}
</div>
```

**Naming pattern:**
| Variable | Purpose |
|----------|---------|
| `--{name}` | Background color |
| `--{name}-foreground` | Text/icon color for that background |

**Standard variables:** `background`, `foreground`, `card`, `popover`, `primary`, `secondary`, `muted`, `accent`, `destructive`, `border`, `input`, `ring`

Reference: [shadcn/ui Theming](https://ui.shadcn.com/docs/theming)
