---
title: Limit to One Primary Call-to-Action Per Screen
impact: HIGH
impactDescription: reduces decision paralysis, improves click-through rates
tags: layout, cta, conversion, ux, decisions
---

## Limit to One Primary Call-to-Action Per Screen

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
