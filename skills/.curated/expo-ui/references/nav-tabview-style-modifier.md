---
title: Set TabView Appearance via tabViewStyle Modifier
impact: HIGH
impactDescription: enables the three TabView appearances (automatic bottom-bar, swipeable pager, sidebar-adaptable) — no style prop exists
tags: nav, tabView, tabViewStyle, ios-design
---

## Set TabView Appearance via tabViewStyle Modifier

`TabView` accepts the same modifier-driven style pattern as `Picker`. Without `tabViewStyle`, it falls back to `automatic`, which iOS resolves contextually but may not match the intent — particularly on iPad where you typically want `sidebarAdaptable`. Specify the modifier to pin the appearance.

**Incorrect (no tabViewStyle — falls back to platform default, no sidebar on iPad):**

```tsx
import { Host, TabView } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <TabView selection={tab} onSelectionChange={setTab}>
    <TabView.Tab value="feed">
      <FeedScreen />
    </TabView.Tab>
    <TabView.Tab value="inbox">
      <InboxScreen />
    </TabView.Tab>
  </TabView>
</Host>
```

**Correct (sidebarAdaptable — sidebar on iPad, bottom tabs on iPhone):**

```tsx
import { Host, TabView } from '@expo/ui/swift-ui';
import { tabViewStyle } from '@expo/ui/swift-ui/modifiers';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <TabView
    selection={tab}
    onSelectionChange={setTab}
    modifiers={[tabViewStyle({ type: 'sidebarAdaptable' })]}>
    <TabView.Tab value="feed">
      <FeedScreen />
    </TabView.Tab>
    <TabView.Tab value="inbox">
      <InboxScreen />
    </TabView.Tab>
  </TabView>
</Host>
```

**Alternative (swipeable page-style for onboarding):**

```tsx
<TabView modifiers={[tabViewStyle({ type: 'page', indexDisplayMode: 'always' })]}>
  <TabView.Tab value="welcome"><WelcomeSlide /></TabView.Tab>
  <TabView.Tab value="permissions"><PermissionsSlide /></TabView.Tab>
  <TabView.Tab value="ready"><ReadySlide /></TabView.Tab>
</TabView>
```

**When NOT to use this pattern:**

- For routed bottom-tab navigation across full-screen routes, prefer `expo-router/unstable-native-tabs` — that is a navigation primitive, not a UI primitive.

Reference: [@expo/ui TabView source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/TabView/index.tsx)
