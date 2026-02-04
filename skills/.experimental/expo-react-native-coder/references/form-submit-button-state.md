---
title: Disable Submit Button During Form Submission
impact: MEDIUM
impactDescription: prevents duplicate submissions
tags: form, submit, loading, ux
---

## Disable Submit Button During Form Submission

Disable the submit button and show a loading indicator during submission to prevent duplicate requests.

**Incorrect (button remains active during submission):**

```typescript
const handleSubmit = async () => {
  await fetch('/api/submit', { method: 'POST', body: JSON.stringify(data) });
};

<Pressable onPress={handleSubmit}>
  <Text>Submit</Text>
</Pressable>
// User can tap multiple times causing duplicate submissions
```

**Correct (disabled button with loading state):**

```typescript
import { useState } from 'react';
import { Pressable, Text, ActivityIndicator, StyleSheet } from 'react-native';

export default function SubmitForm() {
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async () => {
    if (submitting) return;  // Extra guard

    setSubmitting(true);
    try {
      const response = await fetch('/api/submit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error('Submission failed');
      }

      // Success - navigate or show confirmation
      router.back();
    } catch (error) {
      // Show error to user
      Alert.alert('Error', 'Failed to submit. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Pressable
      style={[styles.button, submitting && styles.buttonDisabled]}
      onPress={handleSubmit}
      disabled={submitting}
    >
      {submitting ? (
        <ActivityIndicator color="#fff" />
      ) : (
        <Text style={styles.buttonText}>Submit</Text>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  button: {
    backgroundColor: '#007AFF',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 50,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 16,
  },
});
```

**Note:** The `disabled` prop prevents taps, while the `if (submitting) return` guard prevents edge cases.

Reference: [Pressable - React Native](https://reactnative.dev/docs/pressable)
