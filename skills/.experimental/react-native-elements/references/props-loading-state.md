---
title: Use Loading Prop for Async Operations
impact: MEDIUM-HIGH
impactDescription: Better UX, prevents double-taps, built-in accessibility announcements
tags: props, buttons, loading, accessibility, async
---

## Use Loading Prop for Async Operations

The Button component's loading prop provides a built-in loading spinner with automatic disable behavior, preventing double-taps and race conditions. It also announces loading state to screen readers. Manually managing loading with a disabled prop and separate ActivityIndicator creates inconsistent behavior and misses accessibility announcements.

**Incorrect (manual loading management):**

```tsx
// Bad: Manual loading state handling
const SubmitButton = ({ onSubmit }) => {
  const [isLoading, setIsLoading] = useState(false);

  const handlePress = async () => {
    setIsLoading(true);
    await onSubmit();
    setIsLoading(false);
  };

  return (
    <TouchableOpacity
      onPress={handlePress}
      disabled={isLoading}
      style={[styles.button, isLoading && styles.disabled]}
    >
      {isLoading ? (
        <ActivityIndicator color="#fff" size="small" />
      ) : (
        <Text style={styles.text}>Submit</Text>
      )}
    </TouchableOpacity>
  );
};

// Another bad pattern: mixing RNE Button with manual ActivityIndicator
const BadButton = ({ isLoading, onPress }) => (
  <Button
    title={isLoading ? '' : 'Submit'}
    onPress={onPress}
    disabled={isLoading}
    icon={isLoading ? <ActivityIndicator color="#fff" /> : undefined}
  />
);
```

**Correct (Button loading prop):**

```tsx
import { Button } from '@rneui/themed';

// Good: Built-in loading state with accessibility
const SubmitButton = ({ onSubmit }) => {
  const [isLoading, setIsLoading] = useState(false);

  const handlePress = async () => {
    setIsLoading(true);
    await onSubmit();
    setIsLoading(false);
  };

  return (
    <Button
      title="Submit"
      onPress={handlePress}
      loading={isLoading}
    />
  );
};

// Customize loading spinner appearance
const CustomLoadingButton = ({ isLoading, onPress }) => (
  <Button
    title="Save Changes"
    onPress={onPress}
    loading={isLoading}
    loadingProps={{
      size: 'small',
      color: 'white',
      animating: true,
    }}
  />
);

// Loading with icon - icon is replaced by spinner
const IconLoadingButton = ({ isSaving, onSave }) => (
  <Button
    title="Save"
    onPress={onSave}
    loading={isSaving}
    icon={{ name: 'save', type: 'material', color: 'white' }}
    loadingStyle={{ marginRight: 10 }}
  />
);
```

Reference: [React Native Elements Button](https://reactnativeelements.com/docs/components/button)
