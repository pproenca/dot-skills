---
title: "Code Style and Traits"
impact: MEDIUM
impactDescription: "Ensures idiomatic Effect code — covers branded types, pattern matching, dual APIs, Equal, Hash"
tags: code, code-style, branded-types, pattern-matching, traits
---
# [Branded Types](https://effect.website/docs/code-style/branded-types/)

## Overview

In this guide, we will explore the concept of **branded types** in TypeScript and learn how to create and work with them using the Brand module.
Branded types are TypeScript types with an added type tag that helps prevent accidental usage of a value in the wrong context.
They allow us to create distinct types based on an existing underlying type, enabling type safety and better code organization.

## The Problem with TypeScript's Structural Typing

TypeScript's type system is structurally typed, meaning that two types are considered compatible if their members are compatible.
This can lead to situations where values of the same underlying type are used interchangeably, even when they represent different concepts or have different meanings.

Consider the following types:

```ts
type UserId = number

type ProductId = number
```

Here, `UserId` and `ProductId` are structurally identical as they are both based on `number`.
TypeScript will treat these as interchangeable, potentially causing bugs if they are mixed up in your application.

**Example** (Unintended Type Compatibility)

```ts
type UserId = number

type ProductId = number

const getUserById = (id: UserId) => {
  // Logic to retrieve user
}

const getProductById = (id: ProductId) => {
  // Logic to retrieve product
}

const id: UserId = 1

getProductById(id) // No type error, but incorrect usage
```

In the example above, passing a `UserId` to `getProductById` does not produce a type error, even though it's logically incorrect. This happens because both types are considered interchangeable.

## How Branded Types Help

Branded types allow you to create distinct types from the same underlying type by adding a unique type tag, enforcing proper usage at compile-time.

Branding is accomplished by adding a symbolic identifier that distinguishes one type from another at the type level.
This method ensures that types remain distinct without altering their runtime characteristics.

Let's start by introducing the `BrandTypeId` symbol:

```ts
const BrandTypeId: unique symbol = Symbol.for("effect/Brand")

type ProductId = number & {
  readonly [BrandTypeId]: {
    readonly ProductId: "ProductId" // unique identifier for ProductId
  }
}
```

This approach assigns a unique identifier as a brand to the `number` type, effectively differentiating `ProductId` from other numerical types.
The use of a symbol ensures that the branding field does not conflict with any existing properties of the `number` type.

Attempting to use a `UserId` in place of a `ProductId` now results in an error:

**Example** (Enforcing Type Safety with Branded Types)

```ts
const BrandTypeId: unique symbol = Symbol.for("effect/Brand")

type ProductId = number & {
  readonly [BrandTypeId]: {
    readonly ProductId: "ProductId"
  }
}

const getProductById = (id: ProductId) => {
  // Logic to retrieve product
}

type UserId = number

const id: UserId = 1

// @errors: 2345
getProductById(id)
```

The error message clearly states that a `number` cannot be used in place of a `ProductId`.

TypeScript won't let us pass an instance of `number` to the function accepting `ProductId` because it's missing the brand field.

Let's add branding to `UserId` as well:

**Example** (Branding UserId and ProductId)

```ts
const BrandTypeId: unique symbol = Symbol.for("effect/Brand")

type ProductId = number & {
  readonly [BrandTypeId]: {
    readonly ProductId: "ProductId" // unique identifier for ProductId
  }
}

const getProductById = (id: ProductId) => {
  // Logic to retrieve product
}

type UserId = number & {
  readonly [BrandTypeId]: {
    readonly UserId: "UserId" // unique identifier for UserId
  }
}

declare const id: UserId

// @errors: 2345
getProductById(id)
```

The error indicates that while both types use branding, the unique values associated with the branding fields (`"ProductId"` and `"UserId"`) ensure they remain distinct and non-interchangeable.

## Generalizing Branded Types

To enhance the versatility and reusability of branded types, they can be generalized using a standardized approach:

```ts
const BrandTypeId: unique symbol = Symbol.for("effect/Brand")

// Create a generic Brand interface using a unique identifier
interface Brand<in out ID extends string | symbol> {
  readonly [BrandTypeId]: {
    readonly [id in ID]: ID
  }
}

// Define a ProductId type branded with a unique identifier
type ProductId = number & Brand<"ProductId">

// Define a UserId type branded similarly
type UserId = number & Brand<"UserId">
```

This design allows any type to be branded using a unique identifier, either a string or symbol.

Here's how you can utilize the `Brand` interface, which is readily available from the Brand module, eliminating the need to craft your own implementation:

**Example** (Using the Brand Interface from the Brand Module)

```ts

// Define a ProductId type branded with a unique identifier
type ProductId = number & Brand.Brand<"ProductId">

// Define a UserId type branded similarly
type UserId = number & Brand.Brand<"UserId">
```

However, creating instances of these types directly leads to an error because the type system expects the brand structure:

**Example** (Direct Assignment Error)

```ts
const BrandTypeId: unique symbol = Symbol.for("effect/Brand")

interface Brand<in out K extends string | symbol> {
  readonly [BrandTypeId]: {
    readonly [k in K]: K
  }
}

type ProductId = number & Brand<"ProductId">

// @errors: 2322
const id: ProductId = 1
```

You cannot directly assign a `number` to `ProductId`. The Brand module provides utilities to correctly construct values of branded types.

## Constructing Branded Types

The Brand module provides two main functions for creating branded types: `nominal` and `refined`.

### nominal

The `Brand.nominal` function is designed for defining branded types that do not require runtime validations.
It simply adds a type tag to the underlying type, allowing us to distinguish between values of the same type but with different meanings.
Nominal branded types are useful when we only want to create distinct types for clarity and code organization purposes.

**Example** (Defining Distinct Identifiers with Nominal Branding)

```ts

// Define UserId as a branded number
type UserId = number & Brand.Brand<"UserId">

// Constructor for UserId
const UserId = Brand.nominal<UserId>()

const getUserById = (id: UserId) => {
  // Logic to retrieve user
}

// Define ProductId as a branded number
type ProductId = number & Brand.Brand<"ProductId">

// Constructor for ProductId
const ProductId = Brand.nominal<ProductId>()

const getProductById = (id: ProductId) => {
  // Logic to retrieve product
}
```

Attempting to assign a non-`ProductId` value will result in a compile-time error:

**Example** (Type Safety with Branded Identifiers)

```ts

type UserId = number & Brand.Brand<"UserId">

const UserId = Brand.nominal<UserId>()

const getUserById = (id: UserId) => {
  // Logic to retrieve user
}

type ProductId = number & Brand.Brand<"ProductId">

const ProductId = Brand.nominal<ProductId>()

const getProductById = (id: ProductId) => {
  // Logic to retrieve product
}

// Correct usage
getProductById(ProductId(1))

// Incorrect, will result in an error
// @errors: 2345
getProductById(1)

// Also incorrect, will result in an error
// @errors: 2345
getProductById(UserId(1))
```

### refined

The `Brand.refined` function enables the creation of branded types that include data validation. It requires a refinement predicate to check the validity of input data against specific criteria.

When the input data does not meet the criteria, the function uses `Brand.error` to generate a `BrandErrors` data type. This provides detailed information about why the validation failed.

**Example** (Creating a Branded Type with Validation)

```ts

// Define a branded type 'Int' to represent integer values
type Int = number & Brand.Brand<"Int">

// Define the constructor using 'refined' to enforce integer values
const Int = Brand.refined<Int>(
  // Validation to ensure the value is an integer
  (n) => Number.isInteger(n),
  // Provide an error if validation fails
  (n) => Brand.error(`Expected ${n} to be an integer`)
)
```

**Example** (Using the `Int` Constructor)

```ts

type Int = number & Brand.Brand<"Int">

const Int = Brand.refined<Int>(
  // Check if the value is an integer
  (n) => Number.isInteger(n),
  // Error message if the value is not an integer
  (n) => Brand.error(`Expected ${n} to be an integer`)
)

// Create a valid Int value
const x: Int = Int(3)
console.log(x) // Output: 3

// Attempt to create an Int with an invalid value
const y: Int = Int(3.14)
// throws [ { message: 'Expected 3.14 to be an integer' } ]
```

Attempting to assign a non-`Int` value will result in a compile-time error:

**Example** (Compile-Time Error for Incorrect Assignments)

```ts

type Int = number & Brand.Brand<"Int">

const Int = Brand.refined<Int>(
  (n) => Number.isInteger(n),
  (n) => Brand.error(`Expected ${n} to be an integer`)
)

// Correct usage
const good: Int = Int(3)

// Incorrect, will result in an error
// @errors: 2322
const bad1: Int = 3

// Also incorrect, will result in an error
// @errors: 2322
const bad2: Int = 3.14
```

## Combining Branded Types

In some cases, you might need to combine multiple branded types. The Brand module provides the `Brand.all` API for this purpose:

**Example** (Combining Multiple Branded Types)

```ts

type Int = number & Brand.Brand<"Int">

const Int = Brand.refined<Int>(
  (n) => Number.isInteger(n),
  (n) => Brand.error(`Expected ${n} to be an integer`)
)

type Positive = number & Brand.Brand<"Positive">

const Positive = Brand.refined<Positive>(
  (n) => n > 0,
  (n) => Brand.error(`Expected ${n} to be positive`)
)

// Combine the Int and Positive constructors
// into a new branded constructor PositiveInt
const PositiveInt = Brand.all(Int, Positive)

// Extract the branded type from the PositiveInt constructor
type PositiveInt = Brand.Brand.FromConstructor<typeof PositiveInt>

// Usage example

// Valid positive integer
const good: PositiveInt = PositiveInt(10)

// throws [ { message: 'Expected -5 to be positive' } ]
const bad1: PositiveInt = PositiveInt(-5)

// throws [ { message: 'Expected 3.14 to be an integer' } ]
const bad2: PositiveInt = PositiveInt(3.14)
```

# [Simplifying Excessive Nesting](https://effect.website/docs/code-style/do/)

## Overview


Suppose you want to create a custom function `elapsed` that prints the elapsed time taken by an effect to execute.

## Using plain pipe

Initially, you may come up with code that uses the standard `pipe` [method](/docs/getting-started/building-pipelines/#the-pipe-method), but this approach can lead to excessive nesting and result in verbose and hard-to-read code:

**Example** (Measuring Elapsed Time with `pipe`)

```ts

// Get the current timestamp
const now = Effect.sync(() => new Date().getTime())

// Prints the elapsed time occurred to `self` to execute
const elapsed = <R, E, A>(
  self: Effect.Effect<A, E, R>
): Effect.Effect<A, E, R> =>
  now.pipe(
    Effect.andThen((startMillis) =>
      self.pipe(
        Effect.andThen((result) =>
          now.pipe(
            Effect.andThen((endMillis) => {
              // Calculate the elapsed time in milliseconds
              const elapsed = endMillis - startMillis
              // Log the elapsed time
              return Console.log(`Elapsed: ${elapsed}`).pipe(
                Effect.map(() => result)
              )
            })
          )
        )
      )
    )
  )

// Simulates a successful computation with a delay of 200 milliseconds
const task = Effect.succeed("some task").pipe(Effect.delay("200 millis"))

const program = elapsed(task)

Effect.runPromise(program).then(console.log)
/*
Output:
Elapsed: 204
some task
*/
```

To address this issue and make the code more manageable, there is a solution: the "do simulation."

## Using the "do simulation"

The "do simulation" in Effect allows you to write code in a more declarative style, similar to the "do notation" in other programming languages. It provides a way to define variables and perform operations on them using functions like `Effect.bind` and `Effect.let`.

Here's how the do simulation works:


1. Start the do simulation using the `Effect.Do` value:

   ```ts
   const program = Effect.Do.pipe(/* ... rest of the code */)
   ```

2. Within the do simulation scope, you can use the `Effect.bind` function to define variables and bind them to `Effect` values:

   ```ts
   Effect.bind("variableName", (scope) => effectValue)
   ```

   - `variableName` is the name you choose for the variable you want to define. It must be unique within the scope.
   - `effectValue` is the `Effect` value that you want to bind to the variable. It can be the result of a function call or any other valid `Effect` value.

3. You can accumulate multiple `Effect.bind` statements to define multiple variables within the scope:

   ```ts
   Effect.bind("variable1", () => effectValue1),
   Effect.bind("variable2", ({ variable1 }) => effectValue2),
   // ... additional bind statements
   ```

4. Inside the do simulation scope, you can also use the `Effect.let` function to define variables and bind them to simple values:

   ```ts
   Effect.let("variableName", (scope) => simpleValue)
   ```

   - `variableName` is the name you give to the variable. Like before, it must be unique within the scope.
   - `simpleValue` is the value you want to assign to the variable. It can be a simple value like a `number`, `string`, or `boolean`.

5. Regular Effect functions like `Effect.andThen`, `Effect.flatMap`, `Effect.tap`, and `Effect.map` can still be used within the do simulation. These functions will receive the accumulated variables as arguments within the scope:

   ```ts
   Effect.andThen(({ variable1, variable2 }) => {
     // Perform operations using variable1 and variable2
     // Return an `Effect` value as the result
   })
   ```


With the do simulation, you can rewrite the `elapsed` function like this:

**Example** (Using Do Simulation to Measure Elapsed Time)

```ts

// Get the current timestamp
const now = Effect.sync(() => new Date().getTime())

const elapsed = <R, E, A>(
  self: Effect.Effect<A, E, R>
): Effect.Effect<A, E, R> =>
  Effect.Do.pipe(
    Effect.bind("startMillis", () => now),
    Effect.bind("result", () => self),
    Effect.bind("endMillis", () => now),
    Effect.let(
      "elapsed",
      // Calculate the elapsed time in milliseconds
      ({ startMillis, endMillis }) => endMillis - startMillis
    ),
    // Log the elapsed time
    Effect.tap(({ elapsed }) => Console.log(`Elapsed: ${elapsed}`)),
    Effect.map(({ result }) => result)
  )

// Simulates a successful computation with a delay of 200 milliseconds
const task = Effect.succeed("some task").pipe(Effect.delay("200 millis"))

const program = elapsed(task)

Effect.runPromise(program).then(console.log)
/*
Output:
Elapsed: 204
some task
*/
```

## Using Effect.gen

The most concise and convenient solution is to use [Effect.gen](/docs/getting-started/using-generators/), which allows you to work with [generators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Generator) when dealing with effects. This approach leverages the native scope provided by the generator syntax, avoiding excessive nesting and leading to more concise code.

**Example** (Using Effect.gen to Measure Elapsed Time)

```ts

// Get the current timestamp
const now = Effect.sync(() => new Date().getTime())

// Prints the elapsed time occurred to `self` to execute
const elapsed = <R, E, A>(
  self: Effect.Effect<A, E, R>
): Effect.Effect<A, E, R> =>
  Effect.gen(function* () {
    const startMillis = yield* now
    const result = yield* self
    const endMillis = yield* now
    // Calculate the elapsed time in milliseconds
    const elapsed = endMillis - startMillis
    // Log the elapsed time
    console.log(`Elapsed: ${elapsed}`)
    return result
  })

// Simulates a successful computation with a delay of 200 milliseconds
const task = Effect.succeed("some task").pipe(Effect.delay("200 millis"))

const program = elapsed(task)

Effect.runPromise(program).then(console.log)
/*
Output:
Elapsed: 204
some task
*/
```

Within the generator, we use `yield*` to invoke effects and bind their results to variables. This eliminates the nesting and provides a more readable and sequential code structure.

The generator style in Effect uses a more linear and sequential flow of execution, resembling traditional imperative programming languages. This makes the code easier to read and understand, especially for developers who are more familiar with imperative programming paradigms.

# [Dual APIs](https://effect.website/docs/code-style/dual/)

## Overview


When you're working with APIs in the Effect ecosystem, you may come across two different ways to use the same API.
These two ways are called the "data-last" and "data-first" variants.

When an API supports both variants, we call them "dual" APIs.

Here's an illustration of these two variants using `Effect.map`.

## Effect.map as a dual API

The `Effect.map` function is defined with two TypeScript overloads. The terms "data-last" and "data-first" refer to the position of the `self` argument (also known as the "data") in the signatures of the two overloads:

```ts
declare const map: {
  //                               ┌─── data-last
  //                               ▼
  <A, B>(f: (a: A) => B): <E, R>(self: Effect<A, E, R>) => Effect<B, E, R>
  //             ┌─── data-first
  //             ▼
  <A, E, R, B>(self: Effect<A, E, R>, f: (a: A) => B): Effect<B, E, R>
}
```

### data-last

In the first overload, the `self` argument comes **last**:

```ts
declare const map: <A, B>(
  f: (a: A) => B
) => <E, R>(self: Effect<A, E, R>) => Effect<B, E, R>
```

This version is commonly used with the `pipe` function. You start by passing the `Effect` as the initial argument to `pipe` and then chain transformations like `Effect.map`:

**Example** (Using data-last with `pipe`)

```ts
const mappedEffect = pipe(effect, Effect.map(func))
```

This style is helpful when chaining multiple transformations, making the code easier to follow in a pipeline format:

```ts
pipe(effect, Effect.map(func1), Effect.map(func2), ...)
```

### data-first

In the second overload, the `self` argument comes **first**:

```ts
declare const map: <A, E, R, B>(
  self: Effect<A, E, R>,
  f: (a: A) => B
) => Effect<B, E, R>
```

This form doesn't require `pipe`. Instead, you provide the `Effect` directly as the first argument:

**Example** (Using data-first without `pipe`)

```ts
const mappedEffect = Effect.map(effect, func)
```

This version works well when you only need to perform a single operation on the `Effect`.

> **Tip: Choosing Between Styles**
  Both overloads achieve the same result. Choose the one that best suits
  your coding style and enhances readability for your team.


# [Guidelines](https://effect.website/docs/code-style/guidelines/)

## Overview


## Using runMain

In Effect, `runMain` is the primary entry point for executing an Effect application on Node.js.

**Example** (Running an Effect Application with Graceful Teardown)

```ts

const program = pipe(
  Effect.addFinalizer(() => Console.log("Application is about to exit!")),
  Effect.andThen(Console.log("Application started!")),
  Effect.andThen(
    Effect.repeat(Console.log("still alive..."), {
      schedule: Schedule.spaced("1 second")
    })
  ),
  Effect.scoped
)

// No graceful teardown on CTRL+C
// Effect.runPromise(program)

// Use NodeRuntime.runMain for graceful teardown on CTRL+C
NodeRuntime.runMain(program)
/*
Output:
Application started!
still alive...
still alive...
still alive...
still alive...
^C <-- CTRL+C
Application is about to exit!
*/
```

The `runMain` function handles finding and interrupting all fibers. Internally, it observes the fiber and listens for `sigint` signals, ensuring a graceful shutdown of the application when interrupted (e.g., using CTRL+C).

> **Tip: Graceful Teardown**
  Ensure the teardown logic is placed in the main effect. If the fiber
  running the application or server is interrupted, `runMain` ensures that
  all resources are properly released.


### Versions for Different Platforms

Effect provides versions of `runMain` tailored for different platforms:

| Platform | Runtime Version          | Import Path                |
| -------- | ------------------------ | -------------------------- |
| Node.js  | `NodeRuntime.runMain`    | `@effect/platform-node`    |
| Bun      | `BunRuntime.runMain`     | `@effect/platform-bun`     |
| Browser  | `BrowserRuntime.runMain` | `@effect/platform-browser` |

## Avoid Tacit Usage

Avoid using tacit (point-free) function calls, such as `Effect.map(fn)`, or using `flow` from the `effect/Function` module.

In Effect, it's generally safer to write functions explicitly:

```ts
Effect.map((x) => fn(x))
```

rather than in a point-free style:

```ts
Effect.map(fn)
```

While tacit functions may be appealing for their brevity, they can introduce a number of problems:

- Using tacit functions, particularly when dealing with optional parameters, can be unsafe. For example, if a function has overloads, writing it in a tacit style may erase all generics, resulting in bugs. Check out this X thread for more details: [link to thread](https://twitter.com/MichaelArnaldi/status/1670715270845935616).

- Tacit usage can also compromise TypeScript's ability to infer types, potentially causing unexpected errors. This isn't just a matter of style but a way to avoid subtle mistakes that can arise from type inference issues.

- Additionally, stack traces might not be as clear when tacit usage is employed.

Avoiding tacit usage is a simple precaution that makes your code more reliable.

# [Pattern Matching](https://effect.website/docs/code-style/pattern-matching/)

## Overview


Pattern matching is a method that allows developers to handle intricate conditions within a single, concise expression. It simplifies code, making it more concise and easier to understand. Additionally, it includes a process called exhaustiveness checking, which helps to ensure that no possible case has been overlooked.

Originating from functional programming languages, pattern matching stands as a powerful technique for code branching. It often offers a more potent and less verbose solution compared to imperative alternatives such as if/else or switch statements, particularly when dealing with complex conditions.

Although not yet a native feature in JavaScript, there's an ongoing [tc39 proposal](https://github.com/tc39/proposal-pattern-matching) in its early stages to introduce pattern matching to JavaScript. However, this proposal is at stage 1 and might take several years to be implemented. Nonetheless, developers can implement pattern matching in their codebase. The `effect/Match` module provides a reliable, type-safe pattern matching implementation that is available for immediate use.

**Example** (Handling Different Data Types with Pattern Matching)

```ts

// Simulated dynamic input that can be a string or a number
const input: string | number = "some input"

//      ┌─── string
//      ▼
const result = Match.value(input).pipe(
  // Match if the value is a number
  Match.when(Match.number, (n) => `number: ${n}`),
  // Match if the value is a string
  Match.when(Match.string, (s) => `string: ${s}`),
  // Ensure all possible cases are covered
  Match.exhaustive
)

console.log(result)
// Output: "string: some input"
```

## How Pattern Matching Works

Pattern matching follows a structured process:

1. **Creating a matcher**.
   Define a `Matcher` that operates on either a specific [type](#matching-by-type) or [value](#matching-by-value).

2. **Defining patterns**.
   Use combinators such as `Match.when`, `Match.not`, and `Match.tag` to specify matching conditions.

3. **Completing the match**.
   Apply a finalizer such as `Match.exhaustive`, `Match.orElse`, or `Match.option` to determine how unmatched cases should be handled.

## Creating a matcher

You can create a `Matcher` using either:

- `Match.type<T>()`: Matches against a specific type.
- `Match.value(value)`: Matches against a specific value.

### Matching by Type

The `Match.type` constructor defines a `Matcher` that operates on a specific type. Once created, you can use patterns like `Match.when` to define conditions for handling different cases.

**Example** (Matching Numbers and Strings)

```ts

// Create a matcher for values that are either strings or numbers
//
//      ┌─── (u: string | number) => string
//      ▼
const match = Match.type<string | number>().pipe(
  // Match when the value is a number
  Match.when(Match.number, (n) => `number: ${n}`),
  // Match when the value is a string
  Match.when(Match.string, (s) => `string: ${s}`),
  // Ensure all possible cases are handled
  Match.exhaustive
)

console.log(match(0))
// Output: "number: 0"

console.log(match("hello"))
// Output: "string: hello"
```

### Matching by Value

Instead of creating a matcher for a type, you can define one directly from a specific value using `Match.value`.

**Example** (Matching an Object by Property)

```ts

const input = { name: "John", age: 30 }

// Create a matcher for the specific object
const result = Match.value(input).pipe(
  // Match when the 'name' property is "John"
  Match.when(
    { name: "John" },
    (user) => `${user.name} is ${user.age} years old`
  ),
  // Provide a fallback if no match is found
  Match.orElse(() => "Oh, not John")
)

console.log(result)
// Output: "John is 30 years old"
```

### Enforcing a Return Type

You can use `Match.withReturnType<T>()` to ensure that all branches return a specific type.

**Example** (Validating Return Type Consistency)

This example enforces that every matching branch returns a `string`.

```ts

const match = Match.type<{ a: number } | { b: string }>().pipe(
  // Ensure all branches return a string
  Match.withReturnType<string>(),
  // ❌ Type error: returns a number
// @errors: 2322
  Match.when({ a: Match.number }, (_) => _.a),
  // ✅ Correct: returns a string
  Match.when({ b: Match.string }, (_) => _.b),
  Match.exhaustive
)
```

> **Note: Must Be First in the Pipeline**
  The `Match.withReturnType<T>()` call must be the first instruction in the pipeline.
  If placed later, TypeScript will not properly enforce return type consistency.


## Defining patterns

### when

The `Match.when` function allows you to define conditions for matching values. It supports both direct value comparisons and predicate functions.

**Example** (Matching with Values and Predicates)

```ts

// Create a matcher for objects with an "age" property
const match = Match.type<{ age: number }>().pipe(
  // Match when age is greater than 18
  Match.when({ age: (age) => age > 18 }, (user) => `Age: ${user.age}`),
  // Match when age is exactly 18
  Match.when({ age: 18 }, () => "You can vote"),
  // Fallback case for all other ages
  Match.orElse((user) => `${user.age} is too young`)
)

console.log(match({ age: 20 }))
// Output: "Age: 20"

console.log(match({ age: 18 }))
// Output: "You can vote"

console.log(match({ age: 4 }))
// Output: "4 is too young"
```

### not

The `Match.not` function allows you to exclude specific values while matching all others.

**Example** (Ignoring a Specific Value)

```ts

// Create a matcher for string or number values
const match = Match.type<string | number>().pipe(
  // Match any value except "hi", returning "ok"
  Match.not("hi", () => "ok"),
  // Fallback case for when the value is "hi"
  Match.orElse(() => "fallback")
)

console.log(match("hello"))
// Output: "ok"

console.log(match("hi"))
// Output: "fallback"
```

### tag

The `Match.tag` function allows pattern matching based on the `_tag` field in a [Discriminated Union](https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes-func.html#discriminated-unions). You can specify multiple tags to match within a single pattern.

**Example** (Matching a Discriminated Union by Tag)

```ts

type Event =
  | { readonly _tag: "fetch" }
  | { readonly _tag: "success"; readonly data: string }
  | { readonly _tag: "error"; readonly error: Error }
  | { readonly _tag: "cancel" }

// Create a Matcher for Either<number, string>
const match = Match.type<Event>().pipe(
  // Match either "fetch" or "success"
  Match.tag("fetch", "success", () => `Ok!`),
  // Match "error" and extract the error message
  Match.tag("error", (event) => `Error: ${event.error.message}`),
  // Match "cancel"
  Match.tag("cancel", () => "Cancelled"),
  Match.exhaustive
)

console.log(match({ _tag: "success", data: "Hello" }))
// Output: "Ok!"

console.log(match({ _tag: "error", error: new Error("Oops!") }))
// Output: "Error: Oops!"
```

> **Caution: Tag Field Naming Convention**
  The `Match.tag` function relies on the convention within the Effect
  ecosystem of naming the tag field as `"_tag"`. Ensure that your
  discriminated unions follow this naming convention for proper
  functionality.


### Built-in Predicates

The `Match` module provides built-in predicates for common types, such as `Match.number`, `Match.string`, and `Match.boolean`. These predicates simplify the process of matching against primitive types.

**Example** (Using Built-in Predicates for Property Keys)

```ts

const matchPropertyKey = Match.type<PropertyKey>().pipe(
  // Match when the value is a number
  Match.when(Match.number, (n) => `Key is a number: ${n}`),
  // Match when the value is a string
  Match.when(Match.string, (s) => `Key is a string: ${s}`),
  // Match when the value is a symbol
  Match.when(Match.symbol, (s) => `Key is a symbol: ${String(s)}`),
  // Ensure all possible cases are handled
  Match.exhaustive
)

console.log(matchPropertyKey(42))
// Output: "Key is a number: 42"

console.log(matchPropertyKey("username"))
// Output: "Key is a string: username"

console.log(matchPropertyKey(Symbol("id")))
// Output: "Key is a symbol: Symbol(id)"
```

| Predicate                 | Description                                                                   |
| ------------------------- | ----------------------------------------------------------------------------- |
| `Match.string`            | Matches values of type `string`.                                              |
| `Match.nonEmptyString`    | Matches non-empty strings.                                                    |
| `Match.number`            | Matches values of type `number`.                                              |
| `Match.boolean`           | Matches values of type `boolean`.                                             |
| `Match.bigint`            | Matches values of type `bigint`.                                              |
| `Match.symbol`            | Matches values of type `symbol`.                                              |
| `Match.date`              | Matches values that are instances of `Date`.                                  |
| `Match.record`            | Matches objects where keys are `string` or `symbol` and values are `unknown`. |
| `Match.null`              | Matches the value `null`.                                                     |
| `Match.undefined`         | Matches the value `undefined`.                                                |
| `Match.defined`           | Matches any defined (non-null and non-undefined) value.                       |
| `Match.any`               | Matches any value without restrictions.                                       |
| `Match.is(...values)`     | Matches a specific set of literal values (e.g., `Match.is("a", 42, true)`).   |
| `Match.instanceOf(Class)` | Matches instances of a given class.                                           |

## Completing the match

### exhaustive

The `Match.exhaustive` method finalizes the pattern matching process by ensuring that all possible cases are accounted for. If any case is missing, TypeScript will produce a type error. This is particularly useful when working with unions, as it helps prevent unintended gaps in pattern matching.

**Example** (Ensuring All Cases Are Covered)

```ts

// Create a matcher for string or number values
const match = Match.type<string | number>().pipe(
  // Match when the value is a number
  Match.when(Match.number, (n) => `number: ${n}`),
  // Mark the match as exhaustive, ensuring all cases are handled
  // TypeScript will throw an error if any case is missing
// @errors: 2345
  Match.exhaustive
)
```

### orElse

The `Match.orElse` method defines a fallback value to return when no other patterns match. This ensures that the matcher always produces a valid result.

**Example** (Providing a Default Value When No Patterns Match)

```ts

// Create a matcher for string or number values
const match = Match.type<string | number>().pipe(
  // Match when the value is "a"
  Match.when("a", () => "ok"),
  // Fallback when no patterns match
  Match.orElse(() => "fallback")
)

console.log(match("a"))
// Output: "ok"

console.log(match("b"))
// Output: "fallback"
```

### option

`Match.option` wraps the match result in an [Option](/docs/data-types/option/). If a match is found, it returns `Some(value)`, otherwise, it returns `None`.

**Example** (Extracting a User Role with Option)

```ts

type User = { readonly role: "admin" | "editor" | "viewer" }

// Create a matcher to extract user roles
const getRole = Match.type<User>().pipe(
  Match.when({ role: "admin" }, () => "Has full access"),
  Match.when({ role: "editor" }, () => "Can edit content"),
  Match.option // Wrap the result in an Option
)

console.log(getRole({ role: "admin" }))
// Output: { _id: 'Option', _tag: 'Some', value: 'Has full access' }

console.log(getRole({ role: "viewer" }))
// Output: { _id: 'Option', _tag: 'None' }
```

### either

The `Match.either` method wraps the result in an [Either](/docs/data-types/either/), providing a structured way to distinguish between matched and unmatched cases. If a match is found, it returns `Right(value)`, otherwise, it returns `Left(no match)`.

**Example** (Extracting a User Role with Either)

```ts

type User = { readonly role: "admin" | "editor" | "viewer" }

// Create a matcher to extract user roles
const getRole = Match.type<User>().pipe(
  Match.when({ role: "admin" }, () => "Has full access"),
  Match.when({ role: "editor" }, () => "Can edit content"),
  Match.either // Wrap the result in an Either
)

console.log(getRole({ role: "admin" }))
// Output: { _id: 'Either', _tag: 'Right', right: 'Has full access' }

console.log(getRole({ role: "viewer" }))
// Output: { _id: 'Either', _tag: 'Left', left: { role: 'viewer' } }
```

# [Equivalence](https://effect.website/docs/behaviour/equivalence/)

## Overview

The Equivalence module provides a way to define equivalence relations between values in TypeScript. An equivalence relation is a binary relation that is reflexive, symmetric, and transitive, establishing a formal notion of when two values should be considered equivalent.

## What is Equivalence?

An `Equivalence<A>` represents a function that compares two values of type `A` and determines if they are equivalent. This is more flexible and customizable than simple equality checks using `===`.

Here's the structure of an `Equivalence`:

```ts
interface Equivalence<A> {
  (self: A, that: A): boolean
}
```

## Using Built-in Equivalences

The module provides several built-in equivalence relations for common data types:

| Equivalence | Description                                 |
| ----------- | ------------------------------------------- |
| `string`    | Uses strict equality (`===`) for strings    |
| `number`    | Uses strict equality (`===`) for numbers    |
| `boolean`   | Uses strict equality (`===`) for booleans   |
| `symbol`    | Uses strict equality (`===`) for symbols    |
| `bigint`    | Uses strict equality (`===`) for bigints    |
| `Date`      | Compares `Date` objects by their timestamps |

**Example** (Using Built-in Equivalences)

```ts

console.log(Equivalence.string("apple", "apple"))
// Output: true

console.log(Equivalence.string("apple", "orange"))
// Output: false

console.log(Equivalence.Date(new Date(2023, 1, 1), new Date(2023, 1, 1)))
// Output: true

console.log(Equivalence.Date(new Date(2023, 1, 1), new Date(2023, 10, 1)))
// Output: false
```

## Deriving Equivalences

For more complex data structures, you may need custom equivalences. The Equivalence module lets you derive new `Equivalence` instances from existing ones with the `Equivalence.mapInput` function.

**Example** (Creating a Custom Equivalence for Objects)

```ts

interface User {
  readonly id: number
  readonly name: string
}

// Create an equivalence that compares User objects based only on the id
const equivalence = Equivalence.mapInput(
  Equivalence.number, // Base equivalence for comparing numbers
  (user: User) => user.id // Function to extract the id from a User
)

// Compare two User objects: they are equivalent if their ids are the same
console.log(equivalence({ id: 1, name: "Alice" }, { id: 1, name: "Al" }))
// Output: true
```

The `Equivalence.mapInput` function takes two arguments:

1. The existing `Equivalence` you want to use as a base (`Equivalence.number` in this case, for comparing numbers).
2. A function that extracts the value used for the equivalence check from your data structure (`(user: User) => user.id` in this case).

# [Order](https://effect.website/docs/behaviour/order/)

## Overview

The Order module provides a way to compare values and determine their order.
It defines an interface `Order<A>` which represents a single function for comparing two values of type `A`.
The function returns `-1`, `0`, or `1`, indicating whether the first value is less than, equal to, or greater than the second value.

Here's the basic structure of an `Order`:

```ts
interface Order<A> {
  (first: A, second: A): -1 | 0 | 1
}
```

## Using the Built-in Orders

The Order module comes with several built-in comparators for common data types:

| Order    | Description                        |
| -------- | ---------------------------------- |
| `string` | Used for comparing strings.        |
| `number` | Used for comparing numbers.        |
| `bigint` | Used for comparing big integers.   |
| `Date`   | Used for comparing `Date` objects. |

**Example** (Using Built-in Comparators)

```ts

console.log(Order.string("apple", "banana"))
// Output: -1, as "apple" < "banana"

console.log(Order.number(1, 1))
// Output: 0, as 1 = 1

console.log(Order.bigint(2n, 1n))
// Output: 1, as 2n > 1n
```

## Sorting Arrays

You can sort arrays using these comparators. The `Array` module offers a `sort` function that sorts arrays without altering the original one.

**Example** (Sorting Arrays with `Order`)

```ts

const strings = ["b", "a", "d", "c"]

const result = Array.sort(strings, Order.string)

console.log(strings) // Original array remains unchanged
// Output: [ 'b', 'a', 'd', 'c' ]

console.log(result) // Sorted array
// Output: [ 'a', 'b', 'c', 'd' ]
```

You can also use an `Order` as a comparator with JavaScript's native `Array.sort` method, but keep in mind that this will modify the original array.

**Example** (Using `Order` with Native `Array.prototype.sort`)

```ts

const strings = ["b", "a", "d", "c"]

strings.sort(Order.string) // Modifies the original array

console.log(strings)
// Output: [ 'a', 'b', 'c', 'd' ]
```

## Deriving Orders

For more complex data structures, you may need custom sorting rules. The Order module lets you derive new `Order` instances from existing ones with the `Order.mapInput` function.

**Example** (Creating a Custom Order for Objects)

Imagine you have a list of `Person` objects, and you want to sort them by their names in ascending order.
To achieve this, you can create a custom `Order`.

```ts

// Define the Person interface
interface Person {
  readonly name: string
  readonly age: number
}

// Create a custom order to sort Person objects by name in ascending order
//
//      ┌─── Order<Person>
//      ▼
const byName = Order.mapInput(
  Order.string,
  (person: Person) => person.name
)
```

The `Order.mapInput` function takes two arguments:

1. The existing `Order` you want to use as a base (`Order.string` in this case, for comparing strings).
2. A function that extracts the value you want to use for sorting from your data structure (`(person: Person) => person.name` in this case).

Once you have defined your custom `Order`, you can apply it to sort an array of `Person` objects:

**Example** (Sorting Objects Using a Custom Order)

```ts

// Define the Person interface
interface Person {
  readonly name: string
  readonly age: number
}

// Create a custom order to sort Person objects by name in ascending order
const byName = Order.mapInput(
  Order.string,
  (person: Person) => person.name
)

const persons: ReadonlyArray<Person> = [
  { name: "Charlie", age: 22 },
  { name: "Alice", age: 25 },
  { name: "Bob", age: 30 }
]

// Sort persons array using the custom order
const sortedPersons = Array.sort(persons, byName)

console.log(sortedPersons)
/*
Output:
[
  { name: 'Alice', age: 25 },
  { name: 'Bob', age: 30 },
  { name: 'Charlie', age: 22 }
]
*/
```

## Combining Orders

The Order module lets you combine multiple `Order` instances to create complex sorting rules. This is useful when sorting by multiple properties.

**Example** (Sorting by Multiple Criteria)

Imagine you have a list of people, each represented by an object with a `name` and an `age`. You want to sort this list first by name and then, for individuals with the same name, by age.

```ts

// Define the Person interface
interface Person {
  readonly name: string
  readonly age: number
}

// Create an Order to sort people by their names in ascending order
const byName = Order.mapInput(
  Order.string,
  (person: Person) => person.name
)

// Create an Order to sort people by their ages in ascending order
const byAge = Order.mapInput(Order.number, (person: Person) => person.age)

// Combine orders to sort by name, then by age
const byNameAge = Order.combine(byName, byAge)

const result = Array.sort(
  [
    { name: "Bob", age: 20 },
    { name: "Alice", age: 18 },
    { name: "Bob", age: 18 }
  ],
  byNameAge
)

console.log(result)
/*
Output:
[
  { name: 'Alice', age: 18 }, // Sorted by name
  { name: 'Bob', age: 18 },   // Sorted by age within the same name
  { name: 'Bob', age: 20 }
]
*/
```

## Additional Useful Functions

The Order module provides additional functions for common comparison operations, making it easier to work with ordered values.

### Reversing Order

`Order.reverse` inverts the order of comparison. If you have an `Order` for ascending values, reversing it makes it descending.

**Example** (Reversing an Order)

```ts

const ascendingOrder = Order.number

const descendingOrder = Order.reverse(ascendingOrder)

console.log(ascendingOrder(1, 3))
// Output: -1 (1 < 3 in ascending order)
console.log(descendingOrder(1, 3))
// Output: 1 (1 > 3 in descending order)
```

### Comparing Values

These functions allow you to perform simple comparisons between values:

| API                    | Description                                              |
| ---------------------- | -------------------------------------------------------- |
| `lessThan`             | Checks if one value is strictly less than another.       |
| `greaterThan`          | Checks if one value is strictly greater than another.    |
| `lessThanOrEqualTo`    | Checks if one value is less than or equal to another.    |
| `greaterThanOrEqualTo` | Checks if one value is greater than or equal to another. |

**Example** (Using Comparison Functions)

```ts

console.log(Order.lessThan(Order.number)(1, 2))
// Output: true (1 < 2)

console.log(Order.greaterThan(Order.number)(5, 3))
// Output: true (5 > 3)

console.log(Order.lessThanOrEqualTo(Order.number)(2, 2))
// Output: true (2 <= 2)

console.log(Order.greaterThanOrEqualTo(Order.number)(4, 4))
// Output: true (4 >= 4)
```

### Finding Minimum and Maximum

The `Order.min` and `Order.max` functions return the minimum or maximum value between two values, considering the order.

**Example** (Finding Minimum and Maximum Numbers)

```ts

console.log(Order.min(Order.number)(3, 1))
// Output: 1 (1 is the minimum)

console.log(Order.max(Order.number)(5, 8))
// Output: 8 (8 is the maximum)
```

### Clamping Values

`Order.clamp` restricts a value within a given range. If the value is outside the range, it is adjusted to the nearest bound.

**Example** (Clamping Numbers to a Range)

```ts

// Define a function to clamp numbers between 20 and 30
const clampNumbers = Order.clamp(Order.number)({
  minimum: 20,
  maximum: 30
})

// Value 26 is within the range [20, 30], so it remains unchanged
console.log(clampNumbers(26))
// Output: 26

// Value 10 is below the minimum bound, so it is clamped to 20
console.log(clampNumbers(10))
// Output: 20

// Value 40 is above the maximum bound, so it is clamped to 30
console.log(clampNumbers(40))
// Output: 30
```

### Checking Value Range

`Order.between` checks if a value falls within a specified inclusive range.

**Example** (Checking if Numbers Fall Within a Range)

```ts

// Create a function to check if numbers are between 20 and 30
const betweenNumbers = Order.between(Order.number)({
  minimum: 20,
  maximum: 30
})

// Value 26 falls within the range [20, 30], so it returns true
console.log(betweenNumbers(26))
// Output: true

// Value 10 is below the minimum bound, so it returns false
console.log(betweenNumbers(10))
// Output: false

// Value 40 is above the maximum bound, so it returns false
console.log(betweenNumbers(40))
// Output: false
```

# [Equal](https://effect.website/docs/trait/equal/)

## Overview

The Equal module provides a simple and convenient way to define and check for equality between two values in TypeScript.

Here are some key reasons why Effect exports an Equal module:

1. **Value-Based Equality**: JavaScript's native equality operators (`===` and `==`) check for equality by reference, meaning they compare objects based on their memory addresses rather than their content. This behavior can be problematic when you want to compare objects with the same values but different references. The Equal module offers a solution by allowing developers to define custom equality checks based on the values of objects.

2. **Custom Equality**: The Equal module enables developers to implement custom equality checks for their data types and classes. This is crucial when you have specific requirements for determining when two objects should be considered equal. By implementing the `Equal` interface, developers can define their own equality logic.

3. **Data Integrity**: In some applications, maintaining data integrity is crucial. The ability to perform value-based equality checks ensures that identical data is not duplicated within collections like sets or maps. This can lead to more efficient memory usage and more predictable behavior.

4. **Predictable Behavior**: The Equal module promotes more predictable behavior when comparing objects. By explicitly defining equality criteria, developers can avoid unexpected results that may occur with JavaScript's default reference-based equality checks.

## How to Perform Equality Checking in Effect

In Effect it's advisable to **stop using** JavaScript's `===` and `==` operators and instead rely on the `Equal.equals` function.
This function can work with any data type that implements the `Equal` interface.
Some examples of such data types include [Option](/docs/data-types/option/), [Either](/docs/data-types/either/), [HashSet](https://effect-ts.github.io/effect/effect/HashSet.ts.html), and [HashMap](https://effect-ts.github.io/effect/effect/HashMap.ts.html).

When you use `Equal.equals` and your objects do not implement the `Equal` interface, it defaults to using the `===` operator for object comparison:

**Example** (Using `Equal.equals` with Default Comparison)

```ts

// Two objects with identical properties and values
const a = { name: "Alice", age: 30 }
const b = { name: "Alice", age: 30 }

// Equal.equals falls back to the default '===' comparison
console.log(Equal.equals(a, b))
// Output: false
```

In this example, `a` and `b` are two separate objects with the same contents. However, `===` considers them different because they occupy different memory locations. This behavior can lead to unexpected results when you want to compare values based on their content.

However, you can configure your models to ensure that `Equal.equals` behaves consistently with your custom equality checks. There are two alternative approaches:

1. **Implementing the `Equal` Interface**: This method is useful when you need to define your custom equality check.

2. **Using the Data Module**: For simple value equality, the [Data](/docs/data-types/data/) module provides a more straightforward solution by automatically generating default implementations for `Equal`.

Let's explore both.

### Implementing the Equal Interface

To create custom equality behavior, you can implement the `Equal` interface in your models. This interface extends the `Hash` interface from the [Hash](/docs/trait/hash/) module.

**Example** (Implementing `Equal` and `Hash` for a Custom Class)

```ts

class Person implements Equal.Equal {
  constructor(
    readonly id: number, // Unique identifier
    readonly name: string,
    readonly age: number
  ) {}

  // Define equality based on id, name, and age
  [Equal.symbol](that: Equal.Equal): boolean {
    if (that instanceof Person) {
      return (
        Equal.equals(this.id, that.id) &&
        Equal.equals(this.name, that.name) &&
        Equal.equals(this.age, that.age)
      )
    }
    return false
  }

  // Generate a hash code based on the unique id
  [Hash.symbol](): number {
    return Hash.hash(this.id)
  }
}
```

In the above code, we define a custom equality function `[Equal.symbol]` and a hash function `[Hash.symbol]` for the `Person` class. The `Hash` interface optimizes equality checks by comparing hash values instead of the objects themselves. When you use the `Equal.equals` function to compare two objects, it first checks if their hash values are equal. If not, it quickly determines that the objects are not equal, avoiding the need for a detailed property-by-property comparison.

Once you've implemented the `Equal` interface, you can utilize the `Equal.equals` function to check for equality using your custom logic.

**Example** (Comparing `Person` Instances)

```ts

class Person implements Equal.Equal {
  constructor(
    readonly id: number, // Unique identifier for each person
    readonly name: string,
    readonly age: number
  ) {}

  // Defines equality based on id, name, and age
  [Equal.symbol](that: Equal.Equal): boolean {
    if (that instanceof Person) {
      return (
        Equal.equals(this.id, that.id) &&
        Equal.equals(this.name, that.name) &&
        Equal.equals(this.age, that.age)
      )
    }
    return false
  }

  // Generates a hash code based primarily on the unique id
  [Hash.symbol](): number {
    return Hash.hash(this.id)
  }
}

const alice = new Person(1, "Alice", 30)
console.log(Equal.equals(alice, new Person(1, "Alice", 30)))
// Output: true

const bob = new Person(2, "Bob", 40)
console.log(Equal.equals(alice, bob))
// Output: false
```

In this code, the equality check returns `true` when comparing `alice` to a new `Person` object with identical property values and `false` when comparing `alice` to `bob` due to their differing property values.

### Simplifying Equality with the Data Module

Implementing both `Equal` and `Hash` can become cumbersome when all you need is straightforward value equality checks. Luckily, the [Data](/docs/data-types/data/) module provides a simpler solution. It offers APIs that automatically generate default implementations for both `Equal` and `Hash`.

**Example** (Using `Data.struct` for Equality Checks)

```ts

const alice = Data.struct({ id: 1, name: "Alice", age: 30 })

const bob = Data.struct({ id: 2, name: "Bob", age: 40 })

console.log(
  Equal.equals(alice, Data.struct({ id: 1, name: "Alice", age: 30 }))
)
// Output: true

console.log(Equal.equals(alice, { id: 1, name: "Alice", age: 30 }))
// Output: false

console.log(Equal.equals(alice, bob))
// Output: false
```

In this example, we use the [Data.struct](/docs/data-types/data/#struct) function to create structured data objects and check their equality using `Equal.equals`. The Data module simplifies the process by providing a default implementation for both `Equal` and `Hash`, allowing you to focus on comparing values without the need for explicit implementations.

The Data module isn't limited to just structs. It can handle various data types, including tuples, arrays, and records. If you're curious about how to leverage its full range of features, you can explore the [Data module documentation](/docs/data-types/data/#value-equality).

## Working with Collections

JavaScript's built-in `Set` and `Map` can be a bit tricky when it comes to checking equality:

**Example** (Native `Set` with Reference-Based Equality)

```ts
const set = new Set()

// Adding two objects with the same content to the set
set.add({ name: "Alice", age: 30 })
set.add({ name: "Alice", age: 30 })

// Even though the objects have identical values, they are treated
// as different elements because JavaScript compares objects by reference,
// not by value.
console.log(set.size)
// Output: 2
```

Even though the two elements in the set have the same values, the set contains two elements. Why? JavaScript's `Set` checks for equality by reference, not by values.

To perform value-based equality checks, you'll need to use the `Hash*` collection types available in the `effect` package. These collection types, such as [HashSet](https://effect-ts.github.io/effect/effect/HashSet.ts.html) and [HashMap](https://effect-ts.github.io/effect/effect/HashMap.ts.html), provide support for the `Equal` interface.

### HashSet

When you use the `HashSet`, it correctly handles value-based equality checks. In the following example, even though you're adding two objects with the same values, the `HashSet` treats them as a single element.

**Example** (Using `HashSet` for Value-Based Equality)

```ts

// Creating a HashSet with objects that implement the Equal interface
const set = HashSet.empty().pipe(
  HashSet.add(Data.struct({ name: "Alice", age: 30 })),
  HashSet.add(Data.struct({ name: "Alice", age: 30 }))
)

// HashSet recognizes them as equal, so only one element is stored
console.log(HashSet.size(set))
// Output: 1
```

**Note**: It's crucial to use elements that implement the `Equal` interface, either by implementing custom equality checks or by using the Data module. This ensures proper functionality when working with `HashSet`. Without this, you'll encounter the same behavior as the native `Set` data type:

**Example** (Reference-Based Equality in `HashSet`)

```ts

// Creating a HashSet with objects that do NOT implement
// the Equal interface
const set = HashSet.empty().pipe(
  HashSet.add({ name: "Alice", age: 30 }),
  HashSet.add({ name: "Alice", age: 30 })
)

// Since these objects are compared by reference,
// HashSet considers them different
console.log(HashSet.size(set))
// Output: 2
```

In this case, without using the Data module alongside `HashSet`, you'll experience the same behavior as the native `Set` data type. The set contains two elements because it checks for equality by reference, not by values.

### HashMap

When working with the `HashMap`, you have the advantage of comparing keys by their values instead of their references. This is particularly helpful in scenarios where you want to associate values with keys based on their content.

**Example** (Value-Based Key Comparisons with `HashMap`)

```ts

// Adding two objects with identical values as keys
const map = HashMap.empty().pipe(
  HashMap.set(Data.struct({ name: "Alice", age: 30 }), 1),
  HashMap.set(Data.struct({ name: "Alice", age: 30 }), 2)
)

console.log(HashMap.size(map))
// Output: 1

// Retrieve the value associated with a key
console.log(HashMap.get(map, Data.struct({ name: "Alice", age: 30 })))
/*
Output:
{ _id: 'Option', _tag: 'Some', value: 2 }
*/
```

In this code snippet, `HashMap` is used to create a map where the keys are objects constructed with `Data.struct`. These objects contain identical values, which would usually create separate entries in a regular JavaScript `Map` because the default comparison is reference-based.

`HashMap`, however, uses value-based comparison, meaning the two objects with identical content are treated as the same key. Thus, when we add both objects, the second key-value pair overrides the first, resulting in a single entry in the map.

# [Hash](https://effect.website/docs/trait/hash/)

## Overview

The `Hash` interface is closely tied to the [Equal](/docs/trait/equal/) interface and serves a supportive role in optimizing equality checks by providing a mechanism for hashing. Hashing is an important step in the efficient determination of equality between two values, particularly when used with data structures like hash tables.

## Role of Hash in Equality Checking

The primary purpose of the `Hash` interface is to provide a quick and efficient way to determine if two values are definitely not equal, thereby complementing the [Equal](/docs/trait/equal/) interface. When two values implement the [Equal](/docs/trait/equal/) interface, their hash values (computed using the `Hash` interface) are compared first:

- **Different Hash Values**: If the hash values are different, it is guaranteed that the values themselves are different. This quick check allows the system to avoid a potentially expensive equality check.
- **Same Hash Values**: If the hash values are the same, it does not guarantee that the values are equal, only that they might be. In this case, a more thorough comparison using the [Equal](/docs/trait/equal/) interface is performed to determine actual equality.

This method dramatically speeds up the equality checking process, especially in collections where quick look-up and insertion times are crucial, such as in hash sets or hash maps.

## Implementing the Hash Interface

Consider a scenario where you have a custom `Person` class, and you want to check if two instances are equal based on their properties.
By implementing both the `Equal` and `Hash` interfaces, you can efficiently manage these checks:

**Example** (Implementing `Equal` and `Hash` for a Custom Class)

```ts

class Person implements Equal.Equal {
  constructor(
    readonly id: number, // Unique identifier
    readonly name: string,
    readonly age: number
  ) {}

  // Define equality based on id, name, and age
  [Equal.symbol](that: Equal.Equal): boolean {
    if (that instanceof Person) {
      return (
        Equal.equals(this.id, that.id) &&
        Equal.equals(this.name, that.name) &&
        Equal.equals(this.age, that.age)
      )
    }
    return false
  }

  // Generate a hash code based on the unique id
  [Hash.symbol](): number {
    return Hash.hash(this.id)
  }
}

const alice = new Person(1, "Alice", 30)
console.log(Equal.equals(alice, new Person(1, "Alice", 30)))
// Output: true

const bob = new Person(2, "Bob", 40)
console.log(Equal.equals(alice, bob))
// Output: false
```

Explanation:

- The `[Equal.symbol]` method determines equality by comparing the `id`, `name`, and `age` fields of `Person` instances. This approach ensures that the equality check is comprehensive and considers all relevant attributes.
- The `[Hash.symbol]` method computes a hash code using the `id` of the person. This value is used to quickly differentiate between instances in hashing operations, optimizing the performance of data structures that utilize hashing.
- The equality check returns `true` when comparing `alice` to a new `Person` object with identical property values and `false` when comparing `alice` to `bob` due to their differing property values.



## Common Mistakes

**Incorrect (raw string types for identifiers):**

```ts
const getUser = (id: string) => // Any string accepted
  db.findUser(id)

getUser("not-a-valid-id") // No compile error
```

**Correct (branded types for type-safe identifiers):**

```ts
import { Brand } from "effect"
type UserId = string & Brand.Brand<"UserId">
const UserId = Brand.nominal<UserId>()

const getUser = (id: UserId) => db.findUser(id)
getUser(UserId("user-123")) // Only branded values accepted
```
