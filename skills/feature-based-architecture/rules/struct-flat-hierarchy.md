---
title: Keep Directory Hierarchy Flat
impact: CRITICAL
impactDescription: Reduces cognitive load; prevents 5+ level deep import paths
tags: struct, nesting, hierarchy, navigation
---

## Keep Directory Hierarchy Flat

Deep nesting creates long import paths, makes file relocation difficult, and obscures the overall structure. Limit nesting to 2-3 levels within features.

**Incorrect (deep nesting):**

```
src/features/checkout/
├── components/
│   ├── form/
│   │   ├── fields/
│   │   │   ├── payment/
│   │   │   │   └── CardInput.tsx
│   │   │   └── shipping/
│   │   │       └── AddressInput.tsx
│   │   └── FormWrapper.tsx
│   └── summary/
│       └── OrderSummary.tsx
```

```typescript
// Import path is 6 levels deep
import { CardInput } from '../../../components/form/fields/payment/CardInput';
```

**Correct (flat hierarchy):**

```
src/features/checkout/
├── components/
│   ├── CardInput.tsx
│   ├── AddressInput.tsx
│   ├── FormWrapper.tsx
│   └── OrderSummary.tsx
```

```typescript
// Import path is 2 levels
import { CardInput } from '../components/CardInput';
```

**When deeper nesting is acceptable:**
- Feature has 20+ components (consider splitting into sub-features)
- Clear categorical distinction (e.g., `forms/` vs `displays/`)

**Guidelines:**
- Maximum 3 levels within a feature folder
- If you need deeper nesting, the feature is likely too large
- Prefer flat with clear naming over deep with vague naming

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/)
