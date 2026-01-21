---
title: Set color-scheme for Native Dark Mode
impact: MEDIUM
impactDescription: eliminates visual theme inconsistencies
tags: theme, color-scheme, dark-mode, native, scrollbars
---

## Set color-scheme for Native Dark Mode

Use the `color-scheme` utility to ensure native browser elements (scrollbars, form controls) match your theme.

**Incorrect (mismatched native elements):**

```html
<html class="dark">
  <body class="bg-gray-900 text-white">
    <!-- Dark background, but scrollbars are still light -->
    <div class="overflow-auto h-screen">
      <!-- Light scrollbar on dark background -->
    </div>
  </body>
</html>
```

**Correct (coordinated color scheme):**

```html
<html class="dark scheme-dark">
  <body class="bg-gray-900 text-white">
    <!-- Scrollbars and native elements are dark -->
    <div class="overflow-auto h-screen">
      <!-- Dark scrollbar matches theme -->
    </div>
  </body>
</html>
```

**Dynamic color scheme:**

```html
<html class="scheme-light dark:scheme-dark">
  <body class="bg-white dark:bg-gray-900">
    <!-- Automatically switches native elements with theme -->
  </body>
</html>
```

**Affected native elements:**
- Scrollbars
- Form inputs (checkboxes, radios)
- `<select>` dropdowns
- `<input type="date">` pickers
- Auto-fill background colors

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
