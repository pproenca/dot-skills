---
title: Call `revalidatePath()` After Successful Mutations
impact: HIGH
impactDescription: prevents stale UI after writes
tags: mutate, revalidate, cache, next-cache, server-action
---

## Call `revalidatePath()` After Successful Mutations

Next.js App Router has two caches that affect post-mutation rendering: the **Router Cache** (client-side RSC payloads) and the **Data Cache** (server-side `fetch` results when explicitly cached). A mutation to Supabase doesn't auto-invalidate either — the user navigating back to the page sees the previous RSC payload from the Router Cache. `revalidatePath()` invalidates both caches for the given path so the next render fetches fresh. `router.refresh()` only invalidates the client-side Router Cache (and won't help if you'd cached the underlying fetch); `router.push()` invalidates nothing. Skip `revalidatePath` and the UI can show pre-mutation state when the user returns to the route.

**Incorrect (mutation succeeds, UI stays stale):**

```ts
'use server';
export const updateAccountAction = authActionClient
  .inputSchema(UpdateAccountSchema)
  .action(async ({ parsedInput, ctx: { user } }) => {
    const client = getSupabaseServerClient();
    await client.from('accounts').update(parsedInput).eq('id', user.id);

    // The mutation worked. The UI shows the old name until manual refresh.
    return { ok: true };
  });

// Or worse:
// router.push('/home/settings');  // Navigates to the same route, but cache is still hot.
// router.refresh();                // Refreshes the route — but only client-side cache.
```

**Correct (revalidate the right scope after the write):**

```ts
'use server';
import { revalidatePath } from 'next/cache';

export const updateAccountAction = authActionClient
  .inputSchema(UpdateAccountSchema)
  .action(async ({ parsedInput, ctx: { user } }) => {
    const client = getSupabaseServerClient();
    await client.from('accounts').update(parsedInput).eq('id', user.id);

    // Next render of /home and its descendants fetches fresh.
    revalidatePath('/home', 'layout');

    return { ok: true };
  });
```

**Picking the scope:**

| Call | What it invalidates |
|------|---------------------|
| `revalidatePath('/home/settings')` | Just that page's segment |
| `revalidatePath('/home/settings', 'layout')` | The layout and every page nested under it |
| `revalidatePath('/home/[account]', 'layout')` | All team workspaces (parameterised route) |
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

**Correct (mutation → revalidate → redirect):**

```ts
const slug = data.slug;
revalidatePath('/home', 'layout');         // Account list updates.
redirect(`/home/${slug}`);                  // Navigate to the new account.
```

**Order matters: revalidate BEFORE redirect.** `redirect()` throws, so any code after it doesn't run. Call `revalidatePath` first.

**What `router.refresh()` actually does:** invalidates the *client-side* Router Cache (the soft cache that holds RSC payloads). It causes the layout to re-fetch, but if the underlying Data Cache still has the stale value, you get the same stale data back. `revalidatePath` invalidates the Data Cache too.

**`router.push()` to the same URL:** triggers a soft navigation. If nothing in the Data Cache changed, the page renders the same content. Use it for *navigation* after a mutation, never as a substitute for invalidation.

**Don't revalidate on read.** `revalidatePath` is a write-side concern. Calling it inside a server component's render path causes an infinite revalidation loop (render → revalidate → re-render → revalidate → ...).

**`revalidateTag('tag')` is the alternative for tag-based invalidation** — useful when you have many routes that depend on the same underlying data. Tag the data on read (`{ next: { tags: ['account', accountId] } }`), invalidate the tag on write. For path-keyed UIs, `revalidatePath` is the simpler tool.

Reference: [Next.js `revalidatePath`](https://nextjs.org/docs/app/api-reference/functions/revalidatePath)
