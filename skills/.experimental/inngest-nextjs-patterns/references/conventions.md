# Inngest + Next.js Conventions

These are the conventions the templates enforce, with the reasoning behind each. Once you understand the reasoning you can make informed exceptions; without it you'll trip the same wires Inngest's own users have tripped.

## Event Naming: `domain/entity.verb_past`

Examples: `user/account.created`, `shop/order.placed`, `billing/invoice.paid`, `ai/summary.requested`.

The shape is three parts:

1. **`domain`** — the business area (single token, lowercase). `shop`, `billing`, `user`, `ai`, `comms`.
2. **`entity`** — what the event is about. `order`, `invoice`, `account`.
3. **`verb_past`** — what just happened. `created`, `placed`, `paid`, `requested`, `cancelled`.

**Why:**

- It's the shape every Inngest example uses. Pattern-matching across the docs is much easier when local events look the same.
- The Inngest dashboard sorts by event name. Grouping by domain prefix lets you scope filters: `shop/*`, `billing/invoice.*`.
- Past-tense verbs prevent the most common modelling mistake: emitting an event that means "please do X" (a command). Events describe facts that have already happened; functions decide what to do about them. If you find yourself reaching for present tense, you're modelling a command — consider whether `step.invoke` (direct function call) fits better.

**Exception:** If the producer is a third party that picks its own name (e.g., `clerk/user.created`, `stripe/invoice.paid`), keep the third-party name verbatim. Mirroring their convention loses you grep-ability across their docs and your code.

## Function ID Stability

Function IDs (the `id` field in `createFunction`) are **permanent durable keys**. Inngest uses them to:

- Match in-flight runs back to the new code after deploy
- Associate step results from a paused run with the next attempt
- Identify the function in the dashboard, alerts, and logs

**Why this matters:**

If you rename `process-order` → `process-customer-order` and deploy, any paused or scheduled runs of the old function are orphaned. They'll never resume. Multi-day workflows (e.g., `step.sleep("7d")`) silently fail.

**Rule:** treat function IDs like database primary keys. Pick once, kebab-case, prefer descriptive (`charge-and-fulfill-order`) over short (`order-job`). Renaming requires a migration: deploy both names, let the old runs drain, then remove the old.

The friendly `name:` field, by contrast, is purely cosmetic — change it freely.

## Step ID Stability and Idempotency

Inside a function, each `step.run("step-id", fn)` call is **memoized by step ID across attempts**. Inngest stores the result in durable storage; on retry or replay, it returns the cached result without re-running the closure.

This has two consequences you have to internalise:

### 1. Step IDs are durable keys too.

Renaming `step.run("charge", ...)` → `step.run("charge-customer", ...)` invalidates the cache for that step. On replay of an existing run, the new step re-executes from scratch — possibly running side effects again. Prefer descriptive IDs from the start; if you must rename, deploy alongside the old name during the migration window.

### 2. The closure inside `step.run` may run more than once.

A successful step runs once. A step that throws runs again on the next attempt. A step that runs to completion but the function then crashes before persisting may run again on retry (Inngest aims for at-least-once at the function level; at-most-once requires the step to be idempotent).

**Rule:** every external side effect inside `step.run` must be idempotent.

- API calls that mutate state: pass an idempotency key derived from `event.data` or `runId + step-id`.

  ```ts
  await stripe.charges.create(
    { amount, customer: cust },
    { idempotencyKey: `${runId}:charge` },
  );
  ```

- Database writes: use upserts, not inserts. Or check-then-act on a unique key.
- Sending email/SMS: write a "sent" record under a unique key first, send second. Reads of the record gate further sends.

**Exception:** read-only steps (`getUser`, `fetchInventory`) don't need keys — re-running them is safe. But it costs duplicate API calls, so cache the result.

## Code Outside Steps Is Plumbing, Not Logic

The function body re-executes from the top on every step boundary. Inngest replays the deterministic prelude, hits the next un-completed step, runs it, then crashes the process and starts fresh from the top for the step after that.

**This means code outside `step.run` runs multiple times.** If you do this:

```ts
async ({ event, step }) => {
  const user = await db.users.find(event.data.id); //   bad — runs every replay

  await step.run("a", async () => { /* ... */ });
  await step.run("b", async () => { /* ... */ });
}
```

…the database fetch happens at least twice (once per step), maybe more. Worse, the result isn't durable — if the DB changes between replays, the two attempts see different `user` objects.

**Rule:** every read or write of mutable state goes inside `step.run`. The function body should contain only:

- Reading `event.data` (immutable per run)
- Calling `step.*`
- Cheap pure transforms of step results (joining strings, picking fields)
- Branching/looping based on step results

**Why:** the same memoization that protects retries from double-side-effects makes step results the only durable values across replays.

## One Schema Per Event, Co-Located With the Event

Define the schema in the same file that exports the event symbol:

```ts
// src/inngest/events/shop.ts
export const orderPlaced = eventType("shop/order.placed", {
  schema: z.object({
    orderId: z.string(),
    accountId: z.string(),
    totalCents: z.number().int().nonnegative(),
  }),
});
```

**Why decentralized (one file per domain) instead of one big schemas file:**

- Inngest's TypeScript SDK v4 explicitly moved away from the centralized `EventSchemas` pattern of v3. The current docs and examples all use per-event `eventType()`.
- Co-location means changing a payload and changing its producers happens in one PR, one diff. With a central schema file the producer is in `app/api/webhook/route.ts` and the schema is in `inngest/schemas.ts` — easy to forget one.
- Domain files become the readable inventory of a domain's vocabulary. Open `events/shop.ts` to see every event the shop domain emits.

## Payloads Carry IDs, Not Whole Objects

Bad:

```ts
await inngest.send({
  name: "shop/order.placed",
  data: { order, customer, items }, // 50KB JSON blob
});
```

Good:

```ts
await inngest.send({
  name: "shop/order.placed",
  data: { orderId: order.id },
});
```

**Why:**

- Events are durable: every event is stored. Big payloads inflate storage and replay overhead.
- State drifts. A snapshot of `order` from event time is stale by the time the function runs. The function should reload fresh state inside `step.run`.
- Step results are also persisted. Loading the order inside `step.run("load-order", ...)` makes that load idempotent and cached for the duration of the run.

**Exception:** include enough denormalized data to make routing/filtering decisions without an extra DB hit. For example, `accountId` on every event keyed for per-tenant concurrency.

## Function Registry: One File, Imported Once

The route handler imports a single array. Adding a new function = one line in the registry, the route handler never changes:

```ts
// src/inngest/functions/index.ts
import { processOrder } from "./process-order";
import { sendWelcomeEmail } from "./send-welcome-email";
import { dailyReport } from "./daily-report";

export const functions = [processOrder, sendWelcomeEmail, dailyReport];
```

```ts
// src/app/api/inngest/route.ts
import { functions } from "@/inngest/functions";
import { inngest } from "@/inngest/client";

export const { GET, POST, PUT } = serve({ client: inngest, functions });
```

**Why:**

- The route handler is high-traffic infrastructure code. You don't want unrelated function edits triggering noise in that file's blame.
- Listing functions in one place gives you a single grep-able inventory.
- Inngest's `serve()` registers what you pass. Forgetting to add a function to the route is the most common "why isn't my function running?" — a registry makes it a one-line addition instead of a multi-step process.

## Cron vs Event Triggers

Use a **cron trigger** when the schedule is the source of truth — "every weekday at 9am report yesterday's metrics." Use an **event trigger** when something happening is the source of truth — "send a welcome email after a user signs up."

Don't simulate one with the other:

- Don't trigger every minute and check "is now within the window?" — Inngest charges per run; bursty work that's mostly no-ops wastes budget.
- Don't fire a manufactured event from external cron and have the function check the time — you've moved the schedule out of Inngest's view and lost the dashboard's visibility.

**Cron expression specifics:**

- 5 fields: `m h dom mon dow`. Standard Unix cron.
- Default timezone is UTC. To use another, prefix with `TZ=…`: `cron("TZ=America/New_York 0 9 * * 1-5")`. Inngest handles DST correctly.
- Crons emit a synthetic event under the hood. The handler receives `event` but it has no `data`. Don't write code that reads `event.data` in a cron-only function.

**Combine triggers** when you want a scheduled job that can also be kicked off manually (helpful for development):

```ts
triggers: [
  cron("0 9 * * *"),
  reportRequested, // event symbol for ad-hoc invocation
],
```

## Fan-Out Patterns

Two distinct shapes. Picking the right one matters because the wrong one either silently drops failures or blows up memory.

### Fire-and-forget: `step.sendEvent`

The orchestrator emits one event per item and returns immediately. Each child run is its own durable function — retries independently, observes independently.

```ts
await step.sendEvent(
  "dispatch",
  items.map((item) => ({ name: "import/contact.requested", data: { id: item.id } })),
);
return { dispatched: items.length };
```

- Scales to millions of items (events are cheap).
- Orchestrator finishes fast; no way to know aggregate success.
- Use when items are independent and the orchestrator doesn't need to act on results.

### Wait-for-results: `Promise.all(step.invoke(...))`

The orchestrator invokes the child function directly and waits for each result. Child runs are sub-workflows of the parent.

```ts
const results = await Promise.all(
  items.map((item, idx) =>
    step.invoke(`child-${item.id}-${idx}`, {
      function: importContact,
      data: { id: item.id },
      timeout: "10m",
    }),
  ),
);
```

- Each `step.invoke` is a step — its result is durable and memoized.
- The orchestrator's runtime is bounded by the slowest child. A child that retries for hours holds the orchestrator open.
- Concurrency is gated by the child function's `concurrency` setting, not the orchestrator's.
- Use when you need to aggregate results (sum totals, collect errors, decide a next action).
- Chunk if `items.length > ~200` — `Promise.all` over thousands of invokes exhausts memory.

## Concurrency, Throttle, Rate-Limit, Debounce — Pick the Right One

They sound similar; they solve different problems.

| Control | What it does | When to use |
|---|---|---|
| `concurrency` | Cap how many runs are *in flight at once*. New runs queue. | Protecting a downstream resource (DB connection pool, third-party API concurrency limit). |
| `throttle` | Cap how many runs *start per period*. Excess runs queue. | Smoothing a bursty input into a steady rate (e.g., webhook floods). |
| `rateLimit` | Cap how many runs *start per period*. Excess runs are **dropped**. | Hard limits where you'd rather skip than queue (free-tier abuse, cost ceilings). |
| `debounce` | Coalesce many same-key events into a single run after a quiet period. | "User edited their profile 12 times in 30s — only run the indexing job once." |

**Common mistake:** using `concurrency` to "rate limit" — concurrency doesn't slow down a single fast run, it just caps parallelism. If your downstream is "100 requests per minute," that's a `throttle`.

All four take a `key` field for per-tenant isolation:

```ts
concurrency: { limit: 5, key: "event.data.accountId", scope: "fn" }
```

…means "5 concurrent runs **per accountId**, not 5 globally." Without `key`, one heavy tenant starves everyone.

## Dev Server: `INNGEST_DEV=1`

Local development needs the Inngest dev server. Run it alongside `next dev`:

```
npx inngest-cli@latest dev
```

In `.env.local`:

```
INNGEST_DEV=1
```

The SDK auto-detects this and points `inngest.send` and the route handler at the local dev server (http://localhost:8288) instead of Inngest Cloud. You can see runs, inspect step state, manually re-run, and replay from any step in the dev UI.

**Why this matters:** without `INNGEST_DEV=1`, the SDK tries to talk to Inngest Cloud. In dev that means either silent no-ops (no event key set) or actual cloud invocations (event key set, which is worse — production traffic touched by local code).

## Path Overrides

If your project uses `app/` (no `src/`) or Pages Router, override defaults in `config.json`:

```json
{
  "client_path": "inngest/client.ts",
  "route_path": "app/api/inngest/route.ts",
  "events_dir": "inngest/events",
  "functions_dir": "inngest/functions"
}
```

The templates still work — the placeholder paths in their import statements need to match. The conventions above are unchanged regardless of layout.
