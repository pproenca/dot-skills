---
title: Include Only Necessary Segments
impact: HIGH
impactDescription: Prevents empty folder clutter; keeps features minimal and focused
tags: struct, segments, minimal, pragmatic
---

## Include Only Necessary Segments

Not every feature needs every segment (components/, hooks/, api/, utils/, types/). Start with only what the feature requires and add segments as complexity grows. Empty folders add noise and suggest over-engineering.

**Incorrect (every segment even when unused):**

```
src/features/notification/
├── api/           # Empty - notifications are client-side only
├── components/
│   └── Toast.tsx
├── hooks/
│   └── useNotification.ts
├── stores/        # Empty - using context instead
├── types/
│   └── index.ts   # Just re-exports one interface
└── utils/         # Empty
```

**Correct (only necessary segments):**

```
src/features/notification/
├── components/
│   └── Toast.tsx
├── hooks/
│   └── useNotification.ts
└── types.ts       # Single file, not a folder with one file
```

**Another example - simple feature:**

```
src/features/theme/
├── ThemeProvider.tsx
├── useTheme.ts
└── index.ts
```

**Complex feature with all segments:**

```
src/features/checkout/
├── api/
│   ├── submit-order.ts
│   └── validate-address.ts
├── components/
│   ├── CheckoutForm.tsx
│   ├── PaymentSection.tsx
│   └── ShippingSection.tsx
├── hooks/
│   ├── useCheckout.ts
│   └── usePaymentMethods.ts
├── stores/
│   └── checkout-store.ts
├── types/
│   └── index.ts
├── utils/
│   └── validation.ts
└── index.ts
```

**Guideline:** Add segments when you have 2+ files that would go there.

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)
