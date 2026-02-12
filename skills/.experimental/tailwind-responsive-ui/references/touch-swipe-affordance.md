---
title: Add Visual Swipe Affordances for Horizontal Scrolling
impact: MEDIUM
impactDescription: increases horizontal scroll discoverability by 3-5x
tags: touch, swipe, scroll, affordance, mobile, ux
---

## Add Visual Swipe Affordances for Horizontal Scrolling

Horizontal scrollable content is effectively invisible without visual cues on mobile. When cards or items are perfectly aligned within the viewport, users have no indication that more content exists off-screen. Research shows that adding a partial-item "peek" increases discoverability of horizontally scrollable areas by 3-5x. The simplest technique is sizing items slightly narrower than the viewport so the next item peeks from the edge, signaling swipeable content.

**Incorrect (no visual hint that more content exists off-screen):**

```html
<!-- Items fit perfectly — user sees 2 cards and has no idea there are 6 more to the right -->
<div class="overflow-x-auto flex gap-4 px-4">
  <div class="w-[calc(50%-8px)] flex-shrink-0 rounded-lg border bg-white p-4">
    <img src="/dest-1.jpg" alt="Paris" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-2 font-semibold">Paris</h3>
    <p class="text-sm text-gray-500">From $299/night</p>
  </div>
  <div class="w-[calc(50%-8px)] flex-shrink-0 rounded-lg border bg-white p-4">
    <img src="/dest-2.jpg" alt="Tokyo" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-2 font-semibold">Tokyo</h3>
    <p class="text-sm text-gray-500">From $199/night</p>
  </div>
  <div class="w-[calc(50%-8px)] flex-shrink-0 rounded-lg border bg-white p-4">
    <img src="/dest-3.jpg" alt="New York" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-2 font-semibold">New York</h3>
    <p class="text-sm text-gray-500">From $249/night</p>
  </div>
  <!-- ...more items hidden with no visual cue -->
</div>
```

**Correct (partial item peek + scroll snap for clear swipe affordance):**

```html
<!-- w-[85%] ensures the next card peeks ~15% from the edge, signaling "swipe for more" -->
<div class="flex snap-x snap-mandatory gap-4 overflow-x-auto scroll-smooth px-4 pb-4 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
  <div class="w-[85%] flex-shrink-0 snap-start rounded-lg border bg-white p-4 md:w-[calc(33.333%-11px)] md:snap-align-none">
    <img src="/dest-1.jpg" alt="Paris" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-2 font-semibold">Paris</h3>
    <p class="text-sm text-gray-500">From $299/night</p>
  </div>
  <div class="w-[85%] flex-shrink-0 snap-start rounded-lg border bg-white p-4 md:w-[calc(33.333%-11px)] md:snap-align-none">
    <img src="/dest-2.jpg" alt="Tokyo" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-2 font-semibold">Tokyo</h3>
    <p class="text-sm text-gray-500">From $199/night</p>
  </div>
  <div class="w-[85%] flex-shrink-0 snap-start rounded-lg border bg-white p-4 md:w-[calc(33.333%-11px)] md:snap-align-none">
    <img src="/dest-3.jpg" alt="New York" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-2 font-semibold">New York</h3>
    <p class="text-sm text-gray-500">From $249/night</p>
  </div>
  <div class="w-[85%] flex-shrink-0 snap-start rounded-lg border bg-white p-4 md:w-[calc(33.333%-11px)] md:snap-align-none">
    <img src="/dest-4.jpg" alt="London" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-2 font-semibold">London</h3>
    <p class="text-sm text-gray-500">From $279/night</p>
  </div>
</div>
```
