---
title: Use Class-Based Dark Mode for Control
impact: MEDIUM
impactDescription: enables manual theme switching, better user control
tags: theme, dark-mode, class, selector, preferences
---

## Use Class-Based Dark Mode for Control

By default, Tailwind v4 uses `prefers-color-scheme`. For user-controlled theme switching, configure class-based dark mode.

**Incorrect (only system preference):**

```css
@import "tailwindcss";
/* Default: dark: responds only to OS setting */
```

```html
<!-- No way for users to manually toggle theme -->
<div class="bg-white dark:bg-gray-900">
```

**Correct (class-based control):**

```css
@import "tailwindcss";

@variant dark (&:where(.dark, .dark *));
```

```html
<!-- Toggle theme by adding/removing .dark class -->
<html class="dark">
  <body class="bg-white dark:bg-gray-900">
    <!-- Dark mode active -->
  </body>
</html>
```

**Theme toggle implementation:**

```typescript
function toggleDarkMode() {
  document.documentElement.classList.toggle("dark");
  localStorage.setItem(
    "theme",
    document.documentElement.classList.contains("dark") ? "dark" : "light"
  );
}

// On page load
if (localStorage.theme === "dark" ||
    (!localStorage.theme && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
  document.documentElement.classList.add("dark");
}
```

Reference: [Tailwind CSS Dark Mode](https://tailwindcss.com/docs/dark-mode)
