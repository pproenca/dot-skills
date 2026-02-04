---
title: Present Screens as Modals with presentation Option
impact: HIGH
impactDescription: creates overlay screens for focused interactions
tags: route, modal, presentation, navigation
---

## Present Screens as Modals with presentation Option

Use the `presentation: 'modal'` option to present screens as overlays. Modals are useful for forms, confirmations, and focused tasks.

**Incorrect (modal as regular stack screen):**

```typescript
// No presentation option - opens as regular push
<Stack.Screen name="create-post" />
```

**Correct (modal presentation):**

```plaintext
app/
├── _layout.tsx
├── (tabs)/
│   └── ...
└── create-post.tsx       # Modal screen
```

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen
        name="create-post"
        options={{
          presentation: 'modal',
          title: 'Create Post',
          headerLeft: () => null,  // Remove back button
        }}
      />
    </Stack>
  );
}
```

```typescript
// app/create-post.tsx
import { router } from 'expo-router';
import { View, Text, Button } from 'react-native';

export default function CreatePostModal() {
  const handleSubmit = async () => {
    // Save post...
    router.back();  // Dismiss modal
  };

  return (
    <View style={{ flex: 1, padding: 16 }}>
      <Text>Create a new post</Text>
      {/* Form fields */}
      <Button title="Submit" onPress={handleSubmit} />
      <Button title="Cancel" onPress={() => router.back()} />
    </View>
  );
}
```

**Presentation options:** `modal`, `transparentModal`, `containedModal`, `containedTransparentModal`, `fullScreenModal`, `formSheet`

Reference: [Modals - Expo Documentation](https://docs.expo.dev/router/advanced/modals/)
