---
title: Upgrade Radio Buttons to Selectable Cards for Key Choices
impact: LOW-MEDIUM
impactDescription: enables 2 to 5 selection options to include descriptions and visual emphasis via selectable cards
tags: sep, forms, radio-buttons, cards, selection, upgrade
---

When options are important to the user's decision, consider upgrading standard radio buttons into selectable cards. Cards give each option more visual real estate and let you include descriptions. This works for pricing tiers, plan selection, and feature toggles — but is not a universal replacement for radio buttons.

**Incorrect (plain radio buttons for a high-stakes choice like pricing):**
```html
<fieldset class="space-y-2">
  <label class="flex items-center gap-2">
    <input type="radio" name="plan" value="basic" />
    <span class="text-sm">Basic — $9/mo</span>
  </label>
  <label class="flex items-center gap-2">
    <input type="radio" name="plan" value="pro" />
    <span class="text-sm">Pro — $29/mo</span>
  </label>
  <label class="flex items-center gap-2">
    <input type="radio" name="plan" value="enterprise" />
    <span class="text-sm">Enterprise — $99/mo</span>
  </label>
</fieldset>
```

**Correct (selectable cards give each option visual weight and descriptions):**
```html
<fieldset class="grid gap-3 sm:grid-cols-3">
  <label class="cursor-pointer rounded-lg border-2 border-transparent bg-white p-4 shadow-sm ring-1 ring-gray-200 has-[:checked]:border-blue-600 has-[:checked]:ring-blue-600">
    <input type="radio" name="plan" value="basic" class="sr-only" />
    <span class="text-sm font-semibold text-gray-900">Basic</span>
    <p class="mt-1 text-2xl font-bold text-gray-900">$9<span class="text-sm font-normal text-gray-500">/mo</span></p>
    <p class="mt-2 text-xs text-gray-500">For individuals getting started</p>
  </label>
  <!-- repeat pattern for Pro, Enterprise -->
</fieldset>
```

**When to use cards:** The choice is prominent (pricing, plan selection), there are 2-5 options, and each option benefits from a description.

**When to keep standard radios:** Long option lists (6+), settings pages, mobile forms with limited space, or any context where compact layout matters more than visual emphasis.

Reference: Refactoring UI — "Finishing Touches"
