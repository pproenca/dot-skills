---
title: Use domAnimation for Basic Animations
impact: CRITICAL
impactDescription: 17kb smaller than domMax
tags: bundle, feature-selection, dom-animation, performance
---

## Use domAnimation for Basic Animations

The `domMax` feature bundle includes layout animations, drag, and pan gestures which many apps do not need. Using `domAnimation` instead provides all common animation features (animate, exit, gestures like hover/tap) at 17kb less cost.

**Incorrect (domMax when only basic animations needed):**

```tsx
// app/layout.tsx
import { LazyMotion, domMax } from "framer-motion"; // Includes layout, drag, pan

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <LazyMotion features={domMax}>
      {children}
    </LazyMotion>
  );
}

// components/NavigationMenu.tsx
import { m } from "framer-motion";

export function NavigationMenu({ items }: NavigationMenuProps) {
  return (
    <m.nav initial={{ y: -20 }} animate={{ y: 0 }}>
      {items.map((item) => (
        <m.a
          key={item.href}
          href={item.href}
          whileHover={{ color: "#0066cc" }} // Only uses basic animations
          whileTap={{ scale: 0.98 }}
        >
          {item.label}
        </m.a>
      ))}
    </m.nav>
  );
}
```

**Correct (domAnimation for basic animations):**

```tsx
// app/layout.tsx
import { LazyMotion, domAnimation } from "framer-motion"; // 17kb smaller

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <LazyMotion features={domAnimation}>
      {children}
    </LazyMotion>
  );
}

// components/NavigationMenu.tsx
import { m } from "framer-motion";

export function NavigationMenu({ items }: NavigationMenuProps) {
  return (
    <m.nav initial={{ y: -20 }} animate={{ y: 0 }}>
      {items.map((item) => (
        <m.a
          key={item.href}
          href={item.href}
          whileHover={{ color: "#0066cc" }}
          whileTap={{ scale: 0.98 }}
        >
          {item.label}
        </m.a>
      ))}
    </m.nav>
  );
}
```

**When to use domMax instead:**
- You need `layout` or `layoutId` animations
- You need drag gestures (`drag`, `dragConstraints`)
- You need pan gestures (`onPan`, `onPanStart`)

Reference: [Framer Motion - Feature Bundles](https://www.framer.com/motion/guide-reduce-bundle-size/#feature-bundles)
