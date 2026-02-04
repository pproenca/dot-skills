---
title: Use Button Type Prop for Variants
impact: HIGH
impactDescription: reduces button boilerplate by 60% with built-in accessibility
tags: comp, buttons, accessibility, styling
---

## Use Button Type Prop for Variants

The Button component's type prop provides solid, clear, and outline variants with proper accessibility, touch feedback, and theme integration. Creating custom button variants with TouchableOpacity requires manually handling all these concerns, leading to inconsistent button behavior across your app.

**Incorrect (custom styled TouchableOpacity for variants):**

```tsx
// Bad: Manual button implementations
const PrimaryButton = ({ title, onPress }) => (
  <TouchableOpacity
    onPress={onPress}
    style={styles.primaryButton}
    activeOpacity={0.7}
  >
    <Text style={styles.primaryText}>{title}</Text>
  </TouchableOpacity>
);

const OutlineButton = ({ title, onPress }) => (
  <TouchableOpacity
    onPress={onPress}
    style={styles.outlineButton}
    activeOpacity={0.7}
  >
    <Text style={styles.outlineText}>{title}</Text>
  </TouchableOpacity>
);

const TextButton = ({ title, onPress }) => (
  <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
    <Text style={styles.textButton}>{title}</Text>
  </TouchableOpacity>
);

// Many lines of manual styling required
const styles = StyleSheet.create({
  primaryButton: { backgroundColor: '#2089dc', padding: 16, borderRadius: 8 },
  primaryText: { color: '#fff', textAlign: 'center', fontWeight: '600' },
  outlineButton: { borderWidth: 2, borderColor: '#2089dc', padding: 16, borderRadius: 8 },
  outlineText: { color: '#2089dc', textAlign: 'center', fontWeight: '600' },
  textButton: { color: '#2089dc', textAlign: 'center' },
});
```

**Correct (Button with type prop):**

```tsx
import { Button } from '@rneui/themed';

// Good: Built-in variants with proper accessibility
const ButtonVariants = () => (
  <View>
    {/* Solid (default) - filled background */}
    <Button title="Primary Action" type="solid" />

    {/* Outline - bordered with transparent background */}
    <Button title="Secondary Action" type="outline" />

    {/* Clear - text only, no background or border */}
    <Button title="Tertiary Action" type="clear" />
  </View>
);

// With icons and loading states
const ActionButtons = ({ isLoading }) => (
  <View>
    <Button
      title="Save"
      type="solid"
      icon={{ name: 'save', type: 'material', color: 'white' }}
      loading={isLoading}
      disabled={isLoading}
    />

    <Button
      title="Edit"
      type="outline"
      icon={{ name: 'edit', type: 'material', color: '#2089dc' }}
    />

    <Button
      title="Delete"
      type="clear"
      icon={{ name: 'delete', type: 'material', color: 'red' }}
      titleStyle={{ color: 'red' }}
    />
  </View>
);

// Size variants
const SizedButtons = () => (
  <View>
    <Button title="Small" size="sm" />
    <Button title="Medium" size="md" />
    <Button title="Large" size="lg" />
  </View>
);

// Custom colors while keeping variants
const ThemedButtons = () => (
  <View>
    <Button title="Success" type="solid" color="success" />
    <Button title="Warning" type="outline" color="warning" />
    <Button title="Error" type="clear" color="error" />
  </View>
);
```

Reference: [React Native Elements Button](https://reactnativeelements.com/docs/components/button)
