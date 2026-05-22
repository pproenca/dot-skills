---
title: Run TypeScript Directly with tsx Instead of ts-node Flags
impact: LOW-MEDIUM
impactDescription: eliminates fragile loader configuration
tags: tooling, tsx, ts-node, esm
---

## Run TypeScript Directly with tsx Instead of ts-node Flags

ts-node needs brittle loader flags (`--loader ts-node/esm`, `--esm`, experimental specifier resolution) that break across Node versions and module settings — a recurring time sink mid-migration when the module system is in flux. tsx, built on esbuild, runs `.ts` files directly with both ESM and CommonJS support and no per-run type-check cost, so dev scripts stop fighting the loader.

**Incorrect (ts-node with brittle ESM flags):**

```json
{
  "scripts": {
    "dev": "node --loader ts-node/esm --experimental-specifier-resolution=node src/server.ts"
  }
}
```

This breaks whenever Node deprecates `--loader` or the project's module
setting changes, forcing another round of flag archaeology.

**Correct (tsx runs the file directly):**

```json
{
  "scripts": {
    "dev": "tsx watch src/server.ts"
  }
}
```

tsx only transpiles, so keep a separate `tsc --noEmit` step for type checking.

Reference: [tsx documentation](https://tsx.is/)
