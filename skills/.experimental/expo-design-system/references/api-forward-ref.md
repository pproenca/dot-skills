---
title: Forward Refs From Every Leaf Component
impact: HIGH
impactDescription: preserves focus and measurement access for callers
tags: api, refs, forwardref, focus
---

## Forward Refs From Every Leaf Component

A wrapper that swallows the ref leaves callers unable to focus, scroll to, or measure the underlying native view — breaking multi-field forms and scroll-to-error flows. Forwarding the ref to the leaf native element keeps those imperative capabilities available without exposing internals.

**Incorrect (no ref forwarding — focus never reaches the input):**

```typescript
function AppTextInput({ label, ...props }: AppTextInputProps) {
  return <TextInput style={styles.input} {...props} />
}

// A form wants to advance focus after submit, but there is nothing to call:
const dosageRef = useRef<TextInput>(null)
<AppTextInput ref={dosageRef} label="Dosage" /> // ref attaches to nothing
dosageRef.current?.focus() // always null — focus cannot move
```

**Correct (accept ref as a prop and pass it to the leaf):**

```typescript
// React 19 (React Native 0.81+): ref is a regular prop, so no forwardRef wrapper is needed
type AppTextInputProps = TextInputProps & { label: string; ref?: Ref<TextInput> }

function AppTextInput({ label, ref, ...props }: AppTextInputProps) {
  return <TextInput ref={ref} style={styles.input} {...props} />
}

const dosageRef = useRef<TextInput>(null)
<AppTextInput ref={dosageRef} label="Dosage" />
// onSubmitEditing of the previous field can now call dosageRef.current?.focus()
```

On React 18 and earlier, wrap the component in `forwardRef` to achieve the same result.

Reference: [Passing refs as props in React 19](https://react.dev/blog/2024/12/05/react-19)
