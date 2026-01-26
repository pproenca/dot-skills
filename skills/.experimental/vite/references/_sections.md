# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Dependency Pre-bundling (deps)

**Impact:** CRITICAL
**Description:** Misconfigured pre-bundling causes repeated discovery, slow cold starts, and full-page reloads. Proper include/exclude configuration yields 10-100× faster module resolution.

## 2. Plugin Performance (plugin)

**Impact:** CRITICAL
**Description:** Slow plugin hooks block dev server startup and transform requests. Auditing and optimizing plugins is essential for large projects.

## 3. Bundle Optimization (bundle)

**Impact:** CRITICAL
**Description:** Production bundle size directly affects load time. manualChunks, dynamic imports, and tree-shaking reduce payload by 30-70%.

## 4. Import Resolution (import)

**Impact:** HIGH
**Description:** Barrel files and implicit extensions cause filesystem thrashing. Direct imports with explicit extensions eliminate unnecessary lookups.

## 5. Build Configuration (build)

**Impact:** HIGH
**Description:** Build target, minification, and source map settings affect build time and output size. Modern targets skip unnecessary legacy transpilation.

## 6. Development Server (dev)

**Impact:** MEDIUM-HIGH
**Description:** Server warmup, browser configuration, and caching settings affect developer experience. Proper setup yields near-instant HMR.

## 7. CSS Optimization (css)

**Impact:** MEDIUM
**Description:** Lightning CSS over PostCSS, code splitting, and preprocessor choices affect both build time and runtime performance.

## 8. Advanced Patterns (advanced)

**Impact:** LOW-MEDIUM
**Description:** SSR externalization, environment variables, and profiling techniques for specific optimization scenarios.
