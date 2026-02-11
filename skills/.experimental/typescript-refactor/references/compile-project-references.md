---
title: Use Project References for Monorepo Builds
impact: MEDIUM
impactDescription: 3-10× faster incremental builds in large codebases
tags: compile, project-references, monorepo, incremental-builds
---

## Use Project References for Monorepo Builds

Project references split a monorepo into independently compilable units. Each project emits declarations once and downstream projects reference those declarations instead of re-type-checking source files. This enables parallel compilation and caching.

**Incorrect (single tsconfig compiles everything):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "strict": true,
    "outDir": "dist"
  },
  "include": ["src/**/*", "packages/**/*"]
}
```

**Correct (project references with composite projects):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "strict": true
  },
  "references": [
    { "path": "./packages/shared" },
    { "path": "./packages/api" },
    { "path": "./packages/web" }
  ]
}
```

```json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "declarationMap": true,
    "outDir": "dist"
  },
  "include": ["src/**/*"]
}
```

**Benefits:**
- `tsc --build` only recompiles changed projects
- Parallel compilation across independent projects
- IDE navigation works across project boundaries with declaration maps

Reference: [TypeScript Handbook - Project References](https://www.typescriptlang.org/docs/handbook/project-references.html)
