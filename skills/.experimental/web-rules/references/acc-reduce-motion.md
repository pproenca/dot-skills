---
title: 'Respect prefers-reduced-motion: reduce'
impact: CRITICAL
impactDescription: '~30% of users with vestibular disorders experience nausea or vertigo from parallax and large translations; macOS/iOS/Windows users set this preference at the OS level'
tags: acc, reduce-motion, prefers-reduced-motion, animation, wcag-2-3-3
---

## Respect prefers-reduced-motion: reduce

When the user has set `prefers-reduced-motion: reduce`, disable any non-essential animation: parallax, autoplay carousels, large translations, scale transforms, and decorative motion. Cross-fades and color transitions are fine. Tailwind ships a `motion-safe:` variant — apply transforms and translations only inside it, and keep `transition-colors`/`transition-opacity` always-on for state legibility.

**Incorrect (animation runs for every user, no reduced-motion handling):**

```tsx
function HeroCard({ children }: { children: React.ReactNode }) {
  return (
    <div className="transition-transform duration-500 hover:translate-y-[-8px] hover:scale-105">
      {children}
    </div>
  )
}

// Library animations that don't check prefers-reduced-motion
<motion.div animate={{ y: [0, -20, 0] }} transition={{ repeat: Infinity }}>
  Pulsing badge
</motion.div>
```

**Correct (use `motion-safe:` for transforms, color/opacity transitions always-on):**

```tsx
function HeroCard({ children }: { children: React.ReactNode }) {
  return (
    <div className="transition-colors duration-150 motion-safe:transition-transform motion-safe:hover:-translate-y-2 motion-safe:hover:scale-[1.02]">
      {children}
    </div>
  )
}

// framer-motion respects prefers-reduced-motion when you tell it to
import { useReducedMotion, motion } from 'framer-motion'

function PulsingBadge() {
  const reduce = useReducedMotion()
  return (
    <motion.div
      animate={reduce ? {} : { y: [0, -20, 0] }}
      transition={{ repeat: Infinity, duration: 1.5 }}
    >
      New
    </motion.div>
  )
}
```

**CSS-level fallback (covers global keyframes you don't control directly):**

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

**Rule:**
- Transforms (`translate`, `scale`, `rotate`) and large translations go under `motion-safe:`
- Color, opacity, and ≤ 150 ms cross-fade transitions are allowed always-on (they aid legibility)
- Library animations check `useReducedMotion()` (framer-motion) or equivalent before animating
- Never autoplay video or background animation; if it must autoplay, provide a Pause control
- Verify by toggling `Settings → Accessibility → Display → Reduce motion` (macOS) or Chrome DevTools Rendering panel → "Emulate CSS media feature prefers-reduced-motion"

Reference: [WCAG 2.3.3 Animation from Interactions](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
