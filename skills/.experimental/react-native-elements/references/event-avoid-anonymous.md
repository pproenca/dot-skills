---
title: Avoid Anonymous Functions in Renders
impact: MEDIUM
impactDescription: New function references each render break React.memo, causing 40-60% more re-renders
tags: event, anonymous-functions, performance, memoization
---

## Avoid Anonymous Functions in Renders

Anonymous functions defined inline during render create new function references every time the component renders. This defeats `React.memo` optimizations because props appear to have changed even when the function logic is identical. Pre-define handlers or use `useCallback` to maintain stable references.

**Incorrect (anonymous function in JSX):**

```tsx
import { Button, Input } from '@rneui/themed';

function UserForm({ onSubmit, onCancel }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  return (
    <View>
      {/* BAD: New function on every render */}
      <Input
        placeholder="Name"
        onChangeText={(text) => setName(text)}
      />

      {/* BAD: Arrow function creates new reference */}
      <Input
        placeholder="Email"
        onChangeText={(text) => setEmail(text.toLowerCase())}
      />

      {/* BAD: Anonymous function breaks Button memo */}
      <Button
        title="Submit"
        onPress={() => onSubmit({ name, email })}
      />

      {/* BAD: Even simple handlers create new refs */}
      <Button
        title="Cancel"
        onPress={() => onCancel()}
      />
    </View>
  );
}
```

**Correct (pre-defined callbacks with useCallback):**

```tsx
import { useCallback, useState } from 'react';
import { Button, Input } from '@rneui/themed';

function UserForm({ onSubmit, onCancel }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  // Stable reference - setName is stable from useState
  const handleNameChange = useCallback((text: string) => {
    setName(text);
  }, []);

  // Stable reference with transformation
  const handleEmailChange = useCallback((text: string) => {
    setEmail(text.toLowerCase());
  }, []);

  // Only recreated when dependencies change
  const handleSubmit = useCallback(() => {
    onSubmit({ name, email });
  }, [onSubmit, name, email]);

  // Simple wrapper with stable reference
  const handleCancel = useCallback(() => {
    onCancel();
  }, [onCancel]);

  return (
    <View>
      <Input
        placeholder="Name"
        onChangeText={handleNameChange}
      />

      <Input
        placeholder="Email"
        onChangeText={handleEmailChange}
      />

      <Button title="Submit" onPress={handleSubmit} />
      <Button title="Cancel" onPress={handleCancel} />
    </View>
  );
}
```

Reference: [React Native Performance](https://reactnative.dev/docs/performance)
