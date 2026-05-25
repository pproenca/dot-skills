---
title: Choose font sizes from a small type scale
tags: type, typography, scale
---

## Choose font sizes from a small type scale

Picking sizes ad hoc produces many near-identical values (15px, 16px, 17px, 19px) that create no clear hierarchy and look accidental. Restrict yourself to a handful of distinct steps from a modular scale so headings, body, and captions read as separate levels.

**Incorrect (many arbitrary, barely-different sizes):**

```css
h1 { font-size: 29px; } h2 { font-size: 23px; } p { font-size: 15px; } small { font-size: 13px; }
```

**Correct (a few distinct steps from one scale):**

```css
h1 { font-size: 30px; } h2 { font-size: 20px; } p { font-size: 16px; } small { font-size: 14px; }
```

Reference: [Refactoring UI — Establishing a type scale](https://www.refactoringui.com/)
