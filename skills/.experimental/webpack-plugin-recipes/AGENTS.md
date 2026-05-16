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

Cookbook of 26 production-shaped webpack 5 plugins (4 guard + 4 meta + 4 virtual + 5 transform + 4 dx + 5 assets), each starting with a clearly defined problem statement and providing a complete working plugin (60-150 lines). Recipes cover: bundle-size budgets, architectural import enforcement, env-var validation, secret-leak detection, build-info injection, asset manifests, license walking, SRI hashes, virtual modules (Vite-style), filesystem routing (Next.js-style), generated barrels, runtime-driven TypeScript types, library replacement (react → preact), debug-helper stripping, conditional polyfills, dynamic banners, config-driven feature flags, build-duration tracking, notifications, changed-chunks diffs, browser auto-open, gzip/brotli pre-compression, image optimization, type-based dist layout, empty-chunk cleanup, and cache-busting query strings. Companion to the webpack-plugin-authoring skill — recipes apply the authoring rules to specific problems and cross-reference them inline.

---

## Table of Contents

1. [Build-time Guardrails](references/_sections.md#1-build-time-guardrails) — **CRITICAL**
   - 1.1 [Fail Builds When Forbidden Imports Cross Architectural Boundaries](references/guard-forbidden-imports.md) — CRITICAL (prevents architecture decay across long-lived codebases)
   - 1.2 [Fail Builds When Initial JS Exceeds a Per-Entry Budget](references/guard-bundle-budget.md) — CRITICAL (prevents silent bundle bloat across releases)
   - 1.3 [Fail Builds When Required Environment Variables Are Missing](references/guard-required-env-vars.md) — CRITICAL (prevents deploying with unset secrets that crash on first request)
   - 1.4 [Fail Builds When Secret-Shaped Strings Leak Into Client Bundles](references/guard-no-secrets-bundled.md) — CRITICAL (prevents shipping API keys / private tokens to the browser)
2. [Build Metadata & Manifests](references/_sections.md#2-build-metadata-&-manifests) — **HIGH**
   - 2.1 [Compute Subresource Integrity Hashes Per Asset](references/meta-sri-manifest.md) — HIGH (enables strict CSP and tamper detection on cached assets)
   - 2.2 [Emit an Asset Manifest Mapping Logical Names to Hashed Filenames](references/meta-asset-manifest.md) — HIGH (enables SSR/server to reference hashed asset URLs)
   - 2.3 [Generate a LICENSES.txt by Walking the Module Graph](references/meta-license-notice.md) — HIGH (provides legal-required OSS attribution without manual upkeep)
   - 2.4 [Inject Build Info (Commit Hash, Build Time) Into Source Code](references/meta-inject-build-info.md) — HIGH (enables runtime identification of which build is deployed)
3. [Virtual Modules & Codegen](references/_sections.md#3-virtual-modules-&-codegen) — **HIGH**
   - 3.1 [Auto-Generate Barrel Re-Exports From a Directory](references/virtual-barrel-from-directory.md) — HIGH (prevents stale exports drifting from filesystem state)
   - 3.2 [Emit TypeScript Declarations From Runtime Data](references/virtual-types-from-runtime.md) — HIGH (keeps TS types in sync with config files / API schemas)
   - 3.3 [Generate a Route Map From the Filesystem (Pages Pattern)](references/virtual-routes-from-filesystem.md) — HIGH (100% route coverage without manual registration)
   - 3.4 [Resolve Imports to In-Memory Strings (Virtual Modules)](references/virtual-module-from-memory.md) — HIGH (enables config-driven codegen without writing temp files to disk)
4. [Code Transformation](references/_sections.md#4-code-transformation) — **MEDIUM-HIGH**
   - 4.1 [Drive DefinePlugin Substitutions From a Config File](references/transform-define-from-config.md) — MEDIUM-HIGH (prevents feature-flag drift across environments)
   - 4.2 [Inject Polyfills Conditionally Based on Target Browsers](references/transform-conditional-polyfill.md) — MEDIUM-HIGH (10-50kb savings on modern bundles vs blanket core-js)
   - 4.3 [Prepend a Per-Chunk Banner With Dynamic Content](references/transform-banner-with-dynamic-content.md) — MEDIUM-HIGH (prevents broken license headers and stale copyright years)
   - 4.4 [Replace One Library With Another at Resolve Time](references/transform-replace-library.md) — MEDIUM-HIGH (30-80kb savings replacing react with preact/compat)
   - 4.5 [Strip Debug-Only Code From Production Bundles](references/transform-strip-debug-helpers.md) — MEDIUM-HIGH (5-30kb savings depending on how much dev instrumentation exists)
5. [Developer Experience](references/_sections.md#5-developer-experience) — **MEDIUM**
   - 5.1 [Open the Browser on the First Successful Dev Build](references/dx-open-browser-on-first-build.md) — MEDIUM (prevents 3-5s manual context switch on every dev-server start)
   - 5.2 [Print Which Chunks Actually Changed Between Rebuilds](references/dx-diff-changed-chunks.md) — MEDIUM (1-2 minutes saved per chunked watch-mode rebuild)
   - 5.3 [Report Build Duration and Detect Regressions](references/dx-build-duration-report.md) — MEDIUM (catches a 30%+ build slowdown the day it happens)
   - 5.4 [Send Desktop / Slack Notification on Build Done](references/dx-notify-on-done.md) — MEDIUM (prevents wasted time switching to terminal to check build status)
6. [Asset Pipeline](references/_sections.md#6-asset-pipeline) — **MEDIUM**
   - 6.1 [Append Cache-Busting Query Strings to Imports](references/assets-add-cache-busting-query.md) — MEDIUM (enables atomic deploys to non-hash-aware hosts)
   - 6.2 [Delete Empty Chunks That Webpack Emits as Side Effects](references/assets-skip-empty-chunks.md) — MEDIUM (removes 0-byte runtime/css chunks polluting the asset graph)
   - 6.3 [Optimize Images Through the Asset Pipeline With Cache Reuse](references/assets-optimize-images.md) — MEDIUM (40-80% smaller images without quality loss)
   - 6.4 [Organize Emitted Assets Into Type-Based Subdirectories](references/assets-route-by-type.md) — MEDIUM (cleaner dist/ for CDN-config and human inspection)
   - 6.5 [Pre-Compress Assets to gzip and brotli for CDN](references/assets-pre-compress-gzip-brotli.md) — MEDIUM (60-80% smaller bytes delivered when CDN serves pre-compressed)

---

## References

1. [https://webpack.js.org/contribute/writing-a-plugin/](https://webpack.js.org/contribute/writing-a-plugin/)
2. [https://webpack.js.org/api/compiler-hooks/](https://webpack.js.org/api/compiler-hooks/)
3. [https://webpack.js.org/api/compilation-hooks/](https://webpack.js.org/api/compilation-hooks/)
4. [https://webpack.js.org/api/compilation-object/](https://webpack.js.org/api/compilation-object/)
5. [https://webpack.js.org/api/normalmodulefactory-hooks/](https://webpack.js.org/api/normalmodulefactory-hooks/)
6. [https://webpack.js.org/api/plugins/](https://webpack.js.org/api/plugins/)
7. [https://webpack.js.org/blog/2020-10-10-webpack-5-release/](https://webpack.js.org/blog/2020-10-10-webpack-5-release/)
8. [https://github.com/webpack/schema-utils](https://github.com/webpack/schema-utils)
9. [https://github.com/webpack-contrib/mini-css-extract-plugin](https://github.com/webpack-contrib/mini-css-extract-plugin)
10. [https://github.com/webpack-contrib/terser-webpack-plugin](https://github.com/webpack-contrib/terser-webpack-plugin)
11. [https://github.com/webpack-contrib/compression-webpack-plugin](https://github.com/webpack-contrib/compression-webpack-plugin)
12. [https://github.com/webpack-contrib/copy-webpack-plugin](https://github.com/webpack-contrib/copy-webpack-plugin)
13. [https://github.com/webpack-contrib/image-minimizer-webpack-plugin](https://github.com/webpack-contrib/image-minimizer-webpack-plugin)
14. [https://github.com/webpack-contrib/css-minimizer-webpack-plugin](https://github.com/webpack-contrib/css-minimizer-webpack-plugin)
15. [https://github.com/jantimon/html-webpack-plugin](https://github.com/jantimon/html-webpack-plugin)
16. [https://github.com/waysact/webpack-subresource-integrity](https://github.com/waysact/webpack-subresource-integrity)
17. [https://github.com/shellscape/webpack-manifest-plugin](https://github.com/shellscape/webpack-manifest-plugin)
18. [https://github.com/vercel/next.js/tree/canary/packages/next/src/build/webpack](https://github.com/vercel/next.js/tree/canary/packages/next/src/build/webpack)
19. [https://github.com/jestjs/jest/tree/main/packages/jest-worker](https://github.com/jestjs/jest/tree/main/packages/jest-worker)
20. [https://github.com/ai/size-limit](https://github.com/ai/size-limit)
21. [https://github.com/sverweij/dependency-cruiser](https://github.com/sverweij/dependency-cruiser)
22. [https://github.com/gitleaks/gitleaks](https://github.com/gitleaks/gitleaks)
23. [https://vite.dev/guide/api-plugin.html#virtual-modules-convention](https://vite.dev/guide/api-plugin.html#virtual-modules-convention)
24. [https://github.com/zloirock/core-js/tree/master/packages/core-js-compat](https://github.com/zloirock/core-js/tree/master/packages/core-js-compat)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |