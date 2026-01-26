---
title: Configure Output Directory and Caching
impact: MEDIUM
impactDescription: 50%+ faster CI rebuilds with caching
tags: build, output, caching, ci-cd
---

## Configure Output Directory and Caching

Proper output directory configuration enables better caching in CI/CD pipelines and prevents stale file issues.

**Incorrect (no caching strategy):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    outDir: 'dist'
    // CI rebuilds from scratch every time
    // node_modules/.vite not cached
    // 5+ minute builds
  }
})
```

**Correct (optimized for CI caching):**

```javascript
// vite.config.js
export default defineConfig({
  cacheDir: 'node_modules/.vite',  // Cache pre-bundled deps
  build: {
    outDir: 'dist',
    emptyOutDir: true
  }
})
```

```yaml
# .github/workflows/build.yml
- name: Cache Vite
  uses: actions/cache@v3
  with:
    path: node_modules/.vite
    key: vite-${{ hashFiles('package-lock.json') }}

# Rebuilds use cached pre-bundled dependencies
```

**Environment-specific output:**

```javascript
// vite.config.js
export default defineConfig(({ mode }) => ({
  build: {
    outDir: `dist/${mode}`
  }
}))
// dist/development, dist/production
```

**Benefits:**
- Cached pre-bundling across CI runs
- Faster incremental builds
- Clean separation of environments

Reference: [Build Options](https://vite.dev/config/build-options)
