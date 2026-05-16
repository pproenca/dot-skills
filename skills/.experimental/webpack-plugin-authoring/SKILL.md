---
name: webpack-plugin-authoring
description: Use this skill whenever writing, reviewing, or debugging webpack 5 plugins — covers hook selection (compiler vs compilation, tap vs tapAsync, processAssets stages), the asset pipeline (emitAsset, source classes, info metadata, source maps), watch-mode and persistent caching (file/context/missing/buildDependencies), plugin lifecycle (constructor purity, multi-compiler isolation, shutdown cleanup), schema-utils validation, WebpackError reporting, jest-worker parallelism, and compatibility patterns (compiler.webpack namespace, peerDependencies, getCompilationHooks WeakMap). Trigger even if the user doesn't explicitly mention "best practices" — anytime an `apply(compiler)` method is being written, hooks are being tapped, or a plugin imports from `webpack-sources`, the rules in this skill apply. Patterns are drawn from production plugins like mini-css-extract-plugin, terser-webpack-plugin, compression-webpack-plugin, and Next.js's webpack plugins.
---

# dot-skills Webpack 5 Plugins Best Practices

Comprehensive guide for writing correct, performant webpack 5 plugins. Contains 44 rules across 8 categories (8 hook + 7 asset + 5 cache + 5 life + 4 schema + 5 diag + 5 perf + 5 compat = 44), ordered by the authoring lifecycle: hook choice is the foundation, then asset manipulation, then caching/watch-mode correctness, then lifecycle hygiene, then user-facing concerns (schema validation, error reporting), then performance, then packaging.

Patterns are derived from `webpack/webpack`, the `webpack-contrib` plugin suite (mini-css-extract, terser, compression, copy, css-minimizer), and Next.js's webpack integration in `vercel/next.js`.

## When to Apply

Reference these rules whenever:

- Writing a new plugin (defining `apply(compiler)`, picking which hook to tap)
- Reviewing existing plugin code for correctness or performance
- Debugging "why isn't my plugin's output showing up" — usually a hook/stage mismatch
- Adding asset manipulation logic (`processAssets`, `emitAsset`, `updateAsset`)
- Fixing watch-mode staleness or persistent-cache poisoning
- Migrating a plugin from webpack 4 to webpack 5 (or supporting both)
- Publishing a plugin to npm (export shape, peerDependencies, schema)

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Hook Selection & Tap Patterns | CRITICAL | `hook-` |
| 2 | Asset Pipeline | CRITICAL | `asset-` |
| 3 | Caching & Watch Mode | HIGH | `cache-` |
| 4 | Plugin Lifecycle & State | HIGH | `life-` |
| 5 | Schema & Options Validation | MEDIUM-HIGH | `schema-` |
| 6 | Errors, Warnings & Logging | MEDIUM-HIGH | `diag-` |
| 7 | Performance & Parallelism | MEDIUM | `perf-` |
| 8 | Compatibility & Packaging | LOW-MEDIUM | `compat-` |

## Quick Reference

### 1. Hook Selection & Tap Patterns (CRITICAL)

- [`hook-tap-method-matches-hook-type`](references/hook-tap-method-matches-hook-type.md) — Match `tap`/`tapAsync`/`tapPromise` to the hook's Sync/Async type
- [`hook-thiscompilation-vs-compilation`](references/hook-thiscompilation-vs-compilation.md) — Use `thisCompilation` to skip child compilations
- [`hook-process-assets-stage`](references/hook-process-assets-stage.md) — Pick the right `PROCESS_ASSETS_STAGE_*` for your mutation
- [`hook-prefer-process-assets-over-emit`](references/hook-prefer-process-assets-over-emit.md) — Mutate in `processAssets`, not `emit`
- [`hook-bail-hook-return-semantics`](references/hook-bail-hook-return-semantics.md) — Return `undefined` from bail hooks unless intentionally stopping
- [`hook-tap-once-not-per-compilation`](references/hook-tap-once-not-per-compilation.md) — Register compiler hooks once in `apply`, not inside compilation hooks
- [`hook-name-matches-class-name`](references/hook-name-matches-class-name.md) — Use a stable tap name equal to the class name
- [`hook-normal-module-factory-stages`](references/hook-normal-module-factory-stages.md) — Tap `normalModuleFactory` at the right resolution stage (beforeResolve vs resolve vs afterResolve)

### 2. Asset Pipeline (CRITICAL)

- [`asset-emit-asset-not-direct-assignment`](references/asset-emit-asset-not-direct-assignment.md) — Use `emitAsset`/`updateAsset`, never `compilation.assets[name] = ...`
- [`asset-source-from-compiler-webpack`](references/asset-source-from-compiler-webpack.md) — Import source classes from `compiler.webpack.sources`
- [`asset-preserve-source-maps`](references/asset-preserve-source-maps.md) — Use `SourceMapSource`/`ReplaceSource` to keep maps attached
- [`asset-set-info-metadata`](references/asset-set-info-metadata.md) — Set `info.immutable`, `info.contenthash`, `info.related` when emitting
- [`asset-content-hash-via-output-options`](references/asset-content-hash-via-output-options.md) — Hash via `compilation.outputOptions.hashFunction`, not hardcoded md5
- [`asset-delete-then-emit-loses-info`](references/asset-delete-then-emit-loses-info.md) — Use `renameAsset` to move; `deleteAsset`+`emitAsset` severs chunk references
- [`asset-buffer-not-source-for-binary`](references/asset-buffer-not-source-for-binary.md) — Use `buffer()` not `source()` for binary assets

### 3. Caching & Watch Mode (HIGH)

- [`cache-add-file-dependencies`](references/cache-add-file-dependencies.md) — Add read files to `compilation.fileDependencies`
- [`cache-context-dependencies-for-directories`](references/cache-context-dependencies-for-directories.md) — Use `contextDependencies` for directory scans
- [`cache-missing-dependencies-for-optional-files`](references/cache-missing-dependencies-for-optional-files.md) — Add probed-but-absent paths to `missingDependencies`
- [`cache-build-dependencies-for-persistent-cache`](references/cache-build-dependencies-for-persistent-cache.md) — Declare `buildDependencies` for persistent cache invalidation
- [`cache-use-input-file-system`](references/cache-use-input-file-system.md) — Read via `compiler.inputFileSystem`, not Node `fs`

### 4. Plugin Lifecycle & State (HIGH)

- [`life-constructor-stores-options-only`](references/life-constructor-stores-options-only.md) — Constructor only validates and stores; side effects belong in `apply()`
- [`life-no-mutable-state-across-builds`](references/life-no-mutable-state-across-builds.md) — Scope mutable state per-compilation via local `const` or `WeakMap`
- [`life-multi-compiler-isolation`](references/life-multi-compiler-isolation.md) — One plugin instance per compiler; or use `WeakMap<Compiler, T>`
- [`life-cleanup-in-shutdown-hook`](references/life-cleanup-in-shutdown-hook.md) — Clean up workers, watchers, fds in `compiler.hooks.shutdown`
- [`life-defensively-copy-user-options`](references/life-defensively-copy-user-options.md) — Never mutate the user's options object

### 5. Schema & Options Validation (MEDIUM-HIGH)

- [`schema-validate-with-schema-utils`](references/schema-validate-with-schema-utils.md) — Validate via `schema-utils.validate()` and a JSON Schema
- [`schema-name-and-base-data-path`](references/schema-name-and-base-data-path.md) — Set `name` and `baseDataPath` for navigable error messages
- [`schema-additional-properties-false`](references/schema-additional-properties-false.md) — Set `additionalProperties: false` on every object to catch typos
- [`schema-tap-into-validate-hook`](references/schema-tap-into-validate-hook.md) — Defer cross-field validation to `compiler.hooks.validate` (5.106+)

### 6. Errors, Warnings & Logging (MEDIUM-HIGH)

- [`diag-push-webpack-error-not-throw`](references/diag-push-webpack-error-not-throw.md) — Push `WebpackError` to `compilation.errors`, don't throw
- [`diag-use-compilation-get-logger`](references/diag-use-compilation-get-logger.md) — Log via `compilation.getLogger('Plugin')`, not console
- [`diag-attach-loc-to-errors`](references/diag-attach-loc-to-errors.md) — Attach `loc` and `module` to errors for IDE click-through
- [`diag-warnings-vs-errors-exit-codes`](references/diag-warnings-vs-errors-exit-codes.md) — Errors fail the build; warnings don't — choose intentionally
- [`diag-progress-reporting`](references/diag-progress-reporting.md) — Report progress via `context.reportProgress` (opt in with `context: true`)

### 7. Performance & Parallelism (MEDIUM)

- [`perf-jest-worker-for-cpu-bound-work`](references/perf-jest-worker-for-cpu-bound-work.md) — Offload CPU-bound work to a `jest-worker` pool
- [`perf-cache-results-with-compilation-cache`](references/perf-cache-results-with-compilation-cache.md) — Cache expensive work via `compilation.getCache(name).providePromise`
- [`perf-traverse-chunks-not-modules`](references/perf-traverse-chunks-not-modules.md) — Iterate `compilation.chunks` not `compilation.modules` when possible
- [`perf-avoid-source-toString-in-hot-paths`](references/perf-avoid-source-toString-in-hot-paths.md) — Avoid `source().toString()` for assets you only inspect
- [`perf-respect-experimental-options`](references/perf-respect-experimental-options.md) — Honor `experiments.cacheUnaffected` / `incremental`

### 8. Compatibility & Packaging (LOW-MEDIUM)

- [`compat-webpack-as-peer-dependency`](references/compat-webpack-as-peer-dependency.md) — Declare `webpack` as `peerDependencies`, not `dependencies`
- [`compat-use-compiler-webpack-namespace`](references/compat-use-compiler-webpack-namespace.md) — Use `compiler.webpack.*` instead of `require('webpack')`
- [`compat-custom-hooks-via-weakmap`](references/compat-custom-hooks-via-weakmap.md) — Expose custom hooks via static `getCompilationHooks` + `WeakMap`
- [`compat-feature-detection-not-version-check`](references/compat-feature-detection-not-version-check.md) — Detect APIs directly; don't parse `webpack/package.json` version
- [`compat-export-shape-and-cjs-esm`](references/compat-export-shape-and-cjs-esm.md) — Export the plugin class as default; provide CJS/ESM interop

## How to Use

When writing or reviewing plugin code, scan `AGENTS.md` for the relevant category, then read the individual rule file for the full pattern and rationale.

- Start at [`references/_sections.md`](references/_sections.md) for category definitions and impact levels
- See [`assets/templates/_template.md`](assets/templates/_template.md) for the rule template if you want to extend this skill
- Read [`AGENTS.md`](AGENTS.md) for a compact navigation index

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions, impact levels, descriptions |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version, discipline, source references |
