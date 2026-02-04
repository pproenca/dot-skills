---
title: Configure Input Handlers Efficiently
impact: MEDIUM
impactDescription: Reduces parent re-renders by 70-80% during typing with local state buffering
tags: event, Input, performance, state-management, typing
---

## Configure Input Handlers Efficiently

Updating parent component state on every keystroke triggers re-renders up the entire component tree. This causes input lag and janky typing experience, especially in complex forms. Buffer input locally and sync to parent state only when needed using debounce or blur events.

**Incorrect (direct parent state update on every keystroke):**

```tsx
import { Input } from '@rneui/themed';

// Parent component re-renders on every keystroke
function ProfileForm({ formData, setFormData }) {
  return (
    <View>
      {/* BAD: Every keystroke updates parent state */}
      <Input
        label="Username"
        value={formData.username}
        onChangeText={(text) =>
          // Triggers parent re-render, which re-renders entire form
          setFormData({ ...formData, username: text })
        }
      />

      <Input
        label="Bio"
        value={formData.bio}
        multiline
        onChangeText={(text) =>
          // Long text input becomes very laggy
          setFormData({ ...formData, bio: text })
        }
      />

      {/* Other expensive components re-render on each keystroke */}
      <ExpensiveAvatarPicker user={formData} />
    </View>
  );
}
```

**Correct (local state with debounced/blur sync to parent):**

```tsx
import { useState, useCallback, useEffect, useMemo } from 'react';
import { Input } from '@rneui/themed';
import debounce from 'lodash.debounce';

// Isolated input with local state
function BufferedInput({ label, value, onValueChange, multiline }) {
  const [localValue, setLocalValue] = useState(value);

  // Sync from parent when value prop changes externally
  useEffect(() => {
    setLocalValue(value);
  }, [value]);

  // Debounced update to parent - only fires after typing stops
  const debouncedUpdate = useMemo(
    () => debounce((text: string) => onValueChange(text), 300),
    [onValueChange]
  );

  const handleChange = useCallback(
    (text: string) => {
      setLocalValue(text); // Immediate local update
      debouncedUpdate(text); // Debounced parent update
    },
    [debouncedUpdate]
  );

  // Cleanup debounce on unmount
  useEffect(() => {
    return () => debouncedUpdate.cancel();
  }, [debouncedUpdate]);

  return (
    <Input
      label={label}
      value={localValue}
      onChangeText={handleChange}
      multiline={multiline}
    />
  );
}

// Parent only re-renders when debounce fires
function ProfileForm({ formData, setFormData }) {
  const updateField = useCallback(
    (field: string) => (value: string) => {
      setFormData((prev) => ({ ...prev, [field]: value }));
    },
    [setFormData]
  );

  return (
    <View>
      <BufferedInput
        label="Username"
        value={formData.username}
        onValueChange={updateField('username')}
      />

      <BufferedInput
        label="Bio"
        value={formData.bio}
        onValueChange={updateField('bio')}
        multiline
      />

      {/* Only re-renders when debounce fires, not every keystroke */}
      <ExpensiveAvatarPicker user={formData} />
    </View>
  );
}
```

Reference: [React Native Performance](https://reactnative.dev/docs/performance)
