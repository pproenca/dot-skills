---
title: Include Only Necessary Segments
impact: HIGH
impactDescription: Prevents empty folder clutter; keeps features minimal and focused
tags: struct, segments, minimal, pragmatic
---

## Include Only Necessary Segments

Not every feature needs every segment (components/, hooks/, queries/, actions/, utils/, types/). Start with only what the feature requires and add segments as complexity grows. Empty folders add noise and suggest over-engineering.

**Incorrect (every segment even when unused):**

```text
src/features/notification/
├── api/           # Empty - notifications are client-side only
├── components/
│   └── Toast.tsx
├── hooks/
│   └── use-notification.ts
├── stores/        # Empty - using context instead
├── types/
│   └── index.ts   # Just re-exports one interface
└── utils/         # Empty
```

**Correct (only necessary segments):**

```text
src/features/notification/
├── components/
│   └── Toast.tsx
├── hooks/
│   └── use-notification.ts
└── types.ts       # Single file, not a folder with one file
```

**Another example - simple feature:**

```text
src/features/theme/
├── ThemeProvider.tsx
├── use-theme.ts
└── index.ts
```

**Complex feature with all segments (server-components era):**

```text
src/features/checkout/
├── types.ts
├── enums/
│   └── order-state.ts
├── queries/                 # server reads, get- prefix
│   ├── get-order.ts
│   └── get-payment-methods.ts
├── actions/                 # server actions, -action suffix
│   ├── submit-order-action.ts
│   └── validate-address-action.ts
├── components/
│   ├── checkout-form.tsx
│   ├── payment-section.tsx
│   └── shipping-section.tsx
├── hooks/
│   └── use-checkout.ts
├── stores/
│   └── checkout-store.ts
├── utils/
│   └── validation.ts
└── index.ts
```

In client-only codebases without server actions, a single `api/` segment replaces `queries/` + `actions/`.

**Guideline:** Add segments when you have 2+ files that would go there.

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/), [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)
