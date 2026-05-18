---
title: Use Label.systemImage for SF Symbols, Label.icon for Custom Glyphs
impact: MEDIUM
impactDescription: enables correct icon layering — systemImage gets symbol effects, icon slot takes a full SwiftUI subview
tags: display, label, systemImage, icon
---

## Use Label.systemImage for SF Symbols, Label.icon for Custom Glyphs

`Label` accepts two ways to provide an icon: `systemImage` (a string SF Symbol name) or `icon` (a full React child). The string form gets all the SF Symbol affordances — symbol effects, Dynamic Type, variable colour. The `icon` slot is for cases where the icon is a custom image, a stylised glyph, or a composed view (e.g., an Image with a Badge overlay). Mixing the two by passing an `<Image>` child when `systemImage` would suffice loses the symbol affordances.

**Incorrect (passing Image where systemImage would do — loses symbol effects):**

```tsx
import { Host, Label, Image } from '@expo/ui/swift-ui';

<Host matchContents>
  <Label title="Inbox" icon={<Image systemName="tray.fill" />} />
</Host>
```

**Correct (systemImage — string SF Symbol gets all the affordances):**

```tsx
import { Host, Label } from '@expo/ui/swift-ui';

<Host matchContents>
  <Label title="Inbox" systemImage="tray.fill" />
</Host>
```

**Alternative (icon slot for a custom image not in the SF Symbol set):**

```tsx
import { Label, Image } from '@expo/ui/swift-ui';

<Label
  title="Slack channel"
  icon={<Image uiImage="file:///bundle/slack-logo.png" size={20} />}
/>
```

Reference: [@expo/ui Label source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Label/index.tsx)
