---
title: Target Modern Browsers
impact: HIGH
impactDescription: 30-50% less transpilation overhead
tags: build, target, transpilation, browsers
---

## Target Modern Browsers

Vite defaults to modern browser targets. Explicitly setting `esnext` for internal tools or adjusting targets based on your audience reduces unnecessary transpilation.

**Incorrect (over-transpiling for legacy browsers):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    target: 'es2015'  // Transpiles modern syntax unnecessarily
    // async/await → generators
    // optional chaining → verbose checks
    // 30% larger output, slower builds
  }
})
```

**Correct (modern targets):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    // Default: 'baseline-widely-available'
    // Chrome 107+, Edge 107+, Firefox 104+, Safari 16
    target: 'esnext'  // For internal tools, Electron apps
  }
})
```

**For specific browser support:**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    target: ['es2020', 'chrome87', 'safari14']
  }
})
```

**For legacy support (when truly needed):**

```javascript
// vite.config.js
import legacy from '@vitejs/plugin-legacy'

export default defineConfig({
  plugins: [
    legacy({
      targets: ['defaults', 'not IE 11']
    })
  ]
})
// Generates both modern and legacy bundles
// Modern users get fast bundle, legacy get polyfills
```

Reference: [Build Options](https://vite.dev/config/build-options)
