---
title: Keep Line Length Between 45-75 Characters
impact: HIGH
impactDescription: prevents eye-strain from lines that are too long or too short
tags: type, line-length, readability, max-width, prose
---

Lines longer than 75 characters force the eye to travel too far, causing readers to lose their place. Lines shorter than 45 characters create too many line breaks. Use max-width to constrain paragraph widths.

**Incorrect (text spans full container width):**
```html
<div class="px-6">
  <p class="text-base text-gray-600">This paragraph of text stretches all the way across the container, making it incredibly hard to read because your eyes have to travel such a long distance from the end of one line to the beginning of the next line, and you often lose your place in the process.</p>
</div>
```

**Correct (constrained to comfortable reading width):**
```html
<div class="px-6">
  <p class="max-w-prose text-base leading-relaxed text-gray-600">This paragraph of text is constrained to a comfortable reading width, making it easy to follow from one line to the next without losing your place.</p>
</div>
```

Note: Tailwind's `max-w-prose` sets max-width to 65ch, which is the ideal reading width.

**Taste checkpoint:** After setting max-width for text, read a full paragraph at the constrained width. Does your eye flow naturally to the next line? If you frequently lose your place, the column is too wide. If it feels choppy, it's too narrow.

Reference: Refactoring UI — "Designing Text"
