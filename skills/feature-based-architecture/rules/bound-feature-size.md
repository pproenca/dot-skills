---
title: Keep Features Appropriately Sized
impact: MEDIUM
impactDescription: Right-sized features balance cohesion and manageability
tags: bound, size, cohesion, splitting
---

## Keep Features Appropriately Sized

Features should be large enough to be meaningful but small enough to be maintainable. A feature that's too small creates unnecessary fragmentation; one that's too large becomes a mini-monolith.

**Incorrect (too granular):**

```
src/features/
├── user-avatar/          # Too small - just one component
├── user-name/            # Too small
├── user-email/           # Too small
├── user-profile/         # Could contain all of these
└── user-settings/
```

**Incorrect (too large):**

```
src/features/
└── user/
    ├── components/
    │   ├── UserAvatar.tsx
    │   ├── UserProfile.tsx
    │   ├── UserSettings.tsx
    │   ├── UserOrders.tsx        # Orders is a separate domain
    │   ├── UserPayments.tsx      # Payments is a separate domain
    │   ├── UserSubscription.tsx  # Subscription is a separate domain
    │   └── ... 30 more files
    └── hooks/
        └── ... 20 hooks
```

**Correct (cohesive features):**

```
src/features/
├── user/                # Core user identity
│   ├── components/
│   │   ├── UserAvatar.tsx
│   │   ├── UserProfile.tsx
│   │   └── UserSettings.tsx
│   └── hooks/
│       └── useUser.ts
├── orders/              # Separate domain
│   ├── components/
│   │   ├── OrderList.tsx
│   │   └── OrderDetail.tsx
│   └── hooks/
│       └── useOrders.ts
├── payments/            # Separate domain
│   └── ...
└── subscription/        # Separate domain
    └── ...
```

**Sizing guidelines:**
- 5-15 components per feature is typical
- If a feature has 20+ files, consider splitting
- If a feature has only 1-2 files, consider merging
- Features should map to business domains, not UI components

**Signs a feature is too large:**
- Multiple developers frequently conflict in the same feature
- Parts of the feature change at different rates
- Some parts are used independently of others

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
