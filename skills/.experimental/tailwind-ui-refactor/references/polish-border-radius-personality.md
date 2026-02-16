---
title: Choose Your Border Radius With Conviction and Apply It Everywhere
impact: MEDIUM
impactDescription: eliminates 3-4 conflicting border-radius values per page by establishing one consistent radius token
tags: polish, border-radius, personality, branding, consistency, conviction
---

Border radius is a brand voice decision, not a finishing touch. It should be made in the first 10 minutes of a project, documented, and defended. No radius = serious/formal (Bloomberg). Small radius = professional/neutral (Linear). Large radius = playful/friendly (Notion). Consistent rounded-none has more personality than inconsistent rounded-lg. Design with conviction.

**Incorrect (inconsistent border radius — no conviction):**
```html
<div class="space-y-4">
  <button class="rounded-full bg-blue-600 px-4 py-2 text-white">Submit</button>
  <div class="rounded border p-4">Card content</div>
  <input class="rounded-lg border px-3 py-2" />
  <span class="rounded-none bg-green-100 px-2 py-1 text-green-700">Badge</span>
</div>
```

**Correct (consistent radius — clear brand voice):**
```html
<div class="space-y-4">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Submit</button>
  <div class="rounded-lg border p-4">Card content</div>
  <input class="rounded-lg border px-3 py-2" />
  <span class="rounded-lg bg-green-100 px-2 py-1 text-xs font-medium text-green-700">Badge</span>
</div>
```

**The conviction test:** Can you explain *why* you chose this radius? "rounded-lg because our product is approachable but professional" is conviction. "rounded-lg because it's the default" is not. If you can't articulate the reason, you haven't made a design decision — you've made a default.

**Taste checkpoint:** After setting your radius, apply it to 5 different component types (button, card, input, badge, modal). If it looks wrong on any of them, you may need a two-tier system (e.g., rounded-lg for containers, rounded for small elements) — but never more than two tiers.

Reference: Refactoring UI — "Starting from Scratch" · John Edson, Design Like Apple — Principle 7: "Design With Conviction"
