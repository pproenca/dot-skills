---
title: Avoid Nesting glassEffect Inside Already-Glass Surfaces
impact: CRITICAL
impactDescription: prevents broken material rendering — stacked glass produces opaque or visually muddy artefacts
tags: hig, glass, liquid-glass, materials
---

## Avoid Nesting glassEffect Inside Already-Glass Surfaces

iOS 26 toolbars, tab bars, and sheet chrome already use Liquid Glass material. Applying `glassEffect()` to content placed *inside* a glass surface (a toolbar button, a sheet's contents) compounds the material — the resulting render is opaque, loses transparency, and breaks the visual depth Apple's design system encodes. Apple's HIG explicitly limits Liquid Glass to the floating control layer; content beneath should use fills, vibrancy, or plain backgrounds.

**Incorrect (sheet content with glass-on-glass — opaque, broken):**

```tsx
import { Host, BottomSheet, Group, Button } from '@expo/ui/swift-ui';
import { glassEffect } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <BottomSheet isPresented onIsPresentedChange={setOpen}>
    <Group modifiers={[glassEffect()]}>
      <Button label="Confirm" onPress={confirm} />
    </Group>
  </BottomSheet>
</Host>
```

**Correct (sheet chrome owns the glass — content uses a plain Group):**

```tsx
import { Host, BottomSheet, Group, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <BottomSheet isPresented onIsPresentedChange={setOpen}>
    <Group>
      <Button label="Confirm" onPress={confirm} />
    </Group>
  </BottomSheet>
</Host>
```

**When NOT to use this pattern:**

- When deliberately layering a separate floating glass control over a glass toolbar (e.g., a floating action button above a tab bar). The two glass surfaces are distinct layers, not nested.

Reference: [Adopting Liquid Glass | Apple](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)
