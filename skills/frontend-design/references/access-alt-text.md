---
title: Provide Meaningful Alt Text for Images
impact: CRITICAL
impactDescription: enables blind users to understand image content
tags: access, alt-text, images, screen-readers, wcag
---

## Provide Meaningful Alt Text for Images

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
