---
title: Decide Your Visual Voice Once — Radius, Shadows, Spacing — Then Defend It
impact: HIGH
impactDescription: prevents inconsistent visual language by establishing system-level design tokens before component work
tags: system, brand, consistency, tokens, conviction
---

A product's visual voice is defined by a handful of decisions made once and applied everywhere: border radius, shadow intensity, spacing density, and color temperature. These decisions should be made in the first 10 minutes of a project, documented, and defended. A product with consistent rounded-none has more personality than one with inconsistent rounded-lg.

**Incorrect (each component makes its own visual decisions):**
```html
<!-- Header: sharp corners, heavy shadows -->
<nav class="bg-white px-6 py-3 shadow-md">
  <button class="rounded bg-blue-600 px-4 py-2 text-sm text-white">New Project</button>
</nav>
<!-- Card: large radius, subtle shadows -->
<div class="mt-6 rounded-xl bg-white p-6 shadow-sm">
  <h3 class="text-lg font-bold">Dashboard</h3>
  <button class="mt-4 rounded-full bg-blue-500 px-6 py-2 text-white">View All</button>
</div>
<!-- Footer: medium radius, no shadows -->
<footer class="mt-8 rounded-lg bg-gray-100 p-8">
  <button class="rounded-lg border border-blue-600 px-4 py-2 text-blue-600">Contact Us</button>
</footer>
```

**Correct (one visual voice applied everywhere):**
```html
<!-- Visual voice: rounded-lg, shadow-sm, blue-600, consistent padding scale -->
<nav class="bg-white px-6 py-3 shadow-sm">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">New Project</button>
</nav>
<div class="mt-6 rounded-lg bg-white p-6 shadow-sm">
  <h3 class="text-lg font-semibold text-gray-900">Dashboard</h3>
  <button class="mt-4 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">View All</button>
</div>
<footer class="mt-8 rounded-lg bg-gray-50 p-6">
  <button class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Contact Us</button>
</footer>
```

**The visual voice checklist — decide these once:**
1. **Radius:** rounded-none / rounded / rounded-lg / rounded-xl — pick one for all components
2. **Shadow intensity:** shadow-sm for everything, or shadow-sm for cards + shadow-md for dropdowns + shadow-xl for modals
3. **Spacing density:** compact (p-3 gap-2) / balanced (p-4 gap-4) / generous (p-6 gap-6)
4. **Color temperature:** cool grays (gray-*) / warm grays (stone-* or zinc-*)
5. **Primary action:** blue-600 / indigo-600 / your brand color — one hue, applied consistently

Reference: John Edson, Design Like Apple — Principle 4: "Design Is Systems Thinking — the product and its context are one"
