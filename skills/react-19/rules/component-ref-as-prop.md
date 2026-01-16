---
title: Use ref as a Prop Instead of forwardRef
impact: MEDIUM
impactDescription: eliminates forwardRef wrapper, reduces code by 30-50%
tags: component, ref, forwardRef, simplification
---

## Use ref as a Prop Instead of forwardRef

React 19 allows refs to be passed as regular props. The `forwardRef` wrapper is no longer necessary and adds unnecessary complexity.

**Incorrect (legacy forwardRef pattern):**

```tsx
import { forwardRef } from 'react'

const TextInput = forwardRef<HTMLInputElement, InputProps>(
  function TextInput({ label, ...props }, ref) {
    return (
      <div>
        <label>{label}</label>
        <input ref={ref} {...props} />
      </div>
    )
  }
)

// Usage
function Form() {
  const inputRef = useRef<HTMLInputElement>(null)
  return <TextInput ref={inputRef} label="Name" />
}
```

**Correct (ref as prop in React 19):**

```tsx
function TextInput({
  label,
  ref,
  ...props
}: InputProps & { ref?: React.Ref<HTMLInputElement> }) {
  return (
    <div>
      <label>{label}</label>
      <input ref={ref} {...props} />
    </div>
  )
}

// Usage - unchanged
function Form() {
  const inputRef = useRef<HTMLInputElement>(null)
  return <TextInput ref={inputRef} label="Name" />
}
```

**Benefits:**
- Cleaner component API
- No wrapper function needed
- TypeScript inference works naturally
- Easier to read and maintain

**Migration:** A codemod is available to automatically convert forwardRef components:

```bash
npx codemod@latest react/19/replace-forward-ref
```

Reference: [React 19 ref as prop](https://react.dev/blog/2024/12/05/react-19#ref-as-a-prop)
