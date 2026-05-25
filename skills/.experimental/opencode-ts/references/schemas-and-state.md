# Schemas and State Management

This reference covers database schemas, Effect Schema patterns, event-sourced state management, and the error taxonomy used across the opencode TypeScript codebase. The codebase is now on Effect `Schema` end to end — service data, bus/sync events, tool params, branded IDs, and both error families. (`zod` is still a dependency but is no longer the schema tool for these.)

---

## 1. SQL Table Patterns (Drizzle ORM + SQLite)

All tables use Drizzle ORM for SQLite. Column names are **snake_case** so Drizzle does not need string redefinitions. Timestamps are Unix epoch milliseconds stored as integers.

### Shared Timestamps Mixin

Every table spreads this into its column definitions:

```typescript
// packages/opencode/src/storage/schema.sql.ts
import { integer } from "drizzle-orm/sqlite-core"

export const Timestamps = {
  time_created: integer()
    .notNull()
    .$default(() => Date.now()),
  time_updated: integer()
    .notNull()
    .$onUpdate(() => Date.now()),
}
```

`$default` runs at insert time. `$onUpdate` runs on every update. Both produce epoch-millisecond integers.

### SessionTable -- Foreign Keys, Indexes, JSON Columns

```typescript
// packages/opencode/src/session/session.sql.ts
export const SessionTable = sqliteTable(
  "session",
  {
    id: text().$type<SessionID>().primaryKey(),
    project_id: text()
      .$type<ProjectID>()
      .notNull()
      .references(() => ProjectTable.id, { onDelete: "cascade" }),
    workspace_id: text().$type<WorkspaceID>(),
    parent_id: text().$type<SessionID>(),
    slug: text().notNull(),
    directory: text().notNull(),
    title: text().notNull(),
    version: text().notNull(),
    share_url: text(),
    summary_additions: integer(),
    summary_deletions: integer(),
    summary_files: integer(),
    summary_diffs: text({ mode: "json" }).$type<Snapshot.FileDiff[]>(),
    revert: text({ mode: "json" }).$type<{ messageID: MessageID; partID?: PartID; snapshot?: string; diff?: string }>(),
    permission: text({ mode: "json" }).$type<Permission.Ruleset>(),
    ...Timestamps,
    time_compacting: integer(),
    time_archived: integer(),
  },
  (table) => [
    index("session_project_idx").on(table.project_id),
    index("session_workspace_idx").on(table.workspace_id),
    index("session_parent_idx").on(table.parent_id),
  ],
)
```

Patterns to note:
- `text().$type<BrandedID>().primaryKey()` -- typed primary key with branded string
- `.references(() => ProjectTable.id, { onDelete: "cascade" })` -- always a function reference, never a direct value
- `text({ mode: "json" }).$type<T>()` -- JSON columns with TypeScript overlay
- Index definitions in the third argument as an array of `index()` calls
- `...Timestamps` spread always appears in the column object

### PartTable -- Multi-Column Indexing

```typescript
// packages/opencode/src/session/session.sql.ts
export const PartTable = sqliteTable(
  "part",
  {
    id: text().$type<PartID>().primaryKey(),
    message_id: text()
      .$type<MessageID>()
      .notNull()
      .references(() => MessageTable.id, { onDelete: "cascade" }),
    session_id: text().$type<SessionID>().notNull(),
    ...Timestamps,
    data: text({ mode: "json" }).notNull().$type<PartData>(),
  },
  (table) => [
    index("part_message_id_id_idx").on(table.message_id, table.id),
    index("part_session_idx").on(table.session_id),
  ],
)
```

The `data` column stores everything except IDs: `type PartData = Omit<MessageV2.Part, "id" | "sessionID" | "messageID">`. IDs are extracted into indexed columns for fast lookups while the JSON column allows flexible schema evolution.

### TodoTable -- Composite Primary Key

```typescript
// packages/opencode/src/session/session.sql.ts
export const TodoTable = sqliteTable(
  "todo",
  {
    session_id: text()
      .$type<SessionID>()
      .notNull()
      .references(() => SessionTable.id, { onDelete: "cascade" }),
    content: text().notNull(),
    status: text().notNull(),
    priority: text().notNull(),
    position: integer().notNull(),
    ...Timestamps,
  },
  (table) => [
    primaryKey({ columns: [table.session_id, table.position] }),
    index("todo_session_idx").on(table.session_id),
  ],
)
```

No auto-increment ID. Composite primary key on `(session_id, position)`.

### EventTable and EventSequenceTable -- Event Sourcing Storage

```typescript
// packages/opencode/src/sync/event.sql.ts
import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core"

export const EventSequenceTable = sqliteTable("event_sequence", {
  aggregate_id: text().notNull().primaryKey(),
  seq: integer().notNull(),
})

export const EventTable = sqliteTable("event", {
  id: text().primaryKey(),
  aggregate_id: text()
    .notNull()
    .references(() => EventSequenceTable.aggregate_id, { onDelete: "cascade" }),
  seq: integer().notNull(),
  type: text().notNull(),
  data: text({ mode: "json" }).$type<Record<string, unknown>>().notNull(),
})
```

Two tables: `event_sequence` tracks the latest sequence number per aggregate, `event` stores all events. Deleting a sequence cascades to all its events.

---

## 2. Effect Schema Patterns (data, events, IDs)

### Schema.Struct + Schema.Schema.Type + .annotate({ identifier })

`.annotate({ identifier })` names a schema for OpenAPI/JSON-Schema generation and SDK type extraction (it replaced Zod's `.meta({ ref })`). `.annotate({ description })` documents a field. Every schema that appears in API responses or events gets an `identifier`:

```typescript
// core/util/log.ts
export const Level = Schema.Literals(["DEBUG", "INFO", "WARN", "ERROR"]).annotate({
  identifier: "LogLevel",
  description: "Log level",
})
export type Level = Schema.Schema.Type<typeof Level>
```

The `identifier` becomes the `$ref`/component name in generated specs. Pull the static TS type with `Schema.Schema.Type<typeof X>` (the replacement for `z.infer`).

### Discriminated unions: Schema.Union + discriminator annotation

A literal field discriminator is declared with `.annotate({ discriminator: "type" })` on a `Schema.Union` of `Schema.Struct`s, each carrying a `Schema.Literal(...)` tag:

```typescript
// session/message-v2.ts -- Part types (each member is a Schema.Struct with type: Schema.Literal(...))
export const Part = Schema.Union([
  TextPart,        // type: Schema.Literal("text") -- with optional synthetic/ignored flags
  SubtaskPart,     // type: Schema.Literal("subtask") -- agent delegation
  ReasoningPart,   // type: Schema.Literal("reasoning") -- model thinking
  FilePart,        // type: Schema.Literal("file") -- attached files with mime, url, optional source
  ToolPart,        // type: Schema.Literal("tool") -- tool calls with full lifecycle state
  StepStartPart,   // type: Schema.Literal("step-start")
  StepFinishPart,  // type: Schema.Literal("step-finish") -- tokens/cost
  SnapshotPart,    // type: Schema.Literal("snapshot")
  PatchPart,       // type: Schema.Literal("patch")
  AgentPart,       // type: Schema.Literal("agent")
  RetryPart,       // type: Schema.Literal("retry")
  CompactionPart,  // type: Schema.Literal("compaction")
]).annotate({ discriminator: "type" })

// session/message-v2.ts -- Tool lifecycle (4-state machine, discriminated on "status")
export const ToolState = Schema.Union([
  ToolStatePending,   // status: Schema.Literal("pending")
  ToolStateRunning,   // status: Schema.Literal("running")
  ToolStateCompleted, // status: Schema.Literal("completed")
  ToolStateError,     // status: Schema.Literal("error")
]).annotate({ discriminator: "status" })
```

`Schema.Literal("text")` is a single literal; `Schema.Literals(["a", "b"])` is the closed set (the old `z.enum`).

### Schema extension with `...Base.fields`

There is no `.extend()` — spread the `.fields` of an existing `Schema.Struct` into a new one:

```typescript
// session/message-v2.ts
export const Assistant = Schema.Struct({
  ...Base.fields,
  role: Schema.Literal("assistant"),
  error: Schema.optional(
    Schema.Union([
      AuthError.Schema,             // { name: "ProviderAuthError", data: { providerID, message } }
      NamedError.Unknown.Schema,    // { name: "UnknownError", data: { message } }
      OutputLengthError.Schema,     // { name: "MessageOutputLengthError", data: {} }
      AbortedError.Schema,          // { name: "MessageAbortedError", data: { message } }
      APIError.Schema,              // { name: "APIError", data: { message, statusCode?, isRetryable, ... } }
      ContextOverflowError.Schema,  // { name: "ContextOverflowError", data: { message, responseBody? } }
    ]).annotate({ discriminator: "name" }),
  ),
}).annotate({ identifier: "AssistantMessage" })
```

The error union is discriminated on `"name"` — each member is a `NamedError` `.Schema` (a `Schema.Struct({ name: Schema.Literal(tag), data })`; see §5).

### Branded ID Schemas

IDs are branded Effect Schema strings. There are two equivalent idioms; both live in `@opencode-ai/core/schema` and there is **no `.zod` bridge** anymore.

**Idiom A — `Schema.String.check(...).pipe(Schema.brand(...), withStatics(...))`** (Session, Message, Part):

```typescript
// session/schema.ts
import { Schema } from "effect"
import { Identifier } from "@/id/id"
import { Session as CoreSession } from "@opencode-ai/core/session"
import { withStatics } from "@opencode-ai/core/schema"

export const SessionID = CoreSession.ID
export type SessionID = Schema.Schema.Type<typeof SessionID>

export const MessageID = Schema.String.check(Schema.isStartsWith("msg")).pipe(
  Schema.brand("MessageID"),
  withStatics((s) => ({
    ascending: (id?: string) => s.make(Identifier.ascending("message", id)),
  })),
)
export type MessageID = Schema.Schema.Type<typeof MessageID>
```

**Idiom B — `Newtype<Self>()("Tag", schema)` class** (Question, Permission): see [service-module.md](service-module.md). Use the class form when you also want instance methods; the `.pipe(withStatics)` form when a value + a couple of static factories is enough.

`Schema.isStartsWith("msg")` validates the prefix at decode time; `s.make(raw)` brands. SessionIDs are **descending** (newest first in DB ordering); MessageIDs/PartIDs are **ascending** (oldest first within a session).

The `Identifier` module generates ULID-like IDs (`prefix_<6-byte-timestamp-hex><random-base62>`) — flat exports closed by a self-barrel:

```typescript
// id/id.ts
const prefixes = {
  event: "evt", session: "ses", message: "msg", permission: "per",
  question: "que", user: "usr", part: "prt", pty: "pty", tool: "tool", workspace: "wrk",
} as const

export function ascending(prefix: keyof typeof prefixes, given?: string) {
  return generateID(prefix, "ascending", given)
}

export function descending(prefix: keyof typeof prefixes, given?: string) {
  return generateID(prefix, "descending", given)
}

export function create(prefix: string, direction: "descending" | "ascending", timestamp?: number): string {
  const currentTimestamp = timestamp ?? Date.now()
  if (currentTimestamp !== lastTimestamp) {
    lastTimestamp = currentTimestamp
    counter = 0
  }
  counter++

  let now = BigInt(currentTimestamp) * BigInt(0x1000) + BigInt(counter)
  now = direction === "descending" ? ~now : now

  const timeBytes = Buffer.alloc(6)
  for (let i = 0; i < 6; i++) {
    timeBytes[i] = Number((now >> BigInt(40 - 8 * i)) & BigInt(0xff))
  }
  return prefixes[prefix] + "_" + timeBytes.toString("hex") + randomBase62(LENGTH - 12)
}

export * as Identifier from "./id"
```

Descending IDs use bitwise NOT (`~now`) so they sort in reverse chronological order without a DESC clause. Prefix validation now lives inline in each ID schema (`Schema.String.check(Schema.isStartsWith(prefix))`) rather than a separate `Identifier.schema()` helper.

---

## 3. Effect Schema Patterns

Effect Schema is the single schema system — domain data, bus/sync events, API validation, branded types, and both error families. Boundaries that need JSON Schema (tools, providers) generate it from the Effect Schema; there is no Zod in between.

### Schema.TaggedErrorClass for Errors

```typescript
// account/schema.ts
export class AccountRepoError extends Schema.TaggedErrorClass<AccountRepoError>()("AccountRepoError", {
  message: Schema.String,
  cause: Schema.optional(Schema.Defect),
}) {}

export class AccountServiceError extends Schema.TaggedErrorClass<AccountServiceError>()("AccountServiceError", {
  message: Schema.String,
  cause: Schema.optional(Schema.Defect),
}) {}

// filesystem/index.ts
export class FileSystemError extends Schema.TaggedErrorClass<FileSystemError>()("FileSystemError", {
  method: Schema.String,
  cause: Schema.optional(Schema.Defect),
}) {}

// auth/index.ts
export class AuthError extends Schema.TaggedErrorClass<AuthError>()("AuthError", {
  message: Schema.String,
  cause: Schema.optional(Schema.Defect),
}) {}

// question/index.ts
export class RejectedError extends Schema.TaggedErrorClass<RejectedError>()("QuestionRejectedError", {}) {
  override get message() { return "The user dismissed this question" }
}

// permission/index.ts
export class RejectedError extends Schema.TaggedErrorClass<RejectedError>()("PermissionRejectedError", {}) {
  override get message() { return "The user rejected permission to use this specific tool call." }
}

export class CorrectedError extends Schema.TaggedErrorClass<CorrectedError>()("PermissionCorrectedError", {
  feedback: Schema.String,
}) {}

export class DeniedError extends Schema.TaggedErrorClass<DeniedError>()("PermissionDeniedError", {
  ruleset: Schema.Any,
}) {}

// installation/index.ts
export class UpgradeFailedError extends Schema.TaggedErrorClass<UpgradeFailedError>()("UpgradeFailedError", {
  stderr: Schema.String,
}) {}
```

Pattern: `Schema.TaggedErrorClass<Self>()(tag, fields)`. The double invocation is required -- first call binds the self type, second call provides the tag and schema fields. These ride Effect error channels (the `E` in `Effect.Effect<A, E>`); the serializable `NamedError` family (§5) is the other half and is now also Effect Schema.

### Schema.brand for Branded Types

```typescript
// sync/schema.ts
export const EventID = Schema.String.check(Schema.isStartsWith("evt")).pipe(
  Schema.brand("EventID"),
  withStatics((s) => ({
    ascending: (id?: string) => s.make(Identifier.ascending("event", id)),
  })),
)
```

`s.make(raw)` brands a prefix-validated string. There is no `.zod` property anymore — the branded schema is used directly wherever a schema is required.

### Effect Schema → JSON Schema (provider/tool boundary)

Providers (OpenAI, Anthropic) and the tool registry need JSON Schema for tool definitions. It is generated directly from the Effect Schema — there is no Effect-to-Zod bridge:

```typescript
// tool/json-schema.ts
export function fromSchema(schema: Schema.Top): JSONSchema7 {
  /* walk schema.ast -> JSON Schema, carrying identifier/description annotations */
}

export function fromTool(tool: Tool.Def): JSONSchema7 {
  return fromSchema(tool.parameters)
}
```

Effect Schema is the source of truth; JSON Schema is the exchange format fed to the model (see `resolveTools` in [tool-module.md](tool-module.md)).

---

## 4. SyncEvent Flow (Event Sourcing)

All state mutations flow through `SyncEvent`. Events are defined with schemas, `run()` writes them, projectors apply them to SQLite, and bus events notify real-time subscribers.

### SyncEvent.define -- Event Registration

```typescript
// session/index.ts
export const Event = {
  Created: SyncEvent.define({
    type: "session.created",
    version: 1,
    aggregate: "sessionID",
    schema: Schema.Struct({
      sessionID: SessionID,
      info: Info,
    }),
  }),
  Updated: SyncEvent.define({
    type: "session.updated",
    version: 1,
    aggregate: "sessionID",
    // the update event carries a partial info -- a Struct of Schema.optional(...) fields the projector patches
    schema: Schema.Struct({
      sessionID: SessionID,
      info: SessionInfoUpdate,
    }),
    // busSchema emits the FULL object to subscribers — intentionally a different shape
    busSchema: Schema.Struct({
      sessionID: SessionID,
      info: Info,
    }),
  }),
}
```

`define()` registers the event in a global registry and tracks the latest version number per type. Once `SyncEvent.init()` is called, the registry freezes -- no more definitions allowed. Branded IDs go in directly (`SessionID`, not `SessionID.zod`).

### SyncEvent.define Internals

```typescript
// sync/index.ts — flat exports closed by `export * as SyncEvent from "."`
import { Schema } from "effect"

export type Definition<Schm extends Schema.Top = Schema.Top, BusSchm extends Schema.Top = Schm> = {
  type: string
  version: number
  aggregate: string
  schema: Schm
  properties: BusSchm // Bus payload schema; defaults to `schema` unless `busSchema` given
}

export const registry = new Map<string, Definition>()
const versions = new Map<string, number>()
let frozen = false

export function define<Type, Agg, Schm, BusSchm>(input) {
  if (frozen) throw new Error("sync system has been frozen")
  const def = { ...input, properties: input.busSchema ?? input.schema }
  versions.set(def.type, Math.max(def.version, versions.get(def.type) || 0))
  registry.set(versionedType(def.type, def.version), def)
  return def
}

export * as SyncEvent from "."
```

Versioned event types: `"session.created"` version 1 is stored as `"session.created.1"` in the registry. Only the latest version can be `run()`; old versions exist only for `replay()`.

### SyncEvent.project -- Projector Functions

Projectors are pure functions that translate events to DB operations:

```typescript
// session/projectors.ts
export default [
  SyncEvent.project(Session.Event.Created, (db, data) => {
    db.insert(SessionTable).values(Session.toRow(data.info)).run()
  }),

  SyncEvent.project(Session.Event.Updated, (db, data) => {
    const info = data.info
    const row = db
      .update(SessionTable)
      .set(toPartialRow(info))
      .where(eq(SessionTable.id, data.sessionID))
      .returning()
      .get()
    if (!row) throw new NotFoundError({ message: `Session not found: ${data.sessionID}` })
  }),

  SyncEvent.project(MessageV2.Event.PartUpdated, (db, data) => {
    const { id, messageID, sessionID, ...rest } = data.part
    try {
      db.insert(PartTable)
        .values({
          id,
          message_id: messageID,
          session_id: sessionID,
          time_created: data.time,
          data: rest,
        })
        .onConflictDoUpdate({ target: PartTable.id, set: { data: rest } })
        .run()
    } catch (err) {
      if (!foreign(err)) throw err
      log.warn("ignored late part update", { partID: id, messageID, sessionID })
    }
  }),
]
```

Projectors handle foreign key failures gracefully -- a late part update after session deletion is logged and ignored, not thrown. The `foreign(err)` helper detects SQLite foreign key constraint violations.

### SyncEvent.run -- The Write Path

```typescript
// sync/index.ts
export function run<Def>(def: Def, data) {
  // Validates version is latest
  // Uses IMMEDIATE transaction for safe read-write
  // Auto-increments sequence per aggregate
  // Calls process() which runs projector + publishes to Bus
  Database.transaction((tx) => {
    const id = EventID.ascending()
    const row = tx.select({ seq }).from(EventSequenceTable).where(...).get()
    const seq = row?.seq != null ? row.seq + 1 : 0
    process(def, { id, seq, aggregateID: agg, data }, { publish: true })
  }, { behavior: "immediate" })
}
```

**Critical**: `{ behavior: "immediate" }` is mandatory for the write path. Without it, concurrent reads could produce duplicate sequence numbers. The sequence is read-then-increment inside the transaction.

### The process() Function -- Projector + Bus

```typescript
// sync/index.ts
function process(def, event, options) {
  Database.transaction((tx) => {
    projector(tx, event.data)                    // Run the projector
    tx.insert(EventSequenceTable).values(...)    // Upsert sequence
      .onConflictDoUpdate(...)
    tx.insert(EventTable).values(...)            // Store event
    Database.effect(() => {                       // Post-commit side effects
      Bus.emit("event", { def, event })
      if (options.publish) {
        const result = convertEvent(def.type, event.data)
        // Handle both sync and async conversion
        ProjectBus.publish(...)
      }
    })
  })
}
```

The projector runs INSIDE the transaction. Bus publishing runs AFTER the transaction commits, via `Database.effect()`. This guarantees that subscribers only see events whose DB writes have succeeded.

### Projector Bootstrap -- server/projectors.ts

```typescript
// server/projectors.ts
export function initProjectors() {
  SyncEvent.init({
    projectors: sessionProjectors,
    convertEvent: (type, data) => {
      if (type === "session.updated") {
        const id = (data as Schema.Schema.Type<typeof Session.Event.Updated.schema>).sessionID
        const row = Database.use((db) => db.select().from(SessionTable).where(eq(SessionTable.id, id)).get())
        if (!row) return data
        return { sessionID: id, info: Session.fromRow(row) }
      }
      return data
    },
  })
}
```

`convertEvent` reshapes events before Bus publication. For `session.updated`, it reads the full row from the DB and publishes the complete state (not the partial update). This is called once at server startup. After `init()`, the registry freezes.

In tests, projectors must be initialized before any SyncEvent operations:

```typescript
const { initProjectors } = await import("../src/server/projectors")
initProjectors()
```

### SyncEvent.replay -- Idempotent Event Replay

```typescript
// sync/index.ts
export function replay(event: SerializedEvent, options?) {
  // Idempotent: skips events with seq <= latest
  // Validates sequence continuity (expected = latest + 1)
  // Does NOT publish to Bus unless options.republish
}
```

Replay enforces strict sequential ordering and skips already-applied events. Used for sync from remote sources.

---

## 5. Error Taxonomy

The codebase has two error families, **both built on Effect `Schema`**: `NamedError` (serializable discriminated-union errors for the API/wire, storage, and assistant-message errors) and `Schema.TaggedErrorClass` (Effect error-channel errors for services). `NamedError` used to be Zod-based; it is now a `Schema.Struct({ name: Schema.Literal(tag), data })`.

### NamedError.create Pattern

```typescript
// core/util/error.ts
import { Schema } from "effect"

export abstract class NamedError extends Error {
  abstract schema(): Schema.Top
  abstract toObject(): { name: string; data: unknown }

  static hasName(error: unknown, name: string): boolean {
    return (
      typeof error === "object" && error !== null && "name" in error &&
      (error as Record<string, unknown>).name === name
    )
  }

  // `data` is either an object of Schema fields (sugar) or a full Schema
  static create<Name extends string>(name: Name, data: Schema.Top | Schema.Struct.Fields) {
    const dataSchema = Schema.isSchema(data) ? data : Schema.Struct(data)
    const schema = Schema.Struct({
      name: Schema.Literal(name),
      data: dataSchema,
    }).annotate({ identifier: name })

    const result = class extends NamedError {
      public static readonly Schema = schema
      public static readonly tag = name
      public override readonly name = name

      constructor(
        public readonly data: Schema.Schema.Type<typeof dataSchema>,
        options?: ErrorOptions,
      ) {
        super(name, options)
        this.name = name
      }

      static isInstance(input: unknown): input is InstanceType<typeof result> {
        return NamedError.hasName(input, name)
      }

      schema() {
        return schema
      }

      toObject() {
        return { name, data: this.data }
      }
    }
    Object.defineProperty(result, "name", { value: name })
    return result
  }

  public static readonly Unknown = NamedError.create("UnknownError", {
    message: Schema.String,
    ref: Schema.optional(Schema.String),
  })
}
```

Each `NamedError.create()` call produces a class with:
- `.Schema` -- an Effect Schema `Schema.Struct({ name: Schema.Literal(tag), data })` (plus `.tag`) for discriminated unions
- `.isInstance()` -- runtime type check using the `name` discriminator
- `.toObject()` -- serialization for JSON responses and event storage

`create` accepts a plain object of `Schema` fields as a shorthand for `Schema.Struct(...)`.

### Real NamedError Subclasses

`create` takes a plain object of `Schema` fields (it wraps them in `Schema.Struct`), so subclasses pass `{ field: Schema.X }` directly.

**Message errors** (session/message-v2.ts):
```typescript
export const OutputLengthError = NamedError.create("MessageOutputLengthError", {})

export const AbortedError = NamedError.create("MessageAbortedError", { message: Schema.String })

export const StructuredOutputError = NamedError.create("StructuredOutputError", {
  message: Schema.String,
  retries: Schema.Number,
})

export const AuthError = NamedError.create("ProviderAuthError", {
  providerID: Schema.String,
  message: Schema.String,
})

export const APIError = NamedError.create("APIError", {
  message: Schema.String,
  statusCode: Schema.optional(Schema.Number),
  isRetryable: Schema.Boolean,
  responseHeaders: Schema.optional(Schema.Record(Schema.String, Schema.String)),
  responseBody: Schema.optional(Schema.String),
  metadata: Schema.optional(Schema.Record(Schema.String, Schema.String)),
})

export const ContextOverflowError = NamedError.create("ContextOverflowError", {
  message: Schema.String,
  responseBody: Schema.optional(Schema.String),
})
```

**Storage errors** (storage/db.ts):
```typescript
export const NotFoundError = NamedError.create("NotFoundError", { message: Schema.String })
```

**Provider errors** (provider/provider.ts):
```typescript
export const ModelNotFoundError = NamedError.create("ProviderModelNotFoundError", {
  providerID: ProviderID,
  modelID: ModelID,
  suggestions: Schema.optional(Schema.Array(Schema.String)),
})

export const InitError = NamedError.create("ProviderInitError", {
  providerID: ProviderID,
})
```

**Provider auth errors** (provider/auth.ts):
```typescript
export const OauthMissing = NamedError.create("ProviderAuthOauthMissing", { providerID: ProviderID })
export const OauthCodeMissing = NamedError.create("ProviderAuthOauthCodeMissing", { providerID: ProviderID })
export const OauthCallbackFailed = NamedError.create("ProviderAuthOauthCallbackFailed", {})
export const ValidationFailed = NamedError.create("ProviderAuthValidationFailed", {
  field: Schema.String,
  message: Schema.String,
})
```

### Error Flow: Provider -> parseAPICallError -> MessageV2.fromError -> HTTP Status

**Step 1 -- ProviderError.parseAPICallError** classifies raw errors from the AI SDK:

```typescript
// provider/error.ts — flat module, closed by the self-barrel
const OVERFLOW_PATTERNS = [
  /prompt is too long/i,                        // Anthropic
  /input is too long for requested model/i,     // Amazon Bedrock
  /exceeds the context window/i,                // OpenAI
  /input token count.*exceeds the maximum/i,    // Google (Gemini)
  /maximum prompt length is \d+/i,              // xAI (Grok)
  /reduce the length of the messages/i,         // Groq
  /maximum context length is \d+ tokens/i,      // OpenRouter, DeepSeek, vLLM
  /exceeds the limit of \d+/i,                  // GitHub Copilot
  /exceeds the available context size/i,        // llama.cpp
  /greater than the context length/i,           // LM Studio
  /context window exceeds limit/i,              // MiniMax
  /exceeded model token limit/i,                // Kimi/Moonshot
  /context[_ ]length[_ ]exceeded/i,             // Generic fallback
  /request entity too large/i,                  // HTTP 413
  /context length is only \d+ tokens/i,         // vLLM
  /input length.*exceeds.*context length/i,     // vLLM
]

export function parseAPICallError(input: { providerID: ProviderID; error: APICallError }): ParsedAPICallError {
  const m = message(input.providerID, input.error)
  const body = json(input.error.responseBody)
  if (isOverflow(m) || input.error.statusCode === 413 || body?.error?.code === "context_length_exceeded") {
    return { type: "context_overflow", message: m, responseBody: input.error.responseBody }
  }
  const metadata = input.error.url ? { url: input.error.url } : undefined
  return {
    type: "api_error",
    message: m,
    statusCode: input.error.statusCode,
    isRetryable: input.providerID.startsWith("openai")
      ? isOpenAiErrorRetryable(input.error)
      : input.error.isRetryable,
    responseHeaders: input.error.responseHeaders,
    responseBody: input.error.responseBody,
    metadata,
  }
}

export * as ProviderError from "."
```

**Step 2 -- MessageV2.fromError** converts any thrown error into the typed discriminated union:

```typescript
// session/message-v2.ts
export function fromError(
  e: unknown,
  ctx: { providerID: ProviderID; aborted?: boolean },
): NonNullable<Assistant["error"]> {
  switch (true) {
    case e instanceof DOMException && e.name === "AbortError":
      return new MessageV2.AbortedError({ message: e.message }, { cause: e }).toObject()

    case MessageV2.OutputLengthError.isInstance(e):
      return e

    case LoadAPIKeyError.isInstance(e):
      return new MessageV2.AuthError(
        { providerID: ctx.providerID, message: e.message },
        { cause: e },
      ).toObject()

    case (e as SystemError)?.code === "ECONNRESET":
      return new MessageV2.APIError(
        {
          message: "Connection reset by server",
          isRetryable: true,
          metadata: { code: (e as SystemError).code ?? "", syscall: (e as SystemError).syscall ?? "", message: (e as SystemError).message ?? "" },
        },
        { cause: e },
      ).toObject()

    case e instanceof Error && (e as FetchDecompressionError).code === "ZlibError":
      if (ctx.aborted) {
        return new MessageV2.AbortedError({ message: e.message }, { cause: e }).toObject()
      }
      return new MessageV2.APIError(
        { message: "Response decompression failed", isRetryable: true, metadata: { code: (e as FetchDecompressionError).code, message: e.message } },
        { cause: e },
      ).toObject()

    case APICallError.isInstance(e):
      const parsed = ProviderError.parseAPICallError({ providerID: ctx.providerID, error: e })
      if (parsed.type === "context_overflow") {
        return new MessageV2.ContextOverflowError({ message: parsed.message, responseBody: parsed.responseBody }, { cause: e }).toObject()
      }
      return new MessageV2.APIError(
        { message: parsed.message, statusCode: parsed.statusCode, isRetryable: parsed.isRetryable, responseHeaders: parsed.responseHeaders, responseBody: parsed.responseBody, metadata: parsed.metadata },
        { cause: e },
      ).toObject()

    case e instanceof Error:
      return new NamedError.Unknown({ message: errorMessage(e) }, { cause: e }).toObject()

    default:
      try {
        const parsed = ProviderError.parseStreamError(e)
        if (parsed) {
          if (parsed.type === "context_overflow") {
            return new MessageV2.ContextOverflowError({ message: parsed.message, responseBody: parsed.responseBody }, { cause: e }).toObject()
          }
          return new MessageV2.APIError({ message: parsed.message, isRetryable: parsed.isRetryable, responseBody: parsed.responseBody }, { cause: e }).toObject()
        }
      } catch {}
      return new NamedError.Unknown({ message: JSON.stringify(e) }, { cause: e }).toObject()
  }
}
```

**Step 3 -- HTTP error handler** maps NamedError types to HTTP status codes:

```typescript
// server/middleware.ts
export function errorHandler(log: Log.Logger): ErrorHandler {
  return (err, c) => {
    log.error("failed", { error: err })
    if (err instanceof NamedError) {
      let status: ContentfulStatusCode
      if (err instanceof NotFoundError) status = 404
      else if (err instanceof Provider.ModelNotFoundError) status = 400
      else if (err.name === "ProviderAuthValidationFailed") status = 400
      else if (err.name.startsWith("Worktree")) status = 400
      else status = 500
      return c.json(err.toObject(), { status })
    }
    if (err instanceof HTTPException) return err.getResponse()
    const message = err instanceof Error && err.stack ? err.stack : err.toString()
    return c.json(new NamedError.Unknown({ message }).toObject(), { status: 500 })
  }
}
```

**Error-to-HTTP mapping:**

| Error class / name | HTTP status |
|---|---|
| `NotFoundError` | 404 |
| `Provider.ModelNotFoundError` | 400 |
| `ProviderAuthValidationFailed` | 400 |
| Any `Worktree*` error | 400 |
| Any other `NamedError` | 500 |
| `HTTPException` (Hono) | exception's own status |
| Any other `Error` | 500 (wrapped as `UnknownError`) |

---

## 6. Database Patterns

### Database Initialization

```typescript
// storage/db.ts — flat module, closed by `export * as Database from "./db"`
export const Path = iife(() => {
  if (Flag.OPENCODE_DB) { /* custom path */ }
  return getChannelPath()
})

export const Client = lazy(() => {
  const db = init(Path)
  db.run("PRAGMA journal_mode = WAL")
  db.run("PRAGMA synchronous = NORMAL")
  db.run("PRAGMA busy_timeout = 5000")
  db.run("PRAGMA cache_size = -64000")
  db.run("PRAGMA foreign_keys = ON")
  db.run("PRAGMA wal_checkpoint(PASSIVE)")
  // Apply migrations
  return db
})

export * as Database from "./db"
```

`Client` uses `lazy()` so the database is opened on first use, not on import. Different release channels use different database files via `getChannelPath()`. The `init` function is platform-conditional: Bun uses `bun:sqlite`, Node uses `node:sqlite` (22+), selected via `#db` import alias.

### Database.use -- Read-Only Context

```typescript
// storage/db.ts
const ctx = LocalContext.create<{ tx: TxOrDb; effects: (() => void | Promise<void>)[] }>("database")

export function use<T>(callback: (trx: TxOrDb) => T): T {
  try {
    return callback(ctx.use().tx)
  } catch (err) {
    if (err instanceof LocalContext.NotFound) {
      const effects: (() => void | Promise<void>)[] = []
      const result = ctx.provide({ effects, tx: Client() }, () => callback(Client()))
      for (const effect of effects) effect()
      return result
    }
    throw err
  }
}
```

If already inside a transaction or context, reuses the existing connection. If no context exists (`LocalContext.NotFound`), auto-creates one with the raw client. Effects queued during the callback are flushed immediately after (since there is no transaction to wait for).

### Database.transaction -- Write Context with Behavior

```typescript
// storage/db.ts
export function transaction<T>(
  callback: (tx: TxOrDb) => NotPromise<T>,
  options?: { behavior?: "deferred" | "immediate" | "exclusive" },
): NotPromise<T> {
  try {
    return callback(ctx.use().tx)
  } catch (err) {
    if (err instanceof LocalContext.NotFound) {
      const effects: (() => void | Promise<void>)[] = []
      const result = Client().transaction(
        (tx: TxOrDb) => ctx.provide({ tx, effects }, () => callback(tx)),
        { behavior: options?.behavior },
      )
      for (const effect of effects) effect()
      return result as NotPromise<T>
    }
    throw err
  }
}
```

**Reentrant**: if already inside a transaction, the callback receives the existing `tx` without nesting. New transactions propagate via `AsyncLocalStorage` (`LocalContext.create`). Effects are flushed AFTER the transaction commits.

`NotPromise<T>` prevents async callbacks -- SQLite transactions are synchronous. Use `{ behavior: "immediate" }` for write transactions that need read consistency (like sequence number increment in `SyncEvent.run`).

### Database.effect -- Post-Commit Side Effects

```typescript
// storage/db.ts
export function effect(fn: () => any | Promise<any>) {
  try { ctx.use().effects.push(fn) }
  catch { fn() }
}
```

Inside a transaction, `effect()` queues the function to run after commit. Outside a transaction (the `catch` path), it runs immediately. This is how Bus publishing happens after DB writes:

```typescript
// Usage inside SyncEvent.process():
Database.transaction((tx) => {
  projector(tx, event.data)             // Mutate DB
  tx.insert(EventTable).values(...)     // Store event
  Database.effect(() => {               // Runs AFTER commit
    Bus.publish(def, event.data)
  })
})
```

### The LocalLocalContext.NotFound Pattern

opencode's own `AsyncLocalStorage` wrapper was renamed from `Context` to **`LocalContext`** (`@/util/local-context`) so it no longer collides with Effect's `Context` (the DI/service namespace). It is a flat module closed by a self-barrel:

```typescript
// util/local-context.ts
export class NotFound extends Error {
  constructor(public override readonly name: string) {
    super(`No context found for ${name}`)
  }
}

export function create<T>(name: string) {
  const storage = new AsyncLocalStorage<T>()
  return {
    use() {
      const result = storage.getStore()
      if (!result) {
        throw new NotFound(name)
      }
      return result
    },
    provide<R>(value: T, fn: () => R) {
      return storage.run(value, fn)
    },
  }
}

export * as LocalContext from "./local-context"
```

Both `Database.use()` and `Database.transaction()` try `ctx.use()` first. If it throws `LocalLocalContext.NotFound`, they auto-create a root context. This means callers never need to explicitly set up a database context -- the first database call in a call stack creates it automatically. (This `LocalContext` is unrelated to Effect's `Context`/`Context.Service` used for DI elsewhere.)
