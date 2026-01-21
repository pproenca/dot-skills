---
title: Use Vite Plugin Over PostCSS
impact: CRITICAL
impactDescription: 3-10× faster incremental builds
tags: build, vite, postcss, tooling, performance
---

## Use Vite Plugin Over PostCSS

The first-party Vite plugin provides tighter integration and significantly faster builds than the PostCSS plugin, especially for incremental rebuilds during development.

**Incorrect (slower PostCSS approach):**

```typescript
// postcss.config.js
export default {
  plugins: ["@tailwindcss/postcss"],
};
// Incremental rebuilds: ~5ms
```

**Correct (optimized Vite plugin):**

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
});
// Incremental rebuilds: ~192µs (26× faster)
```

**When NOT to use this pattern:**
- Projects not using Vite as their build tool
- Legacy projects requiring PostCSS pipeline compatibility

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
