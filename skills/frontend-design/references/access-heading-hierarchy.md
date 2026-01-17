---
title: Maintain Logical Heading Hierarchy
impact: CRITICAL
impactDescription: enables screen reader users to navigate and understand page structure
tags: access, headings, hierarchy, navigation, wcag
---

## Maintain Logical Heading Hierarchy

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
