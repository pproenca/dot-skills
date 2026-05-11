---
name: effect-ts
description: >
  Use this skill whenever writing, reviewing, debugging, or refactoring TypeScript code that uses
  the Effect-TS library. Trigger when you see imports from `effect`, `effect/*`, or any `@effect/*`
  scoped package (schema, platform, sql, opentelemetry, cli, cluster, rpc, vitest). Trigger on
  Effect-specific constructs: Effect.gen generators, Schema.Struct/Schema.Class definitions,
  Layer/Context.Tag/Service patterns, Effect.pipe pipelines, Data.TaggedError/Data.Class error
  types, Ref/Queue/PubSub/Deferred concurrency primitives, Match module, Config providers,
  Scope/Exit/Cause/Runtime patterns, or any code using Effect's typed error channel (E parameter).
  Also trigger when the user asks about Effect patterns, migration from Promises/fp-ts/neverthrow
  to Effect, or how to structure an Effect application. Do NOT trigger for React's useEffect,
  Redux side effects, or general English usage of "effect" unless the context clearly involves
  the Effect-TS library.
---

# Effect TypeScript Best Practices

Effect is a TypeScript library for building complex, type-safe applications with structured
error handling, dependency injection via services/layers, fiber-based concurrency, and
resource safety.

## When to Apply

- Writing or reviewing TypeScript code that imports from `effect`, `@effect/schema`, or `@effect/platform`
- Implementing typed error handling with `Effect<Success, Error, Requirements>`
- Building services and layers for dependency injection
- Working with Schema for data validation, decoding, and transformation
- Using fiber-based concurrency (queues, semaphores, PubSub, deferred)
- Processing data with Stream and Sink
- Migrating from Promises, fp-ts, neverthrow, or ZIO to Effect

## How to Use

This skill is organized by domain. Read the relevant reference file for the area you're working in.

### Read First: The Paradigm

**Always read this before diving into API references**, especially when refactoring existing
code to use Effect or writing new Effect services:

| Reference | When to Read |
|-----------|-------------|
| [**Think in Effect: The Paradigm Shift**](references/getting-paradigm.md) | **Before any other reference.** Mental model shifts, refactoring recipes, anti-patterns, application architecture. Read this to understand HOW to think in Effect — the other files teach WHAT to type. |

### Core Foundations

| Reference | When to Read |
|-----------|-------------|
| [Getting Started](references/getting-started.md) | Creating the Effect type, pipelines, generators, running effects |
| [Error Management](references/error-management.md) | Typed errors, recovery, retrying, timeouts, sandboxing |
| [Core Concepts](references/core-concepts.md) | Request batching, configuration management, runtime system |

### Data & Validation

| Reference | When to Read |
|-----------|-------------|
| [Data Types](references/data-types.md) | Option, Either, Cause, Chunk, DateTime, Duration, Exit, Data |
| [Schema Basics](references/schema-basics.md) | Schema intro, basic usage, classes, constructors, effect data types |
| [Schema Advanced](references/schema-advanced.md) | Transformations, filters, annotations, error formatting, JSON Schema output |

### Architecture & Dependencies

| Reference | When to Read |
|-----------|-------------|
| [Requirements Management](references/req-management.md) | Services, Layers, dependency injection, layer memoization |
| [Resource Management](references/resource-management.md) | Scope, safe resource acquisition/release, caching |
| [State Management](references/state-management.md) | Ref, SubscriptionRef, SynchronizedRef for concurrent state |

### Concurrency & Streaming

| Reference | When to Read |
|-----------|-------------|
| [Concurrency](references/conc-concurrency.md) | Fibers, Deferred, Latch, PubSub, Queue, Semaphore |
| [Streams and Sinks](references/streams-and-sinks.md) | Creating, consuming, transforming streams; sink operations |
| [Scheduling](references/sched-scheduling.md) | Built-in schedules, cron, combinators, repetition |

### Platform & Observability

| Reference | When to Read |
|-----------|-------------|
| [Platform](references/plat-platform.md) | FileSystem, Command, Terminal, KeyValueStore, Path |
| [Observability](references/obs-observability.md) | Logging, metrics, tracing, Supervisor |
| [Testing](references/test-testing.md) | TestClock for time simulation; for service mocking and layer testing, see [Requirements Management](references/req-management.md) |

### Style, AI & Migration

| Reference | When to Read |
|-----------|-------------|
| [Code Style](references/code-style.md) | Branded types, pattern matching, dual APIs, guidelines, traits |
| [AI Integration](references/ai-integration.md) | Effect AI packages for LLM tool use and execution planning |
| [Micro](references/micro-module.md) | Lightweight Effect alternative for smaller bundles |
| [Migration Guides](references/migration-guides.md) | Coming from Promises, fp-ts, neverthrow, or ZIO |

## Quick Reference — Common Patterns

### The Effect Type
```ts
//         ┌─── Success type
//         │        ┌─── Error type
//         │        │      ┌─── Required dependencies
//         ▼        ▼      ▼
Effect<Success, Error, Requirements>
```

### Creating Effects
```ts
import { Effect } from "effect"

// From sync values
const succeed = Effect.succeed(42)
const fail = Effect.fail(new Error("oops"))

// From sync code that may throw
const sync = Effect.try(() => JSON.parse(data))

// From promises
const async = Effect.tryPromise(() => fetch(url))

// From generators (recommended for complex flows)
const program = Effect.gen(function* () {
  const user = yield* getUser(id)
  const todos = yield* getTodos(user.id)
  return { user, todos }
})
```

### Running Effects
```ts
// Async (returns Promise)
Effect.runPromise(program)

// With full Exit information
Effect.runPromiseExit(program)

// Sync (throws on async)
Effect.runSync(program)
```

### Typed Errors
```ts
import { Data, Effect } from "effect"

class NotFound extends Data.TaggedError("NotFound")<{
  readonly id: string
}> {}

class Unauthorized extends Data.TaggedError("Unauthorized")<{}> {}

// Error type is tracked: Effect<User, NotFound | Unauthorized>
const getUser = (id: string) =>
  Effect.gen(function* () {
    // ...
  })
```

### Services and Layers
```ts
import { Context, Effect, Layer } from "effect"

// Define a service
class UserRepo extends Context.Tag("UserRepo")<
  UserRepo,
  { readonly findById: (id: string) => Effect.Effect<User, NotFound> }
>() {}

// Use in effects — adds to Requirements channel
const program = Effect.gen(function* () {
  const repo = yield* UserRepo
  return yield* repo.findById("1")
})

// Implement with a Layer
const UserRepoLive = Layer.succeed(UserRepo, {
  findById: (id) => Effect.succeed({ id, name: "Alice" })
})

// Provide and run
program.pipe(Effect.provide(UserRepoLive), Effect.runPromise)
```

### Schema Validation
```ts
import { Schema } from "effect"

const User = Schema.Struct({
  id: Schema.Number,
  name: Schema.String,
  email: Schema.String.pipe(Schema.pattern(/@/))
})

type User = typeof User.Type

// Decode (parse + validate)
const decode = Schema.decodeUnknownSync(User)
const user = decode({ id: 1, name: "Alice", email: "a@b.com" })
```

### Pipelines
```ts
import { Effect, pipe } from "effect"

// Data-last (pipe style)
const result = pipe(
  getTodos,
  Effect.map((todos) => todos.filter((t) => !t.done)),
  Effect.flatMap((active) => sendNotification(active.length)),
  Effect.catchTag("NetworkError", () => Effect.succeed("offline"))
)

// Fluent (method style)
const result2 = getTodos.pipe(
  Effect.map((todos) => todos.filter((t) => !t.done)),
  Effect.flatMap((active) => sendNotification(active.length))
)
```

## Gotchas

See [gotchas.md](gotchas.md) for known failure points.
