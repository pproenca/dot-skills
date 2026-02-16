---
title: Use Transitions to Acknowledge User Actions, Not to Decorate
impact: MEDIUM
impactDescription: replaces gratuitous animations with purposeful 150ms transitions that acknowledge user interaction
tags: system, transitions, motion, feedback, interaction
---

A 150ms shadow transition on hover says "I noticed you." A gratuitous 500ms fade-in says "look at me." Transitions should serve the user — acknowledging their action, confirming a state change, or guiding their attention — never decorating for its own sake. The iPhone keyboard that Ken Kocienda built spent enormous effort on touch feedback timing because responsiveness communicates respect for the user's time.

**Incorrect (decorative transitions that slow the user down):**
```html
<div class="space-y-4">
  <button class="transform rounded-lg bg-blue-600 px-4 py-2 text-white transition-all duration-500 hover:scale-110 hover:rotate-1 hover:shadow-xl">
    Save Changes
  </button>
  <div class="animate-pulse rounded-lg border p-4 transition-all duration-700 hover:border-blue-300 hover:bg-blue-50 hover:shadow-lg">
    <h3 class="font-semibold">Project Card</h3>
  </div>
</div>
```

**Correct (purposeful transitions that acknowledge interaction):**
```html
<div class="space-y-4">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white transition-colors duration-150 hover:bg-blue-700 active:bg-blue-800">
    Save Changes
  </button>
  <div class="cursor-pointer rounded-lg border border-gray-200 p-4 shadow-sm transition-shadow duration-150 hover:shadow-md">
    <h3 class="text-sm font-semibold text-gray-900">Project Card</h3>
  </div>
</div>
```

**Transition purpose guide:**
| Purpose | Property | Duration | Example |
|---------|----------|----------|---------|
| **Hover acknowledgment** | colors, shadow | 150ms | `transition-colors duration-150` |
| **State change** | background, border | 150-200ms | `transition-colors duration-200` |
| **Expanding content** | height, opacity | 200-300ms | `transition-all duration-200` |
| **Page-level entrance** | None — skip | 0ms | Content should appear instantly |

**When to skip transitions entirely:** Page loads, content refreshes, data table updates, and any context where the user is waiting. Making someone wait 300ms for a fade-in after they already waited 200ms for data to load doubles the perceived latency.

Reference: Ken Kocienda, Creative Selection — the iPhone keyboard's feedback timing was refined through hundreds of demo iterations
