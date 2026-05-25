---
title: Feature Packages Follow a `components / hooks / schema / server` Layout
impact: MEDIUM
impactDescription: prevents structural drift across feature packages
tags: arch, feature-package, layout, convention
---

## Feature Packages Follow a `components / hooks / schema / server` Layout

Give every feature package under `packages/features/` the same shape: `components/` for shared client UI, `hooks/` for client-side hooks, `schema/` for Zod definitions reusable on both sides, `server/api.ts` for the feature API factory, `server/actions/` for server actions, `server/services/` for business logic, and `server/policies/` when the feature has policy gating. New contributors find what they need without grepping; refactoring patterns work across features; one ESLint rule can enforce the layout instead of one per package.

**Incorrect (each feature invents its own structure):**

```text
packages/features/projects/
├── src/
│   ├── api.ts              # Server-only, but server/ is named differently
│   ├── ProjectCard.tsx     # PascalCase, no folder grouping
│   ├── helpers.ts          # Mixed client/server, unclear purpose
│   ├── projectActions.ts   # Server actions mixed with regular code
│   └── form-validation.ts  # Zod schema, but tooling won't find it
```

**Correct (the conventional layout your packages all share):**

```text
packages/features/<feature-name>/
├── package.json                      # Exports map: ./api, ./components, ./hooks, etc.
└── src/
    ├── components/                   # Reusable client UI for this feature
    │   ├── project-card.tsx
    │   └── create-project-form.tsx
    ├── hooks/                        # Client-side hooks (data client + React Query)
    │   ├── use-projects.ts
    │   └── use-create-project.ts
    ├── schema/                       # Zod schemas (shared client + server)
    │   ├── create-project.schema.ts
    │   └── update-project.schema.ts
    └── server/                       # Server-only code (mark with import 'server-only')
        ├── api.ts                    # Feature API factory: createProjectsApi(client)
        ├── actions/                  # Server actions
        │   ├── create-project-server-actions.ts
        │   └── delete-project-server-actions.ts
        ├── services/                 # Business logic
        │   ├── create-project.service.ts
        │   └── delete-project.service.ts
        └── policies/                 # Optional: when feature has configurable rules
            ├── invitation-policies.ts
            └── invitation-policy-context-builder.ts
```

**`package.json` exports:**

```json
{
  "name": "@app/projects",
  "exports": {
    "./api": "./src/server/api.ts",
    "./components/project-card": "./src/components/project-card.tsx",
    "./hooks/use-projects": "./src/hooks/use-projects.ts",
    "./schema": "./src/schema/index.ts",
    "./server/actions": "./src/server/actions/index.ts"
  }
}
```

Consumers import `@app/projects/api` or `@app/projects/hooks/use-projects` — not `@app/projects/src/server/api`. (See the "import via package exports" rule.)

**File naming inside the layout:**

| Folder | Naming | Example |
|--------|--------|---------|
| `components/` | kebab-case | `project-card.tsx` |
| `hooks/` | `use-*` kebab-case | `use-projects.ts` |
| `schema/` | `{action}.schema.ts` | `create-project.schema.ts` |
| `server/actions/` | `{feature}-server-actions.ts` or `{action}.action.ts` | `create-project-server-actions.ts` |
| `server/services/` | `{action}.service.ts` | `create-project.service.ts` |
| `server/policies/` | `{feature}-policies.ts`, `*-context-builder.ts` | `invitation-policies.ts` |
| `server/api.ts` | Always exactly this filename | `api.ts` |

**Why a fixed `server/` folder:** the directory itself is a hint to add `import 'server-only'` to every file inside. Tooling can enforce "if path ends in `/server/*.ts`, file must start with `import 'server-only'`" with a one-line lint rule.

**When to deviate:** very small features (one component, one hook) can skip empty folders. A package with only `src/server/api.ts` is fine. Don't create empty folders for the sake of conformance — but if you add the second file in a category, create the folder.

**Don't put `_internal/` or implementation-detail folders in the public surface.** If something shouldn't be imported, omit it from the exports map. Consumers can't import what isn't exported.

Reference: [Turborepo internal packages](https://turborepo.com/docs/core-concepts/internal-packages)
