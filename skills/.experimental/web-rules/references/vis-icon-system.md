---
title: Use lucide-react With 1.5 px Stroke and `size-4` / `size-5` Standard Sizes
impact: HIGH
impactDescription: Mismatched icon sets (lucide + heroicons + emoji) cause 30%+ visual-cohesion issues in reviews; non-standard sizes break optical alignment across components
tags: vis, icons, lucide-react, heroicons, sizing, stroke-width
---

## Use lucide-react With 1.5 px Stroke and `size-4` / `size-5` Standard Sizes

Pick one icon set and use it everywhere: `lucide-react` (default; 1500+ icons, tree-shakable, stroke-based) or `@heroicons/react` (Tailwind team; outline + solid pairs). Mixing sets visibly breaks coherence. Standard sizes inside buttons and rows: `size-4` (16 px) for dense UI, `size-5` (20 px) for default, `size-6` (24 px) for hero treatment. Always set `aria-hidden="true"` when the icon is decorative next to a text label.

**Incorrect (mixed icon sets, raw SVG, inconsistent sizing, missing aria-hidden):**

```tsx
import { Star } from 'lucide-react'
import { TrashIcon } from '@heroicons/react/24/outline' // different set
import emojiCheckmark from './emoji.svg'                 // third source

function Toolbar() {
  return (
    <div className="flex gap-2">
      <button><Star width={18} /></button>            {/* odd size */}
      <button><TrashIcon className="w-5 h-5" /></button> {/* different look */}
      <button><img src={emojiCheckmark} /></button>
      <button>
        <svg viewBox="0 0 24 24"><path d="..." /></svg>   {/* raw SVG, no semantics */}
      </button>
    </div>
  )
}
```

**Correct (single set, standard sizes, aria-hidden, stroke consistency):**

```tsx
import { Star, Trash2, Check, MoreHorizontal } from 'lucide-react'

function Toolbar() {
  return (
    <div className="flex gap-1">
      <Button size="icon" variant="ghost" aria-label="Star">
        <Star className="size-4" aria-hidden="true" />
      </Button>
      <Button size="icon" variant="ghost" aria-label="Delete">
        <Trash2 className="size-4" aria-hidden="true" />
      </Button>
      <Button size="icon" variant="ghost" aria-label="Mark complete">
        <Check className="size-4" aria-hidden="true" />
      </Button>
      <Button size="icon" variant="ghost" aria-label="More actions">
        <MoreHorizontal className="size-4" aria-hidden="true" />
      </Button>
    </div>
  )
}
```

**Configure stroke globally for consistency:**

```tsx
// components/ui/icon.tsx — wrap lucide if you want app-wide stroke control
import { LucideIcon } from 'lucide-react'

export function Icon({ icon: I, className, ...rest }: { icon: LucideIcon; className?: string }) {
  return <I strokeWidth={1.5} className={cn('size-4', className)} aria-hidden="true" {...rest} />
}

// Usage
<Icon icon={Star} />
<Icon icon={Trash2} className="size-5 text-destructive" />
```

**Size standards by context:**

```text
size-3  (12 px)  → very dense inline icons (status dots, badges)
size-4  (16 px)  → default in buttons, rows, menu items
size-5  (20 px)  → primary toolbar buttons, larger row leading icons
size-6  (24 px)  → standalone icon buttons, header chrome
size-8+ (32+ px) → hero icons, illustration placeholders
```

**Rule:**
- One icon set across the whole app — `lucide-react` is the default
- Use Tailwind `size-N` utilities, not `width`/`height` props
- Decorative icons next to text labels: `aria-hidden="true"`
- Icon-only buttons: parent has `aria-label` (see [acc-labels](acc-labels.md))
- Stroke width 1.5 — lucide ships this default; if you wrap it, enforce via the wrapper

Reference: [lucide.dev](https://lucide.dev/) · [Iconography in design systems — Nathan Curtis](https://medium.com/eightshapes-llc/iconography-in-design-systems-fa2a9d2f4dde)
