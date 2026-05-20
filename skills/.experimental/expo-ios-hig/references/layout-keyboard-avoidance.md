---
title: Keep inputs visible above the keyboard
impact: HIGH
impactDescription: prevents inputs hidden behind the keyboard
tags: layout, keyboard, input, forms
---

## Keep inputs visible above the keyboard

When the keyboard appears it covers the lower half of the screen. A form that doesn't react leaves the focused field — and the submit button — hidden behind the keyboard, so the user types blind. `KeyboardAvoidingView` with `behavior="padding"` lifts the content on iOS, and pairing it with a keyboard-dismissing scroll view lets the user scroll the form while typing.

**Incorrect (static form ignores the keyboard):**

```tsx
import { View, TextInput, Button } from 'react-native';

// When the keyboard opens, the notes field and Save button vanish behind it
function ReviewForm() {
  return (
    <View style={styles.form}>
      <TextInput placeholder="Notes about this hike" multiline />
      <Button title="Save" onPress={saveReview} />
    </View>
  );
}
```

**Correct (content lifts above the keyboard):**

```tsx
import { KeyboardAvoidingView, ScrollView, TextInput, Button } from 'react-native';

// Content lifts on iOS; the scroll view stays usable while the keyboard is up
function ReviewForm() {
  return (
    <KeyboardAvoidingView behavior="padding" style={{ flex: 1 }}>
      <ScrollView keyboardDismissMode="interactive">
        <TextInput placeholder="Notes about this hike" multiline />
        <Button title="Save" onPress={saveReview} />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
```

Reference: [React Native — KeyboardAvoidingView](https://reactnative.dev/docs/keyboardavoidingview)
