# OpenCode Style DNA

The invisible decisions that make code belong in this codebase. Learn from the patterns, not the prose.

---

## 1. Mandatory Rules (verbatim from AGENTS.md)

These are enforced. Violating any of them gets code rejected.

- **ALWAYS USE PARALLEL TOOLS WHEN APPLICABLE.**
- Keep things in one function unless composable or reusable
- Avoid `try`/`catch` where possible
- Avoid using the `any` type
- Prefer single word variable names where possible
- ~~Use Bun APIs when possible, like `Bun.file()`~~ **SUPERSEDED:** The codebase migrated away from Bun-specific APIs. Use `Filesystem`, `Glob`, `Process` from `@/util/` instead of `Bun.file()`, `Bun.Glob`, `Bun.spawn`. See [refactoring-patterns.md](refactoring-patterns.md) Pattern 2.
- Rely on type inference when possible; avoid explicit type annotations or interfaces unless necessary for exports or clarity
- Prefer functional array methods (flatMap, filter, map) over for loops; use type guards on filter to maintain type inference downstream

### Naming Enforcement (MANDATORY FOR AGENT WRITTEN CODE)

- Use single word names by default for new locals, params, and helper functions.
- Multi-word names are allowed only when a single word would be unclear or ambiguous.
- Do not introduce new camelCase compounds when a short single-word alternative is clear.
- Before finishing edits, review touched lines and shorten newly introduced identifiers where possible.
- Good short names to prefer: `pid`, `cfg`, `err`, `opts`, `dir`, `root`, `child`, `state`, `timeout`.
- Examples to avoid unless truly required: `inputPID`, `existingClient`, `connectTimeout`, `workerPath`.
- Reduce total variable count by inlining when a value is only used once.

### Destructuring

Avoid unnecessary destructuring. Use dot notation to preserve context.

```ts
// Good
obj.a
obj.b

// Bad
const { a, b } = obj
```

### Variables

Prefer `const` over `let`. Use ternaries or early returns instead of reassignment.

### Control Flow

Avoid `else` statements. Prefer early returns.

### Schema Definitions (Drizzle)

Use snake_case for field names so column names don't need to be redefined as strings.

### Testing

- Avoid mocks as much as possible
- Test actual implementation, do not duplicate logic into tests
- Tests cannot run from repo root; run from package dirs like `packages/opencode`.
- Always run `bun typecheck` from package directories, never `tsc` directly.

---

## 2. Variable Naming -- Real Examples

Single-word preference runs deep. These are real variable names from the codebase:

| Variable | Context | What a typical codebase would call it |
|----------|---------|--------------------------------------|
| `state` | in-memory service state object | `serviceState`, `currentState` |
| `pending` | `Map<ID, PendingEntry>` of unresolved requests | `pendingRequests`, `pendingMap` |
| `existing` | result of a `.get()` lookup | `existingEntry`, `foundItem` |
| `info` | typed request/response payload | `requestInfo`, `questionData` |
| `deferred` | Effect `Deferred` for async coordination | `deferredResult`, `responseDeferred` |
| `rule` | single permission rule from evaluation | `matchedRule`, `evaluatedRule` |
| `row` | database row from Drizzle query | `dbRow`, `accountRow` |
| `decode` | `Schema.decodeUnknownSync(Info)` | `decoder`, `infoDecoder` |
| `norm` | normalized key (`key.replace(/\/+$/, "")`) | `normalizedKey` |
| `lock` | acquired lock reference | `acquiredLock`, `lockHandle` |
| `file` | path string to a file | `filePath`, `authFile` |
| `prefix` | joined token prefix for arity matching | `commandPrefix` |
| `query` | database query helper function | `executeQuery`, `dbQuery` |
| `tx` | database transaction helper | `transaction`, `dbTransaction` |
| `cfg` | resolved config object | `config`, `resolvedConfig` |
| `cache` | `ScopedCache` instance | `stateCache`, `instanceCache` |

Inline when used once:

```ts
// This codebase
const journal = await Bun.file(path.join(dir, "journal.json")).json()

// NOT this
const journalPath = path.join(dir, "journal.json")
const journal = await Bun.file(journalPath).json()
```

```ts
// This codebase
return prefixes[prefix] + "_" + timeBytes.toString("hex") + randomBase62(LENGTH - 12)

// NOT this
const hexPart = timeBytes.toString("hex")
const randomPart = randomBase62(LENGTH - 12)
return prefixes[prefix] + "_" + hexPart + randomPart
```

---

## 3. Control Flow -- Real Patterns

### No-else, early return

From `permission/index.ts` -- the `reply` method:

```ts
const reply = Effect.fn("Permission.reply")(function* (input: z.infer<typeof ReplyInput>) {
  const { approved, pending } = yield* InstanceState.get(state)
  const existing = pending.get(input.requestID)
  if (!existing) return                          // early return, no else

  pending.delete(input.requestID)
  void Bus.publish(Event.Replied, {
    sessionID: existing.info.sessionID,
    requestID: existing.info.id,
    reply: input.reply,
  })

  if (input.reply === "reject") {
    yield* Deferred.fail(
      existing.deferred,
      input.message ? new CorrectedError({ feedback: input.message }) : new RejectedError(),
    )
    // cascade rejections...
    return                                       // early return from branch
  }

  yield* Deferred.succeed(existing.deferred, undefined)
  if (input.reply === "once") return             // early return again
  // "always" logic follows...
})
```

### Ternary over reassignment

From `permission/index.ts`:

```ts
input.message ? new CorrectedError({ feedback: input.message }) : new RejectedError()
```

From `effect/run-service.ts`:

```ts
const getRuntime = () => (rt ??= ManagedRuntime.make(layer, { memoMap }))
```

From `effect/cross-spawn-spawner.ts`:

```ts
const pipe = (x: NodeChildProcess.IOType | undefined) =>
  process.platform === "win32" && x === "pipe" ? "overlapped" : x
```

### Guard-clause chains (no else, no nesting)

From `util/filesystem.ts`:

```ts
export function windowsPath(p: string): string {
  // Each condition returns early, no else chains
}
```

From `permission/index.ts`:

```ts
function expand(pattern: string): string {
  if (pattern.startsWith("~/")) return os.homedir() + pattern.slice(1)
  if (pattern === "~") return os.homedir()
  if (pattern.startsWith("$HOME/")) return os.homedir() + pattern.slice(5)
  if (pattern.startsWith("$HOME")) return os.homedir() + pattern.slice(5)
  return pattern
}
```

### Functional array methods over loops

From `question/index.ts`:

```ts
return Array.from(pending.values(), (x) => x.info)
```

From `permission/index.ts`:

```ts
const rules = rulesets.flat()
const match = rules.findLast(
  (rule) => Wildcard.match(permission, rule.permission) && Wildcard.match(pattern, rule.pattern),
)
return match ?? { action: "ask", permission, pattern: "*" }
```

From `permission/index.ts`:

```ts
ruleset.push(
  ...Object.entries(value).map(([pattern, action]) => ({ permission: key, pattern: expand(pattern), action })),
)
```

---

## 4. Import Conventions

### Ordering (observed across all modules)

```ts
// 1. Node.js builtins
import path from "path"
import os from "os"
import { randomBytes } from "crypto"

// 2. Effect ecosystem (effect, effect/unstable/*)
import { Deferred, Effect, Layer, Schema, ServiceMap } from "effect"

// 3. External packages
import z from "zod"
import launch from "cross-spawn"

// 4. Internal @/ absolute imports (deep -> shallow)
import { Bus } from "@/bus"
import { BusEvent } from "@/bus/bus-event"
import { InstanceState } from "@/effect/instance-state"
import { makeRuntime } from "@/effect/run-service"
import { SessionID, MessageID } from "@/session/schema"
import { Log } from "@/util/log"

// 5. Relative sibling imports (always last)
import { QuestionID } from "./schema"
```

### Key conventions

- `effect` imports are destructured from the main package: `{ Effect, Layer, Schema, ServiceMap }`
- `ServiceMap` specifically: `import * as ServiceMap from "effect/ServiceMap"` in infrastructure, but `{ ServiceMap }` from `"effect"` in modules
- Zod is always `import z from "zod"` (default import, lowercase `z`)
- Internal paths use `@/` prefix (configured in tsconfig): `@/bus`, `@/util/log`, `@/effect/run-service`
- Schema files import from sibling: `import { QuestionID } from "./schema"`
- SQL table files import from sibling: `import { AccountTable } from "./account.sql"`
- Never barrel imports. Always import from the specific file.

---

## 5. Namespace Shape -- Standard Anatomy

Every service module follows this exact structure inside `export namespace X { }`:

```ts
export namespace Question {
  // ---- Private setup ----
  const log = Log.create({ service: "question" })

  // ---- Zod schemas (API-facing) ----
  export const Option = z.object({ ... }).meta({ ref: "QuestionOption" })
  export type Option = z.infer<typeof Option>

  export const Info = z.object({ ... }).meta({ ref: "QuestionInfo" })
  export type Info = z.infer<typeof Info>

  export const Request = z.object({ ... }).meta({ ref: "QuestionRequest" })
  export type Request = z.infer<typeof Request>

  // ---- Bus events ----
  export const Event = {
    Asked: BusEvent.define("question.asked", Request),
    Replied: BusEvent.define("question.replied", z.object({ ... })),
  }

  // ---- Error classes (Effect Schema) ----
  export class RejectedError extends Schema.TaggedErrorClass<RejectedError>()(
    "QuestionRejectedError", {}
  ) {
    override get message() {
      return "The user dismissed this question"
    }
  }

  // ---- Private types ----
  interface PendingEntry {
    info: Request
    deferred: Deferred.Deferred<Answer[], RejectedError>
  }

  interface State {
    pending: Map<QuestionID, PendingEntry>
  }

  // ---- Service interface ----
  export interface Interface {
    readonly ask: (...) => Effect.Effect<Answer[], RejectedError>
    readonly reply: (...) => Effect.Effect<void>
    readonly reject: (...) => Effect.Effect<void>
    readonly list: () => Effect.Effect<Request[]>
  }

  // ---- Service tag ----
  export class Service extends ServiceMap.Service<Service, Interface>()(
    "@opencode/Question"
  ) {}

  // ---- Layer (the implementation) ----
  export const layer = Layer.effect(
    Service,
    Effect.gen(function* () {
      const state = yield* InstanceState.make<State>(
        Effect.fn("Question.state")(function* () { ... })
      )

      const ask = Effect.fn("Question.ask")(function* (input) { ... })
      const reply = Effect.fn("Question.reply")(function* (input) { ... })
      const reject = Effect.fn("Question.reject")(function* (requestID) { ... })
      const list = Effect.fn("Question.list")(function* () { ... })

      return Service.of({ ask, reply, reject, list })
    }),
  )

  // ---- Runtime bridge ----
  const { runPromise } = makeRuntime(Service, layer)

  // ---- Public async facade ----
  export async function ask(input) {
    return runPromise((s) => s.ask(input))
  }

  export async function reply(input) {
    return runPromise((s) => s.reply(input))
  }
}
```

### The 5-layer cake (never skip a layer)

| Layer | Purpose |
|-------|---------|
| **Interface** | Pure method signatures with `Effect.Effect<A, E>` returns |
| **Service class** | `ServiceMap.Service<Self, Interface>()("@opencode/Name")` |
| **Layer** | `Layer.effect(Service, Effect.gen(function* () { ... return Service.of({...}) }))` |
| **makeRuntime** | `const { runPromise } = makeRuntime(Service, layer)` |
| **Public facade** | `export async function name() { return runPromise((s) => s.name()) }` |

### Namespace naming

- Service tag: `"@opencode/Question"`, `"@opencode/Permission"`, `"@opencode/Auth"`
- Effect.fn tracing: `"Question.ask"`, `"Permission.reply"`, `"Auth.get"`
- Log service tag: `Log.create({ service: "question" })`
- Bus event names: `"question.asked"`, `"permission.replied"` (dot-separated lowercase)

---

## 6. Schema Conventions

### Zod schemas -- API-facing

Always attach `.meta({ ref })` for codegen. Schema and type share the same name.

```ts
export const Option = z
  .object({
    label: z.string().describe("Display text (1-5 words, concise)"),
    description: z.string().describe("Explanation of choice"),
  })
  .meta({ ref: "QuestionOption" })
export type Option = z.infer<typeof Option>
```

```ts
export const Action = z.enum(["allow", "deny", "ask"]).meta({
  ref: "PermissionAction",
})
export type Action = z.infer<typeof Action>
```

### Effect Schema -- internal domain types

```ts
export class Oauth extends Schema.Class<Oauth>("OAuth")({
  type: Schema.Literal("oauth"),
  refresh: Schema.String,
  access: Schema.String,
  expires: Schema.Number,
  accountId: Schema.optional(Schema.String),
}) {}
```

### Branded types -- two patterns

**Newtype** (for IDs with ascending/descending generation):

```ts
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

**Schema.brand** (for simple branded primitives):

```ts
export const AccountID = Schema.String.pipe(
  Schema.brand("AccountID"),
  withStatics((s) => ({ make: (id: string) => s.makeUnsafe(id) })),
)
export type AccountID = Schema.Schema.Type<typeof AccountID>
```

### Drizzle tables -- snake_case, $type for brands

```ts
export const AccountTable = sqliteTable("account", {
  id: text().$type<AccountID>().primaryKey(),
  email: text().notNull(),
  url: text().notNull(),
  access_token: text().$type<AccessToken>().notNull(),
  refresh_token: text().$type<RefreshToken>().notNull(),
  token_expiry: integer(),
  ...Timestamps,
})
```

Never do this:

```ts
// WRONG -- camelCase field with string column name
projectID: text("project_id").notNull(),
createdAt: integer("created_at").notNull(),
```

Always do this:

```ts
// RIGHT -- snake_case field name matches SQL column automatically
project_id: text().notNull(),
created_at: integer().notNull(),
```

### Error classes

```ts
export class RejectedError extends Schema.TaggedErrorClass<RejectedError>()(
  "QuestionRejectedError",
  {},
) {
  override get message() {
    return "The user dismissed this question"
  }
}
```

```ts
export class DeniedError extends Schema.TaggedErrorClass<DeniedError>()(
  "PermissionDeniedError",
  { ruleset: Schema.Any },
) {
  override get message() {
    return `The user has specified a rule which prevents you from using this specific tool call. Here are some of the relevant rules ${JSON.stringify(this.ruleset)}`
  }
}
```

---

## 7. Things That Compile But Get Rejected in Review

### Using `else`

```ts
// REJECTED
if (condition) return 1
else return 2

// ACCEPTED
if (condition) return 1
return 2
```

### Destructuring when dot notation works

```ts
// REJECTED
const { pending } = yield* InstanceState.get(state)

// ACCEPTED (when accessing multiple times, the codebase does permit destructuring from yield*)
const pending = (yield* InstanceState.get(state)).pending
```

Note: the codebase does use destructuring from `yield*` when accessing multiple fields:

```ts
// ACCEPTED -- multiple fields from same source
const { approved, pending } = yield* InstanceState.get(state)
```

### Introducing intermediate variables for single-use values

```ts
// REJECTED
const lockfile = path.join(dir, Hash.fast(key) + ".lock")
const lock = await acquireLockDir(lockfile, ...)

// ACCEPTED (if lockfile is only used once)
const lock = await acquireLockDir(path.join(dir, Hash.fast(key) + ".lock"), ...)
```

### Using `let` when `const` + ternary works

```ts
// REJECTED
let foo
if (condition) foo = 1
else foo = 2

// ACCEPTED
const foo = condition ? 1 : 2
```

### Forgetting `.meta({ ref })` on Zod schemas used in the API

```ts
// REJECTED -- no ref means no stable name in generated SDK
export const Info = z.object({ question: z.string() })

// ACCEPTED
export const Info = z.object({ question: z.string() }).meta({ ref: "QuestionInfo" })
```

### Using camelCase in Drizzle table fields

```ts
// REJECTED
projectId: text("project_id").notNull(),

// ACCEPTED
project_id: text().notNull(),
```

### Creating multi-word names when single-word is clear

```ts
// REJECTED
const requestID = QuestionID.ascending()
const pendingMap = new Map()

// ACCEPTED
const id = QuestionID.ascending()
const pending = new Map()
```

### Forgetting `Effect.fn("Namespace.method")` wrapper

```ts
// REJECTED -- no tracing
const ask = function* (input) { ... }

// ACCEPTED
const ask = Effect.fn("Question.ask")(function* (input) { ... })
```

### Forgetting shared `memoMap` in `makeRuntime`

```ts
// REJECTED -- each runtime creates isolated layer instances
export const memoMap = Layer.makeMemoMapUnsafe() // must exist at module level
// ...
ManagedRuntime.make(layer)                       // missing { memoMap }

// ACCEPTED
ManagedRuntime.make(layer, { memoMap })
```

### Using `Effect.tryPromise` where `Effect.try` suffices

```ts
// REJECTED -- Database.use is synchronous
const query = (f) =>
  Effect.tryPromise({
    try: async () => Database.use(f),
    catch: (cause) => new Error(cause),
  })

// ACCEPTED
const query = (f) =>
  Effect.try({
    try: () => Database.use(f),
    catch: (cause) => new RepoError({ message: "Database operation failed", cause }),
  })
```

### Missing `void` on fire-and-forget Bus.publish

```ts
// ACCEPTED (both forms appear in the codebase)
Bus.publish(Event.Asked, info)
void Bus.publish(Event.Asked, info)
```

### Using `Math.random()` for IDs

```ts
// REJECTED
const id = Math.random().toString(36)

// ACCEPTED
const bytes = randomBytes(length)  // crypto.randomBytes
```

### Not wrapping ScopedCache access in `Effect.suspend`

```ts
// REJECTED -- directory captured at construction, not execution
export const get = (self) => ScopedCache.get(self.cache, Instance.directory)

// ACCEPTED
export const get = (self) => Effect.suspend(() => ScopedCache.get(self.cache, Instance.directory))
```

### Using `Promise.all` for disposers (one failure kills the rest)

```ts
// REJECTED
await Promise.all([...disposers].map((d) => d(directory)))

// ACCEPTED
await Promise.allSettled([...disposers].map((d) => d(directory)))
```

### Explicit type annotations where inference works

```ts
// REJECTED
const id: QuestionID = QuestionID.ascending()
const pending: Map<QuestionID, PendingEntry> = new Map<QuestionID, PendingEntry>()

// ACCEPTED
const id = QuestionID.ascending()
const pending = new Map<QuestionID, PendingEntry>()
```

### Using `for` loops when functional methods work

```ts
// REJECTED
const infos = []
for (const entry of pending.values()) {
  infos.push(entry.info)
}

// ACCEPTED
return Array.from(pending.values(), (x) => x.info)
```
