---
title: Load Independent Data in Parallel with `Promise.all`
impact: HIGH
impactDescription: 2-3x faster loaders with N concurrent reads
tags: server, async, promise-all, parallel, waterfall
---

## Load Independent Data in Parallel with `Promise.all`

Sequential `await`s in a server loader serialize round-trips: three independent reads become 3 × RTT. Wrapping them in `Promise.all` collapses to ~1 × RTT (the slowest read). The kit's workspace loaders fetch accounts, workspace, and user in parallel — three Supabase queries finish in the time of the slowest one. The pattern only works when the reads are *truly* independent; if one depends on another, only parallelize the independent group.

**Incorrect (sequential awaits — round-trips serialize):**

```ts
// 3 sequential queries: ~3x latency.
async function workspaceLoader() {
  const client = getSupabaseServerClient();
  const api = createAccountsApi(client);

  const accounts = await api.loadUserAccounts();        // wait 50ms
  const workspace = await api.getAccountWorkspace();    // wait 50ms
  const user = await requireUserInServerComponent();    // wait 50ms
  // Total: ~150ms before the page can render.

  return { accounts, workspace, user };
}
```

**Correct (the shipped pattern — `Promise.all` for independent reads):**

```ts
// app/[locale]/home/(user)/_lib/server/load-user-workspace.ts
async function workspaceLoader() {
  const client = getSupabaseServerClient();
  const api = createAccountsApi(client);

  const accountsPromise = shouldLoadAccounts
    ? () => api.loadUserAccounts()
    : () => Promise.resolve([]);
  const workspacePromise = api.getAccountWorkspace();

  // All three fire simultaneously; await waits for the slowest.
  const [accounts, workspace, user] = await Promise.all([
    accountsPromise(),
    workspacePromise,
    requireUserInServerComponent(),
  ]);
  // Total: ~max(50, 50, 50) = ~50ms.

  return { accounts, workspace, user };
}
```

**Correct (mixed: parallelize within each dependency tier):**

```ts
// User is needed before we can load their projects.
const user = await requireUserInServerComponent();

// These three depend on user.id but are independent of each other.
const [projects, invitations, billing] = await Promise.all([
  api.getProjects(user.id),
  api.getPendingInvitations(user.id),
  api.getBillingState(user.id),
]);
```

**`Promise.all` fails fast — one rejection rejects the whole.** For loaders that should redirect on missing data, this is what you want (one failure → render dies → user sees the error boundary). For loaders that should partially-succeed (e.g., "show the page even if billing data is unavailable"), use `Promise.allSettled`:

```ts
const [projectsResult, billingResult] = await Promise.allSettled([
  api.getProjects(user.id),
  externalBillingProvider.getInvoices(user.id),  // OK if this fails.
]);

const projects = projectsResult.status === 'fulfilled' ? projectsResult.value : [];
const billing = billingResult.status === 'fulfilled' ? billingResult.value : null;
```

**Watch the database connection pool ceiling.** A loader that fans out to 20 parallel reads can starve the pool. Most Supabase plans cap at 60-200 connections — parallel reads from a high-traffic loader (many users × many parallel queries) can saturate quickly. If a loader fans out to more than ~5 parallel queries, look for ways to combine them server-side (e.g., a database view or RPC).

**`Promise.all` over arrays from `.map`:**

```ts
// Each ID becomes a query; all run in parallel.
const accounts = await Promise.all(
  accountIds.map((id) => api.getAccount(id)),
);
```

For large N, batch into chunks of ~5-10 to avoid pool saturation, or write an `.in()` query that fetches them all in one round-trip:

```ts
// One query instead of N.
const { data: accounts } = await client
  .from('accounts')
  .select('*')
  .in('id', accountIds);
```

Reference: [MDN Promise.all](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)
