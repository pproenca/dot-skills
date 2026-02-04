---
title: Test Components with React Native Testing Library
impact: MEDIUM
impactDescription: catches 80% of bugs before production
tags: test, testing-library, components, unit-testing
---

## Test Components with React Native Testing Library

Use `@testing-library/react-native` for testing components the way users interact with them.

**Incorrect (testing implementation details):**

```typescript
import { Counter } from '../Counter';

describe('Counter', () => {
  it('has correct internal state', () => {
    const wrapper = shallow(<Counter />);
    expect(wrapper.state('count')).toBe(0);  // Testing internals
    wrapper.instance().handleIncrement();     // Calling private methods
    expect(wrapper.state('count')).toBe(1);
  });
});
// Brittle tests break when implementation changes
```

**Correct (testing user behavior):**

```bash
npx expo install @testing-library/react-native @testing-library/jest-native
```

```typescript
// components/Counter.tsx
import { View, Text, Pressable } from 'react-native';
import { useState } from 'react';

export function Counter({ initialValue = 0 }: { initialValue?: number }) {
  const [count, setCount] = useState(initialValue);
  return (
    <View>
      <Text testID="count-text">Count: {count}</Text>
      <Pressable onPress={() => setCount(c => c + 1)} testID="increment-button">
        <Text>Increment</Text>
      </Pressable>
    </View>
  );
}
```

```typescript
// components/__tests__/Counter.test.tsx
import { render, screen, fireEvent } from '@testing-library/react-native';
import { Counter } from '../Counter';

describe('Counter', () => {
  it('renders initial value', () => {
    render(<Counter initialValue={5} />);
    expect(screen.getByText('Count: 5')).toBeTruthy();
  });

  it('increments count when button pressed', () => {
    render(<Counter />);
    fireEvent.press(screen.getByTestId('increment-button'));
    expect(screen.getByText('Count: 1')).toBeTruthy();
  });
});
```

**Best practices:** Use `testID` for selection, test behavior not implementation.

Reference: [Testing Library - React Native](https://callstack.github.io/react-native-testing-library/)
