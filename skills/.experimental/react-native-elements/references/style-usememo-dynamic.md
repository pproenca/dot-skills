---
title: Memoize Dynamic Styles with useMemo
impact: MEDIUM
impactDescription: Prevents style object recreation on each render; reduces garbage collection and avoids unnecessary re-renders of styled children
tags: style, performance, hooks, memoization
---

## Memoize Dynamic Styles with useMemo

When styles depend on props or state, computing them directly in the render function creates new object references every render. This defeats React's reconciliation optimizations and can cause child components to re-render unnecessarily. Using useMemo ensures dynamic styles are only recalculated when their dependencies change.

**Incorrect (computing styles in render):**

```tsx
// Bad: Style object recreated on every render
function DynamicButton({ isActive, size }: Props) {
  // New object created each render, even if isActive/size unchanged
  const buttonStyle = {
    backgroundColor: isActive ? '#2089dc' : '#ccc',
    padding: size === 'large' ? 20 : 10,
    opacity: isActive ? 1 : 0.6,
  };

  return (
    <Button
      title="Action"
      buttonStyle={buttonStyle}
    />
  );
}
```

**Correct (useMemo for dynamic styles with proper deps):**

```tsx
import { useMemo } from 'react';
import { Button } from '@rneui/themed';

function DynamicButton({ isActive, size }: Props) {
  // Good: Style only recalculated when isActive or size changes
  const buttonStyle = useMemo(
    () => ({
      backgroundColor: isActive ? '#2089dc' : '#ccc',
      padding: size === 'large' ? 20 : 10,
      opacity: isActive ? 1 : 0.6,
    }),
    [isActive, size]
  );

  return (
    <Button
      title="Action"
      buttonStyle={buttonStyle}
    />
  );
}
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
