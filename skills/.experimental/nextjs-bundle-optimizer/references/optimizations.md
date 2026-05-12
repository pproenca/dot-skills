# Optimization Recipes

A catalog of recipes addressing the most common findings from `analyze.sh`. Each recipe has the same shape:

- **Signal** — what the analyzer/diagnose output looks like
- **Fix** — the minimum-diff change
- **Expected impact** — rough magnitude based on the public benchmarks linked
- **Verify** — what `compare.sh` should show; what `verify.sh` catches

Recipe IDs match the anchors emitted by `diagnose.sh` (e.g. `#shared-heavy-dep`).

---

## Bundle-size recipes

### shared-heavy-dep

**Signal:** A single chunk >100 KB used by ≥3 routes. The treemap shows a third-party library (lodash, moment, large UI kit) at the top.

**Fix — typical sequence:**
1. Identify which packages contribute. In the Turbopack analyzer, click the chunk and inspect the module list. Outside the analyzer: `grep -r "from 'lodash'" src/` (or whichever lib).
2. Replace barrel imports with subpath imports:

   ```ts
   // Before — pulls all of lodash
   import { debounce, throttle } from 'lodash'

   // After — only the two functions
   import debounce from 'lodash/debounce'
   import throttle from 'lodash/throttle'
   ```

3. For webpack-mode projects (Next < 16 or `--no-turbo`), add to `next.config.js`:

   ```js
   experimental: {
     optimizePackageImports: ['lodash', '@mui/icons-material'],
   }
   ```

   *Skip this on Turbopack — it's already automatic.*

4. For date libraries (`moment` → `date-fns` or `dayjs`), do the smallest swap first: only at one call site, verify, then propagate.

**Expected impact:** 30–80% reduction for the targeted chunk. Lodash full → tree-shaken commonly saves 50–60 KB gzipped.

**Verify:** `compare.sh` shows the chunk shrink. `verify.sh` confirms no behavioral break (often: a missing subpath, like `lodash/fp` not having the same default-export semantics).

**Common pitfalls:**
- `lodash` has different ESM/CJS layouts. The subpath `lodash/debounce` works in both; named-import-from-package works in `lodash-es`.
- Some libraries publish broken subpath exports — verify in dev before committing.

---

### large-route-bundle

**Signal:** A single route's total exceeds ~250 KB (warning) or ~500 KB (critical).

**Fix:**
1. Open the analyzer treemap for that route. Look at the top 3 modules by area.
2. For each: is it actually needed on first paint?
   - **Heavy interactive widget** (charts, date pickers, code editors): wrap with `next/dynamic`.

     ```tsx
     'use client'
     import dynamic from 'next/dynamic'

     const Chart = dynamic(() => import('./Chart'), {
       ssr: false,
       loading: () => <ChartSkeleton />,
     })
     ```

   - **Server-only utility imported from a client component**: move the import into a Server Component. The lib never ships to the browser.
   - **"Just in case" import** (a util that's exported broadly but only used by one rare path): inline-import inside the handler.

3. For client components that fetch and render on mount, consider whether the work can move to a Server Component and stream HTML.

**Expected impact:** A `next/dynamic({ ssr: false })` move on a chart library can shrink the route by 100–300 KB gzipped.

**Verify:** `compare.sh` shows the route drop. `verify.sh` runs your tests — these often catch SSR/hydration issues if you set `ssr: false` on something that was being rendered on the server.

**Common pitfalls:**
- `ssr: false` produces empty HTML for that component on first paint. If LCP is the metric, you may have moved the cost from JS to the missing content. Measure with Lighthouse separately.
- Don't `next/dynamic` everything — each dynamic boundary adds a network round-trip to fetch the chunk.

---

### polyfill-bloat

**Signal:** A chunk named like `polyfills*.js`, `core-js*`, or a framework chunk with disproportionate size for the modern-browser baseline.

**Fix:**
1. Inspect the project's `browserslist` config (in `package.json` or `.browserslistrc`).
2. Drop legacy targets if your users are on modern browsers:

   ```json
   "browserslist": [
     "defaults and supports es6-module"
   ]
   ```

3. Audit any `@babel/preset-env` config — Next.js 16 with Turbopack mostly bypasses Babel, but webpack-mode projects may still hit Babel for some packages.
4. If a specific dependency forces a polyfill (e.g. it imports `core-js` directly), the right fix is to upgrade or replace that dependency, not the polyfill.

**Expected impact:** 20–50 KB reduction depending on initial baseline. Largest wins come from dropping IE-era targets.

**Verify:** `compare.sh` on the polyfill chunk. `verify.sh` tests on a CI runner matching your real-browser baseline (this is where you discover that `Array.prototype.at` isn't in iOS 14 Safari).

**Common pitfalls:**
- "Tighten browserslist" can silently break in production for old mobile browsers that don't show up in your local testing. Roll out behind a canary if possible.

---

### heavy-client-component

**Signal:** A route-specific chunk >200 KB, treemap shows it's dominated by one component or feature.

**Fix:** Same playbook as `large-route-bundle`, applied to the specific component:

1. Is this a client component that doesn't actually need to be? Mark it as a Server Component (remove `'use client'`) if it doesn't use hooks, browser APIs, or event handlers.
2. Is the component imported eagerly but rendered conditionally? Lazy-load:

   ```tsx
   const HeavyModal = dynamic(() => import('./HeavyModal'))

   // Render only when needed:
   {isOpen && <HeavyModal />}
   ```

3. Is the component a wrapper that re-exports a heavy lib? Often you can drop the wrapper and import the lib directly only where needed.

**Expected impact:** Varies widely. A `next/dynamic` move on a confirmed-not-needed-on-first-paint component is typically 50–150 KB.

**Verify:** Standard `compare.sh` + `verify.sh`. Pay special attention to hydration warnings in tests — `ssr: false` removes SSR HTML for the boundary.

---

### duplicate-deps

**Signal:** Multiple versions of the same package in the analyzer (e.g. `react-is@17` and `react-is@18` both present), or two chunks containing what looks like the same code.

**Fix:**
1. Identify the culprit:
   ```bash
   npm ls <package>            # or `pnpm why <package>` / `yarn why <package>`
   ```
2. Force resolution to one version via `package.json`:

   ```jsonc
   // npm:
   "overrides": { "react-is": "^18.2.0" }

   // pnpm:
   "pnpm": { "overrides": { "react-is": "^18.2.0" } }

   // yarn:
   "resolutions": { "react-is": "^18.2.0" }
   ```

3. Reinstall: `rm -rf node_modules && <package_manager> install`
4. Re-baseline (the install step changes the entire dependency graph; the previous baseline is no longer comparable).

**Expected impact:** Eliminates one full copy of the duplicated package. For mid-sized libs, 10–80 KB.

**Verify:** `compare.sh` should show a global decrease. `verify.sh` catches behavioral breaks — overrides occasionally pin a sub-dep to an incompatible version.

**Common pitfalls:**
- Overrides are powerful and dangerous; a wrong major-version override can break unrelated packages. Always run the full test suite.
- Re-baselining is mandatory after a dependency tree mutation. Don't try to `compare.sh` across that change.

---

### icon-library

**Signal:** A chunk containing thousands of icons from `@mui/icons-material`, `lucide-react`, `react-icons`, etc.

**Fix:** Use per-icon imports:

```tsx
// Before — naive named import (may or may not be tree-shaken depending on bundler):
import { Search, Menu, Close } from 'lucide-react'

// After — explicit per-icon paths (always tree-shaken):
import Search from 'lucide-react/dist/esm/icons/search'
import Menu from 'lucide-react/dist/esm/icons/menu'
```

For Turbopack, the named import form is usually already optimal — verify by re-analyzing after the build.

For webpack mode, add to `optimizePackageImports`:

```js
experimental: {
  optimizePackageImports: ['lucide-react', '@mui/icons-material'],
}
```

**Expected impact:** Often dramatic — icon libraries can be 1–2 MB; per-icon import brings it down to KBs.

**Verify:** Per-route delta on any route that imports icons. Visual smoke test of the affected routes.

---

### framework-chunks

**Signal:** A `framework*.js` chunk in the top offenders.

**Fix:** Usually not worth touching directly. Framework chunks contain React, Next.js runtime, and a few core deps — they're shared across all routes and benefit from long-term caching.

If the framework chunk is genuinely outsized (>200 KB gzipped), look for:
- A heavy library that got hoisted into the shared chunk (e.g. a chart library imported by every page).
- An accidental "everything" barrel re-export from a shared `lib/index.ts`.

**Expected impact:** Low; usually 0. Spend the iteration on a different recipe.

---

## Build-time recipes

### turbopack-fs-cache

**Signal:** Cold builds take >1 minute and you re-build often (CI or local dev).

**Fix:**

```ts
// next.config.ts
const nextConfig = {
  experimental: {
    turbopackFileSystemCacheForBuild: true, // opt-in beta in Next 16
    // turbopackFileSystemCacheForDev is on by default in Next 16
  },
}
```

**Expected impact:** Warm builds 30–70% faster. Cold builds: no change.

**Verify:** Run `measure.sh` twice — first cold (default), then `measure.sh --warm`. Compare the two `timing.json` `build_seconds`.

**Caveats:**
- "Beta" in Next 16 — verify the build artifact in production before relying on it for releases.
- The cache lives in `.next/cache`. CI needs to persist this directory between runs to benefit.

---

### narrow-transpilepackages

**Signal:** Build is slow, and `next.config.{js,ts}` has a long `transpilePackages` list — often a list that has grown over time and includes packages that no longer need transpilation.

**Fix:**
1. Audit each entry. For each package, check if its `dist/` output is already ESM/CJS-compatible (look at `package.json` `"type"` and `"exports"`).
2. Remove entries that don't need transpilation.
3. Test by building — if a removed entry was actually needed, the build fails with a clear "unexpected token" or similar error. Re-add it.

**Expected impact:** Each unnecessary entry adds compile cost proportional to the package size. Removing a large unnecessary entry can save 5–20% of build time.

**Verify:** `measure.sh` build-time delta. `verify.sh` catches the case where a removed entry was actually load-bearing.

---

### typecheck-out-of-build

**Signal:** `next build` runs type-checking inline and dominates build time. Visible in build logs as "Linting and checking validity of types" taking many seconds.

**Fix:**

1. Disable type-checking during `next build`:

   ```ts
   const nextConfig = {
     typescript: { ignoreBuildErrors: false }, // keep validation, just decouple
     // Or, more aggressively for CI flow control:
     // typescript: { ignoreBuildErrors: true }
   }
   ```

2. Run `tsc --noEmit` as a separate CI job in parallel with `next build`.
3. Fail the CI pipeline if either job fails.

**Expected impact:** Removes type-check time from the critical path. Often 10–40 seconds on mid-size projects.

**Verify:** `measure.sh` build-time delta. `verify.sh` still runs the separated `tsc --noEmit` as a verification step, so type safety is preserved.

**Caveats:**
- Don't `ignoreBuildErrors: true` in dev workflows — you want fast feedback locally.
- This is a CI-shape change, not a code change; rolling it out means updating the pipeline.

---

### tracing-bottleneck

**Signal:** Build time is bad and the previous recipes haven't moved it. You suspect a single file or module is the bottleneck.

**Fix:**

```bash
NEXT_TURBOPACK_TRACING=1 npm run build
```

This produces `.next-profiles/trace-turbopack`. Inspect with `chrome://tracing` or share with the Next.js team via a GitHub issue.

For deeper analysis: search the trace for spans >500ms. Common culprits:
- A single component file with extreme generic-type complexity.
- A circular import chain that triggers re-compilation.
- A `node_modules` package with a corrupted source map.

**Expected impact:** Diagnostic only — produces evidence, not a fix. The fix follows from what you find.

**Verify:** Compare trace before/after applying whatever fix the trace points to.

**Caveats:**
- The trace file is large (tens of MB on real apps). Don't commit it.
- The trace format is experimental and may change between Next.js versions.

---

## Recipe selection cheat sheet

| Finding (from `diagnose.sh`) | First recipe to try |
|------------------------------|---------------------|
| `shared-heavy` chunk with library name in path | `#shared-heavy-dep` |
| `shared-heavy` chunk named polyfill/legacy | `#polyfill-bloat` |
| Route-specific chunk >500 KB | `#large-route-bundle` → `#heavy-client-component` |
| Two versions of same package in graph | `#duplicate-deps` |
| Icon library in top offenders | `#icon-library` |
| Slow CI builds, no bundle issue | `#turbopack-fs-cache`, `#typecheck-out-of-build` |
| Slow build, suspicious `transpilePackages` | `#narrow-transpilepackages` |
| Slow build, no obvious cause | `#tracing-bottleneck` (diagnostic) |
