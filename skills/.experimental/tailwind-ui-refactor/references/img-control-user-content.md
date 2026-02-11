---
title: Control User-Uploaded Image Size and Aspect Ratio
impact: LOW-MEDIUM
impactDescription: prevents broken layouts from unpredictable image dimensions
tags: img, user-content, aspect-ratio, object-fit, layout
---

User-uploaded images come in every size and aspect ratio. Without constraints, they break layouts. Always define a fixed container with object-fit: cover to crop images consistently.

**Incorrect (uncontrolled image dimensions):**
```html
<div class="flex gap-4">
  <img src="/avatar1.jpg" class="rounded-full" />
  <img src="/avatar2.jpg" class="rounded-full" />
  <img src="/avatar3.jpg" class="rounded-full" />
</div>
```

**Correct (fixed dimensions with object-fit):**
```html
<div class="flex gap-4">
  <img src="/avatar1.jpg" class="h-10 w-10 rounded-full object-cover" />
  <img src="/avatar2.jpg" class="h-10 w-10 rounded-full object-cover" />
  <img src="/avatar3.jpg" class="h-10 w-10 rounded-full object-cover" />
</div>
```

Reference: Refactoring UI — "Working with Images"
