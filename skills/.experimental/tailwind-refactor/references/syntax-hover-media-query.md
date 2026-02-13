---
title: Account for Hover Variant Media Query Wrapping
impact: MEDIUM
impactDescription: prevents broken hover states on touch devices
tags: syntax, hover, media-query, accessibility, v4-migration
---

## Account for Hover Variant Media Query Wrapping

Tailwind v4 wraps the `hover:` variant inside `@media (hover: hover)`, which means hover styles only apply on devices that actually support hover (mouse/trackpad). This is the correct behavior — hover effects on touch devices were always a UX bug that caused "sticky hover" states. Be aware of this change when testing on mobile devices.

**Incorrect (what's wrong):**

```html
<!-- Assuming hover: works on all devices like v3 -->
<button class="hover:bg-blue-600">
  May not show hover feedback on touch devices in v4
</button>
```

**Correct (what's right):**

```html
<!-- v4 default behavior is correct for most cases -->
<button class="hover:bg-blue-600 active:bg-blue-700">
  Use active: for touch feedback alongside hover: for pointer devices
</button>
```

If you genuinely need hover behavior on all devices (rare), restore v3 behavior with:

```css
@custom-variant hover (&:hover);
```
