# Schemas and State Management

This reference covers database schemas, Zod/Effect schema patterns, event-sourced state management, and the error taxonomy used across the opencode TypeScript codebase.

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

## 2. Zod Schema Patterns

### z.object + z.infer + .meta({ref})

The `.meta({ ref })` annotation names schemas for OpenAPI generation and SDK type extraction:

```typescript
// packages/util/src/error.ts -- inside NamedError.create
const schema = z
  .object({
    name: z.literal(name),
    data,
  })
  .meta({
    ref: name,
  })
```

```typescript
// util/log.ts
export const Level = z.enum(["DEBUG", "INFO", "WARN", "ERROR"]).meta({ ref: "LogLevel", description: "Log level" })
export type Level = z.infer<typeof Level>
```

The `ref` becomes the `$ref` name in generated OpenAPI specs. Every schema that appears in API responses or events gets a `.meta({ ref })`.

### z.discriminatedUnion for Variant Types

Messages use discriminated unions on `"type"` for parts, `"status"` for tool state, and `"name"` for errors:

```typescript
// session/message-v2.ts -- Part types (12 variants)
export const Part = z.discriminatedUnion("type", [
  TextPart,        // text with optional synthetic/ignored flags
  SubtaskPart,     // agent delegation
  ReasoningPart,   // model thinking
  FilePart,        // attached files with mime, url, optional source
  ToolPart,        // tool calls with full lifecycle state
  StepStartPart,   // marks beginning of an LLM step (with snapshot)
  StepFinishPart,  // marks end with tokens/cost
  SnapshotPart,    // git snapshot reference
  PatchPart,       // file changes since last snapshot
  AgentPart,       // agent reference
  RetryPart,       // retry tracking
  CompactionPart,  // context compaction marker
])

// session/message-v2.ts -- Tool lifecycle (4-state machine)
export const ToolState = z.discriminatedUnion("status", [
  ToolStatePending,   // { status: "pending", input: {}, raw: "" }
  ToolStateRunning,   // { status: "running", input: {}, title?, metadata?, time: { start } }
  ToolStateCompleted, // { status: "completed", input: {}, output, title, metadata, time: { start, end, compacted? }, attachments? }
  ToolStateError,     // { status: "error", input: {}, error, metadata?, time: { start, end } }
])

// session/message-v2.ts -- Error variants on assistant messages
export const Assistant = Base.extend({
  role: z.literal("assistant"),
  error: z
    .discriminatedUnion("name", [
      AuthError.Schema,           // { name: "ProviderAuthError", data: { providerID, message } }
      NamedError.Unknown.Schema,  // { name: "UnknownError", data: { message } }
      OutputLengthError.Schema,   // { name: "MessageOutputLengthError", data: {} }
      AbortedError.Schema,        // { name: "MessageAbortedError", data: { message } }
      StructuredOutputError.Schema, // { name: "StructuredOutputError", data: { message, retries } }
      ContextOverflowError.Schema, // { name: "ContextOverflowError", data: { message, responseBody? } }
      APIError.Schema,            // { name: "APIError", data: { message, statusCode?, isRetryable, ... } }
    ])
    .optional(),
})
```

### Schema Extension with .extend()

`.extend()` adds fields to an existing z.object. Used for role-specific message schemas:

```typescript
// session/message-v2.ts
export const Assistant = Base.extend({
  role: z.literal("assistant"),
  error: z.discriminatedUnion("name", [/* ... */]).optional(),
})
```

For partial updates, `updateSchema()` wraps all fields as optional+nullable, then `.extend()` adds nested partial fields:

```typescript
// session/index.ts
Updated: SyncEvent.define({
  type: "session.updated",
  version: 1,
  aggregate: "sessionID",
  schema: z.object({
    sessionID: SessionID.zod,
    info: updateSchema(Info).extend({
      share: updateSchema(Info.shape.share.unwrap()).optional(),
      time: updateSchema(Info.shape.time).optional(),
    }),
  }),
  busSchema: z.object({
    sessionID: SessionID.zod,
    info: Info,
  }),
}),
```

The event `schema` accepts partial updates (for projectors). The `busSchema` emits the full object (for subscribers). These are intentionally different shapes.

### Branded ID Schemas (Newtype + Identifier)

IDs are branded Effect Schema strings with dual Zod representations. The `Newtype` + `withStatics` pattern creates nominal types:

```typescript
// util/schema.ts
export function Newtype<Self>() {
  return <const Tag extends string, S extends Schema.Top>(tag: Tag, schema: S) => {
    type Branded = NewtypeBrand<Tag>

    abstract class Base {
      declare readonly [NewtypeBrand]: Tag

      static makeUnsafe(value: Schema.Schema.Type<S>): Self {
        return value as unknown as Self
      }
    }

    Object.setPrototypeOf(Base, schema)

    return Base as unknown as (abstract new (_: never) => Branded) & {
      readonly makeUnsafe: (value: Schema.Schema.Type<S>) => Self
    } & Omit<Schema.Opaque<Self, S, {}>, "makeUnsafe">
  }
}

export const withStatics =
  <S extends object, M extends Record<string, unknown>>(methods: (schema: S) => M) =>
  (schema: S): S & M =>
    Object.assign(schema, methods(schema))
```

Applied to create branded IDs:

```typescript
// session/schema.ts
export const SessionID = Schema.String.pipe(
  Schema.brand("SessionID"),
  withStatics((s) => ({
    make: (id: string) => s.makeUnsafe(id),
    descending: (id?: string) => s.makeUnsafe(Identifier.descending("session", id)),
    zod: Identifier.schema("session").pipe(z.custom<Schema.Schema.Type<typeof s>>()),
  })),
)

export const MessageID = Schema.String.pipe(
  Schema.brand("MessageID"),
  withStatics((s) => ({
    make: (id: string) => s.makeUnsafe(id),
    ascending: (id?: string) => s.makeUnsafe(Identifier.ascending("message", id)),
    zod: Identifier.schema("message").pipe(z.custom<Schema.Schema.Type<typeof s>>()),
  })),
)
```

SessionIDs are **descending** (newest first in DB ordering). MessageIDs are **ascending** (oldest first within a session). Each has both an Effect Schema representation and a `.zod` property for Zod interop.

The `Identifier` module generates ULID-like IDs with the format `prefix_<6-byte-timestamp-hex><14-char-random-base62>`:

```typescript
// id/id.ts
export namespace Identifier {
  const prefixes = {
    event: "evt",
    session: "ses",
    message: "msg",
    permission: "per",
    question: "que",
    user: "usr",
    part: "prt",
    pty: "pty",
    tool: "tool",
    workspace: "wrk",
  } as const

  export function schema(prefix: keyof typeof prefixes) {
    return z.string().startsWith(prefixes[prefix])
  }

  export function ascending(prefix: keyof typeof prefixes, given?: string) {
    return generateID(prefix, false, given)
  }

  export function descending(prefix: keyof typeof prefixes, given?: string) {
    return generateID(prefix, true, given)
  }

  export function create(prefix: keyof typeof prefixes, descending: boolean, timestamp?: number): string {
    const currentTimestamp = timestamp ?? Date.now()

    if (currentTimestamp !== lastTimestamp) {
      lastTimestamp = currentTimestamp
      counter = 0
    }
    counter++

    let now = BigInt(currentTimestamp) * BigInt(0x1000) + BigInt(counter)

    now = descending ? ~now : now

    const timeBytes = Buffer.alloc(6)
    for (let i = 0; i < 6; i++) {
      timeBytes[i] = Number((now >> BigInt(40 - 8 * i)) & BigInt(0xff))
    }

    return prefixes[prefix] + "_" + timeBytes.toString("hex") + randomBase62(LENGTH - 12)
  }
}
```

Descending IDs use bitwise NOT (`~now`) so they sort in reverse chronological order without a DESC clause.

---

## 3. Effect Schema Patterns

Effect Schema is used for domain error classes and branded types. Zod is used for event schemas, API validation, and OpenAPI generation. The two worlds are bridged explicitly.

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

Pattern: `Schema.TaggedErrorClass<Self>()(tag, fields)`. The double invocation is required -- first call binds the self type, second call provides the tag and schema fields. These are used in Effect error channels, not in Zod discriminated unions.

### Schema.brand for Branded Types

```typescript
// sync/schema.ts
export const EventID = Schema.String.pipe(
  Schema.brand("EventID"),
  withStatics((s) => ({
    make: (id: string) => s.makeUnsafe(id),
    ascending: (id?: string) => s.makeUnsafe(Identifier.ascending("event", id)),
    zod: Identifier.schema("event").pipe(z.custom<Schema.Schema.Type<typeof s>>()),
  })),
)
```

Every branded ID has `.zod` for cross-system compatibility. The `.zod` property creates a Zod schema that validates the prefix and casts to the branded type.

### Bridge: Effect Schema to Zod

The `util/effect-zod.ts` module converts Effect Schema AST to Zod schemas by walking the AST tree:

```typescript
// util/effect-zod.ts
export function zod<S extends Schema.Top>(schema: S): z.ZodType<Schema.Schema.Type<S>> {
  return walk(schema.ast) as z.ZodType<Schema.Schema.Type<S>>
}

function walk(ast: SchemaAST.AST): z.ZodTypeAny {
  const out = body(ast)
  const desc = SchemaAST.resolveDescription(ast)
  const ref = SchemaAST.resolveIdentifier(ast)
  const next = desc ? out.describe(desc) : out
  return ref ? next.meta({ ref }) : next
}
```

This is needed because providers (OpenAI, Anthropic) expect Zod schemas for tool definitions. Effect Schema is the source of truth for domain types; Zod is the exchange format.

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
    schema: z.object({
      sessionID: SessionID.zod,
      info: Info,
    }),
  }),
  Updated: SyncEvent.define({
    type: "session.updated",
    version: 1,
    aggregate: "sessionID",
    schema: z.object({
      sessionID: SessionID.zod,
      info: updateSchema(Info).extend({
        share: updateSchema(Info.shape.share.unwrap()).optional(),
        time: updateSchema(Info.shape.time).optional(),
      }),
    }),
    busSchema: z.object({
      sessionID: SessionID.zod,
      info: Info,
    }),
  }),
}
```

`define()` registers the event in a global registry and tracks the latest version number per type. Once `SyncEvent.init()` is called, the registry freezes -- no more definitions allowed.

### SyncEvent.define Internals

```typescript
// sync/index.ts
export namespace SyncEvent {
  export type Definition = {
    type: string
    version: number
    aggregate: string
    schema: z.ZodObject
    properties: z.ZodObject  // Bus compat
  }

  export const registry = new Map<string, Definition>()
  let projectors: Map<Definition, ProjectorFunc> | undefined
  const versions = new Map<string, number>()
  let frozen = false

  export function define<Type, Agg, Schema, BusSchema>(input) {
    if (frozen) throw new Error("sync system has been frozen")
    const def = { ...input, properties: input.busSchema || input.schema }
    versions.set(def.type, Math.max(def.version, versions.get(def.type) || 0))
    registry.set(versionedType(def.type, def.version), def)
    return def
  }
}
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
        const id = (data as z.infer<typeof Session.Event.Updated.schema>).sessionID
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

The codebase has two parallel error systems: `NamedError` (Zod-based, for API/storage errors) and `Schema.TaggedErrorClass` (Effect-based, for domain/service errors).

### NamedError.create Pattern

```typescript
// packages/util/src/error.ts
export abstract class NamedError extends Error {
  abstract schema(): z.core.$ZodType
  abstract toObject(): { name: string; data: any }

  static create<Name extends string, Data extends z.core.$ZodType>(name: Name, data: Data) {
    const schema = z
      .object({
        name: z.literal(name),
        data,
      })
      .meta({
        ref: name,
      })
    const result = class extends NamedError {
      public static readonly Schema = schema

      public override readonly name = name as Name

      constructor(
        public readonly data: z.input<Data>,
        options?: ErrorOptions,
      ) {
        super(name, options)
        this.name = name
      }

      static isInstance(input: any): input is InstanceType<typeof result> {
        return typeof input === "object" && "name" in input && input.name === name
      }

      schema() {
        return schema
      }

      toObject() {
        return {
          name: name,
          data: this.data,
        }
      }
    }
    Object.defineProperty(result, "name", { value: name })
    return result
  }

  public static readonly Unknown = NamedError.create(
    "UnknownError",
    z.object({
      message: z.string(),
    }),
  )
}
```

Each `NamedError.create()` call produces a class with:
- `.Schema` -- a Zod schema with `{ name: z.literal(tag), data: ... }` for discriminated unions
- `.isInstance()` -- runtime type check using the `name` discriminator
- `.toObject()` -- serialization for JSON responses and event storage

### Real NamedError Subclasses

**Message errors** (session/message-v2.ts):
```typescript
export const OutputLengthError = NamedError.create("MessageOutputLengthError", z.object({}))

export const AbortedError = NamedError.create("MessageAbortedError", z.object({ message: z.string() }))

export const StructuredOutputError = NamedError.create(
  "StructuredOutputError",
  z.object({
    message: z.string(),
    retries: z.number(),
  }),
)

export const AuthError = NamedError.create(
  "ProviderAuthError",
  z.object({
    providerID: z.string(),
    message: z.string(),
  }),
)

export const APIError = NamedError.create(
  "APIError",
  z.object({
    message: z.string(),
    statusCode: z.number().optional(),
    isRetryable: z.boolean(),
    responseHeaders: z.record(z.string(), z.string()).optional(),
    responseBody: z.string().optional(),
    metadata: z.record(z.string(), z.string()).optional(),
  }),
)

export const ContextOverflowError = NamedError.create(
  "ContextOverflowError",
  z.object({ message: z.string(), responseBody: z.string().optional() }),
)
```

**Storage errors** (storage/db.ts):
```typescript
export const NotFoundError = NamedError.create(
  "NotFoundError",
  z.object({
    message: z.string(),
  }),
)
```

**Provider errors** (provider/provider.ts):
```typescript
export const ModelNotFoundError = NamedError.create(
  "ProviderModelNotFoundError",
  z.object({
    providerID: ProviderID.zod,
    modelID: ModelID.zod,
    suggestions: z.array(z.string()).optional(),
  }),
)

export const InitError = NamedError.create(
  "ProviderInitError",
  z.object({
    providerID: ProviderID.zod,
  }),
)
```

**Provider auth errors** (provider/auth.ts):
```typescript
export const OauthMissing = NamedError.create("ProviderAuthOauthMissing", z.object({ providerID: ProviderID.zod }))
export const OauthCodeMissing = NamedError.create("ProviderAuthOauthCodeMissing", z.object({ providerID: ProviderID.zod }))
export const OauthCallbackFailed = NamedError.create("ProviderAuthOauthCallbackFailed", z.object({}))
export const ValidationFailed = NamedError.create(
  "ProviderAuthValidationFailed",
  z.object({
    field: z.string(),
    message: z.string(),
  }),
)
```

### Error Flow: Provider -> parseAPICallError -> MessageV2.fromError -> HTTP Status

**Step 1 -- ProviderError.parseAPICallError** classifies raw errors from the AI SDK:

```typescript
// provider/error.ts
export namespace ProviderError {
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
}
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
// storage/db.ts
export namespace Database {
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
}
```

`Client` uses `lazy()` so the database is opened on first use, not on import. Different release channels use different database files via `getChannelPath()`. The `init` function is platform-conditional: Bun uses `bun:sqlite`, Node uses `node:sqlite` (22+), selected via `#db` import alias.

### Database.use -- Read-Only Context

```typescript
// storage/db.ts
const ctx = Context.create<{ tx: TxOrDb; effects: (() => void | Promise<void>)[] }>("database")

export function use<T>(callback: (trx: TxOrDb) => T): T {
  try {
    return callback(ctx.use().tx)
  } catch (err) {
    if (err instanceof Context.NotFound) {
      const effects: (() => void | Promise<void>)[] = []
      const result = ctx.provide({ effects, tx: Client() }, () => callback(Client()))
      for (const effect of effects) effect()
      return result
    }
    throw err
  }
}
```

If already inside a transaction or context, reuses the existing connection. If no context exists (`Context.NotFound`), auto-creates one with the raw client. Effects queued during the callback are flushed immediately after (since there is no transaction to wait for).

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
    if (err instanceof Context.NotFound) {
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

**Reentrant**: if already inside a transaction, the callback receives the existing `tx` without nesting. New transactions propagate via `AsyncLocalStorage` (`Context.create`). Effects are flushed AFTER the transaction commits.

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

### The Context.NotFound Pattern

The `Context` module wraps `AsyncLocalStorage`:

```typescript
// util/context.ts
export namespace Context {
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
}
```

Both `Database.use()` and `Database.transaction()` try `ctx.use()` first. If it throws `Context.NotFound`, they auto-create a root context. This means callers never need to explicitly set up a database context -- the first database call in a call stack creates it automatically.
