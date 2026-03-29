---
title: "Think in Effect: The Paradigm Shift"
impact: CRITICAL
impactDescription: "Transforms agent output from 'code that uses Effect APIs' to 'idiomatic Effect code' — the difference between compiling and being maintainable"
tags: getting, paradigm, mental-model, refactoring, architecture
---

# Think in Effect: The Paradigm Shift

Effect is not a utility library you add to existing code. It is a different way of writing
programs, inspired by Scala's ZIO, Haskell's IO monad, and algebraic effects research. Using
Effect APIs without understanding the paradigm produces code that compiles but misses every
architectural benefit the library provides.

**Read this file BEFORE any API reference.** It teaches you how to think. The other reference
files teach you what to type.

---

## The Five Mental Model Shifts

### 1. Programs Are Values, Not Instructions

In typical TypeScript, code executes as you write it. A `fetch()` call fires immediately.
A `new Promise(...)` starts running the moment it's constructed.

In Effect, code is a **description** of what should happen. Nothing executes until you
explicitly run it at the program boundary with `Effect.runPromise` or `Effect.runSync`.

This is the single most important concept. Everything else follows from it.

```ts
// This does NOT make an HTTP call. It describes one.
const fetchUser = Effect.tryPromise(() => fetch("/api/user"))

// You can pass it around, compose it, retry it, race it — nothing has happened yet.
const withRetry = Effect.retry(fetchUser, { times: 3 })
const withTimeout = Effect.timeout(withRetry, "5 seconds")

// NOW it executes — at the boundary, once, with all the composition applied.
Effect.runPromise(withTimeout)
```

**Why this matters for your code:** Place `runPromise`/`runSync` at the outermost edge of
your application (the `main` function, the HTTP request handler, the CLI entry point). Never
in the middle of business logic. If you're calling `runPromise` inside a service, you've
broken the paradigm — you're executing a sub-program instead of composing descriptions.

### 2. The Type Signature Is the Architecture

`Effect<Success, Error, Requirements>` is not just a return type — it's a function's
complete contract:

```ts
//         What it produces     What can go wrong     What it needs to run
//                ▼                    ▼                      ▼
Effect<     User,              NotFound | DbError,      UserRepo | Logger     >
```

- **A (Success):** The value produced on success. Same as a Promise's resolved type.
- **E (Error):** Every failure mode, tracked by the compiler. Not `unknown`, not `Error` —
  the exact union of things that can go wrong. If you add a new failure mode, every caller's
  type changes, forcing you to handle it.
- **R (Requirements):** Every dependency needed to run this effect. Not imported globally —
  declared in the type. If you need a database, the type says so. If you need a logger, the
  type says so.

**Why this matters for your code:** When you write a function that returns
`Effect<User, NotFound | DbError, UserRepo>`, you've simultaneously written:
- The function's return type
- Its error documentation
- Its dependency manifest

The compiler enforces all three. You cannot run this effect without providing `UserRepo`.
You cannot ignore `NotFound`. This is architecture enforced by types, not by convention.

### 3. Dependencies Are Declared, Not Imported

Typical TypeScript uses imports for dependencies:

```ts
// Typical TS — dependency is a global import, invisible in the type
import { prisma } from "./db"

export const getUser = async (id: string) => {
  return prisma.user.findUnique({ where: { id } })
}
// Caller has no idea this touches a database. Can't test without mocking the import.
```

Effect declares dependencies in the R channel and provides them via `Layer`:

```ts
// Effect — dependency is declared in the type, provided at the boundary
class UserRepo extends Context.Tag("UserRepo")<UserRepo, {
  readonly findById: (id: string) => Effect.Effect<User, NotFound>
}>() {}

export const getUser = (id: string) =>
  UserRepo.pipe(Effect.flatMap((repo) => repo.findById(id)))
// Type: Effect<User, NotFound, UserRepo>
// Caller SEES the dependency. Tests provide a different UserRepo.
```

This is TypeScript's version of **tagless final** from Scala. You program against
interfaces (`Context.Tag`), provide implementations at the edge (`Layer`), and the
compiler ensures everything is wired before the program runs.

**The architectural pattern:**

```text
Business logic (pure effects, declares R)
       ↓ composed with
Service interfaces (Context.Tag definitions)
       ↓ implemented by
Layers (concrete implementations — DB, HTTP, cache)
       ↓ provided at
Program boundary (main / request handler / test harness)
```

### 4. Errors Are Data, Not Exceptions

Typical TypeScript scatters `throw` and `try/catch` throughout the codebase. Error types
are unknown, catch blocks are defensive, and it's impossible to know what a function might
throw without reading its entire implementation.

Effect treats errors as **typed data** flowing through the E channel:

```ts
// Define error types FIRST — before the happy path
class NotFound extends Data.TaggedError("NotFound")<{
  readonly entity: string
  readonly id: string
}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{
  readonly field: string
  readonly message: string
}> {}

// Errors flow through the type system. The caller sees: Effect<User, NotFound | ValidationError>
const getUser = (id: string) =>
  Effect.gen(function* () {
    if (!isValidId(id)) yield* new ValidationError({ field: "id", message: "Invalid format" })
    const user = yield* findUser(id)
    if (!user) yield* new NotFound({ entity: "User", id })
    return user
  })
```

**The principle: define error types first, handle them last.**

Don't catch errors inside services. Let them flow outward through the E channel. Handle
them at boundaries (HTTP handler → map to status codes, CLI → map to exit codes, main →
log and exit). This is the opposite of defensive programming — it's letting the type system
do the work.

```ts
// At the HTTP boundary — the only place errors are handled
const handler = pipe(
  getUser(id),
  Effect.catchTag("NotFound", (e) => HttpResponse.json({ error: "Not found" }, { status: 404 })),
  Effect.catchTag("ValidationError", (e) => HttpResponse.json({ error: e.message }, { status: 400 }))
)
```

### 5. Compose Small Things, Don't Orchestrate Big Things

Typical TypeScript programs are orchestrated step-by-step:

```ts
// Imperative orchestration — hard to reuse, test, or modify
async function processOrder(orderId: string) {
  const order = await getOrder(orderId)
  const user = await getUser(order.userId)
  await validateInventory(order.items)
  const payment = await chargeCard(user.paymentMethod, order.total)
  await sendConfirmation(user.email, order, payment)
  return { order, payment }
}
```

Effect programs are built by composing small, reusable pieces:

```ts
// Each step is an independent, testable, retryable effect
const processOrder = (orderId: string) =>
  Effect.gen(function* () {
    const order = yield* OrderService.pipe(Effect.flatMap((s) => s.get(orderId)))
    const user = yield* UserService.pipe(Effect.flatMap((s) => s.get(order.userId)))
    yield* InventoryService.pipe(Effect.flatMap((s) => s.validate(order.items)))
    const payment = yield* PaymentService.pipe(Effect.flatMap((s) => s.charge(user.paymentMethod, order.total)))
    yield* NotificationService.pipe(Effect.flatMap((s) => s.sendConfirmation(user.email, order, payment)))
    return { order, payment }
  })
// Type tells you everything: Effect<OrderResult, OrderNotFound | UserNotFound | InsufficientStock | PaymentFailed | EmailError, OrderService | UserService | InventoryService | PaymentService | NotificationService>
```

Each service is independently testable, replaceable, and composable. The type signature
is the dependency graph and error manifest combined.

---

## Refactoring Recipes

When converting existing TypeScript code to Effect, apply these transformations
systematically. The order matters — start with error types, then services, then wiring.

### Recipe 1: async/await → Effect.gen

**Incorrect (direct async/await translation that misses the paradigm):**

```ts
// Just wrapping async in Effect — misses dependency injection and typed errors
const getUser = (id: string) =>
  Effect.tryPromise(async () => {
    const res = await fetch(`/api/users/${id}`)
    if (!res.ok) throw new Error("Failed")
    return res.json()
  })
```

**Correct (idiomatic Effect with typed errors and services):**

```ts
class UserNotFound extends Data.TaggedError("UserNotFound")<{ readonly id: string }> {}
class UserApiError extends Data.TaggedError("UserApiError")<{ readonly status: number }> {}

class UserApi extends Context.Tag("UserApi")<UserApi, {
  readonly getById: (id: string) => Effect.Effect<User, UserNotFound | UserApiError>
}>() {}

// Implementation in a Layer
const UserApiLive = Layer.succeed(UserApi, {
  getById: (id) =>
    Effect.gen(function* () {
      const res = yield* Effect.tryPromise({
        try: () => fetch(`/api/users/${id}`),
        catch: () => new UserApiError({ status: 0 })
      })
      if (res.status === 404) return yield* new UserNotFound({ id })
      if (!res.ok) return yield* new UserApiError({ status: res.status })
      return yield* Effect.tryPromise({
        try: () => res.json() as Promise<User>,
        catch: () => new UserApiError({ status: res.status })
      })
    })
})
```

### Recipe 2: throw → Effect.fail with tagged errors

**Incorrect (throw inside Effect — creates untyped defects):**

```ts
const divide = (a: number, b: number) =>
  Effect.sync(() => {
    if (b === 0) throw new Error("Division by zero") // Untyped defect!
    return a / b
  })
// Type: Effect<number, never, never> — the error is INVISIBLE
```

**Correct (Effect.fail with tagged error — tracked in the type):**

```ts
class DivisionByZero extends Data.TaggedError("DivisionByZero")<{}> {}

const divide = (a: number, b: number): Effect.Effect<number, DivisionByZero> =>
  b === 0 ? Effect.fail(new DivisionByZero()) : Effect.succeed(a / b)
// Type: Effect<number, DivisionByZero, never> — error is VISIBLE
```

### Recipe 3: Global imports → Context.Tag + Layer

**Incorrect (importing singletons — untestable, invisible dependencies):**

```ts
import { PrismaClient } from "@prisma/client"
const prisma = new PrismaClient()

export const getUser = (id: string) =>
  Effect.tryPromise(() => prisma.user.findUnique({ where: { id } }))
// Type: Effect<User | null, UnknownException, never>
// The database dependency is INVISIBLE in the type
```

**Correct (Context.Tag service — testable, explicit dependency):**

```ts
class Database extends Context.Tag("Database")<Database, {
  readonly user: {
    readonly findById: (id: string) => Effect.Effect<User, UserNotFound>
  }
}>() {}

export const getUser = (id: string) =>
  Database.pipe(Effect.flatMap((db) => db.user.findById(id)))
// Type: Effect<User, UserNotFound, Database>
// The database dependency is VISIBLE and SWAPPABLE

// Production layer
const DatabaseLive = Layer.effect(Database,
  Effect.gen(function* () {
    const prisma = new PrismaClient()
    return {
      user: {
        findById: (id) =>
          Effect.tryPromise({ try: () => prisma.user.findUnique({ where: { id } }), catch: () => new UserNotFound({ id }) })
          .pipe(Effect.flatMap((u) => u ? Effect.succeed(u) : Effect.fail(new UserNotFound({ id }))))
      }
    }
  })
)

// Test layer — no database needed
const DatabaseTest = Layer.succeed(Database, {
  user: {
    findById: (id) =>
      id === "1" ? Effect.succeed({ id: "1", name: "Alice", email: "a@b.com" }) : Effect.fail(new UserNotFound({ id }))
  }
})
```

### Recipe 4: try/finally → Effect.acquireRelease

**Incorrect (manual cleanup that can leak on interruption):**

```ts
const withConnection = Effect.gen(function* () {
  const conn = yield* Effect.tryPromise(() => pool.connect())
  try {
    return yield* doWork(conn)
  } finally {
    conn.release() // Not Effect-aware — ignores interruption, not composable
  }
})
```

**Correct (acquireRelease with guaranteed cleanup):**

```ts
const withConnection = Effect.acquireUseRelease(
  Effect.tryPromise({ try: () => pool.connect(), catch: (e) => new ConnectionError({ cause: e }) }),
  (conn) => doWork(conn),
  (conn) => Effect.sync(() => conn.release())  // Guaranteed to run, even on fiber interruption
)
```

### Recipe 5: Promise.all → Effect.all with structured concurrency

**Incorrect (Promise.all without cancellation or error tracking):**

```ts
const [user, orders, prefs] = await Promise.all([
  getUser(id),        // If this fails...
  getOrders(id),      // ...this keeps running wastefully
  getPreferences(id)  // ...and so does this
])
```

**Correct (Effect.all with automatic interruption):**

```ts
const [user, orders, prefs] = yield* Effect.all(
  [getUser(id), getOrders(id), getPreferences(id)],
  { concurrency: "unbounded" }
)
// If getUser fails, the other two are AUTOMATICALLY interrupted.
// Error type: UserNotFound | OrderError | PrefError (full union, tracked)
```

### Recipe 6: Class with injected deps → Layer.effect

**Incorrect (class-based DI — constructor injection, new keyword):**

```ts
class OrderService {
  constructor(
    private db: Database,
    private payment: PaymentGateway,
    private mailer: Mailer
  ) {}

  async process(orderId: string) { /* ... */ }
}
// Wiring: new OrderService(new Database(...), new PaymentGateway(...), new Mailer(...))
```

**Correct (Layer composition — no classes, no new, no constructors):**

```ts
class OrderService extends Context.Tag("OrderService")<OrderService, {
  readonly process: (orderId: string) => Effect.Effect<Order, OrderError>
}>() {}

const OrderServiceLive = Layer.effect(OrderService,
  Effect.gen(function* () {
    const db = yield* Database
    const payment = yield* PaymentGateway
    const mailer = yield* Mailer
    return {
      process: (orderId) =>
        Effect.gen(function* () {
          const order = yield* db.getOrder(orderId)
          yield* payment.charge(order)
          yield* mailer.sendConfirmation(order)
          return order
        })
    }
  })
)

// Wiring: Layer composition, not constructor calls
const AppLive = OrderServiceLive.pipe(
  Layer.provide(Layer.merge(DatabaseLive, PaymentGatewayLive)),
  Layer.provide(MailerLive)
)
```

---

## Anti-Patterns

### Don't wrap everything in Effect

Only wrap at system boundaries (I/O, external APIs, database calls). Pure computation
stays as plain TypeScript:

```ts
// WRONG — unnecessary Effect wrapping
const add = (a: number, b: number) => Effect.succeed(a + b)

// RIGHT — plain function, used inside Effect.gen when needed
const add = (a: number, b: number) => a + b

const program = Effect.gen(function* () {
  const x = yield* getNumber()
  return add(x, 10)  // No yield* needed — it's just a value
})
```

### Don't call runPromise inside services

`runPromise` is the program boundary. Calling it inside a service breaks composition —
you lose error tracking, dependency tracking, and interruption:

```ts
// WRONG — runPromise inside a service breaks the Effect chain
const getUser = (id: string) =>
  Effect.tryPromise(() =>
    Effect.runPromise(someOtherEffect)  // Breaks composition!
  )

// RIGHT — compose effects, don't execute them
const getUser = (id: string) =>
  someOtherEffect.pipe(
    Effect.flatMap((result) => /* ... */)
  )
```

### Don't catch errors too early

Let errors flow through the E channel to the boundary. Catching inside services hides
failure modes from callers:

```ts
// WRONG — swallowing errors inside the service
const getUser = (id: string) =>
  findUser(id).pipe(
    Effect.catchAll(() => Effect.succeed(null))  // Caller can't distinguish "not found" from "db down"
  )

// RIGHT — let errors propagate, handle at the boundary
const getUser = (id: string) => findUser(id)
// Type: Effect<User, NotFound | DbError, Database>
// The HTTP handler decides: NotFound → 404, DbError → 500
```

### Don't use generic Error — use tagged errors

Every distinct failure mode gets its own error class. This enables precise handling
with `catchTag`:

```ts
// WRONG — generic Error, can't handle specifically
Effect.fail(new Error("user not found"))
Effect.fail(new Error("database connection failed"))
// Caller: catchAll or nothing. Can't distinguish the two.

// RIGHT — tagged errors, precise handling
class UserNotFound extends Data.TaggedError("UserNotFound")<{ readonly id: string }> {}
class DbConnectionFailed extends Data.TaggedError("DbConnectionFailed")<{ readonly host: string }> {}
// Caller: catchTag("UserNotFound", ...) vs catchTag("DbConnectionFailed", ...)
```

### Don't put business logic in Layer construction

Layers are for wiring — creating service instances and connecting dependencies. Business
logic belongs in the service methods, not in the Layer factory:

```ts
// WRONG — business logic in Layer
const UserServiceLive = Layer.effect(UserService,
  Effect.gen(function* () {
    const db = yield* Database
    const users = yield* db.loadAllUsers()  // Business logic in wiring!
    return { getUser: (id) => /* ... */ }
  })
)

// RIGHT — Layer only wires, service methods contain logic
const UserServiceLive = Layer.effect(UserService,
  Effect.gen(function* () {
    const db = yield* Database
    return {
      getUser: (id) => db.findUser(id),        // Logic here
      listUsers: () => db.loadAllUsers()         // And here
    }
  })
)
```

---

## Application Architecture: The Onion

An idiomatic Effect application has a layered structure, like an onion:

```text
┌─────────────────────────────────────────────┐
│  Boundary (main / request handler)           │
│  - Effect.runPromise / Effect.runFork        │
│  - Layer.provide(AppLive)                    │
│  - Error → exit code / HTTP status mapping   │
├─────────────────────────────────────────────┤
│  Services (business logic)                   │
│  - Pure effects: Effect.gen, pipe, flatMap   │
│  - Declares R (dependencies via Context.Tag) │
│  - Declares E (typed errors via TaggedError) │
│  - NO imports of implementations             │
│  - NO runPromise / runSync                   │
├─────────────────────────────────────────────┤
│  Service Interfaces (Context.Tag)            │
│  - Defines the contract                      │
│  - Typed methods returning Effects           │
│  - No implementation details                 │
├─────────────────────────────────────────────┤
│  Implementations (Layers)                    │
│  - Layer.succeed / Layer.effect              │
│  - Concrete I/O: database, HTTP, filesystem  │
│  - Composed with Layer.merge / Layer.provide │
├─────────────────────────────────────────────┤
│  Error Types (Data.TaggedError)              │
│  - Defined per domain concept                │
│  - Shared across services                    │
│  - Hierarchical when needed                  │
└─────────────────────────────────────────────┘
```

**Reading order when building an Effect application:**

1. Define error types (`Data.TaggedError` for each failure mode)
2. Define service interfaces (`Context.Tag` with typed method signatures)
3. Write business logic (effects that use services, declare errors)
4. Implement services (`Layer.effect` with concrete I/O)
5. Compose layers (`Layer.merge`, `Layer.provide`)
6. Wire at the boundary (`Effect.provide(AppLive)`, `Effect.runPromise`)

**Reading order when refactoring existing code to Effect:**

1. Identify all error cases → create `Data.TaggedError` for each
2. Identify all external dependencies (DB, HTTP, cache, config) → create `Context.Tag` for each
3. Rewrite functions as effects returning `Effect<A, E, R>`
4. Replace `throw` with `Effect.fail`, `try/catch` with `catchTag`
5. Replace imports with service access via `yield* ServiceTag`
6. Create `Layer` implementations for each service
7. Compose all layers and provide at the entry point
8. Move `runPromise` to the outermost boundary

---

## When to Break the Rules

These patterns are defaults, not absolutes. Pragmatic exceptions exist:

- **Small scripts**: A 50-line CLI tool doesn't need full service/layer architecture. Use
  `Effect.gen` with direct calls and `Effect.runPromise` at the top.
- **Interop boundaries**: When calling Effect code from non-Effect code (e.g., an Express
  route handler), `runPromise` at that boundary is correct.
- **Performance-critical inner loops**: Pure computation in hot loops should stay as plain
  TypeScript, not wrapped in Effect.
- **Gradual adoption**: You can use Effect for new code while keeping existing code as-is.
  Wrap the boundary, don't rewrite everything at once.

The test: if adding Effect indirection doesn't buy you typed errors, testable dependencies,
or composable retries/timeouts, it's just ceremony. Skip it for that specific case.
