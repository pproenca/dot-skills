---
title: "Error Management"
impact: CRITICAL
impactDescription: "Prevents unhandled errors and incorrect error recovery — covers typed errors, retrying, timeouts, sandboxing"
tags: error, error-management, typed-errors, recovery, retrying
---
# [Two Types of Errors](https://effect.website/docs/error-management/two-error-types/)

## Overview

Just like any other program, Effect programs may fail for expected or unexpected reasons.
The difference between a non-Effect program and an Effect program is in the detail provided to you when your program fails.
Effect attempts to preserve as much information as possible about what caused your program to fail to produce a detailed,
comprehensive, and human readable failure message.

In an Effect program, there are two possible ways for a program to fail:

- **Expected Errors**: These are errors that developers anticipate and expect as part of normal program execution.

- **Unexpected Errors**: These are errors that occur unexpectedly and are not part of the intended program flow.

## Expected Errors

These errors, also referred to as _failures_, _typed errors_
or _recoverable errors_, are errors that developers anticipate as part of the normal program execution.
They serve a similar purpose to checked exceptions and play a role in defining the program's domain and control flow.

Expected errors **are tracked** at the type level by the `Effect` data type in the "Error" channel:

```ts
const program: Effect<string, HttpError, never>
```

it is evident from the type that the program can fail with an error of type `HttpError`.

## Unexpected Errors

Unexpected errors, also referred to as _defects_, _untyped errors_, or _unrecoverable errors_, are errors that developers
do not anticipate occurring during normal program execution.
Unlike expected errors, which are considered part of a program's domain and control flow,
unexpected errors resemble unchecked exceptions and lie outside the expected behavior of the program.

Since these errors are not expected, Effect **does not track** them at the type level.
However, the Effect runtime does keep track of these errors and provides several methods to aid in recovering from unexpected errors.


---

# [Expected Errors](https://effect.website/docs/error-management/expected-errors/)

## Overview


Expected errors are tracked at the type level by the [Effect data type](/docs/getting-started/the-effect-type/) in the "Error channel":

```text
         ┌─── Represents the success type
         │        ┌─── Represents the error type
         │        │      ┌─── Represents required dependencies
         ▼        ▼      ▼
Effect<Success, Error, Requirements>
```

This means that the `Effect` type captures not only what the program returns on success but also what type of error it might produce.

**Example** (Creating an Effect That Can Fail)

In this example, we define a program that might randomly fail with an `HttpError`.

```ts

// Define a custom error type using Data.TaggedError
class HttpError extends Data.TaggedError("HttpError")<{}> {}

//      ┌─── Effect<string, HttpError, never>
//      ▼
const program = Effect.gen(function* () {
  // Generate a random number between 0 and 1
  const n = yield* Random.next

  // Simulate an HTTP error
  if (n < 0.5) {
    return yield* Effect.fail(new HttpError())
  }

  return "some result"
})
```

The type of `program` tells us that it can either return a `string` or fail with an `HttpError`:

```ts "HttpError"
const program: Effect<string, HttpError, never>
```

In this case, we use a class to represent the `HttpError` type, which allows us to define both the error type and a constructor.

When using `Data.TaggedError`, a `_tag` field is automatically added to the class

```ts
// This field serves as a discriminant for the error
console.log(new HttpError()._tag)
// Output: "HttpError"
```

This discriminant field will be useful when we discuss APIs like [Effect.catchTag](#catchtag), which help in handling specific error types.

> **Tip: Why Tagged Errors Are Useful**
  Adding a discriminant field, such as `_tag`, can be beneficial for
  distinguishing between different types of errors during error handling.
  It also prevents TypeScript from unifying types, ensuring that each
  error is treated uniquely based on its discriminant value.

For more information on constructing tagged errors, see [Data.TaggedError](/docs/error-management/yieldable-errors/#datataggederror).



## Error Tracking

In Effect, if a program can fail with multiple types of errors, they are automatically tracked as a union of those error types.
This allows you to know exactly what errors can occur during execution, making error handling more precise and predictable.

The example below illustrates how errors are automatically tracked for you.

**Example** (Automatically Tracking Errors)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  // Generate two random numbers between 0 and 1
  const n1 = yield* Random.next
  const n2 = yield* Random.next

  // Simulate an HTTP error
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  // Simulate a validation error
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }

  return "some result"
})
```

Effect automatically keeps track of the possible errors that can occur during the execution of the program as a union:

```ts
const program: Effect<string, HttpError | ValidationError, never>
```

indicating that it can potentially fail with either a `HttpError` or a `ValidationError`.

## Short-Circuiting

When working with APIs like [Effect.gen](/docs/getting-started/using-generators/#understanding-effectgen), [Effect.map](/docs/getting-started/building-pipelines/#map), [Effect.flatMap](/docs/getting-started/building-pipelines/#flatmap), and [Effect.andThen](/docs/getting-started/building-pipelines/#andthen), it's important to understand how they handle errors.
These APIs are designed to **short-circuit the execution** upon encountering the **first error**.

What does this mean for you as a developer? Well, let's say you have a chain of operations or a collection of effects to be executed in sequence. If any error occurs during the execution of one of these effects, the remaining computations will be skipped, and the error will be propagated to the final result.

In simpler terms, the short-circuiting behavior ensures that if something goes wrong at any step of your program, it won't waste time executing unnecessary computations. Instead, it will immediately stop and return the error to let you know that something went wrong.

**Example** (Short-Circuiting Behavior)

```ts

// Define three effects representing different tasks.
const task1 = Console.log("Executing task1...")
const task2 = Effect.fail("Something went wrong!")
const task3 = Console.log("Executing task3...")

// Compose the three tasks to run them in sequence.
// If one of the tasks fails, the subsequent tasks won't be executed.
const program = Effect.gen(function* () {
  yield* task1
  // After task1, task2 is executed, but it fails with an error
  yield* task2
  // This computation won't be executed because the previous one fails
  yield* task3
})

Effect.runPromiseExit(program).then(console.log)
/*
Output:
Executing task1...
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Something went wrong!' }
}
*/
```

This code snippet demonstrates the short-circuiting behavior when an error occurs.
Each operation depends on the successful execution of the previous one.
If any error occurs, the execution is short-circuited, and the error is propagated.
In this specific example, `task3` is never executed because an error occurs in `task2`.

## Catching All Errors

### either

The `Effect.either` function transforms an `Effect<A, E, R>` into an effect that encapsulates both potential failure and success within an [Either](/docs/data-types/either/) data type:

```ts
Effect<A, E, R> -> Effect<Either<A, E>, never, R>
```

This means if you have an effect with the following type:

```ts
Effect<string, HttpError, never>
```

and you call `Effect.either` on it, the type becomes:

```ts
Effect<Either<string, HttpError>, never, never>
```

The resulting effect cannot fail because the potential failure is now represented within the `Either`'s `Left` type.
The error type of the returned `Effect` is specified as `never`, confirming that the effect is structured to not fail.

By yielding an `Either`, we gain the ability to "pattern match" on this type to handle both failure and success cases within the generator function.

**Example** (Using `Effect.either` to Handle Errors)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, never, never>
//      ▼
const recovered = Effect.gen(function* () {
  //      ┌─── Either<string, HttpError | ValidationError>
  //      ▼
  const failureOrSuccess = yield* Effect.either(program)
  if (Either.isLeft(failureOrSuccess)) {
    // Failure case: you can extract the error from the `left` property
    const error = failureOrSuccess.left
    return `Recovering from ${error._tag}`
  } else {
    // Success case: you can extract the value from the `right` property
    return failureOrSuccess.right
  }
})
```

As you can see since all errors are handled, the error type of the resulting effect `recovered` is `never`:

```ts
const recovered: Effect<string, never, never>
```

We can make the code less verbose by using the `Either.match` function, which directly accepts the two callback functions for handling errors and successful values:

**Example** (Simplifying with `Either.match`)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, never, never>
//      ▼
const recovered = Effect.gen(function* () {
  //      ┌─── Either<string, HttpError | ValidationError>
  //      ▼
  const failureOrSuccess = yield* Effect.either(program)
  return Either.match(failureOrSuccess, {
    onLeft: (error) => `Recovering from ${error._tag}`,
    onRight: (value) => value // Do nothing in case of success
  })
})
```

### option

Transforms an effect to encapsulate both failure and success using the [Option](/docs/data-types/option/) data type.

The `Effect.option` function wraps the success or failure of an effect within the
`Option` type, making both cases explicit. If the original effect succeeds,
its value is wrapped in `Option.some`. If it fails, the failure is mapped to
`Option.none`.

The resulting effect cannot fail directly, as the error type is set to `never`. However, fatal errors like defects are not encapsulated.

**Example** (Using `Effect.option` to Handle Errors)

```ts

const maybe1 = Effect.option(Effect.succeed(1))

Effect.runPromiseExit(maybe1).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Success',
  value: { _id: 'Option', _tag: 'Some', value: 1 }
}
*/

const maybe2 = Effect.option(Effect.fail("Uh oh!"))

Effect.runPromiseExit(maybe2).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Success',
  value: { _id: 'Option', _tag: 'None' }
}
*/

const maybe3 = Effect.option(Effect.die("Boom!"))

Effect.runPromiseExit(maybe3).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Die', defect: 'Boom!' }
}
*/
```

### catchAll

Handles all errors in an effect by providing a fallback effect.

The `Effect.catchAll` function catches any errors that may occur during the
execution of an effect and allows you to handle them by specifying a fallback
effect. This ensures that the program continues without failing by recovering
from errors using the provided fallback logic.

> **Note: Recoverable Errors Only**
  `Effect.catchAll` only handles recoverable errors. It will not recover
  from unrecoverable defects. See [Effect.catchAllCause](#catchallcause)
  for handling all types of failures.


**Example** (Providing Recovery Logic for Recoverable Errors)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, never, never>
//      ▼
const recovered = program.pipe(
  Effect.catchAll((error) =>
    Effect.succeed(`Recovering from ${error._tag}`)
  )
)
```

We can observe that the type in the error channel of our program has changed to `never`:

```ts
const recovered: Effect<string, never, never>
```

indicating that all errors have been handled.

### catchAllCause

Handles both recoverable and unrecoverable errors by providing a recovery effect.

The `Effect.catchAllCause` function allows you to handle all errors, including
unrecoverable defects, by providing a recovery effect. The recovery logic is
based on the `Cause` of the error, which provides detailed information about
the failure.

**Example** (Recovering from All Errors)

```ts

// Define an effect that may fail with a recoverable or unrecoverable error
const program = Effect.fail("Something went wrong!")

// Recover from all errors by examining the cause
const recovered = program.pipe(
  Effect.catchAllCause((cause) =>
    Cause.isFailType(cause)
      ? Effect.succeed("Recovered from a regular error")
      : Effect.succeed("Recovered from a defect")
  )
)

Effect.runPromise(recovered).then(console.log)
// Output: "Recovered from a regular error"
```

> **Tip: When to Recover from Defects**
  Defects are unexpected errors that typically shouldn't be recovered
  from, as they often indicate serious issues. However, in some cases,
  such as dynamically loaded plugins, controlled recovery might be needed.


## Catching Some Errors

### either

The [`Effect.either`](#either) function, which was previously shown as a way to catch all errors, can also be used to catch specific errors.

By yielding an `Either`, we gain the ability to "pattern match" on this type to handle both failure and success cases within the generator function.

**Example** (Handling Specific Errors with `Effect.either`)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, ValidationError, never>
//      ▼
const recovered = Effect.gen(function* () {
  const failureOrSuccess = yield* Effect.either(program)
  if (Either.isLeft(failureOrSuccess)) {
    const error = failureOrSuccess.left
    // Only handle HttpError errors
    if (error._tag === "HttpError") {
      return "Recovering from HttpError"
    } else {
      // Rethrow ValidationError
      return yield* Effect.fail(error)
    }
  } else {
    return failureOrSuccess.right
  }
})
```

We can observe that the type in the error channel of our program has changed to only show `ValidationError`:

```ts
const recovered: Effect<string, ValidationError, never>
```

indicating that `HttpError` has been handled.

If we also want to handle `ValidationError`, we can easily add another case to our code:

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, never, never>
//      ▼
const recovered = Effect.gen(function* () {
  const failureOrSuccess = yield* Effect.either(program)
  if (Either.isLeft(failureOrSuccess)) {
    const error = failureOrSuccess.left
    // Handle both HttpError and ValidationError
    if (error._tag === "HttpError") {
      return "Recovering from HttpError"
    } else {
      return "Recovering from ValidationError"
    }
  } else {
    return failureOrSuccess.right
  }
})
```

We can observe that the type in the error channel has changed to `never`:

```ts
const recovered: Effect<string, never, never>
```

indicating that all errors have been handled.

### catchSome

Catches and recovers from specific types of errors, allowing you to attempt recovery only for certain errors.

`Effect.catchSome` lets you selectively catch and handle errors of certain
types by providing a recovery effect for specific errors. If the error
matches a condition, recovery is attempted; if not, it doesn't affect the
program. This function doesn't alter the error type, meaning the error type
remains the same as in the original effect.

**Example** (Handling Specific Errors with `Effect.catchSome`)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const recovered = program.pipe(
  Effect.catchSome((error) => {
    // Only handle HttpError errors
    if (error._tag === "HttpError") {
      return Option.some(Effect.succeed("Recovering from HttpError"))
    } else {
      return Option.none()
    }
  })
)
```

In the code above, `Effect.catchSome` takes a function that examines the error and decides whether to attempt recovery or not. If the error matches a specific condition, recovery can be attempted by returning `Option.some(effect)`. If no recovery is possible, you can simply return `Option.none()`.

It's important to note that while `Effect.catchSome` lets you catch specific errors, it doesn't alter the error type itself.
Therefore, the resulting effect will still have the same error type as the original effect:

```ts
const recovered: Effect<string, HttpError | ValidationError, never>
```

### catchIf

Recovers from specific errors based on a predicate.

`Effect.catchIf` works similarly to [`Effect.catchSome`](#catchsome), but it allows you to
recover from errors by providing a predicate function. If the predicate
matches the error, the recovery effect is applied. This function doesn't
alter the error type, so the resulting effect still carries the original
error type unless a user-defined type guard is used to narrow the type.

**Example** (Catching Specific Errors with a Predicate)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, ValidationError, never>
//      ▼
const recovered = program.pipe(
  Effect.catchIf(
    // Only handle HttpError errors
    (error) => error._tag === "HttpError",
    () => Effect.succeed("Recovering from HttpError")
  )
)
```

It's important to note that for TypeScript versions < 5.5, while `Effect.catchIf` lets you catch specific errors, it **doesn't alter the error type** itself.
Therefore, the resulting effect will still have the same error type as the original effect:

```ts
const recovered: Effect<string, HttpError | ValidationError, never>
```

In TypeScript versions >= 5.5, improved type narrowing causes the resulting error type to be inferred as `ValidationError`.

#### Workaround For TypeScript versions < 5.5

If you provide a [user-defined type guard](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#using-type-predicates) instead of a predicate, the resulting error type will be pruned, returning an `Effect<string, ValidationError, never>`:

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, ValidationError, never>
//      ▼
const recovered = program.pipe(
  Effect.catchIf(
    // User-defined type guard
    (error): error is HttpError => error._tag === "HttpError",
    () => Effect.succeed("Recovering from HttpError")
  )
)
```

### catchTag

Catches and handles specific errors by their `_tag` field, which is used as a discriminator.

`Effect.catchTag` is useful when your errors are tagged with a `_tag` field
that identifies the error type. You can use this function to handle specific
error types by matching the `_tag` value. This allows for precise error
handling, ensuring that only specific errors are caught and handled.

The error type must have a `_tag` field to use `Effect.catchTag`. This field
is used to identify and match errors.

**Example** (Handling Errors by Tag)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, ValidationError, never>
//      ▼
const recovered = program.pipe(
  // Only handle HttpError errors
  Effect.catchTag("HttpError", (_HttpError) =>
    Effect.succeed("Recovering from HttpError")
  )
)
```

In the example above, the `Effect.catchTag` function allows us to handle `HttpError` specifically.
If a `HttpError` occurs during the execution of the program, the provided error handler function will be invoked,
and the program will proceed with the recovery logic specified within the handler.

We can observe that the type in the error channel of our program has changed to only show `ValidationError`:

```ts
const recovered: Effect<string, ValidationError, never>
```

indicating that `HttpError` has been handled.

If we also wanted to handle `ValidationError`, we can simply add another `catchTag`:

**Example** (Handling Multiple Error Types with `catchTag`)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, never, never>
//      ▼
const recovered = program.pipe(
  // Handle both HttpError and ValidationError
  Effect.catchTag("HttpError", (_HttpError) =>
    Effect.succeed("Recovering from HttpError")
  ),
  Effect.catchTag("ValidationError", (_ValidationError) =>
    Effect.succeed("Recovering from ValidationError")
  )
)
```

We can observe that the type in the error channel of our program has changed to `never`:

```ts
const recovered: Effect<string, never, never>
```

indicating that all errors have been handled.

> **Caution: Error Type Requirement**
  The error type must have a readonly `_tag` field to use `catchTag`. This
  field is used to identify and match errors.


### catchTags

Handles multiple errors in a single block of code using their `_tag` field.

`Effect.catchTags` is a convenient way to handle multiple error types at
once. Instead of using [`Effect.catchTag`](#catchtag) multiple times, you can pass an
object where each key is an error type's `_tag`, and the value is the handler
for that specific error. This allows you to catch and recover from multiple
error types in a single call.

**Example** (Handling Multiple Tagged Error Types at Once)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{}> {}

//      ┌─── Effect<string, HttpError | ValidationError, never>
//      ▼
const program = Effect.gen(function* () {
  const n1 = yield* Random.next
  const n2 = yield* Random.next
  if (n1 < 0.5) {
    return yield* Effect.fail(new HttpError())
  }
  if (n2 < 0.5) {
    return yield* Effect.fail(new ValidationError())
  }
  return "some result"
})

//      ┌─── Effect<string, never, never>
//      ▼
const recovered = program.pipe(
  Effect.catchTags({
    HttpError: (_HttpError) =>
      Effect.succeed(`Recovering from HttpError`),
    ValidationError: (_ValidationError) =>
      Effect.succeed(`Recovering from ValidationError`)
  })
)
```

This function takes an object where each property represents a specific error `_tag` (`"HttpError"` and `"ValidationError"` in this case),
and the corresponding value is the error handler function to be executed when that particular error occurs.

> **Caution: Error Type Requirement**
  The error type must have a readonly `_tag` field to use `catchTag`. This
  field is used to identify and match errors.


## Effect.fn

The `Effect.fn` function allows you to create traced functions that return an effect. It provides two key features:

- **Stack traces with location details** if an error occurs.
- **Automatic span creation** for [tracing](/docs/observability/tracing/) when a span name is provided.

If a span name is passed as the first argument, the function's execution is tracked using that name.
If no name is provided, stack tracing still works, but spans are not created.

A function can be defined using either:

- A generator function, allowing the use of `yield*` for effect composition.
- A regular function that returns an `Effect`.

**Example** (Creating a Traced Function with a Span Name)

```ts

const myfunc = Effect.fn("myspan")(function* <N extends number>(n: N) {
  yield* Effect.annotateCurrentSpan("n", n) // Attach metadata to the span
  console.log(`got: ${n}`)
  yield* Effect.fail(new Error("Boom!")) // Simulate failure
})

Effect.runFork(myfunc(100).pipe(Effect.catchAllCause(Effect.logError)))
/*
Output:
got: 100
timestamp=... level=ERROR fiber=#0 cause="Error: Boom!
    at <anonymous> (/.../index.ts:6:22) <= Raise location
    at myspan (/.../index.ts:3:23)  <= Definition location
    at myspan (/.../index.ts:9:16)" <= Call location
*/
```

### Exporting Spans for Tracing

`Effect.fn` automatically creates [spans](/docs/observability/tracing/). The spans capture information about the function execution, including metadata and error details.

**Example** (Exporting Spans to the Console)

```ts
import {
  ConsoleSpanExporter,
  BatchSpanProcessor
} from "@opentelemetry/sdk-trace-base"

const myfunc = Effect.fn("myspan")(function* <N extends number>(n: N) {
  yield* Effect.annotateCurrentSpan("n", n)
  console.log(`got: ${n}`)
  yield* Effect.fail(new Error("Boom!"))
})

const program = myfunc(100)

const NodeSdkLive = NodeSdk.layer(() => ({
  resource: { serviceName: "example" },
  // Export span data to the console
  spanProcessor: new BatchSpanProcessor(new ConsoleSpanExporter())
}))

Effect.runFork(program.pipe(Effect.provide(NodeSdkLive)))
/*
Output:
got: 100
{
  resource: {
    attributes: {
      'service.name': 'example',
      'telemetry.sdk.language': 'nodejs',
      'telemetry.sdk.name': '@effect/opentelemetry',
      'telemetry.sdk.version': '1.30.1'
    }
  },
  instrumentationScope: { name: 'example', version: undefined, schemaUrl: undefined },
  traceId: '22801570119e57a6e2aacda3dec9665b',
  parentId: undefined,
  traceState: undefined,
  name: 'myspan',
  id: '7af530c1e01bc0cb',
  kind: 0,
  timestamp: 1741182277518402.2,
  duration: 4300.416,
  attributes: {
    n: 100,
    'code.stacktrace': 'at <anonymous> (/.../index.ts:8:23)\n' +
      'at <anonymous> (/.../index.ts:14:17)'
  },
  status: { code: 2, message: 'Boom!' },
  events: [
    {
      name: 'exception',
      attributes: {
        'exception.type': 'Error',
        'exception.message': 'Boom!',
        'exception.stacktrace': 'Error: Boom!\n' +
          '    at <anonymous> (/.../index.ts:11:22)\n' +
          '    at myspan (/.../index.ts:8:23)\n' +
          '    at myspan (/.../index.ts:14:17)'
      },
      time: [ 1741182277, 522702583 ],
      droppedAttributesCount: 0
    }
  ],
  links: []
}
*/
```

### Using Effect.fn as a pipe Function

`Effect.fn` also acts as a pipe function, allowing you to create a pipeline after
the function definition using the effect returned by the generator function as
the starting value of the pipeline.

**Example** (Creating a Traced Function with a Delay)

```ts

const myfunc = Effect.fn(
  function* (n: number) {
    console.log(`got: ${n}`)
    yield* Effect.fail(new Error("Boom!"))
  },
  // You can access both the created effect and the original arguments
  (effect, n) => Effect.delay(effect, `${n / 100} seconds`)
)

Effect.runFork(myfunc(100).pipe(Effect.catchAllCause(Effect.logError)))
/*
Output:
got: 100
timestamp=... level=ERROR fiber=#0 cause="Error: Boom! (<= after 1 second)
*/
```


---

# [Unexpected Errors](https://effect.website/docs/error-management/unexpected-errors/)

## Overview


There are situations where you may encounter unexpected errors, and you need to decide how to handle them. Effect provides functions to help you deal with such scenarios, allowing you to take appropriate actions when errors occur during the execution of your effects.

## Creating Unrecoverable Errors

In the same way it is possible to leverage combinators such as [Effect.fail](/docs/getting-started/creating-effects/#fail) to create values of type `Effect<never, E, never>` the Effect library provides tools to create defects.

Creating defects is a common necessity when dealing with errors from which it is not possible to recover from a business logic perspective, such as attempting to establish a connection that is refused after multiple retries.

In those cases terminating the execution of the effect and moving into reporting, through an output such as stdout or some external monitoring service, might be the best solution.

The following functions and combinators allow for termination of the effect and are often used to convert values of type `Effect<A, E, R>` into values of type `Effect<A, never, R>` allowing the programmer an escape hatch from having to handle and recover from errors for which there is no sensible way to recover.

### die

Creates an effect that terminates a fiber with a specified error.

Use `Effect.die` when encountering unexpected conditions in your code that should
not be handled as regular errors but instead represent unrecoverable defects.

The `Effect.die` function is used to signal a defect, which represents a critical
and unexpected error in the code. When invoked, it produces an effect that
does not handle the error and instead terminates the fiber.

The error channel of the resulting effect is of type `never`, indicating that
it cannot recover from this failure.

**Example** (Terminating on Division by Zero with a Specified Error)

```ts

const divide = (a: number, b: number) =>
  b === 0
    ? Effect.die(new Error("Cannot divide by zero"))
    : Effect.succeed(a / b)

//      ┌─── Effect<number, never, never>
//      ▼
const program = divide(1, 0)

Effect.runPromise(program).catch(console.error)
/*
Output:
(FiberFailure) Error: Cannot divide by zero
  ...stack trace...
*/
```

### dieMessage

Creates an effect that terminates a fiber with a `RuntimeException` containing the specified message.

Use `Effect.dieMessage` when you want to terminate a fiber due to an unrecoverable
defect and include a clear explanation in the message.

The `Effect.dieMessage` function is used to signal a defect, representing a critical
and unexpected error in the code. When invoked, it produces an effect that
terminates the fiber with a `RuntimeException` carrying the given message.

The resulting effect has an error channel of type `never`, indicating it does
not handle or recover from the error.

**Example** (Terminating on Division by Zero with a Specified Message)

```ts

const divide = (a: number, b: number) =>
  b === 0
    ? Effect.dieMessage("Cannot divide by zero")
    : Effect.succeed(a / b)

//      ┌─── Effect<number, never, never>
//      ▼
const program = divide(1, 0)

Effect.runPromise(program).catch(console.error)
/*
Output:
(FiberFailure) RuntimeException: Cannot divide by zero
  ...stack trace...
*/
```

## Converting Failures to Defects

### orDie

Converts an effect's failure into a fiber termination, removing the error from the effect's type.

Use `Effect.orDie` when failures should be treated as unrecoverable defects and no error handling is required.

The `Effect.orDie` function is used when you encounter errors that you do not want to handle or recover from.
It removes the error type from the effect and ensures that any failure will terminate the fiber.
This is useful for propagating failures as defects, signaling that they should not be handled within the effect.

**Example** (Propagating an Error as a Defect)

```ts

const divide = (a: number, b: number) =>
  b === 0
    ? Effect.fail(new Error("Cannot divide by zero"))
    : Effect.succeed(a / b)

//      ┌─── Effect<number, never, never>
//      ▼
const program = Effect.orDie(divide(1, 0))

Effect.runPromise(program).catch(console.error)
/*
Output:
(FiberFailure) Error: Cannot divide by zero
  ...stack trace...
*/
```

### orDieWith

Converts an effect's failure into a fiber termination with a custom error.

Use `Effect.orDieWith` when failures should terminate the fiber as defects, and you want to customize
the error for clarity or debugging purposes.

The `Effect.orDieWith` function behaves like [Effect.orDie](#ordie), but it allows you to provide a mapping
function to transform the error before terminating the fiber. This is useful for cases where
you want to include a more detailed or user-friendly error when the failure is propagated
as a defect.

**Example** (Customizing Defect)

```ts

const divide = (a: number, b: number) =>
  b === 0
    ? Effect.fail(new Error("Cannot divide by zero"))
    : Effect.succeed(a / b)

//      ┌─── Effect<number, never, never>
//      ▼
const program = Effect.orDieWith(
  divide(1, 0),
  (error) => new Error(`defect: ${error.message}`)
)

Effect.runPromise(program).catch(console.error)
/*
Output:
(FiberFailure) Error: defect: Cannot divide by zero
  ...stack trace...
*/
```

## Catching All Defects

There is no sensible way to recover from defects. The functions we're
about to discuss should be used only at the boundary between Effect and
an external system, to transmit information on a defect for diagnostic
or explanatory purposes.

### exit

The `Effect.exit` function transforms an `Effect<A, E, R>` into an effect that encapsulates both potential failure and success within an [Exit](/docs/data-types/exit/) data type:

```ts
Effect<A, E, R> -> Effect<Exit<A, E>, never, R>
```

This means if you have an effect with the following type:

```ts
Effect<string, HttpError, never>
```

and you call `Effect.exit` on it, the type becomes:

```ts
Effect<Exit<string, HttpError>, never, never>
```

The resulting effect cannot fail because the potential failure is now represented within the `Exit`'s `Failure` type.
The error type of the returned effect is specified as `never`, confirming that the effect is structured to not fail.

By yielding an `Exit`, we gain the ability to "pattern match" on this type to handle both failure and success cases within the generator function.

**Example** (Catching Defects with `Effect.exit`)

```ts

// Simulating a runtime error
const task = Effect.dieMessage("Boom!")

const program = Effect.gen(function* () {
  const exit = yield* Effect.exit(task)
  if (Exit.isFailure(exit)) {
    const cause = exit.cause
    if (
      Cause.isDieType(cause) &&
      Cause.isRuntimeException(cause.defect)
    ) {
      yield* Console.log(
        `RuntimeException defect caught: ${cause.defect.message}`
      )
    } else {
      yield* Console.log("Unknown failure caught.")
    }
  }
})

// We get an Exit.Success because we caught all failures
Effect.runPromiseExit(program).then(console.log)
/*
Output:
RuntimeException defect caught: Boom!
{
  _id: "Exit",
  _tag: "Success",
  value: undefined
}
*/
```

### catchAllDefect

Recovers from all defects using a provided recovery function.

`Effect.catchAllDefect` allows you to handle defects, which are unexpected errors
that usually cause the program to terminate. This function lets you recover
from these defects by providing a function that handles the error.

However, it does not handle expected errors (like those from [Effect.fail](/docs/getting-started/creating-effects/#fail)) or
execution interruptions (like those from [Effect.interrupt](/docs/concurrency/basic-concurrency/#interrupt)).

**Example** (Handling All Defects)

```ts

// Simulating a runtime error
const task = Effect.dieMessage("Boom!")

const program = Effect.catchAllDefect(task, (defect) => {
  if (Cause.isRuntimeException(defect)) {
    return Console.log(
      `RuntimeException defect caught: ${defect.message}`
    )
  }
  return Console.log("Unknown defect caught.")
})

// We get an Exit.Success because we caught all defects
Effect.runPromiseExit(program).then(console.log)
/*
Output:
RuntimeException defect caught: Boom!
{
  _id: "Exit",
  _tag: "Success",
  value: undefined
}
*/
```

> **Tip: When to Recover from Defects**
  Defects are unexpected errors that typically shouldn't be recovered
  from, as they often indicate serious issues. However, in some cases,
  such as dynamically loaded plugins, controlled recovery might be needed.


## Catching Some Defects

### catchSomeDefect

Recovers from specific defects using a provided partial function.

`Effect.catchSomeDefect` allows you to handle specific defects, which are
unexpected errors that can cause the program to stop. It uses a partial
function to catch only certain defects and ignores others.

However, it does not handle expected errors (like those from [Effect.fail](/docs/getting-started/creating-effects/#fail)) or
execution interruptions (like those from [Effect.interrupt](/docs/concurrency/basic-concurrency/#interrupt)).

The function provided to `Effect.catchSomeDefect` acts as a filter and a handler for defects:

- It receives the defect as an input.
- If the defect matches a specific condition (e.g., a certain error type), the function returns
  an `Option.some` containing the recovery logic.
- If the defect does not match, the function returns `Option.none`, allowing the defect to propagate.

**Example** (Handling Specific Defects)

```ts

// Simulating a runtime error
const task = Effect.dieMessage("Boom!")

const program = Effect.catchSomeDefect(task, (defect) => {
  if (Cause.isIllegalArgumentException(defect)) {
    return Option.some(
      Console.log(
        `Caught an IllegalArgumentException defect: ${defect.message}`
      )
    )
  }
  return Option.none()
})

// Since we are only catching IllegalArgumentException
// we will get an Exit.Failure because we simulated a runtime error.
Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Die',
    defect: { _tag: 'RuntimeException' }
  }
}
*/
```

> **Tip: When to Recover from Defects**
  Defects are unexpected errors that typically shouldn't be recovered
  from, as they often indicate serious issues. However, in some cases,
  such as dynamically loaded plugins, controlled recovery might be needed.



---

# [Yieldable Errors](https://effect.website/docs/error-management/yieldable-errors/)

## Overview

Yieldable Errors are special types of errors that can be yielded directly within a generator function using [Effect.gen](/docs/getting-started/using-generators/).
These errors allow you to handle them intuitively, without needing to explicitly invoke [Effect.fail](/docs/getting-started/creating-effects/#fail). This simplifies how you manage custom errors in your code.

## Data.Error

The `Data.Error` constructor provides a way to define a base class for yieldable errors.

**Example** (Creating and Yielding a Custom Error)

```ts

// Define a custom error class extending Data.Error
class MyError extends Data.Error<{ message: string }> {}

export const program = Effect.gen(function* () {
  // Yield a custom error (equivalent to failing with MyError)
  yield* new MyError({ message: "Oh no!" })
})

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: { message: 'Oh no!' } }
}
*/
```

## Data.TaggedError

The `Data.TaggedError` constructor lets you define custom yieldable errors with unique tags. Each error has a `_tag` property, allowing you to easily distinguish between different error types. This makes it convenient to handle specific tagged errors using functions like [Effect.catchTag](/docs/error-management/expected-errors/#catchtag) or [Effect.catchTags](/docs/error-management/expected-errors/#catchtags).

**Example** (Handling Multiple Tagged Errors)

```ts

// An error with _tag: "Foo"
class FooError extends Data.TaggedError("Foo")<{
  message: string
}> {}

// An error with _tag: "Bar"
class BarError extends Data.TaggedError("Bar")<{
  randomNumber: number
}> {}

const program = Effect.gen(function* () {
  const n = yield* Random.next
  return n > 0.5
    ? "yay!"
    : n < 0.2
    ? yield* new FooError({ message: "Oh no!" })
    : yield* new BarError({ randomNumber: n })
}).pipe(
  // Handle different tagged errors using catchTags
  Effect.catchTags({
    Foo: (error) => Effect.succeed(`Foo error: ${error.message}`),
    Bar: (error) => Effect.succeed(`Bar error: ${error.randomNumber}`)
  })
)

Effect.runPromise(program).then(console.log, console.error)
/*
Example Output (n < 0.2):
Foo error: Oh no!
*/
```


---

# [Error Accumulation](https://effect.website/docs/error-management/error-accumulation/)

## Overview


Sequential combinators such as [Effect.zip](/docs/getting-started/control-flow/#zip), [Effect.all](/docs/getting-started/control-flow/#all) and [Effect.forEach](/docs/getting-started/control-flow/#foreach) have a "fail fast" policy when it comes to error management. This means that they stop and return immediately when they encounter the first error.

Here's an example using `Effect.zip`, which stops at the first failure and only shows the first error:

**Example** (Fail Fast with `Effect.zip`)

```ts

const task1 = Console.log("task1").pipe(Effect.as(1))
const task2 = Effect.fail("Oh uh!").pipe(Effect.as(2))
const task3 = Console.log("task2").pipe(Effect.as(3))
const task4 = Effect.fail("Oh no!").pipe(Effect.as(4))

const program = task1.pipe(
  Effect.zip(task2),
  Effect.zip(task3),
  Effect.zip(task4)
)

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
task1
(FiberFailure) Error: Oh uh!
*/
```

The `Effect.forEach` function behaves similarly. It applies an effectful operation to each element in a collection, but will stop when it hits the first error:

**Example** (Fail Fast with `Effect.forEach`)

```ts

const program = Effect.forEach([1, 2, 3, 4, 5], (n) => {
  if (n < 4) {
    return Console.log(`item ${n}`).pipe(Effect.as(n))
  } else {
    return Effect.fail(`${n} is not less that 4`)
  }
})

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
item 1
item 2
item 3
(FiberFailure) Error: 4 is not less that 4
*/
```

However, there are cases where you may want to collect all errors rather than fail fast. In these situations, you can use functions that accumulate both successes and errors.

## validate

The `Effect.validate` function is similar to `Effect.zip`, but it continues combining effects even after encountering errors, accumulating both successes and failures.

**Example** (Validating and Collecting Errors)

```ts

const task1 = Console.log("task1").pipe(Effect.as(1))
const task2 = Effect.fail("Oh uh!").pipe(Effect.as(2))
const task3 = Console.log("task2").pipe(Effect.as(3))
const task4 = Effect.fail("Oh no!").pipe(Effect.as(4))

const program = task1.pipe(
  Effect.validate(task2),
  Effect.validate(task3),
  Effect.validate(task4)
)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
task1
task2
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Sequential',
    left: { _id: 'Cause', _tag: 'Fail', failure: 'Oh uh!' },
    right: { _id: 'Cause', _tag: 'Fail', failure: 'Oh no!' }
  }
}
*/
```

## validateAll

The `Effect.validateAll` function is similar to the `Effect.forEach` function. It transforms all elements of a collection using the provided effectful operation, but it collects all errors in the error channel, as well as the success values in the success channel.

```ts

//      ┌─── Effect<number[], string[], never>
//      ▼
const program = Effect.validateAll([1, 2, 3, 4, 5], (n) => {
  if (n < 4) {
    return Console.log(`item ${n}`).pipe(Effect.as(n))
  } else {
    return Effect.fail(`${n} is not less that 4`)
  }
})

Effect.runPromiseExit(program).then(console.log)
/*
Output:
item 1
item 2
item 3
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: [ '4 is not less that 4', '5 is not less that 4' ]
  }
}
*/
```

> **Caution: Loss of Successes**
  Note that this function is lossy, which means that if there are any
  errors, all successes will be lost. If you need to preserve both
  successes and failures, consider using [Effect.partition](#partition).


## validateFirst

The `Effect.validateFirst` function is similar to `Effect.validateAll` but it returns the first successful result, or all errors if none succeed.

**Example** (Returning the First Success)

```ts

//      ┌─── Effect<number, string[], never>
//      ▼
const program = Effect.validateFirst([1, 2, 3, 4, 5], (n) => {
  if (n < 4) {
    return Effect.fail(`${n} is not less that 4`)
  } else {
    return Console.log(`item ${n}`).pipe(Effect.as(n))
  }
})

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
item 4
4
*/
```

Notice that `Effect.validateFirst` returns a single `number` as the success type, rather than an array of results like `Effect.validateAll`.

## partition

The `Effect.partition` function processes an iterable and applies an effectful function to each element. It returns a tuple, where the first part contains all the failures, and the second part contains all the successes.

**Example** (Partitioning Successes and Failures)

```ts

//      ┌─── Effect<[string[], number[]], never, never>
//      ▼
const program = Effect.partition([0, 1, 2, 3, 4], (n) => {
  if (n % 2 === 0) {
    return Effect.succeed(n)
  } else {
    return Effect.fail(`${n} is not even`)
  }
})

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
[ [ '1 is not even', '3 is not even' ], [ 0, 2, 4 ] ]
*/
```

This operator is an unexceptional effect, meaning the error channel type is `never`. Failures are collected without stopping the effect, so the entire operation completes and returns both errors and successes.


---

# [Error Channel Operations](https://effect.website/docs/error-management/error-channel-operations/)

## Overview


In Effect you can perform various operations on the error channel of effects. These operations allow you to transform, inspect, and handle errors in different ways. Let's explore some of these operations.

## Map Operations

### mapError

The `Effect.mapError` function is used when you need to transform or modify an error produced by an effect, without affecting the success value. This can be helpful when you want to add extra information to the error or change its type.

**Example** (Mapping an Error)

Here, the error type changes from `string` to `Error`.

```ts

//      ┌─── Effect<number, string, never>
//      ▼
const simulatedTask = Effect.fail("Oh no!").pipe(Effect.as(1))

//      ┌─── Effect<number, Error, never>
//      ▼
const mapped = Effect.mapError(
  simulatedTask,
  (message) => new Error(message)
)
```

> **Note**
  It's important to note that using the `Effect.mapError` function does
  not change the overall success or failure of the effect. It only
  transforms the values in the error channel while preserving the effect's
  original success or failure status.


### mapBoth

The `Effect.mapBoth` function allows you to apply transformations to both channels: the error channel and the success channel of an effect. It takes two map functions as arguments: one for the error channel and the other for the success channel.

**Example** (Mapping Both Success and Error)

```ts

//      ┌─── Effect<number, string, never>
//      ▼
const simulatedTask = Effect.fail("Oh no!").pipe(Effect.as(1))

//      ┌─── Effect<boolean, Error, never>
//      ▼
const modified = Effect.mapBoth(simulatedTask, {
  onFailure: (message) => new Error(message),
  onSuccess: (n) => n > 0
})
```

> **Note**
  It's important to note that using the `Effect.mapBoth` function does not
  change the overall success or failure of the effect. It only transforms
  the values in the error and success channels while preserving the
  effect's original success or failure status.


## Filtering the Success Channel

The Effect library provides several operators to filter values on the success channel based on a given predicate.

These operators offer different strategies for handling cases where the predicate fails:

| API                                  | Description                                                                                                                                                                                                                                       |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `filterOrFail`                       | This operator filters the values on the success channel based on a predicate. If the predicate fails for any value, the original effect fails with an error.                                                                                      |
| `filterOrDie` / `filterOrDieMessage` | These operators also filter the values on the success channel based on a predicate. If the predicate fails for any value, the original effect terminates abruptly. The `filterOrDieMessage` variant allows you to provide a custom error message. |
| `filterOrElse`                       | This operator filters the values on the success channel based on a predicate. If the predicate fails for any value, an alternative effect is executed instead.                                                                                    |

**Example** (Filtering Success Values)

```ts

// Fail with a custom error if predicate is false
const task1 = Effect.filterOrFail(
  Random.nextRange(-1, 1),
  (n) => n >= 0,
  () => "random number is negative"
)

// Die with a custom exception if predicate is false
const task2 = Effect.filterOrDie(
  Random.nextRange(-1, 1),
  (n) => n >= 0,
  () => new Cause.IllegalArgumentException("random number is negative")
)

// Die with a custom error message if predicate is false
const task3 = Effect.filterOrDieMessage(
  Random.nextRange(-1, 1),
  (n) => n >= 0,
  "random number is negative"
)

// Run an alternative effect if predicate is false
const task4 = Effect.filterOrElse(
  Random.nextRange(-1, 1),
  (n) => n >= 0,
  () => task3
)
```

It's important to note that depending on the specific filtering operator used, the effect can either fail, terminate abruptly, or execute an alternative effect when the predicate fails. Choose the appropriate operator based on your desired error handling strategy and program logic.

The filtering APIs can also be combined with [user-defined type guards](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#using-type-predicates) to improve type safety and code clarity. This ensures that only valid types pass through.

**Example** (Using a Type Guard)

```ts

// Define a user interface
interface User {
  readonly name: string
}

// Simulate an asynchronous authentication function
declare const auth: () => Promise<User | null>

const program = pipe(
  Effect.promise(() => auth()),
  // Use filterOrFail with a custom type guard to ensure user is not null
  Effect.filterOrFail(
    (user): user is User => user !== null, // Type guard
    () => new Error("Unauthorized")
  ),
  // 'user' now has the type `User` (not `User | null`)
  Effect.andThen((user) => user.name)
)
```

In the example above, a guard is used within the `filterOrFail` API to ensure that the `user` is of type `User` rather than `User | null`.

If you prefer, you can utilize a pre-made guard like [Predicate.isNotNull](https://effect-ts.github.io/effect/effect/Predicate.ts.html#isnotnull) for simplicity and consistency.

## Inspecting Errors

Similar to [tapping](/docs/getting-started/building-pipelines/#tap) for success values, Effect provides several operators for inspecting error values.
These operators allow developers to observe failures or underlying issues without modifying the outcome.

### tapError

Executes an effectful operation to inspect the failure of an effect without altering it.

**Example** (Inspecting Errors)

```ts

// Simulate a task that fails with an error
const task: Effect.Effect<number, string> = Effect.fail("NetworkError")

// Use tapError to log the error message when the task fails
const tapping = Effect.tapError(task, (error) =>
  Console.log(`expected error: ${error}`)
)

Effect.runFork(tapping)
/*
Output:
expected error: NetworkError
*/
```

### tapErrorTag

This function allows you to inspect errors that match a specific tag, helping you handle different error types more precisely.

**Example** (Inspecting Tagged Errors)

```ts

class NetworkError extends Data.TaggedError("NetworkError")<{
  readonly statusCode: number
}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{
  readonly field: string
}> {}

// Create a task that fails with a NetworkError
const task: Effect.Effect<number, NetworkError | ValidationError> =
  Effect.fail(new NetworkError({ statusCode: 504 }))

// Use tapErrorTag to inspect only NetworkError types
// and log the status code
const tapping = Effect.tapErrorTag(task, "NetworkError", (error) =>
  Console.log(`expected error: ${error.statusCode}`)
)

Effect.runFork(tapping)
/*
Output:
expected error: 504
*/
```

### tapErrorCause

This function inspects the complete cause of an error, including failures and defects.

**Example** (Inspecting Error Causes)

```ts

// Create a task that fails with a NetworkError
const task1: Effect.Effect<number, string> = Effect.fail("NetworkError")

const tapping1 = Effect.tapErrorCause(task1, (cause) =>
  Console.log(`error cause: ${cause}`)
)

Effect.runFork(tapping1)
/*
Output:
error cause: Error: NetworkError
*/

// Simulate a severe failure in the system
const task2: Effect.Effect<number, string> = Effect.dieMessage(
  "Something went wrong"
)

const tapping2 = Effect.tapErrorCause(task2, (cause) =>
  Console.log(`error cause: ${cause}`)
)

Effect.runFork(tapping2)
/*
Output:
error cause: RuntimeException: Something went wrong
  ... stack trace ...
*/
```

### tapDefect

Specifically inspects non-recoverable failures or defects in an effect (i.e., one or more [Die](/docs/data-types/cause/#die) causes).

**Example** (Inspecting Defects)

```ts

// Simulate a task that fails with a recoverable error
const task1: Effect.Effect<number, string> = Effect.fail("NetworkError")

// tapDefect won't log anything because NetworkError is not a defect
const tapping1 = Effect.tapDefect(task1, (cause) =>
  Console.log(`defect: ${cause}`)
)

Effect.runFork(tapping1)
/*
No Output
*/

// Simulate a severe failure in the system
const task2: Effect.Effect<number, string> = Effect.dieMessage(
  "Something went wrong"
)

// Log the defect using tapDefect
const tapping2 = Effect.tapDefect(task2, (cause) =>
  Console.log(`defect: ${cause}`)
)

Effect.runFork(tapping2)
/*
Output:
defect: RuntimeException: Something went wrong
  ... stack trace ...
*/
```

### tapBoth

Inspects both success and failure outcomes of an effect, performing different actions based on the result.

**Example** (Inspecting Both Success and Failure)

```ts

// Simulate a task that might fail
const task = Effect.filterOrFail(
  Random.nextRange(-1, 1),
  (n) => n >= 0,
  () => "random number is negative"
)

// Use tapBoth to log both success and failure outcomes
const tapping = Effect.tapBoth(task, {
  onFailure: (error) => Console.log(`failure: ${error}`),
  onSuccess: (randomNumber) =>
    Console.log(`random number: ${randomNumber}`)
})

Effect.runFork(tapping)
/*
Example Output:
failure: random number is negative
*/
```

## Exposing Errors in The Success Channel

The `Effect.either` function transforms an `Effect<A, E, R>` into an effect that encapsulates both potential failure and success within an [Either](/docs/data-types/either/) data type:

```ts
Effect<A, E, R> -> Effect<Either<A, E>, never, R>
```

This means if you have an effect with the following type:

```ts
Effect<string, HttpError, never>
```

and you call `Effect.either` on it, the type becomes:

```ts
Effect<Either<string, HttpError>, never, never>
```

The resulting effect cannot fail because the potential failure is now represented within the `Either`'s `Left` type.
The error type of the returned `Effect` is specified as `never`, confirming that the effect is structured to not fail.

This function becomes especially useful when recovering from effects that may fail when using [Effect.gen](/docs/getting-started/using-generators/#understanding-effectgen):

**Example** (Using `Effect.either` to Handle Errors)

```ts

// Simulate a task that fails
//
//      ┌─── Either<number, string, never>
//      ▼
const program = Effect.fail("Oh uh!").pipe(Effect.as(2))

//      ┌─── Either<number, never, never>
//      ▼
const recovered = Effect.gen(function* () {
  //      ┌─── Either<number, string>
  //      ▼
  const failureOrSuccess = yield* Effect.either(program)
  if (Either.isLeft(failureOrSuccess)) {
    const error = failureOrSuccess.left
    yield* Console.log(`failure: ${error}`)
    return 0
  } else {
    const value = failureOrSuccess.right
    yield* Console.log(`success: ${value}`)
    return value
  }
})

Effect.runPromise(recovered).then(console.log)
/*
Output:
failure: Oh uh!
0
*/
```

## Exposing the Cause in The Success Channel

You can use the `Effect.cause` function to expose the cause of an effect, which is a more detailed representation of failures, including error messages and defects.

**Example** (Logging the Cause of Failure)

```ts

//      ┌─── Effect<number, string, never>
//      ▼
const program = Effect.fail("Oh uh!").pipe(Effect.as(2))

//      ┌─── Effect<void, never, never>
//      ▼
const recovered = Effect.gen(function* () {
  const cause = yield* Effect.cause(program)
  yield* Console.log(cause)
})
```

## Merging the Error Channel into the Success Channel

The `Effect.merge` function allows you to combine the error channel with the success channel. This results in an effect that never fails; instead, both successes and errors are handled as values in the success channel.

**Example** (Combining Error and Success Channels)

```ts

//      ┌─── Effect<number, string, never>
//      ▼
const program = Effect.fail("Oh uh!").pipe(Effect.as(2))

//      ┌─── Effect<number | string, never, never>
//      ▼
const recovered = Effect.merge(program)
```

## Flipping Error and Success Channels

The `Effect.flip` function allows you to switch the error and success channels of an effect. This means that what was previously a success becomes the error, and vice versa.

**Example** (Swapping Error and Success Channels)

```ts

//      ┌─── Effect<number, string, never>
//      ▼
const program = Effect.fail("Oh uh!").pipe(Effect.as(2))

//      ┌─── Effect<string, number, never>
//      ▼
const flipped = Effect.flip(program)
```


---

# [Fallback](https://effect.website/docs/error-management/fallback/)

## Overview


This page explains various techniques for handling failures and creating fallback mechanisms in the Effect library.

## orElse

`Effect.orElse` allows you to attempt to run an effect, and if it fails, you
can provide a fallback effect to run instead.

This is useful for handling failures gracefully by defining an alternative effect to execute if the first
one encounters an error.

**Example** (Handling Fallback with `Effect.orElse`)

```ts

const success = Effect.succeed("success")
const failure = Effect.fail("failure")
const fallback = Effect.succeed("fallback")

// Try the success effect first, fallback is not used
const program1 = Effect.orElse(success, () => fallback)
console.log(Effect.runSync(program1))
// Output: "success"

// Try the failure effect first, fallback is used
const program2 = Effect.orElse(failure, () => fallback)
console.log(Effect.runSync(program2))
// Output: "fallback"
```

## orElseFail

`Effect.orElseFail` allows you to replace the failure from one effect with a
custom failure value. If the effect fails, you can provide a new failure to
be returned instead of the original one.

This function only applies to failed effects. If the effect
succeeds, it will remain unaffected.

**Example** (Replacing Failure with `Effect.orElseFail`)

```ts

const validate = (age: number): Effect.Effect<number, string> => {
  if (age < 0) {
    return Effect.fail("NegativeAgeError")
  } else if (age < 18) {
    return Effect.fail("IllegalAgeError")
  } else {
    return Effect.succeed(age)
  }
}

const program = Effect.orElseFail(validate(-1), () => "invalid age")

console.log(Effect.runSyncExit(program))
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'invalid age' }
}
*/
```

## orElseSucceed

`Effect.orElseSucceed` allows you to replace the failure of an effect with a
success value. If the effect fails, it will instead succeed with the provided
value, ensuring the effect always completes successfully.

This is useful when you want to guarantee a successful result regardless of whether the original
effect failed.

The function ensures that any failure is effectively "swallowed" and replaced
by a successful value, which can be helpful for providing default values in
case of failure.

This function only applies to failed effects. If the effect
already succeeds, it will remain unchanged.

**Example** (Replacing Failure with Success using `Effect.orElseSucceed`)

```ts

const validate = (age: number): Effect.Effect<number, string> => {
  if (age < 0) {
    return Effect.fail("NegativeAgeError")
  } else if (age < 18) {
    return Effect.fail("IllegalAgeError")
  } else {
    return Effect.succeed(age)
  }
}

const program = Effect.orElseSucceed(validate(-1), () => 18)

console.log(Effect.runSyncExit(program))
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: 18 }
*/
```

## firstSuccessOf

`Effect.firstSuccessOf` allows you to try multiple effects in sequence, and
as soon as one of them succeeds, it returns that result. If all effects fail,
it returns the error of the last effect in the list.

This is useful when you
have several potential alternatives and want to use the first one that works.

This function is sequential, meaning that the `Effect` values in the iterable
will be executed in sequence, and the first one that succeeds will determine
the outcome of the resulting `Effect` value.

> **Caution: Empty Collection Error**
  If the collection provided to the `Effect.firstSuccessOf` function is
  empty, it will throw an `IllegalArgumentException` error.


**Example** (Finding Configuration with Fallbacks)

In this example, we try to retrieve a configuration from different nodes. If the primary node fails, we fall back to other nodes until we find a successful configuration.

```ts

interface Config {
  host: string
  port: number
  apiKey: string
}

// Create a configuration object with sample values
const makeConfig = (name: string): Config => ({
  host: `${name}.example.com`,
  port: 8080,
  apiKey: "12345-abcde"
})

// Simulate retrieving configuration from a remote node
const remoteConfig = (name: string): Effect.Effect<Config, Error> =>
  Effect.gen(function* () {
    // Simulate node3 being the only one with available config
    if (name === "node3") {
      yield* Console.log(`Config for ${name} found`)
      return makeConfig(name)
    } else {
      yield* Console.log(`Unavailable config for ${name}`)
      return yield* Effect.fail(new Error(`Config not found for ${name}`))
    }
  })

// Define the master configuration and potential fallback nodes
const masterConfig = remoteConfig("master")
const nodeConfigs = ["node1", "node2", "node3", "node4"].map(remoteConfig)

// Attempt to find a working configuration,
// starting with the master and then falling back to other nodes
const config = Effect.firstSuccessOf([masterConfig, ...nodeConfigs])

// Run the effect to retrieve the configuration
const result = Effect.runSync(config)

console.log(result)
/*
Output:
Unavailable config for master
Unavailable config for node1
Unavailable config for node2
Config for node3 found
{ host: 'node3.example.com', port: 8080, apiKey: '12345-abcde' }
*/
```


---

# [Matching](https://effect.website/docs/error-management/matching/)

## Overview


In the Effect module, similar to other modules like [Option](/docs/data-types/option/#pattern-matching) and [Exit](/docs/data-types/exit/#pattern-matching), we have a `Effect.match` function that allows us to handle different cases simultaneously.
Additionally, Effect provides various functions to manage both success and failure scenarios in effectful programs.

## match

`Effect.match` lets you define custom handlers for both success and failure
scenarios. You provide separate functions to handle each case, allowing you
to process the result if the effect succeeds, or handle the error if the
effect fails.

This is useful for structuring your code to respond differently to success or failure without triggering side effects.

**Example** (Handling Both Success and Failure Cases)

```ts

const success: Effect.Effect<number, Error> = Effect.succeed(42)

const program1 = Effect.match(success, {
  onFailure: (error) => `failure: ${error.message}`,
  onSuccess: (value) => `success: ${value}`
})

// Run and log the result of the successful effect
Effect.runPromise(program1).then(console.log)
// Output: "success: 42"

const failure: Effect.Effect<number, Error> = Effect.fail(
  new Error("Uh oh!")
)

const program2 = Effect.match(failure, {
  onFailure: (error) => `failure: ${error.message}`,
  onSuccess: (value) => `success: ${value}`
})

// Run and log the result of the failed effect
Effect.runPromise(program2).then(console.log)
// Output: "failure: Uh oh!"
```

## ignore

`Effect.ignore` allows you to run an effect without caring about its result,
whether it succeeds or fails.

This is useful when you only care about the side effects of the effect and do not need to handle or process its outcome.

**Example** (Using `Effect.ignore` to Discard Values)

```ts

//      ┌─── Effect<number, string, never>
//      ▼
const task = Effect.fail("Uh oh!").pipe(Effect.as(5))

//      ┌─── Effect<void, never, never>
//      ▼
const program = Effect.ignore(task)
```

## matchEffect

The `Effect.matchEffect` function is similar to [Effect.match](#match), but it
enables you to perform side effects in the handlers for both success and
failure outcomes.

This is useful when you need to execute additional actions,
like logging or notifying users, based on whether an effect succeeds or
fails.

**Example** (Handling Success and Failure with Side Effects)

```ts

const success: Effect.Effect<number, Error> = Effect.succeed(42)
const failure: Effect.Effect<number, Error> = Effect.fail(
  new Error("Uh oh!")
)

const program1 = Effect.matchEffect(success, {
  onFailure: (error) =>
    Effect.succeed(`failure: ${error.message}`).pipe(
      Effect.tap(Effect.log)
    ),
  onSuccess: (value) =>
    Effect.succeed(`success: ${value}`).pipe(Effect.tap(Effect.log))
})

console.log(Effect.runSync(program1))
/*
Output:
timestamp=... level=INFO fiber=#0 message="success: 42"
success: 42
*/

const program2 = Effect.matchEffect(failure, {
  onFailure: (error) =>
    Effect.succeed(`failure: ${error.message}`).pipe(
      Effect.tap(Effect.log)
    ),
  onSuccess: (value) =>
    Effect.succeed(`success: ${value}`).pipe(Effect.tap(Effect.log))
})

console.log(Effect.runSync(program2))
/*
Output:
timestamp=... level=INFO fiber=#1 message="failure: Uh oh!"
failure: Uh oh!
*/
```

## matchCause

The `Effect.matchCause` function allows you to handle failures with access to
the full [cause](/docs/data-types/cause/) of the failure within a fiber.

This is useful for differentiating between different types of errors, such as regular failures,
defects, or interruptions. You can provide specific handling logic for each
failure type based on the cause.

**Example** (Handling Different Failure Causes)

```ts

const task: Effect.Effect<number, Error> = Effect.die("Uh oh!")

const program = Effect.matchCause(task, {
  onFailure: (cause) => {
    switch (cause._tag) {
      case "Fail":
        // Handle standard failure
        return `Fail: ${cause.error.message}`
      case "Die":
        // Handle defects (unexpected errors)
        return `Die: ${cause.defect}`
      case "Interrupt":
        // Handle interruption
        return `${cause.fiberId} interrupted!`
    }
    // Fallback for other causes
    return "failed due to other causes"
  },
  onSuccess: (value) =>
    // task completes successfully
    `succeeded with ${value} value`
})

Effect.runPromise(program).then(console.log)
// Output: "Die: Uh oh!"
```

## matchCauseEffect

The `Effect.matchCauseEffect` function works similarly to [Effect.matchCause](#matchcause),
but it also allows you to perform additional side effects based on the
failure cause.

This function provides access to the complete [cause](/docs/data-types/cause/) of the
failure, making it possible to differentiate between various failure types,
and allows you to respond accordingly while performing side effects (like
logging or other operations).

**Example** (Handling Different Failure Causes with Side Effects)

```ts

const task: Effect.Effect<number, Error> = Effect.die("Uh oh!")

const program = Effect.matchCauseEffect(task, {
  onFailure: (cause) => {
    switch (cause._tag) {
      case "Fail":
        // Handle standard failure with a logged message
        return Console.log(`Fail: ${cause.error.message}`)
      case "Die":
        // Handle defects (unexpected errors) by logging the defect
        return Console.log(`Die: ${cause.defect}`)
      case "Interrupt":
        // Handle interruption and log the fiberId that was interrupted
        return Console.log(`${cause.fiberId} interrupted!`)
    }
    // Fallback for other causes
    return Console.log("failed due to other causes")
  },
  onSuccess: (value) =>
    // Log success if the task completes successfully
    Console.log(`succeeded with ${value} value`)
})

Effect.runPromise(program)
// Output: "Die: Uh oh!"
```


---

# [Parallel and Sequential Errors](https://effect.website/docs/error-management/parallel-and-sequential-errors/)

## Overview


When working with Effect, if an error occurs, the default behavior is to fail with the first error encountered.

**Example** (Failing on the First Error)

Here, the program fails with the first error it encounters, `"Oh uh!"`.

```ts

const fail = Effect.fail("Oh uh!")
const die = Effect.dieMessage("Boom!")

// Run both effects sequentially
const program = Effect.all([fail, die])

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Oh uh!' }
}
*/
```

## Parallel Errors

In some cases, you might encounter multiple errors, especially during concurrent computations. When tasks are run concurrently, multiple errors can happen at the same time.

**Example** (Handling Multiple Errors in Concurrent Computations)

In this example, both the `fail` and `die` effects are executed concurrently. Since both fail, the program will report multiple errors in the output.

```ts

const fail = Effect.fail("Oh uh!")
const die = Effect.dieMessage("Boom!")

// Run both effects concurrently
const program = Effect.all([fail, die], {
  concurrency: "unbounded"
}).pipe(Effect.asVoid)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Parallel',
    left: { _id: 'Cause', _tag: 'Fail', failure: 'Oh uh!' },
    right: { _id: 'Cause', _tag: 'Die', defect: [Object] }
  }
}
*/
```

### parallelErrors

Effect provides a function called `Effect.parallelErrors` that captures all failure errors from concurrent operations in the error channel.

**Example** (Capturing Multiple Concurrent Failures)

In this example, `Effect.parallelErrors` combines the errors from `fail1` and `fail2` into a single error.

```ts

const fail1 = Effect.fail("Oh uh!")
const fail2 = Effect.fail("Oh no!")
const die = Effect.dieMessage("Boom!")

// Run all effects concurrently and capture all errors
const program = Effect.all([fail1, fail2, die], {
  concurrency: "unbounded"
}).pipe(Effect.asVoid, Effect.parallelErrors)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: [ 'Oh uh!', 'Oh no!' ] }
}
*/
```

> **Note: Applicability**
  Note that `Effect.parallelErrors` is only for failures, not defects or
  interruptions.


## Sequential Errors

When working with resource-safety operators like `Effect.ensuring`, you may encounter multiple sequential errors.
This happens because regardless of whether the original effect has any errors or not, the finalizer is uninterruptible and will always run.

**Example** (Handling Multiple Sequential Errors)

In this example, both `fail` and the finalizer `die` result in sequential errors, and both are captured.

```ts

// Simulate an effect that fails
const fail = Effect.fail("Oh uh!")

// Simulate a finalizer that causes a defect
const die = Effect.dieMessage("Boom!")

// The finalizer 'die' will always run, even if 'fail' fails
const program = fail.pipe(Effect.ensuring(die))

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Sequential',
    left: { _id: 'Cause', _tag: 'Fail', failure: 'Oh uh!' },
    right: { _id: 'Cause', _tag: 'Die', defect: [Object] }
  }
}
*/
```


---

# [Retrying](https://effect.website/docs/error-management/retrying/)

## Overview


In software development, it's common to encounter situations where an operation may fail temporarily due to various factors such as network issues, resource unavailability, or external dependencies. In such cases, it's often desirable to retry the operation automatically, allowing it to succeed eventually.

Retrying is a powerful mechanism to handle transient failures and ensure the successful execution of critical operations. In Effect retrying is made simple and flexible with built-in functions and scheduling strategies.

In this guide, we will explore the concept of retrying in Effect and learn how to use the `retry` and `retryOrElse` functions to handle failure scenarios. We'll see how to define retry policies using schedules, which dictate when and how many times the operation should be retried.

Whether you're working on network requests, database interactions, or any other potentially error-prone operations, mastering the retrying capabilities of effect can significantly enhance the resilience and reliability of your applications.

## retry

The `Effect.retry` function takes an effect and a [Schedule](/docs/scheduling/introduction/) policy, and will automatically retry the effect if it fails, following the rules of the policy.

If the effect ultimately succeeds, the result will be returned.

If the maximum retries are exhausted and the effect still fails, the failure is propagated.

This can be useful when dealing with intermittent failures, such as network issues or temporary resource unavailability. By defining a retry policy, you can control the number of retries, the delay between them, and when to stop retrying.

**Example** (Retrying with a Fixed Delay)

```ts

let count = 0

// Simulates an effect with possible failures
const task = Effect.async<string, Error>((resume) => {
  if (count <= 2) {
    count++
    console.log("failure")
    resume(Effect.fail(new Error()))
  } else {
    console.log("success")
    resume(Effect.succeed("yay!"))
  }
})

// Define a repetition policy using a fixed delay between retries
const policy = Schedule.fixed("100 millis")

const repeated = Effect.retry(task, policy)

Effect.runPromise(repeated).then(console.log)
/*
Output:
failure
failure
failure
success
yay!
*/
```

### Retrying n Times Immediately

You can also retry a failing effect a set number of times with a simpler policy that retries immediately:

**Example** (Retrying a Task up to 5 times)

```ts

let count = 0

// Simulates an effect with possible failures
const task = Effect.async<string, Error>((resume) => {
  if (count <= 2) {
    count++
    console.log("failure")
    resume(Effect.fail(new Error()))
  } else {
    console.log("success")
    resume(Effect.succeed("yay!"))
  }
})

// Retry the task up to 5 times
Effect.runPromise(Effect.retry(task, { times: 5 }))
/*
Output:
failure
failure
failure
success
*/
```

### Retrying Based on a Condition

You can customize how retries are managed by specifying conditions. Use the `until` or `while` options to control when retries stop.

**Example** (Retrying Until a Specific Condition is Met)

```ts

let count = 0

// Define an effect that simulates varying error on each invocation
const action = Effect.failSync(() => {
  console.log(`Action called ${++count} time(s)`)
  return `Error ${count}`
})

// Retry the action until a specific condition is met
const program = Effect.retry(action, {
  until: (err) => err === "Error 3"
})

Effect.runPromiseExit(program).then(console.log)
/*
Output:
Action called 1 time(s)
Action called 2 time(s)
Action called 3 time(s)
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Error 3' }
}
*/
```

> **Tip: Alternative**
  You can also use
  [Effect.repeat](/docs/scheduling/repetition/#repeating-based-on-a-condition)
  if your retry condition is based on successful outcomes rather than
  errors.


## retryOrElse

The `Effect.retryOrElse` function attempts to retry a failing effect multiple times according to a defined [Schedule](/docs/scheduling/introduction/) policy.

If the retries are exhausted and the effect still fails, it runs a fallback effect instead.

This function is useful when you want to handle failures gracefully by specifying an alternative action after repeated failures.

**Example** (Retrying with Fallback)

```ts

let count = 0

// Simulates an effect with possible failures
const task = Effect.async<string, Error>((resume) => {
  if (count <= 2) {
    count++
    console.log("failure")
    resume(Effect.fail(new Error()))
  } else {
    console.log("success")
    resume(Effect.succeed("yay!"))
  }
})

// Retry the task with a delay between retries and a maximum of 2 retries
const policy = Schedule.addDelay(Schedule.recurs(2), () => "100 millis")

// If all retries fail, run the fallback effect
const repeated = Effect.retryOrElse(
  task,
  policy,
  // fallback
  () => Console.log("orElse").pipe(Effect.as("default value"))
)

Effect.runPromise(repeated).then(console.log)
/*
Output:
failure
failure
failure
orElse
default value
*/
```


---

# [Timing Out](https://effect.website/docs/error-management/timing-out/)

## Overview


In programming, it's common to deal with tasks that may take some time to complete. Often, we want to enforce a limit on how long we're willing to wait for these tasks. The `Effect.timeout` function helps by placing a time constraint on an operation, ensuring it doesn't run indefinitely.

## Basic Usage

### timeout

The `Effect.timeout` function employs a [Duration](/docs/data-types/duration/) parameter to establish a time limit on an operation. If the operation exceeds this limit, a `TimeoutException` is triggered, indicating a timeout has occurred.

**Example** (Setting a Timeout)

Here, the task completes within the timeout duration, so the result is returned successfully.

```ts

const task = Effect.gen(function* () {
  console.log("Start processing...")
  yield* Effect.sleep("2 seconds") // Simulates a delay in processing
  console.log("Processing complete.")
  return "Result"
})

// Sets a 3-second timeout for the task
const timedEffect = task.pipe(Effect.timeout("3 seconds"))

// Output will show that the task completes successfully
// as it falls within the timeout duration
Effect.runPromiseExit(timedEffect).then(console.log)
/*
Output:
Start processing...
Processing complete.
{ _id: 'Exit', _tag: 'Success', value: 'Result' }
*/
```

If the operation exceeds the specified duration, a `TimeoutException` is raised:

```ts

const task = Effect.gen(function* () {
  console.log("Start processing...")
  yield* Effect.sleep("2 seconds") // Simulates a delay in processing
  console.log("Processing complete.")
  return "Result"
})

// Output will show a TimeoutException as the task takes longer
// than the specified timeout duration
const timedEffect = task.pipe(Effect.timeout("1 second"))

Effect.runPromiseExit(timedEffect).then(console.log)
/*
Output:
Start processing...
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: { _tag: 'TimeoutException' }
  }
}
*/
```

### timeoutOption

If you want to handle timeouts more gracefully, consider using `Effect.timeoutOption`. This function treats timeouts as regular results, wrapping the outcome in an [Option](/docs/data-types/option/).

**Example** (Handling Timeout as an Option)

In this example, the first task completes successfully, while the second times out. The result of the timed-out task is represented as `None` in the `Option` type.

```ts

const task = Effect.gen(function* () {
  console.log("Start processing...")
  yield* Effect.sleep("2 seconds") // Simulates a delay in processing
  console.log("Processing complete.")
  return "Result"
})

const timedOutEffect = Effect.all([
  task.pipe(Effect.timeoutOption("3 seconds")),
  task.pipe(Effect.timeoutOption("1 second"))
])

Effect.runPromise(timedOutEffect).then(console.log)
/*
Output:
Start processing...
Processing complete.
Start processing...
[
  { _id: 'Option', _tag: 'Some', value: 'Result' },
  { _id: 'Option', _tag: 'None' }
]
*/
```

## Handling Timeouts

When an operation does not finish within the specified duration, the behavior of the `Effect.timeout` depends on whether the operation is "uninterruptible".

> **Note: Uninterruptible Effects**
  An uninterruptible effect is one that, once started, cannot be stopped
  mid-execution by the timeout mechanism directly. This could be because
  the operations within the effect need to run to completion to avoid
  leaving the system in an inconsistent state.


1. **Interruptible Operation**: If the operation can be interrupted, it is terminated immediately once the timeout threshold is reached, resulting in a `TimeoutException`.

   ```ts
   import { Effect } from "effect"

   const task = Effect.gen(function* () {
     console.log("Start processing...")
     yield* Effect.sleep("2 seconds") // Simulates a delay in processing
     console.log("Processing complete.")
     return "Result"
   })

   const timedEffect = task.pipe(Effect.timeout("1 second"))

   Effect.runPromiseExit(timedEffect).then(console.log)
   /*
    Output:
    Start processing...
    {
      _id: 'Exit',
      _tag: 'Failure',
      cause: {
        _id: 'Cause',
        _tag: 'Fail',
        failure: { _tag: 'TimeoutException' }
      }
    }
    */
   ```

2. **Uninterruptible Operation**: If the operation is uninterruptible, it continues until completion before the `TimeoutException` is assessed.

   ```ts
   import { Effect } from "effect"

   const task = Effect.gen(function* () {
     console.log("Start processing...")
     yield* Effect.sleep("2 seconds") // Simulates a delay in processing
     console.log("Processing complete.")
     return "Result"
   })

   const timedEffect = task.pipe(
     Effect.uninterruptible,
     Effect.timeout("1 second")
   )

   // Outputs a TimeoutException after the task completes,
   // because the task is uninterruptible
   Effect.runPromiseExit(timedEffect).then(console.log)
   /*
    Output:
    Start processing...
    Processing complete.
    {
      _id: 'Exit',
      _tag: 'Failure',
      cause: {
        _id: 'Cause',
        _tag: 'Fail',
        failure: { _tag: 'TimeoutException' }
      }
    }
    */
   ```

## Disconnection on Timeout

The `Effect.disconnect` function provides a way to handle timeouts in uninterruptible effects more flexibly. It allows an uninterruptible effect to complete in the background, while the main control flow proceeds as if a timeout had occurred.

Here's the distinction:

**Without** `Effect.disconnect`:

- An uninterruptible effect will ignore the timeout and continue executing until it completes, after which the timeout error is assessed.
- This can lead to delays in recognizing a timeout condition because the system must wait for the effect to complete.

**With** `Effect.disconnect`:

- The uninterruptible effect is allowed to continue in the background, independent of the main control flow.
- The main control flow recognizes the timeout immediately and proceeds with the timeout error or alternative logic, without having to wait for the effect to complete.
- This method is particularly useful when the operations of the effect do not need to block the continuation of the program, despite being marked as uninterruptible.

**Example** (Running Uninterruptible Tasks with Timeout and Background Completion)

Consider a scenario where a long-running data processing task is initiated, and you want to ensure the system remains responsive, even if the data processing takes too long:

```ts

const longRunningTask = Effect.gen(function* () {
  console.log("Start heavy processing...")
  yield* Effect.sleep("5 seconds") // Simulate a long process
  console.log("Heavy processing done.")
  return "Data processed"
})

const timedEffect = longRunningTask.pipe(
  Effect.uninterruptible,
  // Allows the task to finish in the background if it times out
  Effect.disconnect,
  Effect.timeout("1 second")
)

Effect.runPromiseExit(timedEffect).then(console.log)
/*
Output:
Start heavy processing...
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: { _tag: 'TimeoutException' }
  }
}
Heavy processing done.
*/
```

In this example, the system detects the timeout after one second, but the long-running task continues and completes in the background, without blocking the program's flow.

## Customizing Timeout Behavior

In addition to the basic `Effect.timeout` function, there are variations available that allow you to customize the behavior when a timeout occurs.

### timeoutFail

The `Effect.timeoutFail` function allows you to produce a specific error when a timeout happens.

**Example** (Custom Timeout Error)

```ts

const task = Effect.gen(function* () {
  console.log("Start processing...")
  yield* Effect.sleep("2 seconds") // Simulates a delay in processing
  console.log("Processing complete.")
  return "Result"
})

class MyTimeoutError extends Data.TaggedError("MyTimeoutError")<{}> {}

const program = task.pipe(
  Effect.timeoutFail({
    duration: "1 second",
    onTimeout: () => new MyTimeoutError() // Custom timeout error
  })
)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
Start processing...
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: MyTimeoutError { _tag: 'MyTimeoutError' }
  }
}
*/
```

### timeoutFailCause

`Effect.timeoutFailCause` lets you define a specific defect to throw when a timeout occurs. This is helpful for treating timeouts as exceptional cases in your code.

**Example** (Custom Defect on Timeout)

```ts

const task = Effect.gen(function* () {
  console.log("Start processing...")
  yield* Effect.sleep("2 seconds") // Simulates a delay in processing
  console.log("Processing complete.")
  return "Result"
})

const program = task.pipe(
  Effect.timeoutFailCause({
    duration: "1 second",
    onTimeout: () => Cause.die("Timed out!") // Custom defect for timeout
  })
)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
Start processing...
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Die', defect: 'Timed out!' }
}
*/
```

### timeoutTo

`Effect.timeoutTo` provides more flexibility compared to `Effect.timeout`, allowing you to define different outcomes for both successful and timed-out operations. This can be useful when you want to customize the result based on whether the operation completes in time or not.

**Example** (Handling Success and Timeout with [Either](/docs/data-types/either/))

```ts

const task = Effect.gen(function* () {
  console.log("Start processing...")
  yield* Effect.sleep("2 seconds") // Simulates a delay in processing
  console.log("Processing complete.")
  return "Result"
})

const program = task.pipe(
  Effect.timeoutTo({
    duration: "1 second",
    onSuccess: (result): Either.Either<string, string> =>
      Either.right(result),
    onTimeout: (): Either.Either<string, string> =>
      Either.left("Timed out!")
  })
)

Effect.runPromise(program).then(console.log)
/*
Output:
Start processing...
{
  _id: "Either",
  _tag: "Left",
  left: "Timed out!"
}
*/
```


---

# [Sandboxing](https://effect.website/docs/error-management/sandboxing/)

## Overview

Errors are an inevitable part of programming, and they can arise from various sources like failures, defects, fiber interruptions, or combinations of these. This guide explains how to use the `Effect.sandbox` function to isolate and understand the causes of errors in your Effect-based code.

## sandbox / unsandbox

The `Effect.sandbox` function allows you to encapsulate all the potential causes of an error in an effect. It exposes the full cause of an effect, whether it's due to a failure, defect, fiber interruption, or a combination of these factors.

In simple terms, it takes an effect `Effect<A, E, R>` and transforms it into an effect `Effect<A, Cause<E>, R>` where the error channel now contains a detailed cause of the error.

**Syntax**

```ts
Effect<A, E, R> -> Effect<A, Cause<E>, R>
```

By using the `Effect.sandbox` function, you gain access to the underlying causes of exceptional effects. These causes are represented as a type of `Cause<E>` and are available in the error channel of the `Effect` data type.

Once you have exposed the causes, you can utilize standard error-handling operators like [Effect.catchAll](/docs/error-management/expected-errors/#catchall) and [Effect.catchTags](/docs/error-management/expected-errors/#catchtags) to handle errors more effectively. These operators allow you to respond to specific error conditions.

If needed, we can undo the sandboxing operation with `Effect.unsandbox`.

**Example** (Handling Different Error Causes)

```ts

//      ┌─── Effect<string, Error, never>
//      ▼
const task = Effect.fail(new Error("Oh uh!")).pipe(
  Effect.as("primary result")
)

//      ┌─── Effect<string, Cause<Error>, never>
//      ▼
const sandboxed = Effect.sandbox(task)

const program = Effect.catchTags(sandboxed, {
  Die: (cause) =>
    Console.log(`Caught a defect: ${cause.defect}`).pipe(
      Effect.as("fallback result on defect")
    ),
  Interrupt: (cause) =>
    Console.log(`Caught a defect: ${cause.fiberId}`).pipe(
      Effect.as("fallback result on fiber interruption")
    ),
  Fail: (cause) =>
    Console.log(`Caught a defect: ${cause.error}`).pipe(
      Effect.as("fallback result on failure")
    )
})

// Restore the original error handling with unsandbox
const main = Effect.unsandbox(program)

Effect.runPromise(main).then(console.log)
/*
Output:
Caught a defect: Oh uh!
fallback result on failure
*/
```


---


## Common Mistakes

**Incorrect (throwing instead of using typed errors):**

```ts
const getUser = (id: string) =>
  Effect.sync(() => {
    throw new Error("not found") // Untyped, not tracked
  })
```

**Correct (using typed errors in the error channel):**

```ts
class NotFound extends Data.TaggedError("NotFound")<{
  readonly id: string
}> {}

const getUser = (id: string) =>
  Effect.fail(new NotFound({ id })) // Tracked in Effect<never, NotFound>
```
