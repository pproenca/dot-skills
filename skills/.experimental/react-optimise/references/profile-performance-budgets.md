---
title: Enforce Performance Budgets in CI
impact: MEDIUM
impactDescription: prevents regressions, catches 90% of perf issues before merge
tags: profile, ci, lighthouse, bundle-size, budgets
---

## Enforce Performance Budgets in CI

Without automated enforcement, performance degrades incrementally — each PR adds a few KB or a slightly slower interaction until the app crosses unacceptable thresholds. CI performance budgets catch regressions at the PR level before they compound.

**Incorrect (no automated performance checks):**

```tsx
// package.json — no size or performance checks
{
  "scripts": {
    "build": "next build",
    "test": "vitest",
    "lint": "eslint ."
  }
}

// .github/workflows/ci.yml — only runs tests and lint
// name: CI
// jobs:
//   check:
//     steps:
//       - run: npm test
//       - run: npm run lint
//       # No bundle size check — grew from 180KB to 420KB over 6 months
//       # No Lighthouse check — LCP regressed from 1.2s to 3.8s unnoticed
```

**Correct (bundle size limits and Lighthouse scores enforced per PR):**

```bash
# Install size-limit for bundle analysis
npm install --save-dev size-limit @size-limit/preset-app
```

```tsx
// package.json — enforced size budgets
{
  "scripts": {
    "build": "next build",
    "test": "vitest",
    "lint": "eslint .",
    "size": "size-limit"
  },
  "size-limit": [
    {
      "path": ".next/static/chunks/*.js",
      "limit": "200 KB",
      "gzip": true
    },
    {
      "path": ".next/static/chunks/pages/index-*.js",
      "limit": "80 KB",
      "gzip": true
    }
  ]
}
```

```bash
# .github/workflows/ci.yml — performance gates
# jobs:
#   performance:
#     steps:
#       - run: npm run build
#       - run: npx size-limit --json | npx size-limit-action
#       - run: npx lhci autorun
#           # lighthouserc.json asserts:
#           # performance >= 0.9
#           # largest-contentful-paint <= 2500ms
#           # cumulative-layout-shift <= 0.1
```

Reference: [Size Limit — Performance Budget Tool](https://github.com/ai/size-limit)
