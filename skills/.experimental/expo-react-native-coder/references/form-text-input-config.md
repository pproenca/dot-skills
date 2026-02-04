---
title: Configure TextInput with Proper Keyboard and AutoComplete
impact: MEDIUM
impactDescription: improves input UX with appropriate keyboard types
tags: form, textinput, keyboard, autocomplete
---

## Configure TextInput with Proper Keyboard and AutoComplete

Set `keyboardType`, `autoComplete`, and `autoCapitalize` for better input UX. The keyboard adapts to the expected input.

**Incorrect (default keyboard for all inputs):**

```typescript
<TextInput placeholder="Email" />
<TextInput placeholder="Phone" />
<TextInput placeholder="Amount" />
// All show standard keyboard - no autocomplete
```

**Correct (appropriate configuration per input type):**

```typescript
import { TextInput, View, StyleSheet } from 'react-native';

export default function SignUpForm() {
  return (
    <View style={styles.container}>
      {/* Name - autocapitalize words */}
      <TextInput
        placeholder="Full Name"
        autoCapitalize="words"
        autoComplete="name"
        textContentType="name"  // iOS autofill
        style={styles.input}
      />

      {/* Email - email keyboard, no caps */}
      <TextInput
        placeholder="Email"
        keyboardType="email-address"
        autoCapitalize="none"
        autoComplete="email"
        textContentType="emailAddress"
        autoCorrect={false}
        style={styles.input}
      />

      {/* Phone - numeric keyboard */}
      <TextInput
        placeholder="Phone Number"
        keyboardType="phone-pad"
        autoComplete="tel"
        textContentType="telephoneNumber"
        style={styles.input}
      />

      {/* Password - secure entry */}
      <TextInput
        placeholder="Password"
        secureTextEntry
        autoCapitalize="none"
        autoComplete="new-password"
        textContentType="newPassword"  // iOS password suggestions
        autoCorrect={false}
        style={styles.input}
      />

      {/* Currency - decimal keyboard */}
      <TextInput
        placeholder="Amount"
        keyboardType="decimal-pad"
        style={styles.input}
      />

      {/* URL - URL keyboard */}
      <TextInput
        placeholder="Website"
        keyboardType="url"
        autoCapitalize="none"
        autoCorrect={false}
        style={styles.input}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { padding: 16 },
  input: { borderWidth: 1, borderColor: '#ddd', padding: 16, borderRadius: 8, marginBottom: 16 },
});
```

**Common keyboardType values:** `default`, `email-address`, `numeric`, `phone-pad`, `decimal-pad`, `url`

Reference: [TextInput - React Native](https://reactnative.dev/docs/textinput)
