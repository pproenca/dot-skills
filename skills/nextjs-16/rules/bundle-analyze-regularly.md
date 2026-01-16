---
title: Analyze Bundle Size Regularly
impact: CRITICAL
impactDescription: Bundle creep is silent; regular analysis catches 50-200KB regressions before they compound into multi-second load times
tags: bundle, bundle-analyzer, performance, monitoring
---

## Analyze Bundle Size Regularly

Bundle size grows silently. A "small" dependency here, a misplaced `'use client'` there, and suddenly your app ships 500KB of JavaScript. Use `@next/bundle-analyzer` to visualize and monitor your bundle.

**Setup bundle analyzer:**

```bash
npm install @next/bundle-analyzer
```

```javascript
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

module.exports = withBundleAnalyzer({
  // your config
})
```

```bash
# Run analysis
ANALYZE=true npm run build
```

**What to look for:**

```
# Warning signs in bundle analysis:

1. Large chunks (>100KB):
   ├── node_modules/moment/         67KB  → Replace with date-fns
   ├── node_modules/lodash/         70KB  → Use lodash-es
   └── @heroicons/react/            45KB  → Direct imports

2. Duplicated code:
   ├── react (in main chunk)
   └── react (in vendor chunk)      → Check package versions

3. Unexpected client components:
   └── components/DataTable/        150KB → Should be Server Component?
```

**Automated bundle budget in CI:**

```javascript
// next.config.js
module.exports = {
  experimental: {
    // Fail build if any page exceeds limits
    bundlePagesRouterDependencies: true,
  },
}
```

```yaml
# .github/workflows/bundle-check.yml
- name: Build and analyze
  run: ANALYZE=true npm run build

- name: Check bundle size
  run: |
    # Fail if main JS exceeds 250KB
    size=$(stat -f%z .next/static/chunks/main-*.js)
    if [ $size -gt 256000 ]; then
      echo "Bundle too large: $size bytes"
      exit 1
    fi
```

**Common findings and fixes:**

| Finding | Impact | Fix |
|---------|--------|-----|
| Icon library in bundle | 50-200KB | Direct imports or `optimizePackageImports` |
| Moment.js | 67KB | Replace with `date-fns` |
| Full lodash | 70KB | Use `lodash-es` with named imports |
| Unused 'use client' | 50-250KB | Move boundary deeper |

**When NOT to use this pattern:**
- Prototyping phase (optimize later)
- Bundle is already optimized and stable

Reference: [Next.js Bundle Analyzer](https://nextjs.org/docs/app/building-your-application/optimizing/bundle-analyzer)
