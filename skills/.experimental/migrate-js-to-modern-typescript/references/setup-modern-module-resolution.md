---
title: Set module and moduleResolution to a Modern Pair
impact: HIGH
impactDescription: prevents import resolution mismatches
tags: setup, moduleresolution, esm, tsconfig
---

## Set module and moduleResolution to a Modern Pair

Legacy `"moduleResolution": "node"` (now aliased `node10`) ignores `package.json` `exports` maps, so it resolves imports differently from your bundler and from Node's ESM loader — code that passes `tsc` then fails to resolve at runtime. Modern `"bundler"` or `"nodenext"` resolution matches how the code is actually loaded.

**Incorrect (legacy resolution — tsc and runtime disagree):**

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "moduleResolution": "node"
  }
}
```

`node` ignores `exports` fields, so it may resolve a package's CommonJS
entry while your bundler picks the ESM build — different types, runtime
surprises that `tsc` never warned about.

**Correct (bundler resolution for a bundled app):**

```json
{
  "compilerOptions": {
    "module": "esnext",
    "moduleResolution": "bundler"
  }
}
```

`bundler` honours `exports` maps exactly as esbuild, Vite, and webpack do.
For a Node service with no bundler, use `"module": "nodenext"` instead,
which also requires explicit file extensions on relative imports.

Reference: [TypeScript 5.0 Release Notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-0.html)
