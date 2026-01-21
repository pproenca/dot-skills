---
title: Use Shared Layer for Truly Generic Code Only
impact: CRITICAL
impactDescription: Prevents shared/ from becoming a dumping ground; maintains feature boundaries
tags: struct, shared, reusability, generic
---

## Use Shared Layer for Truly Generic Code Only

The shared layer should contain only code with high reusability and minimal business logic. When business-specific code lands in shared/, it creates hidden dependencies and prevents features from being truly independent.

**Incorrect (business logic in shared):**

```
src/shared/
├── components/
│   ├── Button.tsx          # Generic - OK
│   ├── ProductCard.tsx     # Business-specific - WRONG
│   └── UserBadge.tsx       # Business-specific - WRONG
├── hooks/
│   ├── useDebounce.ts      # Generic - OK
│   └── useCheckout.ts      # Business-specific - WRONG
└── utils/
    ├── formatDate.ts       # Generic - OK
    └── calculateTax.ts     # Business-specific - WRONG
```

**Correct (shared is generic only):**

```
src/shared/
├── components/
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Modal.tsx
│   └── Tooltip.tsx
├── hooks/
│   ├── useDebounce.ts
│   ├── useLocalStorage.ts
│   └── useMediaQuery.ts
└── utils/
    ├── formatDate.ts
    ├── formatCurrency.ts
    └── cn.ts
```

```
src/features/product/
├── components/
│   └── ProductCard.tsx     # Business component lives with feature
└── ...

src/features/checkout/
├── hooks/
│   └── useCheckout.ts      # Business hook lives with feature
├── utils/
│   └── calculateTax.ts     # Business util lives with feature
└── ...
```

**Litmus test for shared/:**
- Would this be useful in a completely different project?
- Does it contain zero business domain knowledge?
- Is it used by 3+ features?

If any answer is "no", it belongs in a feature folder.

Reference: [Feature-Sliced Design](https://feature-sliced.design/)
