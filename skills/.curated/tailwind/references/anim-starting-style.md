---
title: Use @starting-style for Entry Animations
impact: LOW-MEDIUM
impactDescription: enables CSS-only entry animations, no JavaScript
tags: anim, starting-style, entry, popover, dialog
---

## Use @starting-style for Entry Animations

Use the `starting:` variant for CSS-only entry animations on elements that appear dynamically (popovers, dialogs, conditionally rendered elements).

**Incorrect (JavaScript-dependent animation):**

```tsx
function Popover({ isOpen }) {
  return (
    <div
      className={`transition-opacity duration-200 ${
        isOpen ? "opacity-100" : "opacity-0"
      }`}
    >
      {/* Requires JavaScript state management */}
    </div>
  );
}
```

**Correct (CSS-only with @starting-style):**

```html
<button popovertarget="my-popover">Open</button>

<div
  popover
  id="my-popover"
  class="transition-discrete opacity-100 starting:open:opacity-0"
>
  <!-- Animates from 0 to 100% opacity when popover opens -->
  <!-- No JavaScript required -->
</div>
```

**With scale and translate:**

```html
<div
  popover
  id="menu"
  class="
    transition-discrete
    opacity-100 scale-100 translate-y-0
    starting:open:opacity-0
    starting:open:scale-95
    starting:open:translate-y-2
  "
>
  <!-- Fades in, scales up, and slides down -->
</div>
```

**Note:** `transition-discrete` is required for animating `display` property changes.

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
