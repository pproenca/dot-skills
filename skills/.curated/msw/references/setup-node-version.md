---
title: Require Node.js 18+ for MSW v2
impact: CRITICAL
impactDescription: MSW v2 requires Node 18+; older versions cause complete failure
tags: setup, node, version, requirements, compatibility
---

## Require Node.js 18+ for MSW v2

MSW v2 sets Node.js 18.0.0 as the minimum supported version. Older versions lack native `fetch` and other required APIs, causing complete mocking failure.

**Incorrect (using unsupported Node version):**

```json
// package.json
{
  "engines": {
    "node": ">=14.0.0"
  }
}
```

```bash
# Node 16 - MSW v2 fails silently or throws cryptic errors
$ node -v
v16.20.0

$ npm test
# ReferenceError: fetch is not defined
# or: Cannot read properties of undefined
```

**Correct (enforce Node 18+ requirement):**

```json
// package.json
{
  "engines": {
    "node": ">=18.0.0"
  }
}
```

```yaml
# .nvmrc
18
```

```yaml
# CI configuration (GitHub Actions)
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
```

**Verify installation:**

```bash
# Check Node version
node -v  # Should be v18.x.x or higher

# Check MSW version
npm ls msw  # Should be v2.x.x
```

**When NOT to use this pattern:**
- If stuck on Node 16, use MSW v1.x instead (with different API patterns)

Reference: [MSW v2 Migration - Requirements](https://mswjs.io/docs/migrations/1.x-to-2.x/)
