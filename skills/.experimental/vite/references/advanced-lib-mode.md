---
title: Configure Library Mode for Package Development
impact: LOW-MEDIUM
impactDescription: 2-3× smaller output, proper ESM/CJS support
tags: advanced, library, npm, package
---

## Configure Library Mode for Package Development

When building a library for npm, use Vite's library mode for optimized output formats with proper externalization.

**Incorrect (bundling dependencies into library):**

```javascript
// vite.config.js
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    // Using default app build settings
    // React bundled into library = 100KB+ bloat
    // Consumers get duplicate React
  }
})
```

**Correct (library mode with externals):**

```javascript
// vite.config.js
import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'MyLib',
      fileName: 'my-lib'
    },
    rollupOptions: {
      external: ['react', 'react-dom'],
      output: {
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM'
        }
      }
    }
  }
})
```

**package.json exports:**

```json
{
  "name": "my-lib",
  "type": "module",
  "exports": {
    ".": {
      "import": "./dist/my-lib.js",
      "require": "./dist/my-lib.cjs"
    }
  },
  "main": "./dist/my-lib.cjs",
  "module": "./dist/my-lib.js",
  "peerDependencies": {
    "react": "^18.0.0"
  }
}
```

**Performance tips:**
- Externalize all peer dependencies
- Use `preserveModules` for tree-shaking
- Generate TypeScript declarations with `vite-plugin-dts`

Reference: [Building for Production](https://vite.dev/guide/build)
