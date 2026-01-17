---
title: Understand Hover Behavior on Touch Devices
impact: MEDIUM
impactDescription: prevents sticky hover states on mobile
tags: resp, hover, touch, mobile, interaction
---

## Understand Hover Behavior on Touch Devices

Tailwind CSS v4 only applies hover styles on devices that support hover, preventing "sticky" hover states on touch devices.

**Incorrect (expecting hover on all devices):**

```html
<button class="bg-blue-500 hover:bg-blue-600">
  <!-- In v3: hover state could "stick" on touch devices -->
  <!-- In v4: hover only applies on hover-capable devices -->
</button>
```

**Correct (understanding the behavior):**

```html
<!-- v4's default behavior is correct for most cases -->
<button class="bg-blue-500 hover:bg-blue-600">
  <!-- Desktop: hover works as expected -->
  <!-- Touch: no sticky hover state -->
</button>

<!-- For touch-specific feedback, use active: -->
<button class="bg-blue-500 hover:bg-blue-600 active:bg-blue-700">
  <!-- Desktop: hover + active -->
  <!-- Touch: active provides feedback -->
</button>
```

**Generated CSS in v4:**

```css
@media (hover: hover) {
  .hover\:bg-blue-600:hover {
    background-color: var(--color-blue-600);
  }
}
```

**Touch interaction patterns:**

```html
<button class="
  bg-blue-500
  hover:bg-blue-600
  active:bg-blue-700
  focus-visible:ring-2
">
  Touch-friendly button
</button>
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
