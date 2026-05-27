---
title: Size touch targets to at least 44px
tags: resp, touch, accessibility
---

## Size touch targets to at least 44px

Icon buttons sized to the icon itself (often 20–24px) are easy to miss with a finger and frustrating on phones. Give interactive controls a hit area of at least 44×44px by padding the target out, without necessarily enlarging the visible icon.

```css
.icon-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 44px;
  min-height: 44px; /* finger-friendly hit area around a 20px icon */
}
```

Reference: [Apple HIG — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
