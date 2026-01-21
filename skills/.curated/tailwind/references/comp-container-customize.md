---
title: Customize Container with @utility
impact: MEDIUM
impactDescription: prevents v4 migration breakage
tags: comp, container, utility, customization, layout
---

## Customize Container with @utility

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
