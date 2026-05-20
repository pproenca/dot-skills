---
title: Respect Reduced-Motion Preferences
impact: MEDIUM
impactDescription: prevents motion-triggered discomfort
tags: design, motion, animation, accessibility
---

## Respect Reduced-Motion Preferences

Auto-playing carousels, parallax, and large transitions inside a chat are distracting and can cause discomfort or trigger vestibular conditions. Gate any non-essential animation behind `prefers-reduced-motion` and keep the remaining transitions short and subtle, so the widget stays calm next to a conversation the user is reading.

**Incorrect (motion always on; ignores the user's reduced-motion setting):**

```css
.carousel { animation: auto-advance 3s infinite; }
.row { transition: transform 600ms ease; }
```

**Correct (disable non-essential motion when the user asks for less):**

```css
@media (prefers-reduced-motion: reduce) {
  .carousel { animation: none; }
  .row { transition: none; }
}
```

Reference: [Design components – Apps SDK](https://developers.openai.com/apps-sdk/plan/components)
