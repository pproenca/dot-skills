---
title: Ensure 4.5:1 Contrast Ratio for Body Text
impact: HIGH
impactDescription: prevents inaccessible text that 15% of users struggle to read
tags: color, contrast, accessibility, wcag, a11y
---

Light gray text on white backgrounds looks elegant but fails accessibility. Body text needs 4.5:1 contrast ratio (WCAG AA). Large text (18px+ bold or 24px+ regular) needs 3:1. Never use gray lighter than gray-500 for body text on white.

**Incorrect (gray-400 body text fails WCAG AA at ~3.5:1):**
```html
<div class="rounded-lg bg-white p-6">
  <h3 class="text-lg font-semibold text-gray-900">Payment Details</h3>
  <p class="mt-2 text-sm text-gray-400">Enter your card information below.</p>
  <label class="mt-4 block text-xs text-gray-400">Card Number</label>
  <input class="mt-1 rounded border px-3 py-2 placeholder:text-gray-300" placeholder="1234 5678 9012 3456" />
</div>
```

**Correct (accessible contrast ratios):**
```html
<div class="rounded-lg bg-white p-6">
  <h3 class="text-lg font-semibold text-gray-900">Payment Details</h3>
  <p class="mt-2 text-sm text-gray-600">Enter your card information below.</p>
  <label class="mt-4 block text-xs font-medium text-gray-700">Card Number</label>
  <input class="mt-1 rounded-lg border px-3 py-2 placeholder:text-gray-400" placeholder="1234 5678 9012 3456" />
</div>
```

Reference: WCAG 2.1 — Success Criterion 1.4.3 Contrast (Minimum)
