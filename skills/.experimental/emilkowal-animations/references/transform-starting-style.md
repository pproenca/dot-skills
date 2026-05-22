---
title: Animate Enter States with @starting-style
impact: HIGH
impactDescription: prevents the mount-flash from useEffect(setMounted) round-trips
tags: transform, starting-style, css, enter, mount
---

## Animate Enter States with @starting-style

`@starting-style` defines the values an element animates *from* on first render, letting you animate entry with pure CSS. It replaces the common React pattern of flipping a `mounted` flag in `useEffect` just to trigger the enter transition—which costs an extra render and can flash the final state for one frame.

**Incorrect (JavaScript mount flag):**

```tsx
function Toast({ message }: { message: string }) {
  const [mounted, setMounted] = useState(false)
  useEffect(() => setMounted(true), [])
  return <div data-mounted={mounted} className="toast">{message}</div>
}
// Needs JS plus a re-render solely to start the enter animation
```

**Correct (@starting-style, no JS):**

```css
.toast {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 400ms ease, transform 400ms ease;

  @starting-style {
    opacity: 0;
    transform: translateY(100%);
  }
}
```

**When NOT to use this pattern:**
- You must support browsers without `@starting-style`—keep the `data-mounted` attribute pattern as a fallback there

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
