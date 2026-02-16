---
title: Ensure 4.5:1 Contrast Ratio for Body Text
impact: HIGH
impactDescription: prevents inaccessible text by enforcing WCAG AA 4.5:1 minimum contrast ratio
tags: color, contrast, accessibility, wcag, a11y, empathy
---

Light gray text on white backgrounds looks elegant but fails accessibility. Body text needs 4.5:1 contrast ratio (WCAG AA). Large text (18px+ bold or 24px+ regular) needs 3:1.

**Contrast safety rules for Tailwind grays on white:**
- **gray-600 and darker** — safe for all text sizes, including `text-sm` (14px) and `text-xs` (12px)
- **gray-500** — passes WCAG AA but with minimal margin (~4.6:1). Use only for `text-base` (16px) or larger, or for bold text (`font-medium`+) at any size
- **gray-400 and lighter** — fails WCAG AA for body text. Use only for placeholder text, decorative elements, or disabled states

**Incorrect (gray-400 body text fails WCAG AA at ~2.9:1):**
```html
<div class="rounded-lg bg-white p-6">
  <h3 class="text-lg font-semibold text-gray-900">Payment Details</h3>
  <p class="mt-2 text-sm text-gray-400">Enter your card information below.</p>
  <label class="mt-4 block text-xs text-gray-400">Card Number</label>
  <input class="mt-1 rounded border px-3 py-2 placeholder:text-gray-300" placeholder="1234 5678 9012 3456" />
</div>
```

**Correct (accessible contrast — gray-600 for small text, gray-700 for labels):**
```html
<div class="rounded-lg bg-white p-6">
  <h3 class="text-lg font-semibold text-gray-900">Payment Details</h3>
  <p class="mt-2 text-sm text-gray-600">Enter your card information below.</p>
  <label class="mt-4 block text-xs font-medium text-gray-700">Card Number</label>
  <input class="mt-1 rounded-lg border px-3 py-2 placeholder:text-gray-400" placeholder="1234 5678 9012 3456" />
</div>
```

Accessibility is empathy. A user with low vision doesn't experience your elegant gray-400 text as "subtle" — they experience it as invisible. Caring about contrast ratios is not a compliance checkbox; it's proof that you designed for real people in real conditions.

**Taste checkpoint:** After setting text colors, squint at the screen. If any text disappears when you squint, it's too light for comfortable reading — even if it technically passes WCAG.

Reference: WCAG 2.1 — Success Criterion 1.4.3 Contrast (Minimum) · Ken Kocienda, Creative Selection — empathy means understanding the user's actual experience
