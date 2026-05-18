---
title: Guard iOS 26-Only Features With a Platform Version Check
impact: MEDIUM
impactDescription: prevents runtime crashes on iOS 17/18/19 — features like glassEffect, tabBarMinimizeBehavior are 26-only
tags: state, platform, ios-26, availability
---

## Guard iOS 26-Only Features With a Platform Version Check

`@expo/ui` JSDoc annotates platform availability per modifier and prop: `@platform ios 17.0+`, `@platform ios 18.0+`, and iOS 26 surface for Liquid Glass and tab-bar accessory APIs. On older iOS versions, those modifiers either no-op or throw depending on the underlying SwiftUI signature. Guard with React Native's `Platform.Version` check before applying.

**Incorrect (glassEffect on iOS 19 device — modifier no-ops, no fallback):**

```tsx
import { Host, Image } from '@expo/ui/swift-ui';
import { glassEffect } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Image systemName="play.fill" modifiers={[glassEffect()]} />
</Host>
```

**Correct (apply glass only on iOS 26+):**

```tsx
import { Platform } from 'react-native';
import { Host, Image } from '@expo/ui/swift-ui';
import { glassEffect, background, cornerRadius } from '@expo/ui/swift-ui/modifiers';

const isIOS26 = Platform.OS === 'ios' && parseInt(String(Platform.Version), 10) >= 26;

<Host matchContents>
  <Image
    systemName="play.fill"
    modifiers={isIOS26 ? [glassEffect()] : [background('#1C1C1E'), cornerRadius(8)]}
  />
</Host>
```

**Alternative (TextField selection prop requires iOS 18+ — gate the prop, not just the modifier):**

```tsx
const supportsSelection = parseInt(String(Platform.Version), 10) >= 18;
const selection = supportsSelection ? selectionState : undefined;

<TextField text={text} selection={selection} />
```

Reference: [@expo/ui JSDoc @platform annotations](https://github.com/expo/expo/tree/main/packages/expo-ui/src/swift-ui)
