---
title: Use Node.js 20+ for Optimal Performance
impact: CRITICAL
impactDescription: required for upgrade tool, enables modern optimizations
tags: build, node, runtime, compatibility, tooling
---

## Use Node.js 20+ for Optimal Performance

Tailwind CSS v4 and its upgrade tool require Node.js 20 or higher. Older Node versions may cause build failures or suboptimal performance.

**Incorrect (outdated Node version):**

```json
{
  "engines": {
    "node": ">=16.0.0"
  }
}
```

```bash
# Node 16/18 may cause issues
npx @tailwindcss/upgrade
# Error: Requires Node.js 20+
```

**Correct (modern Node version):**

```json
{
  "engines": {
    "node": ">=20.0.0"
  }
}
```

```bash
# Node 20+ runs optimally
npx @tailwindcss/upgrade
# Upgrade completes successfully
```

**Benefits:**
- Full compatibility with Tailwind v4 tooling
- Better performance from V8 engine improvements
- Access to modern JavaScript features
- Required for automated migration

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
