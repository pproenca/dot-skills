---
title: Reduce Choices Per Screen — Fewer Options Beat Prettier Options
impact: CRITICAL
impactDescription: reduces decision fatigue by limiting visible actions per screen (Hick's Law — fewer choices means faster decisions)
tags: intent, cognitive-load, hicks-law, simplify, actions, cta
---

Adding styling to 6 buttons does not fix the problem of having 6 buttons. Hick's Law: decision time increases logarithmically with the number of choices. Before styling a group of actions, reduce the count. One primary action, one secondary, and a "more" menu beats five equally styled buttons.

**Incorrect (5 actions competing — styling cannot fix this):**
```html
<div class="flex gap-2">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Approve</button>
  <button class="rounded-lg bg-green-600 px-4 py-2 text-sm font-medium text-white">Merge</button>
  <button class="rounded-lg bg-yellow-500 px-4 py-2 text-sm font-medium text-white">Request Changes</button>
  <button class="rounded-lg bg-gray-600 px-4 py-2 text-sm font-medium text-white">Assign</button>
  <button class="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white">Close</button>
</div>
```

**Correct (reduce first, then style the hierarchy):**
```html
<div class="flex items-center gap-3">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Approve</button>
  <button class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Request Changes</button>
  <button class="text-sm text-gray-500">More...</button>
</div>
```

The goal is not to style all actions — it is to surface the right action for the user's current context. Hide the rest behind a dropdown or secondary screen.

**When NOT to reduce actions:** Power-user interfaces where speed matters more than simplicity. A code editor's command palette shows many options because the user is searching, not choosing. Reduce choices in consumer flows; preserve density in expert tools. See [`intent-match-context-fidelity`](intent-match-context-fidelity.md).

**Taste checkpoint:** After reducing actions, does the remaining set feel like a clear decision or a confusing pair? Sometimes reducing from 5 options to 2 creates a harder choice than the original 5 — because both remaining options seem equally valid. If that happens, you may need to rethink the interaction, not just the count.

Reference: Refactoring UI — "Hierarchy is Everything"
