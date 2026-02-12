---
title: Tighten Line Height as Font Size Increases
impact: HIGH
impactDescription: prevents wasted vertical space in large headings
tags: fluid, line-height, leading, headings, vertical-rhythm
---

## Tighten Line Height as Font Size Increases

Line height and font size are inversely proportional — large headings need tighter line-height (1.1-1.2) while body text needs looser spacing (1.5-1.75) for comfortable reading. Applying a single generous line-height to both creates enormous vertical gaps between heading lines that break visual cohesion and waste above-the-fold space, especially on mobile where a two-line `text-5xl` heading with `leading-relaxed` can consume over half the viewport.

**Incorrect (same relaxed line-height on headings and body):**

```html
<!-- leading-relaxed on a 3rem heading creates ~30px gaps between lines -->
<article class="mx-auto max-w-3xl px-4 py-8">
  <h1 class="text-3xl font-bold leading-relaxed text-gray-900 md:text-5xl md:leading-relaxed">
    Building Responsive Interfaces That Scale Across Every Device
  </h1>
  <p class="mt-6 leading-relaxed text-gray-600">
    When designing for the web, typography choices have an outsized impact
    on how professional and readable your interface feels. Getting line-height
    right is one of the highest-leverage typographic decisions you can make.
  </p>
</article>
```

**Correct (tight leading on headings, relaxed on body):**

```html
<!-- Heading uses leading-tight (1.25), body uses leading-relaxed (1.625) -->
<article class="mx-auto max-w-3xl px-4 py-8">
  <h1 class="text-3xl font-bold leading-tight text-gray-900 md:text-5xl md:leading-[1.15]">
    Building Responsive Interfaces That Scale Across Every Device
  </h1>
  <p class="mt-6 text-base leading-relaxed text-gray-600">
    When designing for the web, typography choices have an outsized impact
    on how professional and readable your interface feels. Getting line-height
    right is one of the highest-leverage typographic decisions you can make.
  </p>
</article>
```

**Key principle:** As headings scale up at wider breakpoints, tighten the line-height further — `leading-tight` at mobile sizes, then `md:leading-[1.15]` or `lg:leading-none` at desktop where the heading font size is largest. Body text should stay at `leading-relaxed` or `leading-7` regardless of breakpoint.

**See also:** `tailwind-ui-refactor/type-line-height-inverse` for the baseline principle; this rule adds the responsive breakpoint transformations.
