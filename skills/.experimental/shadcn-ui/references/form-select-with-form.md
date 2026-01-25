---
title: Use Controller for Select in React Hook Form
impact: MEDIUM-HIGH
impactDescription: enables validation for non-native select components
tags: form, select, controller, react-hook-form, validation
---

## Use Controller for Select in React Hook Form

shadcn/ui Select is not a native input, so `register()` won't work. Use Controller from React Hook Form to integrate Select with form validation.

**Incorrect (register with Select):**

```tsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

function RoleSelect({ register }) {
  return (
    <Select {...register("role")}>  {/* Won't work - Select isn't an input */}
      <SelectTrigger>
        <SelectValue placeholder="Select role" />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="admin">Admin</SelectItem>
        <SelectItem value="user">User</SelectItem>
      </SelectContent>
    </Select>
  )
}
```

**Correct (Controller wrapper):**

```tsx
import { Controller, useForm } from "react-hook-form"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"

function RoleSelect() {
  const { control, formState: { errors } } = useForm()

  return (
    <Controller
      name="role"
      control={control}
      rules={{ required: "Please select a role" }}
      render={({ field }) => (
        <Field data-invalid={!!errors.role}>
          <FieldLabel>Role</FieldLabel>
          <Select value={field.value} onValueChange={field.onChange}>
            <SelectTrigger>
              <SelectValue placeholder="Select role" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="admin">Admin</SelectItem>
              <SelectItem value="user">User</SelectItem>
            </SelectContent>
          </Select>
          {errors.role && <FieldError>{errors.role.message}</FieldError>}
        </Field>
      )}
    />
  )
}
```

**Also requires Controller:** Checkbox, Switch, RadioGroup, Combobox, DatePicker

Reference: [React Hook Form Controller](https://react-hook-form.com/docs/usecontroller)
