---
title: Group Features into Domains at Large Scale
impact: HIGH
impactDescription: Keeps 20+ feature codebases navigable; gives monorepo extraction a ready seam
tags: struct, domains, monorepo, scale
---

## Group Features into Domains at Large Scale

A flat `features/` folder stops scaling somewhere around 15–20 features: unrelated business areas interleave alphabetically and ownership blurs. Introduce a `domains/` layer that groups related features by business domain. Domains follow the same boundary rules as features one level up: domains do not import from each other, with a single exception for a foundational `core/` domain (user, tenant, auth) that every domain may use.

**Incorrect (flat features folder at scale):**

```text
src/features/
├── comment/
├── contact/
├── customer/
├── invoice/
├── project/
├── space/
├── tenant/
├── user/
└── ... 15 more, unrelated areas interleaved
```

**Correct (features grouped by domain):**

```text
src/
├── domains/
│   ├── workspace/
│   │   └── features/
│   │       ├── project/
│   │       ├── customer/
│   │       └── contact/
│   ├── core/                # foundational — the only domain others may import
│   │   └── features/
│   │       ├── user/
│   │       └── tenant/
│   └── cms/
│       └── features/
│           ├── comment/
│           └── space/
├── components/              # shared generic UI
├── hooks/
└── utils/
```

**Evolution to a monorepo.** Domain folders are the seam for the next two scale steps. When build times or team autonomy demand it, extract shared code into `packages/` (each with its own `package.json`, imported by name like `@yourorg/shared`), and when shipping multiple deployables, split `apps/`:

```text
apps/
├── web-admin/
├── web-workspace/
└── web-cms/
domains/
├── workspace/src/features/...
├── core/src/features/...
└── cms/src/features/...
packages/
├── shared/src/...
├── typescript-config/
└── vitest-config/
```

**Dependency model (unidirectional, extends shared → features → app):**
- Apps depend on domains and packages — never on each other.
- Domains depend on packages and on foundational domains (`core/`) — never on sibling domains.
- Packages depend on no one; they are the foundation layer.

**When NOT to use this pattern:**
- Under ~15 features, a flat `features/` folder is simpler and sufficient.
- Do not create `domains/` with a single domain inside — that is a rename, not a boundary.

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/)
