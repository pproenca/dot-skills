---
title: Use Shared Layer for Truly Generic Code Only
impact: CRITICAL
impactDescription: Prevents shared/ from becoming a dumping ground; maintains feature boundaries
tags: struct, shared, reusability, generic
---

## Use Shared Layer for Truly Generic Code Only

The shared layer should contain only code with high reusability and minimal business logic. When business-specific code lands in shared/, it creates hidden dependencies and prevents features from being truly independent.

**Incorrect (business logic in shared):**

```text
src/shared/
├── components/
│   ├── Button.tsx          # Generic - OK
│   ├── ProductCard.tsx     # Business-specific - WRONG
│   └── UserBadge.tsx       # Business-specific - WRONG
├── hooks/
│   ├── use-debounce.ts      # Generic - OK
│   └── use-checkout.ts      # Business-specific - WRONG
└── utils/
    ├── format-date.ts       # Generic - OK
    └── calculate-tax.ts     # Business-specific - WRONG
```

**Correct (shared is generic only):**

```text
src/shared/
├── components/
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Modal.tsx
│   └── Tooltip.tsx
├── hooks/
│   ├── use-debounce.ts
│   ├── use-local-storage.ts
│   └── use-media-query.ts
└── utils/
    ├── format-date.ts
    ├── format-currency.ts
    └── cn.ts
```

```text
src/features/product/
├── components/
│   └── ProductCard.tsx     # Business component lives with feature
└── ...

src/features/checkout/
├── hooks/
│   └── use-checkout.ts      # Business hook lives with feature
├── utils/
│   └── calculate-tax.ts     # Business util lives with feature
└── ...
```

**Promotion rule (rule of two):** if exactly one feature uses a util, it lives inside that feature; once two or more features need it, it moves up to the shared layer. Promotion is a deliberate move — never place code in shared/ speculatively "because something else might need it".

**Litmus test for shared/:**
- Would this be useful in a completely different project?
- Does it contain zero business domain knowledge?
- Do 2+ features use it today (not hypothetically)?

If any answer is "no", it belongs in a feature folder.

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/), [Feature-Sliced Design](https://feature-sliced.design/)
