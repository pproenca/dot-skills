# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group recipes.

Each recipe is a complete, working plugin that solves a named problem. The "impact" rating reflects how much pain the problem causes when left unsolved — not the complexity of the solution.

---

## 1. Build-time Guardrails (guard)

**Impact:** CRITICAL  
**Description:** Recipes that fail the build when an invariant is violated — bundle size budgets, forbidden cross-layer imports, missing environment variables, accidentally bundled secrets. These problems escape into production silently without a plugin to catch them: a 100kb dependency creep, a UI component reaching into server-only code, an unset `STRIPE_SECRET_KEY` that crashes on first request. The fix is always cheaper at build time than after deploy.

## 2. Build Metadata & Manifests (meta)

**Impact:** HIGH  
**Description:** Recipes that produce or inject information ABOUT the build — git commit hash baked into the JS, manifest files mapping logical names to hashed filenames, license/notice files walked from the module graph, SRI hashes for CSP compliance. SSR servers, edge functions, and CDN configurations need this information; without a plugin emitting it, teams hand-maintain JSON files that drift from the build's actual output.

## 3. Virtual Modules & Codegen (virtual)

**Impact:** HIGH  
**Description:** Recipes that synthesize module content at build time without writing files to disk — `import 'virtual:config'` resolving to a runtime-generated string, filesystem-based route maps, auto-generated barrel exports, runtime-driven TypeScript types. These patterns power Next.js's file-based routing, Vite's virtual modules, and Nuxt's auto-imports; reimplementing them in a custom webpack build requires understanding `NormalModuleFactory` hooks and resolver patterns.

## 4. Code Transformation (transform)

**Impact:** MEDIUM-HIGH  
**Description:** Recipes that modify what gets bundled — replacing one library with another at resolve time (`react` → `preact/compat`), stripping `if (__DEV__)` blocks in production, injecting polyfills conditionally based on target, prepending dynamic banners (git info, copyright with year), config-driven feature flag defines. These are the patterns that bridge "I want my source code to stay clean" and "I want my production bundle to be different from my dev bundle."

## 5. Developer Experience (dx)

**Impact:** MEDIUM  
**Description:** Recipes that improve the developer feedback loop — build duration reports with regression detection, desktop/Slack notifications on rebuild completion, diffs showing which chunks actually changed between rebuilds, browser auto-open on dev-server's first successful build. These are the small frictions that compound across a team: 20 developers × 50 rebuilds/day × 10s of "did it finish?" = real time. Each recipe is small enough to drop into a project on a Friday afternoon.

## 6. Asset Pipeline (assets)

**Impact:** MEDIUM  
**Description:** Recipes that process emitted assets — pre-compressing with gzip/brotli for CDN-served assets, optimizing images via sharp/imagemin with cache reuse, routing assets into typed subdirectories (`js/`, `css/`, `img/`), suppressing empty chunks that SSR doesn't need, appending cache-busting query strings for hosts that ignore content hashes. These complement webpack's built-in asset pipeline for specific deployment targets (Cloudflare, S3, Vercel edge, traditional NGINX).
