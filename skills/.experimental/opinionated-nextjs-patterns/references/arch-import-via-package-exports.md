---
title: Import via the Package `exports` Map, Never Deep Internal Paths
impact: MEDIUM
impactDescription: prevents coupling consumers to internal file structure
tags: arch, imports, exports, package-json, monorepo
---

## Import via the Package `exports` Map, Never Deep Internal Paths

Each package's `package.json` declares an `exports` map that names the public surface (`@app/ui/button` → `./src/shadcn/button.tsx`, `@app/ui/form` → `./src/components/form.tsx`). Importing through this contract means the package can reshape internally — move files, rename folders, wrap an upstream primitive with project-specific behavior — without breaking consumers. Deep imports bypass the contract and break the next time the package's internal layout changes.

**Incorrect (deep import — bypasses the contract):**

```ts
import { Button } from '@app/ui/src/shadcn/button';        // ❌ Internal path.
import { FormMessage } from '@app/ui/src/components/form';  // ❌ Internal path.
import { useSupabase } from '@app/supabase/src/hooks/use-supabase'; // ❌

// First time @app/ui refactors src/shadcn → src/primitives, every consumer breaks.
// First time @app/ui wraps Button with project-specific render logic,
// these deep imports skip the wrapper and miss the new behavior.
```

**Correct (import via the declared exports):**

```ts
import { Button } from '@app/ui/button';
import { FormMessage } from '@app/ui/form';
import { useSupabase } from '@app/supabase/client';
import { Trans } from '@app/ui/trans';
import { Form, FormField, FormItem, FormLabel, FormControl } from '@app/ui/form';
```

**What the exports map looks like (`packages/ui/package.json`):**

```json
{
  "name": "@app/ui",
  "exports": {
    "./accordion": "./src/shadcn/accordion.tsx",
    "./alert-dialog": "./src/shadcn/alert-dialog.tsx",
    "./button": "./src/shadcn/button.tsx",
    "./form": "./src/components/form.tsx",
    "./trans": "./src/components/trans.tsx",
    "./sonner": "./src/components/sonner.tsx",
    "./hooks/use-mobile": "./src/hooks/use-mobile.ts",
    "./hooks/use-upload": "./src/hooks/use-upload.ts"
  }
}
```

**Why `@app/ui/form` points to `components/form.tsx`:** your package wraps the upstream shadcn `Form` with project-specific behavior (an i18n-aware `FormMessage`). Deep-importing from `@app/ui/src/shadcn/form` would get the unwrapped version and miss the i18n integration.

**Path aliases in `apps/web`:**

| Alias | Resolves to | Use for |
|-------|------------|---------|
| `~/config/*` | `apps/web/config/*` | App config files (paths, feature flags) |
| `~/components/*` | `apps/web/components/*` | App-shared components (not route-local) |
| `~/lib/*` | `apps/web/lib/*` | App utilities |
| `~/*` | Auto-resolves into `apps/web/app/*` | Inside `apps/web` only |

```ts
// apps/web/app/[locale]/home/[account]/billing/page.tsx
import pathsConfig from '~/config/paths.config';
import { TopBar } from '~/components/top-bar';
```

Outside `apps/web` (in `packages/*`), never use `~/*` — packages don't have that alias and shouldn't know the host app's layout.

**Discovering the exports surface:** open the package's `package.json` and read the `exports` map. Editors with TypeScript path-completion only suggest declared exports — if your IDE doesn't auto-complete the import, the path is not public. Use the closest declared export instead.

**Adding a new export:** edit `package.json`'s `exports` map AND make sure the file at the target path actually exists. Forgetting either step breaks the import in a confusing way (the editor accepts the path, runtime fails).

**Internal imports within a package CAN use relative paths or `#`-aliases:**

```ts
// packages/ui/src/components/form.tsx (internal — can use #-imports)
import { Form as ShadcnForm } from '#components/form';   // Internal alias.
import { cn } from '#utils';
```

These `#` aliases are declared in `package.json`'s `imports` field — they're private to the package and don't appear in the exports map.

**Don't add a re-export shim in your own code "to avoid deep imports."** That's just relocating the problem. Use the package's exports as published.

Reference: [Node.js subpath exports](https://nodejs.org/api/packages.html#subpath-exports)
