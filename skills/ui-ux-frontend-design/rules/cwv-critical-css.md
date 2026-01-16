---
title: Inline Critical CSS and Defer the Rest
impact: CRITICAL
impactDescription: eliminates render-blocking CSS, 200-500ms faster FCP
tags: cwv, css, critical-path, performance, loading
---

## Inline Critical CSS and Defer the Rest

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
