---
title: Enable Turbopack for Faster Development
impact: CRITICAL
impactDescription: 5-10× faster Fast Refresh compared to Webpack; reduces HMR from seconds to milliseconds on large codebases
tags: bundle, turbopack, development, dx
---

## Enable Turbopack for Faster Development

Turbopack is Next.js's Rust-based bundler, delivering dramatically faster compilation. It's the default in Next.js 16 for new projects and stable for both development and production builds.

**Development mode (default in Next.js 16):**

```bash
# Turbopack enabled by default in Next.js 16
next dev

# Explicitly enable for older versions
next dev --turbopack
```

**Production builds:**

```bash
# Turbopack builds (stable in Next.js 16)
next build --turbopack
```

**Performance comparison:**

| Operation | Webpack | Turbopack |
|-----------|---------|-----------|
| Initial compile | 5-15s | 1-3s |
| Fast Refresh | 500-2000ms | 50-200ms |
| Route compile | 1-5s | 200-500ms |

**Turbopack benefits:**
- Incremental computation (only rebuilds changed files)
- Rust-based (faster than JavaScript bundlers)
- Automatic import optimization (no `optimizePackageImports` needed)
- Native TypeScript and JSX support

**Migration checklist:**

```javascript
// next.config.js - Remove Webpack-specific config
module.exports = {
  // ❌ Remove if only used for development
  webpack: (config) => {
    // Custom webpack config may need alternatives
    return config
  },

  // ✓ Keep - these work with Turbopack
  experimental: {
    ppr: true,
  },
}
```

**Check compatibility:**

```bash
# See Turbopack compatibility warnings
next dev --turbopack 2>&1 | grep -i "turbopack"
```

**Common compatibility issues:**
- Custom Webpack plugins (may need alternatives)
- `@next/bundle-analyzer` (use build output instead)
- Some CSS-in-JS libraries (check docs)

**When NOT to use Turbopack:**
- Custom Webpack plugins with no Turbopack equivalent
- Specific build requirements not yet supported
- Production if you need Webpack-specific optimizations

Reference: [Next.js Turbopack](https://nextjs.org/docs/app/api-reference/turbopack)
