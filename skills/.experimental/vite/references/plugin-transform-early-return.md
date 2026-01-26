---
title: Early Return in Transform Hooks
impact: CRITICAL
impactDescription: 10-100× faster file processing
tags: plugin, transform, filter, optimization
---

## Early Return in Transform Hooks

Transform hooks run on every file request. Check if the file matches your criteria before doing any heavy processing.

**Incorrect (processes all files):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    async transform(code, id) {
      const ast = parse(code)  // Expensive parse on EVERY file

      if (!id.endsWith('.mdx')) {
        return null  // Too late, already parsed
      }

      return transformMdx(ast)
    }
  }
}
```

**Correct (filter first, process later):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    async transform(code, id) {
      // Early return for non-matching files
      if (!id.endsWith('.mdx')) return

      // Only parse files we care about
      const ast = parse(code)
      return transformMdx(ast)
    }
  }
}
```

**Best practices:**
- Check file extension first
- Use simple string checks before regex
- Check for keywords in code before full parsing
- Use `filter` option if plugin supports it

Reference: [Performance | Vite](https://vite.dev/guide/performance)
