---
title: "Migration Guides"
impact: LOW
impactDescription: "Eases adoption from other libraries — covers migration from Promise, fp-ts, neverthrow, ZIO"
tags: migration, promises, fp-ts, neverthrow
---
# [Coming From ZIO](https://effect.website/docs/additional-resources/coming-from-zio/)

## Overview

If you are coming to Effect from ZIO, there are a few differences to be aware of.

## Environment

In Effect, we represent the environment required to run an effect workflow as a **union** of services:

**Example** (Defining the Environment with a Union of Services)

```ts

interface IOError {
  readonly _tag: "IOError"
}

interface HttpError {
  readonly _tag: "HttpError"
}

interface Console {
  readonly log: (msg: string) => void
}

interface Logger {
  readonly log: (msg: string) => void
}

type Response = Record<string, string>

// `R` is a union of `Console` and `Logger`
type Http = Effect.Effect<Response, IOError | HttpError, Console | Logger>
```

This may be confusing to folks coming from ZIO, where the environment is represented as an **intersection** of services:

```scala
type Http = ZIO[Console with Logger, IOError, Response]
```

## Rationale

The rationale for using a union to represent the environment required by an `Effect` workflow boils down to our desire to remove `Has` as a wrapper for services in the environment (similar to what was achieved in ZIO 2.0).

To be able to remove `Has` from Effect, we had to think a bit more structurally given that TypeScript is a structural type system. In TypeScript, if you have a type `A & B` where there is a structural conflict between `A` and `B`, the type `A & B` will reduce to `never`.

**Example** (Intersection Type Conflict)

```ts
interface A {
  readonly prop: string
}

interface B {
  readonly prop: number
}

// @errors: 2322
const ab: A & B = {
  prop: ""
}
```

In previous versions of Effect, intersections were used for representing an environment with multiple services. The problem with using intersections (i.e. `A & B`) is that there could be multiple services in the environment that have functions and properties named in the same way. To remedy this, we wrapped services in the `Has` type (similar to ZIO 1.0), so you would have `Has<A> & Has<B>` in your environment.

In ZIO 2.0, the _contravariant_ `R` type parameter of the `ZIO` type (representing the environment) became fully phantom, thus allowing for removal of the `Has` type. This significantly improved the clarity of type signatures as well as removing another "stumbling block" for new users.

To facilitate removal of `Has` in Effect, we had to consider how types in the environment compose. By the rule of composition, contravariant parameters composed as an intersection (i.e. with `&`) are equivalent to covariant parameters composed together as a union (i.e. with `|`) for purposes of assignability. Based upon this fact, we decided to diverge from ZIO and make the `R` type parameter _covariant_ given `A | B` does not reduce to `never` if `A` and `B` have conflicts.

From our example above:

```ts
interface A {
  readonly prop: string
}

interface B {
  readonly prop: number
}

// ok
const ab: A | B = {
  prop: ""
}
```

Representing `R` as a covariant type parameter containing the union of services required by an `Effect` workflow allowed us to remove the requirement for `Has`.

## Type Aliases

In Effect, there are no predefined type aliases such as `UIO`, `URIO`, `RIO`, `Task`, or `IO` like in ZIO.

The reason for this is that type aliases are lost as soon as you compose them, which renders them somewhat useless unless you maintain **multiple** signatures for **every** function. In Effect, we have chosen not to go down this path. Instead, we utilize the `never` type to indicate unused types.

It's worth mentioning that the perception of type aliases being quicker to understand is often just an illusion. In Effect, the explicit notation `Effect<A>` clearly communicates that only type `A` is being used. On the other hand, when using a type alias like `RIO<R, A>`, questions arise about the type `E`. Is it `unknown`? `never`? Remembering such details becomes challenging.


---

# [Effect vs fp-ts](https://effect.website/docs/additional-resources/effect-vs-fp-ts/)

## Overview

## Key Developments

- **Project Merger**: The fp-ts project is officially merging with the Effect-TS ecosystem. Giulio Canti, the author of fp-ts, is being welcomed into the Effect organization. For more details, see the [announcement here](https://dev.to/effect/a-bright-future-for-effect-455m).
- **Continuity and Evolution**: Effect can be seen as the successor to fp-ts v2 and is effectively fp-ts v3, marking a significant evolution in the library's capabilities.

## FAQ

### Bundle Size Comparison Between Effect and fp-ts

**Q: I compared the bundle sizes of two simple programs using Effect and fp-ts. Why does Effect have a larger bundle size?**

A: It's natural to observe different bundle sizes because Effect and fp-ts are distinct systems designed for different purposes.
Effect's bundle size is larger due to its included fiber runtime, which is crucial for its functionality.
While the initial bundle size may seem large, the overhead amortizes as you use Effect.

**Q: Should I be concerned about the bundle size difference when choosing between Effect and fp-ts?**

A: Not necessarily. Consider the specific requirements and benefits of each library for your project.

The **Micro** module in Effect is designed as a lightweight alternative to the standard `Effect` module, specifically for scenarios where reducing bundle size is crucial.
This module is self-contained and does not include more complex features like `Layer`, `Ref`, `Queue`, and `Deferred`.
If any major Effect modules (beyond basic data modules like `Option`, `Either`, `Array`, etc.) are used, the effect runtime will be added to your bundle, negating the benefits of Micro.
This makes Micro ideal for libraries that aim to implement Effect functionality with minimal impact on bundle size, especially for libraries that plan to expose `Promise`-based APIs.
It also supports scenarios where a client might use Micro while a server uses the full suite of Effect features, maintaining compatibility and shared logic between different parts of an application.

## Comparison Table

The following table compares the features of the Effect and [fp-ts](https://github.com/gcanti/fp-ts) libraries.

| Feature                   | fp-ts | Effect |
| ------------------------- | ----- | ------ |
| Typed Services            | ❌    | ✅     |
| Built-in Services         | ❌    | ✅     |
| Typed errors              | ✅    | ✅     |
| Pipeable APIs             | ✅    | ✅     |
| Dual APIs                 | ❌    | ✅     |
| Testability               | ❌    | ✅     |
| Resource Management       | ❌    | ✅     |
| Interruptions             | ❌    | ✅     |
| Defects                   | ❌    | ✅     |
| Fiber-Based Concurrency   | ❌    | ✅     |
| Fiber Supervision         | ❌    | ✅     |
| Retry and Retry Policies  | ❌    | ✅     |
| Built-in Logging          | ❌    | ✅     |
| Built-in Scheduling       | ❌    | ✅     |
| Built-in Caching          | ❌    | ✅     |
| Built-in Batching         | ❌    | ✅     |
| Metrics                   | ❌    | ✅     |
| Tracing                   | ❌    | ✅     |
| Configuration             | ❌    | ✅     |
| Immutable Data Structures | ❌    | ✅     |
| Stream Processing         | ❌    | ✅     |

Here's an explanation of each feature:

### Typed Services

Both fp-ts and Effect libraries provide the ability to track requirements at the type level, allowing you to define and use services with specific types. In fp-ts, you can utilize the `ReaderTaskEither<R, E, A>` type, while in Effect, the `Effect<A, E, R>` type is available. It's important to note that in fp-ts, the `R` type parameter is contravariant, which means that there is no guarantee of avoiding conflicts, and the library offers only basic tools for dependency management.

On the other hand, in Effect, the `R` type parameter is covariant and all APIs have the ability to merge dependencies at the type level when multiple effects are involved. Effect also provides a range of specifically designed tools to simplify the management of dependencies, including `Tag`, `Context`, and `Layer`. These tools enhance the ease and flexibility of handling dependencies in your code, making it easier to compose and manage complex applications.

### Built-in Services

The Effect library has built-in services like `Clock`, `Random` and `Tracer`, while fp-ts does not provide any default services.

### Typed errors

Both libraries support typed errors, enabling you to define and handle errors with specific types. However, in Effect, all APIs have the ability to merge errors at the type-level when multiple effects are involved, and each effect can potentially fail with different types of errors.

This means that when combining multiple effects that can fail, the resulting type of the error will be a union of the individual error types. Effect provides utilities and type-level operations to handle and manage these merged error types effectively.

### Pipeable APIs

Both fp-ts and Effect libraries provide pipeable APIs, allowing you to compose and sequence operations in a functional and readable manner using the `pipe` function. However, Effect goes a step further and offers a `.pipe()` method on each data type, making it more convenient to work with pipelines without the need to explicitly import the `pipe` function every time.

### Dual APIs

Effect library provides dual APIs, allowing you to use the same API in different ways (e.g., "data-last" and "data-first" variants).

### Testability

The functional style of fp-ts generally promotes good testability of the code written using it, but the library itself does not provide dedicated tools specifically designed for the testing phase. On the other hand, Effect takes testability a step further by offering additional tools that are specifically tailored to simplify the testing process.

Effect provides a range of utilities that improve testability. For example, it offers the `TestClock` utility, which allows you to control the passage of time during tests. This is useful for testing time-dependent code. Additionally, Effect provides the `TestRandom` utility, which enables fully deterministic testing of code that involves randomness. This ensures consistent and predictable test results. Another helpful tool is `ConfigProvider.fromMap`, which makes it easy to define mock configurations for your application during testing.

### Resource Management

The Effect library provides built-in capabilities for resource management, while fp-ts has limited features in this area (mainly `bracket`) and they are less sophisticated.

In Effect, resource management refers to the ability to acquire and release resources, such as database connections, file handles, or network sockets, in a safe and controlled manner. The library offers comprehensive and refined mechanisms to handle resource acquisition and release, ensuring proper cleanup and preventing resource leaks.

### Interruptions

The Effect library supports interruptions, which means you can interrupt and cancel ongoing computations if needed. This feature gives you more control over the execution of your code and allows you to handle situations where you want to stop a computation before it completes.

In Effect, interruptions are useful in scenarios where you need to handle user cancellations, timeouts, or other external events that require stopping ongoing computations. You can explicitly request an interruption and the library will safely and efficiently halt the execution of the computation.

On the other hand, fp-ts does not have built-in support for interruptions. Once a computation starts in fp-ts, it will continue until it completes or encounters an error, without the ability to be interrupted midway.

### Defects

The Effect library provides mechanisms for handling defects and managing **unexpected** failures. In Effect, defects refer to unexpected errors or failures that can occur during the execution of a program.

With the Effect library, you have built-in tools and utilities to handle defects in a structured and reliable manner. It offers error handling capabilities that allow you to catch and handle exceptions, recover from failures, and gracefully handle unexpected scenarios.

On the other hand, fp-ts does not have built-in support specifically dedicated to managing defects. While you can handle errors using standard functional programming techniques in fp-ts, the Effect library provides a more comprehensive and streamlined approach to dealing with defects.

### Fiber-Based Concurrency

The Effect library leverages fiber-based concurrency, which enables lightweight and efficient concurrent computations. In simpler terms, fiber-based concurrency allows multiple tasks to run concurrently, making your code more responsive and efficient.

With fiber-based concurrency, the Effect library can handle concurrent operations in a way that is lightweight and doesn't block the execution of other tasks. This means that you can run multiple computations simultaneously, taking advantage of the available resources and maximizing performance.

On the other hand, fp-ts does not have built-in support for fiber-based concurrency. While fp-ts provides a rich set of functional programming features, it doesn't have the same level of support for concurrent computations as the Effect library.

### Fiber Supervision

Effect library provides supervision strategies for managing and monitoring fibers. fp-ts does not have built-in support for fiber supervision.

### Retry and Retry Policies

The Effect library includes built-in support for retrying computations with customizable retry policies. This feature is not available in fp-ts out of the box, and you would need to rely on external libraries to achieve similar functionality. However, it's important to note that the external libraries may not offer the same level of sophistication and fine-tuning as the built-in retry capabilities provided by the Effect library.

Retry functionality allows you to automatically retry a computation or action when it fails, based on a set of predefined rules or policies. This can be particularly useful in scenarios where you are working with unreliable or unpredictable resources, such as network requests or external services.

The Effect library provides a comprehensive set of retry policies that you can customize to fit your specific needs. These policies define the conditions for retrying a computation, such as the number of retries, the delay between retries, and the criteria for determining if a retry should be attempted.

By leveraging the built-in retry functionality in the Effect library, you can handle transient errors or temporary failures in a more robust and resilient manner. This can help improve the overall reliability and stability of your applications, especially in scenarios where you need to interact with external systems or services.

In contrast, fp-ts does not offer built-in support for retrying computations. If you require retry functionality in fp-ts, you would need to rely on external libraries, which may not provide the same level of sophistication and flexibility as the Effect library.

It's worth noting that the built-in retry capabilities of the Effect library are designed to work seamlessly with its other features, such as error handling and resource management. This integration allows for a more cohesive and comprehensive approach to handling failures and retries within your computations.

### Built-in Logging

The Effect library comes with built-in logging capabilities. This means that you can easily incorporate logging into your applications without the need for additional libraries or dependencies. In addition, the default logger provided by Effect can be replaced with a custom logger to suit your specific logging requirements.

Logging is an essential aspect of software development as it allows you to record and track important information during the execution of your code. It helps you monitor the behavior of your application, debug issues, and gather insights for analysis.

With the built-in logging capabilities of the Effect library, you can easily log messages, warnings, errors, or any other relevant information at various points in your code. This can be particularly useful for tracking the flow of execution, identifying potential issues, or capturing important events during the operation of your application.

On the other hand, fp-ts does not provide built-in logging capabilities. If you need logging functionality in fp-ts, you would need to rely on external libraries or implement your own logging solution from scratch. This can introduce additional complexity and dependencies into your codebase.

### Built-in Scheduling

The Effect library provides built-in scheduling capabilities, which allows you to manage the execution of computations over time. This feature is not available in fp-ts.

In many applications, it's common to have tasks or computations that need to be executed at specific intervals or scheduled for future execution. For example, you might want to perform periodic data updates, trigger notifications, or run background processes at specific times. This is where built-in scheduling comes in handy.

On the other hand, fp-ts does not have built-in scheduling capabilities. If you need to schedule tasks or manage timed computations in fp-ts, you would have to rely on external libraries or implement your own scheduling mechanisms, which can add complexity to your codebase.

### Built-in Caching

The Effect library provides built-in caching mechanisms, which enable you to cache the results of computations for improved performance. This feature is not available in fp-ts.

In many applications, computations can be time-consuming or resource-intensive, especially when dealing with complex operations or accessing remote resources. Caching is a technique used to store the results of computations so that they can be retrieved quickly without the need to recompute them every time.

With the built-in caching capabilities of the Effect library, you can easily cache the results of computations and reuse them when needed. This can significantly improve the performance of your application by avoiding redundant computations and reducing the load on external resources.

### Built-in Batching

The Effect library offers built-in batching capabilities, which enable you to combine multiple computations into a single batched computation. This feature is not available in fp-ts.

In many scenarios, you may need to perform multiple computations that share similar inputs or dependencies. Performing these computations individually can result in inefficiencies and increased overhead. Batching is a technique that allows you to group these computations together and execute them as a single batch, improving performance and reducing unnecessary processing.

### Metrics

The Effect library includes built-in support for collecting and reporting metrics related to computations and system behavior. It specifically supports [OpenTelemetry Metrics](https://opentelemetry.io/docs/specs/otel/metrics/). This feature is not available in fp-ts.

Metrics play a crucial role in understanding and monitoring the performance and behavior of your applications. They provide valuable insights into various aspects, such as response times, resource utilization, error rates, and more. By collecting and analyzing metrics, you can identify performance bottlenecks, optimize your code, and make informed decisions to improve your application's overall quality.

### Tracing

The Effect library has built-in tracing capabilities, which enable you to trace and debug the execution of your code and track the path of a request through an application. Additionally, Effect offers a dedicated [OpenTelemetry exporter](https://opentelemetry.io/docs/instrumentation/js/exporters/) for integrating with the OpenTelemetry observability framework. In contrast, fp-ts does not offer a similar tracing tool to enhance visibility into code execution.

### Configuration

The Effect library provides built-in support for managing and accessing configuration values within your computations. This feature is not available in fp-ts.

Configuration values are an essential aspect of software development. They allow you to customize the behavior of your applications without modifying the code. Examples of configuration values include database connection strings, API endpoints, feature flags, and various settings that can vary between environments or deployments.

With the Effect library's built-in support for configuration, you can easily manage and access these values within your computations. It provides convenient utilities and abstractions to load, validate, and access configuration values, ensuring that your application has the necessary settings it requires to function correctly.

By leveraging the built-in configuration support in the Effect library, you can:

- Load configuration values from various sources such as environment variables, configuration files, or remote configuration providers.
- Validate and ensure that the loaded configuration values adhere to the expected format and structure.
- Access the configuration values within your computations, allowing you to use them wherever necessary.

### Immutable Data Structures

The Effect library provides built-in support for immutable data structures such as `Chunk`, `HashSet`, and `HashMap`. These data structures ensure that once created, their values cannot be modified, promoting safer and more predictable code. In contrast, fp-ts does not have built-in support for such data structures and only provides modules that add additional APIs to standard data types like `Set` and `Map`. While these modules can be useful, they do not offer the same level of performance optimizations and specialized operations as the built-in immutable data structures provided by the Effect library.

Immutable data structures offer several benefits, including:

- Immutability: Immutable data structures cannot be changed after they are created. This property eliminates the risk of accidental modifications and enables safer concurrent programming.

- Predictability: With immutable data structures, you can rely on the fact that their values won't change unexpectedly. This predictability simplifies reasoning about code behavior and reduces bugs caused by mutable state.

- Sharing and Reusability: Immutable data structures can be safely shared between different parts of your program. Since they cannot be modified, you don't need to create defensive copies, resulting in more efficient memory usage and improved performance.

### Stream Processing

The Effect ecosystem provides built-in support for stream processing, enabling you to work with streams of data. Stream processing is a powerful concept that allows you to efficiently process and transform continuous streams of data in a reactive and asynchronous manner. However, fp-ts does not have this feature built-in and relies on external libraries like RxJS to handle stream processing.


---

# [Effect vs neverthrow](https://effect.website/docs/additional-resources/effect-vs-neverthrow/)

## Overview


When working with error handling in TypeScript, both [neverthrow](https://github.com/supermacro/neverthrow) and Effect provide useful abstractions for modeling
success and failure without exceptions. They share many concepts, such as wrapping computations in a safe container,
transforming values with `map`, handling errors with `mapErr`/`mapLeft`, and offering utilities to combine or unwrap results.

This page shows a side-by-side comparison of neverthrow and Effect APIs for common use cases.
If you're already familiar with neverthrow, the examples will help you understand how to achieve the same patterns with Effect.
If you're starting fresh, the comparison highlights the similarities and differences so you can decide which library better fits your project.

neverthrow exposes **instance methods** (for example, `result.map(...)`).
Effect exposes **functions** on `Either` (for example, `Either.map(result, ...)`) and supports a `pipe` style for readability and better tree shaking.

## Synchronous API

### ok

**Example** (Creating a success result)



```ts

const result = ok({ myData: "test" })

result.isOk() // true
result.isErr() // false
```



```ts
import * as Either from "effect/Either"

const result = Either.right({ myData: "test" })

Either.isRight(result) // true
Either.isLeft(result) // false
```



### err

**Example** (Creating a failure result)



```ts

const result = err("Oh no")

result.isOk() // false
result.isErr() // true
```



```ts
import * as Either from "effect/Either"

const result = Either.left("Oh no")

Either.isRight(result) // false
Either.isLeft(result) // true
```



### map

**Example** (Transforming the success value)



```ts

declare function getLines(s: string): Result<Array<string>, Error>

const result = getLines("1\n2\n3\n4\n")

// this Result now has a Array<number> inside it
const newResult = result.map((arr) => arr.map(parseInt))

newResult.isOk() // true
```



```ts
import * as Either from "effect/Either"

declare function getLines(s: string): Either.Either<Array<string>, Error>

const result = getLines("1\n2\n3\n4\n")

// this Either now has a Array<number> inside it
const newResult = result.pipe(Either.map((arr) => arr.map(parseInt)))

Either.isRight(newResult) // true
```



### mapErr

**Example** (Transforming the error value)



```ts

declare function parseHeaders(
  raw: string
): Result<Record<string, string>, string>

const rawHeaders = "nonsensical gibberish and badly formatted stuff"

const result = parseHeaders(rawHeaders)

// const newResult: Result<Record<string, string>, Error>
const newResult = result.mapErr((err) => new Error(err))
```



```ts
import * as Either from "effect/Either"

declare function parseHeaders(
  raw: string
): Either.Either<Record<string, string>, string>

const rawHeaders = "nonsensical gibberish and badly formatted stuff"

const result = parseHeaders(rawHeaders)

// const newResult: Either<Record<string, string>, Error>
const newResult = result.pipe(Either.mapLeft((err) => new Error(err)))
```



### unwrapOr

**Example** (Providing a default value)



```ts

const result = err("Oh no")

const multiply = (value: number): number => value * 2

const unwrapped = result.map(multiply).unwrapOr(10)
```



```ts
import * as Either from "effect/Either"

const result = Either.left("Oh no")

const multiply = (value: number): number => value * 2

const unwrapped = result.pipe(
  Either.map(multiply),
  Either.getOrElse(() => 10)
)
```



### andThen

**Example** (Chaining computations that may fail)



```ts

const sqrt = (n: number): Result<number, string> =>
  n > 0 ? ok(Math.sqrt(n)) : err("n must be positive")

ok(16).andThen(sqrt).andThen(sqrt)
// Ok(2)
```



```ts
import * as Either from "effect/Either"

const sqrt = (n: number): Either.Either<number, string> =>
  n > 0 ? Either.right(Math.sqrt(n)) : Either.left("n must be positive")

Either.right(16).pipe(Either.andThen(sqrt), Either.andThen(sqrt))
// Right(2)
```



### asyncAndThen

**Example** (Chaining asynchronous computations that may fail)



```ts

// const result: ResultAsync<number, never>
const result = ok(1).asyncAndThen((n) => okAsync(n + 1))
```



```ts
import * as Either from "effect/Either"
import * as Effect from "effect/Effect"

// const result: Effect<number, never, never>
const result = Either.right(1).pipe(
  Effect.andThen((n) => Effect.succeed(n + 1))
)
```



### orElse

**Example** (Providing an alternative on failure)



```ts

enum DatabaseError {
  PoolExhausted = "PoolExhausted",
  NotFound = "NotFound"
}

const dbQueryResult: Result<string, DatabaseError> = err(
  DatabaseError.NotFound
)

const updatedQueryResult = dbQueryResult.orElse((dbError) =>
  dbError === DatabaseError.NotFound
    ? ok("User does not exist")
    : err(500)
)
```



```ts
import * as Either from "effect/Either"

enum DatabaseError {
  PoolExhausted = "PoolExhausted",
  NotFound = "NotFound"
}

const dbQueryResult: Either.Either<string, DatabaseError> = Either.left(
  DatabaseError.NotFound
)

const updatedQueryResult = dbQueryResult.pipe(
  Either.orElse((dbError) =>
    dbError === DatabaseError.NotFound
      ? Either.right("User does not exist")
      : Either.left(500)
  )
)
```



### match

**Example** (Pattern matching on success or failure)



```ts

declare const myResult: Result<number, string>

myResult.match(
  (value) => `The value is ${value}`,
  (error) => `The error is ${error}`
)
```



```ts
import * as Either from "effect/Either"

declare const myResult: Either.Either<number, string>

myResult.pipe(
  Either.match({
    onLeft: (error) => `The error is ${error}`,
    onRight: (value) => `The value is ${value}`
  })
)
```



### asyncMap

**Example** (Parsing headers and looking up a user)



```ts

interface User {}
declare function parseHeaders(
  raw: string
): Result<Record<string, string>, string>
declare function findUserInDatabase(
  authorization: string
): Promise<User | undefined>

const rawHeader = "Authorization: Bearer 1234567890"

// const asyncResult: ResultAsync<User | undefined, string>
const asyncResult = parseHeaders(rawHeader)
  .map((kvMap) => kvMap["Authorization"])
  .asyncMap((authorization) =>
    authorization === undefined
      ? Promise.resolve(undefined)
      : findUserInDatabase(authorization)
  )
```



```ts
import * as Either from "effect/Either"
import * as Effect from "effect/Effect"

interface User {}
declare function parseHeaders(
  raw: string
): Either.Either<Record<string, string>, string>
declare function findUserInDatabase(
  authorization: string
): Promise<User | undefined>

const rawHeader = "Authorization: Bearer 1234567890"

// const asyncResult: Effect<User | undefined, string | UnknownException>
const asyncResult = parseHeaders(rawHeader).pipe(
  Either.map((kvMap) => kvMap["Authorization"]),
  Effect.andThen((authorization) =>
    authorization === undefined
      ? Promise.resolve(undefined)
      : findUserInDatabase(authorization)
  )
)
```

**Note**. In neverthrow, `asyncMap` works with Promises directly.
In Effect, passing a Promise to combinators like `Effect.andThen` automatically lifts it into an `Effect`.
If the Promise rejects, the rejection is turned into an `UnknownException`, which is why the error type is widened to `string | UnknownException`.



### combine

**Example** (Combining multiple results)



```ts

const results: Result<number, string>[] = [ok(1), ok(2)]

// const combined: Result<number[], string>
const combined = Result.combine(results)
```



```ts
import * as Either from "effect/Either"

const results: Either.Either<number, string>[] = [
  Either.right(1),
  Either.right(2)
]

// const combined: Either<number[], string>
const combined = Either.all(results)
```



### combineWithAllErrors

**Example** (Collecting all errors and successes)



```ts

const results: Result<number, string>[] = [
  ok(123),
  err("boooom!"),
  ok(456),
  err("ahhhhh!")
]

const result = Result.combineWithAllErrors(results)
// result is Err(['boooom!', 'ahhhhh!'])
```



```ts
import * as Either from "effect/Either"
import * as Array from "effect/Array"

const results: Either.Either<number, string>[] = [
  Either.right(123),
  Either.left("boooom!"),
  Either.right(456),
  Either.left("ahhhhh!")
]

const errors = Array.getLefts(results)
// errors is ['boooom!', 'ahhhhh!']

const successes = Array.getRights(results)
// successes is [123, 456]
```



**Note**. There is no exact equivalent of `Result.combineWithAllErrors` in Effect.
Use `Array.getLefts` to collect all errors and `Array.getRights` to collect all successes.

## Asynchronous API

In the examples below we use `Effect.runPromise` to run an effect and return a `Promise`.
You can also use other APIs such as `Effect.runPromiseExit`, which can capture additional cases like defects (runtime errors) and interruptions.

### okAsync

**Example** (Creating a successful async result)



```ts

const myResultAsync = okAsync({ myData: "test" })

const result = await myResultAsync

result.isOk() // true
result.isErr() // false
```



```ts
import * as Either from "effect/Either"
import * as Effect from "effect/Effect"

const myResultAsync = Effect.succeed({ myData: "test" })

const result = await Effect.runPromise(Effect.either(myResultAsync))

Either.isRight(result) // true
Either.isLeft(result) // false
```



### errAsync

**Example** (Creating a failed async result)



```ts

const myResultAsync = errAsync("Oh no")

const myResult = await myResultAsync

myResult.isOk() // false
myResult.isErr() // true
```



```ts
import * as Either from "effect/Either"
import * as Effect from "effect/Effect"

const myResultAsync = Effect.fail("Oh no")

const result = await Effect.runPromise(Effect.either(myResultAsync))

Either.isRight(result) // false
Either.isLeft(result) // true
```



### fromThrowable

**Example** (Wrapping a Promise-returning function that may throw)



```ts

interface User {}
declare function insertIntoDb(user: User): Promise<User>

// (user: User) => ResultAsync<User, Error>
const insertUser = ResultAsync.fromThrowable(
  insertIntoDb,
  () => new Error("Database error")
)
```



```ts
import * as Effect from "effect/Effect"

interface User {}
declare function insertIntoDb(user: User): Promise<User>

// (user: User) => Effect<User, Error>
const insertUser = (user: User) =>
  Effect.tryPromise({
    try: () => insertIntoDb(user),
    catch: () => new Error("Database error")
  })
```



### map

**Example** (Transforming the success value)



```ts

interface User {
  readonly name: string
}
declare function findUsersIn(
  country: string
): ResultAsync<Array<User>, Error>

const usersInCanada = findUsersIn("Canada")

const namesInCanada = usersInCanada.map((users: Array<User>) =>
  users.map((user) => user.name)
)

// We can extract the Result using .then() or await
namesInCanada.then((namesResult: Result<Array<string>, Error>) => {
  if (namesResult.isErr()) {
    console.log(
      "Couldn't get the users from the database",
      namesResult.error
    )
  } else {
    console.log(
      "Users in Canada are named: " + namesResult.value.join(",")
    )
  }
})
```



```ts
import * as Effect from "effect/Effect"
import * as Either from "effect/Either"

interface User {
  readonly name: string
}
declare function findUsersIn(
  country: string
): Effect.Effect<Array<User>, Error>

const usersInCanada = findUsersIn("Canada")

const namesInCanada = usersInCanada.pipe(
  Effect.map((users: Array<User>) => users.map((user) => user.name))
)

// We can extract the Either using Effect.either
Effect.runPromise(Effect.either(namesInCanada)).then(
  (namesResult: Either.Either<Array<string>, Error>) => {
    if (Either.isLeft(namesResult)) {
      console.log(
        "Couldn't get the users from the database",
        namesResult.left
      )
    } else {
      console.log(
        "Users in Canada are named: " + namesResult.right.join(",")
      )
    }
  }
)
```



### mapErr

**Example** (Transforming the error value)



```ts

interface User {
  readonly name: string
}
declare function findUsersIn(
  country: string
): ResultAsync<Array<User>, Error>

const usersInCanada = findUsersIn("Canada").mapErr((error: Error) => {
  // The only error we want to pass to the user is "Unknown country"
  if (error.message === "Unknown country") {
    return error.message
  }
  // All other errors will be labelled as a system error
  return "System error, please contact an administrator."
})

usersInCanada.then((usersResult: Result<Array<User>, string>) => {
  if (usersResult.isErr()) {
    console.log(
      "Couldn't get the users from the database",
      usersResult.error
    )
  } else {
    console.log("Users in Canada are: " + usersResult.value.join(","))
  }
})
```



```ts
import * as Effect from "effect/Effect"
import * as Either from "effect/Either"

interface User {
  readonly name: string
}
declare function findUsersIn(
  country: string
): Effect.Effect<Array<User>, Error>

const usersInCanada = findUsersIn("Canada").pipe(
  Effect.mapError((error: Error) => {
    // The only error we want to pass to the user is "Unknown country"
    if (error.message === "Unknown country") {
      return error.message
    }
    // All other errors will be labelled as a system error
    return "System error, please contact an administrator."
  })
)

Effect.runPromise(Effect.either(usersInCanada)).then(
  (usersResult: Either.Either<Array<User>, string>) => {
    if (Either.isLeft(usersResult)) {
      console.log(
        "Couldn't get the users from the database",
        usersResult.left
      )
    } else {
      console.log("Users in Canada are: " + usersResult.right.join(","))
    }
  }
)
```



### unwrapOr

**Example** (Providing a default value when async fails)



```ts

const unwrapped = await errAsync(0).unwrapOr(10)
// unwrapped = 10
```



```ts
import * as Effect from "effect/Effect"

const unwrapped = await Effect.runPromise(
  Effect.fail(0).pipe(Effect.orElseSucceed(() => 10))
)
// unwrapped = 10
```



### andThen

**Example** (Chaining multiple async computations)



```ts

interface User {}
declare function validateUser(user: User): ResultAsync<User, Error>
declare function insertUser(user: User): ResultAsync<User, Error>
declare function sendNotification(user: User): ResultAsync<void, Error>

const user: User = {}

const resAsync = validateUser(user)
  .andThen(insertUser)
  .andThen(sendNotification)

resAsync.then((res: Result<void, Error>) => {
  if (res.isErr()) {
    console.log("Oops, at least one step failed", res.error)
  } else {
    console.log(
      "User has been validated, inserted and notified successfully."
    )
  }
})
```



```ts
import * as Effect from "effect/Effect"
import * as Either from "effect/Either"

interface User {}
declare function validateUser(user: User): Effect.Effect<User, Error>
declare function insertUser(user: User): Effect.Effect<User, Error>
declare function sendNotification(user: User): Effect.Effect<void, Error>

const user: User = {}

const resAsync = validateUser(user).pipe(
  Effect.andThen(insertUser),
  Effect.andThen(sendNotification)
)

Effect.runPromise(Effect.either(resAsync)).then(
  (res: Either.Either<void, Error>) => {
    if (Either.isLeft(res)) {
      console.log("Oops, at least one step failed", res.left)
    } else {
      console.log(
        "User has been validated, inserted and notified successfully."
      )
    }
  }
)
```



### orElse

**Example** (Fallback when an async operation fails)



```ts

interface User {}
declare function fetchUserData(id: string): ResultAsync<User, Error>
declare function getDefaultUser(): User

const userId = "123"

// Try to fetch user data, but provide a default if it fails
const userResult = fetchUserData(userId).orElse(() =>
  ok(getDefaultUser())
)

userResult.then((result) => {
  if (result.isOk()) {
    console.log("User data:", result.value)
  }
})
```



```ts
import * as Effect from "effect/Effect"
import * as Either from "effect/Either"

interface User {}
declare function fetchUserData(id: string): Effect.Effect<User, Error>
declare function getDefaultUser(): User

const userId = "123"

// Try to fetch user data, but provide a default if it fails
const userResult = fetchUserData(userId).pipe(
  Effect.orElse(() => Effect.succeed(getDefaultUser()))
)

Effect.runPromise(Effect.either(userResult)).then((result) => {
  if (Either.isRight(result)) {
    console.log("User data:", result.right)
  }
})
```



### match

**Example** (Handling success and failure at the end of a chain)



```ts

interface User {
  readonly name: string
}
declare function validateUser(user: User): ResultAsync<User, Error>
declare function insertUser(user: User): ResultAsync<User, Error>

const user: User = { name: "John" }

// Handle both cases at the end of the chain using match
const resultMessage = await validateUser(user)
  .andThen(insertUser)
  .match(
    (user: User) => `User ${user.name} has been successfully created`,
    (error: Error) => `User could not be created because ${error.message}`
  )
```



```ts
import * as Effect from "effect/Effect"

interface User {
  readonly name: string
}
declare function validateUser(user: User): Effect.Effect<User, Error>
declare function insertUser(user: User): Effect.Effect<User, Error>

const user: User = { name: "John" }

// Handle both cases at the end of the chain using match
const resultMessage = await Effect.runPromise(
  validateUser(user).pipe(
    Effect.andThen(insertUser),
    Effect.match({
      onSuccess: (user) =>
        `User ${user.name} has been successfully created`,
      onFailure: (error) =>
        `User could not be created because ${error.message}`
    })
  )
)
```



### combine

**Example** (Combining multiple async results)



```ts

const resultList: ResultAsync<number, string>[] = [okAsync(1), okAsync(2)]

// const combinedList: ResultAsync<number[], string>
const combinedList = ResultAsync.combine(resultList)
```



```ts
import * as Effect from "effect/Effect"

const resultList: Effect.Effect<number, string>[] = [
  Effect.succeed(1),
  Effect.succeed(2)
]

// const combinedList: Effect<number[], string>
const combinedList = Effect.all(resultList)
```



### combineWithAllErrors

**Example** (Collecting all errors instead of failing fast)



```ts

const resultList: ResultAsync<number, string>[] = [
  okAsync(123),
  errAsync("boooom!"),
  okAsync(456),
  errAsync("ahhhhh!")
]

const result = await ResultAsync.combineWithAllErrors(resultList)
// result is Err(['boooom!', 'ahhhhh!'])
```



```ts

const resultList: Effect.Effect<number, string>[] = [
  Effect.succeed(123),
  Effect.fail("boooom!"),
  Effect.succeed(456),
  Effect.fail("ahhhhh!")
]

const result = await Effect.runPromise(
  Effect.either(Effect.validateAll(resultList, identity))
)
// result is left(['boooom!', 'ahhhhh!'])
```



## Utilities

### fromThrowable

**Example** (Safely wrapping a throwing function)



```ts

type ParseError = { message: string }
const toParseError = (): ParseError => ({ message: "Parse Error" })

const safeJsonParse = Result.fromThrowable(JSON.parse, toParseError)

// the function can now be used safely,
// if the function throws, the result will be an Err
const result = safeJsonParse("{")
```



```ts
import * as Either from "effect/Either"

type ParseError = { message: string }
const toParseError = (): ParseError => ({ message: "Parse Error" })

const safeJsonParse = (s: string) =>
  Either.try({ try: () => JSON.parse(s), catch: toParseError })

// the function can now be used safely,
// if the function throws, the result will be an Either
const result = safeJsonParse("{")
```



### safeTry

**Example** (Using generators to simplify error handling)



```ts

declare function mayFail1(): Result<number, string>
declare function mayFail2(): Result<number, string>

function myFunc(): Result<number, string> {
  return safeTry<number, string>(function* () {
    return ok(
      (yield* mayFail1().mapErr(
        (e) => `aborted by an error from 1st function, ${e}`
      )) +
        (yield* mayFail2().mapErr(
          (e) => `aborted by an error from 2nd function, ${e}`
        ))
    )
  })
}
```



```ts
import * as Either from "effect/Either"

declare function mayFail1(): Either.Either<number, string>
declare function mayFail2(): Either.Either<number, string>

function myFunc(): Either.Either<number, string> {
  return Either.gen(function* () {
    return (
      (yield* mayFail1().pipe(
        Either.mapLeft(
          (e) => `aborted by an error from 1st function, ${e}`
        )
      )) +
      (yield* mayFail2().pipe(
        Either.mapLeft(
          (e) => `aborted by an error from 2nd function, ${e}`
        )
      ))
    )
  })
}
```



**Note**. With `Either.gen`, you do not need to wrap the final value with `Either.right`. The generator's return value becomes the `Right`.

You can also use an async generator function with `safeTry` to represent an asynchronous block.
On the Effect side, the same pattern is written with `Effect.gen` instead of `Either.gen`.

**Example** (Using async generators to handle multiple failures)



```ts

declare function mayFail1(): ResultAsync<number, string>
declare function mayFail2(): ResultAsync<number, string>

function myFunc(): ResultAsync<number, string> {
  return safeTry<number, string>(async function* () {
    return ok(
      (yield* mayFail1().mapErr(
        (e) => `aborted by an error from 1st function, ${e}`
      )) +
        (yield* mayFail2().mapErr(
          (e) => `aborted by an error from 2nd function, ${e}`
        ))
    )
  })
}
```



```ts

declare function mayFail1(): Effect.Effect<number, string>
declare function mayFail2(): Effect.Effect<number, string>

function myFunc(): Effect.Effect<number, string> {
  return Effect.gen(function* () {
    return (
      (yield* mayFail1().pipe(
        Effect.mapError(
          (e) => `aborted by an error from 1st function, ${e}`
        )
      )) +
      (yield* mayFail2().pipe(
        Effect.mapError(
          (e) => `aborted by an error from 2nd function, ${e}`
        )
      ))
    )
  })
}
```



**Note**. With `Effect.gen`, you do not need to wrap the final value with `Effect.succeed`. The generator's return value becomes the `Success`.


---

# [Effect vs Promise](https://effect.website/docs/additional-resources/effect-vs-promise/)

## Overview


In this guide, we will explore the differences between `Promise` and `Effect`, two approaches to handling asynchronous operations in TypeScript. We'll discuss their type safety, creation, chaining, and concurrency, providing examples to help you understand their usage.

## Comparing Effects and Promises: Key Distinctions

- **Evaluation Strategy:** Promises are eagerly evaluated, whereas effects are lazily evaluated.
- **Execution Mode:** Promises are one-shot, executing once, while effects are multi-shot, repeatable.
- **Interruption Handling and Automatic Propagation:** Promises lack built-in interruption handling, posing challenges in managing interruptions, and don't automatically propagate interruptions, requiring manual abort controller management. In contrast, effects come with interruption handling capabilities and automatically compose interruption, simplifying management locally on smaller computations without the need for high-level orchestration.
- **Structured Concurrency:** Effects offer structured concurrency built-in, which is challenging to achieve with Promises.
- **Error Reporting (Type Safety):** Promises don't inherently provide detailed error reporting at the type level, whereas effects do, offering type-safe insight into error cases.
- **Runtime Behavior:** The Effect runtime aims to remain synchronous as long as possible, transitioning into asynchronous mode only when necessary due to computation requirements or main thread starvation.

## Type safety

Let's start by comparing the types of `Promise` and `Effect`. The type parameter `A` represents the resolved value of the operation:



```ts
Promise<A>
```



```ts
Effect<A, Error, Context>
```



Here's what sets `Effect` apart:

- It allows you to track the types of errors statically through the type parameter `Error`. For more information about error management in `Effect`, see [Expected Errors](/docs/error-management/expected-errors/).
- It allows you to track the types of required dependencies statically through the type parameter `Context`. For more information about context management in `Effect`, see [Managing Services](/docs/requirements-management/services/).

## Creating

### Success

Let's compare creating a successful operation using `Promise` and `Effect`:



```ts
const success = Promise.resolve(2)
```



```ts

const success = Effect.succeed(2)
```



### Failure

Now, let's see how to handle failures with `Promise` and `Effect`:



```ts
const failure = Promise.reject("Uh oh!")
```



```ts

const failure = Effect.fail("Uh oh!")
```



### Constructor

Creating operations with custom logic:



```ts
const task = new Promise<number>((resolve, reject) => {
  setTimeout(() => {
    Math.random() > 0.5 ? resolve(2) : reject("Uh oh!")
  }, 300)
})
```



```ts

const task = Effect.gen(function* () {
  yield* Effect.sleep("300 millis")
  return Math.random() > 0.5 ? 2 : yield* Effect.fail("Uh oh!")
})
```



## Thenable

Mapping the result of an operation:

### map



```ts
const mapped = Promise.resolve("Hello").then((s) => s.length)
```



```ts

const mapped = Effect.succeed("Hello").pipe(
  Effect.map((s) => s.length)
  // or Effect.andThen((s) => s.length)
)
```



### flatMap

Chaining multiple operations:



```ts
const flatMapped = Promise.resolve("Hello").then((s) =>
  Promise.resolve(s.length)
)
```



```ts

const flatMapped = Effect.succeed("Hello").pipe(
  Effect.flatMap((s) => Effect.succeed(s.length))
  // or Effect.andThen((s) => Effect.succeed(s.length))
)
```



## Comparing Effect.gen with async/await

If you are familiar with `async`/`await`, you may notice that the flow of writing code is similar.

Let's compare the two approaches:



```ts
const increment = (x: number) => x + 1

const divide = (a: number, b: number): Promise<number> =>
  b === 0
    ? Promise.reject(new Error("Cannot divide by zero"))
    : Promise.resolve(a / b)

const task1 = Promise.resolve(10)

const task2 = Promise.resolve(2)

const program = async function () {
  const a = await task1
  const b = await task2
  const n1 = await divide(a, b)
  const n2 = increment(n1)
  return `Result is: ${n2}`
}

program().then(console.log) // Output: "Result is: 6"
```



```ts

const increment = (x: number) => x + 1

const divide = (a: number, b: number): Effect.Effect<number, Error> =>
  b === 0
    ? Effect.fail(new Error("Cannot divide by zero"))
    : Effect.succeed(a / b)

const task1 = Effect.promise(() => Promise.resolve(10))

const task2 = Effect.promise(() => Promise.resolve(2))

const program = Effect.gen(function* () {
  const a = yield* task1
  const b = yield* task2
  const n1 = yield* divide(a, b)
  const n2 = increment(n1)
  return `Result is: ${n2}`
})

Effect.runPromise(program).then(console.log)
// Output: "Result is: 6"
```



It's important to note that although the code appears similar, the two programs are not identical. The purpose of comparing them side by side is just to highlight the resemblance in how they are written.

## Concurrency

### Promise.all()



```ts
const task1 = new Promise<number>((resolve, reject) => {
  console.log("Executing task1...")
  setTimeout(() => {
    console.log("task1 done")
    resolve(1)
  }, 100)
})

const task2 = new Promise<number>((resolve, reject) => {
  console.log("Executing task2...")
  setTimeout(() => {
    console.log("task2 done")
    reject("Uh oh!")
  }, 200)
})

const task3 = new Promise<number>((resolve, reject) => {
  console.log("Executing task3...")
  setTimeout(() => {
    console.log("task3 done")
    resolve(3)
  }, 300)
})

const program = Promise.all([task1, task2, task3])

program.then(console.log, console.error)
/*
Output:
Executing task1...
Executing task2...
Executing task3...
task1 done
task2 done
Uh oh!
task3 done
*/
```



```ts

const task1 = Effect.gen(function* () {
  console.log("Executing task1...")
  yield* Effect.sleep("100 millis")
  console.log("task1 done")
  return 1
})

const task2 = Effect.gen(function* () {
  console.log("Executing task2...")
  yield* Effect.sleep("200 millis")
  console.log("task2 done")
  return yield* Effect.fail("Uh oh!")
})

const task3 = Effect.gen(function* () {
  console.log("Executing task3...")
  yield* Effect.sleep("300 millis")
  console.log("task3 done")
  return 3
})

const program = Effect.all([task1, task2, task3], {
  concurrency: "unbounded"
})

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
Executing task1...
Executing task2...
Executing task3...
task1 done
task2 done
(FiberFailure) Error: Uh oh!
*/
```



### Promise.allSettled()



```ts
const task1 = new Promise<number>((resolve, reject) => {
  console.log("Executing task1...")
  setTimeout(() => {
    console.log("task1 done")
    resolve(1)
  }, 100)
})

const task2 = new Promise<number>((resolve, reject) => {
  console.log("Executing task2...")
  setTimeout(() => {
    console.log("task2 done")
    reject("Uh oh!")
  }, 200)
})

const task3 = new Promise<number>((resolve, reject) => {
  console.log("Executing task3...")
  setTimeout(() => {
    console.log("task3 done")
    resolve(3)
  }, 300)
})

const program = Promise.allSettled([task1, task2, task3])

program.then(console.log, console.error)
/*
Output:
Executing task1...
Executing task2...
Executing task3...
task1 done
task2 done
task3 done
[
  { status: 'fulfilled', value: 1 },
  { status: 'rejected', reason: 'Uh oh!' },
  { status: 'fulfilled', value: 3 }
]
*/
```



```ts

const task1 = Effect.gen(function* () {
  console.log("Executing task1...")
  yield* Effect.sleep("100 millis")
  console.log("task1 done")
  return 1
})

const task2 = Effect.gen(function* () {
  console.log("Executing task2...")
  yield* Effect.sleep("200 millis")
  console.log("task2 done")
  return yield* Effect.fail("Uh oh!")
})

const task3 = Effect.gen(function* () {
  console.log("Executing task3...")
  yield* Effect.sleep("300 millis")
  console.log("task3 done")
  return 3
})

const program = Effect.forEach(
  [task1, task2, task3],
  (task) => Effect.either(task), // or Effect.exit
  {
    concurrency: "unbounded"
  }
)

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
Executing task1...
Executing task2...
Executing task3...
task1 done
task2 done
task3 done
[
  {
    _id: "Either",
    _tag: "Right",
    right: 1
  }, {
    _id: "Either",
    _tag: "Left",
    left: "Uh oh!"
  }, {
    _id: "Either",
    _tag: "Right",
    right: 3
  }
]
*/
```



### Promise.any()



```ts
const task1 = new Promise<number>((resolve, reject) => {
  console.log("Executing task1...")
  setTimeout(() => {
    console.log("task1 done")
    reject("Something went wrong!")
  }, 100)
})

const task2 = new Promise<number>((resolve, reject) => {
  console.log("Executing task2...")
  setTimeout(() => {
    console.log("task2 done")
    resolve(2)
  }, 200)
})

const task3 = new Promise<number>((resolve, reject) => {
  console.log("Executing task3...")
  setTimeout(() => {
    console.log("task3 done")
    reject("Uh oh!")
  }, 300)
})

const program = Promise.any([task1, task2, task3])

program.then(console.log, console.error)
/*
Output:
Executing task1...
Executing task2...
Executing task3...
task1 done
task2 done
2
task3 done
*/
```



```ts

const task1 = Effect.gen(function* () {
  console.log("Executing task1...")
  yield* Effect.sleep("100 millis")
  console.log("task1 done")
  return yield* Effect.fail("Something went wrong!")
})

const task2 = Effect.gen(function* () {
  console.log("Executing task2...")
  yield* Effect.sleep("200 millis")
  console.log("task2 done")
  return 2
})

const task3 = Effect.gen(function* () {
  console.log("Executing task3...")
  yield* Effect.sleep("300 millis")
  console.log("task3 done")
  return yield* Effect.fail("Uh oh!")
})

const program = Effect.raceAll([task1, task2, task3])

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
Executing task1...
Executing task2...
Executing task3...
task1 done
task2 done
2
*/
```



### Promise.race()



```ts
const task1 = new Promise<number>((resolve, reject) => {
  console.log("Executing task1...")
  setTimeout(() => {
    console.log("task1 done")
    reject("Something went wrong!")
  }, 100)
})

const task2 = new Promise<number>((resolve, reject) => {
  console.log("Executing task2...")
  setTimeout(() => {
    console.log("task2 done")
    reject("Uh oh!")
  }, 200)
})

const task3 = new Promise<number>((resolve, reject) => {
  console.log("Executing task3...")
  setTimeout(() => {
    console.log("task3 done")
    resolve(3)
  }, 300)
})

const program = Promise.race([task1, task2, task3])

program.then(console.log, console.error)
/*
Output:
Executing task1...
Executing task2...
Executing task3...
task1 done
Something went wrong!
task2 done
task3 done
*/
```



```ts

const task1 = Effect.gen(function* () {
  console.log("Executing task1...")
  yield* Effect.sleep("100 millis")
  console.log("task1 done")
  return yield* Effect.fail("Something went wrong!")
})

const task2 = Effect.gen(function* () {
  console.log("Executing task2...")
  yield* Effect.sleep("200 millis")
  console.log("task2 done")
  return yield* Effect.fail("Uh oh!")
})

const task3 = Effect.gen(function* () {
  console.log("Executing task3...")
  yield* Effect.sleep("300 millis")
  console.log("task3 done")
  return 3
})

const program = Effect.raceAll([task1, task2, task3].map(Effect.either)) // or Effect.exit

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
Executing task1...
Executing task2...
Executing task3...
task1 done
{
  _id: "Either",
  _tag: "Left",
  left: "Something went wrong!"
}
*/
```



## FAQ

**Question**. What is the equivalent of starting a promise without immediately waiting for it in Effects?

```ts {10,16} twoslash
const task = (delay: number, name: string) =>
  new Promise((resolve) =>
    setTimeout(() => {
      console.log(`${name} done`)
      return resolve(name)
    }, delay)
  )

export async function program() {
  const r0 = task(2_000, "long running task")
  const r1 = await task(200, "task 2")
  const r2 = await task(100, "task 3")
  return {
    r1,
    r2,
    r0: await r0
  }
}

program().then(console.log)
/*
Output:
task 2 done
task 3 done
long running task done
{ r1: 'task 2', r2: 'task 3', r0: 'long running promise' }
*/
```

**Answer:** You can achieve this by utilizing `Effect.fork` and `Fiber.join`.

```ts {11,17} twoslash

const task = (delay: number, name: string) =>
  Effect.gen(function* () {
    yield* Effect.sleep(delay)
    console.log(`${name} done`)
    return name
  })

const program = Effect.gen(function* () {
  const r0 = yield* Effect.fork(task(2_000, "long running task"))
  const r1 = yield* task(200, "task 2")
  const r2 = yield* task(100, "task 3")
  return {
    r1,
    r2,
    r0: yield* Fiber.join(r0)
  }
})

Effect.runPromise(program).then(console.log)
/*
Output:
task 2 done
task 3 done
long running task done
{ r1: 'task 2', r2: 'task 3', r0: 'long running promise' }
*/
```


---

# [Myths About Effect](https://effect.website/docs/additional-resources/myths/)

## Overview

## Effect heavily relies on generators and generators are slow!

Effect's internals are not built on generators, we only use generators to provide an API which closely mimics async-await. Internally async-await uses the same mechanics as generators and they are equally performant. So if you don't have a problem with async-await you won't have a problem with Effect's generators.

Where generators and iterables are unacceptably slow is in transforming collections of data, for that try to use plain arrays as much as possible.

## Effect will make your code 500x slower!

Effect does perform 500x slower if you are comparing:

```ts
const result = 1 + 1
```

to

```ts

const result = Effect.runSync(
  Effect.zipWith(Effect.succeed(1), Effect.succeed(1), (a, b) => a + b)
)
```

The reason is one operation is optimized by the JIT compiler to be a direct CPU instruction and the other isn't.

In reality you'd never use Effect in such cases, Effect is an app-level library to tame concurrency, error handling, and much more!

You'd use Effect to coordinate your thunks of code, and you can build your thunks of code in the best perfoming manner as you see fit while still controlling execution through Effect.

## Effect has a huge performance overhead!

Depends what you mean by performance, many times performance bottlenecks in JS are due to bad management of concurrency.

Thanks to structured concurrency and observability it becomes much easier to spot and optimize those issues.

There are apps in frontend running at 120fps that use Effect intensively, so most likely effect won't be your perf problem.

In regards of memory, it doesn't use much more memory than a normal program would, there are a few more allocations compared to non Effect code but usually this is no longer the case when the non Effect code does the same thing as the Effect code.

The advice would be start using it and monitor your code, optimise out of need not out of thought, optimizing too early is the root of all evils in software design.

## The bundle size is HUGE!

Effect's minimum cost is about 25k of gzipped code, that chunk contains the Effect Runtime and already includes almost all the functions that you'll need in a normal app-code scenario.

From that point on Effect is tree-shaking friendly so you'll only include what you use.

Also when using Effect your own code becomes shorter and terser, so the overall cost is amortized with usage, we have apps where adopting Effect in the majority of the codebase led to reduction of the final bundle.

## Effect is impossible to learn, there are so many functions and modules!

True, the full Effect ecosystem is quite large and some modules contain 1000s of functions, the reality is that you don't need to know them all to start being productive, you can safely start using Effect knowing just 10-20 functions and progressively discover the rest, just like you can start using TypeScript without knowing every single NPM package.

A short list of commonly used functions to begin are:

- [Effect.succeed](/docs/getting-started/creating-effects/#succeed)
- [Effect.fail](/docs/getting-started/creating-effects/#fail)
- [Effect.sync](/docs/getting-started/creating-effects/#sync)
- [Effect.tryPromise](/docs/getting-started/creating-effects/#trypromise)
- [Effect.gen](/docs/getting-started/using-generators/)
- [Effect.runPromise](/docs/getting-started/running-effects/#runpromise)
- [Effect.catchTag](/docs/error-management/expected-errors/#catchtag)
- [Effect.catchAll](/docs/error-management/expected-errors/#catchall)
- [Effect.acquireRelease](/docs/resource-management/scope/#acquirerelease)
- [Effect.acquireUseRelease](/docs/resource-management/introduction/#acquireuserelease)
- [Effect.provide](/docs/requirements-management/layers/#providing-a-layer-to-an-effect)
- [Effect.provideService](/docs/requirements-management/services/#providing-a-service-implementation)
- [Effect.andThen](/docs/getting-started/building-pipelines/#andthen)
- [Effect.map](/docs/getting-started/building-pipelines/#map)
- [Effect.tap](/docs/getting-started/building-pipelines/#tap)

A short list of commonly used modules:

- [Effect](https://effect-ts.github.io/effect/effect/Effect.ts.html)
- [Context](/docs/requirements-management/services/#creating-a-service)
- [Layer](/docs/requirements-management/layers/)
- [Option](/docs/data-types/option/)
- [Either](/docs/data-types/either/)
- [Array](https://effect-ts.github.io/effect/effect/Array.ts.html)
- [Match](/docs/code-style/pattern-matching/)

## Effect is the same as RxJS and shares its problems

This is a sensitive topic, let's start by saying that RxJS is a great project and that it has helped millions of developers write reliable software and we all should be thankful to the developers who contributed to such an amazing project.

Discussing the scope of the projects, RxJS aims to make working with Observables easy and wants to provide reactive extensions to JS, Effect instead wants to make writing production-grade TypeScript easy. While the intersection is non-empty the projects have fundamentally different objectives and strategies.

Sometimes people refer to RxJS in bad light, and the reason isn't RxJS in itself but rather usage of RxJS in problem domains where RxJS wasn't thought to be used.

Namely the idea that "everything is a stream" is theoretically true but it leads to fundamental limitations on developer experience, the primary issue being that streams are multi-shot (emit potentially multiple elements, or zero) and mutable delimited continuations (JS Generators) are known to be only good to represent single-shot effects (that emit a single value).

In short it means that writing in imperative style (think of async/await) is practically impossible with stream primitives (practically because there would be the option of replaying the generator at every element and at every step, but this tends to be inefficient and the semantics of it are counter-intuitive, it would only work under the assumption that the full body is free of side-effects), forcing the developer to use declarative approaches such as pipe to represent all of their code.

Effect has a Stream module (which is pull-based instead of push-based in order to be memory constant), but the basic Effect type is single-shot and it is optimised to act as a smart & lazy Promise that enables imperative programming, so when using Effect you're not forced to use a declarative style for everything and you can program using a model which is similar to async-await.

The other big difference is that RxJS only cares about the happy-path with explicit types, it doesn't offer a way of typing errors and dependencies, Effect instead consider both errors and dependencies as explicitely typed and offers control-flow around those in a fully type-safe manner.

In short if you need reactive programming around Observables, use RxJS, if you need to write production-grade TypeScript that includes by default native telemetry, error handling, dependency injection, and more use Effect.

## Effect should be a language or Use a different language

Neither solve the issue of writing production grade software in TypeScript.

TypeScript is an amazing language to write full stack code with deep roots in the JS ecosystem and wide compatibility of tools, it is an industrial language adopted by many large scale companies.

The fact that something like Effect is possible within the language and the fact that the language supports things such as generators that allows for imperative programming with custom types such as Effect makes TypeScript a unique language.

In fact even in functional languages such as Scala the interop with effect systems is less optimal than it is in TypeScript, to the point that effect system authors have expressed wish for their language to support as much as TypeScript supports.


---

# [API Reference](https://effect.website/docs/additional-resources/api-reference/)

## Overview

- [`effect`](https://effect-ts.github.io/effect/docs/effect)
- [`@effect/cli`](https://effect-ts.github.io/effect/docs/cli) ([Getting Started](https://github.com/Effect-TS/effect/blob/main/packages/cli/README.md))
- [`@effect/opentelemetry`](https://effect-ts.github.io/effect/docs/opentelemetry)
- [`@effect/platform`](https://effect-ts.github.io/effect/docs/platform) ([Experimental Features](https://github.com/Effect-TS/effect/blob/main/packages/platform/README.md))
- [`@effect/printer`](https://effect-ts.github.io/effect/docs/printer) ([Getting Started](https://github.com/Effect-TS/effect/blob/main/packages/printer/README.md))
- [`@effect/rpc`](https://effect-ts.github.io/effect/docs/rpc) ([Getting Started](https://github.com/Effect-TS/effect/blob/main/packages/rpc/README.md))
- [`@effect/typeclass`](https://effect-ts.github.io/effect/docs/typeclass) ([Getting Started](https://github.com/Effect-TS/effect/blob/main/packages/typeclass/README.md))


---


## Common Mistakes

**Incorrect (Promise.all without error typing):**

```ts
const [user, todos] = await Promise.all([
  getUser(id),    // Error type unknown
  getTodos(id)    // Error type unknown
])
```

**Correct (Effect.all with tracked errors):**

```ts
const [user, todos] = yield* Effect.all([
  getUser(id),    // Effect<User, NotFound>
  getTodos(id)    // Effect<Todo[], DbError>
])
// Error channel: NotFound | DbError — fully tracked
```
