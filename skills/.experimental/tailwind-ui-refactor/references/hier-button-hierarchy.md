---
title: Style Buttons by Visual Hierarchy, Not Semantic Importance
impact: CRITICAL
impactDescription: eliminates competing CTAs that confuse users and prevents misclick on irreversible actions
tags: hier, buttons, actions, cta, primary, secondary, tertiary, empathy
---

Not every button deserves to be a big, colorful, primary button. Style buttons based on their position in the action hierarchy: primary (solid fill), secondary (outline or muted), tertiary (text-only link style). But hierarchy alone is not enough — consider the *consequence* of each action. An irreversible action needs more than visual de-emphasis; it needs physical separation or a confirmation step.

**Incorrect (all buttons look equally important):**
```html
<div class="flex gap-2">
  <button class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white">Save</button>
  <button class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white">Cancel</button>
  <button class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white">Delete</button>
</div>
```

**Correct (clear action hierarchy — save context):**
```html
<div class="flex items-center gap-2">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Save</button>
  <button class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Cancel</button>
  <button class="ml-auto text-sm text-red-600">Delete</button>
</div>
```

**When destructive IS the primary action (confirmation dialog):**
```html
<div class="mx-auto max-w-sm rounded-lg bg-white p-6 shadow-xl">
  <h3 class="text-base font-semibold text-gray-900">Delete this project?</h3>
  <p class="mt-2 text-sm text-gray-600">This will permanently delete "Project Alpha" and all its data. This cannot be undone.</p>
  <div class="mt-6 flex gap-3">
    <button class="flex-1 rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Cancel</button>
    <button class="flex-1 rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white">Delete Project</button>
  </div>
</div>
```

**When NOT to use simple de-emphasis for destructive actions:** If the action is irreversible (account deletion, data purge, production deployment), visual de-emphasis alone is insufficient. Use physical separation (place the destructive action in a separate section), require explicit confirmation (modal or inline confirmation), or both. Consider the *consequence of misclick* — the Apple approach prioritizes preventing harm over visual elegance.

**Taste checkpoint:** After styling the button hierarchy, ask: "If the user accidentally clicks the wrong button, what happens? Can they undo it? If not, have I made it hard enough to click accidentally?"

Reference: Refactoring UI — "Hierarchy is Everything" · John Edson, Design Like Apple — Principle 6: "Design Is For People"
