---
title: Leverage Automatic Content Detection
impact: CRITICAL
impactDescription: eliminates manual configuration, prevents missing utilities
tags: build, content, detection, configuration, scanning
---

## Leverage Automatic Content Detection

Tailwind CSS v4 automatically detects template files without manual configuration. Only use `@source` when you need to include files outside the standard detection scope.

**Incorrect (unnecessary manual configuration):**

```css
/* styles.css */
@import "tailwindcss";

/* Redundant - these paths are auto-detected */
@source "./src/**/*.{js,ts,jsx,tsx}";
@source "./components/**/*.vue";
@source "./app/**/*.tsx";
```

**Correct (minimal configuration):**

```css
/* styles.css */
@import "tailwindcss";

/* Only specify external packages not in your repo */
@source "../node_modules/@my-company/ui-lib";
```

**When to use @source:**
- External UI libraries in node_modules
- Files outside the project root
- Paths excluded by .gitignore that you need to include

**Auto-ignored paths:**
- Files listed in .gitignore
- Binary files (images, videos, zips)
- node_modules (unless explicitly sourced)

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)
