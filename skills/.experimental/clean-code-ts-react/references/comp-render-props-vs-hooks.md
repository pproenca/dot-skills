---
title: Prefer Hooks Over Render Props for Logic Reuse
impact: MEDIUM-HIGH
impactDescription: simplifies composition and improves type inference
tags: comp, hooks, render-props, react
---

## Prefer Hooks Over Render Props for Logic Reuse

Render props were React 16's answer to sharing stateful logic. Hooks (since 16.8) do the same job with less indentation, no "wrapper hell," better TypeScript inference, and trivial composition with other hooks. Keep render props for the case they're actually for — injecting markup, not just logic.

**Incorrect (render prop for what should be a hook):**

```tsx
// Verbose; nesting two providers needs two layers of render-prop indentation;
// inference for the inner function's params is fiddly.
function MousePosition({ children }: { children: (p: { x: number; y: number }) => ReactNode }) {
  const [pos, setPos] = useState({ x: 0, y: 0 });
  useEffect(() => {
    const handler = (e: MouseEvent) => setPos({ x: e.clientX, y: e.clientY });
    window.addEventListener('mousemove', handler);
    return () => window.removeEventListener('mousemove', handler);
  }, []);
  return <>{children(pos)}</>;
}

function MouseIndicator() {
  return <MousePosition>{({ x, y }) => <div>{x},{y}</div>}</MousePosition>;
}
```

**Correct (hook composes cleanly with other hooks):**

```tsx
// Use the value alongside any other hook; no extra indentation.
function useMousePosition(): { x: number; y: number } {
  const [pos, setPos] = useState({ x: 0, y: 0 });
  useEffect(() => {
    const handler = (e: MouseEvent) => setPos({ x: e.clientX, y: e.clientY });
    window.addEventListener('mousemove', handler);
    return () => window.removeEventListener('mousemove', handler);
  }, []);
  return pos;
}

function MouseIndicator() {
  const { x, y } = useMousePosition();
  return <div>{x},{y}</div>;
}
```

**When NOT to apply this pattern:**
- Components that genuinely need to wrap children in markup — a `<Popover>` that renders an overlay around its consumer; a `<DragOverlay>` from dnd-kit. Render props or compound components are the right tool.
- Library APIs where render props are the established convention — many chart libraries (Recharts, Visx) use them for cell-level customization; follow their grain.
- Legacy code where converting a render prop to a hook is a wide-spread, low-payoff change.

**Why this matters:** Picking hooks for logic reuse and composition for markup reuse keeps each tool used for what it's actually good at — the same shape as command-query separation.

Reference: [Clean Code, Chapter 10: Classes (substituted: Composition)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [React Docs: Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
