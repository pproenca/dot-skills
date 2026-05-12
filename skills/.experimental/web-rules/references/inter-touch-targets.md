---
title: Maintain 44×44 px Minimum Touch Targets (WCAG 2.5.5)
impact: CRITICAL
impactDescription: Touch targets below 44×44 px cause 15-40% mis-tap rate on mobile (MIT Touch Lab + Apple HIG); WCAG 2.2 AA requires 24×24 minimum, AAA requires 44×44
tags: inter, touch-targets, hit-area, mobile, wcag-2-5-5
---

## Maintain 44×44 px Minimum Touch Targets (WCAG 2.5.5)

Every interactive element must have a hit area of at least 44×44 CSS pixels, even when the visible affordance is smaller. Use padding (or `min-h-11 min-w-11` in Tailwind 4 — `h-11` = 44 px) to expand the hit area without changing the visual size. Inline icon buttons in dense lists are the most common offender; wrap them in a `<button>` with the required size.

**Incorrect (icon button has only ~16×16 px hit area):**

```tsx
<button onClick={onClose} className="text-muted-foreground">
  <X className="size-4" />
</button>
```

**Correct (icon button has 44×44 px hit area while staying visually compact):**

```tsx
<button
  onClick={onClose}
  aria-label="Close"
  className="inline-flex size-11 items-center justify-center rounded-md text-muted-foreground hover:bg-accent focus-visible:outline-2 focus-visible:outline-ring"
>
  <X className="size-4" />
</button>
```

**Common patterns:**

```tsx
// shadcn/ui Button with size="icon" already uses size-9 (36px) — bump to size="icon-lg"
<Button size="icon" className="size-11">
  <Plus className="size-4" />
</Button>

// Checkbox row — entire label is the hit area
<label className="flex min-h-11 items-center gap-3 px-3 cursor-pointer">
  <Checkbox checked={selected} onCheckedChange={setSelected} />
  <span>{label}</span>
</label>
```

**Rule:**
- `min-h-11 min-w-11` (44 px) on every standalone interactive control
- Adjacent targets need ≥ 8 px gap so users can hit each without misfire
- Hit area > visual area is fine — use transparent padding, not visible margin
- Verify with the Chrome DevTools "Tap targets" Lighthouse audit before shipping

Reference: [WCAG 2.5.5 Target Size (Enhanced)](https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html)
