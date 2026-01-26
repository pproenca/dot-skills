# Vite

**Version 0.1.0**  
Vite  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Vite applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (dependency pre-bundling, plugin performance, bundle optimization) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Dependency Pre-bundling](#1-dependency-pre-bundling) — **CRITICAL**
   - 1.1 [Configure Custom Entry Points for Discovery](#11-configure-custom-entry-points-for-discovery)
   - 1.2 [Configure holdUntilCrawlEnd for Startup Behavior](#12-configure-holduntilcrawlend-for-startup-behavior)
   - 1.3 [Exclude Small ESM Dependencies](#13-exclude-small-esm-dependencies)
   - 1.4 [Handle Linked Dependencies in Monorepos](#14-handle-linked-dependencies-in-monorepos)
   - 1.5 [Include Large Dependencies with Many Modules](#15-include-large-dependencies-with-many-modules)
   - 1.6 [Use --force Flag for Dependency Changes](#16-use-force-flag-for-dependency-changes)
2. [Plugin Performance](#2-plugin-performance) — **CRITICAL**
   - 2.1 [Audit Community Plugins for Performance](#21-audit-community-plugins-for-performance)
   - 2.2 [Avoid Long Operations in Startup Hooks](#22-avoid-long-operations-in-startup-hooks)
   - 2.3 [Early Return in Transform Hooks](#23-early-return-in-transform-hooks)
   - 2.4 [Use Dynamic Imports in Plugin Code](#24-use-dynamic-imports-in-plugin-code)
   - 2.5 [Use SWC Instead of Babel for React](#25-use-swc-instead-of-babel-for-react)
3. [Bundle Optimization](#3-bundle-optimization) — **CRITICAL**
   - 3.1 [Address Large Chunk Warnings](#31-address-large-chunk-warnings)
   - 3.2 [Analyze Bundle Composition](#32-analyze-bundle-composition)
   - 3.3 [Configure Asset Inlining Threshold](#33-configure-asset-inlining-threshold)
   - 3.4 [Disable Compressed Size Reporting for Large Projects](#34-disable-compressed-size-reporting-for-large-projects)
   - 3.5 [Enable Effective Tree-Shaking](#35-enable-effective-tree-shaking)
   - 3.6 [Use Dynamic Imports for Route-Level Splitting](#36-use-dynamic-imports-for-route-level-splitting)
   - 3.7 [Use manualChunks for Vendor Splitting](#37-use-manualchunks-for-vendor-splitting)
4. [Import Resolution](#4-import-resolution) — **HIGH**
   - 4.1 [Avoid Barrel File Imports](#41-avoid-barrel-file-imports)
   - 4.2 [Configure Path Aliases for Clean Imports](#42-configure-path-aliases-for-clean-imports)
   - 4.3 [Import SVGs as Strings Instead of Components](#43-import-svgs-as-strings-instead-of-components)
   - 4.4 [Use Explicit File Extensions in Imports](#44-use-explicit-file-extensions-in-imports)
   - 4.5 [Use Glob Imports Carefully](#45-use-glob-imports-carefully)
5. [Build Configuration](#5-build-configuration) — **HIGH**
   - 5.1 [Configure Output Directory and Caching](#51-configure-output-directory-and-caching)
   - 5.2 [Consider Rolldown for Faster Builds](#52-consider-rolldown-for-faster-builds)
   - 5.3 [Disable Source Maps in Production](#53-disable-source-maps-in-production)
   - 5.4 [Enable CSS Code Splitting](#54-enable-css-code-splitting)
   - 5.5 [Target Modern Browsers](#55-target-modern-browsers)
   - 5.6 [Use esbuild for Minification](#56-use-esbuild-for-minification)
6. [Development Server](#6-development-server) — **MEDIUM-HIGH**
   - 6.1 [Configure HTTPS and Proxy for Development](#61-configure-https-and-proxy-for-development)
   - 6.2 [Increase File Descriptor Limits on Linux](#62-increase-file-descriptor-limits-on-linux)
   - 6.3 [Keep Browser Cache Enabled in DevTools](#63-keep-browser-cache-enabled-in-devtools)
   - 6.4 [Use Polling for WSL File Watching](#64-use-polling-for-wsl-file-watching)
   - 6.5 [Warm Up Frequently Used Files](#65-warm-up-frequently-used-files)
7. [CSS Optimization](#7-css-optimization) — **MEDIUM**
   - 7.1 [Extract Critical CSS for Initial Paint](#71-extract-critical-css-for-initial-paint)
   - 7.2 [Prefer CSS Over Preprocessors When Possible](#72-prefer-css-over-preprocessors-when-possible)
   - 7.3 [Use CSS Modules for Component Styles](#73-use-css-modules-for-component-styles)
   - 7.4 [Use Lightning CSS Instead of PostCSS](#74-use-lightning-css-instead-of-postcss)
8. [Advanced Patterns](#8-advanced-patterns) — **LOW-MEDIUM**
   - 8.1 [Configure Library Mode for Package Development](#81-configure-library-mode-for-package-development)
   - 8.2 [Externalize Dependencies for SSR](#82-externalize-dependencies-for-ssr)
   - 8.3 [Profile Build Performance](#83-profile-build-performance)
   - 8.4 [Use Static Environment Variables](#84-use-static-environment-variables)

---

## 1. Dependency Pre-bundling

**Impact: CRITICAL**

Misconfigured pre-bundling causes repeated discovery, slow cold starts, and full-page reloads. Proper include/exclude configuration yields 10-100× faster module resolution.

### 1.1 Configure Custom Entry Points for Discovery

**Impact: HIGH (prevents runtime discovery and full-page reloads)**

Vite crawls HTML files by default to discover dependencies. For non-standard setups (SSR, library mode), configure `optimizeDeps.entries` to ensure complete discovery.

**Incorrect (missing entry points):**

```javascript
// vite.config.js
export default defineConfig({
  // Only crawls index.html
  // SSR entry and test files not discovered
  // Runtime discovery causes full-page reloads
})
```

**Correct (explicit entry points):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    entries: [
      'index.html',
      'src/server/entry.ts',     // SSR entry
      'src/**/*.spec.ts'         // Test files
    ]
  }
})
// All dependencies discovered at startup
// No runtime reloads
```

**When to configure entries:**
- SSR applications with separate server entries
- Library mode projects
- Projects with test files importing dependencies
- Non-HTML entry points (Web Workers)

**For monorepos:**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    entries: [
      'apps/web/index.html',
      'apps/admin/index.html',
      'packages/*/src/index.ts'
    ]
  }
})
```

Reference: [Dep Optimization Options](https://vite.dev/config/dep-optimization-options)

### 1.2 Configure holdUntilCrawlEnd for Startup Behavior

**Impact: HIGH (prevents mid-session reloads)**

When Vite discovers new dependencies after initial load, it triggers a full-page reload. The `holdUntilCrawlEnd` option controls whether Vite waits for full discovery before optimizing.

**Incorrect (disabling wait causes more reloads):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    holdUntilCrawlEnd: false  // Don't wait for full crawl
    // Deps discovered after initial optimization cause reloads
  }
})
```

**Correct (default: wait for full discovery):**

```javascript
// vite.config.js
export default defineConfig({
  // holdUntilCrawlEnd: true is the default
  // Vite waits for all static imports to be discovered
  // Fewer mid-session reloads
})
```

**When to set `false`:**
- All dependencies are pre-identified in `include`
- You need fastest possible cold start
- Very large projects where crawl is slow

**Benefits of default `true`:**
- Eliminates mid-session full-page reloads
- More stable development experience
- Better for projects with dynamic imports

Reference: [Dep Optimization Options](https://vite.dev/config/dep-optimization-options)

### 1.3 Exclude Small ESM Dependencies

**Impact: CRITICAL (reduces pre-bundling overhead)**

Small dependencies that are already valid ESM should be excluded from pre-bundling. This lets the browser load them directly, reducing startup time.

**Incorrect (unnecessarily pre-bundling ESM):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    // Pre-bundling everything including tiny ESM packages
    include: ['tiny-esm-lib', 'small-util']
  }
})
```

**Correct (let browser handle small ESM):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    exclude: [
      'tiny-esm-lib',  // Already valid ESM, small
      'small-util'     // Browser can handle directly
    ]
  }
})
```

**When to exclude:**
- Small packages with few modules
- Packages already shipping valid ESM
- Dependencies you're actively developing (linked packages)

**When NOT to exclude:**
- Large packages with many internal modules
- CommonJS-only packages
- Packages causing "does not provide an export" errors

Reference: [Dep Optimization Options](https://vite.dev/config/dep-optimization-options)

### 1.4 Handle Linked Dependencies in Monorepos

**Impact: HIGH (prevents broken module resolution)**

Linked packages (via npm link, yarn link, or workspace protocols) that aren't ESM need special handling. Add them to both `optimizeDeps.include` and `build.commonjsOptions.include`.

**Incorrect (linked CJS package breaks):**

```javascript
// vite.config.js
export default defineConfig({
  // Linked package 'my-lib' uses CommonJS
  // Vite treats it as source, not dependency
  // Module resolution fails
})
```

**Correct (explicit configuration for linked CJS):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    include: ['my-lib']  // Pre-bundle linked package
  },
  build: {
    commonjsOptions: {
      include: [/my-lib/, /node_modules/]
    }
  }
})
```

**For ESM linked packages:**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    exclude: ['my-esm-lib']  // Let browser handle ESM
  }
})
```

**Remember:** Restart dev server with `--force` after changing linked dependency configuration.

Reference: [Dependency Pre-Bundling](https://vite.dev/guide/dep-pre-bundling)

### 1.5 Include Large Dependencies with Many Modules

**Impact: CRITICAL (10-100× faster module resolution)**

Packages with many internal modules (regardless of ESM/CJS format) should be included in pre-bundling. Without this, Vite makes hundreds of HTTP requests, causing slow initial loads.

**Incorrect (runtime discovery, 600+ requests):**

```javascript
// vite.config.js
export default defineConfig({
  // No optimizeDeps configuration
  // lodash-es has 600+ internal modules
  // Browser makes 600+ HTTP requests on first import
})
```

**Correct (pre-bundled into single module):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    include: [
      'lodash-es',   // 600+ ESM modules → 1 module
      'date-fns',    // Many ESM modules → 1 module
      'axios',       // CommonJS → converted to ESM
    ]
  }
})
```

**When to include:**
- **Many internal modules** (lodash-es, date-fns, rxjs) - reduces HTTP requests
- **CommonJS packages** - need ESM conversion for browser
- **Dynamic imports** not discoverable by static analysis

**When to exclude instead:**
- Small ESM packages with few modules
- Dependencies you're actively developing

Reference: [Dependency Pre-Bundling](https://vite.dev/guide/dep-pre-bundling)

### 1.6 Use --force Flag for Dependency Changes

**Impact: CRITICAL (prevents stale cache issues)**

When modifying linked dependencies or troubleshooting pre-bundling issues, use the `--force` flag to clear the cache. Stale caches cause confusing behavior.

**Incorrect (using stale cache):**

```bash
# After modifying a linked dependency
npm run dev
# Changes not reflected due to cached pre-bundle
```

**Correct (force re-bundling):**

```bash
# Clear cache and re-bundle
vite --force

# Or configure in vite.config.js for debugging
```

```javascript
// vite.config.js (temporary for debugging)
export default defineConfig({
  optimizeDeps: {
    force: true  // Remove after debugging
  }
})
```

**When to use --force:**
- After modifying linked dependencies in a monorepo
- When seeing stale module behavior
- After changing `optimizeDeps.include` or `exclude`
- When debugging "module not found" errors

**Cache location:** `node_modules/.vite`

Reference: [Dependency Pre-Bundling](https://vite.dev/guide/dep-pre-bundling)

---

## 2. Plugin Performance

**Impact: CRITICAL**

Slow plugin hooks block dev server startup and transform requests. Auditing and optimizing plugins is essential for large projects.

### 2.1 Audit Community Plugins for Performance

**Impact: HIGH (identifies 50-80% of dev server slowdowns)**

Community plugins may not be optimized. Use `vite-plugin-inspect` and `--debug` flags to identify slow plugins before they impact your development experience.

**Incorrect (blindly trusting plugins):**

```javascript
// vite.config.js
import eslintPlugin from 'vite-plugin-eslint'
import svgIcons from 'vite-plugin-svg-icons'

export default defineConfig({
  plugins: [
    eslintPlugin(),   // Blocks buildStart with full lint
    svgIcons()        // Calls fs.glob on every transform
  ]
})
// Dev server takes 30+ seconds to start
```

**Correct (audit and optimize):**

```bash
# See transform times per plugin
vite --debug plugin-transform

# Generate CPU profile
vite --profile
# Upload to speedscope.app
```

```javascript
// vite.config.js
import Inspect from 'vite-plugin-inspect'

export default defineConfig({
  plugins: [Inspect()]
})
// Visit /__inspect in dev
// See exactly which plugins are slow
```

**Problematic plugins to replace:**

| Slow Plugin | Issue | Alternative |
|-------------|-------|-------------|
| vite-plugin-eslint | Blocks buildStart | vite-plugin-checker |
| vite-plugin-svg-icons | fs.glob every transform | Direct SVG imports |

**What to look for:**
- buildStart taking >100ms
- transform hooks with no early return
- Synchronous filesystem operations

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 2.2 Avoid Long Operations in Startup Hooks

**Impact: CRITICAL (prevents dev server startup delays)**

The `buildStart`, `config`, and `configResolved` hooks are awaited during dev server startup. Long operations in these hooks delay when you can access the site.

**Incorrect (blocking startup hooks):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    async buildStart() {
      // ESLint check blocks startup
      await eslint.lintFiles(['src/**/*.ts'])

      // File system operations block startup
      await glob('src/**/*.svg')
    }
  }
}
// Dev server unavailable until all files checked
```

**Correct (defer to transform or separate process):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    buildStart() {
      // Quick, non-blocking initialization only
      this.cache = new Map()
    },
    async transform(code, id) {
      // Do work per-file as needed
      if (id.endsWith('.ts')) {
        // Lint individual files on demand
      }
    }
  }
}
```

**Alternative:** Use `vite-plugin-checker` for non-blocking linting.

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 2.3 Early Return in Transform Hooks

**Impact: CRITICAL (10-100× faster file processing)**

Transform hooks run on every file request. Check if the file matches your criteria before doing any heavy processing.

**Incorrect (processes all files):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    async transform(code, id) {
      const ast = parse(code)  // Expensive parse on EVERY file

      if (!id.endsWith('.mdx')) {
        return null  // Too late, already parsed
      }

      return transformMdx(ast)
    }
  }
}
```

**Correct (filter first, process later):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    async transform(code, id) {
      // Early return for non-matching files
      if (!id.endsWith('.mdx')) return

      // Only parse files we care about
      const ast = parse(code)
      return transformMdx(ast)
    }
  }
}
```

**Best practices:**
- Check file extension first
- Use simple string checks before regex
- Check for keywords in code before full parsing
- Use `filter` option if plugin supports it

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 2.4 Use Dynamic Imports in Plugin Code

**Impact: CRITICAL (reduces Node.js startup time by 50%+)**

Large dependencies used only in certain plugin hooks should be dynamically imported. Top-level imports slow down Node.js startup for every dev server start.

**Incorrect (eager loading blocks startup):**

```javascript
// my-vite-plugin.js
import { parse } from 'heavy-parser'      // 500ms import
import { transform } from 'big-transformer' // 300ms import

export function myPlugin() {
  return {
    name: 'my-plugin',
    transform(code, id) {
      if (!id.endsWith('.special')) return
      return transform(parse(code))
    }
  }
}
// Startup blocked by 800ms even if .special files are rare
```

**Correct (lazy loading on demand):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    async transform(code, id) {
      if (!id.endsWith('.special')) return

      const { parse } = await import('heavy-parser')
      const { transform } = await import('big-transformer')
      return transform(parse(code))
    }
  }
}
// Only loads when .special files are processed
```

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 2.5 Use SWC Instead of Babel for React

**Impact: HIGH (20-70× faster transforms)**

SWC is a Rust-based compiler that's 20-70× faster than Babel. For React projects, use `@vitejs/plugin-react-swc` instead of `@vitejs/plugin-react`.

**Incorrect (Babel-based transforms):**

```javascript
// vite.config.js
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: ['@emotion/babel-plugin']
      }
    })
  ]
})
// Babel processes every JSX file
```

**Correct (SWC-based transforms):**

```javascript
// vite.config.js
import react from '@vitejs/plugin-react-swc'

export default defineConfig({
  plugins: [react()]
})
// SWC handles JSX 20-70× faster
```

**When you must use Babel:**
- Using Babel-only plugins (some emotion configurations)
- Legacy decorator syntax not supported by SWC
- Custom Babel transforms with no SWC equivalent

**If using @vitejs/plugin-react without Babel config:**

```javascript
// vite.config.js
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    react()  // No babel option = esbuild for production
  ]
})
```

Reference: [Performance | Vite](https://vite.dev/guide/performance)

---

## 3. Bundle Optimization

**Impact: CRITICAL**

Production bundle size directly affects load time. manualChunks, dynamic imports, and tree-shaking reduce payload by 30-70%.

### 3.1 Address Large Chunk Warnings

**Impact: HIGH (indicates 2-5s load time problems)**

When Vite warns "Some chunks are larger than 500 kB", investigate and optimize. Large chunks hurt initial load time.

**Incorrect (ignore warning, raise limit):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    chunkSizeWarningLimit: 1000  // Just hiding the problem
    // Users still download 1MB+ on first visit
  }
})
```

**Correct (investigate and split):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            // Split heavy libs into separate chunks
            if (id.includes('react')) return 'react-vendor'
            if (id.includes('chart')) return 'chart-vendor'
            return 'vendor'
          }
        }
      }
    }
  }
})
```

**Optimization strategies:**

1. **Dynamic import heavy components:**
```typescript
const HeavyChart = lazy(() => import('./HeavyChart'))
```

2. **Replace large libraries:**
```javascript
// moment (300KB) → date-fns (tree-shakeable)
// lodash → lodash-es with named imports
```

3. **Check for duplicates** using bundle analyzer

**Acceptable to increase limit when:**
- Large chunks are lazy-loaded (not initial)
- You've optimized everything possible
- Application truly requires the dependency

Reference: [Build Options](https://vite.dev/config/build-options)

### 3.2 Analyze Bundle Composition

**Impact: CRITICAL (identifies 50-200KB hidden dependencies)**

Use `rollup-plugin-visualizer` to understand what's in your bundle. Hidden large dependencies often cause unexpected bundle size.

**Incorrect (blind optimization):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    // "Bundle is too large"
    // No idea which dependencies are causing it
    // Random optimization attempts
  }
})
```

**Correct (data-driven analysis):**

```javascript
// vite.config.js
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    visualizer({
      open: true,
      filename: 'dist/stats.html',
      gzipSize: true,
      brotliSize: true
    })
  ]
})
```

```bash
# Run analysis
vite build
# Opens interactive treemap showing:
# - moment.js: 300KB (replace with date-fns)
# - lodash: 70KB (use named imports)
# - duplicate React versions: 200KB
```

**What to look for:**
- Unexpectedly large dependencies
- Duplicate packages (different versions)
- Unused code that should be tree-shaken
- Heavy dependencies that could be lazy-loaded

**Common findings and fixes:**
| Finding | Size | Fix |
|---------|------|-----|
| moment.js | 300KB | Replace with date-fns |
| lodash | 70KB | Named imports from lodash-es |
| Icon library | 500KB | Direct imports |

Reference: [Building for Production](https://vite.dev/guide/build)

### 3.3 Configure Asset Inlining Threshold

**Impact: MEDIUM (reduces HTTP requests by 10-50)**

Vite inlines assets smaller than 4KB as base64 URLs. Adjust this threshold based on your asset profile to balance HTTP requests vs bundle size.

**Incorrect (too low threshold, many requests):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    assetsInlineLimit: 0  // No inlining
  }
})
// 50 tiny icons = 50 HTTP requests
// Slow on high-latency connections
```

**Correct (balanced threshold):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    assetsInlineLimit: 4096  // 4KB default
  }
})
// Small icons inlined as data URLs
// Reduces requests without bloating JS
```

**Fine-grained control:**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    assetsInlineLimit: (filePath, content) => {
      // Always inline SVG icons
      if (filePath.endsWith('.svg') && content.length < 10000) {
        return true
      }
      // Never inline photos
      if (/\.(png|jpg|gif)$/.test(filePath)) {
        return false
      }
      return content.length < 4096
    }
  }
})
```

**Considerations:**
- Inlined assets can't be cached separately
- Large base64 strings increase JS parse time
- Many separate files = many requests (less impact with HTTP/2)

Reference: [Build Options](https://vite.dev/config/build-options)

### 3.4 Disable Compressed Size Reporting for Large Projects

**Impact: MEDIUM-HIGH (10-30 seconds faster builds)**

By default, Vite calculates gzip sizes for all chunks. For large projects, this adds significant build time. Disable it when you don't need the information.

**Incorrect (always calculating compression):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    reportCompressedSize: true  // Default
  }
})
// Build output:
// dist/index.js    500 kB │ gzip: 150 kB  (10-30s to calculate)
// dist/vendor.js   800 kB │ gzip: 200 kB
```

**Correct (skip for faster builds):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    reportCompressedSize: false
  }
})
// Build output:
// dist/index.js    500 kB
// dist/vendor.js   800 kB
// Build completes 10-30s faster
```

**When to disable:**
- Large projects with many chunks
- CI/CD pipelines where build time matters
- When you measure compression separately

**When to keep enabled:**
- Small projects (minimal overhead)
- Debugging bundle size issues
- Need quick size feedback during development

Reference: [Build Options](https://vite.dev/config/build-options)

### 3.5 Enable Effective Tree-Shaking

**Impact: HIGH (removes 20-60% of unused code)**

Tree-shaking removes unused code from the bundle. Ensure your dependencies support ESM and avoid patterns that prevent tree-shaking.

**Incorrect (prevents tree-shaking):**

```javascript
// Importing entire library
import _ from 'lodash'
const result = _.get(obj, 'path')

// CommonJS default export
const utils = require('./utils')

// Side-effect imports without sideEffects flag
import './analytics'
```

**Correct (tree-shakeable):**

```javascript
// Named imports from ESM
import { get } from 'lodash-es'
const result = get(obj, 'path')

// ESM imports
import { helper } from './utils'

// Mark side-effect-free in package.json
```

```json
// package.json
{
  "sideEffects": false,
  // Or specify files with side effects
  "sideEffects": ["*.css", "./src/analytics.js"]
}
```

**Verify tree-shaking:**

```bash
# Check what's included
vite build --debug
# Or use bundle analyzer
```

**Dependencies to replace:**
- `lodash` → `lodash-es`
- `moment` → `date-fns`
- `rxjs` → `rxjs` (use pipeable operators)

Reference: [Building for Production](https://vite.dev/guide/build)

### 3.6 Use Dynamic Imports for Route-Level Splitting

**Impact: CRITICAL (reduces initial bundle by 30-70%)**

Load route components dynamically so users only download code for the page they visit. This dramatically reduces initial bundle size.

**Incorrect (eager loading all routes):**

```javascript
// router.js
import Home from './pages/Home'
import Dashboard from './pages/Dashboard'
import Settings from './pages/Settings'
import Analytics from './pages/Analytics'

const routes = [
  { path: '/', component: Home },
  { path: '/dashboard', component: Dashboard },
  { path: '/settings', component: Settings },
  { path: '/analytics', component: Analytics }
]
// All pages in initial bundle
```

**Correct (lazy loading routes):**

```javascript
// router.js (React)
import { lazy, Suspense } from 'react'

const Home = lazy(() => import('./pages/Home'))
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Settings = lazy(() => import('./pages/Settings'))
const Analytics = lazy(() => import('./pages/Analytics'))

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
        <Route path="/analytics" element={<Analytics />} />
      </Routes>
    </Suspense>
  )
}
// Each page loads only when visited
```

**Vue equivalent:**

```javascript
// router.js (Vue)
const routes = [
  { path: '/', component: () => import('./pages/Home.vue') },
  { path: '/dashboard', component: () => import('./pages/Dashboard.vue') }
]
```

Reference: [Building for Production](https://vite.dev/guide/build)

### 3.7 Use manualChunks for Vendor Splitting

**Impact: CRITICAL (improves caching, reduces load time by 30-50%)**

Split vendor dependencies into separate chunks for better caching. When your app code changes, vendor chunks stay cached in the browser.

**Incorrect (single vendor chunk):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            return 'vendor'  // All deps in one chunk
          }
        }
      }
    }
  }
})
// Any dep update invalidates entire vendor cache
```

**Correct (strategic vendor splitting):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            // React ecosystem (rarely changes)
            if (id.includes('react') || id.includes('react-dom') || id.includes('react-router')) {
              return 'react-vendor'
            }
            // Utility libraries
            if (id.includes('lodash') || id.includes('date-fns') || id.includes('axios')) {
              return 'utils-vendor'
            }
            // Heavy charting libs (load separately)
            if (id.includes('chart.js') || id.includes('recharts') || id.includes('d3')) {
              return 'chart-vendor'
            }
            return 'vendor'
          }
        }
      }
    }
  }
})
```

**Benefits:**
- React core cached long-term
- Utility updates don't invalidate React chunk
- Heavy libraries isolated for lazy loading

Reference: [Building for Production](https://vite.dev/guide/build)

---

## 4. Import Resolution

**Impact: HIGH**

Barrel files and implicit extensions cause filesystem thrashing. Direct imports with explicit extensions eliminate unnecessary lookups.

### 4.1 Avoid Barrel File Imports

**Impact: HIGH (prevents loading 100s of unused modules)**

Barrel files (index.js re-exports) force Vite to load all modules even when you need just one. Import directly from source files.

**Incorrect (loads entire library):**

```javascript
// Barrel file loads all 600+ lodash functions
import { debounce } from 'lodash-es'

// Icon library loads all icons
import { IconCheck } from '@tabler/icons-react'

// Your own barrel file
import { Button } from '@/components'
// components/index.ts re-exports 50 components
```

**Correct (direct imports):**

```javascript
// Import specific module
import debounce from 'lodash-es/debounce'

// Direct icon import
import { IconCheck } from '@tabler/icons-react/dist/esm/icons/IconCheck'

// Direct component import
import { Button } from '@/components/Button'
```

**For icon libraries, configure optimizePackageImports:**

```javascript
// vite.config.js
export default defineConfig({
  // Experimental - auto-transforms barrel imports
  experimental: {
    optimizePackageImports: ['@tabler/icons-react', 'lucide-react']
  }
})
```

**In your own codebase:**
- Avoid creating index.ts barrel files
- Import components directly by path
- Use path aliases for cleaner imports

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 4.2 Configure Path Aliases for Clean Imports

**Impact: MEDIUM-HIGH (eliminates brittle relative paths, simplifies refactoring)**

Path aliases eliminate long relative imports and make refactoring easier. Configure them in both Vite and TypeScript for consistency.

**Incorrect (fragile relative paths):**

```typescript
// Deep component importing from utils
import { formatDate } from '../../../utils/date'
import { useAuth } from '../../../hooks/useAuth'
import { Button } from '../../../components/Button'
// Breaks when files move
// Hard to read, error-prone
```

**Correct (stable path aliases):**

```typescript
import { formatDate } from '@/utils/date'
import { useAuth } from '@/hooks/useAuth'
import { Button } from '@/components/Button'
// Clear, consistent, refactor-friendly
```

**Vite configuration:**

```javascript
// vite.config.js
import { resolve } from 'path'

export default defineConfig({
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@utils': resolve(__dirname, './src/utils')
    }
  }
})
```

**TypeScript configuration:**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@utils/*": ["./src/utils/*"]
    }
  }
}
```

**Benefits:**
- Cleaner imports
- Easier refactoring
- Better IDE support

Reference: [Configuring Vite](https://vite.dev/config/)

### 4.3 Import SVGs as Strings Instead of Components

**Impact: MEDIUM-HIGH (reduces transform overhead)**

Transforming SVGs into React/Vue components adds transform overhead. Import as strings or URLs for simple display.

**Incorrect (component transform):**

```typescript
// Each SVG becomes a full React component
import Logo from './logo.svg?react'
import Icon from './icon.svg?react'
// Plugin transforms SVG → JSX → JavaScript
```

**Correct (string or URL import):**

```typescript
// Import as URL (fastest)
import logoUrl from './logo.svg'
// <img src={logoUrl} alt="Logo" />

// Import as raw string
import logoSvg from './logo.svg?raw'
// <div dangerouslySetInnerHTML={{ __html: logoSvg }} />

// Or use inline for simple cases
// <img src="/logo.svg" alt="Logo" />
```

**When to use component transform:**
- SVG needs dynamic props (color, size)
- SVG needs event handlers
- SVG needs to be part of the DOM for accessibility

**When to use strings/URLs:**
- Static images
- Background images
- Decorative icons
- Logos

```javascript
// vite.config.js - avoid default component transform
export default defineConfig({
  // Don't add vite-plugin-svgr unless needed
})
```

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 4.4 Use Explicit File Extensions in Imports

**Impact: HIGH (reduces filesystem checks per import)**

Omitting extensions forces Vite to check multiple possibilities (.ts, .tsx, .js, .jsx, etc.) for every import. Explicit extensions eliminate these lookups.

**Incorrect (multiple filesystem checks):**

```typescript
// Vite checks: Component.ts, Component.tsx, Component.js, Component.jsx, Component/index.ts...
import { Button } from './components/Button'
import { useAuth } from './hooks/useAuth'
import { formatDate } from './utils/date'
```

**Correct (single filesystem check):**

```typescript
import { Button } from './components/Button.tsx'
import { useAuth } from './hooks/useAuth.ts'
import { formatDate } from './utils/date.ts'
```

**Enable TypeScript support:**

```json
// tsconfig.json
{
  "compilerOptions": {
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true
  }
}
```

**Narrow resolve.extensions:**

```javascript
// vite.config.js
export default defineConfig({
  resolve: {
    extensions: ['.ts', '.tsx']  // Only check these
  }
})
```

**Tradeoff:** Explicit extensions are less portable but faster. Use for internal imports; external packages handle their own resolution.

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 4.5 Use Glob Imports Carefully

**Impact: MEDIUM (prevents 100+ unnecessary module loads)**

Vite's `import.meta.glob` is useful for dynamic imports but can accidentally import hundreds of files. Use specific patterns and eager loading judiciously.

**Incorrect (too broad, eager loading):**

```typescript
// Eagerly loads ALL files in pages directory
const modules = import.meta.glob('./pages/**/*.tsx', { eager: true })
// 100 pages = 100 modules in initial bundle

// Too broad pattern
const icons = import.meta.glob('./assets/**/*')
// Matches everything, including large images
```

**Correct (specific patterns, lazy by default):**

```typescript
// Lazy loading (default) - loads on demand
const modules = import.meta.glob('./pages/**/*.tsx')
// modules['/pages/Home.tsx']() returns Promise<Module>

// Specific pattern for just what you need
const routes = import.meta.glob('./pages/[!_]*.tsx')
// Excludes files starting with underscore

// Eager only for small sets
const locales = import.meta.glob('./locales/*.json', { eager: true })
// Small JSON files, ok to eager load
```

**With typed imports:**

```typescript
const modules = import.meta.glob<{ default: React.ComponentType }>(
  './pages/*.tsx'
)
```

**Query parameters:**

```typescript
// Import as URL strings
const images = import.meta.glob('./assets/icons/*.svg', {
  query: '?url',
  import: 'default'
})
```

Reference: [Features | Vite](https://vite.dev/guide/features)

---

## 5. Build Configuration

**Impact: HIGH**

Build target, minification, and source map settings affect build time and output size. Modern targets skip unnecessary legacy transpilation.

### 5.1 Configure Output Directory and Caching

**Impact: MEDIUM (50%+ faster CI rebuilds with caching)**

Proper output directory configuration enables better caching in CI/CD pipelines and prevents stale file issues.

**Incorrect (no caching strategy):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    outDir: 'dist'
    // CI rebuilds from scratch every time
    // node_modules/.vite not cached
    // 5+ minute builds
  }
})
```

**Correct (optimized for CI caching):**

```javascript
// vite.config.js
export default defineConfig({
  cacheDir: 'node_modules/.vite',  // Cache pre-bundled deps
  build: {
    outDir: 'dist',
    emptyOutDir: true
  }
})
```

```yaml
# .github/workflows/build.yml
- name: Cache Vite
  uses: actions/cache@v3
  with:
    path: node_modules/.vite
    key: vite-${{ hashFiles('package-lock.json') }}

# Rebuilds use cached pre-bundled dependencies
```

**Environment-specific output:**

```javascript
// vite.config.js
export default defineConfig(({ mode }) => ({
  build: {
    outDir: `dist/${mode}`
  }
}))
// dist/development, dist/production
```

**Benefits:**
- Cached pre-bundling across CI runs
- Faster incremental builds
- Clean separation of environments

Reference: [Build Options](https://vite.dev/config/build-options)

### 5.2 Consider Rolldown for Faster Builds

**Impact: MEDIUM-HIGH (2-10× faster builds (experimental))**

Rolldown is a Rust-based Rollup replacement that unifies Vite's dev and build tooling. It's experimental but offers significant performance improvements.

**Incorrect (separate tools with inconsistencies):**

```javascript
// vite.config.js
export default defineConfig({
  // Current architecture:
  // Dev:   esbuild (pre-bundling) + native ESM
  // Build: Rollup (bundling) + esbuild (minification)
  // Behavior can differ between dev and prod
})
```

**Correct (unified Rolldown bundler):**

```javascript
// vite.config.js
export default defineConfig({
  builder: {
    name: 'rolldown'  // Experimental
  }
})
// Same bundler for dev and build
// Consistent behavior, faster builds
```

**Benefits:**
- 2-10× faster builds (Rust performance)
- Consistent behavior dev ↔ build
- Better tree-shaking

**Current limitations:**
- Experimental status
- Some Rollup plugins may not work
- API differences in edge cases

**When to try Rolldown:**
- Greenfield projects
- Build time is a significant pain point
- Willing to test experimental features

**When to wait:**
- Production critical applications
- Heavy reliance on Rollup plugins

Reference: [Rolldown Integration](https://vite.dev/guide/rolldown)

### 5.3 Disable Source Maps in Production

**Impact: HIGH (reduces build time significantly)**

Source map generation adds significant build time. Disable for production unless you need them for error tracking.

**Incorrect (always generating sourcemaps):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    sourcemap: true  // Adds 20-50% build time
  }
})
```

**Correct (environment-based):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    sourcemap: process.env.NODE_ENV !== 'production'
  }
})
```

**Hidden source maps (for error tracking):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    sourcemap: 'hidden'  // Generates .map files but no reference in bundles
  }
})
// Upload .map files to error tracking service
// Don't serve them publicly
```

**Options:**
| Value | Output | Use Case |
|-------|--------|----------|
| `false` | No maps | Production (fastest) |
| `true` | Inline + external | Development |
| `'inline'` | Inline only | Simple debugging |
| `'hidden'` | External only | Error tracking services |

**With error tracking:**
- Generate hidden sourcemaps
- Upload to Sentry/Datadog/etc.
- Delete from public deployment

Reference: [Build Options](https://vite.dev/config/build-options)

### 5.4 Enable CSS Code Splitting

**Impact: MEDIUM-HIGH (30-50% smaller initial CSS payload)**

CSS code splitting keeps styles with their JavaScript chunks. Users only download CSS for components they use.

**Incorrect (single CSS file):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    cssCodeSplit: false
  }
})
// All 500KB of CSS loaded on first page
// Dashboard styles loaded even on landing page
```

**Correct (CSS code splitting enabled):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    cssCodeSplit: true  // Default
  }
})
```

```typescript
// Routes lazy load their CSS automatically
const Dashboard = lazy(() => import('./Dashboard'))
// Dashboard.css loads only when user visits /dashboard
```

**How it works:**

```typescript
// Home.tsx
import './Home.css'  // Bundled with Home chunk (50KB)

// Dashboard.tsx (lazy loaded)
import './Dashboard.css'  // Bundled with Dashboard chunk (200KB)

// Initial load: only Home.css
// Dashboard visit: loads Dashboard.css on demand
```

**Benefits:**
- Smaller initial CSS payload
- Better caching (page-specific CSS)
- Reduced unused CSS per page

Reference: [Build Options](https://vite.dev/config/build-options)

### 5.5 Target Modern Browsers

**Impact: HIGH (30-50% less transpilation overhead)**

Vite defaults to modern browser targets. Explicitly setting `esnext` for internal tools or adjusting targets based on your audience reduces unnecessary transpilation.

**Incorrect (over-transpiling for legacy browsers):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    target: 'es2015'  // Transpiles modern syntax unnecessarily
    // async/await → generators
    // optional chaining → verbose checks
    // 30% larger output, slower builds
  }
})
```

**Correct (modern targets):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    // Default: 'baseline-widely-available'
    // Chrome 107+, Edge 107+, Firefox 104+, Safari 16
    target: 'esnext'  // For internal tools, Electron apps
  }
})
```

**For specific browser support:**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    target: ['es2020', 'chrome87', 'safari14']
  }
})
```

**For legacy support (when truly needed):**

```javascript
// vite.config.js
import legacy from '@vitejs/plugin-legacy'

export default defineConfig({
  plugins: [
    legacy({
      targets: ['defaults', 'not IE 11']
    })
  ]
})
// Generates both modern and legacy bundles
// Modern users get fast bundle, legacy get polyfills
```

Reference: [Build Options](https://vite.dev/config/build-options)

### 5.6 Use esbuild for Minification

**Impact: HIGH (20-40× faster than Terser)**

Vite uses esbuild for minification by default, which is 20-40× faster than Terser with only 1-2% larger output.

**Incorrect (slow Terser minification):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true
      }
    }
  }
})
// Minification takes 30+ seconds on large projects
```

**Correct (fast esbuild minification):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    minify: 'esbuild'  // Default, 20-40× faster
  }
})
// Minification completes in 1-2 seconds
```

**When Terser is needed:**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,  // Remove console.* (esbuild: use define)
        passes: 2            // Multiple compression passes
      },
      mangle: {
        properties: true     // Mangle property names
      }
    }
  }
})
// Use only when you need Terser-specific features
```

**Comparison:**
| Minifier | Speed | Output Size |
|----------|-------|-------------|
| esbuild | 20-40× faster | ~1-2% larger |
| terser | Slower | Slightly smaller |

Reference: [Build Options](https://vite.dev/config/build-options)

---

## 6. Development Server

**Impact: MEDIUM-HIGH**

Server warmup, browser configuration, and caching settings affect developer experience. Proper setup yields near-instant HMR.

### 6.1 Configure HTTPS and Proxy for Development

**Impact: MEDIUM (eliminates CORS issues, enables secure contexts)**

Configure dev server proxy to avoid CORS issues and HTTPS for APIs requiring secure contexts.

**Incorrect (CORS errors block development):**

```typescript
// api.ts
fetch('https://api.example.com/users')
// CORS error: No 'Access-Control-Allow-Origin' header
// Development blocked, need backend changes
```

**Correct (proxy through Vite):**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'https://api.example.com',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})
```

```typescript
// api.ts
fetch('/api/users')  // Proxied to https://api.example.com/users
// No CORS issues - same origin from browser's perspective
```

**Enable HTTPS:**

```javascript
// vite.config.js
import basicSsl from '@vitejs/plugin-basic-ssl'

export default defineConfig({
  plugins: [basicSsl()],
  server: {
    https: true
  }
})
// Required for: WebAuthn, Geolocation, Service Workers
```

**WebSocket proxy:**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    proxy: {
      '/socket.io': {
        target: 'ws://localhost:3001',
        ws: true
      }
    }
  }
})
```

Reference: [Server Options | Vite](https://vite.dev/config/server-options)

### 6.2 Increase File Descriptor Limits on Linux

**Impact: MEDIUM-HIGH (prevents EMFILE errors, enables large projects)**

Vite serves files unbundled in development. Large projects can hit OS file descriptor limits, causing errors and slowdowns.

**Incorrect (hitting system limits):**

```bash
# Error messages:
Error: EMFILE: too many open files
Error: ENOSPC: System limit for number of file watchers reached

# Default limits often too low:
ulimit -n  # 1024 (not enough for large projects)
```

**Correct (increased limits):**

```bash
# Check current limits
ulimit -n
cat /proc/sys/fs/inotify/max_user_watches

# Increase file descriptor limit
ulimit -n 65536

# Increase inotify watches (Linux)
sudo sysctl fs.inotify.max_user_watches=524288
```

**Permanent configuration:**

```bash
# ~/.bashrc or ~/.zshrc
ulimit -n 65536

# /etc/sysctl.conf (Linux)
fs.inotify.max_user_watches=524288
```

**Alternative: Reduce watched files**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    watch: {
      ignored: ['**/node_modules/**', '**/dist/**', '**/.git/**']
    }
  }
})
```

**macOS equivalent:**

```bash
sudo launchctl limit maxfiles 65536 200000
```

Reference: [Troubleshooting | Vite](https://vite.dev/guide/troubleshooting)

### 6.3 Keep Browser Cache Enabled in DevTools

**Impact: MEDIUM-HIGH (5-10× faster reloads in development)**

When Browser DevTools are open with "Disable cache" checked, Vite's aggressive caching is bypassed, causing slower reloads.

**Incorrect (cache disabled in DevTools):**

```plaintext
Browser DevTools → Network tab → ☑ "Disable cache"
Every file request bypasses Vite's cache
Hot reloads: 2-5 seconds
Pre-bundled deps re-downloaded
```

**Correct (cache enabled):**

```plaintext
Browser DevTools → Network tab → ☐ "Disable cache"
Vite's caching works as intended
Hot reloads: 10-50ms
Pre-bundled deps cached (max-age=31536000)
```

**Why this matters:**

Vite uses aggressive caching:
- Pre-bundled dependencies: `max-age=31536000,immutable`
- Source files: fast 304 responses
- HMR updates only changed modules

**Development profile recommendation:**

```bash
# Chrome with clean profile (no extensions)
google-chrome --user-data-dir=/tmp/vite-dev

# Or use incognito mode
# Extensions can intercept requests and slow Vite
```

**Problematic extensions:**
- Ad blockers
- Privacy extensions
- React DevTools (can slow large apps)

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 6.4 Use Polling for WSL File Watching

**Impact: MEDIUM (enables HMR on Windows filesystem in WSL)**

WSL (Windows Subsystem for Linux) doesn't properly propagate file system events to Linux processes when files are on the Windows filesystem. Enable polling for HMR to work.

**Incorrect (inotify fails on Windows filesystem):**

```bash
# Project on Windows filesystem
pwd  # /mnt/c/Users/you/project

npm run dev
# Edit file...
# Nothing happens - HMR doesn't detect changes
```

**Correct (enable polling):**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    watch: {
      usePolling: true,
      interval: 100
    }
  }
})
// HMR works on Windows filesystem
```

**Better solution: Use Linux filesystem**

```bash
# Move project to WSL filesystem
mv /mnt/c/Users/you/project ~/project
cd ~/project
npm run dev
# HMR works without polling (faster, less CPU)
```

**Conditional configuration:**

```javascript
// vite.config.js
const isWSL = process.platform === 'linux' &&
  process.env.WSL_DISTRO_NAME !== undefined

export default defineConfig({
  server: {
    watch: isWSL ? { usePolling: true } : undefined
  }
})
```

**Note:** Polling uses more CPU than inotify. Prefer moving project to Linux filesystem when possible.

Reference: [Troubleshooting | Vite](https://vite.dev/guide/troubleshooting)

### 6.5 Warm Up Frequently Used Files

**Impact: MEDIUM-HIGH (eliminates transform latency for common files)**

Use `server.warmup` to pre-transform files that are always requested. This eliminates the transform latency on first load.

**Incorrect (cold transforms on first request):**

```javascript
// vite.config.js
export default defineConfig({
  // First request to App.tsx triggers transform
  // User sees delay on initial page load
})
```

**Correct (pre-transformed common files):**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    warmup: {
      clientFiles: [
        './src/App.tsx',
        './src/components/Layout.tsx',
        './src/hooks/useAuth.ts',
        './src/utils/api.ts'
      ]
    }
  }
})
```

**With SSR:**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    warmup: {
      clientFiles: ['./src/main.tsx'],
      ssrFiles: ['./src/entry-server.tsx']
    }
  }
})
```

**Find candidates to warm up:**

```bash
# See which files are transformed
vite --debug transform
# Add frequently appearing files to warmup list
```

**Benefits:**
- Faster initial page load
- Transforms happen during startup
- Better developer experience

Reference: [Performance | Vite](https://vite.dev/guide/performance)

---

## 7. CSS Optimization

**Impact: MEDIUM**

Lightning CSS over PostCSS, code splitting, and preprocessor choices affect both build time and runtime performance.

### 7.1 Extract Critical CSS for Initial Paint

**Impact: MEDIUM (200-500ms faster First Contentful Paint)**

Critical CSS inlines styles needed for above-the-fold content, reducing render-blocking resources.

**Incorrect (all CSS blocks rendering):**

```html
<!-- index.html -->
<head>
  <link rel="stylesheet" href="/assets/styles.css">
  <!-- 500KB CSS blocks rendering -->
  <!-- User sees blank page for 2s -->
</head>
```

**Correct (critical CSS inlined):**

```html
<!-- index.html -->
<head>
  <!-- Critical CSS inlined -->
  <style>
    body { margin: 0; font-family: system-ui; }
    .header { height: 64px; background: #fff; }
    .hero { min-height: 400px; }
  </style>

  <!-- Non-critical CSS loaded async -->
  <link rel="preload" href="/assets/styles.css" as="style"
        onload="this.onload=null;this.rel='stylesheet'">
</head>
```

**Automated with plugin:**

```javascript
// vite.config.js
import critical from 'vite-plugin-critical'

export default defineConfig({
  plugins: [
    critical({
      criticalUrl: 'http://localhost:5173',
      criticalPages: [{ uri: '/', template: 'index' }],
      criticalConfig: {
        inline: true,
        dimensions: [
          { width: 375, height: 667 },
          { width: 1920, height: 1080 }
        ]
      }
    })
  ]
})
```

**Benefits:**
- Faster First Contentful Paint
- Reduced render-blocking
- Better Lighthouse scores

Reference: [Building for Production](https://vite.dev/guide/build)

### 7.2 Prefer CSS Over Preprocessors When Possible

**Impact: MEDIUM (reduces transform overhead)**

Modern CSS supports nesting, variables, and other features that previously required Sass/Less. Native CSS is faster to process.

**Incorrect (preprocessor for basic features):**

```scss
// styles.scss
$primary: #007bff;
$spacing: 8px;

.button {
  color: $primary;
  padding: $spacing;

  &:hover {
    opacity: 0.8;
  }

  .icon {
    margin-right: $spacing;
  }
}
// Requires sass compilation
```

**Correct (native CSS with nesting):**

```css
/* styles.css */
:root {
  --primary: #007bff;
  --spacing: 8px;
}

.button {
  color: var(--primary);
  padding: var(--spacing);

  &:hover {
    opacity: 0.8;
  }

  .icon {
    margin-right: var(--spacing);
  }
}
/* Native CSS, no preprocessing needed */
```

**When to use preprocessors:**
- Team already uses Sass/Less
- Need advanced functions (color manipulation)
- Complex mixins
- Existing codebase

**When to use native CSS:**
- New projects
- Simple styling needs
- Maximum performance
- Smaller team

**Enable CSS nesting in PostCSS:**

```javascript
// postcss.config.js
export default {
  plugins: {
    'postcss-nesting': {}
  }
}
```

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 7.3 Use CSS Modules for Component Styles

**Impact: MEDIUM (eliminates style conflicts, enables tree-shaking)**

CSS Modules provide automatic class name scoping and integrate well with Vite's code splitting.

**Incorrect (global styles cause conflicts):**

```css
/* Button.css */
.button {
  background: blue;
}
/* Conflicts with other .button classes */
/* Unused styles still bundled */
```

```typescript
// Button.tsx
import './Button.css'

export function Button() {
  return <button className="button">Click</button>
}
```

**Correct (scoped CSS Modules):**

```css
/* Button.module.css */
.button {
  background: blue;
}

.primary {
  background: green;
}
```

```typescript
// Button.tsx
import styles from './Button.module.css'

export function Button({ variant }) {
  return (
    <button className={`${styles.button} ${styles[variant]}`}>
      Click
    </button>
  )
}
// Classes become: Button_button_x7d3f
// No conflicts, tree-shakeable
```

**Configure CSS Modules:**

```javascript
// vite.config.js
export default defineConfig({
  css: {
    modules: {
      localsConvention: 'camelCase',
      generateScopedName: '[name]__[local]___[hash:base64:5]'
    }
  }
})
```

**Benefits:**
- No class name collisions
- Dead code elimination works
- Co-located with components

Reference: [Features | Vite](https://vite.dev/guide/features)

### 7.4 Use Lightning CSS Instead of PostCSS

**Impact: MEDIUM (10-100× faster CSS transforms)**

Lightning CSS is a Rust-based CSS processor that's significantly faster than PostCSS for common transformations.

**Incorrect (slow PostCSS for basic transforms):**

```javascript
// vite.config.js
export default defineConfig({
  // PostCSS handles autoprefixer, nesting
  // 500ms+ per CSS file in large projects
})

// postcss.config.js
module.exports = {
  plugins: {
    autoprefixer: {},
    'postcss-nesting': {}
  }
}
```

**Correct (Lightning CSS):**

```javascript
// vite.config.js
export default defineConfig({
  css: {
    transformer: 'lightningcss'
  },
  build: {
    cssMinify: 'lightningcss'
  }
})
// Autoprefixer, nesting handled natively
// 10-100× faster transforms
```

**What Lightning CSS handles:**
- Autoprefixer (vendor prefixes)
- CSS nesting
- CSS modules
- Color function transforms
- Custom media queries

**When PostCSS is still needed:**

```javascript
// vite.config.js
export default defineConfig({
  css: {
    transformer: 'lightningcss'
    // PostCSS config still works for:
    // - TailwindCSS
    // - Custom PostCSS plugins
  }
})
```

Reference: [Features | Vite](https://vite.dev/guide/features)

---

## 8. Advanced Patterns

**Impact: LOW-MEDIUM**

SSR externalization, environment variables, and profiling techniques for specific optimization scenarios.

### 8.1 Configure Library Mode for Package Development

**Impact: LOW-MEDIUM (2-3× smaller output, proper ESM/CJS support)**

When building a library for npm, use Vite's library mode for optimized output formats with proper externalization.

**Incorrect (bundling dependencies into library):**

```javascript
// vite.config.js
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    // Using default app build settings
    // React bundled into library = 100KB+ bloat
    // Consumers get duplicate React
  }
})
```

**Correct (library mode with externals):**

```javascript
// vite.config.js
import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'MyLib',
      fileName: 'my-lib'
    },
    rollupOptions: {
      external: ['react', 'react-dom'],
      output: {
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM'
        }
      }
    }
  }
})
```

**package.json exports:**

```json
{
  "name": "my-lib",
  "type": "module",
  "exports": {
    ".": {
      "import": "./dist/my-lib.js",
      "require": "./dist/my-lib.cjs"
    }
  },
  "main": "./dist/my-lib.cjs",
  "module": "./dist/my-lib.js",
  "peerDependencies": {
    "react": "^18.0.0"
  }
}
```

**Performance tips:**
- Externalize all peer dependencies
- Use `preserveModules` for tree-shaking
- Generate TypeScript declarations with `vite-plugin-dts`

Reference: [Building for Production](https://vite.dev/guide/build)

### 8.2 Externalize Dependencies for SSR

**Impact: MEDIUM (2-5× faster SSR builds)**

For SSR, CommonJS dependencies can be externalized from Vite's transform system. This uses Node.js `require()` directly, improving both build and runtime performance.

**Incorrect (bundling all dependencies for SSR):**

```javascript
// vite.config.js
export default defineConfig({
  ssr: {
    noExternal: true  // Bundle everything
    // Transforms React, lodash, etc. unnecessarily
    // SSR bundle becomes huge
    // Build takes 10× longer
  }
})
```

**Correct (externalize CommonJS dependencies):**

```javascript
// vite.config.js
export default defineConfig({
  ssr: {
    external: ['react', 'react-dom', 'lodash'],
    noExternal: [
      '@my-org/ui-components',  // ESM-only, needs transform
      /\.css$/                   // CSS must be processed
    ]
  }
})
```

**Auto-externalize with exceptions:**

```javascript
// vite.config.js
export default defineConfig({
  ssr: {
    external: true,  // Externalize all node_modules
    noExternal: [
      // Only bundle packages that need transformation
      'esm-only-package',
      '@org/linked-package'
    ]
  }
})
```

**When to externalize:**
- CommonJS packages (react, lodash)
- Large dependencies
- Node.js native modules

**When to bundle (noExternal):**
- ESM-only packages without CJS build
- Linked workspace packages
- Packages with side-effect imports

Reference: [Server-Side Rendering](https://vite.dev/guide/ssr)

### 8.3 Profile Build Performance

**Impact: LOW-MEDIUM (pinpoints 80% of bottlenecks)**

Use Vite's built-in profiling to identify specific performance bottlenecks in your build pipeline.

**Incorrect (guessing at performance issues):**

```javascript
// vite.config.js
export default defineConfig({
  // "Build feels slow"
  // Randomly trying optimizations
  // No data to guide decisions
})
```

**Correct (data-driven profiling):**

```bash
# Generate CPU profile
vite build --profile
# Creates vite-profile-0.cpuprofile
```

```javascript
// vite.config.js
import Inspect from 'vite-plugin-inspect'

export default defineConfig({
  plugins: [
    Inspect()  // Visit /__inspect in dev
  ]
})
// See exactly which plugins take time
```

**Debug plugin transforms:**

```bash
# See transform times per file
vite --debug plugin-transform

# Example output:
# 10:32:15 [vite] ✓ transform (23ms) src/App.tsx
# 10:32:15 [vite] ✓ transform (156ms) src/HeavyComponent.tsx  ← bottleneck
```

**Analyze with speedscope:**

1. Upload `.cpuprofile` to https://www.speedscope.app
2. Look for wide bars (long-running operations)
3. Identify plugin names in stack traces

**Fix common issues:**
- Slow plugin → lazy import dependencies
- Many transforms → add file filters
- Large modules → dynamic imports

Reference: [Performance | Vite](https://vite.dev/guide/performance)

### 8.4 Use Static Environment Variables

**Impact: MEDIUM (enables tree-shaking of dev-only code)**

Vite replaces `import.meta.env` values statically at build time. Use full static strings to enable dead code elimination.

**Incorrect (dynamic access prevents tree-shaking):**

```typescript
// Runtime check - not eliminated
const key = 'DEV'
if (import.meta.env[key]) {
  console.log('Development mode')
}

// Computed access
const envKey = 'VITE_API_URL'
const url = import.meta.env[envKey]
```

**Correct (static access enables tree-shaking):**

```typescript
// Compile-time elimination
if (import.meta.env.DEV) {
  console.log('Development mode')
}
// Entire block removed in production

// Static access
const url = import.meta.env.VITE_API_URL
// Replaced with actual value at build time
```

**Built-in env variables:**

```typescript
import.meta.env.MODE       // 'development' | 'production'
import.meta.env.DEV        // true in dev
import.meta.env.PROD       // true in prod
import.meta.env.SSR        // true in SSR
import.meta.env.BASE_URL   // base path
```

**Custom env variables:**

```env
# .env
VITE_API_URL=https://api.example.com
VITE_FEATURE_FLAG=true
```

```typescript
// Only VITE_ prefixed vars are exposed
const api = import.meta.env.VITE_API_URL
```

**Type declarations:**

```typescript
// env.d.ts
interface ImportMetaEnv {
  readonly VITE_API_URL: string
  readonly VITE_FEATURE_FLAG: string
}
```

Reference: [Env Variables and Modes](https://vite.dev/guide/env-and-mode)

---

## References

1. [https://vite.dev/guide/performance](https://vite.dev/guide/performance)
2. [https://vite.dev/config/build-options](https://vite.dev/config/build-options)
3. [https://vite.dev/guide/dep-pre-bundling](https://vite.dev/guide/dep-pre-bundling)
4. [https://vite.dev/config/dep-optimization-options](https://vite.dev/config/dep-optimization-options)
5. [https://vite.dev/guide/build](https://vite.dev/guide/build)
6. [https://vite.dev/guide/ssr](https://vite.dev/guide/ssr)
7. [https://lightningcss.dev/docs.html](https://lightningcss.dev/docs.html)
8. [https://rolldown.rs](https://rolldown.rs)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |