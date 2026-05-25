---
title: Pair colour with a second cue for state
tags: color, accessibility, feedback
---

## Pair colour with a second cue for state

Communicating status with colour alone — a red border for an error, green for success — is invisible to colour-blind users and to anyone who misses the hue. Pair colour with text or an icon so the meaning survives without it.

**Incorrect (colour is the only error signal):**

```tsx
<input className="border border-red-500" />
```

**Correct (an icon and message carry the meaning too):**

```tsx
<input aria-invalid className="border border-red-500" />
<p className="text-red-700 flex items-center gap-1">
  <AlertCircleIcon aria-hidden /> Enter a valid email address
</p>
```

Reference: [WCAG 2.2 — Use of Color 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)
