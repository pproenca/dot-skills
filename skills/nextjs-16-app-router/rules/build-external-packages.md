---
title: Configure Server External Packages for Node Dependencies
impact: HIGH
impactDescription: prevents bundling issues, faster builds
tags: build, external-packages, node-modules, server
---

## Configure Server External Packages for Node Dependencies

Some Node.js packages with native bindings or complex dependencies should not be bundled. Use `serverExternalPackages` to exclude them from the server bundle.

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
