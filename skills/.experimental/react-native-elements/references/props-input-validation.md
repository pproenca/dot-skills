---
title: Use errorMessage for Form Validation
impact: MEDIUM-HIGH
impactDescription: Built-in error display, consistent styling, automatic accessibility announcements
tags: props, forms, validation, input, accessibility
---

## Use errorMessage for Form Validation

The Input component's errorMessage prop provides built-in error display with consistent styling and proper accessibility. It automatically positions the error message below the input, applies theme-consistent error colors, and announces validation errors to screen readers. Using manual Text components for errors leads to inconsistent positioning, styling, and missed accessibility features.

**Incorrect (manual error Text component):**

```tsx
// Bad: Manual error handling outside Input
const EmailInput = ({ value, onChange, error }) => (
  <View>
    <Input
      value={value}
      onChangeText={onChange}
      label="Email"
      placeholder="Enter email"
      // No built-in error handling
    />
    {error && (
      <Text style={{ color: 'red', marginTop: -15, marginLeft: 10 }}>
        {error}
      </Text>
    )}
  </View>
);

// Bad: Inconsistent error styling across forms
const PasswordInput = ({ value, onChange, error }) => (
  <View>
    <Input value={value} onChangeText={onChange} label="Password" />
    {error && (
      <Text style={{ color: '#ff0000', fontSize: 11, paddingLeft: 5 }}>
        {error}
      </Text>
    )}
  </View>
);

// Bad: Error state without visual feedback on input
const BadValidation = ({ error }) => (
  <View>
    <TextInput style={styles.input} />
    {error && <Text style={styles.error}>{error}</Text>}
    {/* Input doesn't show error state visually */}
  </View>
);
```

**Correct (Input errorMessage prop):**

```tsx
import { Input } from '@rneui/themed';

// Good: Built-in error display with consistent styling
const EmailInput = ({ value, onChange, error }) => (
  <Input
    value={value}
    onChangeText={onChange}
    label="Email"
    placeholder="Enter email"
    keyboardType="email-address"
    errorMessage={error}
  />
);

// Good: Customize error styling while keeping functionality
const PasswordInput = ({ value, onChange, error }) => (
  <Input
    value={value}
    onChangeText={onChange}
    label="Password"
    secureTextEntry
    errorMessage={error}
    errorStyle={{
      fontSize: 12,
      marginTop: 4,
    }}
  />
);

// Good: Full form validation with consistent error handling
const LoginForm = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({});

  const validate = () => {
    const newErrors = {};
    if (!email) newErrors.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(email)) newErrors.email = 'Invalid email format';
    if (!password) newErrors.password = 'Password is required';
    else if (password.length < 8) newErrors.password = 'Password must be 8+ characters';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  return (
    <View>
      <Input
        value={email}
        onChangeText={setEmail}
        label="Email"
        errorMessage={errors.email}
        renderErrorMessage={!!errors.email}
      />
      <Input
        value={password}
        onChangeText={setPassword}
        label="Password"
        secureTextEntry
        errorMessage={errors.password}
        renderErrorMessage={!!errors.password}
      />
    </View>
  );
};

// Good: Set error styling globally via theme
const theme = createTheme({
  components: {
    Input: {
      errorStyle: {
        color: '#D32F2F',
        fontSize: 12,
      },
    },
  },
});
```

Reference: [React Native Elements Input](https://reactnativeelements.com/docs/components/input)
