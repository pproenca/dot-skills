---
title: Pass ref as a Prop Instead of forwardRef
impact: HIGH
impactDescription: removes forwardRef boilerplate; ref becomes a normal prop
tags: tsx, ref, forwardref, react-19
---

## Pass ref as a Prop Instead of forwardRef

React 19 lets function components receive `ref` as an ordinary prop and deprecates `forwardRef`. Declaring `ref` in the props type drops the generic-argument gymnastics of `forwardRef` and types exactly like any other prop.

**Incorrect (forwardRef wrapper, deprecated in React 19):**

```tsx
import { forwardRef } from "react"

const SearchInput = forwardRef<HTMLInputElement, SearchInputProps>(
  function SearchInput({ placeholder }, ref) {
    return <input ref={ref} placeholder={placeholder} />
  },
)
```

**Correct (ref is a normal prop):**

```tsx
interface SearchInputProps {
  placeholder: string
  ref?: React.Ref<HTMLInputElement>
}

function SearchInput({ placeholder, ref }: SearchInputProps) {
  return <input ref={ref} placeholder={placeholder} />
}
```

For components that forward every native attribute, use `React.ComponentPropsWithRef<"input">` so `ref` is typed automatically — see [`tsx-extend-native-props`](tsx-extend-native-props.md).

Reference: [React 19 — ref as a prop](https://react.dev/blog/2024/12/05/react-19#ref-as-a-prop)
