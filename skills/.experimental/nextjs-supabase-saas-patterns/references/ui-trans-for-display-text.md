---
title: Render Display Text Through `<Trans>` or `useTranslations`
impact: MEDIUM
impactDescription: prevents untranslated strings shipping to non-English locales
tags: ui, i18n, trans, next-intl, translation
---

## Render Display Text Through `<Trans>` or `useTranslations`

`<Trans i18nKey="namespace:key" values={{...}} />` from `@kit/ui/trans` looks up the string in the active locale's messages file. Hardcoding "Save" or "Cancel" in JSX ships English to every locale — Portuguese users see English labels, Japanese users see English buttons, every locale that the kit ships translations for breaks. The kit's i18n is opt-out, not opt-in — the right pattern is "translate by default, hardcode only for true exceptions."

**Incorrect (hardcoded display text — breaks all non-English locales):**

```tsx
<Button>Save</Button>                                   // ❌
<h1>Welcome back, {user.name}</h1>                      // ❌
<p>You have {count} unread notifications</p>            // ❌
<Tooltip>Click to dismiss</Tooltip>                     // ❌
toast.success(`Project ${name} created`);               // ❌
```

**Correct (every user-visible string is a translation key):**

```tsx
import { Trans } from '@kit/ui/trans';
import { useTranslations } from 'next-intl';

// Static text in JSX:
<Button>
  <Trans i18nKey="common.save" />
</Button>

<h1>
  <Trans i18nKey="home.welcomeBack" values={{ name: user.name }} />
</h1>

// Plurals via interpolation key + count:
<p>
  <Trans
    i18nKey="notifications.unreadCount"
    values={{ count }}
  />
</p>

// Text in a non-JSX context (toast, alert):
const t = useTranslations();
toast.success(t('projects.createdSuccess', { name }));
```

**Where translations live:**

```text
apps/web/i18n/messages/
├── en/
│   ├── common.json     # {"save": "Save", "cancel": "Cancel"}
│   ├── home.json       # {"welcomeBack": "Welcome back, {name}"}
│   ├── notifications.json # {"unreadCount": "You have {count, plural, one {# unread} other {# unread}}"}
│   └── projects.json
├── pt/
│   ├── common.json     # {"save": "Guardar"}
│   └── ...
└── ja/
    └── ...
```

**Namespacing convention:** dot-separated nested keys — e.g., `'common.save'`, `'auth.errors.invalidEmail'`, `'teams.personalAccount'`. The first segment maps to the JSON file (`common.json`, `auth.json`, `teams.json`); subsequent segments are nested object keys within it.

**Variable interpolation:**

```ts
// messages/en/projects.json
{ "createdSuccess": "Project {name} created" }

// Usage:
<Trans i18nKey="projects.createdSuccess" values={{ name: project.name }} />
```

**Plurals (ICU format, supported by next-intl):**

```ts
// messages/en/notifications.json
{
  "unreadCount": "{count, plural, =0 {No unread notifications} one {# unread notification} other {# unread notifications}}"
}

// Usage:
<Trans i18nKey="notifications.unreadCount" values={{ count }} />
```

**Server components use `getTranslations`:**

```tsx
import { getTranslations } from 'next-intl/server';

export default async function Page() {
  const t = await getTranslations();
  return <h1>{t('home.welcomeBack', { name: 'Pedro' })}</h1>;
  // Or use <Trans> — works in server components too.
}
```

**Client components use `useTranslations`:**

```tsx
'use client';
import { useTranslations } from 'next-intl';

export function ProjectMenu() {
  const t = useTranslations();
  return (
    <DropdownMenu>
      <DropdownMenu.Item onClick={onEdit}>{t('common.edit')}</DropdownMenu.Item>
      <DropdownMenu.Item onClick={onDelete}>{t('common.delete')}</DropdownMenu.Item>
    </DropdownMenu>
  );
}
```

**`<Trans>` vs `t()`:** prefer `<Trans>` for inline rendering inside JSX (it handles HTML escaping and ICU components like `<bold>`). Use `t()` when you need a string (toast messages, aria-labels, alt text).

**Where hardcoded strings ARE allowed:**

- **Internal test fixtures, dev-only debug pages** — not user-facing.
- **Constants meant to be code-grep-able** — error codes (`'PERMISSION_DENIED'`), event names (`'account.deleted'`).
- **System messages that never render** — logger names, internal IDs.

**Locale-aware formatting:**

```tsx
import { useFormatter } from 'next-intl';

const format = useFormatter();
const date = format.dateTime(project.createdAt, { dateStyle: 'medium' });
const price = format.number(plan.price, { style: 'currency', currency: 'USD' });
```

Hardcoding `new Date().toLocaleDateString('en-US', ...)` or `'$' + price.toFixed(2)` has the same problem as hardcoded strings — it ignores the user's locale.

**Strict mode catches missing keys at build time.** Set `NEXT_INTL_STRICT_KEY_CHECK=true` in CI; the build fails if any `<Trans i18nKey="..."/>` references a key that doesn't exist in every locale. This is the difference between "translations might be missing" and "translations are guaranteed complete."

Reference: [next-intl docs](https://next-intl-docs.vercel.app/)
