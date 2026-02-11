---
title: Convert Radio Buttons and Checkboxes to Selectable Cards
impact: LOW-MEDIUM
impactDescription: makes selection options more visually prominent and scannable
tags: sep, forms, radio-buttons, cards, selection, upgrade
---

When options are important to the user's decision, convert standard radio buttons into selectable cards. Cards give each option more visual real estate and let you include descriptions. This is especially useful for pricing tiers, plan selection, and feature toggles.

**Incorrect (plain radio buttons):**
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

**Correct (selectable cards):**
```html
<fieldset class="grid gap-3 sm:grid-cols-3">
  <label class="cursor-pointer rounded-lg border-2 border-transparent bg-white p-4 shadow-sm ring-1 ring-gray-200 has-[:checked]:border-blue-600 has-[:checked]:ring-blue-600">
    <input type="radio" name="plan" value="basic" class="sr-only" />
    <span class="text-sm font-semibold text-gray-900">Basic</span>
    <p class="mt-1 text-2xl font-bold text-gray-900">$9<span class="text-sm font-normal text-gray-500">/mo</span></p>
    <p class="mt-2 text-xs text-gray-500">For individuals getting started</p>
  </label>
  <label class="cursor-pointer rounded-lg border-2 border-transparent bg-white p-4 shadow-sm ring-1 ring-gray-200 has-[:checked]:border-blue-600 has-[:checked]:ring-blue-600">
    <input type="radio" name="plan" value="pro" class="sr-only" />
    <span class="text-sm font-semibold text-gray-900">Pro</span>
    <p class="mt-1 text-2xl font-bold text-gray-900">$29<span class="text-sm font-normal text-gray-500">/mo</span></p>
    <p class="mt-2 text-xs text-gray-500">For growing teams</p>
  </label>
  <label class="cursor-pointer rounded-lg border-2 border-transparent bg-white p-4 shadow-sm ring-1 ring-gray-200 has-[:checked]:border-blue-600 has-[:checked]:ring-blue-600">
    <input type="radio" name="plan" value="enterprise" class="sr-only" />
    <span class="text-sm font-semibold text-gray-900">Enterprise</span>
    <p class="mt-1 text-2xl font-bold text-gray-900">$99<span class="text-sm font-normal text-gray-500">/mo</span></p>
    <p class="mt-2 text-xs text-gray-500">For large organizations</p>
  </label>
</fieldset>
```

**When NOT to use this pattern:**
- Long option lists (6+ items) — standard radios are more compact
- Settings pages where space is at a premium
- Mobile forms where vertical space is limited

Reference: Refactoring UI — "Finishing Touches"
