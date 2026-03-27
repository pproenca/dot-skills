# Service Module Reference

Two complete service module implementations from the opencode codebase, copied verbatim. Read these before writing a new module.

---

## Anatomy of a service module

Every module follows this structure inside an `export namespace X { }` block:

```
1.  Imports (effect, zod, internal @/ imports, local ./schema)
2.  export namespace X {
3.    const log = Log.create({ service: "x" })
4.    Schemas         -- Zod objects with z.infer + .meta({ ref }) for codegen
5.    Events          -- BusEvent.define("x.eventname", zodSchema)
6.    Errors          -- Schema.TaggedErrorClass (Effect-native errors)
7.    Internal types  -- PendingEntry, State (not exported)
8.    Interface       -- pure TS interface, methods return Effect.Effect<A, E>
9.    Service class   -- ServiceMap.Service<Self, Interface>()("@opencode/X")
10.   layer           -- Layer.effect(Service, Effect.gen(function* () { ... }))
11.   makeRuntime     -- const { runPromise } = makeRuntime(Service, layer)
12.   Facade funcs    -- export async function name() { return runPromise((s) => s.name()) }
13. }
```

The namespace doubles as the module's public API. Consumers call `X.method()` (the facade) for Promise-based access, or depend on `X.Service` inside Effect pipelines.

---

## Module 1: Question

The simplest complete service. In-memory question/answer flow using `Deferred` for async request/response coordination. No database, no external dependencies.

### `question/schema.ts` (18 lines)

```typescript
import { Schema } from "effect"
import z from "zod"

import { Identifier } from "@/id/id"
import { Newtype } from "@/util/schema"

export class QuestionID extends Newtype<QuestionID>()("QuestionID", Schema.String) {
  static make(id: string): QuestionID {
    return this.makeUnsafe(id)
  }

  static ascending(id?: string): QuestionID {
    return this.makeUnsafe(Identifier.ascending("question", id))
  }

  static readonly zod = Identifier.schema("question") as unknown as z.ZodType<QuestionID>
}
```

<!-- Newtype gives you three things: an Effect Schema branded type, a Zod bridge (.zod),
     and ascending() for time-ordered IDs. Every Deferred-based module needs ascending IDs
     because pending entries are keyed by them. -->

### `question/index.ts` (210 lines)

```typescript
import { Deferred, Effect, Layer, Schema, ServiceMap } from "effect"
import { Bus } from "@/bus"
import { BusEvent } from "@/bus/bus-event"
import { InstanceState } from "@/effect/instance-state"
import { makeRuntime } from "@/effect/run-service"
import { SessionID, MessageID } from "@/session/schema"
import { Log } from "@/util/log"
import z from "zod"
import { QuestionID } from "./schema"

export namespace Question {
  const log = Log.create({ service: "question" })

  // ── Schemas ──────────────────────────────────────────────────────────

  export const Option = z
    .object({
      label: z.string().describe("Display text (1-5 words, concise)"),
      description: z.string().describe("Explanation of choice"),
    })
    .meta({ ref: "QuestionOption" })
  export type Option = z.infer<typeof Option>

  export const Info = z
    .object({
      question: z.string().describe("Complete question"),
      header: z.string().describe("Very short label (max 30 chars)"),
      options: z.array(Option).describe("Available choices"),
      multiple: z.boolean().optional().describe("Allow selecting multiple choices"),
      custom: z.boolean().optional().describe("Allow typing a custom answer (default: true)"),
    })
    .meta({ ref: "QuestionInfo" })
  export type Info = z.infer<typeof Info>

  export const Request = z
    .object({
      id: QuestionID.zod,
      sessionID: SessionID.zod,
      questions: z.array(Info).describe("Questions to ask"),
      tool: z
        .object({
          messageID: MessageID.zod,
          callID: z.string(),
        })
        .optional(),
    })
    .meta({ ref: "QuestionRequest" })
  export type Request = z.infer<typeof Request>

  export const Answer = z.array(z.string()).meta({ ref: "QuestionAnswer" })
  export type Answer = z.infer<typeof Answer>

  export const Reply = z.object({
    answers: z
      .array(Answer)
      .describe("User answers in order of questions (each answer is an array of selected labels)"),
  })
  export type Reply = z.infer<typeof Reply>

  // ── Events ───────────────────────────────────────────────────────────

  export const Event = {
    Asked: BusEvent.define("question.asked", Request),
    Replied: BusEvent.define(
      "question.replied",
      z.object({
        sessionID: SessionID.zod,
        requestID: QuestionID.zod,
        answers: z.array(Answer),
      }),
    ),
    Rejected: BusEvent.define(
      "question.rejected",
      z.object({
        sessionID: SessionID.zod,
        requestID: QuestionID.zod,
      }),
    ),
  }

  // ── Errors ───────────────────────────────────────────────────────────

  export class RejectedError extends Schema.TaggedErrorClass<RejectedError>()("QuestionRejectedError", {}) {
    override get message() {
      return "The user dismissed this question"
    }
  }

  // ── Internal types ───────────────────────────────────────────────────
  // Not exported. PendingEntry pairs the request info with its Deferred.

  interface PendingEntry {
    info: Request
    deferred: Deferred.Deferred<Answer[], RejectedError>
  }

  interface State {
    pending: Map<QuestionID, PendingEntry>
  }

  // ── Interface ────────────────────────────────────────────────────────

  export interface Interface {
    readonly ask: (input: {
      sessionID: SessionID
      questions: Info[]
      tool?: { messageID: MessageID; callID: string }
    }) => Effect.Effect<Answer[], RejectedError>
    readonly reply: (input: { requestID: QuestionID; answers: Answer[] }) => Effect.Effect<void>
    readonly reject: (requestID: QuestionID) => Effect.Effect<void>
    readonly list: () => Effect.Effect<Request[]>
  }

  // ── Service + Layer ──────────────────────────────────────────────────

  export class Service extends ServiceMap.Service<Service, Interface>()("@opencode/Question") {}

  export const layer = Layer.effect(
    Service,
    Effect.gen(function* () {
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
        questions: Info[]
        tool?: { messageID: MessageID; callID: string }
      }) {
        const pending = (yield* InstanceState.get(state)).pending
        const id = QuestionID.ascending()
        log.info("asking", { id, questions: input.questions.length })

        const deferred = yield* Deferred.make<Answer[], RejectedError>()
        const info: Request = {
          id,
          sessionID: input.sessionID,
          questions: input.questions,
          tool: input.tool,
        }
        pending.set(id, { info, deferred })
        Bus.publish(Event.Asked, info)

        // Effect.ensuring guarantees the Map entry is deleted even if
        // the Deferred is interrupted (not just succeeded/failed).
        return yield* Effect.ensuring(
          Deferred.await(deferred),
          Effect.sync(() => {
            pending.delete(id)
          }),
        )
      })

      const reply = Effect.fn("Question.reply")(function* (input: { requestID: QuestionID; answers: Answer[] }) {
        const pending = (yield* InstanceState.get(state)).pending
        const existing = pending.get(input.requestID)
        if (!existing) {
          log.warn("reply for unknown request", { requestID: input.requestID })
          return
        }
        pending.delete(input.requestID)
        log.info("replied", { requestID: input.requestID, answers: input.answers })
        Bus.publish(Event.Replied, {
          sessionID: existing.info.sessionID,
          requestID: existing.info.id,
          answers: input.answers,
        })
        yield* Deferred.succeed(existing.deferred, input.answers)
      })

      const reject = Effect.fn("Question.reject")(function* (requestID: QuestionID) {
        const pending = (yield* InstanceState.get(state)).pending
        const existing = pending.get(requestID)
        if (!existing) {
          log.warn("reject for unknown request", { requestID })
          return
        }
        pending.delete(requestID)
        log.info("rejected", { requestID })
        Bus.publish(Event.Rejected, {
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

  // ── Runtime + Facade ─────────────────────────────────────────────────

  const { runPromise } = makeRuntime(Service, layer)

  export async function ask(input: {
    sessionID: SessionID
    questions: Info[]
    tool?: { messageID: MessageID; callID: string }
  }): Promise<Answer[]> {
    return runPromise((s) => s.ask(input))
  }

  export async function reply(input: { requestID: QuestionID; answers: Answer[] }) {
    return runPromise((s) => s.reply(input))
  }

  export async function reject(requestID: QuestionID) {
    return runPromise((s) => s.reject(requestID))
  }

  export async function list() {
    return runPromise((s) => s.list())
  }
}
```

---

## Module 2: Permission

A medium-complexity service showing rule evaluation, cascading approvals/rejections, database-backed initial state, multiple error types, and utility functions alongside the Effect service.

### `permission/schema.ts` (18 lines)

```typescript
import { Schema } from "effect"
import z from "zod"

import { Identifier } from "@/id/id"
import { Newtype } from "@/util/schema"

export class PermissionID extends Newtype<PermissionID>()("PermissionID", Schema.String) {
  static make(id: string): PermissionID {
    return this.makeUnsafe(id)
  }

  static ascending(id?: string): PermissionID {
    return this.makeUnsafe(Identifier.ascending("permission", id))
  }

  static readonly zod = Identifier.schema("permission") as unknown as z.ZodType<PermissionID>
}
```

### `permission/index.ts` (~250 lines)

```typescript
import { Bus } from "@/bus"
import { BusEvent } from "@/bus/bus-event"
import { Config } from "@/config/config"
import { InstanceState } from "@/effect/instance-state"
import { makeRuntime } from "@/effect/run-service"
import { ProjectID } from "@/project/schema"
import { Instance } from "@/project/instance"
import { MessageID, SessionID } from "@/session/schema"
import { PermissionTable } from "@/session/session.sql"
import { Database, eq } from "@/storage/db"
import { Log } from "@/util/log"
import { Wildcard } from "@/util/wildcard"
import { Deferred, Effect, Layer, Schema, ServiceMap } from "effect"
import os from "os"
import z from "zod"
import { evaluate as evalRule } from "./evaluate"
import { PermissionID } from "./schema"

export namespace Permission {
  const log = Log.create({ service: "permission" })

  // ── Schemas ──────────────────────────────────────────────────────────

  export const Action = z.enum(["allow", "deny", "ask"]).meta({
    ref: "PermissionAction",
  })
  export type Action = z.infer<typeof Action>

  export const Rule = z
    .object({
      permission: z.string(),
      pattern: z.string(),
      action: Action,
    })
    .meta({
      ref: "PermissionRule",
    })
  export type Rule = z.infer<typeof Rule>

  export const Ruleset = Rule.array().meta({
    ref: "PermissionRuleset",
  })
  export type Ruleset = z.infer<typeof Ruleset>

  export const Request = z
    .object({
      id: PermissionID.zod,
      sessionID: SessionID.zod,
      permission: z.string(),
      patterns: z.string().array(),
      metadata: z.record(z.string(), z.any()),
      always: z.string().array(),
      tool: z
        .object({
          messageID: MessageID.zod,
          callID: z.string(),
        })
        .optional(),
    })
    .meta({
      ref: "PermissionRequest",
    })
  export type Request = z.infer<typeof Request>

  export const Reply = z.enum(["once", "always", "reject"])
  export type Reply = z.infer<typeof Reply>

  export const Approval = z.object({
    projectID: ProjectID.zod,
    patterns: z.string().array(),
  })

  // ── Events ───────────────────────────────────────────────────────────

  export const Event = {
    Asked: BusEvent.define("permission.asked", Request),
    Replied: BusEvent.define(
      "permission.replied",
      z.object({
        sessionID: SessionID.zod,
        requestID: PermissionID.zod,
        reply: Reply,
      }),
    ),
  }

  // ── Errors ───────────────────────────────────────────────────────────
  // Three error types: denied by rule, rejected by user, rejected with feedback.

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

  export type Error = DeniedError | RejectedError | CorrectedError

  // ── Input schemas (Zod) ──────────────────────────────────────────────

  export const AskInput = Request.partial({ id: true }).extend({
    ruleset: Ruleset,
  })

  export const ReplyInput = z.object({
    requestID: PermissionID.zod,
    reply: Reply,
    message: z.string().optional(),
  })

  // ── Interface ────────────────────────────────────────────────────────

  export interface Interface {
    readonly ask: (input: z.infer<typeof AskInput>) => Effect.Effect<void, Error>
    readonly reply: (input: z.infer<typeof ReplyInput>) => Effect.Effect<void>
    readonly list: () => Effect.Effect<Request[]>
  }

  // ── Internal types ───────────────────────────────────────────────────

  interface PendingEntry {
    info: Request
    deferred: Deferred.Deferred<void, RejectedError | CorrectedError>
  }

  interface State {
    pending: Map<PermissionID, PendingEntry>
    approved: Ruleset   // <-- persisted rules loaded from DB, plus session-accumulated "always" approvals
  }

  // ── Pure utility (exported from namespace, not part of the service) ──

  export function evaluate(permission: string, pattern: string, ...rulesets: Ruleset[]): Rule {
    log.info("evaluate", { permission, pattern, ruleset: rulesets.flat() })
    return evalRule(permission, pattern, ...rulesets)
  }

  // ── Service + Layer ──────────────────────────────────────────────────

  export class Service extends ServiceMap.Service<Service, Interface>()("@opencode/Permission") {}

  export const layer = Layer.effect(
    Service,
    Effect.gen(function* () {
      const state = yield* InstanceState.make<State>(
        // The callback receives project context (ctx.project.id).
        // It reads persisted approved rules from the database on init.
        Effect.fn("Permission.state")(function* (ctx) {
          const row = Database.use((db) =>
            db.select().from(PermissionTable).where(eq(PermissionTable.project_id, ctx.project.id)).get(),
          )
          const state = {
            pending: new Map<PermissionID, PendingEntry>(),
            approved: row?.data ?? [],
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

      const ask = Effect.fn("Permission.ask")(function* (input: z.infer<typeof AskInput>) {
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
          ...request,
        }
        log.info("asking", { id, permission: info.permission, patterns: info.patterns })

        const deferred = yield* Deferred.make<void, RejectedError | CorrectedError>()
        pending.set(id, { info, deferred })
        void Bus.publish(Event.Asked, info)
        return yield* Effect.ensuring(
          Deferred.await(deferred),
          Effect.sync(() => {
            pending.delete(id)
          }),
        )
      })

      const reply = Effect.fn("Permission.reply")(function* (input: z.infer<typeof ReplyInput>) {
        const { approved, pending } = yield* InstanceState.get(state)
        const existing = pending.get(input.requestID)
        if (!existing) return

        pending.delete(input.requestID)
        void Bus.publish(Event.Replied, {
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
            void Bus.publish(Event.Replied, {
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
          void Bus.publish(Event.Replied, {
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

  // ── Pure utility functions (no Effect service, just namespace exports) ──

  function expand(pattern: string): string {
    if (pattern.startsWith("~/")) return os.homedir() + pattern.slice(1)
    if (pattern === "~") return os.homedir()
    if (pattern.startsWith("$HOME/")) return os.homedir() + pattern.slice(5)
    if (pattern.startsWith("$HOME")) return os.homedir() + pattern.slice(5)
    return pattern
  }

  export function fromConfig(permission: Config.Permission) {
    const ruleset: Ruleset = []
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

  export function merge(...rulesets: Ruleset[]): Ruleset {
    return rulesets.flat()
  }

  const EDIT_TOOLS = ["edit", "write", "apply_patch", "multiedit"]

  export function disabled(tools: string[], ruleset: Ruleset): Set<string> {
    const result = new Set<string>()
    for (const tool of tools) {
      const permission = EDIT_TOOLS.includes(tool) ? "edit" : tool
      const rule = ruleset.findLast((rule) => Wildcard.match(permission, rule.permission))
      if (!rule) continue
      if (rule.pattern === "*" && rule.action === "deny") result.add(tool)
    }
    return result
  }

  // ── Runtime + Facade ─────────────────────────────────────────────────

  export const { runPromise } = makeRuntime(Service, layer)

  export async function ask(input: z.infer<typeof AskInput>) {
    return runPromise((s) => s.ask(input))
  }

  export async function reply(input: z.infer<typeof ReplyInput>) {
    return runPromise((s) => s.reply(input))
  }

  export async function list() {
    return runPromise((s) => s.list())
  }
}
```

---

## When building a new module

### Newtype vs Schema.brand for IDs

Use **Newtype** when the ID needs all three of:
- Time-ordered generation via `Identifier.ascending("prefix")`
- A `.zod` bridge for use in Zod schemas (bus events, API schemas)
- Dual existence in both Effect Schema and Zod worlds

This applies to any entity that uses `Deferred` (Question, Permission) or that appears in bus events and API responses.

Use **Schema.brand + withStatics** when the ID is simpler:
- No time-ordering needed
- Primarily lives in Effect Schema land (database rows, internal domain models)
- Example: `AccountID`, `AccessToken`, `OrgID`, `DeviceCode`

```typescript
// Newtype (Question, Permission, Session, Message)
export class ThingID extends Newtype<ThingID>()("ThingID", Schema.String) {
  static make(id: string): ThingID { return this.makeUnsafe(id) }
  static ascending(id?: string): ThingID { return this.makeUnsafe(Identifier.ascending("thing", id)) }
  static readonly zod = Identifier.schema("thing") as unknown as z.ZodType<ThingID>
}

// Schema.brand (Account, tokens, org IDs)
export const ThingID = Schema.String.pipe(
  Schema.brand("ThingID"),
  withStatics((s) => ({ make: (id: string) => s.makeUnsafe(id) })),
)
```

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

Use **BusEvent.define** + **Bus.publish** when:
- Multiple consumers need to react to the same event (UI, sync, logging)
- The publisher does not care about the result (fire-and-forget)
- Events cross module boundaries (session updates, permission decisions)

`Bus.publish` is fire-and-forget -- no `yield*` needed. Use `void Bus.publish(...)` when you want to be explicit about discarding the return value.

Use **direct function calls** when:
- There is exactly one consumer
- The caller needs the return value
- The interaction is synchronous within the same Effect pipeline

### When to add a separate .sql.ts file

Add a `module/module.sql.ts` file when the module owns a database table. The convention:
- File contains only Drizzle `sqliteTable` definitions
- Uses `$type<BrandedID>()` for type-safe branded columns
- Spreads `...Timestamps` for `created_at`/`updated_at`
- References other tables via `references(() => OtherTable.id, { onDelete: "cascade" })`
- Is imported by the module's `index.ts` or `repo.ts`

Skip the `.sql.ts` file when the module is purely in-memory (Question) or uses file-based storage (Auth).
