---
title: Constrain Line Length to 45-75 Characters
impact: HIGH
impactDescription: maintains readability across all screen widths
tags: fluid, measure, line-length, max-width, prose, readability
---

## Constrain Line Length to 45-75 Characters

Optimal reading measure is 45-75 characters per line (roughly 20-35em). On wide screens, unconstrained paragraph text stretches to 120+ characters per line, forcing the reader's eye to travel too far to find the next line and drastically increasing reading fatigue. On mobile, the viewport naturally constrains line length, but on anything wider than a tablet you must explicitly cap it. Tailwind's `max-w-prose` (65ch) is purpose-built for this.

**Incorrect (full-width paragraph stretching across the viewport):**

```html
<!-- At 1440px wide, this paragraph runs ~130 characters per line -->
<div class="px-8 py-12">
  <h2 class="text-2xl font-bold text-gray-900">Why Responsive Design Matters</h2>
  <p class="mt-4 text-lg text-gray-600">
    Responsive design is not just about making things fit on smaller screens. It is about
    creating an experience that feels intentional at every width. When text stretches across
    the full width of a wide monitor, readers lose their place between lines and comprehension
    drops significantly. Studies show that reading speed and retention both decrease when line
    length exceeds 75 characters, making measure one of the most impactful typographic choices.
  </p>
</div>
```

**Correct (line length capped with max-w-prose):**

```html
<!-- max-w-prose caps width at 65ch — comfortable reading on any screen -->
<div class="px-8 py-12">
  <div class="mx-auto max-w-prose">
    <h2 class="text-2xl font-bold text-gray-900">Why Responsive Design Matters</h2>
    <p class="mt-4 text-lg text-gray-600">
      Responsive design is not just about making things fit on smaller screens. It is about
      creating an experience that feels intentional at every width. When text stretches across
      the full width of a wide monitor, readers lose their place between lines and comprehension
      drops significantly. Studies show that reading speed and retention both decrease when line
      length exceeds 75 characters, making measure one of the most impactful typographic choices.
    </p>
  </div>
</div>
```

**Key principle:** Wrap text content in `max-w-prose` (65ch), `max-w-2xl` (~42rem), or `max-w-3xl` (~48rem) and center it with `mx-auto`. This only constrains the text container — your outer layout can still span the full viewport for backgrounds and decorative elements. On mobile, the screen width is already within comfortable range, so the constraint only activates on wider viewports.

**See also:** `tailwind-ui-refactor/type-line-length` for the baseline 45-75 character principle; this rule adds the responsive implementation with Tailwind utilities.
