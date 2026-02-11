---
title: Use Vite Plugin Over PostCSS
impact: CRITICAL
impactDescription: 2-5x faster HMR and incremental performance vs PostCSS
tags: build, vite, postcss, tooling, performance
---

## Use Vite Plugin Over PostCSS

The first-party Vite plugin provides tighter integration and better performance than the PostCSS plugin, especially for Hot Module Replacement and incremental rebuilds during development.

**Incorrect (PostCSS approach in Vite projects):**

```typescript
// postcss.config.js — works, but misses Vite-specific optimizations
export default {
  plugins: ["@tailwindcss/postcss"],
};
```

**Correct (dedicated Vite plugin):**

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
});
```

**When NOT to use this pattern:**
- Projects not using Vite as their build tool
- Projects using webpack, Parcel, or other bundlers (use `@tailwindcss/postcss` instead)

**Note:** Both integration methods benefit from v4's engine improvements (full builds up to 5x faster, incremental builds over 100x faster than v3). The Vite plugin adds further gains through direct bundler integration.

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
