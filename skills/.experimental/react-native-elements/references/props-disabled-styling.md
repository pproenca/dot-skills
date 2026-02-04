---
title: Configure disabledStyle for Visual Feedback
impact: MEDIUM-HIGH
impactDescription: improves task completion rate by 20-30% with clear disabled feedback
tags: props, buttons, disabled, styling, accessibility
---

## Configure disabledStyle for Visual Feedback

The Button component's disabledStyle and disabledTitleStyle props allow you to provide clear visual feedback when a button is disabled. Without explicit disabled styling, users may not understand why a button isn't responding to their taps, leading to confusion and frustration. Proper disabled styling improves both UX and accessibility.

**Incorrect (disabled without visual indication):**

```tsx
// Bad: disabled prop without visual styling
const SubmitButton = ({ canSubmit, onSubmit }) => (
  <Button
    title="Submit"
    onPress={onSubmit}
    disabled={!canSubmit}
    // No visual indication that button is disabled!
  />
);

// Bad: Only using opacity without proper styling
const BadDisabledButton = ({ disabled, onPress }) => (
  <TouchableOpacity
    onPress={onPress}
    disabled={disabled}
    style={{ opacity: disabled ? 0.5 : 1 }}
  >
    <Text>Submit</Text>
  </TouchableOpacity>
);

// Bad: Inconsistent manual disabled handling
const InconsistentButton = ({ disabled }) => (
  <Button
    title="Save"
    disabled={disabled}
    buttonStyle={disabled ? { backgroundColor: 'gray' } : {}}
    // Title color remains the same - unclear disabled state
  />
);
```

**Correct (disabled with disabledStyle and disabledTitleStyle):**

```tsx
import { Button } from '@rneui/themed';

// Good: Clear disabled state with both button and title styling
const SubmitButton = ({ canSubmit, onSubmit }) => (
  <Button
    title="Submit"
    onPress={onSubmit}
    disabled={!canSubmit}
    disabledStyle={{
      backgroundColor: '#E0E0E0',
      borderColor: '#BDBDBD',
    }}
    disabledTitleStyle={{
      color: '#9E9E9E',
    }}
  />
);

// Good: Outline button with proper disabled styling
const OutlineDisabledButton = ({ disabled, onPress }) => (
  <Button
    title="Edit"
    type="outline"
    onPress={onPress}
    disabled={disabled}
    disabledStyle={{
      borderColor: '#E0E0E0',
      backgroundColor: 'transparent',
    }}
    disabledTitleStyle={{
      color: '#BDBDBD',
    }}
  />
);

// Good: Set defaults via theme for consistency
import { createTheme, ThemeProvider } from '@rneui/themed';

const theme = createTheme({
  components: {
    Button: {
      disabledStyle: {
        backgroundColor: '#E0E0E0',
      },
      disabledTitleStyle: {
        color: '#9E9E9E',
      },
    },
  },
});

// All buttons now have consistent disabled styling
const App = () => (
  <ThemeProvider theme={theme}>
    <Button title="Submit" disabled />
    <Button title="Cancel" disabled />
  </ThemeProvider>
);
```

Reference: [React Native Elements Button](https://reactnativeelements.com/docs/components/button)
