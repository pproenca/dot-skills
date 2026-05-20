---
title: Place search in the navigation bar
impact: MEDIUM-HIGH
impactDescription: enables the native search field that hides on scroll
tags: nav, search, navigation-bar, header
---

## Place search in the navigation bar

iOS users expect search to live in the navigation bar, where it tucks under the title and reveals on pull-down, integrates with the keyboard and Cancel button, and supports the scope bar. A `TextInput` placed in the screen body scrolls away with the content, doesn't get the system styling or the search keyboard return key, and forces you to rebuild focus and cancel behavior by hand.

**Incorrect (search box in the scroll body):**

```tsx
import { ScrollView, TextInput } from 'react-native';

// Custom field scrolls with the list and lacks the native reveal,
// Cancel button, and search-styled keyboard
export default function TrailsScreen() {
  return (
    <ScrollView>
      <TextInput placeholder="Search trails" onChangeText={setQuery} />
      <TrailList query={query} />
    </ScrollView>
  );
}
```

**Correct (search integrated in the header):**

```tsx
import { Stack } from 'expo-router';
import { ScrollView } from 'react-native';

export default function TrailsScreen() {
  return (
    <>
      {/* Native search field: pull-to-reveal, Cancel button, search keyboard */}
      <Stack.Screen
        options={{
          headerSearchBarOptions: {
            placeholder: 'Search trails',
            onChangeText: (e) => setQuery(e.nativeEvent.text),
          },
        }}
      />
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <TrailList query={query} />
      </ScrollView>
    </>
  );
}
```

Reference: [Apple HIG — Searching](https://developer.apple.com/design/human-interface-guidelines/searching)
