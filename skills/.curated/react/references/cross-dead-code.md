---
title: Delete components, hooks, and utilities with zero importers
impact: MEDIUM-HIGH
impactDescription: removes bundle weight, reduces maintenance surface, prevents accidental copy-from-zombie
tags: cross, dead-code, unused, deletion, bundle-size
---

## Delete components, hooks, and utilities with zero importers

**This is a cross-cutting rule.** It cannot be seen from a single file — a file looks "valid" even if nothing imports it.

### Shapes to recognize

- Exported components that no other file imports (after route auto-discovery is accounted for).
- Custom hooks named `useX` that no other file imports.
- Utility functions exported from `*/lib`, `*/utils`, `*/helpers` with zero imports.
- "Legacy" / "Old" / "V1" / "Deprecated" prefixed exports kept "in case we need them."
- Type/interface exports that exist only because an internal helper got typed against them, but nothing external uses the helper either.
- Components that are imported only by *other dead components* (transitive dead code).

### Detection procedure

1. Build an import graph of the inventory: every `import` statement, every `export` declaration.
2. Start from the roots — route entry files (`page.tsx`, `layout.tsx`, top-level `app.tsx`), test entry points, public package entry points.
3. Mark everything reachable from a root as live.
4. Everything unmarked is dead. Order the dead set by file size (large modules first).
5. **Re-check three false-positive sources before deleting:**
   - **Dynamic imports** — `import('./foo')` inside a code-split route or feature flag.
   - **Public API surface** — files re-exported from a package `index.ts` may have external consumers not in the inventory.
   - **String-keyed registries** — code that resolves modules by name at runtime (less common in React, but check for `lazy(() => import(`./pages/${name}`))`).

If your tooling supports it, use `ts-prune`, `knip`, or `madge --orphans` for the initial pass, then verify by hand. Tooling alone overreports because of the three sources above.

### Multi-file example

**Incorrect (inventory finding — these files exist, nothing imports them):**

```text
src/components/LegacyButton.tsx        — 0 importers
src/components/OldHeader.tsx           — 0 importers
src/hooks/useDeprecatedAuth.ts         — 0 importers
src/lib/v1/                            — entire directory, 0 importers
src/components/HeroVariantC.tsx        — imported only by HeroVariantC.test.tsx
                                         (the test exists; the component does not ship anywhere)
```

**Correct (after deletion):**

```text
src/components/LegacyButton.tsx        — deleted
src/components/OldHeader.tsx           — deleted
src/hooks/useDeprecatedAuth.ts         — deleted
src/lib/v1/                            — deleted (entire directory)
src/components/HeroVariantC.tsx        — deleted (+ orphan test deleted)
```

Bundle size dropped by ~30 KB minified; one fewer place where a future contributor can accidentally copy stale patterns.

**Cross-file observation:**

> 5 files (≈ 412 lines, ≈ 18 KB minified) are unreachable from any route entry, public export, or non-test import. `HeroVariantC` is reachable only from its own test — the test is exercising an orphan. Delete the files and the orphan test.

**Reporting shape (what the audit emits):**

| File | Size | Importers | Action | Risk |
|---|---|---|---|---|
| `src/components/LegacyButton.tsx` | 6.1 KB | 0 | delete | none |
| `src/components/OldHeader.tsx` | 4.4 KB | 0 | delete | none |
| `src/hooks/useDeprecatedAuth.ts` | 3.0 KB | 0 | delete | check storybook for runtime use |
| `src/lib/v1/` | 12 files | 0 | delete | check if any package consumer imports `lib/v1/*` directly |
| `src/components/HeroVariantC.tsx` + test | 5.2 KB + 1.8 KB | 1 (own test) | delete both | none |

### When NOT to delete

- The file is referenced by a `lazy(() => import(...))` whose path is computed at runtime — verify by running the relevant code path.
- The repo is a published package and the file is in a public path (`index.ts`, `src/public/`) — external consumers may exist.
- The file is feature-flagged off but scheduled for re-enable — leave it but file a TODO with the flag name and the expected re-enable date.

### Risk before deleting

- Run the full test suite *after* deletion, not before — broken imports from dead files will surface.
- Check `package.json` for `"files"` and `"exports"` — exports may make a "dead" file public.
- One commit per logical group (one component + its test + its types). Easier to revert if a consumer surfaces.

Reference: [Removing unused code with TypeScript — ts-prune / knip](https://github.com/webpro-nl/knip)
