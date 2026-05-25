# Primitives Catalog

Reusable primitives in the opencode TypeScript codebase. Every entry shows the import, signature, a real usage example, and when to reach for it.

---

## 1. Effect Runtime

### makeRuntime

```ts
import { makeRuntime } from "@/effect/run-service"
```

```ts
export function makeRuntime<I, S, E>(
  service: Context.Service<I, S>,
  layer: Layer.Layer<I, E>,
): {
  runSync: <A, Err>(fn: (svc: S) => Effect.Effect<A, Err, I>) => A
  runPromise: <A, Err>(fn: (svc: S) => Effect.Effect<A, Err, I>, options?: Effect.RunOptions) => Promise<A>
  runFork: <A, Err>(fn: (svc: S) => Effect.Effect<A, Err, I>) => Fiber<A, Err>
  runCallback: <A, Err>(fn: (svc: S) => Effect.Effect<A, Err, I>) => void
}
```

```ts
// bus/index.ts -- only modules with imperative (non-Effect) callers keep a facade
const { runPromise, runSync } = makeRuntime(Service, layer)

export async function publish(ctx, def, properties, options?) {
  return runPromise((svc) => svc.publish(def, properties, options).pipe(Effect.provideService(InstanceRef, ctx)))
}
```

Use when: bridging an Effect `Context` service to imperative async/sync callers. Pure Effect-land services (Question, Permission) skip this — they're used via `yield* X.Service`.

### memoMap

```ts
import { memoMap } from "@/effect/run-service"
```

```ts
export const memoMap = Layer.makeMemoMapUnsafe()
```

Module-level singleton shared across all runtimes. Ensures Effect layers are instantiated once globally.

Use when: never directly -- it is consumed internally by `makeRuntime`. Only relevant if building a custom runtime.

### InstanceState.make

```ts
import { InstanceState } from "@/effect/instance-state"
```

```ts
export const make = <A, E = never, R = never>(
  init: (ctx: InstanceContext) => Effect.Effect<A, E, R | Scope.Scope>,
): Effect.Effect<InstanceState<A, E, Exclude<R, Scope.Scope>>, never, R | Scope.Scope>
```

```ts
// bus/index.ts
const cache = yield* InstanceState.make<State>(
  Effect.fn("Bus.state")(function* (ctx) {
    const wildcard = yield* PubSub.unbounded<Payload>()
    const typed = new Map<string, PubSub.PubSub<Payload>>()
    yield* Effect.addFinalizer(() => Effect.gen(function* () {
      yield* PubSub.shutdown(wildcard)
      for (const ps of typed.values()) yield* PubSub.shutdown(ps)
    }))
    return { wildcard, typed }
  }),
)
```

Use when: you need per-project-directory state inside an Effect layer that auto-invalidates on instance disposal.

### Context.Service

```ts
import { Context } from "effect"
```

```ts
// question/index.ts
export class Service extends Context.Service<Service, Interface>()("@opencode/Question") {}

export const layer = Layer.effect(Service, Effect.gen(function* () {
  // ... build state, define methods
  return Service.of({ ask, reply, reject })
}))
```

Use when: defining a new Effect-based service. `Context.Service` replaced both `effect/ServiceMap`'s `ServiceMap.Service` (early v4-beta) and the older `Context.Tag` pattern.

---

## 2. Identity

### Identifier.ascending / Identifier.descending

```ts
import { Identifier } from "@/id/id"
```

```ts
export function ascending(prefix: keyof typeof prefixes, given?: string): string
export function descending(prefix: keyof typeof prefixes, given?: string): string
```

Prefixes: `event`=`evt`, `session`=`ses`, `message`=`msg`, `permission`=`per`, `question`=`que`, `user`=`usr`, `part`=`prt`, `pty`=`pty`, `tool`=`tool`, `workspace`=`wrk`.

Format: `<prefix>_<6-byte-timestamp-hex><14-char-random-base62>` (26 chars after prefix).

- `ascending` -- IDs sort oldest-first. Used for messages, parts, events.
- `descending` -- bitwise NOT on timestamp, IDs sort newest-first. Used for sessions.
- `given` -- if provided, validates prefix and returns it unchanged (idempotent).

```ts
// session/schema.ts
SessionID.descending()  // => "ses_ff0a1b2c3d4eAbCdEfGhIjKlMn"

// message/schema.ts
MessageID.ascending()   // => "msg_00f5e4d3c2b1XyZaBcDeFgHiJk"
```

Use when: generating a new ID for any entity. Always use the domain-specific wrapper (e.g., `SessionID.descending()`) rather than calling `Identifier` directly.

### Identifier.timestamp

```ts
export function timestamp(id: string): number
```

Extracts the Unix timestamp from an ascending ID. Does NOT work with descending IDs.

Use when: you need to know when an ascending ID was created without a DB lookup.

---

## 3. Schema

### Branded IDs (Schema.String.check + brand + withStatics)

```ts
import { withStatics } from "@opencode-ai/core/schema"
```

The standard pattern for branded ID types — a prefix check, `Schema.brand`, and static factories:

```ts
// session/schema.ts
export const MessageID = Schema.String.check(Schema.isStartsWith("msg")).pipe(
  Schema.brand("MessageID"),
  withStatics((s) => ({
    ascending: (id?: string) => s.make(Identifier.ascending("message", id)),
  })),
)
export type MessageID = Schema.Schema.Type<typeof MessageID>
```

Each branded ID exposes `.make(raw)` to brand a validated string and `.ascending()`/`.descending()` to mint a fresh one. There is **no `.zod` bridge** — the branded schema is used directly wherever a schema is needed.

Use when: defining a new entity type that needs a branded ID.

### withStatics

```ts
import { withStatics } from "@opencode-ai/core/schema"
```

```ts
export const withStatics =
  <S extends object, M extends Record<string, unknown>>(methods: (schema: S) => M) =>
  (schema: S): S & M =>
    Object.assign(schema, methods(schema))
```

```ts
// sync/schema.ts
export const EventID = Schema.String.check(Schema.isStartsWith("evt")).pipe(
  Schema.brand("EventID"),
  withStatics((s) => ({
    ascending: (id?: string) => s.make(Identifier.ascending("event", id)),
  })),
)
```

Use when: attaching static factories to an Effect Schema in a `.pipe()` chain.

### Newtype (class-based, for IDs with methods)

```ts
import { Newtype } from "@opencode-ai/core/schema"
```

```ts
// question/schema.ts
export class QuestionID extends Newtype<QuestionID>()("QuestionID", Schema.String.check(Schema.isStartsWith("que"))) {
  static ascending(id?: string): QuestionID {
    return this.make(Identifier.ascending("question", id))
  }
}
```

`Newtype<Self>()(tag, schema)` returns a class that IS the schema (the `Self` generic enables circular type references). Use the class form when you want instance/static methods; the `.pipe(withStatics)` form when a value plus a couple of factories is enough.

### .annotate({ identifier })

```ts
Schema.Struct({ ... }).annotate({ identifier: "SessionInfo" })
```

Attaches a reference name to a schema (replaced Zod's `.meta({ ref })`). Used by SDK/JSON-Schema generation and discriminated-union construction; `.annotate({ description })` documents a field.

```ts
// bus/bus-event.ts
Schema.Struct({
  type: Schema.Literal(type),
  properties: def.properties,
}).annotate({ identifier: "Event." + def.type })
```

Use when: any schema that will appear in generated SDKs or API types.

---

## 4. Validation

### fn (validated commands)

```ts
import { fn } from "@/util/fn"
```

```ts
export function fn<T extends Schema.Top, Result>(
  schema: T,
  cb: (input: Schema.Schema.Type<T>) => Result,
): ((input: Schema.Schema.Type<T>) => Result) & { force: (input: Schema.Schema.Type<T>) => Result; schema: T }
```

```ts
export const create = fn(
  Schema.Struct({
    sessionID: SessionID,
    title: Schema.String,
  }),
  (input) => {
    // input is validated and typed
    SyncEvent.run(Event.Created, { sessionID: input.sessionID, info: { ... } })
  },
)

// Bypass validation for trusted internal calls:
create.force({ sessionID, title })

// Introspect schema for docs/SDK generation:
create.schema
```

Use when: defining a command/mutation that receives external input and needs runtime Zod validation.

---

## 5. Lifecycle

### lazy

```ts
import { lazy } from "@/util/lazy"
```

```ts
export function lazy<T>(fn: () => T): (() => T) & { reset: () => void }
```

```ts
// storage/db.ts
export const Client = lazy(() => {
  const db = init(Path)
  db.run("PRAGMA journal_mode = WAL")
  db.run("PRAGMA synchronous = NORMAL")
  db.run("PRAGMA busy_timeout = 5000")
  return db
})

// Reset on close to allow reopening:
Client.reset()
```

Failures are NOT cached -- on error, subsequent calls retry. `.reset()` allows re-initialization.

Use when: expensive initialization that should happen on first use, not at import time.

### defer

```ts
import { defer } from "@/util/defer"
```

```ts
export function defer<T extends () => void | Promise<void>>(fn: T):
  { [Symbol.dispose]: () => void; [Symbol.asyncDispose]: () => Promise<void> }
```

```ts
using _ = defer(() => cleanup())
await using _ = defer(() => asyncCleanup())
```

Implements both `Symbol.dispose` and `Symbol.asyncDispose`. Works with `using` and `await using`.

Use when: Go-style deferred cleanup in a scope.

### iife

```ts
import { iife } from "@/util/iife"
```

```ts
export function iife<T>(fn: () => T): T
```

```ts
// storage/db.ts
export const Path = iife(() => {
  if (Flag.OPENCODE_DB) return customPath()
  return getChannelPath()
})
```

Use when: multi-line const initializers that need intermediate logic. Preserves type inference.

---

## 6. Async

### AsyncQueue

```ts
import { AsyncQueue } from "@/util/queue"
```

```ts
class AsyncQueue<T> implements AsyncIterable<T> {
  push(item: T): void
  next(): Promise<T>
  [Symbol.asyncIterator](): AsyncIterableIterator<T>
}
```

```ts
const queue = new AsyncQueue<Message>()
queue.push(msg)

// Consume with for-await:
for await (const item of queue) {
  handle(item)  // loops forever -- break externally
}
```

Unbounded async channel. `push` resolves a waiting consumer immediately or buffers. Iterator never terminates.

Use when: producer/consumer patterns where items arrive asynchronously.

### work (bounded concurrency)

```ts
import { work } from "@/util/queue"
```

```ts
export async function work<T>(concurrency: number, items: T[], fn: (item: T) => Promise<void>): Promise<void>
```

Simple bounded-concurrency worker pool. Uses `pop()` (LIFO, O(1)).

Use when: processing a known list of items with limited parallelism.

### Lock (read-write, in-process)

```ts
import { Lock } from "@/util/lock"
```

```ts
export async function read(key: string): Promise<Disposable>
export async function write(key: string): Promise<Disposable>
```

```ts
// storage/storage.ts
using _ = await Lock.read(target)
const content = await Filesystem.readJson<T>(target)

using _ = await Lock.write(target)
await Filesystem.writeJson(target, content)
```

In-process RW lock. Writers are prioritized to prevent starvation. Returns `Disposable` for `using`.

Use when: concurrent in-process access to a shared resource (files, maps).

### Flock (filesystem, cross-process)

```ts
import { Flock } from "@/util/flock"
```

```ts
export async function acquire(key: string, input?: Options): Promise<Lease>
export async function withLock<T>(key: string, fn: () => Promise<T>, input?: Options): Promise<T>
```

```ts
await using _ = await Flock.acquire("my-resource")
// ... exclusive access

await Flock.withLock("my-resource", async () => {
  // ... exclusive access
})
```

Filesystem lock using `mkdir` atomicity. Heartbeat-based stale detection. Breaker pattern for safe stale lock cleanup. Exponential backoff with jitter.

Use when: cross-process mutual exclusion (multiple CLI instances, parallel builds).

### withTimeout

```ts
import { withTimeout } from "@/util/timeout"
```

```ts
export function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T>
```

```ts
const result = await withTimeout(fetch(url), 5000)
```

Use when: adding a timeout to any promise. Clears the timer on success.

### abortAfterAny

```ts
import { abortAfter, abortAfterAny } from "@/util/abort"
```

```ts
export function abortAfter(ms: number): { controller: AbortController; signal: AbortSignal; clearTimeout: () => void }
export function abortAfterAny(ms: number, ...signals: AbortSignal[]): { signal: AbortSignal; clearTimeout: () => void }
```

```ts
const { signal, clearTimeout } = abortAfterAny(30_000, request.signal)
try {
  await fetch(url, { signal })
} finally {
  clearTimeout()
}
```

Uses `.bind(controller)` instead of arrow functions to avoid capturing large objects in closure scope.

Use when: combining a timeout with external AbortSignals (e.g., request cancellation + deadline).

### signal

```ts
import { signal } from "@/util/signal"
```

```ts
export function signal(): { trigger: () => void; wait: () => Promise<void> }
```

One-shot signaling mechanism. `trigger()` resolves the promise; `wait()` awaits it.

Use when: coordinating a one-time "ready" or "done" event between async tasks.

---

## 7. Logging

### Log.create

```ts
import * as Log from "@opencode-ai/core/util/log"
```

```ts
export function create(tags?: Record<string, any>): Logger
```

```ts
const log = Log.create({ service: "session" })
log.info("created", { sessionID: id })
log.error("failed", { error: err })

// Timed operations (works with `using`):
using _ = log.time("migration")

// Tag mutation:
log.tag("phase", "init")
```

Loggers are cached by `service` tag -- same service name returns the same instance. Format: `LEVEL YYYY-MM-DDTHH:MM:SS +<delta>ms key=value message`.

Use when: any module needs logging. Always pass `{ service: "name" }`.

---

## 8. Local Context

### LocalContext.create (AsyncLocalStorage wrapper)

```ts
import { LocalContext } from "@/util/local-context"
```

Renamed from `Context` to `LocalContext` so it no longer collides with Effect's `Context` (the DI/service namespace). It is opencode's own AsyncLocalStorage helper — unrelated to `Context.Service`.

```ts
export function create<T>(name: string): {
  use(): T                                // throws LocalContext.NotFound if missing
  provide<R>(value: T, fn: () => R): R    // runs fn with value in scope
}
```

```ts
// storage/db.ts
const ctx = LocalContext.create<{ tx: TxOrDb; effects: (() => void)[] }>("database")

// Provide:
ctx.provide({ tx: client, effects: [] }, () => callback(client))

// Consume:
const { tx } = ctx.use()
```

Use when: implicit propagation of request-scoped state (transactions, instance context) without threading parameters.

### Instance (project-scoped context)

```ts
import { Instance } from "@/project/instance"
```

```ts
const Instance = {
  provide<R>(input: { directory: string; init?: () => Promise<any>; fn: () => R }): Promise<R>,
  get current(): InstanceContext,
  get directory(): string,
  get worktree(): string,
  get project(): Project.Info,
  bind<F extends (...args: any[]) => any>(fn: F): F,
  state<S>(init: () => S, dispose?: (state: Awaited<S>) => Promise<void>): () => S,
  dispose(): Promise<void>,
}
```

```ts
// cli/bootstrap.ts
await Instance.provide({
  directory,
  init: InstanceBootstrap,
  fn: async () => {
    const result = await cb()
    await Instance.dispose()
    return result
  },
})

// Reading current context (anywhere inside provide scope):
const dir = Instance.directory

// Binding a callback to preserve instance context:
const cb: ParcelWatcher.SubscribeCallback = Instance.bind((err, evts) => {
  for (const evt of evts) Bus.publish(Event.Updated, { file: evt.path })
})

// Per-directory state:
const state = Instance.state(async () => {
  return await loadConfig(Instance.directory)
})
```

Use when: `provide` at entry points (CLI bootstrap, HTTP middleware). Read `directory`/`project`/`worktree` anywhere inside. Use `bind` when passing callbacks to external libraries that lose AsyncLocalStorage context. Use `state` for per-project cached state.

---

## 9. Events

### BusEvent.define

```ts
import { BusEvent } from "@/bus/bus-event"
```

```ts
export function define<Type extends string, Properties extends Schema.Top>(
  type: Type,
  properties: Properties,
): Definition<Type, Properties>
```

```ts
// question/index.ts
export const Event = {
  Asked: BusEvent.define("question.asked", Request),
  Replied: BusEvent.define("question.replied", Schema.Struct({
    sessionID: SessionID,
    requestID: QuestionID,
    answers: Schema.Array(Answer),
  })),
}
```

Events are auto-registered in a global registry. `BusEvent.effectPayloads()` builds the discriminated union for SDK generation.

Use when: defining a new pub/sub event type.

### Bus.publish / Bus.subscribe

```ts
import { Bus } from "@/bus"
```

```ts
// top-level async facade (for imperative callers)
export async function publish<D>(ctx: InstanceContext, def: D, properties: Schema.Schema.Type<D["properties"]>): Promise<void>
export function subscribe<D>(def: D, callback: (event: { properties: Schema.Schema.Type<D["properties"]> }) => unknown): () => void
```

```ts
// Inside an Effect service: acquire the bus, then yield* publish (it returns an Effect)
const bus = yield* Bus.Service
yield* bus.publish(Event.Asked, { sessionID, requestID: id, tool: input.tool })

// Imperative subscribe (returns unsubscribe function):
const unsub = Bus.subscribe(Session.Event.Updated, (event) => {
  console.log("session updated:", event.properties.sessionID)
})
```

Inside a service, `bus.publish(...)` is an `Effect` — yield it (not fire-and-forget). The top-level `Bus.publish(ctx, ...)` (async) and `Bus.subscribe` (runSync) are facades for imperative callers.

Use when: decoupled communication between modules.

### SyncEvent.define / SyncEvent.run / SyncEvent.project

```ts
import { SyncEvent } from "@/sync"
```

```ts
export function define<Type, Agg, Schm, BusSchm>(input: {
  type: Type; version: number; aggregate: Agg; schema: Schm; busSchema?: BusSchm
}): Definition

export function run<Def>(def: Def, data: Schema.Schema.Type<Def["schema"]>): void

export function project<Def>(def: Def, fn: (db: TxOrDb, data: Schema.Schema.Type<Def["schema"]>) => void): [Def, ProjectorFunc]
```

```ts
// Define events:
export const Event = {
  Created: SyncEvent.define({
    type: "session.created",
    version: 1,
    aggregate: "sessionID",
    schema: Schema.Struct({ sessionID: SessionID, info: Info }),
  }),
}

// Run an event (validates, stores, projects, publishes to Bus):
SyncEvent.run(Event.Updated, { sessionID, info: { time: { updated: Date.now() } } })

// Define a projector:
export default [
  SyncEvent.project(Session.Event.Created, (db, data) => {
    db.insert(SessionTable).values(Session.toRow(data.info)).run()
  }),
  SyncEvent.project(Session.Event.Updated, (db, data) => {
    db.update(SessionTable).set(toPartialRow(data.info))
      .where(eq(SessionTable.id, data.sessionID)).run()
  }),
]
```

Event sourcing pipeline: `define` -> `run` (stores event + calls projector) -> projector writes to SQLite -> Bus publishes after commit via `Database.effect()`.

Use when: any state mutation that needs event history, replay, and real-time notification.

---

## 10. Database

### Database.use

```ts
import { Database } from "@/storage/db"
```

```ts
export function use<T>(callback: (db: TxOrDb) => T): T
```

```ts
// permission/index.ts
const row = Database.use((db) =>
  db.select().from(PermissionTable).where(eq(PermissionTable.project_id, ctx.project.id)).get()
)
```

Auto-creates a context if none exists. If already inside a transaction, reuses that transaction's connection.

Use when: read-only queries or simple writes that don't need explicit transaction control.

### Database.transaction

```ts
export function transaction<T>(callback: (tx: TxOrDb) => T, options?: { behavior?: "immediate" }): T
```

```ts
// sync/index.ts
Database.transaction((tx) => {
  const id = EventID.ascending()
  const row = tx.select({ seq }).from(EventSequenceTable).where(...).get()
  const seq = row?.seq != null ? row.seq + 1 : 0
  tx.insert(EventTable).values({ id, seq, ... }).run()
}, { behavior: "immediate" })
```

Reentrant: nested calls reuse the existing transaction. Use `{ behavior: "immediate" }` for write transactions that need read consistency. Callbacks must be synchronous (SQLite).

Use when: multiple DB operations that must be atomic.

### Database.effect

```ts
export function effect(fn: () => any | Promise<any>): void
```

```ts
// sync/index.ts
Database.effect(() => {
  Bus.publish(Event.Updated, { sessionID, info })
})
```

Queues a side effect to run AFTER the current transaction commits. If called outside a transaction, runs immediately.

Use when: side effects (Bus publishing, notifications) that should only happen if the transaction succeeds.

### Drizzle patterns

```ts
// Table definition -- snake_case fields (AGENTS.md rule):
export const SessionTable = sqliteTable("session", {
  id: text().$type<SessionID>().primaryKey(),
  project_id: text().$type<ProjectID>().notNull()
    .references(() => ProjectTable.id, { onDelete: "cascade" }),
  ...Timestamps,
  data: text({ mode: "json" }).notNull().$type<InfoData>(),
})
```

```ts
// Reusable timestamp columns:
import { Timestamps } from "@/storage/schema.sql"

export const Timestamps = {
  time_created: integer().notNull().$default(() => Date.now()),
  time_updated: integer().notNull().$onUpdate(() => Date.now()),
}
```

```ts
// Platform-conditional import via #db alias:
import { init } from "#db"  // Resolves to db.bun.ts or db.node.ts
```

---

## 11. Errors

### NamedError.create

```ts
import { NamedError } from "@opencode-ai/core/util/error"
```

```ts
export abstract class NamedError extends Error {
  // `data` is an object of Schema fields (sugar for Schema.Struct) or a full Schema
  static create<Name extends string>(
    name: Name,
    data: Schema.Top | Schema.Struct.Fields,
  ): typeof NamedError & { Schema: Schema.Top; tag: Name; new(data, options?: ErrorOptions): NamedError }
}
```

```ts
// session/message-v2.ts
export const AbortedError = NamedError.create("MessageAbortedError", {
  message: Schema.String,
})

// provider/provider.ts
export const ModelNotFoundError = NamedError.create("ProviderModelNotFoundError", {
  providerID: ProviderID,
  modelID: ModelID,
  suggestions: Schema.optional(Schema.Array(Schema.String)),
})

// Throwing:
throw new AbortedError({ message: "User cancelled" })

// Serialization (for API responses):
error.toObject()  // => { name: "MessageAbortedError", data: { message: "User cancelled" } }

// Schema access:
AbortedError.Schema  // Effect Schema (Schema.Struct({ name: Schema.Literal(tag), data })) for validation/SDK generation
```

Each subclass has a `.Schema` static (Effect Schema) for introspection, a `.tag`, and a `.toObject()` for serialization.

Use when: serializable cross-boundary errors (API responses, wire/storage, assistant-message errors).

### Schema.TaggedErrorClass

```ts
import { Schema } from "effect"
```

```ts
export class RejectedError extends Schema.TaggedErrorClass<RejectedError>()("QuestionRejectedError", {}) {
  override get message() { return "The user dismissed this question" }
}

export class AuthError extends Schema.TaggedErrorClass<AuthError>()("AuthError", {
  message: Schema.String,
  cause: Schema.optional(Schema.Defect),
}) {}

export class DeniedError extends Schema.TaggedErrorClass<DeniedError>()("PermissionDeniedError", {
  ruleset: Schema.Any,
}) {
  override get message() {
    return `The user has specified a rule which prevents you from using this tool call.`
  }
}
```

Effect-native errors with `_tag` discriminator. Used inside Effect pipelines where errors flow through the type system.

Use when: errors within Effect service implementations that need to be caught/matched via `_tag`.

### When to use which error pattern

| Pattern | Built on | When |
|---------|----------|------|
| `NamedError.create` | Effect Schema (`Schema.Struct({ name, data })`) | API boundaries, wire/storage, serializable discriminated-union errors |
| `Schema.TaggedErrorClass` | Effect Schema | Inside Effect pipelines, typed error channels (the `E` in `Effect.Effect<A, E>`) |
