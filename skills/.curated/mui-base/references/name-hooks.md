---
title: Hook Naming with use Prefix
impact: HIGH
impactDescription: follows React convention and enables lint rule enforcement
tags: name, hooks, use, convention
---

## Hook Naming with use Prefix

Name hooks with `use` prefix in camelCase. This follows React conventions and enables the Rules of Hooks lint plugin.

**Incorrect (anti-pattern):**

```typescript
function UseButton(params) { ... }
function buttonHook(params) { ... }
function getButtonProps(params) { ... }
function createButton(params) { ... }
```

**Correct (recommended):**

```typescript
function useButton(params: useButton.Parameters): useButton.ReturnValue {
  // ...
}

function useAccordionItem(params: useAccordionItem.Parameters): useAccordionItem.ReturnValue {
  // ...
}

function useControlled<T>(params: UseControlledParameters<T>): [T, (value: T) => void] {
  // ...
}

function useRenderElement(
  tag: keyof JSX.IntrinsicElements,
  props: object,
  options: UseRenderElementOptions
): React.ReactElement {
  // ...
}
```

**When to use:**
- All functions that use React hooks internally
- Functions following the composition pattern that return props objects
