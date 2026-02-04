---
title: Use Input Component for Form Fields
impact: HIGH
impactDescription: Built-in label, error, icon support reduces boilerplate by 50%
tags: comp, forms, validation, accessibility
---

## Use Input Component for Form Fields

The Input component bundles label, error message display, icons, and accessibility features that would otherwise require 50+ lines of custom code. Using raw TextInput forces you to manually handle these common form patterns, leading to inconsistent implementations across your app.

**Incorrect (raw TextInput with manual handling):**

```tsx
// Bad: Manual implementation of common form patterns
const EmailField = ({ value, onChange, error }) => (
  <View style={styles.inputContainer}>
    <Text style={styles.label}>Email Address</Text>
    <View style={styles.inputWrapper}>
      <Icon name="email" style={styles.icon} />
      <TextInput
        value={value}
        onChangeText={onChange}
        placeholder="Enter your email"
        style={[styles.input, error && styles.inputError]}
        keyboardType="email-address"
        autoCapitalize="none"
      />
    </View>
    {error && <Text style={styles.errorText}>{error}</Text>}
  </View>
);

// Requires extensive manual styling
const styles = StyleSheet.create({
  inputContainer: { marginBottom: 16 },
  label: { fontSize: 14, fontWeight: '600', marginBottom: 4 },
  inputWrapper: { flexDirection: 'row', alignItems: 'center', borderWidth: 1, borderRadius: 8 },
  icon: { padding: 10 },
  input: { flex: 1, padding: 12 },
  inputError: { borderColor: 'red' },
  errorText: { color: 'red', fontSize: 12, marginTop: 4 },
});
```

**Correct (Input with built-in features):**

```tsx
import { Input, Icon } from '@rneui/themed';

// Good: All common form features built-in
const EmailField = ({ value, onChange, error }) => (
  <Input
    value={value}
    onChangeText={onChange}
    label="Email Address"
    placeholder="Enter your email"
    keyboardType="email-address"
    autoCapitalize="none"
    errorMessage={error}
    leftIcon={<Icon name="email" type="material" />}
  />
);

// Password field with visibility toggle
const PasswordField = ({ value, onChange, error }) => {
  const [visible, setVisible] = useState(false);

  return (
    <Input
      value={value}
      onChangeText={onChange}
      label="Password"
      placeholder="Enter your password"
      secureTextEntry={!visible}
      errorMessage={error}
      leftIcon={<Icon name="lock" type="material" />}
      rightIcon={
        <Icon
          name={visible ? 'visibility' : 'visibility-off'}
          type="material"
          onPress={() => setVisible(!visible)}
        />
      }
    />
  );
};

// Disabled and loading states
const DisabledInput = () => (
  <Input
    label="Username"
    disabled
    disabledInputStyle={{ opacity: 0.5 }}
    placeholder="Loading..."
  />
);
```

Reference: [React Native Elements Input](https://reactnativeelements.com/docs/components/input)
