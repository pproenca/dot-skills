---
title: Use isActive Option for Focus Management
impact: HIGH
impactDescription: prevents input conflicts between components
tags: input, focus, isactive, components, ink
---

## Use isActive Option for Focus Management

Use the `isActive` option with `useInput` to enable/disable input handling based on focus state. This prevents multiple components from competing for keyboard input.

**Incorrect (all components receive all input):**

```typescript
function TextInput({ onSubmit }: { onSubmit: (value: string) => void }) {
  const [value, setValue] = useState('')

  useInput((input, key) => {
    if (key.return) {
      onSubmit(value)
    } else if (input) {
      setValue(v => v + input)
    }
  })
  // Always active - conflicts with other inputs

  return <Text>{value}</Text>
}

function App() {
  return (
    <Box flexDirection="column">
      <TextInput onSubmit={handleName} />
      <TextInput onSubmit={handleEmail} />
      {/* Both inputs receive the same keystrokes */}
    </Box>
  )
}
```

**Correct (focus-aware input handling):**

```typescript
function TextInput({
  onSubmit,
  isFocused
}: {
  onSubmit: (value: string) => void
  isFocused: boolean
}) {
  const [value, setValue] = useState('')

  useInput((input, key) => {
    if (key.return) {
      onSubmit(value)
    } else if (input) {
      setValue(v => v + input)
    }
  }, { isActive: isFocused })  // Only receives input when focused

  return (
    <Text color={isFocused ? 'cyan' : undefined}>
      {isFocused ? '> ' : '  '}{value}
    </Text>
  )
}

function App() {
  const [focusIndex, setFocusIndex] = useState(0)

  return (
    <Box flexDirection="column">
      <TextInput onSubmit={handleName} isFocused={focusIndex === 0} />
      <TextInput onSubmit={handleEmail} isFocused={focusIndex === 1} />
    </Box>
  )
}
```

**Benefits:**
- Only the focused component receives keyboard events
- Clear visual indication of which component is active
- Prevents input from being duplicated across components

Reference: [Ink Documentation - useInput options](https://github.com/vadimdemedes/ink#useinputinputhandler-options)
