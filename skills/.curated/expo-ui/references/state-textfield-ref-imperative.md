---
title: Use TextFieldRef for Imperative Focus and Selection
impact: MEDIUM
impactDescription: enables focus management, text replacement, and selection control — declarative props can't model these
tags: state, textField, ref, imperative, focus
---

## Use TextFieldRef for Imperative Focus and Selection

`TextField` and `SecureField` expose a `ref` of type `TextFieldRef`/`SecureFieldRef` with `focus()`, `blur()`, `clear()`, `setText()`, and `setSelection()` methods. These cover the imperative cases declarative props can't reach: focusing on mount, jumping the cursor after a "paste from clipboard" action, clearing on submit. Wiring a `text` `useNativeState` for the value *and* a ref for the imperative handle is the standard combination.

**Incorrect (declarative-only — no way to clear on submit, no programmatic focus):**

```tsx
import { Host, TextField, Button, useNativeState } from '@expo/ui/swift-ui';

const message = useNativeState('');

<Host matchContents>
  <TextField text={message} placeholder="Reply" />
  <Button
    label="Send"
    onPress={() => {
      sendMessage(message.value);
      message.value = '';
    }}
  />
</Host>
```

**Correct (ref provides clear + focus — flow recovers cleanly):**

```tsx
import { useRef } from 'react';
import { Host, TextField, Button, useNativeState, type TextFieldRef } from '@expo/ui/swift-ui';

const message = useNativeState('');
const inputRef = useRef<TextFieldRef>(null);

<Host matchContents>
  <TextField ref={inputRef} text={message} placeholder="Reply" autoFocus />
  <Button
    label="Send"
    onPress={async () => {
      await sendMessage(message.value);
      await inputRef.current?.clear();
      await inputRef.current?.focus();
    }}
  />
</Host>
```

**Alternative (jump cursor after inserting a mention):**

```tsx
await inputRef.current?.setText(`${message.value}@${mention.handle} `);
await inputRef.current?.setSelection(message.value.length + mention.handle.length + 2, 0);
```

Reference: [@expo/ui TextFieldRef](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/TextField/index.tsx)
