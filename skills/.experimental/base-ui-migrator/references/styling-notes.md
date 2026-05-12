# Styling Notes — Adapting Unstyled Base UI to Your Project

Base UI ships zero styles. Every visual decision is up to you. This file documents the styling model so migrations preserve the project's existing approach (Tailwind / CSS Modules / styled-components / vanilla-extract).

## The Two Things You Need to Know

1. **Base UI exposes state through HTML data attributes.** Style with attribute selectors, not by conditionally adding/removing class names.
2. **Each part is a separate stylable surface.** `Dialog.Backdrop`, `Dialog.Popup`, `Dialog.Title` are all DOM elements you can target independently.

## Data Attributes — The State Model

| Attribute | When present | Common use |
|-----------|--------------|------------|
| `data-[state=open]` / `data-[state=closed]` | On `Popup` parts | Fade in/out, show/hide |
| `data-[checked]` / `data-[unchecked]` | Checkbox, Switch, Radio, Toggle | Filled state |
| `data-[disabled]` | Any interactive part when disabled | Dimmed/muted |
| `data-[pressed]` | Toggle, ToggleGroup.Item | "Active" look |
| `data-[hover]` / `data-[focus]` / `data-[focus-visible]` | Triggers, items | Custom hover/focus styles |
| `data-[highlighted]` | Menu.Item, Select.Item, Combobox.Item | Currently keyboard-focused option |
| `data-[selected]` | Tabs.Tab, Menu.Item (when used as a selection), Select.Item | The chosen value |
| `data-[starting-style]` | On any element being inserted | Initial CSS to transition FROM on mount |
| `data-[ending-style]` | On any element being removed | Final CSS to transition TO on unmount |
| `data-[side=top\|bottom\|left\|right]` | Positioner parts | Style differently per anchored side |
| `data-[align=start\|center\|end]` | Positioner parts | Style differently per alignment |
| `data-[orientation=horizontal\|vertical]` | Slider, Tabs, ToggleGroup, Toolbar | Layout-aware styles |

### The transition pattern (replace JS-driven enter/exit animations)

```tsx
<Dialog.Popup
  className="
    transition-all duration-150
    data-[starting-style]:opacity-0 data-[starting-style]:scale-95
    data-[ending-style]:opacity-0 data-[ending-style]:scale-95
  "
>
```

**Why this works:** Base UI mounts the element with `data-starting-style` set, then removes the attribute on the next paint. CSS transition handles the rest. On close, it sets `data-ending-style`, waits for the transition, then unmounts.

You no longer need `<AnimatePresence>` or `useEffect` open-state tracking for these animations.

## Tailwind (most common)

### Required Tailwind version

Data-attribute variants need Tailwind v3.1+. Most projects are fine. If you see `data-[state=open]:opacity-100` not applying, check `tailwind.config.js` and upgrade.

### Pattern: state-driven styling

**Before — class composition by state:**

```tsx
<div className={`fixed inset-0 bg-black/50 ${open ? 'opacity-100' : 'opacity-0'} transition-opacity`}>
```

**After — data-attribute variant:**

```tsx
<Dialog.Backdrop className="fixed inset-0 bg-black/50 transition-opacity duration-150 data-[starting-style]:opacity-0 data-[ending-style]:opacity-0">
```

### Pattern: side-aware styling for popovers

```tsx
<Popover.Positioner sideOffset={8}>
  <Popover.Popup className="
    data-[side=top]:slide-in-from-bottom
    data-[side=bottom]:slide-in-from-top
    data-[side=left]:slide-in-from-right
    data-[side=right]:slide-in-from-left
  ">
```

### Pattern: keyboard-highlighted items

```tsx
<Menu.Item className="
  px-3 py-2 rounded
  data-[highlighted]:bg-blue-100 data-[highlighted]:outline-none
  data-[disabled]:opacity-50 data-[disabled]:pointer-events-none
">
```

## CSS Modules

Same idea — target the data attributes directly:

```css
/* Dialog.module.css */
.popup {
  position: fixed;
  inset: 50%;
  transform: translate(-50%, -50%);
  transition: transform 150ms, opacity 150ms;
}

.popup[data-starting-style],
.popup[data-ending-style] {
  opacity: 0;
  transform: translate(-50%, -50%) scale(0.95);
}

.item[data-highlighted] {
  background: var(--bg-hover);
}
```

```tsx
import styles from './Dialog.module.css';
<Dialog.Popup className={styles.popup}>
```

## styled-components / emotion

Use the `&[data-state="open"]` selector inside the styled template:

```tsx
const StyledPopup = styled(Dialog.Popup)`
  transition: opacity 150ms, transform 150ms;
  &[data-starting-style], &[data-ending-style] {
    opacity: 0;
    transform: scale(0.95);
  }
`;
```

**Gotcha:** When wrapping Base UI parts with `styled()`, you lose the `render` prop ergonomics. Prefer plain `className` on Base UI parts when possible, and use styled-components only for primitive elements inside them.

## vanilla-extract

```ts
// dialog.css.ts
import { style } from '@vanilla-extract/css';

export const popup = style({
  position: 'fixed',
  selectors: {
    '&[data-starting-style]': { opacity: 0, transform: 'scale(0.95)' },
    '&[data-ending-style]': { opacity: 0, transform: 'scale(0.95)' },
  },
});
```

## Class Variance Authority (cva) / tailwind-variants

Same pattern as Tailwind. Use data-attribute variants in your variant definitions:

```tsx
import { cva } from 'class-variance-authority';

const popupStyles = cva([
  'rounded-md bg-white shadow-lg p-4 transition-all duration-150',
  'data-[starting-style]:opacity-0 data-[starting-style]:scale-95',
  'data-[ending-style]:opacity-0 data-[ending-style]:scale-95',
], {
  variants: {
    size: { sm: 'w-72', md: 'w-96', lg: 'w-[32rem]' },
  },
});
```

## Common Migration Mistakes (Styling)

| Mistake | Fix |
|---------|-----|
| Conditional className for open state: `${open ? 'opacity-100' : 'opacity-0'}` | Replace with `data-[starting-style]:opacity-0 data-[ending-style]:opacity-0` and let the data attribute drive it. |
| `framer-motion` `<AnimatePresence>` wrapping the Popup | Drop it. Use `data-[starting-style]` + `data-[ending-style]` for enter/exit. |
| `useEffect` setting class names based on `aria-expanded` | Use `data-[state=open]` / `data-[state=closed]` selectors on the source. |
| Manually toggling a `visible` class on the backdrop | The backdrop appears/disappears with the dialog automatically. Style with data attributes. |
| Position calculations in CSS using a `position` variable in state | Use `data-[side=top]` / `data-[side=bottom]` selectors on the Positioner. |
| Adding `transition: opacity 0.15s` but no opacity change | Make sure you have BOTH the starting AND ending style for symmetric transitions, or just one if you only animate in one direction. |

## When the Project Has No Styling Convention

If the file you're migrating is unstyled (e.g., a fresh component), don't invent a system. Match the project's broader convention — check `tailwind.config.js`, look at sibling files. If genuinely none exists, ask the user before adding Tailwind to the migration.

## Verifying Animations Actually Run

After migration, transitions can silently fail because:

1. The element doesn't have `transition: ...` set
2. The starting-style and ending-style are identical to the resting state (no diff to animate from)
3. Tailwind is purging the `data-[starting-style]:` classes because they look unused (only happens with custom regex content paths — usually fine)

Quick check: open the migrated component in a browser, open DevTools, and watch the data attributes flip when you open/close. If the attributes flip but the visual doesn't change, your CSS is missing the starting/ending styles.
