---
title: Add a Type-Check Step to CI Separate from the Build
impact: LOW-MEDIUM
impactDescription: prevents shipping unchecked types
tags: tooling, ci, tsc, noemit
---

## Add a Type-Check Step to CI Separate from the Build

Bundlers like esbuild, swc, and Vite strip types without checking them, so a green build can still contain the exact type errors your migration set out to eliminate. A dedicated `tsc --noEmit` step is the only CI gate that actually enforces the types you added — without it, strictness flags you turned on are advisory.

**Incorrect (build is the only gate — types never checked):**

```json
{
  "scripts": {
    "build": "esbuild src/index.ts --bundle --outfile=dist/index.js",
    "ci": "npm run build"
  }
}
```

esbuild transpiles and discards types, so type errors sail through CI unseen.

**Correct (a separate type-check gate runs first):**

```json
{
  "scripts": {
    "build": "esbuild src/index.ts --bundle --outfile=dist/index.js",
    "typecheck": "tsc --noEmit",
    "ci": "npm run typecheck && npm run build"
  }
}
```

Reference: [tsconfig: noEmit](https://www.typescriptlang.org/tsconfig/#noEmit)
