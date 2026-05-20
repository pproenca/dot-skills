---
title: Collapse Layout Gracefully on Small Screens
impact: MEDIUM-HIGH
impactDescription: maintains usability on mobile widths
tags: display, responsive, breakpoints, mobile
---

## Collapse Layout Gracefully on Small Screens

The same widget renders in a wide desktop panel and a narrow mobile sheet, so a fixed multi-column layout overflows and gets clipped on phones. Set a max width and use breakpoints (or intrinsic CSS grid) so columns stack instead of overflowing, and keep the primary action inside the safe area where the user can reach it.

**Incorrect (fixed three-column width overflows the mobile sheet):**

```tsx
return <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 240px)" }}>{cards}</div>;
```

**Correct (auto-fit columns collapse to one on narrow widths):**

```tsx
return (
  <div style={{ display: "grid", gap: 12, gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))" }}>
    {cards}
  </div>
);
```

Test at both extremes; a layout that looks balanced on desktop frequently breaks at the mobile width the host uses on phones.

Reference: [Design components – Apps SDK](https://developers.openai.com/apps-sdk/plan/components)
