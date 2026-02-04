---
title: Wrap RNE Components Correctly
impact: LOW
impactDescription: prevents 100% of prop-forwarding bugs and maintains ref access
tags: adv, composition, forwardRef, typescript
---

## Wrap RNE Components Correctly

When creating custom wrapper components around React Native Elements, you must use forwardRef and properly spread props to maintain theme context inheritance and allow consumers to pass refs. Breaking the prop chain or theme context causes styling inconsistencies and limits component usability.

**Incorrect (breaking theme context and ref forwarding):**

```tsx
import { Button, ButtonProps } from '@rneui/themed';

// Bad: No ref forwarding, props not spread correctly
const MyButton = (props: { label: string; onPress: () => void }) => {
  return (
    <Button
      title={props.label}
      onPress={props.onPress}
      // Other ButtonProps cannot be passed through
    />
  );
};

// Bad: Wrapping with extra View breaks theme context
const WrappedButton = (props: ButtonProps) => {
  return (
    <View>
      <Button {...props} />
    </View>
  );
};
```

**Correct (using forwardRef with proper prop spreading):**

```tsx
import React, { forwardRef } from 'react';
import { Button, ButtonProps } from '@rneui/themed';
import type { Button as ButtonType } from '@rneui/base';

// Good: forwardRef preserves ref access, props spread maintains flexibility
interface MyButtonProps extends ButtonProps {
  variant?: 'primary' | 'secondary';
}

const MyButton = forwardRef<ButtonType, MyButtonProps>(
  ({ variant = 'primary', ...props }, ref) => {
    return (
      <Button
        ref={ref}
        type={variant === 'secondary' ? 'outline' : 'solid'}
        {...props}
      />
    );
  }
);

MyButton.displayName = 'MyButton';

// Usage: All ButtonProps work, refs work, theme inherited
<MyButton
  ref={buttonRef}
  title="Submit"
  onPress={handlePress}
  loading={isLoading}
/>
```

Reference: [React Native Elements Components](https://reactnativeelements.com/docs)
