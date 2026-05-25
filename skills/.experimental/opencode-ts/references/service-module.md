# Service Module Reference

Two complete service module implementations from the opencode codebase, copied verbatim from the `dev` branch (post Effect v4-beta migration). Read these before writing a new module.

---

## Anatomy of a service module

A module is a single file of **flat top-level exports**, closed by a self-barrel. There is no `export namespace X { }` wrapper anymore — the barrel at the bottom is what makes `import { X } from "@/x"` resolve to a namespace.

```
1.  Imports (effect, internal @/ imports, @opencode-ai/core/*, local ./schema)
2.  const log = Log.create({ service: "x" })
3.  Schemas         -- Schema.Struct + Schema.Schema.Type, .annotate({ identifier }) for codegen
4.  Events          -- BusEvent.define("x.eventname", Schema.Struct({ ... }))
5.  Errors          -- Schema.TaggedErrorClass (Effect-native errors)
6.  Internal types  -- PendingEntry, State (not exported)
7.  Interface       -- pure TS interface, methods return Effect.Effect<A, E>
8.  Service class    -- Context.Service<Self, Interface>()("@opencode/X")
9.  use (optional)  -- export const use = serviceUse(Service)
10. layer           -- Layer.effect(Service, Effect.gen(function* () { ... return Service.of({...}) }))
11. defaultLayer    -- layer.pipe(Layer.provide(Dep.layer))
12. Facade (only if needed) -- makeRuntime(Service, layer) + async wrappers for imperative callers
13. export * as X from "."   -- self-barrel; THIS is the module's namespace
```

Consumers depend on `X.Service` inside Effect pipelines (`const x = yield* X.Service`), or call the async facade for Promise-based access from imperative code. **Most services skip the facade** — Question and Permission below have none, because every caller is already in Effect-land. A facade is added only where non-Effect code must call in (see `Bus.publish` in [primitives.md](primitives.md)).

---

## Module 1: Question

The simplest complete service. In-memory question/answer flow using `Deferred` for async request/response coordination. No database, no external dependencies, no facade.

### `question/schema.ts`

```typescript
import { Schema } from "effect"

import { Identifier } from "@/id/id"
import { Newtype } from "@opencode-ai/core/schema"

export class QuestionID extends Newtype<QuestionID>()("QuestionID", Schema.String.check(Schema.isStartsWith("que"))) {
  static ascending(id?: string): QuestionID {
    return this.make(Identifier.ascending("question", id))
  }
}
```

`Newtype` (from `@opencode-ai/core/schema`) gives a branded Effect Schema type with a runtime check (`Schema.isStartsWith("que")`), `.make()` to brand a raw string, and `.ascending()` for time-ordered IDs. Every `Deferred`-based module needs ascending IDs because pending entries are keyed by them. (Note: no more `.zod` bridge — the codebase is on Effect Schema end to end.)

### `question/index.ts`

```typescript
import { Deferred, Effect, Layer, Schema, Context } from "effect"
import { Bus } from "@/bus"
import { BusEvent } from "@/bus/bus-event"
import { InstanceState } from "@/effect/instance-state"
import { SessionID, MessageID } from "@/session/schema"
import * as Log from "@opencode-ai/core/util/log"
import { QuestionID } from "./schema"

const log = Log.create({ service: "question" })

// Schemas — these are pure data; nothing checks class identity (see PR
// description) so they're plain `Schema.Struct` + type alias. That lets
// `Question.ask` and other internal sites trust the type contract without a
// re-decode to coerce nested class instances.

export const Option = Schema.Struct({
  label: Schema.String.annotate({
    description: "Display text (1-5 words, concise)",
  }),
  description: Schema.String.annotate({
    description: "Explanation of choice",
  }),
}).annotate({ identifier: "QuestionOption" })
export type Option = Schema.Schema.Type<typeof Option>

const base = {
  question: Schema.String.annotate({
    description: "Complete question",
  }),
  header: Schema.String.annotate({
    description: "Very short label (max 30 chars)",
  }),
  options: Schema.Array(Option).annotate({
    description: "Available choices",
  }),
  multiple: Schema.optional(Schema.Boolean).annotate({
    description: "Allow selecting multiple choices",
  }),
}

export const Info = Schema.Struct({
  ...base,
  custom: Schema.optional(Schema.Boolean).annotate({
    description: "Allow typing a custom answer (default: true)",
  }),
}).annotate({ identifier: "QuestionInfo" })
export type Info = Schema.Schema.Type<typeof Info>

export const Prompt = Schema.Struct(base).annotate({ identifier: "QuestionPrompt" })
export type Prompt = Schema.Schema.Type<typeof Prompt>

export const Tool = Schema.Struct({
  messageID: MessageID,
  callID: Schema.String,
}).annotate({ identifier: "QuestionTool" })
export type Tool = Schema.Schema.Type<typeof Tool>

export const Request = Schema.Struct({
  id: QuestionID,
  sessionID: SessionID,
  questions: Schema.Array(Info).annotate({
    description: "Questions to ask",
  }),
  tool: Schema.optional(Tool),
}).annotate({ identifier: "QuestionRequest" })
export type Request = Schema.Schema.Type<typeof Request>

export const Answer = Schema.Array(Schema.String).annotate({ identifier: "QuestionAnswer" })
export type Answer = Schema.Schema.Type<typeof Answer>

const Replied = Schema.Struct({
  sessionID: SessionID,
  requestID: QuestionID,
  answers: Schema.Array(Answer),
}).annotate({ identifier: "QuestionReplied" })

const Rejected = Schema.Struct({
  sessionID: SessionID,
  requestID: QuestionID,
}).annotate({ identifier: "QuestionRejected" })

export const Event = {
  Asked: BusEvent.define("question.asked", Request),
  Replied: BusEvent.define("question.replied", Replied),
  Rejected: BusEvent.define("question.rejected", Rejected),
}

export class RejectedError extends Schema.TaggedErrorClass<RejectedError>()("QuestionRejectedError", {}) {
  override get message() {
    return "The user dismissed this question"
  }
}

export class NotFoundError extends Schema.TaggedErrorClass<NotFoundError>()("Question.NotFoundError", {
  requestID: QuestionID,
}) {}

interface PendingEntry {
  info: Request
  deferred: Deferred.Deferred<ReadonlyArray<Answer>, RejectedError>
}

interface State {
  pending: Map<QuestionID, PendingEntry>
}

// Service

export interface Interface {
  readonly ask: (input: {
    sessionID: SessionID
    questions: ReadonlyArray<Info>
    tool?: Tool
  }) => Effect.Effect<ReadonlyArray<Answer>, RejectedError>
  readonly reply: (input: {
    requestID: QuestionID
    answers: ReadonlyArray<Answer>
  }) => Effect.Effect<void, NotFoundError>
  readonly reject: (requestID: QuestionID) => Effect.Effect<void, NotFoundError>
  readonly list: () => Effect.Effect<ReadonlyArray<Request>>
}

export class Service extends Context.Service<Service, Interface>()("@opencode/Question") {}

export const layer = Layer.effect(
  Service,
  Effect.gen(function* () {
    const bus = yield* Bus.Service
    const state = yield* InstanceState.make<State>(
      Effect.fn("Question.state")(function* () {
        const state = {
          pending: new Map<QuestionID, PendingEntry>(),
        }

        // Finalizer: reject all pending deferreds when the scope closes
        // (e.g., project/session teardown). Without this, awaiting fibers hang.
        yield* Effect.addFinalizer(() =>
          Effect.gen(function* () {
            for (const item of state.pending.values()) {
              yield* Deferred.fail(item.deferred, new RejectedError())
            }
            state.pending.clear()
          }),
        )

        return state
      }),
    )

    const ask = Effect.fn("Question.ask")(function* (input: {
      sessionID: SessionID
      questions: ReadonlyArray<Info>
      tool?: Tool
    }) {
      const pending = (yield* InstanceState.get(state)).pending
      const id = QuestionID.ascending()
      log.info("asking", { id, questions: input.questions.length })

      const deferred = yield* Deferred.make<ReadonlyArray<Answer>, RejectedError>()
      const info: Request = {
        id,
        sessionID: input.sessionID,
        questions: input.questions,
        tool: input.tool,
      }
      pending.set(id, { info, deferred })
      yield* bus.publish(Event.Asked, info)

      // Effect.ensuring guarantees the Map entry is deleted even if
      // the Deferred is interrupted (not just succeeded/failed).
      return yield* Effect.ensuring(
        Deferred.await(deferred),
        Effect.sync(() => {
          pending.delete(id)
        }),
      )
    })

    const reply = Effect.fn("Question.reply")(function* (input: {
      requestID: QuestionID
      answers: ReadonlyArray<Answer>
    }) {
      const pending = (yield* InstanceState.get(state)).pending
      const existing = pending.get(input.requestID)
      if (!existing) {
        log.warn("reply for unknown request", { requestID: input.requestID })
        return yield* new NotFoundError({ requestID: input.requestID })
      }
      pending.delete(input.requestID)
      log.info("replied", { requestID: input.requestID, answers: input.answers })
      yield* bus.publish(Event.Replied, {
        sessionID: existing.info.sessionID,
        requestID: existing.info.id,
        answers: input.answers.map((a) => [...a]),
      })
      yield* Deferred.succeed(existing.deferred, input.answers)
    })

    const reject = Effect.fn("Question.reject")(function* (requestID: QuestionID) {
      const pending = (yield* InstanceState.get(state)).pending
      const existing = pending.get(requestID)
      if (!existing) {
        log.warn("reject for unknown request", { requestID })
        return yield* new NotFoundError({ requestID })
      }
      pending.delete(requestID)
      log.info("rejected", { requestID })
      yield* bus.publish(Event.Rejected, {
        sessionID: existing.info.sessionID,
        requestID: existing.info.id,
      })
      yield* Deferred.fail(existing.deferred, new RejectedError())
    })

    const list = Effect.fn("Question.list")(function* () {
      const pending = (yield* InstanceState.get(state)).pending
      return Array.from(pending.values(), (x) => x.info)
    })

    return Service.of({ ask, reply, reject, list })
  }),
)

export const defaultLayer = layer.pipe(Layer.provide(Bus.layer))

export * as Question from "."
```

Note what changed from the old (Zod / `ServiceMap` / `namespace`) shape:
- Dependencies are acquired in the layer: `const bus = yield* Bus.Service` — not via a global `Bus.publish` call.
- `bus.publish(...)` returns an `Effect`, so it is **`yield*`-ed**, not fire-and-forget.
- Errors are real failure channels (`NotFoundError` returned via `yield* new NotFoundError(...)`), so the `Interface` methods carry typed error types.
- The module ends at `defaultLayer` + `export * as Question from "."`. No `makeRuntime`, no `export async function ask()` — Question is consumed only inside Effect pipelines.

---

## Module 2: Permission

A medium-complexity service showing rule evaluation, cascading approvals/rejections, database-backed initial state, multiple error types, and utility functions alongside the Effect service. Still no facade — every caller is in Effect-land.

### `permission/schema.ts`

```typescript
import { Schema } from "effect"

import { Identifier } from "@/id/id"
import { Newtype } from "@opencode-ai/core/schema"

export class PermissionID extends Newtype<PermissionID>()(
  "PermissionID",
  Schema.String.check(Schema.isStartsWith("per")),
) {
  static ascending(id?: string): PermissionID {
    return this.make(Identifier.ascending("permission", id))
  }
}
```

### `permission/index.ts`

```typescript
import { Bus } from "@/bus"
import { BusEvent } from "@/bus/bus-event"
import { ConfigPermission } from "@/config/permission"
import { InstanceState } from "@/effect/instance-state"
import { ProjectID } from "@/project/schema"
import { MessageID, SessionID } from "@/session/schema"
import { PermissionTable } from "@/session/session.sql"
import { Database } from "@/storage/db"
import { eq } from "drizzle-orm"
import * as Log from "@opencode-ai/core/util/log"
import { Wildcard } from "@opencode-ai/core/util/wildcard"
import { Deferred, Effect, Layer, Schema, Context } from "effect"
import os from "os"
import { PermissionV2 } from "@opencode-ai/core/permission"
import { PermissionID } from "./schema"

const log = Log.create({ service: "permission" })

export const Action = PermissionV2.Action.annotate({ identifier: "PermissionAction" })
export type Action = Schema.Schema.Type<typeof Action>

export const Rule = Schema.Struct({
  permission: Schema.String,
  pattern: Schema.String,
  action: Action,
}).annotate({ identifier: "PermissionRule" })
export type Rule = Schema.Schema.Type<typeof Rule>

export const Ruleset = Schema.Array(Rule).annotate({ identifier: "PermissionRuleset" })
export type Ruleset = Schema.Schema.Type<typeof Ruleset>

// Pure data; nothing checks class identity. As `Schema.Struct` + type alias,
// `Permission.ask` can trust its already-typed input and skip the inner
// `decodeUnknownSync` that would otherwise throw uncaught on any structural
// mismatch. Same pattern as `Question.Request` in PR #28570.
export const Request = Schema.Struct({
  id: PermissionID,
  sessionID: SessionID,
  permission: Schema.String,
  patterns: Schema.Array(Schema.String),
  metadata: Schema.Record(Schema.String, Schema.Unknown),
  always: Schema.Array(Schema.String),
  tool: Schema.optional(
    Schema.Struct({
      messageID: MessageID,
      callID: Schema.String,
    }),
  ),
}).annotate({ identifier: "PermissionRequest" })
export type Request = Schema.Schema.Type<typeof Request>

export const Reply = Schema.Literals(["once", "always", "reject"])
export type Reply = Schema.Schema.Type<typeof Reply>

const reply = {
  reply: Reply,
  message: Schema.optional(Schema.String),
}

export const ReplyBody = Schema.Struct(reply).annotate({ identifier: "PermissionReplyBody" })
export type ReplyBody = Schema.Schema.Type<typeof ReplyBody>

export const Approval = Schema.Struct({
  projectID: ProjectID,
  patterns: Schema.Array(Schema.String),
}).annotate({ identifier: "PermissionApproval" })
export type Approval = Schema.Schema.Type<typeof Approval>

export const Event = {
  Asked: BusEvent.define("permission.asked", Request),
  Replied: BusEvent.define(
    "permission.replied",
    Schema.Struct({
      sessionID: SessionID,
      requestID: PermissionID,
      reply: Reply,
    }),
  ),
}

export class RejectedError extends Schema.TaggedErrorClass<RejectedError>()("PermissionRejectedError", {}) {
  override get message() {
    return "The user rejected permission to use this specific tool call."
  }
}

export class CorrectedError extends Schema.TaggedErrorClass<CorrectedError>()("PermissionCorrectedError", {
  feedback: Schema.String,
}) {
  override get message() {
    return `The user rejected permission to use this specific tool call with the following feedback: ${this.feedback}`
  }
}

export class DeniedError extends Schema.TaggedErrorClass<DeniedError>()("PermissionDeniedError", {
  ruleset: Schema.Any,
}) {
  override get message() {
    return `The user has specified a rule which prevents you from using this specific tool call. Here are some of the relevant rules ${JSON.stringify(this.ruleset)}`
  }
}

export class NotFoundError extends Schema.TaggedErrorClass<NotFoundError>()("Permission.NotFoundError", {
  requestID: PermissionID,
}) {}

export type Error = DeniedError | RejectedError | CorrectedError

export const AskInput = Schema.Struct({
  ...Request.fields,
  id: Schema.optional(PermissionID),
  ruleset: Ruleset,
}).annotate({ identifier: "PermissionAskInput" })
export type AskInput = Schema.Schema.Type<typeof AskInput>

export const ReplyInput = Schema.Struct({
  requestID: PermissionID,
  ...reply,
}).annotate({ identifier: "PermissionReplyInput" })
export type ReplyInput = Schema.Schema.Type<typeof ReplyInput>

export interface Interface {
  readonly ask: (input: AskInput) => Effect.Effect<void, Error>
  readonly reply: (input: ReplyInput) => Effect.Effect<void, NotFoundError>
  readonly list: () => Effect.Effect<ReadonlyArray<Request>>
}

interface PendingEntry {
  info: Request
  deferred: Deferred.Deferred<void, RejectedError | CorrectedError>
}

interface State {
  pending: Map<PermissionID, PendingEntry>
  approved: Rule[]
}

export function evaluate(permission: string, pattern: string, ...rulesets: Ruleset[]): Rule {
  return PermissionV2.evaluate(permission, pattern, ...rulesets)
}

export class Service extends Context.Service<Service, Interface>()("@opencode/Permission") {}

export const layer = Layer.effect(
  Service,
  Effect.gen(function* () {
    const bus = yield* Bus.Service
    const state = yield* InstanceState.make<State>(
      // The callback receives project context (ctx.project.id).
      // It reads persisted approved rules from the database on init.
      Effect.fn("Permission.state")(function* (ctx) {
        const row = Database.use((db) =>
          db.select().from(PermissionTable).where(eq(PermissionTable.project_id, ctx.project.id)).get(),
        )
        const state = {
          pending: new Map<PermissionID, PendingEntry>(),
          approved: [...(row?.data ?? [])],
        }

        yield* Effect.addFinalizer(() =>
          Effect.gen(function* () {
            for (const item of state.pending.values()) {
              yield* Deferred.fail(item.deferred, new RejectedError())
            }
            state.pending.clear()
          }),
        )

        return state
      }),
    )

    const ask = Effect.fn("Permission.ask")(function* (input: AskInput) {
      const { approved, pending } = yield* InstanceState.get(state)
      const { ruleset, ...request } = input
      let needsAsk = false

      // Evaluate each pattern against config rules + session-approved rules.
      // Any "deny" is immediate. All "allow" means skip the prompt.
      for (const pattern of request.patterns) {
        const rule = evaluate(request.permission, pattern, ruleset, approved)
        log.info("evaluated", { permission: request.permission, pattern, action: rule })
        if (rule.action === "deny") {
          return yield* new DeniedError({
            ruleset: ruleset.filter((rule) => Wildcard.match(request.permission, rule.permission)),
          })
        }
        if (rule.action === "allow") continue
        needsAsk = true
      }

      if (!needsAsk) return

      const id = request.id ?? PermissionID.ascending()
      const info: Request = {
        id,
        sessionID: request.sessionID,
        permission: request.permission,
        patterns: request.patterns,
        metadata: request.metadata,
        always: request.always,
        tool: request.tool,
      }
      log.info("asking", { id, permission: info.permission, patterns: info.patterns })

      const deferred = yield* Deferred.make<void, RejectedError | CorrectedError>()
      pending.set(id, { info, deferred })
      yield* bus.publish(Event.Asked, info)
      return yield* Effect.ensuring(
        Deferred.await(deferred),
        Effect.sync(() => {
          pending.delete(id)
        }),
      )
    })

    const reply = Effect.fn("Permission.reply")(function* (input: ReplyInput) {
      const { approved, pending } = yield* InstanceState.get(state)
      const existing = pending.get(input.requestID)
      if (!existing) return yield* new NotFoundError({ requestID: input.requestID })

      pending.delete(input.requestID)
      yield* bus.publish(Event.Replied, {
        sessionID: existing.info.sessionID,
        requestID: existing.info.id,
        reply: input.reply,
      })

      // ── Rejection cascade ──
      // When one permission is rejected, ALL pending permissions for the
      // same session are also rejected. This prevents a flood of prompts
      // after the user says "no".
      if (input.reply === "reject") {
        yield* Deferred.fail(
          existing.deferred,
          input.message ? new CorrectedError({ feedback: input.message }) : new RejectedError(),
        )

        for (const [id, item] of pending.entries()) {
          if (item.info.sessionID !== existing.info.sessionID) continue
          pending.delete(id)
          yield* bus.publish(Event.Replied, {
            sessionID: item.info.sessionID,
            requestID: item.info.id,
            reply: "reject",
          })
          yield* Deferred.fail(item.deferred, new RejectedError())
        }
        return
      }

      yield* Deferred.succeed(existing.deferred, undefined)
      if (input.reply === "once") return

      // ── Approval cascade ("always") ──
      // Push new allow rules into approved state, then re-evaluate all
      // pending permissions for the same session. Any that now pass are
      // auto-approved, so the user isn't asked again for the same pattern.
      for (const pattern of existing.info.always) {
        approved.push({
          permission: existing.info.permission,
          pattern,
          action: "allow",
        })
      }

      for (const [id, item] of pending.entries()) {
        if (item.info.sessionID !== existing.info.sessionID) continue
        const ok = item.info.patterns.every(
          (pattern) => evaluate(item.info.permission, pattern, approved).action === "allow",
        )
        if (!ok) continue
        pending.delete(id)
        yield* bus.publish(Event.Replied, {
          sessionID: item.info.sessionID,
          requestID: item.info.id,
          reply: "always",
        })
        yield* Deferred.succeed(item.deferred, undefined)
      }
    })

    const list = Effect.fn("Permission.list")(function* () {
      const pending = (yield* InstanceState.get(state)).pending
      return Array.from(pending.values(), (item) => item.info)
    })

    return Service.of({ ask, reply, list })
  }),
)

function expand(pattern: string): string {
  if (pattern.startsWith("~/")) return os.homedir() + pattern.slice(1)
  if (pattern === "~") return os.homedir()
  if (pattern.startsWith("$HOME/")) return os.homedir() + pattern.slice(5)
  if (pattern.startsWith("$HOME")) return os.homedir() + pattern.slice(5)
  return pattern
}

export function fromConfig(permission: ConfigPermission.Info) {
  const ruleset: Rule[] = []
  for (const [key, value] of Object.entries(permission)) {
    if (typeof value === "string") {
      ruleset.push({ permission: key, action: value, pattern: "*" })
      continue
    }
    ruleset.push(
      ...Object.entries(value).map(([pattern, action]) => ({ permission: key, pattern: expand(pattern), action })),
    )
  }
  return ruleset
}

export function merge(...rulesets: Ruleset[]): Rule[] {
  return [...PermissionV2.merge(...rulesets)]
}

export function disabled(tools: string[], ruleset: Ruleset): Set<string> {
  return PermissionV2.disabled(tools, ruleset)
}

export const defaultLayer = layer.pipe(Layer.provide(Bus.layer))

export * as Permission from "."
```

What this module adds on top of Question:
- **Shared domain logic lives in `@opencode-ai/core`.** `PermissionV2` (schema + `evaluate`/`merge`/`disabled`) is imported from `@opencode-ai/core/permission`; this module is the thin app-side wiring. `Action` is re-annotated from `PermissionV2.Action`.
- **Schema extension via `.fields`.** `AskInput` is `Schema.Struct({ ...Request.fields, id: Schema.optional(PermissionID), ruleset: Ruleset })` — the Effect Schema equivalent of Zod's `.extend()`/`.partial()`.
- **Literal unions** use `Schema.Literals(["once", "always", "reject"])` (the old `z.enum`).
- Pure utilities (`fromConfig`, `merge`, `disabled`, `evaluate`) are plain exported functions in the same file — picked up by the `export * as Permission from "."` barrel alongside the service.

---

## When building a new module

### Branded IDs: `Newtype` from `@opencode-ai/core/schema`

Branded IDs are now a single pattern — a class extending `Newtype<Self>()("Name", schema)`:

```typescript
import { Newtype } from "@opencode-ai/core/schema"
import { Identifier } from "@/id/id"

export class ThingID extends Newtype<ThingID>()("ThingID", Schema.String.check(Schema.isStartsWith("thg"))) {
  static ascending(id?: string): ThingID {
    return this.make(Identifier.ascending("thing", id))
  }
}
```

- `Schema.String.check(Schema.isStartsWith("thg"))` enforces the prefix at decode time.
- `.make(raw)` brands a raw string; `.ascending()` mints a fresh time-ordered ID.
- Add `.ascending()` for any entity keyed in a `Map` or used with `Deferred` (Question, Permission, Session, Message). Omit it for IDs that are only ever received, not generated.

There is no longer a `.zod` bridge or `makeUnsafe` — the codebase is on Effect Schema end to end, so the ID is already usable directly in `Schema.Struct` fields and bus events.

### InstanceState vs Database for state

Use **InstanceState** when:
- State is per-project and scoped to the project's lifetime
- State lives in memory (pending maps, caches, loaded skill records)
- You need `Effect.addFinalizer` for cleanup on scope close
- The `InstanceState.make` callback receives project context (`ctx.project.id`, `ctx.directory`, `ctx.worktree`)

Use **Database** (Drizzle + SQLite) when:
- State must persist across process restarts
- State is queried by other modules or displayed in the UI
- You need transactional writes or indexed lookups

Many modules use **both**: Permission loads `approved` rules from Database inside `InstanceState.make`, then accumulates session-local approvals in memory. The database is the source of truth on restart; InstanceState is the working copy.

### BusEvent vs direct calls

Use **BusEvent.define** + `bus.publish` when:
- Multiple consumers need to react to the same event (UI, sync, logging)
- Events cross module boundaries (session updates, permission decisions)

Inside a service, acquire the bus in the layer (`const bus = yield* Bus.Service`) and **`yield* bus.publish(event, props)`** — `publish` returns an `Effect`, so it must be yielded; it is not fire-and-forget. The top-level `Bus.publish(ctx, def, props)` async facade exists only for imperative (non-Effect) callers.

Use **direct function calls** when:
- There is exactly one consumer
- The caller needs the return value
- The interaction is synchronous within the same Effect pipeline

### When to add a facade (`makeRuntime`)

Add `const { runPromise } = makeRuntime(Service, layer)` plus async wrappers **only** when imperative, non-Effect code must call the service (CLI handlers, HTTP route bodies that aren't already Effects, third-party callbacks). Question and Permission have none because every caller is in Effect-land. See `Bus` in [primitives.md](primitives.md) for a module that does keep a facade (`runPromise`/`runSync`) for its imperative `publish`/`subscribe` entry points.

### When to add a separate .sql.ts file

Add a `module/module.sql.ts` file when the module owns a database table. The convention:
- File contains only Drizzle `sqliteTable` definitions
- Uses `$type<BrandedID>()` for type-safe branded columns
- Spreads `...Timestamps` for `created_at`/`updated_at`
- References other tables via `references(() => OtherTable.id, { onDelete: "cascade" })`
- Is imported by the module's `index.ts` or `repo.ts`

Skip the `.sql.ts` file when the module is purely in-memory (Question) or uses file-based storage (Auth).
