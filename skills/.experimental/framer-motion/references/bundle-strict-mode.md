---
title: Enable Strict Mode to Catch Accidental motion Imports
impact: HIGH
impactDescription: prevents 30kb+ bundle regressions
tags: bundle, strict-mode, lazy-motion, dev-experience
---

## Enable Strict Mode to Catch Accidental motion Imports

When using LazyMotion, developers might accidentally import `motion` instead of `m`, silently adding the full 34kb bundle. Enabling `strict` mode on LazyMotion throws an error when a `motion` component is rendered, catching these mistakes during development.

**Incorrect (no strict mode, accidental import goes unnoticed):**

```tsx
// app/layout.tsx
import { LazyMotion, domAnimation } from "framer-motion";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <LazyMotion features={domAnimation}>
      {children}
    </LazyMotion>
  );
}

// components/SearchInput.tsx
import { motion } from "framer-motion"; // Accidental import - no warning!

export function SearchInput({ onSearch }: SearchInputProps) {
  return (
    <motion.div // Silently adds 34kb to bundle
      initial={{ width: 200 }}
      animate={{ width: 300 }}
    >
      <input type="search" onChange={(e) => onSearch(e.target.value)} />
    </motion.div>
  );
}
```

**Correct (strict mode catches accidental imports):**

```tsx
// app/layout.tsx
import { LazyMotion, domAnimation } from "framer-motion";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <LazyMotion features={domAnimation} strict>
      {children}
    </LazyMotion>
  );
}

// components/SearchInput.tsx
import { m } from "framer-motion"; // Correct import with m component

export function SearchInput({ onSearch }: SearchInputProps) {
  return (
    <m.div // Works correctly with LazyMotion
      initial={{ width: 200 }}
      animate={{ width: 300 }}
    >
      <input type="search" onChange={(e) => onSearch(e.target.value)} />
    </m.div>
  );
}
```

**Error thrown with strict mode when using motion:**
```text
Error: motion components must be wrapped in a LazyMotion component with
the "domAnimation" or "domMax" features. You are using a motion component
but strict mode is enabled.
```

Reference: [Framer Motion - LazyMotion strict](https://www.framer.com/motion/lazy-motion/#strict)
