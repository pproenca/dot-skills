---
title: Use esbuild for Minification
impact: HIGH
impactDescription: 20-40× faster than Terser
tags: build, minification, esbuild, terser
---

## Use esbuild for Minification

Vite uses esbuild for minification by default, which is 20-40× faster than Terser with only 1-2% larger output.

**Incorrect (slow Terser minification):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true
      }
    }
  }
})
// Minification takes 30+ seconds on large projects
```

**Correct (fast esbuild minification):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    minify: 'esbuild'  // Default, 20-40× faster
  }
})
// Minification completes in 1-2 seconds
```

**When Terser is needed:**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,  // Remove console.* (esbuild: use define)
        passes: 2            // Multiple compression passes
      },
      mangle: {
        properties: true     // Mangle property names
      }
    }
  }
})
// Use only when you need Terser-specific features
```

**Comparison:**
| Minifier | Speed | Output Size |
|----------|-------|-------------|
| esbuild | 20-40× faster | ~1-2% larger |
| terser | Slower | Slightly smaller |

Reference: [Build Options](https://vite.dev/config/build-options)
