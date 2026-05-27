---
title: Align multi-line text to the left
tags: type, alignment, readability
---

## Align multi-line text to the left

Centring is the default reach for "tidy", but a centred paragraph gives every line a different starting edge, so the eye has to hunt for where the next line begins. Left-align anything longer than two lines; reserve centring for short, isolated text such as a single heading.

**Incorrect (centred paragraph with a ragged left edge):**

```css
.empty-state__description { text-align: center; max-width: 60ch; }
```

**Correct (left-aligned body; centre only the short heading):**

```css
.empty-state__title { text-align: center; }
.empty-state__description { text-align: left; max-width: 60ch; }
```

Reference: [Butterick — Centered text](https://practicaltypography.com/centered-text.html)
