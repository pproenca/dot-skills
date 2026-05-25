---
title: Call `revalidatePath()` After a Successful Write So the UI Refreshes
impact: HIGH
impactDescription: prevents stale UI after writes
tags: mutate, revalidate, cache, next-cache, server-action
---

## Call `revalidatePath()` After a Successful Write So the UI Refreshes

The App Router has two caches that affect post-mutation rendering: the **Router Cache** (client-side RSC payloads) and the **Data Cache** (server-side results when explicitly cached). A write to your data store invalidates neither — the user who navigates back to the page sees the previous RSC payload from the Router Cache. `revalidatePath()` invalidates both caches for the given path so the next render fetches fresh. `router.refresh()` only invalidates the client-side Router Cache (and won't help if you'd cached the underlying read); `router.push()` invalidates nothing. Skip `revalidatePath` and the UI can show pre-mutation state when the user returns to the route.

**Incorrect (the write succeeds, the UI stays stale):**

```ts
'use server';
export const updateAccountAction = authActionClient
  .inputSchema(UpdateAccountSchema)
  .action(async ({ parsedInput, ctx: { user } }) => {
    const client = getServerClient();
    await client.from('accounts').update(parsedInput).eq('id', user.id);

    // The write worked. The UI shows the old name until a manual refresh.
    return { ok: true };
  });

// Or worse:
// router.push('/home/settings');  // Same route, but the cache is still hot.
// router.refresh();               // Refreshes the route — but only the client-side cache.
```

**Correct (revalidate the right scope after the write):**

```ts
'use server';
import { revalidatePath } from 'next/cache';

export const updateAccountAction = authActionClient
  .inputSchema(UpdateAccountSchema)
  .action(async ({ parsedInput, ctx: { user } }) => {
    const client = getServerClient();
    await client.from('accounts').update(parsedInput).eq('id', user.id);

    // The next render of /home and its descendants fetches fresh.
    revalidatePath('/home', 'layout');

    return { ok: true };
  });
```

**Picking the scope:**

| Call | What it invalidates |
|------|---------------------|
| `revalidatePath('/home/settings')` | Just that page's segment |
| `revalidatePath('/home/settings', 'layout')` | The layout and every page nested under it |
| `revalidatePath('/home/[account]', 'layout')` | All workspaces (parameterised route) |
| `revalidatePath('/', 'layout')` | The entire app (nuclear option for full revalidation) |

**When to revalidate broadly:**

```ts
// Account deletion affects everything the user sees — nuke the whole cache.
revalidatePath('/', 'layout');
redirect('/');
```

**When to revalidate narrowly:**

```ts
// Updating a single project: only its own pages need invalidation.
revalidatePath(`/home/${accountSlug}/projects/${projectId}`);
```

**Mutation → revalidate → redirect:**

```ts
const accountSlug = createdAccount.slug;
revalidatePath('/home', 'layout');         // Account list updates.
redirect(`/home/${accountSlug}`);          // Navigate to the new account.
```

**Order matters: revalidate BEFORE redirect.** `redirect()` throws, so any code after it never runs. Call `revalidatePath` first.

**What `router.refresh()` actually does:** invalidates the *client-side* Router Cache (the soft cache that holds RSC payloads). It re-fetches the layout, but if the Data Cache still holds the stale value, you get the same stale data back. `revalidatePath` invalidates the Data Cache too.

**`router.push()` to the same URL:** triggers a soft navigation. If nothing in the Data Cache changed, the page renders the same content. Use it for *navigation* after a write, never as a substitute for invalidation.

**Don't revalidate on read.** `revalidatePath` is a write-side concern. Calling it inside a server component's render path causes an infinite revalidation loop (render → revalidate → re-render → revalidate → ...).

**`revalidateTag('tag')` is the alternative for tag-based invalidation** — useful when many routes depend on the same underlying data. Tag the data on read (`{ next: { tags: ['account', accountId] } }`), invalidate the tag on write. For path-keyed UIs, `revalidatePath` is the simpler tool.

Reference: [Next.js `revalidatePath`](https://nextjs.org/docs/app/api-reference/functions/revalidatePath)
