---
title: Use useControlled Hook for Dual Modes
impact: CRITICAL
impactDescription: provides consistent controlled/uncontrolled behavior with proper warnings for mode switches
tags: comp, controlled, uncontrolled, useControlled
---

## Use useControlled Hook for Dual Modes

Use the `useControlled` hook for components that support both controlled and uncontrolled modes. This hook handles the state management and provides development warnings when switching between modes.

**Incorrect (manual controlled/uncontrolled handling):**

```typescript
function Accordion({ value, defaultValue, onValueChange }) {
  const [internalValue, setInternalValue] = useState(value ?? defaultValue ?? [])

  // No warning when switching from uncontrolled to controlled
  const currentValue = value !== undefined ? value : internalValue

  const setValue = (newValue) => {
    if (value === undefined) {
      setInternalValue(newValue)
    }
    onValueChange?.(newValue)
  }

  return ...
}
```

**Correct (useControlled hook):**

```typescript
import { useControlled } from '@base-ui/utils/useControlled'

function AccordionRoot(props: AccordionRoot.Props) {
  const {
    value: valueProp,
    defaultValue = [],
    onValueChange,
    ...otherProps
  } = props

  const [value, setValueState] = useControlled({
    controlled: valueProp,
    default: defaultValue,
    name: 'Accordion',
    state: 'value',
  })

  const setValue = React.useCallback((newValue: string[]) => {
    setValueState(newValue)
    onValueChange?.(newValue)
  }, [setValueState, onValueChange])

  return ...
}
```

**When to use:**
- Components with `value`/`defaultValue` props
- Components with `open`/`defaultOpen` props
- Any component supporting both controlled and uncontrolled modes
