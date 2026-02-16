---
title: Line Height and Font Size Are Inversely Proportional
impact: HIGH
impactDescription: prevents cramped headings and spacey body text with leading-tight (2xl+) and leading-relaxed (sm)
tags: type, line-height, leading, headings, body-text
---

Large text (headings) needs tighter line height (1.0-1.25). Small text (body) needs looser line height (1.5-1.75). Using the same line height for all text sizes creates cramped body text or spacey headings.

**Incorrect (same line height for all sizes):**
```html
<div class="space-y-4 leading-normal">
  <h1 class="text-4xl font-bold">Dashboard Overview</h1>
  <h2 class="text-2xl font-semibold">Recent Activity</h2>
  <p class="text-sm text-gray-600">Your recent activity is shown below. Click on any item to see more details about the activity and any related information.</p>
</div>
```

**Correct (line height inversely proportional to size):**
```html
<div class="space-y-4">
  <h1 class="text-4xl font-bold leading-tight">Dashboard Overview</h1>
  <h2 class="text-2xl font-semibold leading-snug">Recent Activity</h2>
  <p class="text-sm leading-relaxed text-gray-600">Your recent activity is shown below. Click on any item to see more details about the activity and any related information.</p>
</div>
```

**Taste checkpoint:** After setting line heights, read a multi-line heading and a body paragraph aloud. If the heading lines feel like separate elements instead of one phrase, the line-height is too loose. If the body paragraph feels cramped, it's too tight.

Reference: Refactoring UI — "Designing Text"
