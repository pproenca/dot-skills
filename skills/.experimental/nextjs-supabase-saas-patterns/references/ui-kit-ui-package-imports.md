---
title: Import UI Components from `@kit/ui/<name>`, Never Internal Paths
impact: MEDIUM
impactDescription: prevents bypassing makerkit-wrapped behavior
tags: ui, imports, kit-ui, makerkit, shadcn
---

## Import UI Components from `@kit/ui/<name>`, Never Internal Paths

`@kit/ui/<name>` resolves to either `packages/ui/src/shadcn/<name>.tsx` (upstream-owned shadcn primitive) or `packages/ui/src/makerkit/<name>.tsx` (project-specific wrapper). The exports map decides which one — and the makerkit wrappers add the i18n-aware `FormMessage`, the `toast` re-export, custom variants, and other project-specific behavior. Deep imports skip the wrapper, miss the project behavior, and break when the shadcn CLI overwrites the upstream file.

**Incorrect (deep imports — skip the makerkit wrapper, brittle to refactors):**

```ts
import { Button } from '@kit/ui/src/shadcn/button';          // ❌
import { FormMessage } from '@kit/ui/src/shadcn/form';       // ❌ Misses i18n wrapping.
import { toast } from '@kit/ui/src/shadcn/sonner';           // ❌
import { Trans } from '@kit/ui/src/makerkit/trans';          // ❌ Internal path.
```

**Correct (use the declared export):**

```ts
import { Button } from '@kit/ui/button';
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from '@kit/ui/form';
import { toast } from '@kit/ui/sonner';
import { Trans } from '@kit/ui/trans';
import { cn } from '@kit/ui/utils';
import { If } from '@kit/ui/if';
```

**Why the makerkit wrapper exists for `@kit/ui/form`:**

```tsx
// packages/ui/src/makerkit/form.tsx (project-specific wrapper)
import { Form, FormField, FormItem, FormLabel, FormControl } from '#components/form';
import { FormMessage as ShadcnFormMessage } from '#components/form';
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

Importing from the deep `@kit/ui/src/shadcn/form` path gets the bare shadcn `FormMessage` and loses the i18n behavior — error messages render as raw `'auth.errors.invalidEmail'` strings to the user.

**Why upstream files in `src/shadcn/` shouldn't be edited:**

The shadcn CLI manages those files. Running `pnpm dlx shadcn@latest add button` overwrites `src/shadcn/button.tsx` — any custom code is gone. The two extension patterns the kit uses:

| Pattern | Use for | Example |
|---------|---------|---------|
| Wrap + re-export | Behavioral additions (i18n, custom logic) | `FormMessage` in `makerkit/form.tsx` |
| Companion token map | Visual variants (success/warning/info) | `badgeExtras` in `makerkit/badge-extras.tsx` |

Then `package.json`'s exports map points `@kit/ui/<name>` to the makerkit wrapper instead of the raw shadcn file. Call sites continue to use the same import path.

**Discoverability:** if your IDE auto-completes `@kit/ui/<name>`, the path is exported. If you have to type the full internal path, you're doing it wrong.

**Tailwind config and globals.css:** the kit's `tailwind.config.ts` scans both `apps/web/**/*` and `packages/ui/src/**/*` so utility classes used in the package are picked up. Don't move package UI files outside `src/` or Tailwind will miss them.

**`If` component for conditional rendering:**

```tsx
import { If } from '@kit/ui/if';

// Better than the ternary for long branches.
<If condition={user.isPremium}>
  <PremiumDashboard />
</If>

// With fallback:
<If condition={!!notifications.length} fallback={<EmptyState />}>
  <NotificationList items={notifications} />
</If>
```

**Don't write your own `Button`/`Input`/`Form` primitives in `apps/web`.** The kit's UI package is the design system. If a primitive is missing, add it to `packages/ui` (wrapped properly in makerkit) so every consumer benefits.

Reference: [shadcn/ui composability](https://ui.shadcn.com/docs)
