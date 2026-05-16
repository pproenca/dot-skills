# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Hook Selection & Tap Patterns (hook)

**Impact:** CRITICAL  
**Description:** Picking the wrong hook or tap method silently breaks the plugin — async work fires after `emit` completes, taps registered on `compilation` fire for child compilations, and `processAssets` mutations land in the wrong stage. This is the foundation: every other rule assumes you tapped the right hook with the right method.

## 2. Asset Pipeline (asset)

**Impact:** CRITICAL  
**Description:** Webpack treats assets as immutable `Source` objects with metadata; mutating `compilation.assets[name]` directly bypasses `emitAsset`/`updateAsset` invariants and breaks SRI hashes, content-hashed filenames, source maps, and downstream plugins that read `assets.info`. The asset graph is the plugin's primary output surface.

## 3. Caching & Watch Mode (cache)

**Impact:** HIGH  
**Description:** Webpack's watch mode and persistent cache only invalidate on inputs the plugin has declared via `fileDependencies`, `contextDependencies`, `missingDependencies`, and `buildDependencies`. Forgetting any of these produces stale builds that pass tests locally but ship the wrong bytes to production.

## 4. Plugin Lifecycle & State (life)

**Impact:** HIGH  
**Description:** A plugin instance is constructed once and reused across every compilation, every `--watch` rebuild, and every `MultiCompiler` child. Mutable instance state leaks between builds; side effects in the constructor break test isolation; taps that should run once-per-compilation fire for every child compilation if registered on the wrong hook.

## 5. Schema & Options Validation (schema)

**Impact:** MEDIUM-HIGH  
**Description:** `schema-utils` is the contract between the plugin and its users — it produces consistent error messages, surfaces invalid options early, and integrates with webpack's `experiments.futureDefaults` validation toggle. Hand-rolled `throw new Error('bad option')` produces unfindable errors and hides typos in nested option keys.

## 6. Errors, Warnings & Logging (diag)

**Impact:** MEDIUM-HIGH  
**Description:** Throwing inside a tap kills the build with a confusing stack; the correct surface is `compilation.errors.push(new WebpackError(...))` and `compilation.getLogger('PluginName')`, both of which integrate with webpack's stats output, IDE error overlays, dev-server overlay, and infrastructure logging filters.

## 7. Performance & Parallelism (perf)

**Impact:** MEDIUM  
**Description:** Plugin code runs inside the build hot path — synchronous filesystem reads, repeated module traversals, and unbounded CPU work serialize on the main thread and dominate build time at scale. `jest-worker`, chunk-level traversal, and reusing `compilation.cache` keep plugins viable in monorepos like Next.js and Storybook.

## 8. Compatibility & Packaging (compat)

**Impact:** LOW-MEDIUM  
**Description:** Webpack 5 made `webpack` a peerDependency for plugins and exposes its sub-modules via `compiler.webpack.*` so consumers can use any compatible webpack version with persistent caching. Direct `require('webpack')` and the legacy `hooks.foo = bar` extension pattern break in monorepos with multiple webpack versions and in webpack 5+'s sealed hook surface.
