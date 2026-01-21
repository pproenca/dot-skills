---
title: Enable Turbopack File System Caching
impact: CRITICAL
impactDescription: 5-10× faster cold starts on large apps
tags: build, turbopack, caching, development
---

## Enable Turbopack File System Caching

Next.js 16 uses Turbopack by default with file system caching. Ensure your configuration doesn't disable these optimizations.

**Incorrect (disabling Turbopack features):**

```typescript
// next.config.ts
const nextConfig = {
  experimental: {
    turbo: {
      // Disabling caching slows down restarts
      persistentCaching: false
    }
  }
}
```

**Correct (leveraging Turbopack defaults):**

```typescript
// next.config.ts
const nextConfig = {
  // Turbopack is default in Next.js 16
  // File system caching is enabled by default
  experimental: {
    turbo: {
      // Add custom loaders if needed
      rules: {
        '*.svg': {
          loaders: ['@svgr/webpack'],
          as: '*.js'
        }
      }
    }
  }
}
```

**Development command:**

```bash
# Turbopack is now the default bundler
next dev

# Explicitly enable for clarity
next dev --turbopack
```

**Note:** Turbopack caches to `.next/cache/turbopack`. Don't add this to `.gitignore` locally for persistent caching across restarts.

Reference: [Next.js 16 Release Notes](https://nextjs.org/blog/next-16)
