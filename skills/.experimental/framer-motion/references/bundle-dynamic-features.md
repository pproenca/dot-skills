---
title: Dynamically Import Motion Features
impact: CRITICAL
impactDescription: defers 150kb chunk until after hydration
tags: bundle, dynamic-import, code-splitting, performance
---

## Dynamically Import Motion Features

Static imports of motion features block hydration even when animations are not immediately visible. Using dynamic imports with `loadFeatures` defers the feature bundle until after the initial page load, improving Time to Interactive.

**Incorrect (static import blocks hydration):**

```tsx
// app/layout.tsx
import { LazyMotion, domMax } from "framer-motion"; // domMax loaded synchronously

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <LazyMotion features={domMax}>
      {children}
    </LazyMotion>
  );
}
```

**Correct (dynamic import defers loading):**

```tsx
// app/layout.tsx
import { LazyMotion } from "framer-motion";

const loadFeatures = () =>
  import("framer-motion").then((mod) => mod.domMax); // Loaded after hydration

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <LazyMotion features={loadFeatures}>
      {children}
    </LazyMotion>
  );
}
```

**With custom feature bundle for maximum control:**

```tsx
// lib/motion-features.ts
import { domAnimation } from "framer-motion";
export default domAnimation;

// app/layout.tsx
import { LazyMotion } from "framer-motion";

const loadFeatures = () =>
  import("@/lib/motion-features").then((mod) => mod.default);

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <LazyMotion features={loadFeatures}>
      {children}
    </LazyMotion>
  );
}
```

Reference: [Framer Motion - LazyMotion](https://www.framer.com/motion/lazy-motion/)
