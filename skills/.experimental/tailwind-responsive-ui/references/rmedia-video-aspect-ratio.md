---
title: Maintain Video Aspect Ratio Across Breakpoints
impact: MEDIUM
impactDescription: eliminates black bars and content overflow for video embeds
tags: rmedia, video, aspect-ratio, embed, responsive
---

## Maintain Video Aspect Ratio Across Breakpoints

Embedded videos from YouTube, Vimeo, or self-hosted sources need to maintain their 16:9 (or other) aspect ratio while filling the available width. Using fixed `width` and `height` attributes on an `<iframe>` causes overflow on mobile — a 560px embed will scroll horizontally on any screen narrower than that. Tailwind's `aspect-video` utility combined with `w-full` solves this in a single wrapper.

**Incorrect (fixed iframe dimensions that overflow on mobile):**

```html
<!-- 560px iframe overflows on mobile, and resizing only the width squashes the video -->
<section class="mx-auto max-w-4xl px-4 py-8">
  <h2 class="text-2xl font-bold text-gray-900">Product Demo</h2>
  <p class="mt-2 text-gray-600">Watch how our platform simplifies your workflow.</p>
  <div class="mt-6">
    <iframe
      width="560"
      height="315"
      src="https://www.youtube.com/embed/dQw4w9WgXcQ"
      title="Product Demo Video"
      frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen
    ></iframe>
  </div>
</section>
```

**Correct (aspect-ratio wrapper that maintains 16:9 at any width):**

```html
<!-- Video fills container width while maintaining perfect 16:9 ratio on every screen size -->
<section class="mx-auto max-w-4xl px-4 py-8">
  <h2 class="text-2xl font-bold text-gray-900">Product Demo</h2>
  <p class="mt-2 text-gray-600">Watch how our platform simplifies your workflow.</p>
  <div class="mt-6 aspect-video w-full overflow-hidden rounded-lg shadow-md">
    <iframe
      class="h-full w-full"
      src="https://www.youtube.com/embed/dQw4w9WgXcQ"
      title="Product Demo Video"
      frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen
    ></iframe>
  </div>
</section>
```

**Key principle:** Wrap video embeds in a container with `aspect-video w-full` (which applies `aspect-ratio: 16/9`) and make the iframe itself `w-full h-full`. The wrapper controls the ratio while filling the available width, and the iframe stretches to match. Remove `width` and `height` attributes from the iframe — the CSS handles sizing now.
