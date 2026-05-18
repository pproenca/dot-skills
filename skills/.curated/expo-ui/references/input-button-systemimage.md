---
title: Use systemImage for Button Icons — SF Symbols Scale and Adapt Automatically
impact: HIGH
impactDescription: enables Dynamic Type scaling, dark mode adaptation, and symbol effect support — prevents pixelation on Retina displays
tags: input, button, systemImage, sf-symbols
---

## Use systemImage for Button Icons — SF Symbols Scale and Adapt Automatically

`Button.systemImage` accepts an SF Symbol name (`"heart"`, `"square.and.arrow.up"`, etc.). SF Symbols are vector glyphs that scale to Dynamic Type sizes, adapt their fill/outline to the system, animate via symbol effects, and stay sharp at every resolution. Embedding a raster PNG via `children` or a custom `Image` bypasses all of that — the icon misaligns at large Dynamic Type, and accessibility settings can't influence it.

**Incorrect (raster PNG inside Button — no Dynamic Type, no symbol effects):**

```tsx
import { Host, Button, Image } from 'react-native';
import { Button as UIButton, Host as UIHost } from '@expo/ui/swift-ui';

<UIHost matchContents>
  <UIButton onPress={share}>
    <Image source={require('./assets/share-icon.png')} style={{ width: 22, height: 22 }} />
  </UIButton>
</UIHost>
```

**Correct (systemImage — SF Symbol scales with text and supports effects):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <Button label="Share" systemImage="square.and.arrow.up" onPress={share} />
</Host>
```

**Alternative (icon-only button via labelStyle modifier):**

```tsx
import { Button } from '@expo/ui/swift-ui';
import { labelStyle } from '@expo/ui/swift-ui/modifiers';

<Button
  label="Share"
  systemImage="square.and.arrow.up"
  onPress={share}
  modifiers={[labelStyle('iconOnly')]}
/>
```

Reference: [SF Symbols](https://developer.apple.com/sf-symbols/)
