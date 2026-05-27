---
name: webpack-plugin-recipes
description: Use whenever you face a webpack-build problem that ends with needing to write a plugin — 26 production-shaped recipes covering bundle-size budgets, forbidden architectural imports, env-var validation, secret-leak prevention, build-info injection, asset manifests, license walking, SRI hashes, virtual modules (Vite-style), filesystem routing (Next.js-style), generated barrels, runtime-driven TS types, library replacement (react→preact), debug-stripping, conditional polyfills, dynamic banners, feature flags, build-duration regression tracking, desktop/Slack notifications, changed-chunks diffing, browser auto-open, gzip/brotli pre-compression, image optimization, type-based dist layout, empty-chunk cleanup, cache-busting query strings. Each recipe is a complete working plugin drawn from production patterns at Next.js, Storybook, webpack-contrib. Trigger when the user asks how to do X with webpack or whether a plugin exists for X. Companion to webpack-plugin-authoring.
---

# dot-skills Webpack 5 Plugins Best Practices

Cookbook of 26 production-shaped webpack 5 plugins, organized by the problem they solve. Each recipe starts with a clearly defined problem statement ("here's what hurts without this"), shows the naive non-plugin approach, then provides a complete working plugin (60-150 lines) with explanation, variations, and "when NOT to use" guidance.

Companion to [`webpack-plugin-authoring`](../webpack-plugin-authoring/) — authoring teaches *how* to write any plugin correctly; recipes teach *which* plugin to write for a specific pain point. Recipes cross-reference the authoring rules they apply.

## When to Apply

Reference these recipes whenever:

- A team has a recurring build-time problem that "feels like it should be a plugin" (architecture rules, secret leak prevention, asset organization)
- You need to integrate webpack output with downstream systems (SSR servers, CDNs, monitoring)
- You're considering whether to write your own plugin OR adopt an existing one — these recipes show the underlying pattern so you can judge fit
- Migrating from another bundler and need to recreate framework-style features (filesystem routing, virtual modules)
- Onboarding new engineers to webpack plugin authoring — recipes give realistic, end-to-end examples

## Recipe Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Build-time Guardrails | CRITICAL | `guard-` |
| 2 | Build Metadata & Manifests | HIGH | `meta-` |
| 3 | Virtual Modules & Codegen | HIGH | `virtual-` |
| 4 | Code Transformation | MEDIUM-HIGH | `transform-` |
| 5 | Developer Experience | MEDIUM | `dx-` |
| 6 | Asset Pipeline | MEDIUM | `assets-` |

## Quick Reference

### 1. Build-time Guardrails (CRITICAL)

- [`guard-bundle-budget`](references/guard-bundle-budget.md) — Fail builds when initial JS exceeds a per-entry gzipped budget
- [`guard-forbidden-imports`](references/guard-forbidden-imports.md) — Fail builds when forbidden imports cross architectural boundaries
- [`guard-required-env-vars`](references/guard-required-env-vars.md) — Fail builds when required environment variables are missing
- [`guard-no-secrets-bundled`](references/guard-no-secrets-bundled.md) — Fail builds when secret-shaped strings leak into client bundles

### 2. Build Metadata & Manifests (HIGH)

- [`meta-inject-build-info`](references/meta-inject-build-info.md) — Inject `__COMMIT__`/`__BUILD_TIME__` into source via DefinePlugin + emit `build-info.json`
- [`meta-asset-manifest`](references/meta-asset-manifest.md) — Emit chunk-grouped manifest mapping logical names → hashed filenames
- [`meta-license-notice`](references/meta-license-notice.md) — Generate `LICENSES.txt` by walking the module graph (not `node_modules/`)
- [`meta-sri-manifest`](references/meta-sri-manifest.md) — Compute SHA-384 SRI hashes per asset for CSP compliance

### 3. Virtual Modules & Codegen (HIGH)

- [`virtual-module-from-memory`](references/virtual-module-from-memory.md) — Resolve `virtual:X` imports to in-memory strings (Vite-style)
- [`virtual-routes-from-filesystem`](references/virtual-routes-from-filesystem.md) — Generate route map from `pages/` directory (Next.js-style)
- [`virtual-barrel-from-directory`](references/virtual-barrel-from-directory.md) — Auto-generate barrel re-exports from a directory
- [`virtual-types-from-runtime`](references/virtual-types-from-runtime.md) — Emit `.d.ts` from runtime data (config files, JSON schemas)

### 4. Code Transformation (MEDIUM-HIGH)

- [`transform-replace-library`](references/transform-replace-library.md) — Replace `react` with `preact/compat` at resolve (with subpath handling)
- [`transform-strip-debug-helpers`](references/transform-strip-debug-helpers.md) — Strip `devAssert()`/`devLog()` calls + dev-only imports from production
- [`transform-conditional-polyfill`](references/transform-conditional-polyfill.md) — Inject only the polyfills target browsers actually need (browserslist + core-js-compat)
- [`transform-banner-with-dynamic-content`](references/transform-banner-with-dynamic-content.md) — Per-chunk banners with current year, version, git commit
- [`transform-define-from-config`](references/transform-define-from-config.md) — Drive `DefinePlugin` substitutions from a `flags/staging.json`-style file

### 5. Developer Experience (MEDIUM)

- [`dx-build-duration-report`](references/dx-build-duration-report.md) — Persist build durations, warn when current build is >30% slower than median
- [`dx-notify-on-done`](references/dx-notify-on-done.md) — Desktop notification (local) + Slack webhook (CI) on build complete
- [`dx-diff-changed-chunks`](references/dx-diff-changed-chunks.md) — Print only the chunks that actually changed between rebuilds
- [`dx-open-browser-on-first-build`](references/dx-open-browser-on-first-build.md) — Open the dev-server URL AFTER first successful build (not before)

### 6. Asset Pipeline (MEDIUM)

- [`assets-pre-compress-gzip-brotli`](references/assets-pre-compress-gzip-brotli.md) — Emit `.gz`/`.br` siblings for CDN-served pre-compression
- [`assets-optimize-images`](references/assets-optimize-images.md) — Optimize PNG/JPEG with imagemin + cache reuse across rebuilds
- [`assets-route-by-type`](references/assets-route-by-type.md) — Organize emitted assets into `js/`/`css/`/`img/`/`fonts/` subdirectories
- [`assets-skip-empty-chunks`](references/assets-skip-empty-chunks.md) — Delete the 0-byte chunks webpack/splitChunks/mini-css emit unnecessarily
- [`assets-add-cache-busting-query`](references/assets-add-cache-busting-query.md) — Append `?v=<hash>` to references of fixed-name assets (manifest.json, sw.js)

## How to Use

When the user describes a webpack problem (or asks for a plugin):

1. Identify the problem category (guardrail? metadata? codegen? transformation? dx? asset?)
2. Open the matching recipe file — read the **Problem** section first to confirm it's the right recipe
3. Use the **Plugin** section as a working starting point — adapt to the project's specifics
4. Read **How it works** for the WHY behind each design choice (cross-references the authoring rules)
5. Check **Variations** for common adaptations and **When NOT to use** to confirm the fit

For learning plugin authoring patterns more broadly, pair with the [`webpack-plugin-authoring`](../webpack-plugin-authoring/) skill — its 44 rules teach the underlying APIs every recipe in this skill applies.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact levels |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new recipes |
| [metadata.json](metadata.json) | Version and source references |
