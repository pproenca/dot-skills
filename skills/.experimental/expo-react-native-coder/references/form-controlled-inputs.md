---
title: Use Controlled Inputs with useState
impact: MEDIUM
impactDescription: enables validation and form state management
tags: form, controlled, state, validation
---

## Use Controlled Inputs with useState

Use controlled inputs where React state is the source of truth. This enables real-time validation and form management.

**Incorrect (uncontrolled inputs):**

```typescript
// Can't validate or manage state
<TextInput ref={inputRef} />
const value = inputRef.current?.value;  // Doesn't work in RN
```

**Correct (controlled inputs):**

```typescript
import { useState } from 'react';
import { View, TextInput, Text, Pressable, StyleSheet } from 'react-native';

interface FormData {
  username: string;
  email: string;
}

interface FormErrors {
  username?: string;
  email?: string;
}

export default function ProfileForm() {
  const [form, setForm] = useState<FormData>({ username: '', email: '' });
  const [errors, setErrors] = useState<FormErrors>({});
  const [touched, setTouched] = useState<Record<string, boolean>>({});

  const validate = (field: keyof FormData, value: string): string | undefined => {
    switch (field) {
      case 'username':
        if (!value.trim()) return 'Username is required';
        if (value.length < 3) return 'Username must be at least 3 characters';
        return undefined;
      case 'email':
        if (!value.trim()) return 'Email is required';
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) return 'Invalid email';
        return undefined;
    }
  };

  const handleChange = (field: keyof FormData, value: string) => {
    setForm(prev => ({ ...prev, [field]: value }));
    if (touched[field]) {
      setErrors(prev => ({ ...prev, [field]: validate(field, value) }));
    }
  };

  const handleBlur = (field: keyof FormData) => {
    setTouched(prev => ({ ...prev, [field]: true }));
    setErrors(prev => ({ ...prev, [field]: validate(field, form[field]) }));
  };

  const handleSubmit = () => {
    const newErrors: FormErrors = {
      username: validate('username', form.username),
      email: validate('email', form.email),
    };
    setErrors(newErrors);
    setTouched({ username: true, email: true });

    if (!newErrors.username && !newErrors.email) {
      // Submit form
      console.log('Submitting:', form);
    }
  };

  return (
    <View style={styles.container}>
      <TextInput
        placeholder="Username"
        value={form.username}
        onChangeText={(text) => handleChange('username', text)}
        onBlur={() => handleBlur('username')}
        style={[styles.input, errors.username && styles.inputError]}
      />
      {errors.username && <Text style={styles.error}>{errors.username}</Text>}

      <TextInput
        placeholder="Email"
        value={form.email}
        onChangeText={(text) => handleChange('email', text)}
        onBlur={() => handleBlur('email')}
        keyboardType="email-address"
        style={[styles.input, errors.email && styles.inputError]}
      />
      {errors.email && <Text style={styles.error}>{errors.email}</Text>}

      <Pressable style={styles.button} onPress={handleSubmit}>
        <Text style={styles.buttonText}>Save</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { padding: 16 },
  input: { borderWidth: 1, borderColor: '#ddd', padding: 16, borderRadius: 8, marginBottom: 4 },
  inputError: { borderColor: 'red' },
  error: { color: 'red', fontSize: 12, marginBottom: 12 },
  button: { backgroundColor: '#007AFF', padding: 16, borderRadius: 8, alignItems: 'center' },
  buttonText: { color: '#fff', fontWeight: '600' },
});
```

Reference: [TextInput - React Native](https://reactnative.dev/docs/textinput)
