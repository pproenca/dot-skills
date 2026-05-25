---
title: Define Routes and Navigation in `config/`, Not Hardcoded in Components
impact: MEDIUM
impactDescription: prevents route-name drift across files
tags: arch, config, navigation, paths
---

## Define Routes and Navigation in `config/`, Not Hardcoded in Components

`apps/web/config/paths.config.ts` is the canonical source for every route name in the app — `pathsConfig.app.home === '/home'`, `pathsConfig.auth.signIn === '/auth/sign-in'`. Navigation configs (`personal-account-navigation.config.tsx`, `team-account-navigation.config.tsx`) define the sidebar entries that read these constants. Sidebars import navigation config; redirects and links import path constants; renaming a route is a one-file diff instead of a grep-and-replace across 20 components.

**Incorrect (hardcoded paths sprinkled through components):**

```tsx
// 20 different files each contain:
<Link href="/home/settings">Settings</Link>
redirect('/auth/sign-in');
router.push('/home/' + account + '/billing');

// Rename /home/settings to /home/account-settings: hunt through every file.
// Add a /home prefix change (e.g., /workspace): another grep-and-replace.
// Typo in one of the 20 places: silently dead link.
```

**Correct (single source of truth in `paths.config.ts`):**

```ts
// apps/web/config/paths.config.ts (Zod-validated for shape correctness)
import * as z from 'zod';

const PathsSchema = z.object({
  auth: z.object({
    signIn: z.string().min(1),
    signUp: z.string().min(1),
    verifyMfa: z.string().min(1),
    callback: z.string().min(1),
  }),
  app: z.object({
    home: z.string().min(1),
    personalAccountSettings: z.string().min(1),
    accountHome: z.string().min(1),       // Template: '/home/[account]'
    accountSettings: z.string().min(1),
  }),
});

const pathsConfig = PathsSchema.parse({
  auth: {
    signIn: '/auth/sign-in',
    signUp: '/auth/sign-up',
    verifyMfa: '/auth/verify',
    callback: '/auth/callback',
  },
  app: {
    home: '/home',
    personalAccountSettings: '/home/settings',
    accountHome: '/home/[account]',
    accountSettings: '/home/[account]/settings',
  },
} satisfies z.output<typeof PathsSchema>);

export default pathsConfig;
```

```tsx
// Every consumer uses the constant.
import pathsConfig from '~/config/paths.config';

<Link href={pathsConfig.app.personalAccountSettings}>Settings</Link>
redirect(pathsConfig.auth.signIn);
router.push(pathsConfig.app.accountHome.replace('[account]', account));
```

**Navigation configs are TSX so they can include icons:**

```tsx
// apps/web/config/team-account-navigation.config.tsx
import { Home, Settings, Users, CreditCard } from 'lucide-react';
import pathsConfig from './paths.config';

export const getTeamAccountNavigationConfig = (account: string) => ({
  routes: [
    {
      label: 'common:routes.home',
      path: pathsConfig.app.accountHome.replace('[account]', account),
      Icon: <Home className="h-4" />,
    },
    {
      label: 'common:routes.members',
      path: `/home/${account}/members`,
      Icon: <Users className="h-4" />,
    },
    {
      label: 'common:routes.billing',
      path: `/home/${account}/billing`,
      Icon: <CreditCard className="h-4" />,
    },
    {
      label: 'common:routes.settings',
      path: pathsConfig.app.accountSettings.replace('[account]', account),
      Icon: <Settings className="h-4" />,
    },
  ],
});
```

```tsx
// Sidebar consumes the navigation config — no hardcoded links.
import { getTeamAccountNavigationConfig } from '~/config/team-account-navigation.config';

export function TeamSidebar({ account }: { account: string }) {
  const config = getTeamAccountNavigationConfig(account);
  return (
    <nav>
      {config.routes.map((route) => (
        <NavLink key={route.path} href={route.path} icon={route.Icon}>
          <Trans i18nKey={route.label} />
        </NavLink>
      ))}
    </nav>
  );
}
```

**Feature flags also live in `config/`:**

```ts
// apps/web/config/feature-flags.config.ts
export default {
  enableTeamAccounts: true,
  enablePersonalAccountDeletion: process.env.NEXT_PUBLIC_ENABLE_PERSONAL_ACCOUNT_DELETION === 'true',
  enableProjects: true,
};

// Consumers read this single source — never re-check the env var in components.
import featureFlagsConfig from '~/config/feature-flags.config';
if (!featureFlagsConfig.enableTeamAccounts) return null;
```

**Zod-validating the config catches shape errors at startup.** A typo like `signIn: '/atuh/sign-in'` is caught when `paths.config.ts` first loads — not at the first time a user clicks the link.

**When you add a route:** update `paths.config.ts` AND the appropriate navigation config. The PR diff for a new route is two config files plus the route's actual code — and reviewers see the whole change in one place.

**Don't bypass for "one-off" links.** Even a single hardcoded `'/home/settings'` is a future grep miss. Always use the constant.

Reference: [Next.js linking and navigating](https://nextjs.org/docs/app/getting-started/linking-and-navigating)
