---
title: Wrap Multiple Glass Siblings in a GlassEffectContainer
impact: CRITICAL
impactDescription: enables Liquid Glass siblings to morph and blend as one shape, prevents per-element pipeline cost
tags: hig, glass, liquid-glass, ios-26, container
---

## Wrap Multiple Glass Siblings in a GlassEffectContainer

iOS 26 Liquid Glass material is designed to blend across adjacent shapes — two glass buttons close together should fuse into one shape as the user interacts. SwiftUI achieves this with `GlassEffectContainer`, which groups its glass children so they share a morph pass. Applying `glassEffect()` to siblings without a container forces each to run an independent shader pass and skips the morphing animation entirely.

**Incorrect (siblings render as isolated glass shapes — no morphing, higher GPU cost):**

```tsx
import { Host, HStack, Image } from '@expo/ui/swift-ui';
import { glassEffect } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <HStack spacing={8}>
    <Image systemName="play.fill" modifiers={[glassEffect()]} />
    <Image systemName="pause.fill" modifiers={[glassEffect()]} />
    <Image systemName="forward.fill" modifiers={[glassEffect()]} />
  </HStack>
</Host>
```

**Correct (container groups the glass shapes for morphing):**

```tsx
import { Host, GlassEffectContainer, HStack, Image } from '@expo/ui/swift-ui';
import { glassEffect } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <GlassEffectContainer spacing={8}>
    <HStack spacing={8}>
      <Image systemName="play.fill" modifiers={[glassEffect()]} />
      <Image systemName="pause.fill" modifiers={[glassEffect()]} />
      <Image systemName="forward.fill" modifiers={[glassEffect()]} />
    </HStack>
  </GlassEffectContainer>
</Host>
```

**When NOT to use this pattern:**

- For a single isolated glass element. The container only matters when glass shapes need to blend.

Reference: [GlassEffectContainer | SwiftUI](https://developer.apple.com/documentation/swiftui/glasseffectcontainer)
