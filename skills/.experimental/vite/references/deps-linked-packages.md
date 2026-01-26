---
title: Handle Linked Dependencies in Monorepos
impact: HIGH
impactDescription: prevents broken module resolution
tags: deps, monorepo, linked, commonjs
---

## Handle Linked Dependencies in Monorepos

Linked packages (via npm link, yarn link, or workspace protocols) that aren't ESM need special handling. Add them to both `optimizeDeps.include` and `build.commonjsOptions.include`.

**Incorrect (linked CJS package breaks):**

```javascript
// vite.config.js
export default defineConfig({
  // Linked package 'my-lib' uses CommonJS
  // Vite treats it as source, not dependency
  // Module resolution fails
})
```

**Correct (explicit configuration for linked CJS):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    include: ['my-lib']  // Pre-bundle linked package
  },
  build: {
    commonjsOptions: {
      include: [/my-lib/, /node_modules/]
    }
  }
})
```

**For ESM linked packages:**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    exclude: ['my-esm-lib']  // Let browser handle ESM
  }
})
```

**Remember:** Restart dev server with `--force` after changing linked dependency configuration.

Reference: [Dependency Pre-Bundling](https://vite.dev/guide/dep-pre-bundling)
