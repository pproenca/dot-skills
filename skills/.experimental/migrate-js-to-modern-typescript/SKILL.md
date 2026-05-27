---
name: migrate-js-to-modern-typescript
description: Migrating a JavaScript codebase to TypeScript — converting .js files to .ts, adding types to existing JS, or tightening a loosely-typed TS project toward strict mode. Covers tsconfig and allowJs strategy, incremental strict-flag ratcheting (noImplicitAny, strictNullChecks, noUncheckedIndexedAccess), typing public surfaces, replacing `any` and unsafe casts with `unknown` and narrowing, validating runtime boundaries (JSON, env, API responses), converting CommonJS to ESM and prototypes to classes, and the build/CI changes a migration needs. Trigger even when the user only says "add types", "turn on strict mode", or "convert this file to TypeScript", and especially on a mixed JS/TS repo. Distinct from general TypeScript refactoring — this is the migration act itself, performed file by file while keeping the build green.
---
# JavaScript to TypeScript Migration Best Practices

Guide for taking a JavaScript codebase to strict, modern TypeScript without a big-bang rewrite. Contains 42 rules across 7 categories, prioritized by impact to drive an incremental, file-by-file migration that keeps the build compiling at every step.

## When to Apply

Reference these guidelines when:
- Converting a `.js` codebase to `.ts` (whole project or one module at a time)
- Adding types to existing JavaScript via JSDoc or annotations
- Choosing a `tsconfig` and `allowJs` strategy for a mixed JS/TS repo
- Turning on `strict` mode or individual strict flags on a large codebase
- Replacing `any`, `as` casts, and `!` assertions left over from a quick conversion
- Validating external data (JSON, env, API responses) so the types you wrote are true at runtime
- Converting CommonJS to ESM, prototypes to classes, and other JS idioms to TS
- Updating the build, runner, and CI to type-check and publish TypeScript

## How the Migration Flows

```
tsconfig & strategy → strictness ratchet → type the surfaces → kill any/casts
   → validate runtime boundaries → convert JS idioms → tooling/build/CI
```

Decisions at the front cascade: a wrong `tsconfig` or a top-down conversion order forces you to re-type modules twice, and an early `any` flood poisons everything downstream. Work from the front of this pipeline and from the leaves of the dependency graph inward.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Migration Setup & tsconfig | CRITICAL | `setup-` |
| 2 | Strictness Ratcheting | CRITICAL | `strict-` |
| 3 | Typing Public Surfaces | HIGH | `surface-` |
| 4 | Replacing `any` & Unsafe Casts | HIGH | `unsafe-` |
| 5 | Runtime Data Validation | MEDIUM-HIGH | `runtime-` |
| 6 | JS-to-TS Idiom Conversion | MEDIUM | `idiom-` |
| 7 | Tooling & Build Migration | LOW-MEDIUM | `tooling-` |

## Quick Reference

### 1. Migration Setup & tsconfig (CRITICAL)

- [`setup-allowjs-checkjs-bridge`](references/setup-allowjs-checkjs-bridge.md) — Enable allowJs and checkJs for incremental migration
- [`setup-migrate-leaves-first`](references/setup-migrate-leaves-first.md) — Convert dependency leaves before their dependents
- [`setup-jsdoc-before-rename`](references/setup-jsdoc-before-rename.md) — Type JS with JSDoc and @ts-check before renaming
- [`setup-prefer-ts-expect-error`](references/setup-prefer-ts-expect-error.md) — Prefer @ts-expect-error over @ts-ignore for suppressions
- [`setup-skiplibcheck-during-migration`](references/setup-skiplibcheck-during-migration.md) — Set skipLibCheck to silence third-party type noise
- [`setup-modern-module-resolution`](references/setup-modern-module-resolution.md) — Set module and moduleResolution to a modern pair
- [`setup-noemitonerror-isolatedmodules`](references/setup-noemitonerror-isolatedmodules.md) — Enable isolatedModules and noEmitOnError for safe output

### 2. Strictness Ratcheting (CRITICAL)

- [`strict-enable-flags-incrementally`](references/strict-enable-flags-incrementally.md) — Enable strict flags one at a time, not all at once
- [`strict-prioritize-null-checks`](references/strict-prioritize-null-checks.md) — Prioritize strictNullChecks for the highest bug yield
- [`strict-no-implicit-any`](references/strict-no-implicit-any.md) — Enable noImplicitAny to surface every untyped value
- [`strict-no-unchecked-indexed-access`](references/strict-no-unchecked-indexed-access.md) — Enable noUncheckedIndexedAccess for index safety
- [`strict-use-unknown-in-catch`](references/strict-use-unknown-in-catch.md) — Type caught errors as unknown, not any
- [`strict-exact-optional-property-types`](references/strict-exact-optional-property-types.md) — Separate missing from undefined with exactOptionalPropertyTypes

### 3. Typing Public Surfaces (HIGH)

- [`surface-annotate-exported-signatures`](references/surface-annotate-exported-signatures.md) — Annotate exported function signatures explicitly
- [`surface-replace-jsdoc-with-types`](references/surface-replace-jsdoc-with-types.md) — Replace JSDoc type tags with real annotations
- [`surface-type-default-params`](references/surface-type-default-params.md) — Type default and optional parameters precisely
- [`surface-interface-for-object-args`](references/surface-interface-for-object-args.md) — Convert loose object arguments to named interfaces
- [`surface-type-callbacks`](references/surface-type-callbacks.md) — Type callback and higher-order parameters
- [`surface-type-class-fields`](references/surface-type-class-fields.md) — Declare class field types instead of relying on assignment

### 4. Replacing any & Unsafe Casts (HIGH)

- [`unsafe-prefer-unknown-over-any`](references/unsafe-prefer-unknown-over-any.md) — Replace any with unknown at untrusted boundaries
- [`unsafe-eliminate-as-casts`](references/unsafe-eliminate-as-casts.md) — Replace as casts with narrowing or validation
- [`unsafe-avoid-double-assertion`](references/unsafe-avoid-double-assertion.md) — Avoid double assertions that force unrelated types
- [`unsafe-type-dynamic-property-access`](references/unsafe-type-dynamic-property-access.md) — Type dynamic property access with Records or index signatures
- [`unsafe-replace-function-type`](references/unsafe-replace-function-type.md) — Replace the Function type with specific call signatures
- [`unsafe-narrow-instead-of-nonnull`](references/unsafe-narrow-instead-of-nonnull.md) — Narrow values instead of using the non-null assertion

### 5. Runtime Data Validation (MEDIUM-HIGH)

- [`runtime-validate-external-data`](references/runtime-validate-external-data.md) — Validate external data at the boundary
- [`runtime-type-environment-variables`](references/runtime-type-environment-variables.md) — Parse and type environment variables once
- [`runtime-derive-types-from-schemas`](references/runtime-derive-types-from-schemas.md) — Derive static types from runtime schemas
- [`runtime-type-guards-at-boundaries`](references/runtime-type-guards-at-boundaries.md) — Write type guards for untyped library returns
- [`runtime-type-json-parse`](references/runtime-type-json-parse.md) — Type JSON.parse results through validation

### 6. JS-to-TS Idiom Conversion (MEDIUM)

- [`idiom-require-to-import`](references/idiom-require-to-import.md) — Convert require and module.exports to ESM syntax
- [`idiom-prototype-to-class`](references/idiom-prototype-to-class.md) — Convert prototype constructors to class syntax
- [`idiom-type-only-imports`](references/idiom-type-only-imports.md) — Use import type for type-only imports
- [`idiom-replace-arguments-object`](references/idiom-replace-arguments-object.md) — Replace the arguments object with rest parameters
- [`idiom-enum-to-union-or-const`](references/idiom-enum-to-union-or-const.md) — Convert frozen-object enums to const objects or unions
- [`idiom-default-export-to-named`](references/idiom-default-export-to-named.md) — Prefer named exports over default exports
- [`idiom-optional-chaining-over-guards`](references/idiom-optional-chaining-over-guards.md) — Replace manual existence guards with optional chaining

### 7. Tooling & Build Migration (LOW-MEDIUM)

- [`tooling-declare-untyped-modules`](references/tooling-declare-untyped-modules.md) — Provide ambient declarations for untyped dependencies
- [`tooling-install-types-packages`](references/tooling-install-types-packages.md) — Install @types packages before casting library returns
- [`tooling-use-tsx-over-ts-node`](references/tooling-use-tsx-over-ts-node.md) — Run TypeScript directly with tsx instead of ts-node flags
- [`tooling-emit-declaration-files`](references/tooling-emit-declaration-files.md) — Emit declaration files for migrated libraries
- [`tooling-typecheck-in-ci`](references/tooling-typecheck-in-ci.md) — Add a type-check step to CI separate from the build

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

## Related Skills

- `typescript-refactor` — Refactoring and modernizing code that is already TypeScript
- `typescript-advanced-patterns` — Advanced type-level patterns once the migration is done

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
