/**
 * Form Screen Template
 *
 * A complete form screen with:
 * - Controlled inputs
 * - Validation
 * - Keyboard handling
 * - Loading and error states
 */

import { useState } from 'react';
import { View, Text, TextInput, Pressable, ActivityIndicator, StyleSheet, Alert } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';
import { router } from 'expo-router';
import * as Haptics from 'expo-haptics';

interface FormData {
  title: string;
  description: string;
  email: string;
}

interface FormErrors {
  title?: string;
  description?: string;
  email?: string;
}

export default function FormScreen() {
  const [form, setForm] = useState<FormData>({
    title: '',
    description: '',
    email: '',
  });
  const [errors, setErrors] = useState<FormErrors>({});
  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [submitting, setSubmitting] = useState(false);

  const validate = (field: keyof FormData, value: string): string | undefined => {
    switch (field) {
      case 'title':
        if (!value.trim()) return 'Title is required';
        if (value.length < 3) return 'Title must be at least 3 characters';
        return undefined;
      case 'description':
        if (!value.trim()) return 'Description is required';
        if (value.length < 10) return 'Description must be at least 10 characters';
        return undefined;
      case 'email':
        if (!value.trim()) return 'Email is required';
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) return 'Invalid email address';
        return undefined;
      default:
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

  const validateAll = (): boolean => {
    const newErrors: FormErrors = {
      title: validate('title', form.title),
      description: validate('description', form.description),
      email: validate('email', form.email),
    };
    setErrors(newErrors);
    setTouched({ title: true, description: true, email: true });
    return !Object.values(newErrors).some(Boolean);
  };

  const handleSubmit = async () => {
    if (!validateAll()) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
      return;
    }

    setSubmitting(true);
    try {
      const response = await fetch('/api/items', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });

      if (!response.ok) {
        throw new Error('Failed to submit');
      }

      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      router.back();
    } catch (error) {
      Alert.alert('Error', 'Failed to submit. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <KeyboardAwareScrollView
      style={styles.container}
      contentContainerStyle={styles.content}
      bottomOffset={100}
    >
      <View style={styles.field}>
        <Text style={styles.label}>Title *</Text>
        <TextInput
          style={[styles.input, errors.title && touched.title && styles.inputError]}
          value={form.title}
          onChangeText={(text) => handleChange('title', text)}
          onBlur={() => handleBlur('title')}
          placeholder="Enter title"
          autoCapitalize="sentences"
        />
        {errors.title && touched.title && (
          <Text style={styles.error}>{errors.title}</Text>
        )}
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Email *</Text>
        <TextInput
          style={[styles.input, errors.email && touched.email && styles.inputError]}
          value={form.email}
          onChangeText={(text) => handleChange('email', text)}
          onBlur={() => handleBlur('email')}
          placeholder="Enter email"
          keyboardType="email-address"
          autoCapitalize="none"
          autoComplete="email"
        />
        {errors.email && touched.email && (
          <Text style={styles.error}>{errors.email}</Text>
        )}
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Description *</Text>
        <TextInput
          style={[styles.input, styles.textArea, errors.description && touched.description && styles.inputError]}
          value={form.description}
          onChangeText={(text) => handleChange('description', text)}
          onBlur={() => handleBlur('description')}
          placeholder="Enter description"
          multiline
          numberOfLines={4}
          textAlignVertical="top"
        />
        {errors.description && touched.description && (
          <Text style={styles.error}>{errors.description}</Text>
        )}
      </View>

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
    </KeyboardAwareScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    padding: 16,
  },
  field: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#E5E5EA',
    borderRadius: 8,
    padding: 16,
    fontSize: 16,
    backgroundColor: '#FAFAFA',
  },
  inputError: {
    borderColor: '#FF3B30',
  },
  textArea: {
    minHeight: 120,
  },
  error: {
    color: '#FF3B30',
    fontSize: 12,
    marginTop: 4,
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 50,
    marginTop: 20,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
