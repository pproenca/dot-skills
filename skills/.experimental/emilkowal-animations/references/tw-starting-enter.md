---
title: Animate Enter States with the starting: Variant in Tailwind v4
impact: MEDIUM
impactDescription: removes the extra mount render and the one-frame final-state flash that a useState/useEffect toggle introduces
tags: tw, tailwind, starting-style, enter, transition-discrete, mount
---

## Animate Enter States with the starting: Variant in Tailwind v4

Tailwind v4 exposes `@starting-style` through the `starting:` variant, so an element can animate from its initial values on first render with no JavaScript. This replaces the React pattern of flipping a `mounted` flag in `useEffect` purely to trigger the enter transition—which costs an extra render and can flash the final state for one frame. Add `transition-discrete` when the element also toggles `display` (popovers, dialogs).

**Incorrect (JS mount flag):**

```tsx
function Toast({ message }: { message: string }) {
  const [mounted, setMounted] = useState(false)
  useEffect(() => setMounted(true), [])
  return (
    <div
      className={`transition-[transform,opacity] duration-300 ease-out ${
        mounted ? "translate-y-0 opacity-100" : "translate-y-full opacity-0"
      }`}
    >
      {message}
    </div>
  )
}
```

**Correct (starting: variant, no mount flag):**

```tsx
function Toast({ message }: { message: string }) {
  return (
    <div className="transition-discrete transition-[transform,opacity] duration-300 ease-out translate-y-0 opacity-100 starting:translate-y-full starting:opacity-0">
      {message}
    </div>
  )
}
```

**When NOT to use this pattern:**
- You must support browsers without `@starting-style`—keep the `mounted` toggle as a fallback there.

Reference: [Building a Toast Component](https://emilkowal.ski/ui/building-a-toast-component)
