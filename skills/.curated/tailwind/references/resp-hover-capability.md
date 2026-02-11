---
title: Pair Hover with Active for Touch-Friendly Interactions
impact: MEDIUM
impactDescription: prevents missing feedback on touch devices
tags: resp, hover, touch, mobile, interaction, active
---

## Pair Hover with Active for Touch-Friendly Interactions

Tailwind CSS v4 only applies `hover:` styles on devices that support hover (`@media (hover: hover)`), preventing "sticky" hover states on touch devices. Always pair `hover:` with `active:` to provide feedback on both device types.

**Incorrect (hover-only feedback):**

```html
<button class="bg-blue-500 hover:bg-blue-600">
  <!-- Desktop: visual feedback on hover -->
  <!-- Touch: no feedback at all — button appears unresponsive -->
</button>

<a href="/settings" class="text-gray-600 hover:text-blue-500">
  <!-- Touch users get no indication the link is tappable -->
  Settings
</a>
```

**Correct (hover + active for all devices):**

```html
<button class="bg-blue-500 hover:bg-blue-600 active:bg-blue-700">
  <!-- Desktop: hover feedback + press feedback -->
  <!-- Touch: press feedback via active: -->
</button>

<a href="/settings" class="text-gray-600 hover:text-blue-500 active:text-blue-600">
  Settings
</a>
```

**Complete interactive pattern:**

```html
<button class="
  bg-blue-500 text-white
  hover:bg-blue-600
  active:bg-blue-700
  focus-visible:ring-2 focus-visible:ring-blue-400
  disabled:opacity-50 disabled:pointer-events-none
">
  Touch-friendly button
</button>
```

**Generated CSS in v4:**

```css
@media (hover: hover) {
  .hover\:bg-blue-600:hover {
    background-color: var(--color-blue-600);
  }
}
/* active: applies on all devices — no media query wrapping */
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
