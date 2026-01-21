---
title: Hook Namespace Exports
impact: MEDIUM
impactDescription: provides consistent type access pattern across hooks and components
tags: comp, hooks, namespace, types
---

## Hook Namespace Exports

Export hook types using namespace pattern for Parameters and ReturnValue to match component type export patterns.

**Incorrect (separate interface exports):**

```typescript
export interface UseButtonParams {
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
}

export interface UseButtonReturn {
  getRootProps: () => React.HTMLAttributes<HTMLButtonElement>
}

export function useButton(params: UseButtonParams): UseButtonReturn {
  // ...
}
```

**Correct (namespace exports):**

```typescript
interface UseButtonParameters {
  disabled?: boolean | undefined
  type?: 'button' | 'submit' | 'reset' | undefined
}

interface UseButtonReturnValue {
  getRootProps: () => React.HTMLAttributes<HTMLButtonElement>
}

export function useButton(params: UseButtonParameters): UseButtonReturnValue {
  // ...
}

export namespace useButton {
  export type Parameters = UseButtonParameters
  export type ReturnValue = UseButtonReturnValue
}

// Usage:
const params: useButton.Parameters = { disabled: true }
const result: useButton.ReturnValue = useButton(params)
```

**When to use:**
- All exported hooks
- Maintains consistency with component namespace patterns (Component.Props, Component.State)
