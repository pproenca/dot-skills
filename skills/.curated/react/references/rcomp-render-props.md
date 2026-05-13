---
title: Use a render prop only when the parent needs to control *rendering* — for logic reuse, prefer a custom hook
impact: LOW-MEDIUM
impactDescription: keeps the inversion-of-rendering use case for render props (where it's irreplaceable), routes logic-sharing through hooks (simpler, composable)
tags: rcomp, render-props, inversion-of-rendering, hooks-vs-renderprops
---

## Use a render prop only when the parent needs to control *rendering* — for logic reuse, prefer a custom hook

**Pattern intent:** render props (and "children as function") let a component expose its state to the caller and let the caller decide the JSX. The pattern is still useful when **the rendering shape itself is the unit of variation**. When the variation is purely logic ("this hook tracks X, then I render however I want anyway"), a custom hook is simpler and more composable.

### Shapes to recognize

- A render-prop API used to share state-tracking logic that has nothing to do with rendering — should be a custom hook (e.g., `useMouse()` instead of `<Mouse>{({x,y}) => ...}</Mouse>`).
- A wrapper component that exists only to invoke `useEffect` and `useState`, then call back through a render prop — a hook wears that role naturally.
- A pre-React-19 render-prop component for data fetching — the canonical answer is now `use(promise)` + Suspense (see [`data-use-hook.md`](data-use-hook.md)), not render props.
- A render prop that receives 6+ values and the caller destructures them — the caller almost always wants the values *and* the rendering control; consider returning a hook tuple instead.
- Two render props on the same component (e.g., `renderItem` and `renderEmpty`) — that's *named slots*, which is the composition pattern in [`rcomp-composition.md`](rcomp-composition.md); pass `children` plus a fallback prop instead.

The canonical resolution: ask "is the *rendering* the thing the caller varies?" If yes, render prop or children-as-function. If no (it's logic, state, or data), a custom hook.

---

**Incorrect (render prop just to share state — should be a hook):**

```typescript
function Mouse({ render }: { render: (pos: { x: number; y: number }) => ReactNode }) {
  const [pos, setPos] = useState({ x: 0, y: 0 })

  useEffect(() => {
    const handler = (e: MouseEvent) => setPos({ x: e.clientX, y: e.clientY })
    window.addEventListener('mousemove', handler)
    return () => window.removeEventListener('mousemove', handler)
  }, [])

  return <>{render(pos)}</>
}

// Usage forces a render prop even though all callers want different JSX
<Mouse render={(pos) => <Cursor x={pos.x} y={pos.y} />} />
```

**Correct (custom hook for logic, JSX written naturally):**

```typescript
function useMouse() {
  const [pos, setPos] = useState({ x: 0, y: 0 })
  useEffect(() => {
    const handler = (e: MouseEvent) => setPos({ x: e.clientX, y: e.clientY })
    window.addEventListener('mousemove', handler)
    return () => window.removeEventListener('mousemove', handler)
  }, [])
  return pos
}

// Each consumer writes JSX naturally
function CursorOverlay() {
  const pos = useMouse()
  return <Cursor x={pos.x} y={pos.y} />
}
```

---

**Correct (render prop for genuine inversion of rendering — a sizing wrapper):**

```typescript
function ResizableBox({
  children,
}: {
  children: (size: { width: number; height: number }) => ReactNode
}) {
  const [size, setSize] = useState({ width: 200, height: 100 })

  return (
    <div
      style={{ width: size.width, height: size.height, resize: 'both', overflow: 'auto' }}
      onMouseUp={(e) => {
        const el = e.currentTarget
        setSize({ width: el.clientWidth, height: el.clientHeight })
      }}
    >
      {children(size)}
    </div>
  )
}

// The caller wants different JSX based on the current size — render prop is justified
<ResizableBox>
  {({ width, height }) => (
    width > 300 ? <BigChart w={width} h={height} /> : <SmallChart w={width} h={height} />
  )}
</ResizableBox>
```

The render-prop API earns its weight here because the *output JSX* genuinely depends on the value the component owns.

**Alternative (children as function — same idea, different syntax):**

```typescript
<ResizableBox>
  {(size) => <Chart size={size} />}
</ResizableBox>
```

Both are render-prop patterns. The choice is style — most modern React codebases use children-as-function.
