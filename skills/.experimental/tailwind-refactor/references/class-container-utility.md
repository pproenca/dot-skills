---
title: Replace Container Plugin Config with @utility
impact: HIGH
impactDescription: eliminates JS config dependency for container behavior
tags: class, container, utility, config
---

## Replace Container Plugin Config with @utility

Tailwind CSS v4 removed JavaScript-based container configuration from `tailwind.config.js`. The `theme.container` options for centering and padding no longer have any effect. Instead, define the container behavior directly in CSS using the `@utility` directive. This keeps all styling in CSS, eliminates the dependency on a JS config file for a purely visual concern, and gives you full control over the container's responsive behavior.

**Incorrect (what's wrong):**

```js
// tailwind.config.js
module.exports = {
  theme: {
    container: {
      center: true,
      padding: '2rem',
    },
  },
};
```

**Correct (what's right):**

```css
@utility container {
  margin-inline: auto;
  padding-inline: 2rem;
}
```
