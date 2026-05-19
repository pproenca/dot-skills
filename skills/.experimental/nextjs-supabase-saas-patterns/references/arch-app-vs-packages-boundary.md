---
title: Place Reusable Code in `packages/`, Product-Specific Code in `apps/web`
impact: MEDIUM
impactDescription: prevents tight coupling between product composition and reusable platform
tags: arch, monorepo, packages, boundaries
---

## Place Reusable Code in `packages/`, Product-Specific Code in `apps/web`

`apps/web` is the *product composition* layer — it owns routes, configs, layouts, feature flags, and the specific way this product wires capabilities together. `packages/*` are *reusable capabilities* — they don't know which product uses them and shouldn't reference product-specific paths, configs, or flags. Misplacing code breaks the boundary: feature-specific code in a package means a future second app can't avoid the feature; reusable code in `apps/web` means it can't be lifted into another app without an extraction migration.

**Incorrect (product-specific code stuffed into a package):**

```ts
// packages/features/projects/src/server/api.ts
import featureFlagsConfig from 'apps/web/config/feature-flags.config';  // ❌
import pathsConfig from 'apps/web/config/paths.config';                  // ❌

export class ProjectsApi {
  // Now this package knows about apps/web's specific config files.
  // If you ever add apps/admin or apps/marketing, this package can't be used there.
}
```

**Correct (package is self-contained; app composes):**

```ts
// packages/features/projects/src/server/api.ts
import type { SupabaseClient } from '@supabase/supabase-js';
import type { Database } from '@kit/supabase/database';

export class ProjectsApi {
  constructor(private readonly client: SupabaseClient<Database>) {}

  async listProjects(accountId: string, options?: { limit?: number }) {
    /* ... */
  }
}

export function createProjectsApi(client: SupabaseClient<Database>) {
  return new ProjectsApi(client);
}
```

```tsx
// apps/web/app/[locale]/home/[account]/projects/page.tsx
import featureFlagsConfig from '~/config/feature-flags.config';
import { createProjectsApi } from '@kit/projects/api';

// apps/web KNOWS the feature flag and decides whether to compose the feature.
// The package doesn't care.
export default async function ProjectsPage() {
  if (!featureFlagsConfig.enableProjects) {
    return <UpgradePrompt />;
  }
  const api = createProjectsApi(getSupabaseServerClient());
  const projects = await api.listProjects(accountId);
  return <ProjectsList projects={projects} />;
}
```

**Decision matrix:**

| Question | Belongs in `apps/web` | Belongs in `packages/*` |
|----------|----------------------|-------------------------|
| Does it import a feature flag? | ✅ | ❌ |
| Does it know a specific route name? | ✅ | ❌ |
| Does it know the app name / branding? | ✅ | ❌ |
| Is it a route, layout, or page component? | ✅ | ❌ |
| Could a second app use it unchanged? | ❌ | ✅ |
| Is it a feature API, hook, schema, or service? | ❌ | ✅ |
| Is it a UI primitive? | ❌ | ✅ (in `packages/ui`) |

**Borderline: route-local code that uses a feature package.** Route-local `_lib/server/*.ts` files live under `apps/web/app/...` — they belong to the *route*, even if they use feature-package APIs. The kit's pattern: composition glue is route-local, the API itself is in the package.

```text
apps/web/app/[locale]/home/[account]/projects/
├── page.tsx                                  # apps/web
├── _components/
│   └── project-list.tsx                      # apps/web (uses @kit/projects)
├── _lib/server/
│   └── projects-page.loader.ts               # apps/web (composes the feature)
└── _lib/projects-page.schema.ts              # apps/web (route-specific schema)
```

The reusable bits (`api.ts`, `hooks/`, generic components) live in `packages/features/projects/`.

**Don't refactor by moving things between app and packages on a whim.** The boundary is meaningful — every move is a "is this reusable enough?" decision. If the same component appears in two route directories, that's a signal to extract; one-off composition glue belongs where it's used.

**Cross-app shared code:** when a future app is added (`apps/admin`, `apps/marketing`), shared apps-level code goes in `packages/shared` or a new `packages/{name}` — never one app importing from another.

Reference: [Turborepo monorepo structure](https://turbo.build/repo/docs/handbook/sharing-code/internal-packages)
