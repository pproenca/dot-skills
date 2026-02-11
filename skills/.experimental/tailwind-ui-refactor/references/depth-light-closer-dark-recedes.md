---
title: Lighter Colors Feel Closer, Darker Colors Recede
impact: MEDIUM
impactDescription: creates depth without shadows using color alone
tags: depth, color, elevation, flat-design, layers
---

In flat design without shadows, use color value to communicate depth. Lighter elements appear closer to the user, darker elements recede into the background. This is useful for nav bars, sidebars, and layered cards.

**Incorrect (flat, no depth cues):**
```html
<div class="flex">
  <aside class="w-56 bg-white p-4">
    <nav class="space-y-2">
      <a class="block rounded px-3 py-2 text-sm text-gray-700">Dashboard</a>
      <a class="block rounded px-3 py-2 text-sm text-gray-700">Projects</a>
    </nav>
  </aside>
  <main class="flex-1 bg-white p-6">Content</main>
</div>
```

**Correct (darker sidebar recedes, content area pops):**
```html
<div class="flex">
  <aside class="w-56 bg-gray-900 p-4">
    <nav class="space-y-1">
      <a class="block rounded-lg bg-gray-800 px-3 py-2 text-sm font-medium text-white">Dashboard</a>
      <a class="block rounded-lg px-3 py-2 text-sm text-gray-400 hover:bg-gray-800 hover:text-white">Projects</a>
    </nav>
  </aside>
  <main class="flex-1 bg-white p-6">Content</main>
</div>
```

Reference: Refactoring UI — "Depth"
