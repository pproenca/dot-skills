---
title: Meet WCAG AA Contrast and Provide Alt Text
impact: MEDIUM-HIGH
impactDescription: prevents accessibility review failures
tags: design, accessibility, contrast, wcag
---

## Meet WCAG AA Contrast and Provide Alt Text

Widgets must clear WCAG AA contrast, carry alt text on meaningful images, expose visible keyboard focus, and survive text resizing — both for real usability and because accessibility gaps block approval. The usual offenders are pale gray captions on white and icon-only buttons with no accessible label, which are invisible to low-vision and screen-reader users.

**Incorrect (low-contrast caption and an unlabeled icon button):**

```tsx
<span style={{ color: "#bbbbbb" }}>Departs 09:40</span>
<button><StarIcon /></button>
```

**Correct (AA-contrast text, a labeled control, and a visible focus ring):**

```tsx
<span style={{ color: "var(--text-secondary)" }}>Departs 09:40</span>
<button aria-label="Save flight" className="focus-ring"><StarIcon /></button>
```

Reference: [UI guidelines – Apps SDK](https://developers.openai.com/apps-sdk/concepts/ui-guidelines)
