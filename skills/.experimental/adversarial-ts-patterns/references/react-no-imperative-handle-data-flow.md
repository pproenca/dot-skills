---
title: No useImperativeHandle for data flow that props express
tags: react, refs, imperative-handle, data-flow
---

## No useImperativeHandle for data flow that props express

The wrong default is exposing child methods through `useImperativeHandle` — `ref.current.open()`, `ref.current.setValue(x)`, `ref.current.getData()` — an OO instance-method port that turns React's declarative data flow back into method calls on an object handle. State pushed or pulled through a ref is invisible to React's render cycle at the call site — the parent holds no state that renders can depend on, and the child's behavior can no longer be understood from its props. The react.dev reference is direct — do not overuse refs; if you can express something as a prop, you should not use a ref.

**Evidence of violation:** a `useImperativeHandle` whose exposed methods read or write child state that a prop could carry — `open()`/`close()` instead of an `isOpen` prop, `setValue()` instead of `value`/`onChange`, `getData()` instead of lifting the data up. The carve-out is genuinely imperative DOM behavior with no declarative equivalent — focus, text selection, scrolling a node into view, media play/pause — where exposing a narrowed handle is exactly what the API is for.

**Incorrect (parent drives child through method calls):**

```tsx
type ConfirmDialogHandle = { open(): void; close(): void }

// React 19 ref-as-prop; parent holds no renderable open state
function ConfirmDialog({ ref }: { ref: React.Ref<ConfirmDialogHandle> }) {
  const [isOpen, setIsOpen] = useState(false)
  useImperativeHandle(ref, () => ({
    open: () => setIsOpen(true),
    close: () => setIsOpen(false),
  }))
  /* ... */
}

// Parent: dialogRef.current?.open() from a click handler
const dialogRef = useRef<ConfirmDialogHandle>(null)
```

**Correct (the open state lives where the decision is made):**

```tsx
function CheckoutPage() {
  const [confirmOpen, setConfirmOpen] = useState(false)
  return (
    <>
      <button onClick={() => setConfirmOpen(true)}>Place order</button>
      <ConfirmDialog isOpen={confirmOpen} onClose={() => setConfirmOpen(false)} />
    </>
  )
}
```

Reference: [react.dev — useImperativeHandle (avoid overusing refs)](https://react.dev/reference/react/useImperativeHandle#exposing-your-own-imperative-methods)
