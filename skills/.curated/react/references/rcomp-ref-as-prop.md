---
title: Use ref as a Regular Prop, Not forwardRef
impact: MEDIUM-HIGH
impactDescription: removes forwardRef wrapper, enables ref cleanup, aligns with the React 19 idiom that will outlive forwardRef
tags: rcomp, ref, forwardRef, useRef, cleanup
---

## Use ref as a Regular Prop, Not forwardRef

In React 19, function components receive `ref` as a regular prop. The `forwardRef` wrapper is no longer needed and will be deprecated in a future major. Always destructure `ref` from props in new components.

**Incorrect (forwardRef wrapper):**

```typescript
import { forwardRef } from 'react'

interface InputProps {
  placeholder?: string
  type?: string
}

const CustomInput = forwardRef<HTMLInputElement, InputProps>(
  function CustomInput({ placeholder, type = 'text' }, ref) {
    return <input ref={ref} placeholder={placeholder} type={type} />
  }
)
// ❌ Extra wrapper, deprecated path, generic noise
```

**Correct (ref as a regular prop):**

```typescript
import { Ref } from 'react'

interface InputProps {
  ref?: Ref<HTMLInputElement>
  placeholder?: string
  type?: string
}

function CustomInput({ ref, placeholder, type = 'text' }: InputProps) {
  return <input ref={ref} placeholder={placeholder} type={type} />
}

// Usage stays the same
function Form() {
  const inputRef = useRef<HTMLInputElement>(null)
  return <CustomInput ref={inputRef} placeholder="Email" />
}
```

**Codemod** (existing forwardRef components): `npx codemod@latest react/19/replace-forwardRef`

---

**useRef now requires an explicit initial value (TypeScript):**

```typescript
// ❌ Was valid in React 18, now a TS error in React 19
const ref = useRef<HTMLInputElement>()

// ✅ Pass null (or another initial value) explicitly
const ref = useRef<HTMLInputElement>(null)
```

All refs are mutable in React 19; the deprecated `MutableRefObject` distinction is gone.

---

**Callback refs can return a cleanup function (React 19):**

This replaces a common `useEffect` + ref pattern:

```typescript
// ❌ Old pattern — wire up listener with effect, tear down on unmount
function Tooltip({ children }: { children: ReactNode }) {
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const el = ref.current
    if (!el) return
    el.addEventListener('mouseenter', show)
    return () => el.removeEventListener('mouseenter', show)
  }, [])

  return <div ref={ref}>{children}</div>
}
```

```typescript
// ✅ New pattern — callback ref with cleanup
function Tooltip({ children }: { children: ReactNode }) {
  return (
    <div
      ref={(el) => {
        if (!el) return
        el.addEventListener('mouseenter', show)
        return () => el.removeEventListener('mouseenter', show)
      }}
    >
      {children}
    </div>
  )
}
```

**Important (TypeScript breaking change):** Callback refs must use a block body. Implicit returns are now rejected because the return slot is reserved for cleanup.

```typescript
// ❌ Type error in React 19
<div ref={(el) => (instance = el)} />

// ✅ Wrap in braces — no return value
<div ref={(el) => { instance = el }} />
```

**Codemod:** `npx types-react-codemod@latest preset-19` (includes `no-implicit-ref-callback-return`).
