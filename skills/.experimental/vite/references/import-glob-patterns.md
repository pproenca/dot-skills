---
title: Use Glob Imports Carefully
impact: MEDIUM
impactDescription: prevents 100+ unnecessary module loads
tags: import, glob, dynamic, bundling
---

## Use Glob Imports Carefully

Vite's `import.meta.glob` is useful for dynamic imports but can accidentally import hundreds of files. Use specific patterns and eager loading judiciously.

**Incorrect (too broad, eager loading):**

```typescript
// Eagerly loads ALL files in pages directory
const modules = import.meta.glob('./pages/**/*.tsx', { eager: true })
// 100 pages = 100 modules in initial bundle

// Too broad pattern
const icons = import.meta.glob('./assets/**/*')
// Matches everything, including large images
```

**Correct (specific patterns, lazy by default):**

```typescript
// Lazy loading (default) - loads on demand
const modules = import.meta.glob('./pages/**/*.tsx')
// modules['/pages/Home.tsx']() returns Promise<Module>

// Specific pattern for just what you need
const routes = import.meta.glob('./pages/[!_]*.tsx')
// Excludes files starting with underscore

// Eager only for small sets
const locales = import.meta.glob('./locales/*.json', { eager: true })
// Small JSON files, ok to eager load
```

**With typed imports:**

```typescript
const modules = import.meta.glob<{ default: React.ComponentType }>(
  './pages/*.tsx'
)
```

**Query parameters:**

```typescript
// Import as URL strings
const images = import.meta.glob('./assets/icons/*.svg', {
  query: '?url',
  import: 'default'
})
```

Reference: [Features | Vite](https://vite.dev/guide/features)
