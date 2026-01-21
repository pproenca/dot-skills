---
title: Define Custom Breakpoints in @theme
impact: MEDIUM
impactDescription: enables project-specific responsive design
tags: resp, breakpoints, theme, custom, responsive
---

## Define Custom Breakpoints in @theme

Add custom breakpoints using the `@theme` directive. This is useful for project-specific design requirements or adding intermediate breakpoints.

**Incorrect (arbitrary values for breakpoints):**

```html
<div class="hidden min-[900px]:block min-[1400px]:flex">
  <!-- Arbitrary values scattered across codebase -->
</div>
```

**Correct (custom theme breakpoints):**

```css
@import "tailwindcss";

@theme {
  --breakpoint-xs: 480px;
  --breakpoint-3xl: 1920px;
  --breakpoint-4xl: 2560px;
}
```

```html
<div class="hidden xs:block 3xl:flex 4xl:grid">
  <!-- Named breakpoints, consistent usage -->
</div>
```

**Override default breakpoints:**

```css
@theme {
  /* Override existing breakpoints */
  --breakpoint-sm: 600px;  /* Was 640px */
  --breakpoint-lg: 992px;  /* Was 1024px */
}
```

**Benefits:**
- Consistent breakpoint values across codebase
- Self-documenting (named vs arbitrary)
- Easy to update project-wide
- IDE autocomplete support

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)
