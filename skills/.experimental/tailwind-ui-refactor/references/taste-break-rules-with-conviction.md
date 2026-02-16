---
title: Break Rules When Breaking Them Better Serves the User
impact: CRITICAL
impactDescription: prevents generic "rule-following" UI by teaching deliberate, justified rule-breaking
tags: taste, conviction, judgment, rules, override
---

Every rule in this skill is a default, not an absolute. A rule should be broken when breaking it better serves the user's task or emotional state. But rule-breaking requires conviction — you must be able to articulate *why* the deviation serves the user, not just that you prefer it.

**Incorrect (following rules mechanically — technically correct but emotionally tone-deaf):**
```html
<div class="mx-auto max-w-md p-8 text-center">
  <h1 class="text-2xl font-bold text-gray-900">Payment Failed</h1>
  <p class="mt-2 text-sm text-gray-500">Your card was declined. Please try a different payment method.</p>
  <button class="mt-6 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Try Again</button>
</div>
```

**Correct (breaking rules with conviction — serves the user's emotional state):**
```html
<div class="mx-auto max-w-md rounded-xl bg-amber-50 p-10 text-center">
  <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-amber-100">
    <svg class="h-6 w-6 text-amber-600"><!-- warning icon --></svg>
  </div>
  <h1 class="mt-4 text-xl font-semibold text-gray-900">Payment didn't go through</h1>
  <p class="mt-2 text-sm text-gray-700">No worries — your items are saved. Try a different card or payment method.</p>
  <button class="mt-6 rounded-lg bg-amber-600 px-6 py-2.5 text-sm font-medium text-white">Try Another Method</button>
  <p class="mt-3 text-xs text-gray-500">Need help? Contact support</p>
</div>
```

The second version breaks several rules: the background is colored (not grayscale-first), the text uses gray-700 instead of gray-500 for secondary content, and the icon circle adds decorative markup. But every deviation serves the user: warm amber reduces anxiety, higher-contrast secondary text is easier to read when stressed, the icon provides visual anchoring, and "No worries" acknowledges their emotional state.

**The conviction test:** Can you complete this sentence? "I'm breaking [rule] because [specific user benefit]." If you can't, follow the rule.

Reference: John Edson, Design Like Apple — Principle 7: "Design With Conviction: Commit to a unique voice"
