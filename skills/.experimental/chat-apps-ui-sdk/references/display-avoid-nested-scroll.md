---
title: Avoid Nested Scroll Inside Inline Cards
impact: MEDIUM-HIGH
impactDescription: prevents scroll traps in the conversation
tags: display, scroll, layout, ux
---

## Avoid Nested Scroll Inside Inline Cards

The chat transcript already scrolls and the iframe grows to its reported content height, so an inner `overflow: auto` container creates a scroll trap: the user's wheel or trackpad gesture gets captured by the inner box and the conversation stops scrolling. Let an inline card grow to fit its content and reserve internal scrolling for fullscreen, where the widget owns the whole surface.

**Incorrect (inner scroll container traps the wheel inside the transcript):**

```css
.results { max-height: 300px; overflow-y: auto; }
```

**Correct (let the card grow; the transcript handles scrolling):**

```css
.results { height: auto; } /* reserve overflow:auto for fullscreen mode only */
```

A horizontally-scrolling carousel is a deliberate exception — horizontal gestures do not fight the vertical transcript.

Reference: [UI guidelines – Apps SDK](https://developers.openai.com/apps-sdk/concepts/ui-guidelines)
