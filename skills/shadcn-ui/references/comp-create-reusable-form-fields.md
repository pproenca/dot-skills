---
title: Create Reusable Form Field Components
impact: MEDIUM
impactDescription: reduces boilerplate and ensures consistency
tags: comp, form, field, reusable, composition
---

## Create Reusable Form Field Components

Extract common form field patterns into reusable components to reduce boilerplate and maintain consistency across forms.

**Incorrect (repeated form field boilerplate):**

```tsx
function UserForm() {
  const form = useForm<UserFormValues>({
    resolver: zodResolver(userSchema),
  })

  return (
    <Form {...form}>
      <FormField
        control={form.control}
        name="firstName"
        render={({ field }) => (
          <FormItem>
            <FormLabel>First Name</FormLabel>
            <FormControl>
              <Input placeholder="Enter first name" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="lastName"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Last Name</FormLabel>
            <FormControl>
              <Input placeholder="Enter last name" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      {/* 10 more fields with identical structure... */}
    </Form>
  )
}
```

**Correct (reusable field components):**

```tsx
// components/form/text-field.tsx
interface TextFieldProps<T extends FieldValues> {
  control: Control<T>
  name: Path<T>
  label: string
  placeholder?: string
  description?: string
  type?: "text" | "email" | "password"
}

function TextField<T extends FieldValues>({
  control,
  name,
  label,
  placeholder,
  description,
  type = "text",
}: TextFieldProps<T>) {
  return (
    <FormField
      control={control}
      name={name}
      render={({ field }) => (
        <FormItem>
          <FormLabel>{label}</FormLabel>
          <FormControl>
            <Input type={type} placeholder={placeholder} {...field} />
          </FormControl>
          {description && <FormDescription>{description}</FormDescription>}
          <FormMessage />
        </FormItem>
      )}
    />
  )
}

// components/form/select-field.tsx
interface SelectFieldProps<T extends FieldValues> {
  control: Control<T>
  name: Path<T>
  label: string
  placeholder?: string
  options: { value: string; label: string }[]
}

function SelectField<T extends FieldValues>({
  control,
  name,
  label,
  placeholder,
  options,
}: SelectFieldProps<T>) {
  return (
    <FormField
      control={control}
      name={name}
      render={({ field }) => (
        <FormItem>
          <FormLabel>{label}</FormLabel>
          <Select onValueChange={field.onChange} defaultValue={field.value}>
            <FormControl>
              <SelectTrigger>
                <SelectValue placeholder={placeholder} />
              </SelectTrigger>
            </FormControl>
            <SelectContent>
              {options.map((option) => (
                <SelectItem key={option.value} value={option.value}>
                  {option.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <FormMessage />
        </FormItem>
      )}
    />
  )
}

// Usage - clean and consistent
function UserForm() {
  const form = useForm<UserFormValues>({ resolver: zodResolver(userSchema) })

  return (
    <Form {...form}>
      <TextField control={form.control} name="firstName" label="First Name" />
      <TextField control={form.control} name="lastName" label="Last Name" />
      <TextField control={form.control} name="email" label="Email" type="email" />
      <SelectField
        control={form.control}
        name="role"
        label="Role"
        options={roleOptions}
      />
    </Form>
  )
}
```

Reference: [React Hook Form with TypeScript](https://react-hook-form.com/ts)
