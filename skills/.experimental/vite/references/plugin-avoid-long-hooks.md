---
title: Avoid Long Operations in Startup Hooks
impact: CRITICAL
impactDescription: prevents dev server startup delays
tags: plugin, hooks, buildStart, config, startup
---

## Avoid Long Operations in Startup Hooks

The `buildStart`, `config`, and `configResolved` hooks are awaited during dev server startup. Long operations in these hooks delay when you can access the site.

**Incorrect (blocking startup hooks):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    async buildStart() {
      // ESLint check blocks startup
      await eslint.lintFiles(['src/**/*.ts'])

      // File system operations block startup
      await glob('src/**/*.svg')
    }
  }
}
// Dev server unavailable until all files checked
```

**Correct (defer to transform or separate process):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    buildStart() {
      // Quick, non-blocking initialization only
      this.cache = new Map()
    },
    async transform(code, id) {
      // Do work per-file as needed
      if (id.endsWith('.ts')) {
        // Lint individual files on demand
      }
    }
  }
}
```

**Alternative:** Use `vite-plugin-checker` for non-blocking linting.

Reference: [Performance | Vite](https://vite.dev/guide/performance)
