---
title: Build Login Form with Validation
impact: MEDIUM
impactDescription: provides secure, user-friendly authentication UI
tags: auth, form, login, validation
---

## Build Login Form with Validation

Create a login form with input validation, error handling, and loading states for a polished authentication experience.

**Incorrect (no validation or error handling):**

```typescript
const [email, setEmail] = useState('');
const [password, setPassword] = useState('');

const handleLogin = () => {
  fetch('/api/login', { body: JSON.stringify({ email, password }) });
};
```

**Correct (complete login form):**

```typescript
import { useState } from 'react';
import { View, TextInput, Text, Pressable, ActivityIndicator, StyleSheet } from 'react-native';
import { useAuth } from '@/context/auth';
import { router } from 'expo-router';

export default function SignInScreen() {
  const { signIn } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const validateEmail = (email: string) => {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  };

  const handleLogin = async () => {
    setError(null);

    // Validation
    if (!email.trim()) {
      setError('Email is required');
      return;
    }
    if (!validateEmail(email)) {
      setError('Please enter a valid email');
      return;
    }
    if (!password || password.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.message || 'Login failed');
      }

      const { token } = await response.json();
      await signIn(token);
      // Navigation handled by protected routes
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Sign In</Text>

      {error && <Text style={styles.error}>{error}</Text>}

      <TextInput
        style={styles.input}
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
        autoComplete="email"
      />

      <TextInput
        style={styles.input}
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        autoComplete="password"
      />

      <Pressable
        style={[styles.button, loading && styles.buttonDisabled]}
        onPress={handleLogin}
        disabled={loading}
      >
        {loading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Sign In</Text>
        )}
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 24, justifyContent: 'center' },
  title: { fontSize: 32, fontWeight: 'bold', marginBottom: 24 },
  input: { borderWidth: 1, borderColor: '#ddd', padding: 16, borderRadius: 8, marginBottom: 16 },
  button: { backgroundColor: '#007AFF', padding: 16, borderRadius: 8, alignItems: 'center' },
  buttonDisabled: { opacity: 0.6 },
  buttonText: { color: '#fff', fontWeight: '600', fontSize: 16 },
  error: { color: 'red', marginBottom: 16 },
});
```

Reference: [Authentication - Expo Documentation](https://docs.expo.dev/develop/authentication/)
