---
title: "Use Pressable with active:/focus:/disabled: States"
impact: MEDIUM
impactDescription: eliminates 10-15 lines of manual state management
tags: state, pressable, active, focus, disabled
---

## Use Pressable with active:/focus:/disabled: States

Uniwind supports `active:`, `focus:`, and `disabled:` pseudo-classes on Pressable components for touch feedback.

**Incorrect (manual press state management):**

```tsx
function Button({ onPress }: ButtonProps) {
  const [isPressed, setIsPressed] = useState(false)

  return (
    <Pressable
      onPressIn={() => setIsPressed(true)}
      onPressOut={() => setIsPressed(false)}
      onPress={onPress}
      className={isPressed ? 'bg-primary/80' : 'bg-primary'}
    >
      <Text className="text-white">Press me</Text>
    </Pressable>
  )
}
```

**Correct (pseudo-class states):**

```tsx
function Button({ onPress, disabled }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      className="
        bg-primary
        active:bg-primary/80
        focus:ring-2 focus:ring-primary/50
        disabled:opacity-50 disabled:bg-gray-400
      "
    >
      <Text className="text-white">Press me</Text>
    </Pressable>
  )
}
```

**Available pseudo-classes:**

| Pseudo-class | Trigger |
|--------------|---------|
| `active:` | While pressed/touched |
| `focus:` | When focused (accessibility) |
| `disabled:` | When disabled prop is true |

**Note:** `hover:` is not supported on native (no mouse). Use `web:hover:` for web targets.

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)
