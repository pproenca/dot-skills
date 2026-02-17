---
title: Use Selectable Cards Only for High-Stakes Radio Choices
impact: LOW
impactDescription: keeps radio controls compact by default and introduces card-style options only when decision context requires extra explanation
tags: sep, forms, radio-buttons, cards, selection, simplify
---

Standard radios are the default. Only upgrade to selectable cards when the choice is high-stakes, there are very few options, and each option needs supporting detail. Card styling on routine settings adds visual noise and too many boxes.

**Incorrect (card-ifying a routine settings choice):**
```html
<fieldset class="grid gap-3">
  <label class="cursor-pointer rounded-lg border bg-white p-4 shadow-sm">
    <input type="radio" name="email-frequency" value="daily" class="sr-only" />
    <span class="text-sm font-semibold">Daily summary</span>
    <p class="mt-1 text-xs text-gray-500">Get one email every day</p>
  </label>
  <label class="cursor-pointer rounded-lg border bg-white p-4 shadow-sm">
    <input type="radio" name="email-frequency" value="weekly" class="sr-only" />
    <span class="text-sm font-semibold">Weekly summary</span>
    <p class="mt-1 text-xs text-gray-500">Get one email every week</p>
  </label>
</fieldset>
```

**Correct (keep routine choices compact):**
```html
<fieldset class="space-y-2">
  <label class="flex items-center gap-2">
    <input type="radio" name="email-frequency" value="daily" />
    <span class="text-sm text-gray-700">Daily summary</span>
  </label>
  <label class="flex items-center gap-2">
    <input type="radio" name="email-frequency" value="weekly" />
    <span class="text-sm text-gray-700">Weekly summary</span>
  </label>
</fieldset>
```

**Use cards only when all are true:** The choice is prominent (e.g., plan/pricing), there are 2-5 options, and each option needs meaningful explanatory text.

**Keep standard radios for everything else:** settings pages, long option lists (6+), dense mobile forms, and any context where speed/scannability matters.

**If unsure:** choose standard radios.

Reference: Refactoring UI — "Finishing Touches"
