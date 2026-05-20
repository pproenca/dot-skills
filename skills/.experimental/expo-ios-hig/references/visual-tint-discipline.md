---
title: Reserve the accent tint for interactive elements
impact: MEDIUM
impactDescription: preserves a single, meaningful accent color
tags: visual, tint, color, hierarchy
---

## Reserve the accent tint for interactive elements

On iOS the tint color is a signal: it tells the user "this is tappable." When the accent color is also sprayed across static labels, backgrounds, and icons that do nothing, that signal disappears and users can no longer tell what is interactive. Reserve the brand tint for controls and links, use `systemRed` for destructive actions, and let static content rest on label and secondary-label colors.

**Incorrect (accent color on non-interactive content):**

```tsx
import { View, Text } from 'react-native';

// Tinting a static heading the same blue as buttons implies it's tappable
function TrailSectionHeader({ title }: { title: string }) {
  return (
    <View>
      <Text style={{ color: '#007aff' }}>{title}</Text>
    </View>
  );
}
```

**Correct (tint only on interactive elements):**

```tsx
import { View, Text, Pressable, PlatformColor } from 'react-native';

// Static heading uses the label color; tint is reserved for the action
function TrailSectionHeader({ title }: { title: string }) {
  return (
    <View>
      <Text style={{ color: PlatformColor('label') }}>{title}</Text>
      <Pressable onPress={seeAll}>
        <Text style={{ color: PlatformColor('systemBlue') }}>See all</Text>
      </Pressable>
    </View>
  );
}
```

Reference: [Apple HIG — Color](https://developer.apple.com/design/human-interface-guidelines/color)
