# UI/UX Frontend Design

**Version 0.1.0**  
UI/UX Best Practices  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive UI/UX and frontend design best practices guide, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (accessibility compliance, Core Web Vitals) to incremental (animation performance). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated code review and generation.

---

## Table of Contents

1. [Accessibility & WCAG Compliance](#1-accessibility-wcag-compliance) — **CRITICAL**
   - 1.1 [Ensure Full Keyboard Navigation](#11-ensure-full-keyboard-navigation)
   - 1.2 [Ensure Minimum Touch Target Size](#12-ensure-minimum-touch-target-size)
   - 1.3 [Maintain Logical Heading Hierarchy](#13-maintain-logical-heading-hierarchy)
   - 1.4 [Provide Meaningful Alt Text for Images](#14-provide-meaningful-alt-text-for-images)
   - 1.5 [Provide Visible Focus Indicators](#15-provide-visible-focus-indicators)
   - 1.6 [Use ARIA Labels for Icon-Only Controls](#16-use-aria-labels-for-icon-only-controls)
   - 1.7 [Use Semantic HTML Elements](#17-use-semantic-html-elements)
2. [Core Web Vitals Optimization](#2-core-web-vitals-optimization) — **CRITICAL**
   - 2.1 [Improve Interaction to Next Paint](#21-improve-interaction-to-next-paint)
   - 2.2 [Inline Critical CSS and Defer the Rest](#22-inline-critical-css-and-defer-the-rest)
   - 2.3 [Lazy Load Offscreen Images and Iframes](#23-lazy-load-offscreen-images-and-iframes)
   - 2.4 [Minimize Cumulative Layout Shift](#24-minimize-cumulative-layout-shift)
   - 2.5 [Optimize Largest Contentful Paint](#25-optimize-largest-contentful-paint)
   - 2.6 [Serve Responsive Images with srcset](#26-serve-responsive-images-with-srcset)
3. [Visual Hierarchy & Layout](#3-visual-hierarchy-layout) — **HIGH**
   - 3.1 [Design for F-Pattern Reading Behavior](#31-design-for-f-pattern-reading-behavior)
   - 3.2 [Establish Clear Visual Hierarchy](#32-establish-clear-visual-hierarchy)
   - 3.3 [Group Related Elements with Proximity](#33-group-related-elements-with-proximity)
   - 3.4 [Limit to One Primary Call-to-Action Per Screen](#34-limit-to-one-primary-call-to-action-per-screen)
   - 3.5 [Use a Consistent Grid System](#35-use-a-consistent-grid-system)
   - 3.6 [Use Whitespace to Improve Readability](#36-use-whitespace-to-improve-readability)
4. [Responsive & Mobile-First Design](#4-responsive-mobile-first-design) — **HIGH**
   - 4.1 [Configure Viewport Meta Tag Correctly](#41-configure-viewport-meta-tag-correctly)
   - 4.2 [Design Mobile-First with min-width Queries](#42-design-mobile-first-with-min-width-queries)
   - 4.3 [Size Touch Targets for Mobile Interaction](#43-size-touch-targets-for-mobile-interaction)
   - 4.4 [Use Container Queries for Component-Based Layouts](#44-use-container-queries-for-component-based-layouts)
   - 4.5 [Use Fluid Typography with clamp()](#45-use-fluid-typography-with-clamp)
5. [Typography & Font Loading](#5-typography-font-loading) — **MEDIUM-HIGH**
   - 5.1 [Constrain Line Length for Readability](#51-constrain-line-length-for-readability)
   - 5.2 [Preload Critical Web Fonts](#52-preload-critical-web-fonts)
   - 5.3 [Set Appropriate Line Height for Text Blocks](#53-set-appropriate-line-height-for-text-blocks)
   - 5.4 [Use font-display to Control Loading Behavior](#54-use-font-display-to-control-loading-behavior)
   - 5.5 [Use System Font Stack for Performance-Critical Text](#55-use-system-font-stack-for-performance-critical-text)
6. [Color & Contrast](#6-color-contrast) — **MEDIUM**
   - 6.1 [Meet WCAG Contrast Ratio Requirements](#61-meet-wcag-contrast-ratio-requirements)
   - 6.2 [Never Use Color Alone to Convey Information](#62-never-use-color-alone-to-convey-information)
   - 6.3 [Support Dark Mode with Color Scheme](#63-support-dark-mode-with-color-scheme)
   - 6.4 [Use Semantic Color Names in Design Tokens](#64-use-semantic-color-names-in-design-tokens)
7. [Forms & Validation UX](#7-forms-validation-ux) — **MEDIUM**
   - 7.1 [Enable Browser Autocomplete with Correct Attributes](#71-enable-browser-autocomplete-with-correct-attributes)
   - 7.2 [Place Labels Above Input Fields](#72-place-labels-above-input-fields)
   - 7.3 [Use Correct HTML Input Types for Mobile Keyboards](#73-use-correct-html-input-types-for-mobile-keyboards)
   - 7.4 [Use Inline Validation After Field Blur](#74-use-inline-validation-after-field-blur)
   - 7.5 [Write Actionable Error Messages](#75-write-actionable-error-messages)
8. [Animation & Performance](#8-animation-performance) — **LOW-MEDIUM**
   - 8.1 [Animate Only GPU-Accelerated Properties](#81-animate-only-gpu-accelerated-properties)
   - 8.2 [Respect User Motion Preferences](#82-respect-user-motion-preferences)
   - 8.3 [Use Appropriate Animation Duration and Easing](#83-use-appropriate-animation-duration-and-easing)
   - 8.4 [Use will-change Sparingly for Animation Hints](#84-use-will-change-sparingly-for-animation-hints)

---

## 1. Accessibility & WCAG Compliance

**Impact: CRITICAL**

Accessibility failures exclude 15%+ of users and create legal liability. WCAG compliance is non-negotiable for inclusive design.

### 1.1 Ensure Full Keyboard Navigation

**Impact: CRITICAL (enables access for motor-impaired users and power users)**

All interactive elements must be reachable and operable via keyboard. Many users navigate entirely by keyboard due to motor disabilities, visual impairments, or preference.

**Incorrect (keyboard-inaccessible interactions):**

```html
<div class="dropdown" onmouseover="showMenu()">
  <span>Menu</span>
  <div class="menu-items">
    <div onclick="selectItem('option1')">Option 1</div>
    <div onclick="selectItem('option2')">Option 2</div>
  </div>
</div>
<!-- Cannot be reached with Tab key -->
<!-- Cannot be activated with Enter/Space -->
```

**Correct (keyboard-accessible implementation):**

```html
<div class="dropdown">
  <button
    aria-expanded="false"
    aria-haspopup="menu"
    onkeydown="handleKeydown(event)"
  >
    Menu
  </button>
  <ul role="menu">
    <li role="menuitem" tabindex="-1">Option 1</li>
    <li role="menuitem" tabindex="-1">Option 2</li>
  </ul>
</div>
<!-- Tab reaches button, Enter opens menu -->
<!-- Arrow keys navigate options, Escape closes -->
```

**Keyboard requirements:**
- Tab: Move between interactive elements
- Enter/Space: Activate buttons and links
- Arrow keys: Navigate within components (menus, tabs, sliders)
- Escape: Close modals and dropdowns

Reference: [WCAG 2.1 Keyboard Accessible](https://www.w3.org/WAI/WCAG21/Understanding/keyboard.html)

### 1.2 Ensure Minimum Touch Target Size

**Impact: CRITICAL (enables users with motor impairments to tap controls accurately)**

Small tap targets cause frustration and errors for users with motor impairments, tremors, or large fingers. WCAG 2.2 requires minimum 24×24px targets.

**Incorrect (tiny touch targets):**

```css
.icon-button {
  width: 16px;
  height: 16px;
  padding: 0;
}

.nav-link {
  padding: 4px 8px;
  font-size: 12px;
}
/* Touch targets too small for reliable tapping */
/* Users with motor impairments will miss frequently */
```

**Correct (adequately sized touch targets):**

```css
.icon-button {
  min-width: 44px;
  min-height: 44px;
  padding: 12px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.nav-link {
  padding: 12px 16px;
  min-height: 44px;
  display: inline-flex;
  align-items: center;
}
/* 44×44px meets WCAG AAA and iOS/Android guidelines */
```

**Target size requirements:**
- WCAG 2.2 AA: Minimum 24×24 CSS pixels
- WCAG 2.2 AAA: Minimum 44×44 CSS pixels (recommended)
- Spacing: At least 8px between adjacent targets
- Exception: Inline text links can be smaller if paragraph text

Reference: [WCAG 2.2 Target Size](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)

### 1.3 Maintain Logical Heading Hierarchy

**Impact: CRITICAL (enables screen reader users to navigate and understand page structure)**

Screen reader users navigate by jumping between headings. Skipped heading levels break this navigation pattern and make page structure unclear.

**Incorrect (skipped heading levels):**

```html
<h1>Company Website</h1>
<h3>Our Products</h3>  <!-- Skipped h2 -->
<h5>Product Details</h5>  <!-- Skipped h4 -->

<div class="section-title">Services</div>  <!-- Not a heading at all -->
<h2>Contact Us</h2>
<!-- Screen reader users cannot build mental model of page structure -->
```

**Correct (sequential heading hierarchy):**

```html
<h1>Company Website</h1>

<h2>Our Products</h2>
<h3>Enterprise Solutions</h3>
<h4>Product Details</h4>
<h4>Pricing</h4>
<h3>Small Business Tools</h3>

<h2>Services</h2>

<h2>Contact Us</h2>
<!-- Headings descend: h1 → h2 → h3 → h4 -->
<!-- Each section starts at appropriate level -->
```

**Heading rules:**
- One `<h1>` per page (usually the page title)
- Never skip levels (h2 → h4 is invalid)
- Headings should describe the section content
- Style with CSS, not heading level choice

Reference: [WCAG Headings and Labels](https://www.w3.org/WAI/WCAG21/Understanding/headings-and-labels.html)

### 1.4 Provide Meaningful Alt Text for Images

**Impact: CRITICAL (enables blind users to understand image content)**

Alt text describes images for users who cannot see them. Screen readers announce this text, making images accessible to blind and low-vision users.

**Incorrect (missing or unhelpful alt text):**

```html
<!-- Missing alt attribute -->
<img src="hero-banner.jpg">

<!-- Empty alt on informative image -->
<img src="chart-q4-revenue.png" alt="">

<!-- Redundant or vague alt -->
<img src="team-photo.jpg" alt="image">
<img src="ceo-portrait.jpg" alt="photo of person">
<!-- Screen reader: "image" or skips entirely -->
```

**Correct (descriptive, contextual alt text):**

```html
<!-- Informative image with description -->
<img
  src="chart-q4-revenue.png"
  alt="Q4 2024 revenue chart showing 23% growth from $4.2M to $5.2M"
>

<!-- Portrait with name and role -->
<img
  src="ceo-portrait.jpg"
  alt="Sarah Chen, CEO of Acme Corp"
>

<!-- Decorative image with empty alt -->
<img src="decorative-divider.svg" alt="">

<!-- Complex image with extended description -->
<img
  src="architecture-diagram.png"
  alt="System architecture overview"
  aria-describedby="arch-details"
>
<p id="arch-details" class="sr-only">
  The diagram shows three tiers: frontend React app,
  Node.js API layer, and PostgreSQL database...
</p>
```

**Alt text guidelines:**
- Describe the content and function, not appearance
- Use empty `alt=""` for purely decorative images
- Keep under 125 characters for most screen readers
- Avoid "image of" or "picture of" prefixes

Reference: [WebAIM Alt Text](https://webaim.org/techniques/alttext/)

### 1.5 Provide Visible Focus Indicators

**Impact: CRITICAL (enables keyboard users to track position on page)**

Focus indicators show keyboard users which element is currently active. Removing or hiding focus styles makes navigation impossible for keyboard-only users.

**Incorrect (focus outline removed globally):**

```css
/* Reset that breaks accessibility */
*:focus {
  outline: none;
}

button:focus {
  outline: 0;
}
/* Keyboard users cannot see where they are on the page */
```

**Correct (enhanced visible focus styles):**

```css
/* Remove default only when providing custom focus */
button:focus {
  outline: none;
}

button:focus-visible {
  outline: 3px solid #005fcc;
  outline-offset: 2px;
  border-radius: 4px;
}

/* High contrast for dark backgrounds */
.dark-theme button:focus-visible {
  outline-color: #ffdd00;
}
/* Focus ring visible with sufficient contrast (3:1 minimum) */
```

**Focus indicator requirements (WCAG 2.2):**
- Minimum 2px thickness
- 3:1 contrast ratio against adjacent colors
- Encloses or is adjacent to the focused element
- Use `:focus-visible` to show focus only for keyboard navigation

Reference: [WCAG 2.2 Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html)

### 1.6 Use ARIA Labels for Icon-Only Controls

**Impact: CRITICAL (enables screen readers to announce button purpose)**

Buttons and links with only icons have no accessible name. Screen readers announce "button" with no context, leaving users unable to understand the control's purpose.

**Incorrect (icon buttons without accessible names):**

```html
<button class="icon-btn">
  <svg><!-- hamburger menu icon --></svg>
</button>
<!-- Screen reader: "button" -->

<button>
  <i class="fa fa-trash"></i>
</button>
<!-- Screen reader: "button" -->

<a href="/cart">
  <svg><!-- cart icon --></svg>
</a>
<!-- Screen reader: "link" -->
```

**Correct (icon buttons with accessible names):**

```html
<button class="icon-btn" aria-label="Open navigation menu">
  <svg aria-hidden="true"><!-- hamburger menu icon --></svg>
</button>
<!-- Screen reader: "Open navigation menu, button" -->

<button aria-label="Delete item">
  <i class="fa fa-trash" aria-hidden="true"></i>
</button>
<!-- Screen reader: "Delete item, button" -->

<a href="/cart" aria-label="Shopping cart, 3 items">
  <svg aria-hidden="true"><!-- cart icon --></svg>
  <span class="badge">3</span>
</a>
<!-- Screen reader: "Shopping cart, 3 items, link" -->
```

**ARIA labeling rules:**
- Use `aria-label` for concise names
- Use `aria-labelledby` to reference visible text elsewhere
- Add `aria-hidden="true"` to decorative icons
- Update dynamic labels (cart count, notification badges)

Reference: [ARIA Labels and Relationships](https://www.w3.org/WAI/tutorials/forms/labels/)

### 1.7 Use Semantic HTML Elements

**Impact: CRITICAL (enables screen reader navigation and improves SEO)**

Semantic HTML provides meaning to assistive technologies and improves SEO. Screen readers rely on semantic elements to navigate content and announce structure to users.

**Incorrect (div soup with no semantic meaning):**

```html
<div class="header">
  <div class="nav">
    <div class="nav-item" onclick="navigate()">Home</div>
    <div class="nav-item" onclick="navigate()">About</div>
  </div>
</div>
<div class="main">
  <div class="article">
    <div class="title">Welcome</div>
    <div class="content">Article content here...</div>
  </div>
</div>
<!-- Screen readers cannot identify page structure -->
```

**Correct (semantic elements with proper roles):**

```html
<header>
  <nav aria-label="Main navigation">
    <a href="/">Home</a>
    <a href="/about">About</a>
  </nav>
</header>
<main>
  <article>
    <h1>Welcome</h1>
    <p>Article content here...</p>
  </article>
</main>
<!-- Screen readers announce: "navigation landmark", "main landmark", "heading level 1" -->
```

**Key semantic elements:**
- `<header>`, `<footer>`, `<nav>`, `<main>` for page landmarks
- `<article>`, `<section>`, `<aside>` for content grouping
- `<h1>`-`<h6>` for heading hierarchy (never skip levels)

Reference: [MDN Semantics](https://developer.mozilla.org/en-US/docs/Glossary/Semantics)

---

## 2. Core Web Vitals Optimization

**Impact: CRITICAL**

LCP, INP, and CLS directly impact SEO rankings (25-30% weight) and user experience. Only 53% of sites pass all thresholds.

### 2.1 Improve Interaction to Next Paint

**Impact: CRITICAL (INP under 200ms makes UI feel responsive)**

INP measures responsiveness to user interactions. Slow INP (over 200ms) makes buttons feel broken and causes users to click repeatedly. INP replaced FID in March 2024.

**Incorrect (blocking main thread during interaction):**

```javascript
button.addEventListener('click', () => {
  // Synchronous heavy computation blocks UI
  const result = processLargeDataset(items); // 500ms blocking
  renderResults(result);
});
// User sees no response for 500ms after click

dropdown.addEventListener('change', (event) => {
  // DOM thrashing during interaction
  items.forEach(item => {
    item.style.display = shouldShow(item) ? 'block' : 'none';
    item.getBoundingClientRect(); // Forces reflow each iteration
  });
});
// Each dropdown change takes 300ms+
```

**Correct (non-blocking responsive interactions):**

```javascript
button.addEventListener('click', async () => {
  // Show immediate feedback
  button.disabled = true;
  showLoadingSpinner();

  // Defer heavy work
  await scheduler.yield();
  const result = await processLargeDatasetAsync(items);
  renderResults(result);
  button.disabled = false;
});
// User sees spinner within 16ms

dropdown.addEventListener('change', (event) => {
  // Batch DOM updates
  const updates = items.map(item => ({
    element: item,
    display: shouldShow(item) ? 'block' : 'none'
  }));

  requestAnimationFrame(() => {
    updates.forEach(({ element, display }) => {
      element.style.display = display;
    });
  });
});
// Single reflow, completes within 50ms
```

**INP optimization strategies:**
- Show immediate visual feedback on interaction
- Use `requestAnimationFrame` for DOM updates
- Break long tasks with `scheduler.yield()` or `setTimeout`
- Avoid synchronous layout (forced reflows)

Reference: [web.dev INP](https://web.dev/articles/inp)

### 2.2 Inline Critical CSS and Defer the Rest

**Impact: CRITICAL (eliminates render-blocking CSS, 200-500ms faster FCP)**

External stylesheets block rendering until fully downloaded. Inlining critical CSS enables immediate rendering while deferring non-essential styles.

**Incorrect (render-blocking stylesheets):**

```html
<head>
  <!-- All styles block rendering -->
  <link rel="stylesheet" href="framework.css">     <!-- 150KB -->
  <link rel="stylesheet" href="components.css">    <!-- 80KB -->
  <link rel="stylesheet" href="utilities.css">     <!-- 40KB -->
</head>
<!-- Nothing renders until 270KB of CSS downloads and parses -->
```

**Correct (critical CSS inlined, rest deferred):**

```html
<head>
  <!-- Critical above-fold styles inlined -->
  <style>
    /* Header, hero, navigation - ~15KB */
    .header { display: flex; justify-content: space-between; }
    .hero { min-height: 60vh; background: #1a1a2e; }
    .nav-link { color: white; padding: 1rem; }
  </style>

  <!-- Non-critical CSS loaded asynchronously -->
  <link
    rel="preload"
    href="styles.css"
    as="style"
    onload="this.onload=null;this.rel='stylesheet'"
  >
  <noscript><link rel="stylesheet" href="styles.css"></noscript>
</head>
<!-- Page renders immediately with critical styles -->
<!-- Full stylesheet loads without blocking -->
```

**Critical CSS extraction:**
- Include only above-fold styles (header, hero, nav)
- Target 14KB or less (fits in first TCP roundtrip)
- Use tools: Critical, Critters, PurgeCSS
- Generate critical CSS per page template

Reference: [web.dev Extract Critical CSS](https://web.dev/articles/extract-critical-css)

### 2.3 Lazy Load Offscreen Images and Iframes

**Impact: CRITICAL (reduces initial page weight by 30-60%)**

Loading all images upfront wastes bandwidth and delays LCP. Lazy loading defers offscreen resources until the user scrolls near them.

**Incorrect (all images load immediately):**

```html
<!-- All 50 product images load on page load -->
<div class="product-grid">
  <img src="product-1.jpg" alt="Product 1">
  <img src="product-2.jpg" alt="Product 2">
  <!-- ... 48 more images ... -->
  <img src="product-50.jpg" alt="Product 50">
</div>
<!-- 15MB of images downloaded before user can interact -->

<!-- YouTube embed loads 1MB+ immediately -->
<iframe src="https://youtube.com/embed/abc123"></iframe>
```

**Correct (lazy load below-fold content):**

```html
<!-- Above-fold hero loads immediately -->
<img
  src="hero.webp"
  alt="Featured product"
  fetchpriority="high"
>

<!-- Below-fold images lazy load -->
<div class="product-grid">
  <img src="product-1.jpg" alt="Product 1" loading="lazy">
  <img src="product-2.jpg" alt="Product 2" loading="lazy">
  <!-- Browser loads images as user scrolls -->
</div>

<!-- Lazy load iframe with facade -->
<lite-youtube videoid="abc123" playlabel="Play video">
  <button type="button" class="lty-playbtn">
    <span class="visually-hidden">Play video</span>
  </button>
</lite-youtube>
<!-- Loads ~300KB facade instead of 1MB+ YouTube embed -->
```

**Lazy loading guidelines:**
- Never lazy load LCP/above-fold images
- Use native `loading="lazy"` for broad support
- Replace heavy embeds (YouTube, maps) with facades
- Use IntersectionObserver for custom lazy loading

Reference: [web.dev Lazy Loading](https://web.dev/articles/lazy-loading-images)

### 2.4 Minimize Cumulative Layout Shift

**Impact: CRITICAL (CLS under 0.1 prevents frustrating misclicks)**

CLS measures visual stability. Layout shifts cause users to click wrong elements, lose reading position, and perceive poor quality. Target CLS below 0.1.

**Incorrect (elements cause layout shifts):**

```html
<!-- Image without dimensions -->
<img src="product.jpg" alt="Product photo">
<!-- Content below shifts down when image loads -->

<!-- Late-loading ad slot -->
<div class="ad-container"></div>
<!-- Injects 300px tall ad, pushes content down -->

<!-- Font swap shifts text -->
<style>
  body { font-family: 'Custom Font', sans-serif; }
</style>
<!-- Text reflows when custom font loads -->
```

**Correct (stable layout reserved):**

```html
<!-- Explicit dimensions prevent shift -->
<img
  src="product.jpg"
  alt="Product photo"
  width="400"
  height="300"
  style="aspect-ratio: 4/3;"
>

<!-- Reserved space for ad -->
<div class="ad-container" style="min-height: 250px;">
  <!-- Ad loads into reserved space -->
</div>

<!-- Font with fallback metrics -->
<style>
  @font-face {
    font-family: 'Custom Font';
    src: url('custom.woff2') format('woff2');
    font-display: optional;
    size-adjust: 105%;
    ascent-override: 95%;
  }
</style>
<!-- Fallback font metrics match custom font -->
```

**CLS prevention strategies:**
- Always set width/height or aspect-ratio on images
- Reserve space for ads, embeds, and iframes
- Use `font-display: optional` or match fallback metrics
- Avoid inserting content above existing content

Reference: [web.dev CLS](https://web.dev/articles/cls)

### 2.5 Optimize Largest Contentful Paint

**Impact: CRITICAL (LCP under 2.5s improves SEO rankings by 8-15%)**

LCP measures how long the largest visible element takes to render. A slow LCP (over 2.5s) hurts SEO rankings and causes users to perceive the page as slow.

**Incorrect (blocking LCP element):**

```html
<head>
  <!-- Render-blocking CSS -->
  <link rel="stylesheet" href="all-styles.css">
  <!-- Blocking fonts -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto">
</head>
<body>
  <!-- Hero image without optimization -->
  <img src="hero-4k.jpg" alt="Hero banner">
  <!-- LCP element loads after all CSS and fonts -->
</body>
```

**Correct (prioritized LCP element):**

```html
<head>
  <!-- Preload LCP image -->
  <link rel="preload" as="image" href="hero-optimized.webp" fetchpriority="high">
  <!-- Critical CSS inlined -->
  <style>/* Above-fold styles */</style>
  <!-- Non-critical CSS deferred -->
  <link rel="stylesheet" href="styles.css" media="print" onload="this.media='all'">
</head>
<body>
  <!-- Optimized hero with explicit dimensions -->
  <img
    src="hero-optimized.webp"
    alt="Hero banner"
    width="1200"
    height="600"
    fetchpriority="high"
    decoding="async"
  >
  <!-- LCP element loads first, renders within 2.5s -->
</body>
```

**LCP optimization strategies:**
- Preload LCP images with `fetchpriority="high"`
- Use WebP/AVIF formats (30-50% smaller than JPEG)
- Inline critical CSS, defer non-critical styles
- Set explicit width/height to prevent layout shifts

Reference: [web.dev LCP](https://web.dev/articles/lcp)

### 2.6 Serve Responsive Images with srcset

**Impact: CRITICAL (reduces image payload by 40-70% on mobile)**

Serving desktop-sized images to mobile devices wastes bandwidth and slows LCP. Use srcset and sizes to deliver appropriately-sized images for each viewport.

**Incorrect (one size for all devices):**

```html
<!-- 2000px image served to all devices -->
<img src="hero-2000.jpg" alt="Hero image">
<!-- Mobile users download 2MB when 200KB would suffice -->

<div style="background-image: url('banner-4k.jpg')"></div>
<!-- No responsive background image support -->
```

**Correct (responsive images with srcset):**

```html
<img
  src="hero-800.jpg"
  srcset="
    hero-400.jpg 400w,
    hero-800.jpg 800w,
    hero-1200.jpg 1200w,
    hero-2000.jpg 2000w
  "
  sizes="(max-width: 600px) 100vw,
         (max-width: 1200px) 50vw,
         800px"
  alt="Hero image"
  loading="lazy"
>
<!-- Browser selects optimal size based on viewport and DPR -->

<picture>
  <source
    media="(max-width: 600px)"
    srcset="banner-mobile.webp"
    type="image/webp"
  >
  <source
    srcset="banner-desktop.webp"
    type="image/webp"
  >
  <img src="banner-desktop.jpg" alt="Banner">
</picture>
<!-- Different crops for mobile vs desktop -->
```

**Responsive image guidelines:**
- Provide 3-5 image sizes spanning common viewports
- Use `sizes` attribute to hint expected display width
- Include WebP/AVIF sources with fallback
- Use `loading="lazy"` for below-fold images

Reference: [MDN Responsive Images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images)

---

## 3. Visual Hierarchy & Layout

**Impact: HIGH**

Poor hierarchy causes users to miss CTAs and increases cognitive load. Proper structure reduces bounce rates and improves conversions.

### 3.1 Design for F-Pattern Reading Behavior

**Impact: HIGH (increases CTA visibility by 30-50%)**

Users scan web pages in an F-pattern: horizontally across the top, then down the left side. Place important content along this path to maximize visibility.

**Incorrect (important content in blind spots):**

```html
<div class="page-layout">
  <aside class="sidebar-left">
    <nav>Navigation links</nav>
  </aside>
  <main class="content">
    <p>Welcome to our platform for developers...</p>
    <p>Build faster with our tools and templates...</p>
  </main>
  <aside class="sidebar-right">
    <!-- Key CTA buried in right sidebar -->
    <button class="cta-signup">Sign Up Free</button>
    <!-- Important announcement hidden -->
    <div class="announcement">50% off today only!</div>
  </aside>
</div>
<!-- Right sidebar gets least attention in F-pattern -->
```

**Correct (key content on F-pattern hot spots):**

```html
<div class="page-layout">
  <header class="top-bar">
    <!-- Horizontal scan line 1: brand + key action -->
    <h1 class="brand">Company</h1>
    <button class="cta-primary">Sign Up Free</button>
  </header>
  <main class="content">
    <!-- Horizontal scan line 2: value proposition -->
    <h2>Save 50% on Your First Order</h2>
    <!-- Left edge: key navigation and content starts -->
    <section class="features">
      <h3>Why Choose Us</h3>
      <!-- Bullet points along left edge -->
      <ul>
        <li>Fast delivery</li>
        <li>Free returns</li>
      </ul>
    </section>
  </main>
</div>
<!-- CTAs in top-right (first scan), headlines start left -->
```

**F-pattern guidelines:**
- Place logo top-left, primary CTA top-right
- Headlines should start at left margin
- Use left-aligned bullet points for scannable content
- Avoid important content in lower-right areas

Reference: [NNGroup F-Pattern](https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/)

### 3.2 Establish Clear Visual Hierarchy

**Impact: HIGH (improves CTA click-through rates by 20-40%)**

Visual hierarchy guides users through content in order of importance. Without it, users struggle to find key information and miss calls-to-action.

**Incorrect (flat hierarchy, nothing stands out):**

```css
.page-content h1 { font-size: 18px; color: #333; }
.page-content h2 { font-size: 16px; color: #333; }
.page-content p { font-size: 16px; color: #333; }
.page-content .cta-button {
  font-size: 14px;
  background: #eee;
  padding: 8px 12px;
}
/* Everything looks the same weight and importance */
/* User's eye has no focal point */
```

**Correct (clear hierarchy through size, weight, and contrast):**

```css
.page-content h1 {
  font-size: 48px;
  font-weight: 700;
  color: #1a1a2e;
  line-height: 1.1;
}

.page-content h2 {
  font-size: 32px;
  font-weight: 600;
  color: #1a1a2e;
}

.page-content p {
  font-size: 18px;
  font-weight: 400;
  color: #4a4a68;
  line-height: 1.6;
}

.page-content .cta-button {
  font-size: 18px;
  font-weight: 600;
  background: #0066ff;
  color: white;
  padding: 16px 32px;
  border-radius: 8px;
}
/* Clear progression: h1 > h2 > p */
/* CTA stands out with color contrast and size */
```

**Hierarchy tools (in order of impact):**
- Size: Larger elements draw attention first
- Color/Contrast: High contrast creates focal points
- Weight: Bold text stands out from regular
- Whitespace: Isolation increases importance
- Position: Top-left is scanned first (F-pattern)

Reference: [NNGroup Visual Hierarchy](https://www.nngroup.com/articles/visual-hierarchy-ux-definition/)

### 3.3 Group Related Elements with Proximity

**Impact: HIGH (reduces cognitive load, clarifies content relationships)**

Elements close together are perceived as related (Gestalt principle). Use proximity to create logical groups and separate unrelated content.

**Incorrect (equal spacing obscures relationships):**

```css
.form-field { margin-bottom: 24px; }
.form-label { margin-bottom: 24px; }
.form-input { margin-bottom: 24px; }
.form-hint { margin-bottom: 24px; }
/* Label appears equidistant from field above and below */
/* Unclear which label belongs to which input */
```

**Correct (proximity creates clear groupings):**

```css
.form-field {
  margin-bottom: 32px; /* Space between field groups */
}

.form-label {
  margin-bottom: 8px; /* Tight to its input */
}

.form-input {
  margin-bottom: 4px; /* Very tight to hint below */
}

.form-hint {
  margin-bottom: 0; /* Part of this field group */
}

/* Visual result: */
/* [Label]      <- 8px */
/* [Input]      <- 4px */
/* [Hint text]           */
/*              <- 32px  */
/* [Label]               */
/* [Input]               */
```

**Proximity guidelines:**
- 1:3 ratio minimum between intra-group and inter-group spacing
- Labels closer to their fields than to adjacent fields
- Card content padded more from edges than between items
- Related icons/text have minimal gap (4-8px)

Reference: [Laws of UX - Proximity](https://lawsofux.com/law-of-proximity/)

### 3.4 Limit to One Primary Call-to-Action Per Screen

**Impact: HIGH (reduces decision paralysis, improves click-through rates)**

Multiple competing CTAs create decision paralysis. Users who can't decide often do nothing. Make one action visually dominant per screen.

**Incorrect (multiple competing CTAs):**

```html
<section class="hero">
  <h1>Welcome to Our Platform</h1>
  <div class="cta-buttons">
    <button class="btn-primary">Start Free Trial</button>
    <button class="btn-primary">Schedule Demo</button>
    <button class="btn-primary">Contact Sales</button>
    <button class="btn-primary">View Pricing</button>
  </div>
</section>
<!-- Four equal-weight CTAs compete for attention -->
<!-- User doesn't know which to click first -->
```

**Correct (clear primary action with secondary options):**

```html
<section class="hero">
  <h1>Welcome to Our Platform</h1>
  <div class="cta-buttons">
    <button class="btn-primary">Start Free Trial</button>
    <a href="/pricing" class="link-secondary">View Pricing →</a>
  </div>
</section>

<style>
  .btn-primary {
    background: #0066ff;
    color: white;
    padding: 16px 32px;
    font-size: 18px;
    font-weight: 600;
  }

  .link-secondary {
    color: #0066ff;
    font-size: 14px;
    text-decoration: underline;
  }
</style>
<!-- One dominant CTA (filled button) -->
<!-- Secondary option clearly less prominent (text link) -->
```

**CTA hierarchy:**
- Primary: Filled button, high contrast, largest size
- Secondary: Outlined button or text link
- Tertiary: Plain text link, smallest size
- Rule: Only one primary CTA visible at a time

Reference: [Baymard CTA Research](https://baymard.com/blog/primary-secondary-buttons)

### 3.5 Use a Consistent Grid System

**Impact: HIGH (creates visual harmony and faster layout development)**

Grid systems create alignment and consistency across pages. Without a grid, elements feel randomly placed and layouts become difficult to maintain.

**Incorrect (arbitrary positioning and widths):**

```css
.header { padding: 15px 23px; }
.hero-section { max-width: 1150px; margin: 0 auto; }
.feature-card { width: 31.333%; margin-right: 17px; }
.sidebar { width: 287px; }
.footer { padding: 43px 20px; }
/* Arbitrary numbers everywhere */
/* No relationship between element sizes */
```

**Correct (consistent grid-based layout):**

```css
:root {
  --grid-columns: 12;
  --grid-gutter: 24px;
  --container-max: 1200px;
  --spacing-unit: 8px;
}

.container {
  max-width: var(--container-max);
  margin: 0 auto;
  padding: 0 var(--grid-gutter);
}

.grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: var(--grid-gutter);
}

.feature-card {
  grid-column: span 4; /* 4 of 12 columns = 1/3 width */
}

.sidebar {
  grid-column: span 3; /* 3 of 12 columns = 1/4 width */
}

.main-content {
  grid-column: span 9; /* 9 of 12 columns */
}
/* All widths derive from 12-column grid */
/* Gutters and spacing use consistent scale */
```

**Grid system benefits:**
- 12-column grid divides evenly (1, 2, 3, 4, 6, 12)
- Consistent gutters create visual rhythm
- Responsive breakpoints modify column spans
- CSS Grid makes implementation straightforward

Reference: [CSS Tricks Grid Guide](https://css-tricks.com/snippets/css/complete-guide-grid/)

### 3.6 Use Whitespace to Improve Readability

**Impact: HIGH (reduces cognitive load by 20%, improves comprehension)**

Whitespace (negative space) reduces cognitive load and groups related content. Cramped layouts overwhelm users and hide important elements.

**Incorrect (cramped layout with no breathing room):**

```css
.card {
  padding: 8px;
  margin: 4px;
}

.card-title { margin-bottom: 2px; }
.card-description { margin-bottom: 4px; }
.card-actions { margin-top: 4px; }

.section { padding: 10px 0; }
.section-title { margin-bottom: 8px; }
/* Content feels cluttered and hard to scan */
/* No visual separation between elements */
```

**Correct (generous whitespace creates breathing room):**

```css
.card {
  padding: 24px;
  margin: 16px;
}

.card-title {
  margin-bottom: 12px;
}

.card-description {
  margin-bottom: 20px;
  line-height: 1.6;
}

.card-actions {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid #eee;
}

.section {
  padding: 64px 0;
}

.section-title {
  margin-bottom: 32px;
}
/* Content has room to breathe */
/* Related elements grouped, sections clearly separated */
```

**Whitespace principles:**
- Use consistent spacing scale (8px base: 8, 16, 24, 32, 48, 64)
- More whitespace around important elements draws attention
- Group related items with less space; separate sections with more
- Line height 1.5-1.7 for body text readability

Reference: [Smashing Magazine Whitespace](https://www.smashingmagazine.com/2014/05/design-principles-space-figure-ground-relationship/)

---

## 4. Responsive & Mobile-First Design

**Impact: HIGH**

Mobile traffic exceeds 60% globally. Non-responsive designs lose majority of users and fail Google's mobile-first indexing.

### 4.1 Configure Viewport Meta Tag Correctly

**Impact: HIGH (enables proper mobile rendering, prevents zoom issues)**

Without a viewport meta tag, mobile browsers render pages at desktop width (typically 980px) then scale down. This breaks responsive layouts and makes text unreadable.

**Incorrect (missing or misconfigured viewport):**

```html
<!-- Missing viewport tag -->
<head>
  <title>My Website</title>
</head>
<!-- Mobile browser renders at 980px width, then shrinks -->
<!-- Text is tiny, user must pinch-zoom to read -->

<!-- Disabled zoom (accessibility violation) -->
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<!-- Users with low vision cannot zoom to read -->
```

**Correct (proper viewport configuration):**

```html
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Website</title>
</head>
<!-- Viewport matches device width -->
<!-- Initial zoom is 100%, user can still zoom if needed -->
```

**Viewport settings explained:**
- `width=device-width`: Match viewport to device screen width
- `initial-scale=1`: Start at 100% zoom
- Never use `maximum-scale=1` or `user-scalable=no` (blocks accessibility zoom)

**Additional responsive meta tags:**

```html
<!-- Proper color scheme support -->
<meta name="color-scheme" content="light dark">

<!-- iOS web app settings -->
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">

<!-- Theme color for browser chrome -->
<meta name="theme-color" content="#1a1a2e">
```

Reference: [MDN Viewport Meta](https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag)

### 4.2 Design Mobile-First with min-width Queries

**Impact: HIGH (20-30% smaller CSS, supports 60%+ mobile traffic)**

Mobile-first design starts with the smallest viewport and progressively enhances for larger screens. Desktop-first approaches often result in broken or cramped mobile experiences.

**Incorrect (desktop-first with max-width degradation):**

```css
/* Desktop styles first */
.navigation {
  display: flex;
  gap: 32px;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
}

/* Then override everything for mobile */
@media (max-width: 768px) {
  .navigation {
    display: none; /* Just hide it?! */
  }

  .card-grid {
    grid-template-columns: 1fr;
  }
}
/* Mobile is an afterthought, features hidden or broken */
```

**Correct (mobile-first with min-width enhancement):**

```css
/* Mobile styles are the base */
.navigation {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.card-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

/* Enhance for tablet */
@media (min-width: 768px) {
  .navigation {
    flex-direction: row;
    gap: 24px;
  }

  .card-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Enhance for desktop */
@media (min-width: 1024px) {
  .card-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
  }
}
/* Mobile experience is complete, larger screens get enhancements */
```

**Mobile-first benefits:**
- Forces prioritization of essential content
- Smaller base CSS file (add vs. override)
- Better performance on slower mobile connections
- Aligns with Google's mobile-first indexing

Reference: [Google Mobile-First Indexing](https://developers.google.com/search/docs/crawling-indexing/mobile/mobile-sites-mobile-first-indexing)

### 4.3 Size Touch Targets for Mobile Interaction

**Impact: HIGH (reduces tap errors by 50%+, improves mobile usability)**

Desktop hover states and small click targets don't work on touch devices. Mobile interfaces need larger tap targets and adequate spacing to prevent accidental taps.

**Incorrect (desktop-sized targets on mobile):**

```css
.nav-link {
  padding: 4px 8px;
  font-size: 12px;
}

.icon-button {
  width: 24px;
  height: 24px;
}

.action-buttons {
  display: flex;
  gap: 4px;
}
/* 24px targets are nearly impossible to tap accurately */
/* 4px gap means constant accidental taps on wrong button */
```

**Correct (mobile-optimized touch targets):**

```css
.nav-link {
  padding: 12px 16px;
  font-size: 16px;
  min-height: 44px;
  display: inline-flex;
  align-items: center;
}

.icon-button {
  min-width: 44px;
  min-height: 44px;
  padding: 10px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.action-buttons {
  display: flex;
  gap: 12px; /* Enough space to prevent mis-taps */
}
/* 44×44px minimum touch target */
/* 12px gap provides safe spacing between actions */
```

**Touch target guidelines:**
- Minimum 44×44px (Apple HIG) or 48×48px (Material Design)
- Minimum 8px spacing between adjacent targets
- Padding counts toward target size, not just visible element
- Inline text links exempt, but consider touch on mobile

Reference: [Apple HIG Touch Targets](https://developer.apple.com/design/human-interface-guidelines/accessibility#Buttons-and-controls)

### 4.4 Use Container Queries for Component-Based Layouts

**Impact: HIGH (enables truly reusable responsive components)**

Media queries respond to viewport width, not component context. Container queries let components adapt to their container, making them truly reusable in any layout.

**Incorrect (media queries break in different contexts):**

```css
.product-card { display: flex; flex-direction: column; }

@media (min-width: 600px) {
  .product-card { flex-direction: row; }
}
/* Card goes horizontal at 600px viewport */
/* But what if it's in a 300px sidebar? Still horizontal = broken */
```

**Correct (container queries adapt to parent width):**

```css
.card-container {
  container-type: inline-size;
}

.product-card {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

@container (min-width: 400px) {
  .product-card {
    flex-direction: row;
  }

  .product-card .image {
    flex: 0 0 40%;
  }
}

@container (min-width: 600px) {
  .product-card .image {
    flex: 0 0 50%;
  }
}
/* Card responds to its container, not viewport */
/* Works in main content, sidebar, or modal */
```

**Container query use cases:**
- Cards that appear in multiple column layouts
- Navigation that collapses based on available space
- Widgets used in main content and sidebars
- Design system components that must work anywhere

**Browser support:** 90%+ (all modern browsers as of 2024)

Reference: [MDN Container Queries](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment/Container_queries)

### 4.5 Use Fluid Typography with clamp()

**Impact: HIGH (eliminates abrupt font size jumps, reduces CSS)**

Fixed font sizes at breakpoints create abrupt jumps. Fluid typography scales smoothly between minimum and maximum sizes, improving readability at every viewport width.

**Incorrect (stepped font sizes with jarring transitions):**

```css
h1 { font-size: 24px; }

@media (min-width: 768px) {
  h1 { font-size: 36px; } /* Sudden jump at 768px */
}

@media (min-width: 1024px) {
  h1 { font-size: 48px; } /* Another jump at 1024px */
}
/* Text size changes abruptly at breakpoints */
/* Users at 767px and 768px have very different experiences */
```

**Correct (smooth fluid scaling with clamp):**

```css
h1 {
  /* Min 24px, scales with viewport, max 48px */
  font-size: clamp(1.5rem, 4vw + 0.5rem, 3rem);
}

h2 {
  font-size: clamp(1.25rem, 3vw + 0.5rem, 2.25rem);
}

p {
  /* Body text: min 16px, max 20px */
  font-size: clamp(1rem, 1vw + 0.75rem, 1.25rem);
}

/* Spacing can also be fluid */
.section {
  padding: clamp(2rem, 5vw, 6rem);
}
/* Typography scales smoothly across all viewport widths */
/* No jarring size changes at breakpoints */
```

**Fluid typography formula:**
```text
clamp(min, preferred, max)
preferred = [viewport-unit] + [base-rem]
Example: clamp(1rem, 2vw + 0.5rem, 2rem)
```

**Guidelines:**
- Body text: 16px minimum, 20px maximum
- Headings: More aggressive scaling (h1 may double)
- Test at narrow widths to ensure readability

Reference: [CSS Tricks Fluid Type](https://css-tricks.com/simplified-fluid-typography/)

---

## 5. Typography & Font Loading

**Impact: MEDIUM-HIGH**

Font loading directly affects LCP and CLS. Poor typography reduces readability and comprehension by 25%+.

### 5.1 Constrain Line Length for Readability

**Impact: MEDIUM-HIGH (improves reading comprehension by 20%+)**

Lines that are too long or too short reduce reading comprehension. Optimal line length is 45-75 characters for body text. Users lose their place in overly wide text blocks.

**Incorrect (full-width text lines):**

```css
.article-content {
  width: 100%;
  padding: 0 20px;
}
/* On wide screens, lines stretch to 150+ characters */
/* Eye has to travel too far to find next line */
/* Reading comprehension drops significantly */
```

**Correct (constrained line length with ch units):**

```css
.article-content {
  max-width: 65ch; /* ~65 characters per line */
  margin: 0 auto;
  padding: 0 24px;
}

.article-content p {
  font-size: 18px;
  line-height: 1.6;
}

/* For multi-column layouts */
.two-column-layout {
  display: grid;
  grid-template-columns: minmax(auto, 65ch) 300px;
  gap: 48px;
}
/* Main content constrained, sidebar separate */
```

**Line length by context:**
- Body text: 45-75 characters (65ch ideal)
- Headings: Can be wider (up to 85ch)
- Captions/notes: Shorter (35-50ch)
- Mobile: Full width is acceptable at small viewports

**Why `ch` unit:**
- 1ch = width of the "0" character in current font
- Adapts to font-size changes automatically
- More accurate than pixel-based max-width

Reference: [Butterick Typography Line Length](https://practicaltypography.com/line-length.html)

### 5.2 Preload Critical Web Fonts

**Impact: MEDIUM-HIGH (reduces font load time by 100-300ms)**

Fonts are discovered late in the loading waterfall (after CSS parses). Preloading tells the browser to fetch fonts immediately, reducing time to first render.

**Incorrect (fonts discovered late in waterfall):**

```html
<head>
  <link rel="stylesheet" href="styles.css">
  <!-- styles.css contains @font-face rules -->
  <!-- Browser: download CSS → parse → discover font → download font -->
  <!-- Font download starts 200-500ms after CSS -->
</head>
```

**Correct (fonts preloaded immediately):**

```html
<head>
  <!-- Preload critical fonts in <head> -->
  <link
    rel="preload"
    href="/fonts/brand-regular.woff2"
    as="font"
    type="font/woff2"
    crossorigin
  >
  <link
    rel="preload"
    href="/fonts/brand-bold.woff2"
    as="font"
    type="font/woff2"
    crossorigin
  >
  <!-- Font download starts immediately, parallel with CSS -->

  <link rel="stylesheet" href="styles.css">
</head>
```

**Preloading guidelines:**
- Only preload fonts used above-the-fold (1-2 fonts max)
- Always include `crossorigin` (even for same-origin fonts)
- Use WOFF2 format (smallest, best compression)
- Match preload href exactly with @font-face src

**Subsetting for smaller files:**

```bash
# Use glyphanger to subset fonts
glyphanger --whitelist="ABCDEFGHIJKLMNOPQRSTUVWXYZ..." --subset="*.woff2"
# Reduces font file from 50KB to 15KB
```

Reference: [web.dev Preload Fonts](https://web.dev/articles/preload-critical-assets)

### 5.3 Set Appropriate Line Height for Text Blocks

**Impact: MEDIUM-HIGH (improves readability by 25%+, reduces eye strain)**

Tight line spacing makes text hard to read and causes eye strain. Too much spacing breaks visual flow. Optimal line height depends on font size and line length.

**Incorrect (tight or inconsistent line height):**

```css
body {
  line-height: 1; /* Lines touch, hard to track */
}

p { line-height: 18px; } /* Fixed px breaks with font-size changes */

.content {
  line-height: 2.5; /* Too loose, disconnects lines */
}
/* Inconsistent line heights across the page */
```

**Correct (contextual unitless line heights):**

```css
/* Base for body text: 1.5-1.7 */
body {
  font-size: 18px;
  line-height: 1.6; /* Unitless = relative to font-size */
}

/* Tighter for large headings */
h1 {
  font-size: 48px;
  line-height: 1.1; /* Large text needs less leading */
}

h2 {
  font-size: 32px;
  line-height: 1.2;
}

/* Looser for wider measure */
.wide-content {
  max-width: 75ch;
  line-height: 1.7; /* Wider lines need more leading */
}

/* Tighter for UI elements */
.button {
  line-height: 1.2; /* UI text can be tighter */
}
```

**Line height guidelines by context:**
- Body text (40-60ch): 1.5-1.6
- Wide body text (60-80ch): 1.6-1.8
- Large headings (32px+): 1.1-1.2
- Small headings: 1.2-1.3
- UI labels/buttons: 1.1-1.3

Reference: [web.dev Line Height](https://web.dev/articles/font-size#line_height)

### 5.4 Use font-display to Control Loading Behavior

**Impact: MEDIUM-HIGH (eliminates FOIT, reduces CLS from font loading)**

Without `font-display`, browsers may hide text until custom fonts load (FOIT). This creates invisible content and frustrates users. Control this behavior explicitly.

**Incorrect (default browser FOIT behavior):**

```css
@font-face {
  font-family: 'Brand Font';
  src: url('brand-font.woff2') format('woff2');
  /* No font-display specified */
  /* Safari hides text indefinitely until font loads */
  /* Chrome/Firefox hide for 3s, then show fallback */
}
/* Users see blank space where text should be */
```

**Correct (explicit font-display strategy):**

```css
/* Option 1: swap - always show text, swap when ready */
@font-face {
  font-family: 'Brand Font';
  src: url('brand-font.woff2') format('woff2');
  font-display: swap;
}
/* Text visible immediately with fallback */
/* Swaps to custom font when loaded (may cause reflow) */

/* Option 2: optional - no swap if not cached */
@font-face {
  font-family: 'Brand Font';
  src: url('brand-font.woff2') format('woff2');
  font-display: optional;
}
/* Text visible immediately */
/* Custom font only used if already cached (no CLS) */

/* Option 3: fallback - short block, then fallback */
@font-face {
  font-family: 'Brand Font';
  src: url('brand-font.woff2') format('woff2');
  font-display: fallback;
}
/* 100ms block period, then fallback */
/* Swap window of ~3s before giving up */
```

**font-display values:**
- `swap`: Show fallback immediately, always swap (may cause CLS)
- `optional`: No CLS, but font may not appear on first visit
- `fallback`: Brief block, then swap window (balanced)

Reference: [web.dev font-display](https://web.dev/articles/font-display)

### 5.5 Use System Font Stack for Performance-Critical Text

**Impact: MEDIUM-HIGH (0ms font load time, eliminates FOUT/FOIT)**

System fonts are already installed on user devices. They render instantly with no download, no FOUT, and no CLS. Use them for UI elements where custom branding is less important than speed.

**Incorrect (custom fonts for everything):**

```css
body {
  font-family: 'Custom Sans', sans-serif;
}

.navigation { font-family: 'Custom Sans', sans-serif; }
.button { font-family: 'Custom Sans', sans-serif; }
.form-label { font-family: 'Custom Sans', sans-serif; }
/* Every element waits for 50KB+ font download */
/* UI feels slow until fonts load */
```

**Correct (system fonts for UI, custom for branding):**

```css
/* System font stack for UI elements */
:root {
  --font-system: -apple-system, BlinkMacSystemFont, 'Segoe UI',
    Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans',
    'Helvetica Neue', sans-serif;

  --font-brand: 'Brand Font', var(--font-system);
}

/* System fonts for instant UI rendering */
body { font-family: var(--font-system); }
.navigation { font-family: var(--font-system); }
.button { font-family: var(--font-system); }
.form-label { font-family: var(--font-system); }

/* Custom font only for brand-critical elements */
h1, h2, .hero-title { font-family: var(--font-brand); }
.logo { font-family: var(--font-brand); }
/* UI renders instantly, headings get branding */
```

**System font stack order:**
1. `-apple-system` (iOS/macOS San Francisco)
2. `BlinkMacSystemFont` (macOS Chrome)
3. `Segoe UI` (Windows)
4. `Roboto` (Android)
5. Generic `sans-serif` fallback

Reference: [CSS Tricks System Font Stack](https://css-tricks.com/snippets/css/system-font-stack/)

---

## 6. Color & Contrast

**Impact: MEDIUM**

Insufficient contrast fails WCAG AA (4.5:1 ratio) and excludes users with visual impairments. Color alone must not convey meaning.

### 6.1 Meet WCAG Contrast Ratio Requirements

**Impact: MEDIUM (makes text readable for 8%+ of users with visual impairments)**

Low contrast text is unreadable for users with visual impairments and difficult for everyone in bright environments. WCAG requires minimum contrast ratios for accessibility compliance.

**Incorrect (insufficient contrast ratios):**

```css
/* Light gray on white: 2.5:1 ratio - FAILS */
.subtle-text {
  color: #999999;
  background: #ffffff;
}

/* Orange on white: 2.9:1 ratio - FAILS for small text */
.warning-text {
  color: #ff9900;
  background: #ffffff;
}

/* White on light blue: 3.8:1 ratio - FAILS AA */
.hero-title {
  color: #ffffff;
  background: #5fa8d3;
}
/* Users in sunlight or with low vision cannot read */
```

**Correct (WCAG compliant contrast):**

```css
/* Dark gray on white: 7:1 ratio - PASSES AAA */
.body-text {
  color: #4a4a4a;
  background: #ffffff;
}

/* Darker orange on white: 4.6:1 ratio - PASSES AA */
.warning-text {
  color: #b35900;
  background: #ffffff;
}

/* White on dark blue: 8.5:1 ratio - PASSES AAA */
.hero-title {
  color: #ffffff;
  background: #1a365d;
}
/* Readable in all lighting conditions */
```

**WCAG contrast requirements:**
| Element | AA Level | AAA Level |
|---------|----------|-----------|
| Normal text (<18px) | 4.5:1 | 7:1 |
| Large text (≥18px bold, ≥24px) | 3:1 | 4.5:1 |
| UI components & graphics | 3:1 | Not defined |

**Testing tools:** WebAIM Contrast Checker, Chrome DevTools, Stark

Reference: [WCAG Contrast Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

### 6.2 Never Use Color Alone to Convey Information

**Impact: MEDIUM (enables 8% of men with color blindness to understand content)**

Approximately 8% of men and 0.5% of women have color vision deficiency. Using only color to indicate status, errors, or required fields excludes these users from understanding the interface.

**Incorrect (color as only indicator):**

```html
<style>
  .required-field { border-color: red; }
  .success-message { color: green; }
  .error-message { color: red; }
</style>

<form>
  <input class="required-field" name="email">
  <span class="error-message">Invalid email</span>
</form>

<div class="chart-legend">
  <span style="color: green;">Sales</span>
  <span style="color: red;">Returns</span>
</div>
<!-- Color-blind users cannot distinguish green from red -->
```

**Correct (color plus additional indicators):**

```html
<style>
  .required-field {
    border-color: #d32f2f;
    border-width: 2px;
  }
  .required-field::after {
    content: "*";
  }

  .success-message {
    color: #2e7d32;
  }
  .success-message::before {
    content: "✓ ";
  }

  .error-message {
    color: #d32f2f;
  }
  .error-message::before {
    content: "⚠ ";
  }
</style>

<form>
  <label>Email <span class="required-asterisk">*</span></label>
  <input class="required-field" name="email" aria-required="true">
  <span class="error-message">⚠ Invalid email format</span>
</form>

<div class="chart-legend">
  <span><span class="icon-circle-fill"></span> Sales</span>
  <span><span class="icon-circle-outline"></span> Returns</span>
</div>
<!-- Color + icon/text provides redundant information -->
```

**Redundant indicators:**
- Icons (✓, ⚠, ✗) alongside colored text
- Patterns or shapes in charts/graphs
- Text labels ("Required", "Error", "Success")
- Underlines, borders, or other visual treatments

Reference: [WCAG Use of Color](https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html)

### 6.3 Support Dark Mode with Color Scheme

**Impact: MEDIUM (reduces eye strain and battery usage for 80%+ of users)**

Over 80% of users prefer dark mode, especially at night. Proper dark mode implementation reduces eye strain and saves battery on OLED screens. Use CSS custom properties for maintainable theming.

**Incorrect (hardcoded colors, no dark mode):**

```css
body {
  background: #ffffff;
  color: #333333;
}

.card {
  background: #f5f5f5;
  border: 1px solid #e0e0e0;
}

.button {
  background: #0066ff;
  color: #ffffff;
}
/* No dark mode support */
/* Users in dark environments experience eye strain */
```

**Correct (CSS custom properties with dark mode):**

```css
:root {
  --color-bg-primary: #ffffff;
  --color-bg-secondary: #f5f5f5;
  --color-text-primary: #1a1a2e;
  --color-text-secondary: #4a4a68;
  --color-border: #e0e0e0;
  --color-accent: #0066ff;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-bg-primary: #1a1a2e;
    --color-bg-secondary: #2d2d44;
    --color-text-primary: #ffffff;
    --color-text-secondary: #a0a0b8;
    --color-border: #3d3d5c;
    --color-accent: #4d94ff;
  }
}

body {
  background: var(--color-bg-primary);
  color: var(--color-text-primary);
}

.card {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
}
/* Automatically responds to system preference */
```

**Dark mode considerations:**
- Avoid pure black (#000); use dark gray (#1a1a2e)
- Reduce contrast slightly (white text on black is harsh)
- Desaturate bright colors to avoid vibration
- Test that contrast ratios still meet WCAG in dark mode

Reference: [web.dev Dark Mode](https://web.dev/articles/prefers-color-scheme)

### 6.4 Use Semantic Color Names in Design Tokens

**Impact: MEDIUM (enables consistent theming and easier maintenance)**

Hardcoded color values scattered through CSS are impossible to maintain and theme. Semantic color tokens describe purpose, not appearance, enabling consistent updates and dark mode support.

**Incorrect (literal color names and raw values):**

```css
.header { background: #1a365d; }
.error { color: #dc2626; }
.success { color: #16a34a; }
.button { background: blue; }
.sidebar { background: #f3f4f6; }

/* Renaming "blue" requires find-replace across codebase */
/* No clear relationship between colors */
```

**Correct (semantic design tokens):**

```css
:root {
  /* Primitive tokens (raw values) */
  --blue-600: #2563eb;
  --blue-700: #1d4ed8;
  --red-600: #dc2626;
  --green-600: #16a34a;
  --gray-100: #f3f4f6;
  --gray-900: #111827;

  /* Semantic tokens (purpose-based) */
  --color-bg-primary: var(--gray-100);
  --color-bg-inverse: var(--gray-900);
  --color-text-primary: var(--gray-900);
  --color-text-inverse: white;

  --color-interactive: var(--blue-600);
  --color-interactive-hover: var(--blue-700);

  --color-feedback-error: var(--red-600);
  --color-feedback-success: var(--green-600);
}

.header { background: var(--color-bg-inverse); }
.error { color: var(--color-feedback-error); }
.success { color: var(--color-feedback-success); }
.button { background: var(--color-interactive); }
.button:hover { background: var(--color-interactive-hover); }
.sidebar { background: var(--color-bg-primary); }
/* Change brand color in one place, updates everywhere */
```

**Token naming hierarchy:**
1. Primitive: `--blue-600` (raw values)
2. Semantic: `--color-interactive` (purpose)
3. Component: `--button-bg` (optional, specific)

Reference: [Design Tokens Community Group](https://www.w3.org/community/design-tokens/)

---

## 7. Forms & Validation UX

**Impact: MEDIUM**

Form abandonment averages 67%. Proper validation timing, clear errors, and helpful inputs directly impact conversion rates.

### 7.1 Enable Browser Autocomplete with Correct Attributes

**Impact: MEDIUM (reduces form filling time by 30%+)**

Browser autofill saves users significant typing time. Using correct `autocomplete` attributes helps browsers fill forms accurately. Disabling autocomplete frustrates users.

**Incorrect (autocomplete disabled or missing):**

```html
<!-- Explicitly disabled (frustrating) -->
<input type="email" autocomplete="off" name="email">

<!-- No autocomplete attribute (browser guesses wrong) -->
<input type="text" name="field1" placeholder="First name">
<input type="text" name="field2" placeholder="Last name">
<!-- Browser may fill "field1" with wrong data -->

<!-- Wrong autocomplete values -->
<input type="text" autocomplete="name" name="address">
```

**Correct (proper autocomplete attributes):**

```html
<!-- Personal information -->
<input type="text" name="firstName" autocomplete="given-name">
<input type="text" name="lastName" autocomplete="family-name">
<input type="email" name="email" autocomplete="email">
<input type="tel" name="phone" autocomplete="tel">

<!-- Address fields -->
<input type="text" name="address" autocomplete="street-address">
<input type="text" name="city" autocomplete="address-level2">
<input type="text" name="state" autocomplete="address-level1">
<input type="text" name="zip" autocomplete="postal-code">
<select name="country" autocomplete="country">

<!-- Payment (for payment forms) -->
<input type="text" name="cardNumber" autocomplete="cc-number">
<input type="text" name="cardName" autocomplete="cc-name">
<input type="text" name="expiry" autocomplete="cc-exp">

<!-- Login forms -->
<input type="text" name="username" autocomplete="username">
<input type="password" name="password" autocomplete="current-password">

<!-- New password (signup/change) -->
<input type="password" name="newPassword" autocomplete="new-password">
```

**Common autocomplete values:**
- Names: `given-name`, `family-name`, `name`
- Contact: `email`, `tel`, `url`
- Address: `street-address`, `postal-code`, `country`
- Payment: `cc-number`, `cc-name`, `cc-exp`

Reference: [HTML autocomplete attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete)

### 7.2 Place Labels Above Input Fields

**Impact: MEDIUM (improves form completion speed by 15%)**

Labels placed above inputs create a clear visual path and work better on mobile. Left-aligned labels require horizontal eye movement and break at narrow widths.

**Incorrect (labels beside inputs):**

```html
<div class="form-row">
  <label>Email Address</label>
  <input type="email">
</div>

<style>
.form-row {
  display: flex;
  align-items: center;
}
.form-row label {
  width: 150px;
  text-align: right;
  padding-right: 12px;
}
</style>
<!-- Eye must zigzag horizontally -->
<!-- Breaks on mobile (labels get cut off or wrap awkwardly) -->
```

**Correct (labels above inputs):**

```html
<div class="form-field">
  <label for="email">Email Address</label>
  <input type="email" id="email" name="email">
</div>

<style>
.form-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 24px;
}

.form-field label {
  font-weight: 500;
  font-size: 14px;
  color: var(--color-text-secondary);
}

.form-field input {
  padding: 12px;
  font-size: 16px;
  border: 1px solid var(--color-border);
  border-radius: 4px;
}
</style>
<!-- Eye flows straight down -->
<!-- Works at any viewport width -->
```

**Label placement rules:**
- Top-aligned labels: Best for most forms (faster completion)
- Inline labels (in field): Only for single fields (search bars)
- Left-aligned labels: Only when vertical space is critical
- Always use `for` attribute linking label to input `id`

Reference: [UX Movement Label Placement](https://uxmovement.com/forms/why-infield-top-aligned-form-labels-are-quickest-to-scan/)

### 7.3 Use Correct HTML Input Types for Mobile Keyboards

**Impact: MEDIUM (reduces typing effort by showing appropriate keyboard)**

Using `type="text"` for all inputs forces mobile users to switch keyboards manually. Proper input types trigger optimized keyboards with relevant keys.

**Incorrect (generic text input for everything):**

```html
<input type="text" name="email" placeholder="Email">
<!-- Shows full QWERTY, user must find @ symbol -->

<input type="text" name="phone" placeholder="Phone">
<!-- Shows full QWERTY, user must switch to number keyboard -->

<input type="text" name="search" placeholder="Search...">
<!-- No "Search" or "Go" button on mobile keyboard -->

<input type="text" name="url" placeholder="Website URL">
<!-- No ".com" shortcut or "/" key prominent -->
```

**Correct (semantic input types):**

```html
<!-- Email: shows @ and .com on keyboard -->
<input type="email" name="email" placeholder="Email" autocomplete="email">

<!-- Phone: shows numeric keypad -->
<input type="tel" name="phone" placeholder="Phone" autocomplete="tel">

<!-- Search: shows Search/Go button instead of Enter -->
<input type="search" name="query" placeholder="Search...">

<!-- URL: shows "/" and ".com" shortcuts -->
<input type="url" name="website" placeholder="Website URL" autocomplete="url">

<!-- Number: shows numeric keypad -->
<input
  type="text"
  inputmode="numeric"
  pattern="[0-9]*"
  name="zipcode"
  placeholder="ZIP Code"
>
```

**Input types and their keyboards:**
| Type | Keyboard shows |
|------|----------------|
| `email` | @ symbol prominent |
| `tel` | Number pad |
| `url` | .com, / shortcuts |
| `search` | Search button |
| `number` | Number pad with +/- |
| `inputmode="numeric"` | Number pad only |

Reference: [web.dev Input Types](https://web.dev/articles/payment-and-address-form-best-practices#input_types)

### 7.4 Use Inline Validation After Field Blur

**Impact: MEDIUM (reduces form abandonment by 22%)**

Validating only on submit forces users to scroll back and fix errors. Inline validation (after field blur, not during typing) gives immediate feedback while respecting the user's flow.

**Incorrect (validation only on submit or during typing):**

```javascript
// Only validates on form submit
form.addEventListener('submit', (event) => {
  const errors = validateAllFields();
  if (errors.length) {
    event.preventDefault();
    showErrorSummary(errors); // User must scroll to find errors
  }
});

// Validates on every keystroke (annoying)
emailInput.addEventListener('input', () => {
  if (!isValidEmail(emailInput.value)) {
    showError('Invalid email'); // Error shows while still typing
  }
});
```

**Correct (inline validation on blur, removal on input):**

```javascript
// Validate when user leaves field
emailInput.addEventListener('blur', () => {
  if (!emailInput.value) return; // Don't validate empty on blur

  if (!isValidEmail(emailInput.value)) {
    showFieldError(emailInput, 'Enter a valid email address');
  }
});

// Clear error when user starts correcting
emailInput.addEventListener('input', () => {
  if (hasError(emailInput) && isValidEmail(emailInput.value)) {
    clearFieldError(emailInput);
  }
});

// Still validate all on submit as backup
form.addEventListener('submit', (event) => {
  const errors = validateAllFields();
  if (errors.length) {
    event.preventDefault();
    focusFirstError();
  }
});
```

**Validation timing rules:**
- Required fields: Validate on blur AND on submit
- Format validation: Validate on blur, clear on valid input
- Never validate empty required fields on blur (wait for submit)
- Never show errors while user is actively typing

Reference: [Baymard Inline Validation](https://baymard.com/blog/inline-form-validation)

### 7.5 Write Actionable Error Messages

**Impact: MEDIUM (reduces user confusion and support requests by 30%)**

Generic error messages like "Invalid input" don't help users fix problems. Effective error messages explain what's wrong and how to fix it.

**Incorrect (vague, unhelpful error messages):**

```html
<div class="error">Invalid input</div>
<div class="error">Error</div>
<div class="error">Please enter a valid value</div>
<div class="error">This field is required</div>
<!-- User doesn't know what's wrong or how to fix it -->
```

**Correct (specific, actionable error messages):**

```html
<!-- Explain format requirements -->
<div class="error">
  Enter your email address (example: name@company.com)
</div>

<!-- Explain constraints -->
<div class="error">
  Password must be at least 8 characters with one number
</div>

<!-- Explain what happened -->
<div class="error">
  This email is already registered. <a href="/login">Log in</a> or use a different email.
</div>

<!-- Explain required context -->
<div class="error">
  Enter your phone number so we can send delivery updates
</div>
```

**Error message guidelines:**
- State what's wrong specifically
- Explain how to fix it
- Use positive language ("Enter..." not "You must...")
- Keep it brief but complete
- Position error adjacent to the field
- Use appropriate tone (helpful, not blaming)

**Error message anatomy:**
```text
[What's wrong] + [How to fix it]
"Password too short" + "Use at least 8 characters"
= "Password must be at least 8 characters"
```

Reference: [NNGroup Error Message Guidelines](https://www.nngroup.com/articles/errors-forms-design-guidelines/)

---

## 8. Animation & Performance

**Impact: LOW-MEDIUM**

Poorly optimized animations cause jank below 60fps, trigger expensive reflows, and drain battery on mobile devices.

### 8.1 Animate Only GPU-Accelerated Properties

**Impact: LOW-MEDIUM (maintains 60fps, eliminates jank on complex animations)**

Animating layout properties like `width`, `height`, or `top` triggers expensive reflows. GPU-accelerated properties (`transform`, `opacity`) animate on a separate compositor layer without affecting layout.

**Incorrect (animating layout-triggering properties):**

```css
.sidebar {
  transition: width 0.3s ease;
}
.sidebar.collapsed {
  width: 60px; /* Triggers layout recalculation */
}

.modal {
  transition: top 0.3s ease;
}
.modal.open {
  top: 50%; /* Triggers reflow on every frame */
}

.card:hover {
  margin-top: -10px; /* Shifts all siblings, expensive */
}
/* Each frame: layout → paint → composite */
/* Results in dropped frames and jank */
```

**Correct (GPU-accelerated transforms):**

```css
.sidebar {
  transition: transform 0.3s ease;
  will-change: transform;
}
.sidebar.collapsed {
  transform: translateX(-200px); /* GPU compositor handles this */
}

.modal {
  transition: transform 0.3s ease, opacity 0.3s ease;
}
.modal.open {
  transform: translate(-50%, -50%); /* No layout recalculation */
  opacity: 1;
}

.card {
  transition: transform 0.2s ease;
}
.card:hover {
  transform: translateY(-10px); /* Only this element moves */
}
/* Each frame: composite only */
/* Smooth 60fps animation */
```

**GPU-accelerated properties:**
- `transform` (translate, scale, rotate, skew)
- `opacity`
- `filter` (blur, brightness, etc.)

**Properties that trigger layout (avoid animating):**
- `width`, `height`, `padding`, `margin`
- `top`, `right`, `bottom`, `left`
- `font-size`, `line-height`

Reference: [CSS Triggers](https://csstriggers.com/)

### 8.2 Respect User Motion Preferences

**Impact: LOW-MEDIUM (prevents motion sickness for 35% of users affected by vestibular disorders)**

Animations can trigger motion sickness, migraines, and seizures in users with vestibular disorders. The `prefers-reduced-motion` media query lets you provide a reduced-motion experience.

**Incorrect (ignoring motion preferences):**

```css
.hero {
  animation: parallax-float 10s infinite;
}

.page-transition {
  animation: slide-in 0.5s ease-out;
}

.notification {
  animation: shake 0.3s ease-in-out;
}
/* Users with motion sensitivity have no way to opt out */
/* Can cause nausea, dizziness, or seizures */
```

**Correct (respecting reduced-motion preference):**

```css
/* Default animations for users who haven't opted out */
.hero {
  animation: parallax-float 10s infinite;
}

.page-transition {
  animation: slide-in 0.5s ease-out;
}

/* Disable or simplify for users who prefer reduced motion */
@media (prefers-reduced-motion: reduce) {
  .hero {
    animation: none;
  }

  .page-transition {
    animation: fade-in 0.2s ease-out; /* Simple opacity fade instead */
  }

  /* Disable all decorative animations globally */
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Alternative: Start with no motion, opt-in */
@media (prefers-reduced-motion: no-preference) {
  .hero {
    animation: parallax-float 10s infinite;
  }
}
```

**Motion that should be reduced/removed:**
- Parallax scrolling effects
- Auto-playing carousels and sliders
- Decorative floating/pulsing elements
- Complex page transitions
- Background video

**Motion that can remain:**
- Essential state change indicators
- Loading spinners (simplified)
- Simple opacity fades

Reference: [web.dev prefers-reduced-motion](https://web.dev/articles/prefers-reduced-motion)

### 8.3 Use Appropriate Animation Duration and Easing

**Impact: LOW-MEDIUM (100-400ms optimal ranges reduce perceived latency)**

Too-slow animations feel laggy; too-fast ones feel jarring. Proper duration and easing curves make interfaces feel responsive and natural.

**Incorrect (wrong durations and linear easing):**

```css
/* Too slow for microinteraction */
.button:hover {
  transition: background-color 1s linear;
}
/* Feels sluggish, user waits for response */

/* Too fast for modal */
.modal {
  transition: opacity 50ms linear;
}
/* Feels abrupt, jarring */

/* Linear easing on movement */
.dropdown {
  transition: transform 0.3s linear;
}
/* Feels mechanical, robotic */
```

**Correct (appropriate durations with natural easing):**

```css
/* Microinteractions: 100-200ms */
.button {
  transition: background-color 150ms ease-out;
}

.checkbox {
  transition: transform 100ms ease-out;
}

/* Expand/collapse: 200-300ms */
.dropdown {
  transition: transform 250ms cubic-bezier(0.4, 0, 0.2, 1);
}

/* Modal/overlay: 200-400ms */
.modal {
  transition: opacity 200ms ease-out,
              transform 300ms cubic-bezier(0.32, 0.72, 0, 1);
}

/* Page transitions: 300-500ms */
.page-transition {
  transition: transform 400ms cubic-bezier(0.4, 0, 0.2, 1);
}
```

**Duration guidelines by action type:**
| Action | Duration |
|--------|----------|
| Hover/focus states | 100-150ms |
| Button feedback | 100-200ms |
| Dropdowns/accordions | 200-300ms |
| Modals/dialogs | 200-400ms |
| Page transitions | 300-500ms |

**Common easing curves:**
- `ease-out`: Fast start, slow end (entering)
- `ease-in`: Slow start, fast end (exiting)
- `cubic-bezier(0.4, 0, 0.2, 1)`: Material Design standard

Reference: [Material Design Motion](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs)

### 8.4 Use will-change Sparingly for Animation Hints

**Impact: LOW-MEDIUM (enables GPU layer promotion without overusing memory)**

The `will-change` property hints that an element will animate, allowing the browser to optimize ahead of time. But overuse consumes GPU memory and can hurt performance.

**Incorrect (will-change on too many elements):**

```css
/* Applied to everything "just in case" */
* {
  will-change: transform, opacity;
}

/* Or on static elements that rarely animate */
.card {
  will-change: transform;
}

.button {
  will-change: transform, opacity, background-color;
}
/* Hundreds of GPU layers created */
/* Memory consumption spikes, performance degrades */
```

**Correct (will-change only when needed):**

```css
/* Apply via JavaScript just before animation */
.element-about-to-animate {
  will-change: transform;
}

/* Or apply on parent hover when child will animate */
.card:hover .card-image {
  will-change: transform;
}

/* Remove after animation completes */
.element.animation-complete {
  will-change: auto;
}
```

```javascript
// Apply will-change just before animation
element.addEventListener('mouseenter', () => {
  element.style.willChange = 'transform';
});

element.addEventListener('animationend', () => {
  element.style.willChange = 'auto'; // Release GPU layer
});

// Or for scroll-triggered animations
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    entry.target.style.willChange = entry.isIntersecting
      ? 'transform, opacity'
      : 'auto';
  });
});
```

**will-change guidelines:**
- Never use `will-change: *` globally
- Apply just before animation starts
- Remove after animation completes
- Limit to 3-4 promoted layers per view
- Use for: modal opens, complex hover states, scroll animations

Reference: [MDN will-change](https://developer.mozilla.org/en-US/docs/Web/CSS/will-change)

---

## References

1. [https://www.w3.org/WAI/WCAG22/quickref/](https://www.w3.org/WAI/WCAG22/quickref/)
2. [https://web.dev/articles/vitals](https://web.dev/articles/vitals)
3. [https://www.nngroup.com/](https://www.nngroup.com/)
4. [https://developer.mozilla.org/](https://developer.mozilla.org/)
5. [https://developers.google.com/search/docs/appearance/core-web-vitals](https://developers.google.com/search/docs/appearance/core-web-vitals)
6. [https://baymard.com/](https://baymard.com/)
7. [https://m3.material.io/](https://m3.material.io/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |