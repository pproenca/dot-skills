---
title: Use Semantic HTML Elements
impact: CRITICAL
impactDescription: enables screen reader navigation and improves SEO
tags: access, semantic, html, screen-readers, seo
---

## Use Semantic HTML Elements

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
