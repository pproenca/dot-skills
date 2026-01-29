---
title: Use Immer for Deeply Nested State Updates
impact: MEDIUM
impactDescription: simplifies complex updates, reduces spread boilerplate
tags: mw, immer, nested, immutability
---

## Use Immer for Deeply Nested State Updates

For stores with deeply nested objects, immer middleware lets you write mutations that are automatically converted to immutable updates. This eliminates spread operator chains.

**Incorrect (manual spreading for nested updates):**

```typescript
const useFormStore = create<FormState>((set) => ({
  form: {
    sections: {
      personal: {
        fields: {
          firstName: { value: '', error: null, touched: false },
          lastName: { value: '', error: null, touched: false },
        },
      },
      address: {
        fields: {
          street: { value: '', error: null, touched: false },
          city: { value: '', error: null, touched: false },
        },
      },
    },
  },

  setFieldValue: (section, field, value) => set((state) => ({
    form: {
      ...state.form,
      sections: {
        ...state.form.sections,
        [section]: {
          ...state.form.sections[section],
          fields: {
            ...state.form.sections[section].fields,
            [field]: {
              ...state.form.sections[section].fields[field],
              value,
            },
          },
        },
      },
    },
  })),
}))
```

**Correct (immer middleware):**

```typescript
import { immer } from 'zustand/middleware/immer'

const useFormStore = create<FormState>()(
  immer((set) => ({
    form: {
      sections: {
        personal: {
          fields: {
            firstName: { value: '', error: null, touched: false },
            lastName: { value: '', error: null, touched: false },
          },
        },
        address: {
          fields: {
            street: { value: '', error: null, touched: false },
            city: { value: '', error: null, touched: false },
          },
        },
      },
    },

    // Direct mutation syntax, immer handles immutability
    setFieldValue: (section, field, value) => set((state) => {
      state.form.sections[section].fields[field].value = value
    }),

    setFieldError: (section, field, error) => set((state) => {
      state.form.sections[section].fields[field].error = error
    }),

    touchField: (section, field) => set((state) => {
      state.form.sections[section].fields[field].touched = true
    }),
  }))
)
```

**When to use immer:**
- Deeply nested state (3+ levels)
- Array operations (push, splice, filter in-place)
- Complex conditional updates

**When NOT to use:**
- Simple flat state
- Performance-critical hot paths (immer has overhead)

Reference: [Zustand - Immer Middleware](https://zustand.docs.pmnd.rs/integrations/immer-middleware)
