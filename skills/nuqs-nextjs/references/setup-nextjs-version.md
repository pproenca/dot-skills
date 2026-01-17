---
title: Ensure Compatible Next.js Version
impact: CRITICAL
impactDescription: prevents cryptic runtime errors from version mismatch
tags: setup, nextjs, version, compatibility, app-router
---

## Ensure Compatible Next.js Version

nuqs requires specific Next.js versions depending on the router you use. Using incompatible versions causes runtime errors or missing functionality.

**Version Requirements:**

| Router | Minimum Next.js | Notes |
|--------|-----------------|-------|
| App Router | 14.2.0+ | Full support including streaming |
| App Router (basic) | 14.0.0+ | Limited features |
| Pages Router | 12.0.0+ | Full support |

**Check your version:**

```bash
npm list next
# or
yarn why next
# or
pnpm why next
```

**Incorrect (outdated Next.js):**

```json
{
  "dependencies": {
    "next": "13.5.0",
    "nuqs": "^2.0.0"
  }
}
// May cause: "Cannot read property 'push' of undefined"
// Or: URL updates not reflected
```

**Correct (compatible version):**

```json
{
  "dependencies": {
    "next": "14.2.0",
    "nuqs": "^2.0.0"
  }
}
```

**Upgrade command:**

```bash
npm install next@latest
# or
yarn add next@latest
# or
pnpm add next@latest
```

**Common symptoms of version mismatch:**
- `useQueryState` returns undefined
- URL doesn't update on state change
- Hydration mismatches
- `TypeError: Cannot read property 'push' of undefined`

Reference: [nuqs Requirements](https://nuqs.dev/docs/getting-started)
