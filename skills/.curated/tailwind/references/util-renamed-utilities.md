---
title: Use Renamed Utility Classes
impact: HIGH
impactDescription: prevents broken styles, ensures v4 compatibility
tags: util, migration, renamed, breaking-changes, scale
---

## Use Renamed Utility Classes

Tailwind CSS v4 renames several utility classes to create consistent scaling. Update these classes to prevent broken styles.

**Incorrect (v3 class names):**

```html
<input class="shadow-sm blur-sm rounded-sm ring ring-blue-500" />
<button class="outline-none">Click me</button>
```

**Correct (v4 class names):**

```html
<input class="shadow-xs blur-xs rounded-xs ring-3 ring-blue-500" />
<button class="outline-hidden">Click me</button>
```

**Complete rename mapping:**

| v3 Class | v4 Class | Reason |
|----------|----------|--------|
| `shadow-sm` | `shadow-xs` | Scale consistency |
| `shadow` | `shadow-sm` | Scale consistency |
| `blur-sm` | `blur-xs` | Scale consistency |
| `rounded-sm` | `rounded-xs` | Scale consistency |
| `ring` (3px) | `ring-3` | Explicit width |
| `ring` (1px) | `ring` | New default |
| `outline-none` | `outline-hidden` | Semantic clarity |

**Automated migration:**

```bash
npx @tailwindcss/upgrade
# Automatically renames classes in your templates
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
