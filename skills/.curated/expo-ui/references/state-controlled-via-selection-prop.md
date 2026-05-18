---
title: Choose selection (Controlled) or defaultSelection (Uncontrolled) — Not Both
impact: MEDIUM
impactDescription: prevents prop conflicts — components ignore defaultSelection when selection is also provided
tags: state, controlled, uncontrolled, selection
---

## Choose selection (Controlled) or defaultSelection (Uncontrolled) — Not Both

`TabView` (and similar selection-based components) accept either a controlled `selection` paired with `onSelectionChange`, or an uncontrolled `defaultSelection` that the native view manages internally. Passing both is a code smell — the component silently ignores `defaultSelection` and is driven by `selection`. Decide up front whether the parent owns the selection or the native view does, and pick one prop.

**Incorrect (both props supplied — defaultSelection is silently ignored):**

```tsx
import { Host, TabView } from '@expo/ui/swift-ui';

const [tab, setTab] = useState('feed');

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <TabView
    selection={tab}
    defaultSelection="feed"
    onSelectionChange={setTab}>
    <TabView.Tab value="feed"><FeedScreen /></TabView.Tab>
    <TabView.Tab value="inbox"><InboxScreen /></TabView.Tab>
  </TabView>
</Host>
```

**Correct (controlled — parent drives selection):**

```tsx
import { Host, TabView } from '@expo/ui/swift-ui';

const [tab, setTab] = useState('feed');

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <TabView selection={tab} onSelectionChange={setTab}>
    <TabView.Tab value="feed"><FeedScreen /></TabView.Tab>
    <TabView.Tab value="inbox"><InboxScreen /></TabView.Tab>
  </TabView>
</Host>
```

**Alternative (uncontrolled — native view manages selection internally):**

```tsx
<TabView defaultSelection="feed">
  <TabView.Tab value="feed"><FeedScreen /></TabView.Tab>
  <TabView.Tab value="inbox"><InboxScreen /></TabView.Tab>
</TabView>
```

Reference: [@expo/ui TabView source — selection vs defaultSelection](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/TabView/index.tsx)
