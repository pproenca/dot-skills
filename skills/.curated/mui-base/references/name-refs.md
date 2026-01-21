---
title: Ref Variable Naming with Suffix
impact: MEDIUM
impactDescription: makes ref usage clear and distinguishes from regular values
tags: name, refs, suffix, variables
---

## Ref Variable Naming with Suffix

Name ref variables with `Ref` suffix to make their purpose clear and distinguish them from regular values.

**Incorrect (anti-pattern):**

```typescript
const accordion = useRef<HTMLDivElement>(null)
const items = useRef(new Map())
const trigger = useRef<HTMLButtonElement>(null)
const previous = useRef(value)
```

**Correct (recommended):**

```typescript
const accordionRef = useRef<HTMLDivElement>(null)
const accordionItemRefs = useRef(new Map<string, HTMLDivElement>())
const triggerRef = useRef<HTMLButtonElement>(null)
const previousValueRef = useRef(value)

// Forwarded refs use forwardedRef
export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  // ...
})
```

**When to use:**
- All useRef declarations
- Forwarded ref parameters
- Makes code scanning easier for ref-related bugs
