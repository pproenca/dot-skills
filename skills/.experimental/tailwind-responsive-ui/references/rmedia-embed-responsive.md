---
title: Make Embedded Content Responsive with Container Constraints
impact: LOW-MEDIUM
impactDescription: prevents iframes and embeds from breaking mobile layouts
tags: rmedia, embed, iframe, overflow, responsive
---

## Make Embedded Content Responsive with Container Constraints

Third-party embeds — maps, forms, calendars, widgets — almost always ship with fixed `width` and `height` attributes that assume a desktop viewport. An 800px-wide Google Maps iframe will blow past its container on any screen under 800px, creating a horizontal scrollbar that breaks the entire page layout. Wrap embeds in a constrained container with `w-full` and an appropriate aspect ratio to make them fluid.

**Incorrect (fixed-dimension iframe that overflows on mobile):**

```html
<!-- 800px iframe overflows on mobile, creating horizontal scroll on the entire page -->
<section class="mx-auto max-w-4xl px-4 py-8">
  <h2 class="text-2xl font-bold text-gray-900">Find Our Office</h2>
  <p class="mt-2 text-gray-600">We're located in the heart of downtown, just steps from the central station.</p>
  <div class="mt-6">
    <iframe
      width="800"
      height="600"
      src="https://www.google.com/maps/embed?pb=!1m18!1m12!..."
      title="Office Location"
      style="border:0"
      allowfullscreen
      loading="lazy"
      referrerpolicy="no-referrer-when-downgrade"
    ></iframe>
  </div>
  <p class="mt-4 text-sm text-gray-500">123 Main Street, Suite 400, Downtown</p>
</section>
```

**Correct (container-constrained embed with proper aspect ratio):**

```html
<!-- Embed fills container width with 4:3 aspect ratio, no overflow at any screen size -->
<section class="mx-auto max-w-4xl px-4 py-8">
  <h2 class="text-2xl font-bold text-gray-900">Find Our Office</h2>
  <p class="mt-2 text-gray-600">We're located in the heart of downtown, just steps from the central station.</p>
  <div class="mt-6 w-full overflow-hidden rounded-lg shadow-sm">
    <iframe
      class="w-full aspect-[4/3]"
      src="https://www.google.com/maps/embed?pb=!1m18!1m12!..."
      title="Office Location"
      style="border:0"
      allowfullscreen
      loading="lazy"
      referrerpolicy="no-referrer-when-downgrade"
    ></iframe>
  </div>
  <p class="mt-4 text-sm text-gray-500">123 Main Street, Suite 400, Downtown</p>
</section>
```

**Key principle:** Remove fixed `width` and `height` attributes from iframes and apply `w-full` with an explicit aspect ratio (`aspect-[4/3]` for maps, `aspect-video` for video). The `overflow-hidden` on the wrapper prevents any content from leaking outside the container bounds. For embeds that resist CSS sizing, use `max-w-full` as a fallback to at least prevent overflow.
