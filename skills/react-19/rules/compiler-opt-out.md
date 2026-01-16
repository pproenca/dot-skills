---
title: Apply use-no-memo Directive to Opt Out of Compilation
impact: MEDIUM-HIGH
impactDescription: enables debugging and third-party library compatibility
tags: compiler, opt-out, debugging, directives
---

## Apply use-no-memo Directive to Opt Out of Compilation

When the compiler causes issues with specific components or you need to debug performance, use the 'use no memo' directive to skip compilation for that component.

**Incorrect (fighting compiler behavior):**

```tsx
// Trying to force re-renders the compiler prevents
function DebugComponent({ data }: { data: Data }) {
  console.log('Render count check')  // May not log due to memoization

  // Hack to break memoization
  const breakMemo = Math.random()

  return <div data-debug={breakMemo}>{data.value}</div>
}
```

**Correct (explicit opt-out):**

```tsx
'use no memo'

function DebugComponent({ data }: { data: Data }) {
  console.log('Render count check')  // Always logs

  return <div>{data.value}</div>
}
```

**Opting out specific hooks:**

```tsx
function ComponentWithThirdParty({ items }: { items: Item[] }) {
  // Third-party library needs exact reference
  // eslint-disable-next-line react-compiler/react-compiler
  const stableRef = useMemo(() => createThirdPartyConfig(items), [items])

  return <ThirdPartyChart config={stableRef} />
}
```

**When to opt out:**
- Debugging render behavior
- Third-party libraries requiring exact reference identity
- Legacy code with intentional impure patterns
- Performance profiling specific components

**Note:** Opt-out should be temporary. Fix the underlying issue when possible.

Reference: [Opting Out of Compilation](https://react.dev/learn/react-compiler/introduction#opting-out)
