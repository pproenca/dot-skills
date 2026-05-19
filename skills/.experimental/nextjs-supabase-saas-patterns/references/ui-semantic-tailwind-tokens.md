---
title: Use Semantic Tailwind Tokens, Not Hardcoded Colors
impact: MEDIUM
impactDescription: prevents dark-mode and theme drift across components
tags: ui, tailwind, design-tokens, theme, dark-mode
---

## Use Semantic Tailwind Tokens, Not Hardcoded Colors

`bg-background`, `text-foreground`, `bg-muted`, `text-muted-foreground` resolve to CSS variables that swap based on the active theme. Hardcoded `bg-white` / `text-gray-500` don't swap — the component looks correct in light mode and breaks in dark mode. The token set is small enough to memorise and covers ~95% of cases; reach for specific colors only when you have a genuine non-semantic need (charts, brand-mandated palette).

**Incorrect (hardcoded colors — breaks in dark mode):**

```tsx
<div className="bg-white text-gray-900 border border-gray-200 rounded-md p-4">
  <h3 className="text-gray-800 font-semibold">Project: {project.name}</h3>
  <p className="text-gray-500 text-sm">Created {project.created_at}</p>
  <button className="bg-blue-600 text-white px-4 py-2 rounded">
    Edit
  </button>
</div>
{/*
  Light mode: looks fine.
  Dark mode: white background blinds the user, gray-500 text is unreadable
  on dark backgrounds, blue-600 fights the dark-mode primary color.
*/}
```

**Correct (semantic tokens — flip automatically):**

```tsx
<div className="bg-card text-card-foreground border border-border rounded-md p-4">
  <h3 className="text-foreground font-semibold">Project: {project.name}</h3>
  <p className="text-muted-foreground text-sm">
    <Trans i18nKey="projects.created" values={{ date: project.created_at }} />
  </p>
  <Button variant="default">
    <Trans i18nKey="common.edit" />
  </Button>
</div>
```

**The semantic token set (`packages/ui/src/styles/globals.css`):**

| Token | Light mode | Dark mode | Use for |
|-------|-----------|-----------|---------|
| `background` / `foreground` | white / near-black | near-black / white | Page background and primary text |
| `card` / `card-foreground` | white / near-black | dark-gray / white | Card/panel surfaces |
| `popover` / `popover-foreground` | white / near-black | dark-gray / white | Tooltips, dropdowns |
| `primary` / `primary-foreground` | brand / white | brand / white | Primary actions |
| `secondary` / `secondary-foreground` | gray-100 / near-black | gray-800 / white | Secondary actions |
| `muted` / `muted-foreground` | gray-50 / gray-500 | gray-900 / gray-400 | Disabled, placeholder, helper text |
| `accent` / `accent-foreground` | gray-100 / near-black | gray-800 / white | Hover states on neutral surfaces |
| `destructive` / `destructive-foreground` | red / white | red / white | Delete buttons, error alerts |
| `border` | gray-200 | gray-800 | Borders |
| `input` | gray-200 | gray-800 | Input borders |
| `ring` | brand | brand | Focus rings |

**Status colors that should remain semantic:**

```tsx
// Use the success/warning/info token maps from packages/ui/src/makerkit/badge-extras.tsx
import { badgeExtras } from '@kit/ui/badge-extras';

<Badge className={cn(badgeExtras.success)}>Active</Badge>
<Badge className={cn(badgeExtras.warning)}>Trialing</Badge>
<Badge className={cn(badgeExtras.destructive)}>Past due</Badge>
```

**When hardcoded colors are appropriate:**

- **Charts.** A chart's first series being `oklch(70% 0.15 30)` is fine — semantic tokens don't model dataseries.
- **Brand-mandated assets.** Logo SVG colors. Marketing-specific palettes.
- **Loading skeletons.** `bg-muted` is the right answer; don't reach for `bg-gray-200`.

**Always use `cn()` for class merging.** When combining base classes with conditional ones, `cn()` from `@kit/ui/utils` runs `tailwind-merge` to resolve conflicting utilities (e.g., `bg-card` overrides a previously-passed `bg-background`):

```tsx
import { cn } from '@kit/ui/utils';

<Card className={cn(
  'bg-card text-card-foreground',
  isHighlighted && 'ring-2 ring-primary',
  className,  // Consumer's overrides win.
)}>
```

**Don't override semantic tokens in component styles.** If you find yourself writing `className="bg-card !bg-blue-100"`, the design system is missing a token — propose one in the global stylesheet rather than fighting tailwind-merge.

Reference: [shadcn/ui theming](https://ui.shadcn.com/docs/theming)
