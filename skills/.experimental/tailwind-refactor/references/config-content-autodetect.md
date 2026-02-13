---
title: Remove Manual Content Configuration
impact: HIGH
impactDescription: eliminates config maintenance — 0 lines of content configuration needed
tags: config, content-detection, purge, source
---

## Remove Manual Content Configuration

Tailwind CSS v4 automatically detects your template files by scanning the project directory. The manual `content` array in the config is no longer needed and should be removed. Keeping a manual list can actually cause issues — files outside the listed globs will be silently missed even though auto-detection would have found them.

**Incorrect (what's wrong):**

```js
// tailwind.config.js
module.exports = {
  content: ['./src/**/*.{html,js,tsx}', './public/index.html'],
};
```

**Correct (what's right):**

Remove the `content` configuration entirely. Tailwind v4 auto-detection respects `.gitignore` and ignores binary files automatically.

For edge cases where you need to include files outside the project root — such as a monorepo dependency — use the `@source` directive in your CSS:

```css
@import "tailwindcss";

@source "../node_modules/@my-company/ui-lib";
```
