---
title: Use LazyMotion and m Component Instead of motion
impact: CRITICAL
impactDescription: reduces bundle from 34kb to <5kb
tags: bundle, lazy-loading, tree-shaking, performance
---

## Use LazyMotion and m Component Instead of motion

The `motion` component includes all animation features by default, adding 34kb to your bundle. Using `LazyMotion` with the `m` component lets you load only the features you need, reducing initial payload to under 5kb.

**Incorrect (full motion bundle loaded):**

```tsx
// components/ProductCard.tsx
import { motion } from "framer-motion"; // 34kb+ included in bundle

export function ProductCard({ product }: ProductCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      whileHover={{ scale: 1.02 }}
    >
      <img src={product.image} alt={product.name} />
      <h3>{product.name}</h3>
      <p>{product.price}</p>
    </motion.div>
  );
}
```

**Correct (lazy-loaded features, minimal bundle):**

```tsx
// components/ProductCard.tsx
import { m } from "framer-motion"; // Only 2.5kb, features loaded separately

export function ProductCard({ product }: ProductCardProps) {
  return (
    <m.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      whileHover={{ scale: 1.02 }}
    >
      <img src={product.image} alt={product.name} />
      <h3>{product.name}</h3>
      <p>{product.price}</p>
    </m.div>
  );
}

// app/layout.tsx (or _app.tsx)
import { LazyMotion, domAnimation } from "framer-motion";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <LazyMotion features={domAnimation}>
      {children}
    </LazyMotion>
  );
}
```

Reference: [Framer Motion - Reduce Bundle Size](https://www.framer.com/motion/guide-reduce-bundle-size/)
