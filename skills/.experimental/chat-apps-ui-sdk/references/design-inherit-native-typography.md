---
title: Inherit Native Fonts and Limit Type Sizes
impact: MEDIUM-HIGH
impactDescription: prevents a foreign, embedded-page look
tags: design, typography, fonts, native
---

## Inherit Native Fonts and Limit Type Sizes

An app that ships a custom web font and a dozen type sizes reads as a foreign page pasted into the chat. Inherit the host font stack, keep to body and body-small sizes, and avoid decorative gradients so the widget reads as part of the conversation rather than an advertisement. Restraint here is what makes a chat app feel native.

**Incorrect (custom font, many sizes, and a gradient make the card look like an ad):**

```css
.card { font-family: "Pacifico", cursive; background: linear-gradient(#f0f, #0ff); }
.title { font-size: 28px; }
.meta { font-size: 9px; }
```

**Correct (inherit the host type, keep two readable sizes, flat surface):**

```css
.card { font: inherit; background: var(--surface); }
.title { font-size: var(--text-body); font-weight: 600; }
.meta { font-size: var(--text-body-sm); }
```

Reference: [UI guidelines – Apps SDK](https://developers.openai.com/apps-sdk/concepts/ui-guidelines)
