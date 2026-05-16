# Webpack 5 Plugins

**Version 0.1.0**  
dot-skills  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide for authoring correct, performant webpack 5 plugins, designed for AI agents and LLMs. Contains 44 rules across 8 categories (8 hook + 7 asset + 5 cache + 5 life + 4 schema + 5 diag + 5 perf + 5 compat), ordered by the plugin authoring lifecycle: hook selection (CRITICAL — wrong hook silently breaks plugins), asset pipeline (CRITICAL — bypassing emitAsset corrupts hashing and SRI), caching & watch mode (HIGH — missing dependencies cause stale builds), plugin lifecycle (HIGH — instance state leaks across rebuilds), schema validation, error/log reporting, performance & parallelism, and packaging/compatibility. Each rule includes incorrect vs correct code examples drawn from production plugins (mini-css-extract-plugin, terser-webpack-plugin, compression-webpack-plugin, copy-webpack-plugin, html-webpack-plugin, Next.js webpack plugins) and quantified impact descriptions.

---

## Table of Contents

1. [Hook Selection & Tap Patterns](references/_sections.md#1-hook-selection-&-tap-patterns) — **CRITICAL**
   - 1.1 [Match tap Method to the Hook's Async Type](references/hook-tap-method-matches-hook-type.md) — CRITICAL (prevents silently dropped async work)
   - 1.2 [Pick the Right processAssets Stage](references/hook-process-assets-stage.md) — CRITICAL (prevents minification undoing your transform)
   - 1.3 [Prefer processAssets Over the emit Hook for Asset Mutation](references/hook-prefer-process-assets-over-emit.md) — CRITICAL (prevents bypassing real-content hashing and SRI)
   - 1.4 [Register Compiler Hooks Once in apply, Not Inside Compilation Hooks](references/hook-tap-once-not-per-compilation.md) — CRITICAL (prevents O(n) duplicate tap registration)
   - 1.5 [Return Undefined From Bail Hooks Unless You Mean to Stop](references/hook-bail-hook-return-semantics.md) — CRITICAL (prevents short-circuiting other plugins)
   - 1.6 [Tap normalModuleFactory at the Right Resolution Stage](references/hook-normal-module-factory-stages.md) — CRITICAL (prevents resolver re-runs and infinite recursion)
   - 1.7 [Use a Stable, Unique Name for Every tap](references/hook-name-matches-class-name.md) — CRITICAL (prevents stats/profiling collisions and HMR breakage)
   - 1.8 [Use thisCompilation to Skip Child Compilations](references/hook-thiscompilation-vs-compilation.md) — CRITICAL (prevents firing for every child compilation)
2. [Asset Pipeline](references/_sections.md#2-asset-pipeline) — **CRITICAL**
   - 2.1 [Hash Asset Content With compilation.outputOptions.hashFunction](references/asset-content-hash-via-output-options.md) — CRITICAL (prevents hash collisions across builds with custom hashFunction)
   - 2.2 [Import Source Classes From compiler.webpack.sources](references/asset-source-from-compiler-webpack.md) — CRITICAL (prevents version drift breaking persistent cache)
   - 2.3 [Preserve Source Maps When Transforming Assets](references/asset-preserve-source-maps.md) — CRITICAL (prevents detached source maps and broken debugging)
   - 2.4 [Set asset.info Metadata When Emitting](references/asset-set-info-metadata.md) — CRITICAL (prevents wrong cache headers and broken SRI)
   - 2.5 [Use buffer() Not source() for Binary Assets](references/asset-buffer-not-source-for-binary.md) — CRITICAL (prevents UTF-8 corruption of images and wasm)
   - 2.6 [Use emitAsset / updateAsset, Not Direct compilation.assets Mutation](references/asset-emit-asset-not-direct-assignment.md) — CRITICAL (prevents desynced asset.info, hashes, and cache state)
   - 2.7 [Use renameAsset to Move Assets, Not Delete + Emit](references/asset-delete-then-emit-loses-info.md) — CRITICAL (prevents losing related-asset graph and chunk linkage)
3. [Caching & Watch Mode](references/_sections.md#3-caching-&-watch-mode) — **HIGH**
   - 3.1 [Add Code Inputs to buildDependencies for Persistent Cache](references/cache-build-dependencies-for-persistent-cache.md) — HIGH (prevents cache poisoning across plugin upgrades)
   - 3.2 [Add Looked-For-But-Absent Paths to missingDependencies](references/cache-missing-dependencies-for-optional-files.md) — HIGH (prevents stale builds when an optional file appears)
   - 3.3 [Add Read Files to compilation.fileDependencies](references/cache-add-file-dependencies.md) — HIGH (prevents stale builds in watch mode)
   - 3.4 [Read Files Via compiler.inputFileSystem, Not Node fs](references/cache-use-input-file-system.md) — HIGH (prevents bypassing the in-memory dev-server filesystem)
   - 3.5 [Use contextDependencies for Directory Scans, Not Glob Expansion](references/cache-context-dependencies-for-directories.md) — HIGH (prevents missing newly-added files in watch mode)
4. [Plugin Lifecycle & State](references/_sections.md#4-plugin-lifecycle-&-state) — **HIGH**
   - 4.1 [Avoid Mutable State Across Compilations](references/life-no-mutable-state-across-builds.md) — HIGH (prevents leaking partial state between rebuilds)
   - 4.2 [Clean Up Resources in compiler.hooks.shutdown](references/life-cleanup-in-shutdown-hook.md) — HIGH (prevents hanging CI processes and leaked workers)
   - 4.3 [Never Mutate the User's Options Object](references/life-defensively-copy-user-options.md) — HIGH (prevents corrupting config across compiler instances)
   - 4.4 [One Plugin Instance Per Compiler in MultiCompiler Setups](references/life-multi-compiler-isolation.md) — HIGH (prevents shared state corrupting parallel builds)
   - 4.5 [Store Options in the Constructor, Do the Work in apply()](references/life-constructor-stores-options-only.md) — HIGH (prevents side effects on plugin import)
5. [Schema & Options Validation](references/_sections.md#5-schema-&-options-validation) — **MEDIUM-HIGH**
   - 5.1 [Set additionalProperties: false on Every Object](references/schema-additional-properties-false.md) — MEDIUM-HIGH (catches ~90% of misconfigurations (typo-driven default activation))
   - 5.2 [Set name and baseDataPath on validate()](references/schema-name-and-base-data-path.md) — MEDIUM-HIGH (prevents anonymous "an options object" errors that don't name the plugin)
   - 5.3 [Use compiler.hooks.validate for Cross-Cutting Validation (5.106+)](references/schema-tap-into-validate-hook.md) — MEDIUM-HIGH (prevents expensive validation running on every config load)
   - 5.4 [Validate Options With schema-utils](references/schema-validate-with-schema-utils.md) — MEDIUM-HIGH (surfaces typos at config-load instead of mid-build)
6. [Errors, Warnings & Logging](references/_sections.md#6-errors,-warnings-&-logging) — **MEDIUM-HIGH**
   - 6.1 [Attach loc and module to Errors for Source Mapping](references/diag-attach-loc-to-errors.md) — MEDIUM-HIGH (enables IDE click-through to the offending line)
   - 6.2 [Choose Errors for Build Failures, Warnings for Quality Notices](references/diag-warnings-vs-errors-exit-codes.md) — MEDIUM-HIGH (prevents CI surprises (silent pass / false fail))
   - 6.3 [Log via compilation.getLogger, Not console](references/diag-use-compilation-get-logger.md) — MEDIUM-HIGH (prevents log spam and integrates with stats filtering)
   - 6.4 [Push WebpackError to compilation.errors Instead of Throwing](references/diag-push-webpack-error-not-throw.md) — MEDIUM-HIGH (prevents one bad input from killing the whole build)
   - 6.5 [Report Progress via context.reportProgress](references/diag-progress-reporting.md) — MEDIUM-HIGH (prevents a frozen progress bar during 10-60s plugin work)
7. [Performance & Parallelism](references/_sections.md#7-performance-&-parallelism) — **MEDIUM**
   - 7.1 [Avoid source().toString() on Assets You Won't Modify](references/perf-avoid-source-toString-in-hot-paths.md) — MEDIUM (skip O(asset-bytes) materialization for read-only checks)
   - 7.2 [Cache Expensive Work via compilation.getCache](references/perf-cache-results-with-compilation-cache.md) — MEDIUM (10-100x faster watch rebuilds (skips unchanged assets))
   - 7.3 [Honor compiler.options.experiments.cacheUnaffected and incremental](references/perf-respect-experimental-options.md) — MEDIUM (5x faster incremental rebuilds (limits work to changed inputs))
   - 7.4 [Offload CPU-Bound Work to jest-worker](references/perf-jest-worker-for-cpu-bound-work.md) — MEDIUM (2-4x build speedup on multi-core machines)
   - 7.5 [Traverse compilation.chunks Not compilation.modules When Possible](references/perf-traverse-chunks-not-modules.md) — MEDIUM (O(modules) becomes O(chunks) — often 10-100x fewer iterations)
8. [Compatibility & Packaging](references/_sections.md#8-compatibility-&-packaging) — **LOW-MEDIUM**
   - 8.1 [Declare webpack as peerDependency, Not dependency](references/compat-webpack-as-peer-dependency.md) — LOW-MEDIUM (prevents duplicate webpack installs and version drift)
   - 8.2 [Detect API Presence, Don't Check Webpack Versions](references/compat-feature-detection-not-version-check.md) — LOW-MEDIUM (prevents brittle version-string parsing)
   - 8.3 [Export the Plugin Class Directly as module.exports (CJS) or default (ESM)](references/compat-export-shape-and-cjs-esm.md) — LOW-MEDIUM (prevents users seeing "X is not a constructor")
   - 8.4 [Expose Custom Hooks via getCompilationHooks WeakMap](references/compat-custom-hooks-via-weakmap.md) — LOW-MEDIUM (prevents memory leaks from per-compilation hook state)
   - 8.5 [Use compiler.webpack.* Instead of Importing webpack](references/compat-use-compiler-webpack-namespace.md) — LOW-MEDIUM (prevents class-identity mismatches in monorepos)

---

## References

1. [https://webpack.js.org/contribute/writing-a-plugin/](https://webpack.js.org/contribute/writing-a-plugin/)
2. [https://webpack.js.org/api/compiler-hooks/](https://webpack.js.org/api/compiler-hooks/)
3. [https://webpack.js.org/api/compilation-hooks/](https://webpack.js.org/api/compilation-hooks/)
4. [https://webpack.js.org/api/plugins/](https://webpack.js.org/api/plugins/)
5. [https://webpack.js.org/contribute/plugin-patterns/](https://webpack.js.org/contribute/plugin-patterns/)
6. [https://webpack.js.org/api/compilation-object/](https://webpack.js.org/api/compilation-object/)
7. [https://webpack.js.org/blog/2020-10-10-webpack-5-release/](https://webpack.js.org/blog/2020-10-10-webpack-5-release/)
8. [https://github.com/webpack/changelog-v5/blob/master/guides/persistent-caching.md](https://github.com/webpack/changelog-v5/blob/master/guides/persistent-caching.md)
9. [https://github.com/webpack/schema-utils](https://github.com/webpack/schema-utils)
10. [https://github.com/webpack/webpack-sources](https://github.com/webpack/webpack-sources)
11. [https://github.com/webpack-contrib/mini-css-extract-plugin](https://github.com/webpack-contrib/mini-css-extract-plugin)
12. [https://github.com/webpack-contrib/terser-webpack-plugin](https://github.com/webpack-contrib/terser-webpack-plugin)
13. [https://github.com/webpack-contrib/compression-webpack-plugin](https://github.com/webpack-contrib/compression-webpack-plugin)
14. [https://github.com/webpack-contrib/copy-webpack-plugin](https://github.com/webpack-contrib/copy-webpack-plugin)
15. [https://github.com/webpack-contrib/css-minimizer-webpack-plugin](https://github.com/webpack-contrib/css-minimizer-webpack-plugin)
16. [https://github.com/jantimon/html-webpack-plugin](https://github.com/jantimon/html-webpack-plugin)
17. [https://github.com/vercel/next.js/tree/canary/packages/next/src/build/webpack](https://github.com/vercel/next.js/tree/canary/packages/next/src/build/webpack)
18. [https://github.com/jestjs/jest/tree/main/packages/jest-worker](https://github.com/jestjs/jest/tree/main/packages/jest-worker)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |