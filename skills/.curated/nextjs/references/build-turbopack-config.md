---
title: Don't disable Turbopack's persistent caching — the defaults are what give 5-10× faster restarts
impact: CRITICAL
impactDescription: 5-10× faster cold starts on large apps when persistent caching stays on; disabling it is the most common Next.js 16 perf regression
tags: build, turbopack, persistent-cache, config-regression
---

## Don't disable Turbopack's persistent caching — the defaults are what give 5-10× faster restarts

**Pattern intent:** Next.js 16's Turbopack ships persistent file-system caching enabled by default. The fast restart story depends on it. Configurations that toggle the cache off (often copied from old guides or copy-pasted from another project) silently drop the win.

### Shapes to recognize

- `experimental.turbo.persistentCaching: false` in `next.config.{js,ts,mjs}` — kills the persistent cache.
- A `.gitignore` rule excluding `.next/cache/turbopack` *plus* CI clearing `.next` between builds — guarantees a cold start every dev session locally, every build remotely.
- A pre-`dev`/pre-`build` script doing `rm -rf .next` "to be safe" — defeats the cache.
- Custom `webpack` configuration that conflicts with Turbopack (loaders pointing at `webpack` rather than `turbo.rules`) — falls back to webpack and loses Turbopack speed.
- A `next` invocation explicitly passing `--no-turbopack` somewhere in package.json scripts — silently downgrades.
- A Docker dev image that doesn't mount `.next/cache` as a volume — re-creates the cache every container start.

The canonical resolution: leave `experimental.turbo` defaults alone unless adding custom loaders/rules. Mount `.next/cache` if running in containers. Stop running pre-build clean steps in dev workflows.

Reference: [Next.js 16 Release Notes](https://nextjs.org/blog/next-16)

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
