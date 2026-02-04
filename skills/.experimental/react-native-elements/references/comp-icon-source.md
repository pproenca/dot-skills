---
title: Choose Icon Type Prop Wisely
impact: HIGH
impactDescription: 50KB-2MB bundle size difference depending on library choice
tags: comp, icons, performance, bundle-size
---

## Choose Icon Type Prop Wisely

The Icon component supports multiple icon libraries through the type prop, but each library has drastically different bundle sizes. MaterialIcons (~100KB) is included with Expo by default, while FontAwesome5 can add 2MB+. Choose the smallest library that covers your icon needs to avoid bundle bloat.

**Incorrect (using heavy icon library for few icons):**

```tsx
// Bad: FontAwesome5 Pro adds ~2MB for just a few icons
import { Icon } from '@rneui/themed';

const Navigation = () => (
  <View>
    {/* Using font-awesome-5 for basic icons available in smaller libraries */}
    <Icon name="home" type="font-awesome-5" />
    <Icon name="user" type="font-awesome-5" />
    <Icon name="cog" type="font-awesome-5" />
    <Icon name="search" type="font-awesome-5" />
  </View>
);

// Bad: Mixing multiple heavy icon libraries
const MixedIcons = () => (
  <View>
    <Icon name="home" type="font-awesome-5" />
    <Icon name="settings" type="ionicon" />
    <Icon name="person" type="material" />
    {/* Three different libraries in bundle */}
  </View>
);
```

**Correct (selecting appropriate icon library):**

```tsx
import { Icon } from '@rneui/themed';

// Good: Use Material Icons (included with Expo, ~100KB)
const Navigation = () => (
  <View>
    <Icon name="home" type="material" />
    <Icon name="person" type="material" />
    <Icon name="settings" type="material" />
    <Icon name="search" type="material" />
  </View>
);

// Good: Stick to one library throughout the app
const ConsistentIcons = () => (
  <View>
    <Icon name="home" type="material" />
    <Icon name="favorite" type="material" />
    <Icon name="star" type="material" />
    <Icon name="share" type="material" />
  </View>
);

// Good: Use specific imports for custom icons
import { MaterialIcons } from '@expo/vector-icons';

const CustomIconButton = () => (
  <Button
    icon={<MaterialIcons name="add" size={24} color="white" />}
    title="Add Item"
  />
);

// Good: Create an icon mapping for app-wide consistency
const AppIcons = {
  home: { name: 'home', type: 'material' },
  profile: { name: 'person', type: 'material' },
  settings: { name: 'settings', type: 'material' },
  search: { name: 'search', type: 'material' },
  notifications: { name: 'notifications', type: 'material' },
} as const;

const IconButton = ({ icon }: { icon: keyof typeof AppIcons }) => (
  <Icon {...AppIcons[icon]} />
);

// Icon library size reference:
// - material: ~100KB (default, recommended)
// - material-community: ~400KB (extended material)
// - ionicon: ~200KB (iOS-style)
// - font-awesome: ~200KB (v4)
// - font-awesome-5: ~2MB+ (v5, heaviest)
// - feather: ~50KB (minimal, outlined)
// - antdesign: ~300KB (Ant Design)
```

Reference: [React Native Elements Icon](https://reactnativeelements.com/docs/components/icon)
