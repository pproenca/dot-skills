---
title: Use KeyboardAvoidingView for Input Screens
impact: MEDIUM
impactDescription: keeps inputs visible when keyboard opens
tags: ux, keyboard, input, form
---

## Use KeyboardAvoidingView for Input Screens

Use `KeyboardAvoidingView` to prevent the keyboard from covering input fields. Behavior differs between iOS and Android.

**Incorrect (keyboard covers input):**

```typescript
<View style={{ flex: 1 }}>
  <TextInput placeholder="Message..." />
  <Button title="Send" />
</View>
// Input hidden when keyboard opens
```

**Correct (KeyboardAvoidingView):**

```typescript
import { KeyboardAvoidingView, Platform, TextInput, Button, View, StyleSheet } from 'react-native';

export default function ChatScreen() {
  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}  // Adjust for header height
    >
      <View style={styles.messages}>
        {/* Message list */}
      </View>
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Type a message..."
          multiline
        />
        <Button title="Send" onPress={() => {}} />
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  messages: { flex: 1 },
  inputContainer: { flexDirection: 'row', padding: 8, borderTopWidth: 1, borderTopColor: '#eee' },
  input: { flex: 1, borderWidth: 1, borderColor: '#ddd', borderRadius: 20, paddingHorizontal: 16, paddingVertical: 8 },
});
```

**For complex forms, use KeyboardAwareScrollView:**

```typescript
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

export default function FormScreen() {
  return (
    <KeyboardAwareScrollView bottomOffset={62}>
      <TextInput placeholder="Name" />
      <TextInput placeholder="Email" />
      <TextInput placeholder="Bio" multiline />
      {/* More fields */}
    </KeyboardAwareScrollView>
  );
}
```

Reference: [Keyboard handling - Expo Documentation](https://docs.expo.dev/guides/keyboard-handling/)
