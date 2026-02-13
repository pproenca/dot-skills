---
title: Account for Hover Variant Media Query Wrapping
impact: MEDIUM
impactDescription: prevents broken hover states on touch devices
tags: syntax, hover, media-query, accessibility, v4-migration
---

## Account for Hover Variant Media Query Wrapping

Tailwind v4 wraps the `hover:` variant inside `@media (hover: hover)`, which means hover styles only apply on devices that actually support hover (mouse/trackpad). This is the correct behavior — hover effects on touch devices were always a UX bug that caused "sticky hover" states. Be aware of this change when testing on mobile devices.

**Incorrect (hover-only — no touch feedback):**

```html
<!-- hover: now only applies on devices with hover support (correct for most cases) -->
<button class="hover:bg-blue-600">
  Will not show hover feedback on touch-only devices in v4
</button>
```

**Correct (hover + touch feedback):**

```html
<!-- Use active: for touch feedback alongside hover: for pointer devices -->
<button class="hover:bg-blue-600 active:bg-blue-700">
  Hover feedback on desktop, press feedback on touch
</button>
```

If you genuinely need hover behavior on all devices (rare), restore v3 behavior with:

```css
@custom-variant hover (&:hover);
```

**When NOT to apply this rule:**
- Standard `hover:` usage is NOT incorrect in v4 — the default behavior is correct for most cases
- Only add `active:` variants when touch feedback is important for the interaction (buttons, links, interactive cards)
- Do not blanket-add `active:` to every `hover:` class in a codebase
