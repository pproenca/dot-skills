---
title: Use SecureField for Password Inputs — Not TextField
impact: HIGH
impactDescription: enables password autofill, biometric autofill, and prevents screenshot capture of the text
tags: input, secureField, password, autofill
---

## Use SecureField for Password Inputs — Not TextField

`SecureField` is a separate native view that wires into the iOS password autofill machinery, biometric autofill (Face ID), and disables screenshot/share-sheet capture of the text contents. A `TextField` with custom obscuring (rendering bullets via JS) gives the visual mask but skips every one of those system integrations. Use `SecureField` whenever the value is a password, passcode, or credential.

**Incorrect (TextField for password — no autofill, no biometric fill):**

```tsx
import { Host, TextField, useNativeState } from '@expo/ui/swift-ui';

export function LoginPasswordField() {
  const password = useNativeState('');
  return (
    <Host matchContents>
      <TextField text={password} placeholder="Password" />
    </Host>
  );
}
```

**Correct (SecureField — iOS autofill and biometric prompts attach):**

```tsx
import { Host, SecureField, useNativeState } from '@expo/ui/swift-ui';

export function LoginPasswordField() {
  const password = useNativeState('');
  return (
    <Host matchContents>
      <SecureField text={password} placeholder="Password" />
    </Host>
  );
}
```

Reference: [@expo/ui SecureField source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/SecureField/index.tsx)
