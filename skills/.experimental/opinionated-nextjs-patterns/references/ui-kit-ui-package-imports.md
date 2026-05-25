---
title: Import UI from Your Design-System Package Surface, Never Internal Paths
impact: MEDIUM
impactDescription: prevents bypassing your design-system wrapper behavior
tags: ui, imports, design-system, shadcn
---

## Import UI from Your Design-System Package Surface, Never Internal Paths

`@app/ui/<name>` resolves to either `packages/ui/src/shadcn/<name>.tsx` (the unmodified shadcn CLI output) or `packages/ui/src/components/<name>.tsx` (your own wrapper). The package's exports map decides which one — and your wrappers add the i18n-aware `FormMessage`, the `toast` re-export, custom variants, and other project-specific behavior. Deep imports skip the wrapper, miss that behavior, and break when the shadcn CLI overwrites the upstream file.

**Incorrect (deep imports — skip your wrapper, brittle to refactors):**

```ts
import { Button } from '@app/ui/src/shadcn/button';          // ❌
import { FormMessage } from '@app/ui/src/shadcn/form';       // ❌ Misses i18n wrapping.
import { toast } from '@app/ui/src/shadcn/sonner';           // ❌
import { Trans } from '@app/ui/src/components/trans';         // ❌ Internal path.
```

**Correct (use the declared export):**

```ts
import { Button } from '@app/ui/button';
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from '@app/ui/form';
import { toast } from '@app/ui/sonner';
import { Trans } from '@app/ui/trans';
import { cn } from '@app/ui/utils';
import { If } from '@app/ui/if';
```

**Why your wrapper exists for `@app/ui/form`:**

```tsx
// packages/ui/src/components/form.tsx (your wrapper)
import { Form, FormField, FormItem, FormLabel, FormControl } from '#shadcn/form';
import { FormMessage as ShadcnFormMessage } from '#shadcn/form';
import { Trans } from './trans';

// Re-export everything from the upstream shadcn primitives.
export { Form, FormField, FormItem, FormLabel, FormControl };

// Override FormMessage to look up the message as an i18n key.
export function FormMessage(props: ComponentProps<typeof ShadcnFormMessage>) {
  const { children, ...rest } = props;
  return (
    <ShadcnFormMessage {...rest}>
      {typeof children === 'string' ? <Trans i18nKey={children} /> : children}
    </ShadcnFormMessage>
  );
}
```

Importing from the deep `@app/ui/src/shadcn/form` path gets the bare shadcn `FormMessage` and loses the i18n behavior — error messages render as raw `'auth.errors.invalidEmail'` strings to the user.

**Why upstream files in `src/shadcn/` shouldn't be edited:**

The shadcn CLI manages those files. Running `pnpm dlx shadcn@latest add button` overwrites `src/shadcn/button.tsx` — any custom code is gone. The two extension patterns to use instead:

| Pattern | Use for | Example |
|---------|---------|---------|
| Wrap + re-export | Behavioral additions (i18n, custom logic) | `FormMessage` in `components/form.tsx` |
| Companion token map | Visual variants (success/warning/info) | `badgeExtras` in `components/badge-extras.tsx` |

Then `package.json`'s exports map points `@app/ui/<name>` to your wrapper instead of the raw shadcn file. Call sites continue to use the same import path.

**Discoverability:** if your IDE auto-completes `@app/ui/<name>`, the path is exported. If you have to type the full internal path, you're doing it wrong.

**Tailwind config and globals.css:** configure Tailwind to scan both `apps/web/**/*` and `packages/ui/src/**/*` so utility classes used inside the package are picked up. Don't move package UI files outside `src/` or Tailwind will miss them.

**`If` component for conditional rendering:**

```tsx
import { If } from '@app/ui/if';

// Better than the ternary for long branches.
<If condition={user.isPremium}>
  <PremiumDashboard />
</If>

// With fallback:
<If condition={!!notifications.length} fallback={<EmptyState />}>
  <NotificationList items={notifications} />
</If>
```

**Don't write your own `Button`/`Input`/`Form` primitives in `apps/web`.** Your UI package is the design system. If a primitive is missing, add it to `packages/ui` (wrapped properly under `src/components/`) so every consumer benefits.

Reference: [shadcn/ui documentation](https://ui.shadcn.com/docs)
