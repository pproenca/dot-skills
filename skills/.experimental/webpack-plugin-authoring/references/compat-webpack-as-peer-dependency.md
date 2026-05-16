---
title: Declare webpack as peerDependency, Not dependency
impact: LOW-MEDIUM
impactDescription: prevents duplicate webpack installs and version drift
tags: compat, peer-dependency, packaging, package-json
---

## Declare webpack as peerDependency, Not dependency

Listing `webpack` in `dependencies` forces npm/yarn/pnpm to install a SECOND copy of webpack alongside the user's. This breaks `instanceof` checks (the plugin's `Compilation` is not the same class as the user's), corrupts persistent cache (different webpack instances serialize differently), and doubles install size. `peerDependencies` says "I work with whichever webpack the user installs" — the package manager warns on incompatible versions instead of silently installing a parallel one.

**Incorrect (webpack as a direct dependency):**

```json
{
  "name": "my-cool-plugin",
  "version": "1.0.0",
  "main": "src/index.js",
  "dependencies": {
    "webpack": "^5.0.0",
    "schema-utils": "^4.0.0"
  }
}
```

```text
npm ls webpack
my-cool-plugin@1.0.0
├── webpack@5.103.0     ← installed twice
└── my-cool-plugin@
    └── webpack@5.85.0  ← the plugin's copy

# Class identity tests fail:
# plugin's `Compilation instanceof user's Compilation` → false
```

**Correct (webpack as peer, schema-utils as direct):**

```json
{
  "name": "my-cool-plugin",
  "version": "1.0.0",
  "main": "src/index.js",
  "peerDependencies": {
    "webpack": "^5.0.0"
  },
  "devDependencies": {
    "webpack": "^5.95.0"
  },
  "dependencies": {
    "schema-utils": "^4.0.0"
  }
}
```

**The dependency triangle:**

| Package type | Where in package.json |
|---|---|
| `webpack` itself | `peerDependencies` (user provides) + `devDependencies` (your tests need it) |
| Plugin runtime deps you own (`schema-utils`, `jest-worker`) | `dependencies` |
| Optional peers (e.g., `@swc/core` for an SWC plugin) | `peerDependenciesMeta: { "@swc/core": { "optional": true } }` |
| TypeScript types for webpack | `devDependencies` (`@types/webpack` if you need types beyond webpack's own .d.ts) |

**Version range conventions (from `webpack-contrib`):**

```json
{
  "peerDependencies": {
    "webpack": "^5.1.0"
  }
}
```

- Use `^5.1.0` not `^5` — names the MINIMUM webpack version your plugin works against
- The minimum should be the version that introduced any APIs your plugin uses (e.g., `^5.99.0` if you use `compiler.hooks.validate`)
- DON'T pin to a single minor (`5.95.x`) — too restrictive for users

**Optional peers for sub-features:**

```json
{
  "peerDependencies": {
    "webpack": "^5.0.0",
    "@swc/core": "^1.0.0"
  },
  "peerDependenciesMeta": {
    "@swc/core": { "optional": true }
  }
}
```

This tells the package manager: "swc is needed if you want my SWC features, but the plugin works without it." No warning when missing.

**For dual webpack 4/5 support, both as peer with OR range:**

```json
{
  "peerDependencies": {
    "webpack": "^4.0.0 || ^5.0.0"
  }
}
```

Combined with runtime feature-detection (`compiler.webpack ? new-api : old-api`).

**npm 7+ auto-installs peerDependencies** — declaring them no longer means "user must remember to install." But declaring them in `dependencies` STILL causes the double-install problem.

Reference: [webpack-contrib repo conventions](https://github.com/webpack-contrib) · [npm — peerDependencies](https://docs.npmjs.com/cli/v10/configuring-npm/package-json#peerdependencies)
