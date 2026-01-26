---
title: Keep Browser Cache Enabled in DevTools
impact: MEDIUM-HIGH
impactDescription: 5-10× faster reloads in development
tags: dev, browser, cache, devtools
---

## Keep Browser Cache Enabled in DevTools

When Browser DevTools are open with "Disable cache" checked, Vite's aggressive caching is bypassed, causing slower reloads.

**Incorrect (cache disabled in DevTools):**

```plaintext
Browser DevTools → Network tab → ☑ "Disable cache"
Every file request bypasses Vite's cache
Hot reloads: 2-5 seconds
Pre-bundled deps re-downloaded
```

**Correct (cache enabled):**

```plaintext
Browser DevTools → Network tab → ☐ "Disable cache"
Vite's caching works as intended
Hot reloads: 10-50ms
Pre-bundled deps cached (max-age=31536000)
```

**Why this matters:**

Vite uses aggressive caching:
- Pre-bundled dependencies: `max-age=31536000,immutable`
- Source files: fast 304 responses
- HMR updates only changed modules

**Development profile recommendation:**

```bash
# Chrome with clean profile (no extensions)
google-chrome --user-data-dir=/tmp/vite-dev

# Or use incognito mode
# Extensions can intercept requests and slow Vite
```

**Problematic extensions:**
- Ad blockers
- Privacy extensions
- React DevTools (can slow large apps)

Reference: [Performance | Vite](https://vite.dev/guide/performance)
