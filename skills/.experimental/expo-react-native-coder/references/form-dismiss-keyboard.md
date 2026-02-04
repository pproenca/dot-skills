---
title: Dismiss Keyboard on Tap Outside Input
impact: LOW
impactDescription: improves form usability
tags: form, keyboard, dismiss, ux
---

## Dismiss Keyboard on Tap Outside Input

Allow users to dismiss the keyboard by tapping outside of text inputs using `Keyboard.dismiss()` or `ScrollView` with `keyboardShouldPersistTaps`.

**Incorrect (keyboard stays open until submit):**

```typescript
<View>
  <TextInput placeholder="Search..." />
  <FlatList data={results} />
</View>
// Can't dismiss keyboard by tapping outside
```

**Correct (dismissible keyboard):**

```typescript
import { Keyboard, Pressable, TextInput, View, StyleSheet } from 'react-native';

// Option 1: Wrap in Pressable that dismisses keyboard
export function SearchScreen() {
  return (
    <Pressable style={{ flex: 1 }} onPress={Keyboard.dismiss}>
      <TextInput placeholder="Search..." style={styles.input} />
      <FlatList data={results} renderItem={...} />
    </Pressable>
  );
}

// Option 2: ScrollView with keyboardShouldPersistTaps
export function FormScreen() {
  return (
    <ScrollView
      keyboardShouldPersistTaps="handled"
      contentContainerStyle={styles.container}
    >
      <TextInput placeholder="Name" style={styles.input} />
      <TextInput placeholder="Email" style={styles.input} />
      <Pressable onPress={handleSubmit}>
        <Text>Submit</Text>
      </Pressable>
    </ScrollView>
  );
}

// Option 3: Dismiss on specific action
export function ChatInput() {
  const handleSend = () => {
    sendMessage();
    Keyboard.dismiss();
  };

  return (
    <View style={styles.inputRow}>
      <TextInput placeholder="Message..." />
      <Pressable onPress={handleSend}>
        <Text>Send</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { padding: 16 },
  input: { borderWidth: 1, borderColor: '#ddd', padding: 16, borderRadius: 8, marginBottom: 16 },
  inputRow: { flexDirection: 'row', padding: 8 },
});
```

**keyboardShouldPersistTaps options:**
- `'never'`: Tapping outside dismisses keyboard
- `'always'`: Keyboard never auto-dismisses
- `'handled'`: Dismisses unless tap is on a Touchable

Reference: [Keyboard - React Native](https://reactnative.dev/docs/keyboard)
