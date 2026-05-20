---
title: Restrain Brand Color to Accents
impact: MEDIUM-HIGH
impactDescription: prevents an advertisement-like card
tags: design, branding, color, accents
---

## Restrain Brand Color to Accents

Use the host's surface and text colors for structure, and apply your brand only to buttons, badges, and small accents. Flooding the background with a brand color or dropping a logo banner into the response reads as advertising, fights the host's light and dark themes, and fails design review. The brand should be a tasteful accent, not the canvas.

**Incorrect (brand floods the surface and a logo banner dominates the card):**

```tsx
return (
  <div style={{ background: "#6d28d9", color: "#ffffff" }}>
    <img src={logo} height={48} alt="brand logo" />
    {body}
  </div>
);
```

**Correct (neutral host surface; brand only on the primary action):**

```tsx
return (
  <div style={{ background: "var(--surface)", color: "var(--text)" }}>
    {body}
    <button style={{ background: "#6d28d9", color: "#ffffff" }}>Reserve</button>
  </div>
);
```

Reference: [UI guidelines – Apps SDK](https://developers.openai.com/apps-sdk/concepts/ui-guidelines)
