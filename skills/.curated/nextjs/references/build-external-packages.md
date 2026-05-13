---
title: Mark Node packages with native bindings or non-bundleable resolution as serverExternalPackages
impact: HIGH
impactDescription: prevents build failures with native bindings, eliminates bundle bloat from packages that can't ship as ESM, faster server builds
tags: build, server-external, native-bindings, node-require
---

## Mark Node packages with native bindings or non-bundleable resolution as serverExternalPackages

**Pattern intent:** some Node packages ship native `.node` binaries, use `require()` at runtime to resolve drivers, or pull in heavy peer trees that the bundler can't trace. Trying to bundle them either fails the build or produces a broken artifact. `serverExternalPackages` tells Next.js "don't try; load this from `node_modules` at runtime."

### Shapes to recognize

- A build error like "Module not found: Can't resolve './build/Release/...'" — almost always a native-binding package being bundled.
- `puppeteer`, `sharp`, `canvas`, `bcrypt`, `argon2`, `node-gyp`-built packages used in Server Components or route handlers without being listed.
- Database drivers (`pg`, `mysql2`, `better-sqlite3`, `@prisma/client`) imported from server-only code without externalization — sometimes works, sometimes catastrophically large bundles.
- A workaround `next.config.js` with custom webpack `externals: [...]` config — pre-Turbopack era; should be `serverExternalPackages` in App Router.
- A `try { require(...) }` wrapping an import to "be safe" — masks the real issue; configuring `serverExternalPackages` removes the need.

The canonical resolution: list the offenders in `serverExternalPackages` in `next.config`. Next.js loads them from `node_modules` at runtime rather than trying to bundle them.

**Incorrect (bundling native modules):**

```typescript
// next.config.ts
const nextConfig = {
  // No external packages configured
}

// lib/pdf.ts
import puppeteer from 'puppeteer'
// Build fails or produces oversized bundles
```

**Correct (excluding native modules):**

```typescript
// next.config.ts
const nextConfig = {
  serverExternalPackages: [
    'puppeteer',
    'sharp',
    'canvas',
    '@prisma/client',
    'bcrypt'
  ]
}

// lib/pdf.ts
import puppeteer from 'puppeteer'
// Loaded at runtime from node_modules
```

**Common packages to externalize:**
- Database drivers: `@prisma/client`, `pg`, `mysql2`
- Image processing: `sharp`, `canvas`
- Native bindings: `bcrypt`, `argon2`
- Browser automation: `puppeteer`, `playwright`
