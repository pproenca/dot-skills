---
title: Use Domain-Driven Feature Names
impact: LOW
impactDescription: Improves discoverability; aligns code with business terminology
tags: name, features, domain, naming
---

## Use Domain-Driven Feature Names

Name features after business domains, not technical implementations. This makes the codebase navigable for non-developers and ensures feature boundaries align with business boundaries.

**Incorrect (technical naming):**

```text
src/features/
├── data-grid/          # What data? What domain?
├── form-handler/       # What form? What entity?
├── api-client/         # Generic technical concern
├── modal-manager/      # UI pattern, not domain
└── list-view/          # Generic view pattern
```

**Correct (domain naming):**

```text
src/features/
├── user/               # User management domain
├── product/            # Product catalog domain
├── cart/               # Shopping cart domain
├── checkout/           # Checkout/payment domain
├── order/              # Order management domain
├── notification/       # Notification domain
└── search/             # Search domain
```

**Naming guidelines:**

| Domain | Good Name | Bad Name |
|--------|-----------|----------|
| User management | `user`, `account` | `profile-component` |
| Product catalog | `product`, `catalog` | `item-list` |
| Shopping | `cart`, `checkout` | `purchase-flow` |
| Authentication | `auth` | `login-system` |

**Keep names singular.** Use `features/customer/`, never `features/customers/`. Even when a component renders a collection, the folder represents one domain concept — `customer/customer-list/` reads unambiguously, while a mix of `customers/` and `customer/` across the tree forces contributors to guess. Collection folders (`features/`, `components/`, `hooks/`, `queries/`) and bundle files (`types.ts`, `utils.ts`) stay plural — they genuinely hold many items; the singular rule applies to domain and component names.

```text
src/features/
├── customer/           # singular, even though it lists customers
│   └── customer-list/
└── project/
    └── project-table/
```

**Sub-features:**

```text
src/features/
├── user/
│   ├── ...            # Core user feature
├── user-preferences/  # Distinct sub-domain
└── user-notifications/ # Another sub-domain
```

**Ask these questions:**
- Would a product manager understand this name?
- Does this map to a business capability?
- Would this name make sense in a requirements document?

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/), [Domain-Driven Design - Eric Evans](https://www.domainlanguage.com/ddd/)
