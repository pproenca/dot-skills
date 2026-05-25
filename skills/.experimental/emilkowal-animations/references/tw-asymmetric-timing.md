---
title: Split Press and Release Timing with active:duration in Tailwind v4
impact: MEDIUM
impactDescription: the release runs ~10× faster than a deliberate 2s confirm press, so the control resets instantly when the user lets go
tags: tw, tailwind, timing, duration, active, asymmetric
---

## Split Press and Release Timing with active:duration in Tailwind v4

Press and release often want different speeds. A hold-to-confirm control should fill slowly so the action feels deliberate, then reset instantly the moment the pointer lifts. A single `duration-*` makes the release as sluggish as the press. Apply the slow duration only while pressed with the `active:` variant; the base duration handles the fast release.

**Incorrect (symmetric duration—slow to reset):**

```tsx
// 2s on the way in AND on the way out: release feels broken
<button className="transition-[clip-path] duration-[2000ms] ease-out">
  Hold to delete
</button>
```

**Correct (slow press, fast release):**

```tsx
// active: applies 2s while held; base 200ms snaps it back on release
<button className="transition-[clip-path] ease-out duration-200 active:duration-[2000ms]">
  Hold to delete
</button>
```

**Notes:**
- The same split works with `data-*` state variants when the open/close state is JS-driven, e.g. `duration-200 data-[open]:duration-500`.

Reference: [Building a Hold to Delete Component](https://emilkowal.ski/ui/building-a-hold-to-delete-component)
