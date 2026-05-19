---
title: Ship Library Types with `exports` and `typesVersions` Maps
impact: MEDIUM
impactDescription: ensures 100% of consumers across CJS/ESM/bundler/node resolve types correctly; prevents "works on my repo" reports
tags: decl, library-publishing, exports-map, types-versions, conditional-exports
---

## Ship Library Types with `exports` and `typesVersions` Maps

A library that just sets `"types": "./dist/index.d.ts"` works under the legacy `node` module resolution and almost nowhere else. Modern consumers — Node ESM, Bun, Vite, TypeScript with `moduleResolution: "bundler"` or `"node16"` — go through `package.json`'s `exports` field, with conditional resolution by environment. Getting this wrong means some consumers see your types and others don't; some import the ESM build and others the CJS; and the diagnoses involve `tsc --traceResolution` output that even authors find painful. The reliable shape is small, but every key matters.

**Incorrect (only `main` and `types` — modern resolvers find nothing):**

```jsonc
// package.json
{
  "name": "acme-sdk",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts"
  // No `exports` field. Under moduleResolution: "node16" / "nodenext" / "bundler",
  // consumers report "Cannot find module 'acme-sdk' or its corresponding type declarations."
}
```

**Correct (modern `exports` map with conditional resolution; `typesVersions` as legacy fallback):**

```jsonc
// package.json
{
  "name": "acme-sdk",
  "type": "module",
  "main": "./dist/index.cjs",          // legacy CJS resolvers
  "module": "./dist/index.js",          // bundlers that read `module`
  "types": "./dist/index.d.ts",         // legacy TS (moduleResolution: "node")
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",     // MUST come first within a condition block
      "import": "./dist/index.js",
      "require": "./dist/index.cjs"
    },
    "./client": {
      "types": "./dist/client.d.ts",
      "import": "./dist/client.js",
      "require": "./dist/client.cjs"
    },
    "./package.json": "./package.json"  // tooling reads this
  },
  "typesVersions": {                    // legacy TS subpath types resolution
    "*": {
      "client": ["./dist/client.d.ts"]
    }
  }
}
```

```jsonc
// Consumer's tsconfig.json — any of these will now resolve correctly
{
  "compilerOptions": {
    "moduleResolution": "bundler"  // or "node16", "nodenext"
  }
}
```

Five rules that catch the common mistakes:

1. **`types` must be the first key in each `exports` condition block.** Resolvers walk top-down and stop at the first match. Putting `"import"` before `"types"` makes TS read the `.js` file as types and fail.
2. **Include both `import` and `require`** for any subpath consumers might use under either module system. A package without `require` is unimportable from CJS even if a CJS build exists on disk.
3. **Subpath exports must be explicit.** Once you have an `exports` field, *unlisted* subpaths are inaccessible — `import 'acme-sdk/internal/util'` errors. This is the feature, not a bug.
4. **Keep `typesVersions` only for legacy support.** It overlaps with `exports`'s `types` condition. Modern resolvers prefer `exports`; old ones need `typesVersions`. Maintain both during migration, drop `typesVersions` when `moduleResolution: "node"` is no longer a concern.
5. **Expose `./package.json`.** Tools (Vite, Webpack, monorepo linkers, type-version detectors) read it; without an explicit entry, they error under `moduleResolution: "bundler"`.

Validate the resulting package with `arethetypeswrong` (`@arethetypeswrong/cli`) before publishing — it simulates every consumer scenario and reports broken paths.

**When NOT to apply:**
- Internal monorepo packages where the consumer's `tsconfig` is under your control — direct `"types"` and `"main"` are usually enough.
- Pure types-only packages (`@types/*`-style) — they need only `types` and don't go through the `exports` machinery.

**Scope delta:**
- No existing TypeScript skill in this repo covers library type publishing. Companion to `[[dsl-narrow-api-surface]]`: that rule controls *what* a library exports, this rule controls *how* those exports resolve across consumer toolchains.

Reference: [Node.js — Package `exports` Field](https://nodejs.org/api/packages.html#exports) | [Are The Types Wrong](https://arethetypeswrong.github.io/)
