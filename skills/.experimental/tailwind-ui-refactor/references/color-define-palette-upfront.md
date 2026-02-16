---
title: Define a Complete Color Palette Upfront — Don't Pick Colors Ad-Hoc
impact: HIGH
impactDescription: eliminates inconsistent color usage across entire UI
tags: color, palette, design-system, tailwind-config, consistency
---

Picking colors one at a time leads to 47 slightly different blues across the app. Define your full palette in advance: 8-10 shades per color (grays, primary, 2-3 accents). Use Tailwind's theme configuration.

**Incorrect (ad-hoc hex values everywhere):**
```html
<div>
  <h3 class="text-[#2d3748]">Account Settings</h3>
  <p class="text-[#6b7c93]">Manage your preferences</p>
  <button class="bg-[#3182ce] text-white">Save</button>
  <button class="text-[#e53e3e]">Delete</button>
</div>
```

**Correct (systematic palette from Tailwind config):**
```html
<div>
  <h3 class="text-gray-900">Account Settings</h3>
  <p class="text-gray-500">Manage your preferences</p>
  <button class="bg-blue-600 text-white">Save</button>
  <button class="text-red-600">Delete</button>
</div>
```

**Taste checkpoint:** After defining your palette, build one complete component using only your palette colors. If you find yourself reaching for arbitrary hex values, your palette has a gap — expand the palette, don't bypass it.

Reference: Refactoring UI — "Working with Color" · John Edson, Design Like Apple — Principle 4: "Design Is Systems Thinking"
