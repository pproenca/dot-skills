---
title: Migrate addVariant to @custom-variant
impact: HIGH
impactDescription: replaces ~10-line JS plugin with 1 CSS directive per variant
tags: config, variants, custom-variant, plugins
---

## Migrate addVariant to @custom-variant

Tailwind CSS v4 replaces the JavaScript `addVariant` plugin API with a CSS-native `@custom-variant` directive. This eliminates the need for a JS plugin file just to register custom variants, keeping your variant definitions alongside the rest of your CSS configuration.

**Incorrect (what's wrong):**

```js
// tailwind.config.js
const plugin = require('tailwindcss/plugin');

module.exports = {
  plugins: [
    plugin(function ({ addVariant }) {
      addVariant('hocus', ['&:hover', '&:focus']);
      addVariant('group-hocus', [':merge(.group):hover &', ':merge(.group):focus &']);
    }),
  ],
};
```

**Correct (what's right):**

```css
@custom-variant hocus (&:hover, &:focus);
@custom-variant group-hocus (:merge(.group):hover &, :merge(.group):focus &);
```

You can then use these variants directly in your templates:

```html
<button class="hocus:underline group-hocus:text-brand">Click me</button>
```
