---
title: Components receive `ref` as a normal destructured prop — drop the `forwardRef` wrapper, drop the drilling
impact: MEDIUM-HIGH
impactDescription: removes a wrapper layer, removes generic-type noise, unlocks callback-ref cleanup (React 19.2), aligns with the API that will outlive `forwardRef`
tags: rcomp, ref-as-prop, no-forwardref, callback-ref-cleanup
---

## Components receive `ref` as a normal destructured prop — drop the `forwardRef` wrapper, drop the drilling

**Pattern intent:** in React 19, `function C({ ref, ...rest })` works directly — `ref` is a regular prop. The `forwardRef(...)` wrapper is no longer needed and is on a deprecation path. Equally important: when authors dodged `forwardRef`'s awkwardness in pre-19 code, they drilled refs through props with names like `innerRef`, `inputRef`, or callback refs — those workarounds are the *in-disguise* shape of the same anti-pattern.

### Shapes to recognize

- `const X = forwardRef(function X(props, ref) { ... })` — the canonical pre-19 wrapper. Codemod removes it.
- A component accepting `innerRef` / `inputRef` / `forwardedRef` as a regular prop and applying it to a child — the author dodged `forwardRef`, but the same indirection is here.
- A callback-ref prop drilled through 2–3 components ("`ref` doesn't work, here's `setNodeRef`"). The chain of indirection often hides the real intent.
- `useRef<HTMLInputElement>()` without an explicit initial value — was valid in React 18, is a TS error in 19. Fix: `useRef<HTMLInputElement>(null)`.
- A callback ref `<div ref={(el) => (instance = el)} />` with an implicit return — TS error in 19, because the return slot is reserved for cleanup. Fix: wrap in `{ }`.
- An old `useEffect` + `ref.current.addEventListener(...)` + return-cleanup dance — could be replaced with a callback ref that returns the cleanup directly (React 19.2 callback-ref cleanup).

The canonical resolution: destructure `ref` from props in new components; codemod `forwardRef` away (`npx codemod@latest react/19/replace-forwardRef`); migrate ref-drilling props to use plain `ref`; collapse listener `useEffect`s into callback refs with returned cleanup where it shortens the code.

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

---

### In disguise — callback ref drilled through three props

The grep-friendly anti-pattern is `forwardRef(...)`. But the same break is *also* present in code that dodges `forwardRef` by manually drilling a callback ref through 2-3 prop layers. The intent is the same ("I need to give a ref to a child's underlying DOM element"); the disguise is the props named `innerRef` / `setNodeRef` / `nodeRef`. In React 19 this collapses to `ref` as a regular prop, no drilling.

**Incorrect — in disguise (callback ref drilled through three components):**

```typescript
// Three layers, none of them using forwardRef, but the same anti-pattern.

// LabeledField.tsx — wants to expose its input's DOM node to the caller
function LabeledField({ label, innerRef, ...rest }: {
  label: string
  innerRef: (el: HTMLInputElement | null) => void
}) {
  return (
    <label>
      {label}
      <Field setNodeRef={innerRef} {...rest} />
    </label>
  )
}

// Field.tsx — middle layer, just passes the ref further
function Field({ setNodeRef, ...rest }: {
  setNodeRef: (el: HTMLInputElement | null) => void
}) {
  return <BaseInput nodeRef={setNodeRef} {...rest} />
}

// BaseInput.tsx — leaf, finally uses it
function BaseInput({ nodeRef, ...rest }: {
  nodeRef: (el: HTMLInputElement | null) => void
}) {
  return <input ref={nodeRef} {...rest} />
}

// Consumer
function MyForm() {
  function focusOnLoad(el: HTMLInputElement | null) { el?.focus() }
  return <LabeledField label="Email" innerRef={focusOnLoad} />
}
// Three differently-named props (innerRef, setNodeRef, nodeRef), all carrying a ref.
// Grep for forwardRef finds nothing. The anti-pattern is still here.
```

**Correct (ref-as-prop all the way down):**

```typescript
// Same three layers, but ref is just a prop. No drilling, no rename.

function LabeledField({ label, ref, ...rest }: {
  label: string
  ref?: Ref<HTMLInputElement>
}) {
  return <label>{label}<Field ref={ref} {...rest} /></label>
}

function Field({ ref, ...rest }: { ref?: Ref<HTMLInputElement> }) {
  return <BaseInput ref={ref} {...rest} />
}

function BaseInput({ ref, ...rest }: { ref?: Ref<HTMLInputElement> }) {
  return <input ref={ref} {...rest} />
}

// Consumer
function MyForm() {
  const inputRef = useRef<HTMLInputElement>(null)
  useEffect(() => { inputRef.current?.focus() }, [])
  return <LabeledField label="Email" ref={inputRef} />
}
```

The fix isn't only "remove `forwardRef`" — it's also "remove the prop-drilling chains people built to avoid `forwardRef` in the first place." Audit for `innerRef` / `forwardedRef` / `setNodeRef` / `nodeRef` prop names; they're tell-tale.
