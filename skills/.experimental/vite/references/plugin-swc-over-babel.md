---
title: Use SWC Instead of Babel for React
impact: HIGH
impactDescription: 20-70× faster transforms
tags: plugin, swc, babel, react, transforms
---

## Use SWC Instead of Babel for React

SWC is a Rust-based compiler that's 20-70× faster than Babel. For React projects, use `@vitejs/plugin-react-swc` instead of `@vitejs/plugin-react`.

**Incorrect (Babel-based transforms):**

```javascript
// vite.config.js
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: ['@emotion/babel-plugin']
      }
    })
  ]
})
// Babel processes every JSX file
```

**Correct (SWC-based transforms):**

```javascript
// vite.config.js
import react from '@vitejs/plugin-react-swc'

export default defineConfig({
  plugins: [react()]
})
// SWC handles JSX 20-70× faster
```

**When you must use Babel:**
- Using Babel-only plugins (some emotion configurations)
- Legacy decorator syntax not supported by SWC
- Custom Babel transforms with no SWC equivalent

**If using @vitejs/plugin-react without Babel config:**

```javascript
// vite.config.js
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    react()  // No babel option = esbuild for production
  ]
})
```

Reference: [Performance | Vite](https://vite.dev/guide/performance)
