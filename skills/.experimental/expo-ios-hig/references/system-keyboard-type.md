---
title: Configure each text field for its content
impact: MEDIUM
impactDescription: enables the correct keyboard and autofill per field
tags: system, keyboard, textcontenttype, autofill
---

## Configure each text field for its content

iOS tailors the keyboard and autofill to the field: an email field gets the @ key, a one-time-code field surfaces the SMS code above the keyboard, and a password field offers the saved-passwords and Strong Password flows. A default text field for everything makes users switch keyboard planes for the @ symbol and forfeits autofill entirely. Set `keyboardType`, `textContentType`, `autoComplete`, and `returnKeyType` per field.

**Incorrect (default field for an email):**

```tsx
import { TextInput } from 'react-native';

// Default keyboard: no @ key, no email autofill, wrong return key
function EmailField() {
  return <TextInput placeholder="Email" onChangeText={setEmail} />;
}
```

**Correct (field configured for email):**

```tsx
import { TextInput } from 'react-native';

// Email keyboard, autofill, and a "next" return key to advance the form
function EmailField() {
  return (
    <TextInput
      placeholder="Email"
      keyboardType="email-address"
      textContentType="emailAddress"
      autoComplete="email"
      autoCapitalize="none"
      returnKeyType="next"
      onChangeText={setEmail}
    />
  );
}
```

Reference: [React Native — TextInput (keyboardType)](https://reactnative.dev/docs/textinput#keyboardtype)
