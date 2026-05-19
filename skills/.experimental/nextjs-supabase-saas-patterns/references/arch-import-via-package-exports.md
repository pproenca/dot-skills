---
title: Import via `@kit/*` Package Exports, Never Deep Internal Paths
impact: MEDIUM
impactDescription: prevents coupling consumers to internal file structure
tags: arch, imports, exports, package-json, monorepo
---

## Import via `@kit/*` Package Exports, Never Deep Internal Paths

Each package's `package.json` declares an `exports` map that names the public surface (`@kit/ui/button` → `./src/shadcn/button.tsx`, `@kit/ui/form` → `./src/makerkit/form.tsx`). Importing through this contract means the package can reshape internally — move files, rename folders, swap shadcn for makerkit wrappers — without breaking consumers. Deep imports bypass the contract and break the next time the package's internal layout changes.

**Incorrect (deep import — bypasses the contract):**

```ts
import { Button } from '@kit/ui/src/shadcn/button';        // ❌ Internal path.
import { FormMessage } from '@kit/ui/src/makerkit/form';   // ❌ Internal path.
import { useSupabase } from '@kit/supabase/src/hooks/use-supabase';  // ❌

// First time @kit/ui refactors src/shadcn → src/components, every consumer breaks.
// First time @kit/ui wraps Button to add the project-specific render prop logic,
// these deep imports skip the wrapper and miss the new behavior.
```

**Correct (import via the declared exports):**

```ts
import { Button } from '@kit/ui/button';
import { FormMessage } from '@kit/ui/form';
import { useSupabase } from '@kit/supabase/hooks/use-supabase';
import { Trans } from '@kit/ui/trans';
import { Form, FormField, FormItem, FormLabel, FormControl } from '@kit/ui/form';
```

**What the exports map looks like (`packages/ui/package.json`):**

```json
{
  "name": "@kit/ui",
  "exports": {
    "./accordion": "./src/shadcn/accordion.tsx",
    "./alert-dialog": "./src/shadcn/alert-dialog.tsx",
    "./button": "./src/shadcn/button.tsx",
    "./form": "./src/makerkit/form.tsx",
    "./trans": "./src/makerkit/trans.tsx",
    "./sonner": "./src/makerkit/sonner.tsx",
    "./hooks/use-mobile": "./src/hooks/use-mobile.ts",
    "./hooks/use-supabase-upload": "./src/hooks/use-supabase-upload.ts"
  }
}
```

**Why `@kit/ui/form` points to `makerkit/form.tsx`:** the kit wraps the upstream shadcn `Form` with project-specific behavior (an i18n-aware `FormMessage`). Deep-importing from `@kit/ui/src/shadcn/form` would get the unwrapped version and miss the i18n integration.

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
// packages/ui/src/makerkit/form.tsx (internal — can use #-imports)
import { Form as ShadcnForm } from '#components/form';   // Internal alias.
import { cn } from '#utils';
```

These `#` aliases are declared in `package.json`'s `imports` field — they're private to the package and don't appear in the exports map.

**Don't add a re-export shim in your own code "to avoid deep imports."** That's just relocating the problem. Use the package's exports as published.

Reference: [Node.js subpath exports](https://nodejs.org/api/packages.html#subpath-exports)
