---
title: Enable CSS Minification in Production
impact: HIGH
impactDescription: 40-60% smaller CSS bundles
tags: bundle, minification, production, optimization, build
---

## Enable CSS Minification in Production

Ensure CSS minification is enabled for production builds. While Tailwind's JIT produces minimal CSS, minification removes whitespace and optimizes output further.

**Incorrect (no minification):**

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
  build: {
    cssMinify: false, // Disabled minification
  },
});
```

**Correct (minification enabled):**

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
  build: {
    cssMinify: "lightningcss", // Fast, modern minifier
  },
});
```

**For CLI builds:**

```bash
# Development (readable output)
npx @tailwindcss/cli -i input.css -o output.css

# Production (minified)
npx @tailwindcss/cli -i input.css -o output.css --minify
```

**Benefits:**
- 40-60% smaller file sizes
- Faster network transfer
- Improved Core Web Vitals

Reference: [Tailwind CSS Installation](https://tailwindcss.com/docs/installation)
