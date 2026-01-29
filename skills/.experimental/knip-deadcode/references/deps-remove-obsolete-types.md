---
title: Remove Obsolete Type Definition Packages
impact: HIGH
impactDescription: reduces install time and avoids type conflicts
tags: deps, types, typescript, cleanup
---

## Remove Obsolete Type Definition Packages

Many packages now include bundled TypeScript types. Remove separate `@types/` packages when the main package includes types to avoid conflicts and reduce dependencies.

**Incorrect (separate types package when types are bundled):**

```json
{
  "dependencies": {
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/axios": "^0.14.0"
  }
}
```

Knip reports: `@types/axios` is unused (axios includes types).

**Correct (remove obsolete @types package):**

```json
{
  "dependencies": {
    "axios": "^1.6.0"
  }
}
```

**Check if types are bundled:**

1. Look for `types` or `typings` field in package.json
2. Check for `.d.ts` files in the package
3. Run `knip` - it detects unused @types packages

**When to keep @types packages:**
- Package has no bundled types
- You need a different version of types than bundled

Reference: [Unused Dependencies](https://knip.dev/typescript/unused-dependencies)
