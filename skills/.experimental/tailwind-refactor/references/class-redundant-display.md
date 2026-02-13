---
title: Remove Redundant Display Classes
impact: HIGH
impactDescription: reduces unnecessary class noise
tags: class, redundant, display, flex, grid
---

## Remove Redundant Display Classes

Several commonly used utility combinations include classes that simply restate the CSS default for that display mode. Removing these redundant classes reduces markup noise without changing any visual output. Common redundant defaults include: `flex-row` (default flex direction), `flex-nowrap` (default wrap behavior), `grid-cols-1` (default single column), `items-stretch` (default align-items), `justify-start` (default justify-content), and `text-left` (default text alignment in LTR).

**Incorrect (what's wrong):**

```html
<div class="flex flex-row">Side by side</div>
<div class="flex flex-nowrap">No wrap</div>
<div class="grid grid-cols-1">Single column</div>
<div class="flex items-stretch">Stretched items</div>
<div class="flex justify-start">Left-aligned items</div>
```

**Correct (what's right):**

```html
<div class="flex">Side by side</div>
<div class="flex">No wrap</div>
<div class="grid">Single column</div>
<div class="flex">Stretched items</div>
<div class="flex">Left-aligned items</div>
```

**When NOT to use this pattern:**
- Only remove these classes when they appear **without** a variant prefix
- Classes like `md:flex-row`, `lg:items-stretch`, `hover:justify-start`, `rtl:text-left` serve a real purpose as responsive or conditional overrides and must be kept
- Example: `flex flex-col md:flex-row` — `md:flex-row` is NOT redundant here
