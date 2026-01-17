# Tailwind CSS v4

**Version 0.1.0**  
Tailwind Labs  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization and best practices guide for Tailwind CSS v4, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (build configuration, CSS generation) to incremental (animation patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Build Configuration](#1-build-configuration) — **CRITICAL**
   - 1.1 [Leverage Automatic Content Detection](#11-leverage-automatic-content-detection)
   - 1.2 [Remove Redundant PostCSS Plugins](#12-remove-redundant-postcss-plugins)
   - 1.3 [Use Correct CLI Package](#13-use-correct-cli-package)
   - 1.4 [Use CSS Import Over @tailwind Directives](#14-use-css-import-over-tailwind-directives)
   - 1.5 [Use Node.js 20+ for Optimal Performance](#15-use-nodejs-20-for-optimal-performance)
   - 1.6 [Use Vite Plugin Over PostCSS](#16-use-vite-plugin-over-postcss)
2. [CSS Generation](#2-css-generation) — **CRITICAL**
   - 2.1 [Avoid Excessive Theme Variables](#21-avoid-excessive-theme-variables)
   - 2.2 [Use @utility for Custom Utilities](#22-use-utility-for-custom-utilities)
   - 2.3 [Use CSS-First Configuration Over JavaScript](#23-use-css-first-configuration-over-javascript)
   - 2.4 [Use Dynamic Utility Values](#24-use-dynamic-utility-values)
   - 2.5 [Use OKLCH Color Space for Vivid Colors](#25-use-oklch-color-space-for-vivid-colors)
   - 2.6 [Use Parentheses for CSS Variable References](#26-use-parentheses-for-css-variable-references)
3. [Bundle Optimization](#3-bundle-optimization) — **HIGH**
   - 3.1 [Avoid Play CDN in Production](#31-avoid-play-cdn-in-production)
   - 3.2 [Avoid Sass/Less Preprocessors](#32-avoid-sassless-preprocessors)
   - 3.3 [Enable CSS Minification in Production](#33-enable-css-minification-in-production)
   - 3.4 [Extract Critical CSS for Initial Render](#34-extract-critical-css-for-initial-render)
   - 3.5 [Remove Built-in Plugins](#35-remove-built-in-plugins)
4. [Utility Patterns](#4-utility-patterns) — **HIGH**
   - 4.1 [Use Explicit Border and Ring Colors](#41-use-explicit-border-and-ring-colors)
   - 4.2 [Use Left-to-Right Variant Stacking](#42-use-left-to-right-variant-stacking)
   - 4.3 [Use Renamed Utility Classes](#43-use-renamed-utility-classes)
   - 4.4 [Use Slash Opacity Modifier](#44-use-slash-opacity-modifier)
   - 4.5 [Use Trailing Important Modifier](#45-use-trailing-important-modifier)
   - 4.6 [Use via-none to Reset Gradient Stops](#46-use-via-none-to-reset-gradient-stops)
5. [Component Architecture](#5-component-architecture) — **MEDIUM-HIGH**
   - 5.1 [Avoid Overusing @apply](#51-avoid-overusing-apply)
   - 5.2 [Customize Container with @utility](#52-customize-container-with-utility)
   - 5.3 [Leverage Smart Utility Sorting](#53-leverage-smart-utility-sorting)
   - 5.4 [Understand Utility File Scope](#54-understand-utility-file-scope)
   - 5.5 [Use @reference for CSS Module Integration](#55-use-reference-for-css-module-integration)
6. [Theming & Design Tokens](#6-theming-design-tokens) — **MEDIUM**
   - 6.1 [Leverage Runtime CSS Variables](#61-leverage-runtime-css-variables)
   - 6.2 [Set color-scheme for Native Dark Mode](#62-set-color-scheme-for-native-dark-mode)
   - 6.3 [Use Class-Based Dark Mode for Control](#63-use-class-based-dark-mode-for-control)
   - 6.4 [Use Prefix for Variable Namespacing](#64-use-prefix-for-variable-namespacing)
   - 6.5 [Use Semantic Design Token Names](#65-use-semantic-design-token-names)
7. [Responsive & Adaptive](#7-responsive-adaptive) — **MEDIUM**
   - 7.1 [Define Custom Breakpoints in @theme](#71-define-custom-breakpoints-in-theme)
   - 7.2 [Understand Hover Behavior on Touch Devices](#72-understand-hover-behavior-on-touch-devices)
   - 7.3 [Use Container Queries for Component-Level Responsiveness](#73-use-container-queries-for-component-level-responsiveness)
   - 7.4 [Use Logical Properties for RTL Support](#74-use-logical-properties-for-rtl-support)
   - 7.5 [Use Mobile-First Responsive Design](#75-use-mobile-first-responsive-design)
8. [Animation & Transitions](#8-animation-transitions) — **LOW-MEDIUM**
   - 8.1 [Use @starting-style for Entry Animations](#81-use-starting-style-for-entry-animations)
   - 8.2 [Use Built-in 3D Transform Utilities](#82-use-built-in-3d-transform-utilities)
   - 8.3 [Use GPU-Accelerated Transform Properties](#83-use-gpu-accelerated-transform-properties)
   - 8.4 [Use OKLCH Gradient Interpolation](#84-use-oklch-gradient-interpolation)

---

## 1. Build Configuration

**Impact: CRITICAL**

Build tooling decisions cascade through the entire pipeline. Vite plugin vs PostCSS, content detection, and configuration approach determine baseline performance with 5-100× build time differences.

### 1.1 Leverage Automatic Content Detection

**Impact: CRITICAL (eliminates manual configuration, prevents missing utilities)**

Tailwind CSS v4 automatically detects template files without manual configuration. Only use `@source` when you need to include files outside the standard detection scope.

**Incorrect (unnecessary manual configuration):**

```css
/* styles.css */
@import "tailwindcss";

/* Redundant - these paths are auto-detected */
@source "./src/**/*.{js,ts,jsx,tsx}";
@source "./components/**/*.vue";
@source "./app/**/*.tsx";
```

**Correct (minimal configuration):**

```css
/* styles.css */
@import "tailwindcss";

/* Only specify external packages not in your repo */
@source "../node_modules/@my-company/ui-lib";
```

**When to use @source:**
- External UI libraries in node_modules
- Files outside the project root
- Paths excluded by .gitignore that you need to include

**Auto-ignored paths:**
- Files listed in .gitignore
- Binary files (images, videos, zips)
- node_modules (unless explicitly sourced)

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)

### 1.2 Remove Redundant PostCSS Plugins

**Impact: HIGH (reduces plugin overhead, simplifies configuration)**

Tailwind CSS v4's `@tailwindcss/postcss` plugin includes functionality that previously required separate plugins. Remove redundant plugins to simplify configuration and reduce build overhead.

**Incorrect (redundant plugins):**

```javascript
// postcss.config.js
export default {
  plugins: [
    "postcss-import",           // Now built-in
    "tailwindcss/nesting",      // Now built-in
    "@tailwindcss/postcss",
    "autoprefixer",             // Now built-in
  ],
};
```

**Correct (simplified configuration):**

```javascript
// postcss.config.js
export default {
  plugins: ["@tailwindcss/postcss"],
};
```

**Built-in functionality in v4:**
- `@import` processing (no postcss-import needed)
- CSS nesting (no tailwindcss/nesting needed)
- Vendor prefixing (no autoprefixer needed)

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 1.3 Use Correct CLI Package

**Impact: HIGH (prevents build failures, ensures v4 compatibility)**

Tailwind CSS v4 uses a separate CLI package. Using the old CLI command with v4 will cause build failures.

**Incorrect (v3 CLI command):**

```bash
# Old CLI - incompatible with v4
npx tailwindcss -i input.css -o output.css

# Results in missing utilities or errors
```

**Correct (v4 CLI package):**

```bash
# New CLI package for v4
npx @tailwindcss/cli -i input.css -o output.css
```

```json
{
  "scripts": {
    "build:css": "tailwindcss -i ./src/input.css -o ./dist/output.css"
  },
  "devDependencies": {
    "@tailwindcss/cli": "^4.0.0"
  }
}
```

**Note:** If using Vite or PostCSS integration, you typically don't need the CLI at all.

Reference: [Tailwind CSS Installation](https://tailwindcss.com/docs/installation)

### 1.4 Use CSS Import Over @tailwind Directives

**Impact: CRITICAL (eliminates deprecated patterns, enables v4 features)**

Tailwind CSS v4 replaces the old `@tailwind` directives with a single CSS import statement. This enables automatic content detection and modern CSS features.

**Incorrect (v3 deprecated directives):**

```css
/* styles.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
/* Requires explicit content configuration */
```

**Correct (v4 CSS import):**

```css
/* styles.css */
@import "tailwindcss";
/* Automatic content detection, zero configuration */
```

**Benefits:**
- Zero configuration required for most projects
- Automatic template file detection
- Built-in @import support without additional plugins
- Single source of truth for styles

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 1.5 Use Node.js 20+ for Optimal Performance

**Impact: CRITICAL (required for upgrade tool, enables modern optimizations)**

Tailwind CSS v4 and its upgrade tool require Node.js 20 or higher. Older Node versions may cause build failures or suboptimal performance.

**Incorrect (outdated Node version):**

```json
{
  "engines": {
    "node": ">=16.0.0"
  }
}
```

```bash
# Node 16/18 may cause issues
npx @tailwindcss/upgrade
# Error: Requires Node.js 20+
```

**Correct (modern Node version):**

```json
{
  "engines": {
    "node": ">=20.0.0"
  }
}
```

```bash
# Node 20+ runs optimally
npx @tailwindcss/upgrade
# Upgrade completes successfully
```

**Benefits:**
- Full compatibility with Tailwind v4 tooling
- Better performance from V8 engine improvements
- Access to modern JavaScript features
- Required for automated migration

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 1.6 Use Vite Plugin Over PostCSS

**Impact: CRITICAL (3-10× faster incremental builds)**

The first-party Vite plugin provides tighter integration and significantly faster builds than the PostCSS plugin, especially for incremental rebuilds during development.

**Incorrect (slower PostCSS approach):**

```typescript
// postcss.config.js
export default {
  plugins: ["@tailwindcss/postcss"],
};
// Incremental rebuilds: ~5ms
```

**Correct (optimized Vite plugin):**

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
});
// Incremental rebuilds: ~192µs (26× faster)
```

**When NOT to use this pattern:**
- Projects not using Vite as their build tool
- Legacy projects requiring PostCSS pipeline compatibility

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

---

## 2. CSS Generation

**Impact: CRITICAL**

How utilities are generated affects bundle size by 2-10×. @theme overuse, duplicate utilities, and JIT inefficiencies bloat CSS output and slow browser parsing.

### 2.1 Avoid Excessive Theme Variables

**Impact: CRITICAL (reduces CSS variable overhead by 50-80%)**

Every `@theme` variable generates a CSS custom property and multiple utility classes. Define only the tokens your design system actually needs.

**Incorrect (excessive variables):**

```css
@theme {
  /* 50 color shades when only 5 are used */
  --color-gray-50: oklch(0.985 0 0);
  --color-gray-100: oklch(0.967 0 0);
  --color-gray-150: oklch(0.945 0 0);
  --color-gray-200: oklch(0.923 0 0);
  /* ...40 more shades... */
  --color-gray-950: oklch(0.145 0 0);

  /* Generates hundreds of unused utilities */
}
```

**Correct (minimal token set):**

```css
@theme {
  /* Only define colors actually used in the design */
  --color-gray-100: oklch(0.967 0 0);
  --color-gray-300: oklch(0.869 0 0);
  --color-gray-500: oklch(0.708 0 0);
  --color-gray-700: oklch(0.373 0 0);
  --color-gray-900: oklch(0.21 0 0);
}
```

**Benefits:**
- Smaller CSS output (fewer variables and utilities)
- Faster CSS parsing in browser
- Clearer design system constraints
- Better maintainability

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)

### 2.2 Use @utility for Custom Utilities

**Impact: HIGH (enables variant support, proper sorting)**

Define custom utilities with `@utility` instead of `@layer utilities`. This enables automatic variant support and proper cascade layer sorting.

**Incorrect (legacy @layer approach):**

```css
@layer utilities {
  .scrollbar-hide {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }
  .scrollbar-hide::-webkit-scrollbar {
    display: none;
  }
}
/* No automatic variant support */
```

**Correct (v4 @utility directive):**

```css
@utility scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
  &::-webkit-scrollbar {
    display: none;
  }
}
/* Automatically works with hover:, focus:, md:, etc. */
```

```html
<div class="scrollbar-hide hover:scrollbar-default">
  <!-- Variants work automatically -->
</div>
```

**Benefits:**
- Automatic variant support (hover, focus, responsive)
- Proper cascade layer ordering
- Smart specificity sorting
- Consistent with built-in utilities

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)

### 2.3 Use CSS-First Configuration Over JavaScript

**Impact: CRITICAL (single source of truth, eliminates config file overhead)**

Tailwind CSS v4 uses the `@theme` directive for configuration instead of JavaScript files. This provides a single source of truth and eliminates the need for context switching.

**Incorrect (JavaScript configuration):**

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          100: "#e6f0ff",
          500: "#0066ff",
          900: "#003380",
        },
      },
      fontFamily: {
        display: ["Satoshi", "sans-serif"],
      },
    },
  },
};
```

**Correct (CSS-first with @theme):**

```css
/* styles.css */
@import "tailwindcss";

@theme {
  --color-brand-100: oklch(0.95 0.02 250);
  --color-brand-500: oklch(0.55 0.21 260);
  --color-brand-900: oklch(0.25 0.15 260);
  --font-display: "Satoshi", "sans-serif";
}
```

**Benefits:**
- All design tokens in one CSS file
- No JavaScript parsing overhead
- CSS variables available at runtime
- Better IDE autocomplete support

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)

### 2.4 Use Dynamic Utility Values

**Impact: HIGH (eliminates arbitrary value syntax, cleaner markup)**

Tailwind CSS v4 supports dynamic values for many utilities without arbitrary value syntax. Grid columns, spacing, and other utilities accept any numeric value.

**Incorrect (arbitrary value syntax):**

```html
<div class="grid grid-cols-[15]">
  <!-- Arbitrary syntax for non-standard column count -->
</div>

<div class="mt-[68px] w-[340px]">
  <!-- Arbitrary pixel values -->
</div>
```

**Correct (dynamic utility values):**

```html
<div class="grid grid-cols-15">
  <!-- Any column count works natively -->
</div>

<div class="mt-17 w-85">
  <!-- Calculated from spacing scale: var(--spacing) * N -->
</div>
```

**How it works:**

```css
/* Generated CSS */
.mt-17 { margin-top: calc(var(--spacing) * 17); }
.w-85 { width: calc(var(--spacing) * 85); }
.grid-cols-15 { grid-template-columns: repeat(15, minmax(0, 1fr)); }
```

**Benefits:**
- Cleaner class names
- Consistent spacing scale
- Better readability
- Fewer arbitrary values in markup

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

### 2.5 Use OKLCH Color Space for Vivid Colors

**Impact: HIGH (20-30% wider color gamut, perceptually uniform)**

Tailwind CSS v4 defaults to OKLCH color space, providing wider P3 gamut colors and perceptually uniform lightness. Use OKLCH syntax for custom colors.

**Incorrect (legacy sRGB hex values):**

```css
@theme {
  --color-accent-500: #7c3aed;
  --color-success-500: #22c55e;
  --color-warning-500: #f59e0b;
}
```

**Correct (OKLCH with wider gamut):**

```css
@theme {
  --color-accent-500: oklch(0.585 0.233 303.9);
  --color-success-500: oklch(0.723 0.191 142.5);
  --color-warning-500: oklch(0.769 0.188 70.08);
}
```

**Benefits:**
- More vivid colors on P3 displays
- Perceptually uniform lightness across hues
- Better gradient interpolation
- Future-proof for HDR displays

**Note:** OKLCH colors gracefully fall back to sRGB on older displays.

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

### 2.6 Use Parentheses for CSS Variable References

**Impact: MEDIUM-HIGH (required v4 syntax, prevents build errors)**

Tailwind CSS v4 changes the syntax for referencing CSS variables in utility classes from square brackets to parentheses.

**Incorrect (v3 square bracket syntax):**

```html
<div class="bg-[--brand-color]">
  <!-- v3 syntax - may not work in v4 -->
</div>

<div class="text-[--heading-size]">
  <!-- Square brackets for CSS variables -->
</div>
```

**Correct (v4 parentheses syntax):**

```html
<div class="bg-(--brand-color)">
  <!-- v4 syntax for CSS variables -->
</div>

<div class="text-(--heading-size)">
  <!-- Parentheses indicate variable reference -->
</div>
```

**Note:** Square brackets are still used for arbitrary static values:

```html
<div class="bg-[#ff5733]"><!-- Static arbitrary value --></div>
<div class="bg-(--custom-color)"><!-- CSS variable reference --></div>
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

---

## 3. Bundle Optimization

**Impact: HIGH**

CSS delivery impacts Core Web Vitals directly. Unused styles, missing compression, and suboptimal code splitting delay LCP and FCP by 100-500ms.

### 3.1 Avoid Play CDN in Production

**Impact: HIGH (10-100× larger payload, runtime compilation overhead)**

The Play CDN is designed for prototyping and learning. It compiles Tailwind in the browser, resulting in significant performance overhead.

**Incorrect (CDN in production):**

```html
<!DOCTYPE html>
<html>
<head>
  <!-- Runtime compilation in browser -->
  <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body>
  <div class="bg-blue-500 p-4">
    <!-- Every page load recompiles styles -->
  </div>
</body>
</html>
```

**Correct (build-time compilation):**

```html
<!DOCTYPE html>
<html>
<head>
  <!-- Pre-compiled, minified CSS -->
  <link href="/dist/styles.css" rel="stylesheet">
</head>
<body>
  <div class="bg-blue-500 p-4">
    <!-- Zero runtime overhead -->
  </div>
</body>
</html>
```

**Play CDN is appropriate for:**
- Quick prototypes and demos
- CodePen/JSFiddle examples
- Learning and experimentation

**Never use CDN for:**
- Production websites
- Performance-critical applications
- SEO-sensitive pages

Reference: [Tailwind CSS Play CDN](https://tailwindcss.com/docs/installation/play-cdn)

### 3.2 Avoid Sass/Less Preprocessors

**Impact: HIGH (prevents compatibility issues, enables native features)**

Tailwind CSS v4 is incompatible with Sass, Less, and Stylus preprocessors. Modern CSS and Tailwind's built-in features replace the need for these tools.

**Incorrect (preprocessor syntax):**

```scss
// styles.scss
@import "tailwindcss"; // May fail with preprocessor

.card {
  @apply bg-white rounded-lg;

  &:hover {
    @apply shadow-lg;
  }

  $padding: 1rem;
  padding: $padding;
}
```

**Correct (native CSS with Tailwind):**

```css
/* styles.css */
@import "tailwindcss";

@utility card {
  @apply bg-white rounded-lg;

  &:hover {
    @apply shadow-lg;
  }

  padding: var(--spacing-4);
}
```

**Native CSS alternatives:**
- CSS nesting (built into v4)
- CSS custom properties (replace Sass variables)
- `@theme` directive (replace Sass maps)
- `calc()` and modern CSS functions

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 3.3 Enable CSS Minification in Production

**Impact: HIGH (40-60% smaller CSS bundles)**

Ensure CSS minification is enabled for production builds. While Tailwind's JIT produces minimal CSS, minification removes whitespace and optimizes output further.

**Incorrect (no minification):**

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
  build: {
    cssMinify: false, // Disabled minification
  },
});
```

**Correct (minification enabled):**

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
  build: {
    cssMinify: "lightningcss", // Fast, modern minifier
  },
});
```

**For CLI builds:**

```bash
# Development (readable output)
npx @tailwindcss/cli -i input.css -o output.css

# Production (minified)
npx @tailwindcss/cli -i input.css -o output.css --minify
```

**Benefits:**
- 40-60% smaller file sizes
- Faster network transfer
- Improved Core Web Vitals

Reference: [Tailwind CSS Installation](https://tailwindcss.com/docs/installation)

### 3.4 Extract Critical CSS for Initial Render

**Impact: MEDIUM-HIGH (100-300ms faster FCP on slow connections)**

For large applications, consider extracting critical CSS for above-the-fold content to improve First Contentful Paint (FCP).

**Incorrect (single large CSS file):**

```html
<head>
  <!-- Blocks rendering until fully loaded -->
  <link href="/styles.css" rel="stylesheet">
</head>
```

**Correct (critical CSS inlined):**

```html
<head>
  <!-- Critical styles inline for immediate render -->
  <style>
    /* Above-the-fold critical styles */
    .flex{display:flex}.justify-between{justify-content:space-between}
    .p-4{padding:1rem}.min-h-screen{min-height:100vh}
    .bg-white{background-color:#fff}.text-gray-900{color:#111827}
  </style>

  <!-- Full stylesheet loads async -->
  <link href="/styles.css" rel="stylesheet" media="print" onload="this.media='all'">
  <noscript><link href="/styles.css" rel="stylesheet"></noscript>
</head>
```

**Framework integration:**

```typescript
// Next.js example with critical CSS extraction
import { getCriticalCss } from "your-critical-css-tool";

export default function Document() {
  return (
    <Html>
      <Head>
        <style dangerouslySetInnerHTML={{ __html: getCriticalCss() }} />
      </Head>
      <body>{/* ... */}</body>
    </Html>
  );
}
```

**When to use:**
- Large CSS bundles (>50KB)
- Slow network connections matter (3G users)
- FCP is a critical metric

Reference: [Web.dev Critical CSS](https://web.dev/extract-critical-css/)

### 3.5 Remove Built-in Plugins

**Impact: HIGH (eliminates duplicate code, reduces dependencies)**

Tailwind CSS v4 includes features that previously required separate plugins. Remove these plugins to avoid duplicate code and reduce bundle size.

**Incorrect (unnecessary plugins):**

```json
{
  "devDependencies": {
    "tailwindcss": "^4.0.0",
    "@tailwindcss/container-queries": "^0.1.0",
    "@tailwindcss/aspect-ratio": "^0.4.0"
  }
}
```

```css
/* Duplicate functionality */
@import "@tailwindcss/container-queries";
```

**Correct (use built-in features):**

```json
{
  "devDependencies": {
    "tailwindcss": "^4.0.0"
  }
}
```

```html
<!-- Container queries are built-in -->
<div class="@container">
  <div class="@sm:grid-cols-3 @lg:grid-cols-4">Content</div>
</div>

<!-- Aspect ratio is built-in -->
<div class="aspect-video">Video</div>
```

**Built-in features in v4:**
- Container queries (`@container`, `@sm:`, `@lg:`)
- Aspect ratio utilities
- Logical properties
- 3D transforms

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

---

## 4. Utility Patterns

**Impact: HIGH**

Choosing correct utilities prevents layout thrashing and repaints. Class ordering, responsive variants, and utility composition affect browser rendering work.

### 4.1 Use Explicit Border and Ring Colors

**Impact: HIGH (prevents invisible borders, ensures consistent appearance)**

Tailwind CSS v4 changes default colors for borders and rings from `gray-200`/`blue-500` to `currentColor`. Always specify colors explicitly.

**Incorrect (relying on v3 defaults):**

```html
<div class="border px-4 py-3">
  <!-- Border may be invisible (currentColor vs gray-200) -->
</div>

<input class="ring" />
<!-- Ring color unpredictable -->
```

**Correct (explicit colors):**

```html
<div class="border border-gray-200 px-4 py-3">
  <!-- Explicit gray border -->
</div>

<input class="ring ring-blue-500" />
<!-- Explicit blue ring -->
```

**v4 default changes:**

| Property | v3 Default | v4 Default |
|----------|------------|------------|
| Border color | `gray-200` | `currentColor` |
| Ring color | `blue-500` | `currentColor` |
| Ring width | `3px` | `1px` |
| Placeholder | `gray-400` | `currentColor` at 50% |

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 4.2 Use Left-to-Right Variant Stacking

**Impact: HIGH (prevents broken responsive/state styles)**

Tailwind CSS v4 changes variant stacking from right-to-left to left-to-right. Update stacked variants to maintain correct behavior.

**Incorrect (v3 right-to-left order):**

```html
<ul class="*:py-2 first:*:pt-0 last:*:pb-0">
  <!-- Child selector applied before first/last -->
</ul>

<div class="group-hover:dark:bg-black">
  <!-- dark applied before group-hover -->
</div>
```

**Correct (v4 left-to-right order):**

```html
<ul class="*:py-2 *:first:pt-0 *:last:pb-0">
  <!-- Child selector first, then first/last -->
</ul>

<div class="dark:group-hover:bg-black">
  <!-- dark first, then group-hover -->
</div>
```

**Reading order:**
- Read variants left-to-right
- Outer context first, inner context last
- Matches natural language order: "in dark mode, on group hover, make background black"

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 4.3 Use Renamed Utility Classes

**Impact: HIGH (prevents broken styles, ensures v4 compatibility)**

Tailwind CSS v4 renames several utility classes to create consistent scaling. Update these classes to prevent broken styles.

**Incorrect (v3 class names):**

```html
<input class="shadow-sm blur-sm rounded-sm ring ring-blue-500" />
<button class="outline-none">Click me</button>
```

**Correct (v4 class names):**

```html
<input class="shadow-xs blur-xs rounded-xs ring-3 ring-blue-500" />
<button class="outline-hidden">Click me</button>
```

**Complete rename mapping:**

| v3 Class | v4 Class | Reason |
|----------|----------|--------|
| `shadow-sm` | `shadow-xs` | Scale consistency |
| `shadow` | `shadow-sm` | Scale consistency |
| `blur-sm` | `blur-xs` | Scale consistency |
| `rounded-sm` | `rounded-xs` | Scale consistency |
| `ring` (3px) | `ring-3` | Explicit width |
| `ring` (1px) | `ring` | New default |
| `outline-none` | `outline-hidden` | Semantic clarity |

**Automated migration:**

```bash
npx @tailwindcss/upgrade
# Automatically renames classes in your templates
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 4.4 Use Slash Opacity Modifier

**Impact: HIGH (50% fewer opacity-related classes)**

Tailwind CSS v4 removes the deprecated opacity utilities (`bg-opacity-*`, `text-opacity-*`). Use the slash syntax for color opacity instead.

**Incorrect (deprecated opacity utilities):**

```html
<div class="bg-blue-500 bg-opacity-50">
  <!-- Deprecated in v4 -->
</div>

<p class="text-black text-opacity-75">
  <!-- Two classes for one effect -->
</p>
```

**Correct (slash opacity modifier):**

```html
<div class="bg-blue-500/50">
  <!-- Single class with opacity -->
</div>

<p class="text-black/75">
  <!-- Cleaner, more readable -->
</p>
```

**With CSS variables:**

```html
<div class="bg-(--brand-color)/50">
  <!-- Works with custom properties too -->
</div>
```

**Benefits:**
- Single class instead of two
- Works with any color utility
- Compatible with CSS variables
- More readable markup

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 4.5 Use Trailing Important Modifier

**Impact: HIGH (prevents v4 syntax errors)**

Tailwind CSS v4 moves the important modifier (`!`) from the beginning to the end of utility classes for better readability.

**Incorrect (v3 leading modifier):**

```html
<div class="!flex !bg-red-500 !p-4">
  <!-- Leading exclamation marks -->
</div>
```

**Correct (v4 trailing modifier):**

```html
<div class="flex! bg-red-500! p-4!">
  <!-- Trailing exclamation marks -->
</div>
```

**Benefits of trailing modifier:**
- Reads left-to-right naturally
- Easier to spot important overrides
- Consistent with other modifier patterns

**With variants:**

```html
<!-- v3 -->
<div class="!hover:bg-blue-500">

<!-- v4 -->
<div class="hover:bg-blue-500!">
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 4.6 Use via-none to Reset Gradient Stops

**Impact: MEDIUM-HIGH (prevents unexpected gradient behavior with variants)**

Tailwind CSS v4 preserves gradient values across variants instead of resetting them. Explicitly use `via-none` to remove a middle stop.

**Incorrect (expecting gradient reset):**

```html
<div class="bg-linear-to-r from-red-500 via-orange-400 to-yellow-400
            dark:from-blue-500 dark:to-teal-400">
  <!-- v3: dark mode resets entire gradient -->
  <!-- v4: dark mode keeps via-orange-400! -->
</div>
```

**Correct (explicit via-none):**

```html
<div class="bg-linear-to-r from-red-500 via-orange-400 to-yellow-400
            dark:via-none dark:from-blue-500 dark:to-teal-400">
  <!-- Explicitly remove via stop in dark mode -->
</div>
```

**How v4 works:**
- Gradient stops are preserved across variants
- Each stop can be individually overridden
- Use `via-none` to convert 3-stop to 2-stop gradient
- More consistent with other utility behaviors

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

---

## 5. Component Architecture

**Impact: MEDIUM-HIGH**

How styles are organized in components affects maintainability and runtime performance. @apply misuse, extraction patterns, and variant usage impact both bundle size and DX.

### 5.1 Avoid Overusing @apply

**Impact: MEDIUM-HIGH (prevents CSS bloat, maintains utility-first benefits)**

While `@apply` extracts utility patterns into custom classes, overuse defeats the purpose of utility-first CSS. Use it sparingly for small, highly reusable patterns.

**Incorrect (over-abstraction):**

```css
/* Recreating traditional CSS with extra steps */
@utility card {
  @apply bg-white rounded-lg shadow-md p-6 border border-gray-200;
}

@utility card-header {
  @apply text-xl font-bold text-gray-900 mb-4;
}

@utility card-body {
  @apply text-gray-600 leading-relaxed;
}

@utility card-footer {
  @apply mt-4 pt-4 border-t border-gray-200 flex justify-end gap-2;
}
/* Now you have to manage class names AND jump between files */
```

**Correct (utility-first with components):**

```tsx
// Card.tsx - Component handles abstraction
function Card({ children, className }) {
  return (
    <div className={`bg-white rounded-lg shadow-md p-6 border border-gray-200 ${className}`}>
      {children}
    </div>
  );
}

// Usage
<Card className="hover:shadow-lg">
  <h2 className="text-xl font-bold text-gray-900 mb-4">Title</h2>
  <p className="text-gray-600 leading-relaxed">Content</p>
</Card>
```

**When @apply is appropriate:**
- Tiny, repeated patterns (buttons, badges)
- Third-party component styling you can't control
- Base form element resets

Reference: [Tailwind CSS Reusing Styles](https://tailwindcss.com/docs/reusing-styles)

### 5.2 Customize Container with @utility

**Impact: MEDIUM (prevents v4 migration breakage)**

Tailwind CSS v4 removes the `container` configuration options (`center`, `padding`). Customize the container utility using `@utility` instead.

**Incorrect (v3 configuration):**

```javascript
// tailwind.config.js - No longer works in v4
module.exports = {
  theme: {
    container: {
      center: true,
      padding: "2rem",
    },
  },
};
```

**Correct (v4 @utility customization):**

```css
@import "tailwindcss";

@utility container {
  margin-inline: auto;
  padding-inline: 2rem;
}
```

**With responsive padding:**

```css
@utility container {
  margin-inline: auto;
  padding-inline: 1rem;

  @media (width >= 640px) {
    padding-inline: 2rem;
  }

  @media (width >= 1024px) {
    padding-inline: 4rem;
  }
}
```

**Benefits:**
- Full CSS control over container behavior
- Responsive customization without config
- Consistent with CSS-first approach

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 5.3 Leverage Smart Utility Sorting

**Impact: MEDIUM (automatic cascade ordering, fewer specificity issues)**

Tailwind CSS v4 automatically sorts utilities by property count, ensuring complex utilities appear earlier in the CSS. This means you can override custom utilities with simple utilities.

**Incorrect (fighting specificity):**

```css
@utility button {
  @apply bg-black text-white px-4 py-2 rounded;
}
```

```html
<!-- Expecting bg-indigo-500 to override, but unsure about specificity -->
<button class="button bg-indigo-500">
  Click me
</button>
```

**Correct (trust smart sorting):**

```css
@utility button {
  @apply bg-black text-white px-4 py-2 rounded;
}
/* button has 5 properties, sorted BEFORE single-property utilities */
```

```html
<!-- bg-indigo-500 (1 property) comes AFTER button (5 properties) -->
<button class="button bg-indigo-500">
  <!-- Works: indigo background overrides black -->
  Click me
</button>
```

**How sorting works:**
1. Multi-property utilities sorted first (e.g., `button`)
2. Single-property utilities sorted after
3. Within same property count, alphabetical
4. Cascade layers handle component vs utility precedence

Reference: [Tailwind CSS Reusing Styles](https://tailwindcss.com/docs/reusing-styles)

### 5.4 Understand Utility File Scope

**Impact: MEDIUM-HIGH (prevents build errors and missing class bugs)**

Custom utilities defined with `@utility` are only available in the file where they're defined. For shared utilities, create a dedicated file and import it.

**Incorrect (expecting global scope):**

```css
/* components/button.css */
@utility btn {
  @apply px-4 py-2 rounded font-medium;
}
```

```css
/* components/card.css */
.card-action {
  @apply btn; /* Error: btn not defined in this file */
}
```

**Correct (shared utilities file):**

```css
/* utilities.css */
@utility btn {
  @apply px-4 py-2 rounded font-medium;
}

@utility card-shadow {
  @apply shadow-md hover:shadow-lg transition-shadow;
}
```

```css
/* components/card.css */
@import "./utilities.css";

.card-action {
  @apply btn; /* Works: imported from utilities.css */
}
```

**Organization pattern:**

```text
styles/
├── main.css          # @import "tailwindcss" + @theme
├── utilities.css     # Shared @utility definitions
└── components/
    ├── button.css    # @import "../utilities.css"
    └── card.css      # @import "../utilities.css"
```

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)

### 5.5 Use @reference for CSS Module Integration

**Impact: MEDIUM-HIGH (eliminates duplicate CSS output in modules)**

When using `@apply` in Vue/Svelte component styles or CSS modules, use `@reference` to import theme variables without duplicating CSS output.

**Incorrect (duplicates styles):**

```vue
<style scoped>
/* Imports entire stylesheet, duplicates in output */
@import "../styles/main.css";

.custom-button {
  @apply bg-brand-500 px-4 py-2 rounded;
}
</style>
```

**Correct (@reference for zero duplication):**

```vue
<style scoped>
/* References variables without emitting styles */
@reference "../styles/main.css";

.custom-button {
  @apply bg-brand-500 px-4 py-2 rounded;
}
</style>
```

**In CSS modules:**

```css
/* button.module.css */
@reference "../../styles/main.css";

.button {
  @apply bg-blue-500 text-white px-4 py-2 rounded;
}

.button:hover {
  @apply bg-blue-600;
}
```

**Benefits:**
- Access to theme variables and utilities
- Zero CSS duplication in output
- Works with scoped styles
- Proper cascade layer integration

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)

---

## 6. Theming & Design Tokens

**Impact: MEDIUM**

@theme directive usage, CSS variable organization, and dark mode implementation affect bundle size, runtime flexibility, and cascade layer efficiency.

### 6.1 Leverage Runtime CSS Variables

**Impact: MEDIUM (enables dynamic theming without JavaScript)**

Tailwind CSS v4 exposes all theme values as CSS variables, enabling runtime customization without rebuilding CSS.

**Incorrect (hardcoded theme values):**

```typescript
// Changing theme requires rebuild
const theme = {
  primary: "#0066ff",
  secondary: "#6b7280",
};

function applyTheme(theme) {
  // Can't change Tailwind classes at runtime
}
```

**Correct (runtime CSS variable override):**

```css
@theme {
  --color-primary: oklch(0.623 0.214 259.1);
  --color-secondary: oklch(0.551 0.027 264.4);
}
```

```typescript
// Change theme at runtime without rebuild
function applyTheme(theme: { primary: string; secondary: string }) {
  document.documentElement.style.setProperty("--color-primary", theme.primary);
  document.documentElement.style.setProperty("--color-secondary", theme.secondary);
}

// Usage
applyTheme({
  primary: "oklch(0.7 0.15 150)",  // Green theme
  secondary: "oklch(0.6 0.1 160)",
});
```

**Use cases:**
- User-customizable themes
- White-label applications
- A/B testing color schemes
- Accessibility contrast modes

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)

### 6.2 Set color-scheme for Native Dark Mode

**Impact: MEDIUM (eliminates visual theme inconsistencies)**

Use the `color-scheme` utility to ensure native browser elements (scrollbars, form controls) match your theme.

**Incorrect (mismatched native elements):**

```html
<html class="dark">
  <body class="bg-gray-900 text-white">
    <!-- Dark background, but scrollbars are still light -->
    <div class="overflow-auto h-screen">
      <!-- Light scrollbar on dark background -->
    </div>
  </body>
</html>
```

**Correct (coordinated color scheme):**

```html
<html class="dark scheme-dark">
  <body class="bg-gray-900 text-white">
    <!-- Scrollbars and native elements are dark -->
    <div class="overflow-auto h-screen">
      <!-- Dark scrollbar matches theme -->
    </div>
  </body>
</html>
```

**Dynamic color scheme:**

```html
<html class="scheme-light dark:scheme-dark">
  <body class="bg-white dark:bg-gray-900">
    <!-- Automatically switches native elements with theme -->
  </body>
</html>
```

**Affected native elements:**
- Scrollbars
- Form inputs (checkboxes, radios)
- `<select>` dropdowns
- `<input type="date">` pickers
- Auto-fill background colors

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

### 6.3 Use Class-Based Dark Mode for Control

**Impact: MEDIUM (enables manual theme switching, better user control)**

By default, Tailwind v4 uses `prefers-color-scheme`. For user-controlled theme switching, configure class-based dark mode.

**Incorrect (only system preference):**

```css
@import "tailwindcss";
/* Default: dark: responds only to OS setting */
```

```html
<!-- No way for users to manually toggle theme -->
<div class="bg-white dark:bg-gray-900">
```

**Correct (class-based control):**

```css
@import "tailwindcss";

@variant dark (&:where(.dark, .dark *));
```

```html
<!-- Toggle theme by adding/removing .dark class -->
<html class="dark">
  <body class="bg-white dark:bg-gray-900">
    <!-- Dark mode active -->
  </body>
</html>
```

**Theme toggle implementation:**

```typescript
function toggleDarkMode() {
  document.documentElement.classList.toggle("dark");
  localStorage.setItem(
    "theme",
    document.documentElement.classList.contains("dark") ? "dark" : "light"
  );
}

// On page load
if (localStorage.theme === "dark" ||
    (!localStorage.theme && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
  document.documentElement.classList.add("dark");
}
```

Reference: [Tailwind CSS Dark Mode](https://tailwindcss.com/docs/dark-mode)

### 6.4 Use Prefix for Variable Namespacing

**Impact: MEDIUM (prevents CSS variable conflicts in large codebases)**

When integrating Tailwind into existing projects or component libraries, use a prefix to prevent CSS variable conflicts.

**Incorrect (potential conflicts):**

```css
@import "tailwindcss";

@theme {
  --color-primary: oklch(0.623 0.214 259.1);
  /* May conflict with existing --color-primary in project */
}
```

**Correct (prefixed variables):**

```css
@import "tailwindcss" prefix(tw);

@theme {
  /* Define without prefix */
  --color-primary: oklch(0.623 0.214 259.1);
  --font-display: "Satoshi", sans-serif;
}
```

```css
/* Generated CSS variables are prefixed */
:root {
  --tw-color-primary: oklch(0.623 0.214 259.1);
  --tw-font-display: "Satoshi", sans-serif;
}
```

```html
<!-- Utility classes are also prefixed -->
<div class="tw:bg-primary tw:font-display">
  Content
</div>
```

**When to use prefixes:**
- Migrating existing projects with CSS variables
- Building embeddable widgets
- Creating component libraries
- Multi-framework applications

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 6.5 Use Semantic Design Token Names

**Impact: MEDIUM (improves maintainability, enables theme switching)**

Name design tokens by their purpose, not their visual appearance. This enables theme switching and makes the design system more maintainable.

**Incorrect (visual naming):**

```css
@theme {
  --color-blue-500: oklch(0.623 0.214 259.1);
  --color-gray-100: oklch(0.967 0 0);
  --color-gray-900: oklch(0.21 0 0);
}
```

```html
<button class="bg-blue-500 text-gray-100">
  <!-- What if brand color changes to green? -->
</button>
```

**Correct (semantic naming):**

```css
@theme {
  /* Semantic tokens reference visual tokens */
  --color-primary: oklch(0.623 0.214 259.1);
  --color-surface: oklch(0.967 0 0);
  --color-text: oklch(0.21 0 0);

  /* Or map directly */
  --color-button-bg: var(--color-primary);
  --color-button-text: oklch(1 0 0);
}
```

```html
<button class="bg-primary text-button-text">
  <!-- Purpose is clear, easy to change -->
</button>
```

**Token hierarchy:**

```css
@theme {
  /* Primitive tokens */
  --color-brand-500: oklch(0.623 0.214 259.1);

  /* Semantic tokens */
  --color-primary: var(--color-brand-500);
  --color-interactive: var(--color-primary);

  /* Component tokens (optional) */
  --color-button-default: var(--color-interactive);
}
```

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)

---

## 7. Responsive & Adaptive

**Impact: MEDIUM**

Breakpoint strategies, container queries, and adaptive patterns impact layout performance and CSS complexity. Mobile-first vs desktop-first affects generated CSS size.

### 7.1 Define Custom Breakpoints in @theme

**Impact: MEDIUM (enables project-specific responsive design)**

Add custom breakpoints using the `@theme` directive. This is useful for project-specific design requirements or adding intermediate breakpoints.

**Incorrect (arbitrary values for breakpoints):**

```html
<div class="hidden min-[900px]:block min-[1400px]:flex">
  <!-- Arbitrary values scattered across codebase -->
</div>
```

**Correct (custom theme breakpoints):**

```css
@import "tailwindcss";

@theme {
  --breakpoint-xs: 480px;
  --breakpoint-3xl: 1920px;
  --breakpoint-4xl: 2560px;
}
```

```html
<div class="hidden xs:block 3xl:flex 4xl:grid">
  <!-- Named breakpoints, consistent usage -->
</div>
```

**Override default breakpoints:**

```css
@theme {
  /* Override existing breakpoints */
  --breakpoint-sm: 600px;  /* Was 640px */
  --breakpoint-lg: 992px;  /* Was 1024px */
}
```

**Benefits:**
- Consistent breakpoint values across codebase
- Self-documenting (named vs arbitrary)
- Easy to update project-wide
- IDE autocomplete support

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)

### 7.2 Understand Hover Behavior on Touch Devices

**Impact: MEDIUM (prevents sticky hover states on mobile)**

Tailwind CSS v4 only applies hover styles on devices that support hover, preventing "sticky" hover states on touch devices.

**Incorrect (expecting hover on all devices):**

```html
<button class="bg-blue-500 hover:bg-blue-600">
  <!-- In v3: hover state could "stick" on touch devices -->
  <!-- In v4: hover only applies on hover-capable devices -->
</button>
```

**Correct (understanding the behavior):**

```html
<!-- v4's default behavior is correct for most cases -->
<button class="bg-blue-500 hover:bg-blue-600">
  <!-- Desktop: hover works as expected -->
  <!-- Touch: no sticky hover state -->
</button>

<!-- For touch-specific feedback, use active: -->
<button class="bg-blue-500 hover:bg-blue-600 active:bg-blue-700">
  <!-- Desktop: hover + active -->
  <!-- Touch: active provides feedback -->
</button>
```

**Generated CSS in v4:**

```css
@media (hover: hover) {
  .hover\:bg-blue-600:hover {
    background-color: var(--color-blue-600);
  }
}
```

**Touch interaction patterns:**

```html
<button class="
  bg-blue-500
  hover:bg-blue-600
  active:bg-blue-700
  focus-visible:ring-2
">
  Touch-friendly button
</button>
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)

### 7.3 Use Container Queries for Component-Level Responsiveness

**Impact: MEDIUM (eliminates viewport-dependent component bugs)**

Use built-in container queries (`@container`, `@sm:`, `@lg:`) for components that should adapt to their container size, not viewport size.

**Incorrect (viewport-based component):**

```html
<aside class="w-full lg:w-80">
  <!-- Card adapts to viewport, not sidebar width -->
  <div class="p-4 lg:p-6">
    <h3 class="text-lg lg:text-xl">Title</h3>
    <p class="text-sm lg:text-base">Description</p>
  </div>
</aside>
```

**Correct (container-based component):**

```html
<aside class="w-full lg:w-80 @container">
  <!-- Card adapts to sidebar width -->
  <div class="p-4 @lg:p-6">
    <h3 class="text-lg @lg:text-xl">Title</h3>
    <p class="text-sm @lg:text-base">Description</p>
  </div>
</aside>
```

**Container query variants:**

```html
<!-- Min-width queries (default) -->
<div class="@sm:flex @lg:grid">

<!-- Max-width queries -->
<div class="@max-md:hidden">

<!-- Range queries -->
<div class="@min-sm:@max-lg:flex">
```

**When to use container queries:**
- Cards in variable-width layouts
- Sidebar components
- Reusable UI components
- Components in grid/flex containers

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

### 7.4 Use Logical Properties for RTL Support

**Impact: MEDIUM (automatic RTL support without duplicate styles)**

Use logical property utilities (`ms-`, `me-`, `ps-`, `pe-`) instead of physical properties (`ml-`, `mr-`, `pl-`, `pr-`) for automatic RTL layout support.

**Incorrect (physical properties):**

```html
<div class="ml-4 mr-8 pl-2 pr-6">
  <!-- Requires separate RTL styles -->
</div>

<div class="text-left">
  <!-- Doesn't flip in RTL -->
</div>
```

**Correct (logical properties):**

```html
<div class="ms-4 me-8 ps-2 pe-6">
  <!-- LTR: margin-left/right, padding-left/right -->
  <!-- RTL: automatically flips to match direction -->
</div>

<div class="text-start">
  <!-- LTR: text-align: left -->
  <!-- RTL: text-align: right -->
</div>
```

**Logical property mapping:**

| Physical | Logical | LTR | RTL |
|----------|---------|-----|-----|
| `ml-*` | `ms-*` | left | right |
| `mr-*` | `me-*` | right | left |
| `pl-*` | `ps-*` | left | right |
| `pr-*` | `pe-*` | right | left |
| `left-*` | `start-*` | left | right |
| `right-*` | `end-*` | right | left |
| `text-left` | `text-start` | left | right |
| `text-right` | `text-end` | right | left |

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

### 7.5 Use Mobile-First Responsive Design

**Impact: MEDIUM (10-30% smaller CSS output)**

Write base styles for mobile, then add complexity with breakpoint prefixes. This produces smaller CSS and follows progressive enhancement principles.

**Incorrect (desktop-first, override down):**

```html
<div class="grid-cols-4 lg:grid-cols-4 md:grid-cols-2 sm:grid-cols-1">
  <!-- Redundant: lg same as base -->
  <!-- More CSS needed to override -->
</div>
```

**Correct (mobile-first, enhance up):**

```html
<div class="grid-cols-1 md:grid-cols-2 lg:grid-cols-4">
  <!-- Base: 1 column (mobile) -->
  <!-- md+: 2 columns (tablet) -->
  <!-- lg+: 4 columns (desktop) -->
</div>
```

**Why mobile-first works better:**
1. Base styles apply to all screen sizes
2. Breakpoints add complexity progressively
3. Smaller CSS output (fewer overrides)
4. Better performance on mobile devices

**Breakpoint reference:**

| Prefix | Min-width | Target |
|--------|-----------|--------|
| (none) | 0px | Mobile |
| `sm:` | 640px | Large phones |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Laptops |
| `xl:` | 1280px | Desktops |
| `2xl:` | 1536px | Large screens |

Reference: [Tailwind CSS Responsive Design](https://tailwindcss.com/docs/responsive-design)

---

## 8. Animation & Transitions

**Impact: LOW-MEDIUM**

GPU-accelerated vs layout-triggering animations, transition utilities, and @starting-style usage affect paint performance and visual smoothness.

### 8.1 Use @starting-style for Entry Animations

**Impact: LOW-MEDIUM (enables CSS-only entry animations, no JavaScript)**

Use the `starting:` variant for CSS-only entry animations on elements that appear dynamically (popovers, dialogs, conditionally rendered elements).

**Incorrect (JavaScript-dependent animation):**

```tsx
function Popover({ isOpen }) {
  return (
    <div
      className={`transition-opacity duration-200 ${
        isOpen ? "opacity-100" : "opacity-0"
      }`}
    >
      {/* Requires JavaScript state management */}
    </div>
  );
}
```

**Correct (CSS-only with @starting-style):**

```html
<button popovertarget="my-popover">Open</button>

<div
  popover
  id="my-popover"
  class="transition-discrete opacity-100 starting:open:opacity-0"
>
  <!-- Animates from 0 to 100% opacity when popover opens -->
  <!-- No JavaScript required -->
</div>
```

**With scale and translate:**

```html
<div
  popover
  id="menu"
  class="
    transition-discrete
    opacity-100 scale-100 translate-y-0
    starting:open:opacity-0
    starting:open:scale-95
    starting:open:translate-y-2
  "
>
  <!-- Fades in, scales up, and slides down -->
</div>
```

**Note:** `transition-discrete` is required for animating `display` property changes.

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

### 8.2 Use Built-in 3D Transform Utilities

**Impact: LOW-MEDIUM (enables 3D effects without custom CSS)**

Tailwind CSS v4 includes native 3D transform utilities. Use them instead of arbitrary values for perspective, 3D rotations, and transform styles.

**Incorrect (arbitrary 3D values):**

```html
<div class="[perspective:1000px]">
  <div class="[transform-style:preserve-3d] [rotate-x:45deg] [rotate-z:30deg]">
    <!-- Arbitrary syntax for 3D transforms -->
  </div>
</div>
```

**Correct (native 3D utilities):**

```html
<div class="perspective-distant">
  <article class="transform-3d rotate-x-45 rotate-z-30">
    <!-- Native 3D transform utilities -->
  </article>
</div>
```

**Available 3D utilities:**

```html
<!-- Perspective on container -->
<div class="perspective-dramatic">  <!-- 100px -->
<div class="perspective-near">      <!-- 300px -->
<div class="perspective-normal">    <!-- 500px -->
<div class="perspective-midrange">  <!-- 800px -->
<div class="perspective-distant">   <!-- 1200px -->

<!-- 3D transform style -->
<div class="transform-3d">          <!-- preserve-3d -->
<div class="transform-flat">        <!-- flat -->

<!-- 3D rotations -->
<div class="rotate-x-45">           <!-- rotateX(45deg) -->
<div class="rotate-y-90">           <!-- rotateY(90deg) -->
<div class="rotate-z-180">          <!-- rotateZ(180deg) -->

<!-- Backface visibility -->
<div class="backface-visible">
<div class="backface-hidden">
```

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

### 8.3 Use GPU-Accelerated Transform Properties

**Impact: LOW-MEDIUM (60fps animations, avoids layout thrashing)**

Animate `transform` and `opacity` properties instead of layout-triggering properties like `width`, `height`, `top`, or `left`. GPU-accelerated properties don't trigger layout recalculation.

**Incorrect (layout-triggering animation):**

```html
<div class="transition-all duration-300 w-20 hover:w-40">
  <!-- Animating width triggers layout on every frame -->
</div>

<div class="absolute top-0 hover:top-10 transition-all">
  <!-- Animating top triggers layout recalculation -->
</div>
```

**Correct (GPU-accelerated animation):**

```html
<div class="transition-transform duration-300 scale-100 hover:scale-x-150">
  <!-- Transform is GPU-accelerated, no layout triggers -->
</div>

<div class="absolute transition-transform hover:translate-y-10">
  <!-- Translate is GPU-accelerated -->
</div>
```

**GPU-accelerated properties:**
- `transform` (translate, rotate, scale, skew)
- `opacity`
- `filter` (blur, brightness, etc.)

**Layout-triggering properties (avoid animating):**
- `width`, `height`
- `top`, `right`, `bottom`, `left`
- `margin`, `padding`
- `font-size`

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

### 8.4 Use OKLCH Gradient Interpolation

**Impact: LOW-MEDIUM (20-40% more vivid gradient midpoints)**

Use the `/oklch` modifier for gradient interpolation to produce more vivid colors and avoid muddy midpoints that occur with sRGB interpolation.

**Incorrect (default sRGB interpolation):**

```html
<div class="bg-linear-to-r from-blue-500 to-green-500">
  <!-- sRGB interpolation produces grayish/muddy midpoint -->
</div>
```

**Correct (OKLCH interpolation):**

```html
<div class="bg-linear-to-r/oklch from-blue-500 to-green-500">
  <!-- OKLCH produces vibrant cyan midpoint -->
</div>
```

**Interpolation comparison:**

```html
<!-- sRGB: Colors can look desaturated in the middle -->
<div class="h-10 bg-linear-to-r/srgb from-red-500 to-blue-500"></div>

<!-- OKLCH: Maintains vibrance throughout -->
<div class="h-10 bg-linear-to-r/oklch from-red-500 to-blue-500"></div>

<!-- Longer hue path for rainbow effect -->
<div class="h-10 bg-linear-to-r/[in_oklch_longer_hue] from-red-500 to-red-500"></div>
```

**When to use OKLCH:**
- Gradients between complementary colors
- Brand gradients requiring specific midpoints
- Any gradient where sRGB looks "muddy"

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)

---

## References

1. [https://tailwindcss.com/docs](https://tailwindcss.com/docs)
2. [https://tailwindcss.com/blog/tailwindcss-v4](https://tailwindcss.com/blog/tailwindcss-v4)
3. [https://tailwindcss.com/docs/upgrade-guide](https://tailwindcss.com/docs/upgrade-guide)
4. [https://tailwindcss.com/docs/functions-and-directives](https://tailwindcss.com/docs/functions-and-directives)
5. [https://tailwindcss.com/docs/theme](https://tailwindcss.com/docs/theme)
6. [https://github.com/tailwindlabs/tailwindcss](https://github.com/tailwindlabs/tailwindcss)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |