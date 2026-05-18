---
title: Prefer systemName SF Symbols Over Raster uiImage for Icons
impact: MEDIUM-HIGH
impactDescription: enables variable color, dynamic-type scaling, and symbol effects — uiImage is a synchronous main-thread file read
tags: display, image, sf-symbols, systemName
---

## Prefer systemName SF Symbols Over Raster uiImage for Icons

`Image.systemName` references the system SF Symbols catalogue: vector glyphs that scale with Dynamic Type, support variable colour for fill states, animate via symbol effects, and stay sharp on every display. `Image.uiImage` loads a file from disk synchronously on the main thread — it blocks layout and can't scale or animate. Use SF Symbols for every icon-style image; reserve `uiImage` for content imagery (photos, screenshots, branded illustrations).

**Incorrect (uiImage for an icon — main-thread read, no Dynamic Type, no symbol effects):**

```tsx
import { Host, Image } from '@expo/ui/swift-ui';

<Host matchContents>
  <Image uiImage="file:///path/to/heart-icon.png" size={24} />
</Host>
```

**Correct (systemName SF Symbol — vector, accessible, animatable):**

```tsx
import { Host, Image } from '@expo/ui/swift-ui';

<Host matchContents>
  <Image systemName="heart.fill" size={24} color="#FF3B30" />
</Host>
```

**Alternative (variable colour for partial fill — battery/signal indicators):**

```tsx
<Image systemName="battery.100" variableValue={0.4} size={20} />
```

Reference: [SF Symbols catalogue](https://developer.apple.com/sf-symbols/)
