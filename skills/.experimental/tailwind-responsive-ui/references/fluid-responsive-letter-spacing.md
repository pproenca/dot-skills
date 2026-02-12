---
title: Adjust Letter Spacing for Responsive Headlines
impact: MEDIUM
impactDescription: 10-15% tighter tracking improves headline readability at 48px+
tags: fluid, letter-spacing, tracking, headlines, kerning
---

## Adjust Letter Spacing for Responsive Headlines

Large headings on desktop benefit from tighter letter-spacing (negative tracking) because at large sizes the default inter-character gaps appear proportionally wider, making words look loose and disconnected. On mobile, where those same headings render at smaller sizes, tight tracking reduces readability by cramming characters together. Match tracking to the rendered size — default or normal at small sizes, progressively tighter as the heading scales up at wider breakpoints.

**Incorrect (same tight tracking at all sizes):**

```html
<!-- tracking-tight on a text-xl mobile heading cramps the characters -->
<header class="bg-gray-950 px-4 py-16 text-white md:px-8 lg:py-24">
  <h1 class="text-xl font-bold tracking-tight md:text-4xl lg:text-6xl">
    The Future of Design Systems
  </h1>
  <p class="mt-4 text-sm tracking-tight text-gray-300 md:text-base lg:text-lg">
    A comprehensive guide to building scalable, maintainable UI architectures
    that work across teams and products.
  </p>
</header>
```

**Correct (tracking tightens as heading size increases):**

```html
<!-- Normal tracking on mobile, tighter as the heading grows at wider breakpoints -->
<header class="bg-gray-950 px-4 py-16 text-white md:px-8 lg:py-24">
  <h1 class="text-xl font-bold tracking-normal md:text-4xl md:tracking-tight lg:text-6xl lg:tracking-tighter">
    The Future of Design Systems
  </h1>
  <p class="mt-4 text-sm text-gray-300 md:text-base lg:text-lg">
    A comprehensive guide to building scalable, maintainable UI architectures
    that work across teams and products.
  </p>
</header>
```

**Key principle:** Only apply `tracking-tight` or `tracking-tighter` at breakpoints where the heading is large enough to benefit from it (typically `text-3xl` and above). Body text and small UI labels should almost always use default tracking. If you are using `clamp()` for fluid font sizing, apply the tighter tracking at the breakpoint where the font size crosses into the "large heading" range.

**See also:** `tailwind-ui-refactor/type-letter-spacing` for the baseline principle; this rule adds responsive breakpoint-conditional application.
