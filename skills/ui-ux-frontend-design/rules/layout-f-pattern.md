---
title: Design for F-Pattern Reading Behavior
impact: HIGH
impactDescription: increases CTA visibility by 30-50%
tags: layout, f-pattern, scanning, reading, ux
---

## Design for F-Pattern Reading Behavior

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
