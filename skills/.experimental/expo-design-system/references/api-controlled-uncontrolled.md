---
title: Support Both Controlled and Uncontrolled State
impact: HIGH
impactDescription: prevents duplicate state wiring at every call site
tags: api, state, controlled, hooks
---

## Support Both Controlled and Uncontrolled State

A controlled-only input forces every screen — even ones that never read the value — to declare state and a handler. Accepting an optional `value` with an internal fallback lets simple call sites stay terse while forms keep full control, matching the behavior of platform inputs.

**Incorrect (controlled-only forces boilerplate everywhere):**

```typescript
type ToggleProps = { value: boolean; onValueChange: (next: boolean) => void }

function ReminderToggle({ value, onValueChange }: ToggleProps) {
  return <Switch value={value} onValueChange={onValueChange} />
}

// Even a screen that does not observe the value must own state for it:
const [on, setOn] = useState(false)
<ReminderToggle value={on} onValueChange={setOn} />
```

**Correct (optional control with an internal fallback):**

```typescript
type ToggleProps = { value?: boolean; defaultValue?: boolean; onValueChange?: (next: boolean) => void }

function ReminderToggle({ value, defaultValue = false, onValueChange }: ToggleProps) {
  const [internal, setInternal] = useState(defaultValue)
  const isControlled = value !== undefined
  const current = isControlled ? value : internal
  const handle = (next: boolean) => {
    if (!isControlled) setInternal(next)
    onValueChange?.(next)
  }
  return <Switch value={current} onValueChange={handle} />
}
// Simple screens write <ReminderToggle defaultValue />; a form still controls it fully.
```

Reference: [React controlled components](https://react.dev/learn/sharing-state-between-components)
