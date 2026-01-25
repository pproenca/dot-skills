---
title: Use Value Prop for Controlled Select Components
impact: HIGH
impactDescription: prevents state desync between UI and application
tags: comp, select, controlled, state, forms
---

## Use Value Prop for Controlled Select Components

Select components must use the `value` prop for controlled state. Using `defaultValue` in controlled scenarios causes state desync.

**Incorrect (defaultValue in controlled component):**

```tsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

function StatusSelect({ status, onStatusChange }) {
  return (
    <Select defaultValue={status} onValueChange={onStatusChange}>
      <SelectTrigger>
        <SelectValue placeholder="Select status" />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="pending">Pending</SelectItem>
        <SelectItem value="active">Active</SelectItem>
        <SelectItem value="completed">Completed</SelectItem>
      </SelectContent>
    </Select>
  )
  // defaultValue only sets initial value
  // If status prop changes, UI won't update
}
```

**Correct (value for controlled state):**

```tsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

function StatusSelect({ status, onStatusChange }) {
  return (
    <Select value={status} onValueChange={onStatusChange}>
      <SelectTrigger>
        <SelectValue placeholder="Select status" />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="pending">Pending</SelectItem>
        <SelectItem value="active">Active</SelectItem>
        <SelectItem value="completed">Completed</SelectItem>
      </SelectContent>
    </Select>
  )
}
```

**When to use each:**
- `value` + `onValueChange`: Form state, external state management
- `defaultValue`: Uncontrolled forms, initial values only

Reference: [Radix UI Select](https://www.radix-ui.com/primitives/docs/components/select)
