---
title: "Streams and Sinks"
impact: HIGH
impactDescription: "Enables efficient streaming data processing — covers stream creation, consumption, operations, sinks"
tags: streams, sinks, streaming, data-processing
---
# [Introduction to Streams](https://effect.website/docs/stream/introduction/)

## Overview

In this guide, we'll explore the concept of a `Stream<A, E, R>`. A `Stream` is a program description that, when executed, can emit **zero or more values** of type `A`, handle errors of type `E`, and operates within a context of type `R`.

## Use Cases

Streams are particularly handy whenever you're dealing with sequences of values over time. They can serve as replacements for observables, node streams, and AsyncIterables.

## What is a Stream?

Think of a `Stream` as an extension of an `Effect`. While an `Effect<A, E, R>` represents a program that requires a context of type `R`, may encounter an error of type `E`, and always produces a single result of type `A`, a `Stream<A, E, R>` takes this further by allowing the emission of zero or more values of type `A`.

To clarify, let's examine some examples using `Effect`:

```ts

// An Effect that fails with a string error
const failedEffect = Effect.fail("fail!")

// An Effect that produces a single number
const oneNumberValue = Effect.succeed(3)

// An Effect that produces a chunk of numbers
const oneListValue = Effect.succeed(Chunk.make(1, 2, 3))

// An Effect that produces an optional number
const oneOption = Effect.succeed(Option.some(1))
```

In each case, the `Effect` always ends with **exactly one value**. There is no variability; you always get one result.

## Understanding Streams

Now, let's shift our focus to `Stream`. A `Stream` represents a program description that shares similarities with `Effect`, it requires a context of type `R`, may signal errors of type `E`, and yields values of type `A`. However, the key distinction is that it can yield **zero or more values**.

Here are the possible scenarios for a `Stream`:

- **An Empty Stream**: It can end up empty, representing a stream with no values.
- **A Single-Element Stream**: It can represent a stream with just one value.
- **A Finite Stream of Elements**: It can represent a stream with a finite number of values.
- **An Infinite Stream of Elements**: It can represent a stream that continues indefinitely, essentially an infinite stream.

Let's see these scenarios in action:

```ts

// An empty Stream
const emptyStream = Stream.empty

// A Stream with a single number
const oneNumberValueStream = Stream.succeed(3)

// A Stream with a range of numbers from 1 to 10
const finiteNumberStream = Stream.range(1, 10)

// An infinite Stream of numbers starting from 1 and incrementing
const infiniteNumberStream = Stream.iterate(1, (n) => n + 1)
```

In summary, a `Stream` is a versatile tool for representing programs that may yield multiple values, making it suitable for a wide range of tasks, from processing finite lists to handling infinite sequences.


---

# [Creating Streams](https://effect.website/docs/stream/creating/)

## Overview

In this section, we'll explore various methods for creating Effect `Stream`s. These methods will help you generate streams tailored to your needs.

## Common Constructors

### make

You can create a pure stream by using the `Stream.make` constructor. This constructor accepts a variable list of values as its arguments.

```ts

const stream = Stream.make(1, 2, 3)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ 1, 2, 3 ] }
```

### empty

Sometimes, you may require a stream that doesn't produce any values. In such cases, you can use `Stream.empty`. This constructor creates a stream that remains empty.

```ts

const stream = Stream.empty

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [] }
```

### void

If you need a stream that contains a single `void` value, you can use `Stream.void`. This constructor is handy when you want to represent a stream with a single event or signal.

```ts

const stream = Stream.void

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ undefined ] }
```

### range

To create a stream of integers within a specified range `[min, max]` (including both endpoints, `min` and `max`), you can use `Stream.range`. This is particularly useful for generating a stream of sequential numbers.

```ts

// Creating a stream of numbers from 1 to 5
const stream = Stream.range(1, 5)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ 1, 2, 3, 4, 5 ] }
```

### iterate

With `Stream.iterate`, you can generate a stream by applying a function iteratively to an initial value. The initial value becomes the first element produced by the stream, followed by subsequent values produced by `f(init)`, `f(f(init))`, and so on.

```ts

// Creating a stream of incrementing numbers
const stream = Stream.iterate(1, (n) => n + 1) // Produces 1, 2, 3, ...

Effect.runPromise(Stream.runCollect(stream.pipe(Stream.take(5)))).then(
  console.log
)
// { _id: 'Chunk', values: [ 1, 2, 3, 4, 5 ] }
```

### scoped

`Stream.scoped` is used to create a single-valued stream from a scoped resource. It can be handy when dealing with resources that require explicit acquisition, usage, and release.

```ts

// Creating a single-valued stream from a scoped resource
const stream = Stream.scoped(
  Effect.acquireUseRelease(
    Console.log("acquire"),
    () => Console.log("use"),
    () => Console.log("release")
  )
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
acquire
use
release
{ _id: 'Chunk', values: [ undefined ] }
*/
```

## From Success and Failure

Much like the `Effect` data type, you can generate a `Stream` using the `fail` and `succeed` functions:

```ts

// Creating a stream that can emit errors
const streamWithError: Stream.Stream<never, string> =
  Stream.fail("Uh oh!")

Effect.runPromise(Stream.runCollect(streamWithError))
// throws Error: Uh oh!

// Creating a stream that emits a numeric value
const streamWithNumber: Stream.Stream<number> = Stream.succeed(5)

Effect.runPromise(Stream.runCollect(streamWithNumber)).then(console.log)
// { _id: 'Chunk', values: [ 5 ] }
```

## From Chunks

You can construct a stream from a `Chunk` like this:

```ts

// Creating a stream with values from a single Chunk
const stream = Stream.fromChunk(Chunk.make(1, 2, 3))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ 1, 2, 3 ] }
```

Moreover, you can create a stream from multiple `Chunk`s as well:

```ts

// Creating a stream with values from multiple Chunks
const stream = Stream.fromChunks(Chunk.make(1, 2, 3), Chunk.make(4, 5, 6))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ 1, 2, 3, 4, 5, 6 ] }
```

## From Effect

You can generate a stream from an Effect workflow by employing the `Stream.fromEffect` constructor. For instance, consider the following stream, which generates a single random number:

```ts

const stream = Stream.fromEffect(Random.nextInt)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// Example Output: { _id: 'Chunk', values: [ 1042302242 ] }
```

This method allows you to seamlessly transform the output of an Effect into a stream, providing a straightforward way to work with asynchronous operations within your streams.

## From Asynchronous Callback

Imagine you have an asynchronous function that relies on callbacks. If you want to capture the results emitted by those callbacks as a stream, you can use the `Stream.async` function. This function is designed to adapt functions that invoke their callbacks multiple times and emit the results as a stream.

Let's break down how to use it in the following example:

```ts

const events = [1, 2, 3, 4]

const stream = Stream.async(
  (emit: StreamEmit.Emit<never, never, number, void>) => {
    events.forEach((n) => {
      setTimeout(() => {
        if (n === 3) {
          // Terminate the stream
          emit(Effect.fail(Option.none()))
        } else {
          // Add the current item to the stream
          emit(Effect.succeed(Chunk.of(n)))
        }
      }, 100 * n)
    })
  }
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ 1, 2 ] }
```

The `StreamEmit.Emit<R, E, A, void>` type represents an asynchronous callback that can be called multiple times. This callback takes a value of type `Effect<Chunk<A>, Option<E>, R>`. Here's what each of the possible outcomes means:

- When the value provided to the callback results in a `Chunk<A>` upon success, it signifies that the specified elements should be emitted as part of the stream.

- If the value passed to the callback results in a failure with `Some<E>`, it indicates the termination of the stream with the specified error.

- When the value passed to the callback results in a failure with `None`, it serves as a signal for the end of the stream, essentially terminating it.

To put it simply, this type allows you to specify how your asynchronous callback interacts with the stream, determining when to emit elements, when to terminate with an error, or when to signal the end of the stream.

## From Iterables

### fromIterable

You can create a pure stream from an `Iterable` of values using the `Stream.fromIterable` constructor. It's a straightforward way to convert a collection of values into a stream.

```ts

const numbers = [1, 2, 3]

const stream = Stream.fromIterable(numbers)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ 1, 2, 3 ] }
```

### fromIterableEffect

When you have an effect that produces a value of type `Iterable`, you can employ the `Stream.fromIterableEffect` constructor to generate a stream from that effect.

For instance, let's say you have a database operation that retrieves a list of users. Since this operation involves effects, you can utilize `Stream.fromIterableEffect` to convert the result into a `Stream`:

```ts

class Database extends Context.Tag("Database")<
  Database,
  { readonly getUsers: Effect.Effect<Array<string>> }
>() {}

const getUsers = Database.pipe(Effect.andThen((_) => _.getUsers))

const stream = Stream.fromIterableEffect(getUsers)

Effect.runPromise(
  Stream.runCollect(
    stream.pipe(
      Stream.provideService(Database, {
        getUsers: Effect.succeed(["user1", "user2"])
      })
    )
  )
).then(console.log)
// { _id: 'Chunk', values: [ 'user1', 'user2' ] }
```

This enables you to work seamlessly with effects and convert their results into streams for further processing.

### fromAsyncIterable

Async iterables are another type of data source that can be converted into a stream. With the `Stream.fromAsyncIterable` constructor, you can work with asynchronous data sources and handle potential errors gracefully.

```ts

const myAsyncIterable = async function* () {
  yield 1
  yield 2
}

const stream = Stream.fromAsyncIterable(
  myAsyncIterable(),
  (e) => new Error(String(e)) // Error Handling
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ 1, 2 ] }
```

In this code, we define an async iterable and then create a stream named `stream` from it. Additionally, we provide an error handler function to manage any potential errors that may occur during the conversion.

## From Repetition

### Repeating a Single Value

You can create a stream that endlessly repeats a specific value using the `Stream.repeatValue` constructor:

```ts

const stream = Stream.repeatValue(0)

Effect.runPromise(Stream.runCollect(stream.pipe(Stream.take(5)))).then(
  console.log
)
// { _id: 'Chunk', values: [ 0, 0, 0, 0, 0 ] }
```

### Repeating a Stream's Content

`Stream.repeat` allows you to create a stream that repeats a specified stream's content according to a schedule. This can be useful for generating recurring events or values.

```ts

// Creating a stream that repeats a value indefinitely
const stream = Stream.repeat(Stream.succeed(1), Schedule.forever)

Effect.runPromise(Stream.runCollect(stream.pipe(Stream.take(5)))).then(
  console.log
)
// { _id: 'Chunk', values: [ 1, 1, 1, 1, 1 ] }
```

### Repeating an Effect's Result

Imagine you have an effectful API call, and you want to use the result of that call to create a stream. You can achieve this by creating a stream from the effect and repeating it indefinitely.

Here's an example of generating a stream of random numbers:

```ts

const stream = Stream.repeatEffect(Random.nextInt)

Effect.runPromise(Stream.runCollect(stream.pipe(Stream.take(5)))).then(
  console.log
)
/*
Example Output:
{
  _id: 'Chunk',
  values: [ 1666935266, 604851965, 2194299958, 3393707011, 4090317618 ]
}
*/
```

### Repeating an Effect with Termination

You can repeatedly evaluate a given effect and terminate the stream based on specific conditions.

In this example, we're draining an `Iterator` to create a stream from it:

```ts

const drainIterator = <A>(it: Iterator<A>): Stream.Stream<A> =>
  Stream.repeatEffectOption(
    Effect.sync(() => it.next()).pipe(
      Effect.andThen((res) => {
        if (res.done) {
          return Effect.fail(Option.none())
        }
        return Effect.succeed(res.value)
      })
    )
  )
```

### Generating Ticks

You can create a stream that emits `void` values at specified intervals using the `Stream.tick` constructor. This is useful for creating periodic events.

```ts

const stream = Stream.tick("100 millis")

Effect.runPromise(Stream.runCollect(stream.pipe(Stream.take(5)))).then(
  console.log
)
/*
Output:
{
  _id: 'Chunk',
  values: [ undefined, undefined, undefined, undefined, undefined ]
}
*/
```

## From Unfolding/Pagination

In functional programming, the concept of `unfold` can be thought of as the counterpart to `fold`.

With `fold`, we process a data structure and produce a return value. For example, we can take an `Array<number>` and calculate the sum of its elements.

On the other hand, `unfold` represents an operation where we start with an initial value and generate a recursive data structure, adding one element at a time using a specified state function. For example, we can create a sequence of natural numbers starting from `1` and using the `increment` function as the state function.

### Unfold

#### unfold

The Stream module includes an `unfold` function defined as follows:

```ts
declare const unfold: <S, A>(
  initialState: S,
  step: (s: S) => Option.Option<readonly [A, S]>
) => Stream<A>
```

Here's how it works:

- **initialState**. This is the initial state value.
- **step**. The state function `step` takes the current state `s` as input. If the result of this function is `None`, the stream ends. If it's `Some<[A, S]>`, the next element in the stream is `A`, and the state `S` is updated for the next step process.

For example, let's create a stream of natural numbers using `Stream.unfold`:

```ts

const stream = Stream.unfold(1, (n) => Option.some([n, n + 1]))

Effect.runPromise(Stream.runCollect(stream.pipe(Stream.take(5)))).then(
  console.log
)
// { _id: 'Chunk', values: [ 1, 2, 3, 4, 5 ] }
```

#### unfoldEffect

Sometimes, we may need to perform effectful state transformations during the unfolding operation. This is where `Stream.unfoldEffect` comes in handy. It allows us to work with effects while generating streams.

Here's an example of creating an infinite stream of random `1` and `-1` values using `Stream.unfoldEffect`:

```ts

const stream = Stream.unfoldEffect(1, (n) =>
  Random.nextBoolean.pipe(
    Effect.map((b) => (b ? Option.some([n, -n]) : Option.some([n, n])))
  )
)

Effect.runPromise(Stream.runCollect(stream.pipe(Stream.take(5)))).then(
  console.log
)
// Example Output: { _id: 'Chunk', values: [ 1, 1, 1, 1, -1 ] }
```

#### Additional Variants

There are also similar operations like `Stream.unfoldChunk` and `Stream.unfoldChunkEffect` tailored for working with `Chunk` data types.

### Pagination

#### paginate

`Stream.paginate` is similar to `Stream.unfold` but allows emitting values one step further.

For example, the following stream emits `0, 1, 2, 3` elements:

```ts

const stream = Stream.paginate(0, (n) => [
  n,
  n < 3 ? Option.some(n + 1) : Option.none()
])

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
// { _id: 'Chunk', values: [ 0, 1, 2, 3 ] }
```

Here's how it works:

- We start with an initial value of `0`.
- The provided function takes the current value `n` and returns a tuple. The first element of the tuple is the value to emit (`n`), and the second element determines whether to continue (`Option.some(n + 1)`) or stop (`Option.none()`).

#### Additional Variants

There are also similar operations like `Stream.paginateChunk` and `Stream.paginateChunkEffect` tailored for working with `Chunk` data types.

### Unfolding vs. Pagination

You might wonder about the difference between the `unfold` and `paginate` combinators and when to use one over the other. Let's explore this by diving into an example.

Imagine we have a paginated API that provides a substantial amount of data in a paginated manner. When we make a request to this API, it returns a `ResultPage` object containing the results for the current page and a flag indicating whether it's the last page or if there's more data to retrieve on the next page. Here's a simplified representation of our API:

```ts

type RawData = string

class PageResult {
  constructor(
    readonly results: Chunk.Chunk<RawData>,
    readonly isLast: boolean
  ) {}
}

const pageSize = 2

const listPaginated = (
  pageNumber: number
): Effect.Effect<PageResult, Error> => {
  return Effect.succeed(
    new PageResult(
      Chunk.map(
        Chunk.range(1, pageSize),
        (index) => `Result ${pageNumber}-${index}`
      ),
      pageNumber === 2 // Return 3 pages
    )
  )
}
```

Our goal is to convert this paginated API into a stream of `RowData` events. For our initial attempt, we might think that using the `Stream.unfold` operation is the way to go:

```ts

type RawData = string

class PageResult {
  constructor(
    readonly results: Chunk.Chunk<RawData>,
    readonly isLast: boolean
  ) {}
}

const pageSize = 2

const listPaginated = (
  pageNumber: number
): Effect.Effect<PageResult, Error> => {
  return Effect.succeed(
    new PageResult(
      Chunk.map(
        Chunk.range(1, pageSize),
        (index) => `Result ${pageNumber}-${index}`
      ),
      pageNumber === 2 // Return 3 pages
    )
  )
}

const firstAttempt = Stream.unfoldChunkEffect(0, (pageNumber) =>
  listPaginated(pageNumber).pipe(
    Effect.map((page) => {
      if (page.isLast) {
        return Option.none()
      }
      return Option.some([page.results, pageNumber + 1] as const)
    })
  )
)

Effect.runPromise(Stream.runCollect(firstAttempt)).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [ "Result 0-1", "Result 0-2", "Result 1-1", "Result 1-2" ]
}
*/
```

However, this approach has a drawback, it doesn't include the results from the last page. To work around this, we perform an extra API call to include those missing results:

```ts

type RawData = string

class PageResult {
  constructor(
    readonly results: Chunk.Chunk<RawData>,
    readonly isLast: boolean
  ) {}
}

const pageSize = 2

const listPaginated = (
  pageNumber: number
): Effect.Effect<PageResult, Error> => {
  return Effect.succeed(
    new PageResult(
      Chunk.map(
        Chunk.range(1, pageSize),
        (index) => `Result ${pageNumber}-${index}`
      ),
      pageNumber === 2 // Return 3 pages
    )
  )
}

const secondAttempt = Stream.unfoldChunkEffect(
  Option.some(0),
  (pageNumber) =>
    Option.match(pageNumber, {
      // We already hit the last page
      onNone: () => Effect.succeed(Option.none()),
      // We did not hit the last page yet
      onSome: (pageNumber) =>
        listPaginated(pageNumber).pipe(
          Effect.map((page) =>
            Option.some([
              page.results,
              page.isLast ? Option.none() : Option.some(pageNumber + 1)
            ])
          )
        )
    })
)

Effect.runPromise(Stream.runCollect(secondAttempt)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    'Result 0-1',
    'Result 0-2',
    'Result 1-1',
    'Result 1-2',
    'Result 2-1',
    'Result 2-2'
  ]
}
*/
```

While this approach works, it's clear that `Stream.unfold` isn't the most friendly option for retrieving data from paginated APIs. It requires additional workarounds to include the results from the last page.

This is where `Stream.paginate` comes to the rescue. It provides a more ergonomic way to convert a paginated API into an Effect stream. Let's rewrite our solution using `Stream.paginate`:

```ts

type RawData = string

class PageResult {
  constructor(
    readonly results: Chunk.Chunk<RawData>,
    readonly isLast: boolean
  ) {}
}

const pageSize = 2

const listPaginated = (
  pageNumber: number
): Effect.Effect<PageResult, Error> => {
  return Effect.succeed(
    new PageResult(
      Chunk.map(
        Chunk.range(1, pageSize),
        (index) => `Result ${pageNumber}-${index}`
      ),
      pageNumber === 2 // Return 3 pages
    )
  )
}

const finalAttempt = Stream.paginateChunkEffect(0, (pageNumber) =>
  listPaginated(pageNumber).pipe(
    Effect.andThen((page) => {
      return [
        page.results,
        page.isLast ? Option.none<number>() : Option.some(pageNumber + 1)
      ]
    })
  )
)

Effect.runPromise(Stream.runCollect(finalAttempt)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    'Result 0-1',
    'Result 0-2',
    'Result 1-1',
    'Result 1-2',
    'Result 2-1',
    'Result 2-2'
  ]
}
*/
```

## From Queue and PubSub

In Effect, there are two essential asynchronous messaging data types: [Queue](/docs/concurrency/queue/) and [PubSub](/docs/concurrency/pubsub/). You can easily transform these data types into `Stream`s by utilizing `Stream.fromQueue` and `Stream.fromPubSub`, respectively.

## From Schedule

We can create a stream from a `Schedule` that does not require any further input. The stream will emit an element for each value output from the schedule, continuing for as long as the schedule continues:

```ts

// Emits values every 1 second for a total of 10 emissions
const schedule = Schedule.spaced("1 second").pipe(
  Schedule.compose(Schedule.recurs(10))
)

const stream = Stream.fromSchedule(schedule)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    0, 1, 2, 3, 4,
    5, 6, 7, 8, 9
  ]
}
*/
```


---

# [Consuming Streams](https://effect.website/docs/stream/consuming-streams/)

## Overview

When working with streams, it's essential to understand how to consume the data they produce.
In this guide, we'll walk through several common methods for consuming streams.

## Using runCollect

To gather all the elements from a stream into a single `Chunk`, you can use the `Stream.runCollect` function.

```ts

const stream = Stream.make(1, 2, 3, 4, 5)

const collectedData = Stream.runCollect(stream)

Effect.runPromise(collectedData).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [ 1, 2, 3, 4, 5 ]
}
*/
```

## Using runForEach

Another way to consume elements of a stream is by using `Stream.runForEach`. It takes a callback function that receives each element of the stream. Here's an example:

```ts

const effect = Stream.make(1, 2, 3).pipe(
  Stream.runForEach((n) => Console.log(n))
)

Effect.runPromise(effect).then(console.log)
/*
Output:
1
2
3
undefined
*/
```

In this example, we use `Stream.runForEach` to log each element to the console.

## Using a Fold Operation

The `Stream.fold` function is another way to consume a stream by performing a fold operation over the stream of values and returning an effect containing the result. Here are a couple of examples:

```ts

const foldedStream = Stream.make(1, 2, 3, 4, 5).pipe(
  Stream.runFold(0, (a, b) => a + b)
)

Effect.runPromise(foldedStream).then(console.log)
// Output: 15

const foldedWhileStream = Stream.make(1, 2, 3, 4, 5).pipe(
  Stream.runFoldWhile(
    0,
    (n) => n <= 3,
    (a, b) => a + b
  )
)

Effect.runPromise(foldedWhileStream).then(console.log)
// Output: 6
```

In the first example (`foldedStream`), we use `Stream.runFold` to calculate the sum of all elements. In the second example (`foldedWhileStream`), we use `Stream.runFoldWhile` to calculate the sum but only until a certain condition is met.

## Using a Sink

To consume a stream using a Sink, you can pass the `Sink` to the `Stream.run` function. Here's an example:

```ts

const effect = Stream.make(1, 2, 3).pipe(Stream.run(Sink.sum))

Effect.runPromise(effect).then(console.log)
// Output: 6
```

In this example, we use a `Sink` to calculate the sum of the elements in the stream.


---

# [Operations](https://effect.website/docs/stream/operations/)

## Overview


In this guide, we'll explore some essential operations you can perform on streams. These operations allow you to manipulate and interact with stream elements in various ways.

## Tapping

The `Stream.tap` operation allows you to run an effect on each element emitted by the stream, observing or performing side effects without altering the elements or return type. This can be useful for logging, monitoring, or triggering additional actions with each emission.

**Example** (Logging with `Stream.tap`)

For example, `Stream.tap` can be used to log each element before and after a mapping operation:

```ts

const stream = Stream.make(1, 2, 3).pipe(
  Stream.tap((n) => Console.log(`before mapping: ${n}`)),
  Stream.map((n) => n * 2),
  Stream.tap((n) => Console.log(`after mapping: ${n}`))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
before mapping: 1
after mapping: 2
before mapping: 2
after mapping: 4
before mapping: 3
after mapping: 6
{ _id: 'Chunk', values: [ 2, 4, 6 ] }
*/
```

## Taking Elements

The "taking" operations in streams let you extract a specific set of elements, either by a fixed number, condition, or position within the stream. Here are a few ways to apply these operations:

| API         | Description                                           |
| ----------- | ----------------------------------------------------- |
| `take`      | Extracts a fixed number of elements.                  |
| `takeWhile` | Extracts elements while a certain condition is met.   |
| `takeUntil` | Extracts elements until a certain condition is met.   |
| `takeRight` | Extracts a specified number of elements from the end. |

**Example** (Extracting Elements in Different Ways)

```ts

const stream = Stream.iterate(0, (n) => n + 1)

// Using `take` to extract a fixed number of elements:
const s1 = Stream.take(stream, 5)
Effect.runPromise(Stream.runCollect(s1)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 0, 1, 2, 3, 4 ] }
*/

// Using `takeWhile` to extract elements while a condition is met:
const s2 = Stream.takeWhile(stream, (n) => n < 5)
Effect.runPromise(Stream.runCollect(s2)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 0, 1, 2, 3, 4 ] }
*/

// Using `takeUntil` to extract elements until a condition is met:
const s3 = Stream.takeUntil(stream, (n) => n === 5)
Effect.runPromise(Stream.runCollect(s3)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 0, 1, 2, 3, 4, 5 ] }
*/

// Using `takeRight` to take elements from the end of the stream:
const s4 = Stream.takeRight(s3, 3)
Effect.runPromise(Stream.runCollect(s4)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 3, 4, 5 ] }
*/
```

## Streams as an Alternative to Async Iterables

When working with asynchronous data sources, such as async iterables, you often need to consume data in a loop until a certain condition is met. Streams provide a similar approach and offer additional flexibility.

With async iterables, data is processed in a loop until a break or return statement is encountered. To replicate this behavior with Streams, consider these options:

| API         | Description                                                                                                                                                           |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `takeUntil` | Takes elements from a stream until a specified condition is met, similar to breaking out of a loop.                                                                   |
| `toPull`    | Returns an effect that continuously pulls data chunks from the stream. This effect can fail with `None` when the stream is finished or with `Some` error if it fails. |

**Example** (Using `Stream.toPull`)

```ts

// Simulate a chunked stream
const stream = Stream.fromIterable([1, 2, 3, 4, 5]).pipe(
  Stream.rechunk(2)
)

const program = Effect.gen(function* () {
  // Create an effect to get data chunks from the stream
  const getChunk = yield* Stream.toPull(stream)

  // Continuously fetch and process chunks
  while (true) {
    const chunk = yield* getChunk
    console.log(chunk)
  }
})

Effect.runPromise(Effect.scoped(program)).then(console.log, console.error)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2 ] }
{ _id: 'Chunk', values: [ 3, 4 ] }
{ _id: 'Chunk', values: [ 5 ] }
(FiberFailure) Error: {
  "_id": "Option",
  "_tag": "None"
}
*/
```

## Mapping

### Basic Mapping

The `Stream.map` operation applies a specified function to each element in a stream, creating a new stream with the transformed values.

**Example** (Incrementing Each Element by 1)

```ts

const stream = Stream.make(1, 2, 3).pipe(
  Stream.map((n) => n + 1) // Increment each element by 1
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 2, 3, 4 ] }
*/
```

### Mapping to a Constant Value

The `Stream.as` method allows you to replace each success value in a stream with a specified constant value. This can be useful when you want all elements in the stream to emit a uniform value, regardless of the original data.

**Example** (Mapping to `null`)

```ts

const stream = Stream.range(1, 5).pipe(Stream.as(null))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ null, null, null, null, null ] }
*/
```

### Effectful Mapping

For transformations involving effects, use `Stream.mapEffect`. This function applies an effectful operation to each element in the stream, producing a new stream with effectful results.

**Example** (Random Number Generation)

```ts

const stream = Stream.make(10, 20, 30).pipe(
  // Generate a random number between 0 and each element
  Stream.mapEffect((n) => Random.nextIntBetween(0, n))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Example Output:
{ _id: 'Chunk', values: [ 5, 9, 22 ] }
*/
```

To handle multiple effectful transformations concurrently, you can use the [concurrency](/docs/concurrency/basic-concurrency/#concurrency-options) option. This option allows a specified number of effects to run concurrently, with results emitted downstream in their original order.

**Example** (Fetching URLs Concurrently)

```ts

const fetchUrl = (url: string) =>
  Effect.gen(function* () {
    console.log(`Fetching ${url}`)
    yield* Effect.sleep("100 millis")
    console.log(`Fetching ${url} done`)
    return [`Resource 0-${url}`, `Resource 1-${url}`, `Resource 2-${url}`]
  })

const stream = Stream.make("url1", "url2", "url3").pipe(
  // Fetch each URL concurrently with a limit of 2
  Stream.mapEffect(fetchUrl, { concurrency: 2 })
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
Fetching url1
Fetching url2
Fetching url1 done
Fetching url3
Fetching url2 done
Fetching url3 done
{
  _id: 'Chunk',
  values: [
    [ 'Resource 0-url1', 'Resource 1-url1', 'Resource 2-url1' ],
    [ 'Resource 0-url2', 'Resource 1-url2', 'Resource 2-url2' ],
    [ 'Resource 0-url3', 'Resource 1-url3', 'Resource 2-url3' ]
  ]
}
*/
```

### Stateful Mapping

`Stream.mapAccum` is similar to `Stream.map`, but it applies a transformation with state tracking, allowing you to map and accumulate values within a single operation. This is useful for tasks like calculating a running total in a stream.

**Example** (Calculating a Running Total)

```ts

const stream = Stream.range(1, 5).pipe(
  //                                  ┌─── next state
  //                                  │          ┌─── emitted value
  //                                  ▼          ▼
  Stream.mapAccum(0, (state, n) => [state + n, state + n])
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 3, 6, 10, 15 ] }
*/
```

### Mapping and Flattening

The `Stream.mapConcat` operation is similar to `Stream.map`, but it goes further by mapping each element to zero or more elements (as an `Iterable`) and then flattening the entire stream. This is particularly useful for transforming each element into multiple values.

**Example** (Splitting and Flattening a Stream)

```ts

const numbers = Stream.make("1-2-3", "4-5", "6").pipe(
  Stream.mapConcat((s) => s.split("-"))
)

Effect.runPromise(Stream.runCollect(numbers)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ '1', '2', '3', '4', '5', '6' ] }
*/
```

## Filtering

The `Stream.filter` operation allows you to pass through only elements that meet a specific condition. It's a way to retain elements in a stream that satisfy a particular criteria while discarding the rest.

**Example** (Filtering Even Numbers)

```ts

const stream = Stream.range(1, 11).pipe(Stream.filter((n) => n % 2 === 0))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 2, 4, 6, 8, 10 ] }
*/
```

## Scanning

Stream scanning allows you to apply a function cumulatively to each element in the stream, emitting every intermediate result. Unlike `reduce`, which only provides a final result, `scan` offers a step-by-step view of the accumulation process.

**Example** (Cumulative Addition)

```ts

const stream = Stream.range(1, 5).pipe(Stream.scan(0, (a, b) => a + b))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 0, 1, 3, 6, 10, 15 ] }
*/
```

If you need only the final accumulated value, you can use [Stream.runFold](/docs/stream/consuming-streams/#using-a-fold-operation):

**Example** (Final Accumulated Result)

```ts

const fold = Stream.range(1, 5).pipe(Stream.runFold(0, (a, b) => a + b))

Effect.runPromise(fold).then(console.log) // Output: 15
```

## Draining

Stream draining lets you execute effectful operations within a stream while discarding the resulting values. This can be useful when you need to run actions or perform side effects but don't require the emitted values. The `Stream.drain` function achieves this by ignoring all elements in the stream and producing an empty output stream.

**Example** (Executing Effectful Operations without Collecting Values)

```ts

const stream = Stream.repeatEffect(
  Effect.gen(function* () {
    const nextInt = yield* Random.nextInt
    const number = Math.abs(nextInt % 10)
    console.log(`random number: ${number}`)
    return number
  })
).pipe(Stream.take(3))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Example Output:
random number: 7
random number: 5
random number: 0
{ _id: 'Chunk', values: [ 7, 5, 0 ] }
*/

const drained = Stream.drain(stream)

Effect.runPromise(Stream.runCollect(drained)).then(console.log)
/*
Example Output:
random number: 0
random number: 1
random number: 7
{ _id: 'Chunk', values: [] }
*/
```

## Detecting Changes in a Stream

The `Stream.changes` operation detects and emits elements that differ from their preceding elements within a stream. This can be useful for tracking changes or deduplicating consecutive values.

**Example** (Emitting Distinct Consecutive Elements)

```ts

const stream = Stream.make(1, 1, 1, 2, 2, 3, 4).pipe(Stream.changes)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2, 3, 4 ] }
*/
```

## Zipping

Zipping combines elements from two streams into a new stream, pairing elements from each input stream. This can be achieved with `Stream.zip` or `Stream.zipWith`, allowing for custom pairing logic.

**Example** (Basic Zipping)

In this example, elements from the two streams are paired sequentially. The resulting stream ends when one of the streams is exhausted.

```ts

// Zip two streams together
const stream = Stream.zip(
  Stream.make(1, 2, 3, 4, 5, 6),
  Stream.make("a", "b", "c")
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ [ 1, 'a' ], [ 2, 'b' ], [ 3, 'c' ] ] }
*/
```

**Example** (Custom Zipping Logic)

Here, `Stream.zipWith` applies custom logic to each pair, combining elements in a user-defined way.

```ts

// Zip two streams with custom pairing logic
const stream = Stream.zipWith(
  Stream.make(1, 2, 3, 4, 5, 6),
  Stream.make("a", "b", "c"),
  (n, s) => [n + 10, s + "!"]
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ [ 11, 'a!' ], [ 12, 'b!' ], [ 13, 'c!' ] ] }
*/
```

### Handling Stream Endings

If one input stream ends before the other, you might want to zip with default values to avoid missing pairs. The `Stream.zipAll` and `Stream.zipAllWith` operators provide this functionality, allowing you to specify defaults for either stream.

**Example** (Zipping with Default Values)

In this example, when the second stream completes, the first stream continues with "x" as a default value for the second stream.

```ts

const stream = Stream.zipAll(Stream.make(1, 2, 3, 4, 5, 6), {
  other: Stream.make("a", "b", "c"),
  defaultSelf: -1,
  defaultOther: "x"
})

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    [ 1, 'a' ],
    [ 2, 'b' ],
    [ 3, 'c' ],
    [ 4, 'x' ],
    [ 5, 'x' ],
    [ 6, 'x' ]
  ]
}
*/
```

**Example** (Custom Logic with zipAllWith)

With `Stream.zipAllWith`, custom logic determines how to combine elements when either stream runs out, offering flexibility to handle these cases.

```ts

const stream = Stream.zipAllWith(Stream.make(1, 2, 3, 4, 5, 6), {
  other: Stream.make("a", "b", "c"),
  onSelf: (n) => [n, "x"],
  onOther: (s) => [-1, s],
  onBoth: (n, s) => [n + 10, s + "!"]
})

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    [ 11, 'a!' ],
    [ 12, 'b!' ],
    [ 13, 'c!' ],
    [ 4, 'x' ],
    [ 5, 'x' ],
    [ 6, 'x' ]
  ]
}
*/
```

### Zipping Streams at Different Rates

When combining streams that emit elements at different speeds, you may not want to wait for the slower stream to emit. Using `Stream.zipLatest` or `Stream.zipLatestWith`, you can zip elements as soon as either stream produces a new value. These functions use the most recent element from the slower stream whenever a new value arrives from the faster stream.

**Example** (Combining Streams with Different Emission Rates)

```ts

const s1 = Stream.make(1, 2, 3).pipe(
  Stream.schedule(Schedule.spaced("1 second"))
)

const s2 = Stream.make("a", "b", "c", "d").pipe(
  Stream.schedule(Schedule.spaced("500 millis"))
)

const stream = Stream.zipLatest(s1, s2)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    [ 1, 'a' ],    // s1 emits 1 and pairs with the latest value from s2
    [ 1, 'b' ],    // s2 emits 'b', pairs with the latest value from s1
    [ 2, 'b' ],    // s1 emits 2, pairs with the latest value from s2
    [ 2, 'c' ],    // s2 emits 'c', pairs with the latest value from s1
    [ 2, 'd' ],    // s2 emits 'd', pairs with the latest value from s1
    [ 3, 'd' ]     // s1 emits 3, pairs with the latest value from s2
  ]
}
*/
```

### Pairing with Previous and Next Elements

| API                      | Description                                               |
| ------------------------ | --------------------------------------------------------- |
| `zipWithPrevious`        | Pairs each element of a stream with its previous element. |
| `zipWithNext`            | Pairs each element of a stream with its next element.     |
| `zipWithPreviousAndNext` | Pairs each element with both its previous and next.       |

**Example** (Pairing Stream Elements with Next)

```ts

const stream = Stream.zipWithNext(Stream.make(1, 2, 3, 4))

Effect.runPromise(Stream.runCollect(stream)).then((chunks) =>
  console.log("%o", chunks)
)
/*
Output:
{
  _id: 'Chunk',
  values: [
    [ 1, { _id: 'Option', _tag: 'Some', value: 2 }, [length]: 2 ],
    [ 2, { _id: 'Option', _tag: 'Some', value: 3 }, [length]: 2 ],
    [ 3, { _id: 'Option', _tag: 'Some', value: 4 }, [length]: 2 ],
    [ 4, { _id: 'Option', _tag: 'None' }, [length]: 2 ],
    [length]: 4
  ]
}
*/
```

### Indexing Stream Elements

The `Stream.zipWithIndex` operator is a helpful tool for indexing each element in a stream, pairing each item with its respective position in the sequence. This is particularly useful when you want to keep track of the order of elements within a stream.

**Example** (Indexing Each Element in a Stream)

```ts

const stream = Stream.zipWithIndex(
  Stream.make("Mary", "James", "Robert", "Patricia")
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    [ 'Mary', 0 ],
    [ 'James', 1 ],
    [ 'Robert', 2 ],
    [ 'Patricia', 3 ]
  ]
}
*/
```

## Cartesian Product of Streams

The Stream module includes a feature for computing the _Cartesian Product_ of two streams, allowing you to create combinations of elements from two different streams. This is helpful when you need to pair each element from one set with every element of another.

In simple terms, imagine you have two collections and want to form all possible pairs by picking one item from each. This pairing process is the Cartesian Product. In streams, this operation generates a new stream that includes every possible pairing of elements from the two input streams.

To create a Cartesian Product of two streams, the `Stream.cross` operator is available, along with similar variants. These operators combine two streams into a new stream of all possible element combinations.

**Example** (Creating a Cartesian Product of Two Streams)

```ts

const s1 = Stream.make(1, 2, 3).pipe(Stream.tap(Console.log))
const s2 = Stream.make("a", "b").pipe(Stream.tap(Console.log))

const cartesianProduct = Stream.cross(s1, s2)

Effect.runPromise(Stream.runCollect(cartesianProduct)).then(console.log)
/*
Output:
1
a
b
2
a
b
3
a
b
{
  _id: 'Chunk',
  values: [
    [ 1, 'a' ],
    [ 1, 'b' ],
    [ 2, 'a' ],
    [ 2, 'b' ],
    [ 3, 'a' ],
    [ 3, 'b' ]
  ]
}
*/
```

> **Caution: Multiple Iterations of Right Stream**
  Note that the right-hand stream (`s2` in this example) will be iterated
  over multiple times, once for each element in the left-hand stream
  (`s1`). If the right-hand stream involves expensive or
  side-effect-producing operations, those will be executed repeatedly.


## Partitioning

Partitioning a stream involves dividing it into two distinct streams based on a specified condition. The Stream module offers two functions for this purpose: `Stream.partition` and `Stream.partitionEither`. Let's look at how these functions work and the best scenarios for their use.

### partition

The `Stream.partition` function takes a predicate (a condition) as input and divides the original stream into two substreams. One substream will contain elements that meet the condition, while the other contains those that do not. Both resulting substreams are wrapped in a `Scope` type.

**Example** (Partitioning a Stream into Odd and Even Numbers)

```ts

//      ┌─── Effect<[Stream<number>, Stream<number>], never, Scope>
//      ▼
const program = Stream.range(1, 9).pipe(
  Stream.partition((n) => n % 2 === 0, { bufferSize: 5 })
)

Effect.runPromise(
  Effect.scoped(
    Effect.gen(function* () {
      const [odds, evens] = yield* program
      console.log(yield* Stream.runCollect(odds))
      console.log(yield* Stream.runCollect(evens))
    })
  )
)
/*
Output:
{ _id: 'Chunk', values: [ 1, 3, 5, 7, 9 ] }
{ _id: 'Chunk', values: [ 2, 4, 6, 8 ] }
*/
```

### partitionEither

In some cases, you might need to partition a stream using a condition that involves an effect. For this, the `Stream.partitionEither` function is ideal. This function uses an effectful predicate to split the stream into two substreams: one for elements that produce `Either.left` values and another for elements that produce `Either.right` values.

**Example** (Partitioning a Stream with an Effectful Predicate)

```ts

//      ┌─── Effect<[Stream<number>, Stream<number>], never, Scope>
//      ▼
const program = Stream.range(1, 9).pipe(
  Stream.partitionEither(
    // Simulate an effectful computation
    (n) => Effect.succeed(n % 2 === 0 ? Either.right(n) : Either.left(n)),
    { bufferSize: 5 }
  )
)

Effect.runPromise(
  Effect.scoped(
    Effect.gen(function* () {
      const [odds, evens] = yield* program
      console.log(yield* Stream.runCollect(odds))
      console.log(yield* Stream.runCollect(evens))
    })
  )
)
/*
Output:
{ _id: 'Chunk', values: [ 1, 3, 5, 7, 9 ] }
{ _id: 'Chunk', values: [ 2, 4, 6, 8 ] }
*/
```

## Grouping

When processing streams of data, you may need to group elements based on specific criteria. The Stream module provides two functions for this purpose: `groupByKey`, `groupBy`, `grouped` and `groupedWithin`. Let's review how these functions work and when to use each one.

### groupByKey

The `Stream.groupByKey` function partitions a stream based on a key function of type `(a: A) => K`, where `A` is the type of elements in the stream, and `K` represents the keys for grouping. This function is non-effectful and groups elements by simply applying the provided key function.

The result of `Stream.groupByKey` is a `GroupBy` data type, representing the grouped stream. To process each group, you can use `GroupBy.evaluate`, which takes a function of type `(key: K, stream: Stream<V, E>) => Stream.Stream<...>`. This function operates across all groups and merges them together in a non-deterministic order.

**Example** (Grouping by Tens Place in Exam Scores)

In the following example, we use `Stream.groupByKey` to group exam scores by the tens place and count the number of scores in each group:

```ts

class Exam {
  constructor(
    readonly person: string,
    readonly score: number
  ) {}
}

// Define a list of exam results
const examResults = [
  new Exam("Alex", 64),
  new Exam("Michael", 97),
  new Exam("Bill", 77),
  new Exam("John", 78),
  new Exam("Bobby", 71)
]

// Group exam results by the tens place in the score
const groupByKeyResult = Stream.fromIterable(examResults).pipe(
  Stream.groupByKey((exam) => Math.floor(exam.score / 10) * 10)
)

// Count the number of exam results in each group
const stream = GroupBy.evaluate(groupByKeyResult, (key, stream) =>
  Stream.fromEffect(
    Stream.runCollect(stream).pipe(
      Effect.andThen((chunk) => [key, Chunk.size(chunk)] as const)
    )
  )
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ [ 60, 1 ], [ 90, 1 ], [ 70, 3 ] ] }
*/
```

### groupBy

For more complex grouping requirements where partitioning involves effects, you can use the `Stream.groupBy` function. This function accepts an effectful partitioning function and returns a `GroupBy` data type, representing the grouped stream. You can then process each group by using `GroupBy.evaluate`, similar to `Stream.groupByKey`.

**Example** (Grouping Names by First Letter)

In the following example, we group names by their first letter and count the number of names in each group. Here, the partitioning operation is set up as an effectful operation:

```ts

// Group names by their first letter
const groupByKeyResult = Stream.fromIterable([
  "Mary",
  "James",
  "Robert",
  "Patricia",
  "John",
  "Jennifer",
  "Rebecca",
  "Peter"
]).pipe(
  // Simulate an effectful groupBy operation
  Stream.groupBy((name) => Effect.succeed([name.substring(0, 1), name]))
)

// Count the number of names in each group and display results
const stream = GroupBy.evaluate(groupByKeyResult, (key, stream) =>
  Stream.fromEffect(
    Stream.runCollect(stream).pipe(
      Effect.andThen((chunk) => [key, Chunk.size(chunk)] as const)
    )
  )
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [ [ 'M', 1 ], [ 'J', 3 ], [ 'R', 2 ], [ 'P', 2 ] ]
}
*/
```

### grouped

The `Stream.grouped` function is ideal for dividing a stream into chunks of a specified size, making it easier to handle data in smaller, organized segments. This is particularly helpful when processing or displaying data in batches.

**Example** (Dividing a Stream into Chunks of 3 Elements)

```ts

// Create a stream of numbers and group them into chunks of 3
const stream = Stream.range(0, 8).pipe(Stream.grouped(3))

Effect.runPromise(Stream.runCollect(stream)).then((chunks) =>
  console.log("%o", chunks)
)
/*
Output:
{
  _id: 'Chunk',
  values: [
    { _id: 'Chunk', values: [ 0, 1, 2, [length]: 3 ] },
    { _id: 'Chunk', values: [ 3, 4, 5, [length]: 3 ] },
    { _id: 'Chunk', values: [ 6, 7, 8, [length]: 3 ] },
    [length]: 3
  ]
}
*/
```

### groupedWithin

The `Stream.groupedWithin` function allows for flexible grouping by creating chunks based on either a specified maximum size or a time interval, whichever condition is met first. This is especially useful for working with data where timing constraints are involved.

**Example** (Grouping by Size or Time Interval)

In this example, `Stream.groupedWithin(18, "1.5 seconds")` groups the stream into chunks whenever either 18 elements accumulate or 1.5 seconds elapse since the last chunk was created.

```ts

// Create a stream that repeats every second and group by size or time
const stream = Stream.range(0, 9).pipe(
  Stream.repeat(Schedule.spaced("1 second")),
  Stream.groupedWithin(18, "1.5 seconds"),
  Stream.take(3)
)

Effect.runPromise(Stream.runCollect(stream)).then((chunks) =>
  console.log(Chunk.toArray(chunks))
)
/*
Output:
[
  {
    _id: 'Chunk',
    values: [
      0, 1, 2, 3, 4, 5, 6,
      7, 8, 9, 0, 1, 2, 3,
      4, 5, 6, 7
    ]
  },
  {
    _id: 'Chunk',
    values: [
      8, 9, 0, 1, 2,
      3, 4, 5, 6, 7,
      8, 9
    ]
  },
  {
    _id: 'Chunk',
    values: [
      0, 1, 2, 3, 4, 5, 6,
      7, 8, 9, 0, 1, 2, 3,
      4, 5, 6, 7
    ]
  }
]
*/
```

## Concatenation

In stream processing, you may need to combine the contents of multiple streams. The Stream module offers several operators to achieve this, including `Stream.concat`, `Stream.concatAll`, and `Stream.flatMap`. Let's look at how each of these operators works.

### Simple Concatenation

The `Stream.concat` operator is a straightforward method for joining two streams. It returns a new stream that emits elements from the first stream (left-hand) followed by elements from the second stream (right-hand). This is helpful when you want to combine two streams in a specific sequence.

**Example** (Concatenating Two Streams Sequentially)

```ts

const stream = Stream.concat(Stream.make(1, 2, 3), Stream.make("a", "b"))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2, 3, 'a', 'b' ] }
*/
```

### Concatenating Multiple Streams

If you have multiple streams to concatenate, `Stream.concatAll` provides an efficient way to combine them without manually chaining multiple `Stream.concat` operations. This function takes a [Chunk](/docs/data-types/chunk/) of streams and returns a single stream containing the elements of each stream in sequence.

**Example** (Concatenating Multiple Streams)

```ts

const s1 = Stream.make(1, 2, 3)
const s2 = Stream.make("a", "b")
const s3 = Stream.make(true, false, false)

const stream = Stream.concatAll<number | string | boolean, never, never>(
  Chunk.make(s1, s2, s3)
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    1,     2,     3,
    'a',   'b',   true,
    false, false
  ]
}
*/
```

### Advanced Concatenation with flatMap

The `Stream.flatMap` operator allows for advanced concatenation by creating a stream where each element is generated
by applying a function of type `(a: A) => Stream<...>` to each output of the source stream.
This operator then concatenates all the resulting streams, effectively flattening them.

**Example** (Generating Repeated Elements with `Stream.flatMap`)

```ts

// Create a stream where each element is repeated 4 times
const stream = Stream.make(1, 2, 3).pipe(
  Stream.flatMap((a) => Stream.repeatValue(a).pipe(Stream.take(4)))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    1, 1, 1, 1, 2,
    2, 2, 2, 3, 3,
    3, 3
  ]
}
*/
```

If you need to perform the `flatMap` operation concurrently, you can use the [concurrency](/docs/concurrency/basic-concurrency/#concurrency-options) option to control how many inner streams run simultaneously.

Additionally, you can use the `switch` option to implement a "switch" behavior where previous streams are automatically
cancelled when new elements arrive from the source stream. This is particularly useful when you only need the most recent
result and want to conserve resources by cancelling outdated operations.

**Example** (Using the `switch` option)

```ts

// Helper function to create a stream with logging
const createStreamWithLogging = (n: number) =>
  Stream.fromEffect(
    Effect.gen(function* () {
      console.log(`Starting stream for value: ${n}`)
      const result = yield* Effect.delay(Effect.succeed(n), "500 millis")
      console.log(`Completed stream for value: ${result}`)
      return result
    }).pipe(
      Effect.onInterrupt(() =>
        Console.log(`Interrupted stream for value: ${n}`)
      )
    )
  )

// Without switch (default behavior):
// all streams run to completion
const stream1 = Stream.fromIterable([1, 2, 3]).pipe(
  Stream.flatMap(createStreamWithLogging)
)

// With switch behavior:
// only the last stream completes, previous streams
// are cancelled when new values arrive
const stream2 = Stream.fromIterable([1, 2, 3]).pipe(
  Stream.flatMap(createStreamWithLogging, { switch: true })
)

// Run examples sequentially to see the difference
Effect.runPromise(
  Effect.gen(function* () {
    console.log("=== Without switch (all streams complete) ===")
    const result1 = yield* Stream.runCollect(stream1)
    console.log(result1)

    console.log("\n=== With switch (only last stream completes) ===")
    const result2 = yield* Stream.runCollect(stream2)
    console.log(result2)
  })
)
/*
Output:
=== Without switch (all streams complete) ===
Starting stream for value: 1
Completed stream for value: 1
Starting stream for value: 2
Completed stream for value: 2
Starting stream for value: 3
Completed stream for value: 3
{ _id: 'Chunk', values: [ 1, 2, 3 ] }

=== With switch (only last stream completes) ===
Starting stream for value: 1
Interrupted stream for value: 1
Starting stream for value: 2
Interrupted stream for value: 2
Starting stream for value: 3
Completed stream for value: 3
{ _id: 'Chunk', values: [ 3 ] }
*/
```

The `switch` option is especially valuable for scenarios like search functionality, real-time data processing,
or any situation where you want to discard previous operations when new input arrives.

## Merging

Sometimes, you may want to interleave elements from two streams and create a single output stream. In such cases, `Stream.concat` isn't suitable because it waits for the first stream to complete before consuming the second. For interleaving elements as they become available, `Stream.merge` and its variants are designed for this purpose.

### merge

The `Stream.merge` operation combines elements from two source streams into a single stream, interleaving elements as they are produced. Unlike `Stream.concat`, `Stream.merge` does not wait for one stream to finish before starting the other.

**Example** (Interleaving Two Streams with `Stream.merge`)

```ts

// Create two streams with different emission intervals
const s1 = Stream.make(1, 2, 3).pipe(
  Stream.schedule(Schedule.spaced("100 millis"))
)
const s2 = Stream.make(4, 5, 6).pipe(
  Stream.schedule(Schedule.spaced("200 millis"))
)

// Merge s1 and s2 into a single stream that interleaves their values
const merged = Stream.merge(s1, s2)

Effect.runPromise(Stream.runCollect(merged)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 4, 2, 3, 5, 6 ] }
*/
```

### Termination Strategy

When merging two streams, it's important to consider the termination strategy, especially if each stream has a different lifetime.
By default, `Stream.merge` waits for both streams to terminate before ending the merged stream. However, you can modify this behavior with `haltStrategy`, selecting from four termination strategies:

| Termination Strategy | Description                                                          |
| -------------------- | -------------------------------------------------------------------- |
| `"left"`             | The merged stream terminates when the left-hand stream terminates.   |
| `"right"`            | The merged stream terminates when the right-hand stream terminates.  |
| `"both"` (default)   | The merged stream terminates only when both streams have terminated. |
| `"either"`           | The merged stream terminates as soon as either stream terminates.    |

**Example** (Using `haltStrategy: "left"` to Control Stream Termination)

```ts

const s1 = Stream.range(1, 5).pipe(
  Stream.schedule(Schedule.spaced("100 millis"))
)
const s2 = Stream.repeatValue(0).pipe(
  Stream.schedule(Schedule.spaced("200 millis"))
)

const merged = Stream.merge(s1, s2, { haltStrategy: "left" })

Effect.runPromise(Stream.runCollect(merged)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    1, 0, 2, 3,
    0, 4, 5
  ]
}
*/
```

### mergeWith

In some cases, you may want to merge two streams while transforming their elements into a unified type. `Stream.mergeWith` is designed for this purpose, allowing you to specify transformation functions for each source stream.

**Example** (Merging and Transforming Two Streams)

```ts

const s1 = Stream.make("1", "2", "3").pipe(
  Stream.schedule(Schedule.spaced("100 millis"))
)
const s2 = Stream.make(4.1, 5.3, 6.2).pipe(
  Stream.schedule(Schedule.spaced("200 millis"))
)

const merged = Stream.mergeWith(s1, s2, {
  // Convert string elements from `s1` to integers
  onSelf: (s) => parseInt(s),
  // Round down decimal elements from `s2`
  onOther: (n) => Math.floor(n)
})

Effect.runPromise(Stream.runCollect(merged)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 4, 2, 3, 5, 6 ] }
*/
```

## Interleaving

### interleave

The `Stream.interleave` operator lets you pull one element at a time from each of two streams, creating a new interleaved stream. If one stream finishes first, the remaining elements from the other stream continue to be pulled until both streams are exhausted.

**Example** (Basic Interleaving of Two Streams)

```ts

const s1 = Stream.make(1, 2, 3)
const s2 = Stream.make(4, 5, 6)

const stream = Stream.interleave(s1, s2)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 4, 2, 5, 3, 6 ] }
*/
```

### interleaveWith

For more complex interleaving, `Stream.interleaveWith` provides additional control by using a third stream of `boolean` values to dictate the interleaving pattern. When this stream emits `true`, an element is taken from the left-hand stream; otherwise, an element is taken from the right-hand stream.

**Example** (Custom Interleaving Logic Using `Stream.interleaveWith`)

```ts

const s1 = Stream.make(1, 3, 5, 7, 9)
const s2 = Stream.make(2, 4, 6, 8, 10)

// Define a boolean stream to control interleaving
const booleanStream = Stream.make(true, false, false).pipe(Stream.forever)

const stream = Stream.interleaveWith(s1, s2, booleanStream)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    1, 2,  4, 3, 6,
    8, 5, 10, 7, 9
  ]
}
*/
```

## Interspersing

Interspersing adds separators or affixes in a stream, useful for formatting or structuring data in streams.

### intersperse

The `Stream.intersperse` operator inserts a specified delimiter element between each pair of elements in a stream. This delimiter can be any chosen value and is added between each consecutive pair.

**Example** (Inserting Delimiters Between Stream Elements)

```ts

// Create a stream of numbers and intersperse `0` between them
const stream = Stream.make(1, 2, 3, 4, 5).pipe(Stream.intersperse(0))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    1, 0, 2, 0, 3,
    0, 4, 0, 5
  ]
}
*/
```

### intersperseAffixes

For more complex needs, `Stream.intersperseAffixes` provides control over different affixes at the start, between elements, and at the end of the stream.

**Example** (Adding Affixes to a Stream)

```ts

// Create a stream and add affixes:
// - `[` at the start
// - `|` between elements
// - `]` at the end
const stream = Stream.make(1, 2, 3, 4, 5).pipe(
  Stream.intersperseAffixes({
    start: "[",
    middle: "|",
    end: "]"
  })
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Chunk',
  values: [
    '[', 1,   '|', 2,   '|',
    3,   '|', 4,   '|', 5,
    ']'
  ]
}
*/
```

## Broadcasting

Broadcasting a stream creates multiple downstream streams that each receive the same elements from the source stream. This is useful when you want to send each element to multiple consumers simultaneously. The upstream stream has a `maximumLag` parameter that sets the limit for how much it can get ahead before slowing down to match the speed of the slowest downstream stream.

**Example** (Broadcasting to Multiple Downstream Streams)

In the following example, we broadcast a stream of numbers to two downstream consumers. The first calculates the maximum value in the stream, while the second logs each number with a delay. The upstream stream's speed adjusts based on the slower logging stream:

```ts

const numbers = Effect.scoped(
  Stream.range(1, 20).pipe(
    Stream.tap((n) =>
      Console.log(`Emit ${n} element before broadcasting`)
    ),
    // Broadcast to 2 downstream consumers with max lag of 5
    Stream.broadcast(2, 5),
    Stream.flatMap(([first, second]) =>
      Effect.gen(function* () {
        // First downstream stream: calculates maximum
        const fiber1 = yield* Stream.runFold(first, 0, (acc, e) =>
          Math.max(acc, e)
        ).pipe(
          Effect.andThen((max) => Console.log(`Maximum: ${max}`)),
          Effect.fork
        )

        // Second downstream stream: logs each element with a delay
        const fiber2 = yield* second.pipe(
          Stream.schedule(Schedule.spaced("1 second")),
          Stream.runForEach((n) =>
            Console.log(`Logging to the Console: ${n}`)
          ),
          Effect.fork
        )

        // Wait for both fibers to complete
        yield* Fiber.join(fiber1).pipe(
          Effect.zip(Fiber.join(fiber2), { concurrent: true })
        )
      })
    ),
    Stream.runCollect
  )
)

Effect.runPromise(numbers).then(console.log)
/*
Output:
Emit 1 element before broadcasting
Emit 2 element before broadcasting
Emit 3 element before broadcasting
Emit 4 element before broadcasting
Emit 5 element before broadcasting
Emit 6 element before broadcasting
Emit 7 element before broadcasting
Emit 8 element before broadcasting
Emit 9 element before broadcasting
Emit 10 element before broadcasting
Emit 11 element before broadcasting
Logging to the Console: 1
Logging to the Console: 2
Logging to the Console: 3
Logging to the Console: 4
Logging to the Console: 5
Emit 12 element before broadcasting
Emit 13 element before broadcasting
Emit 14 element before broadcasting
Emit 15 element before broadcasting
Emit 16 element before broadcasting
Logging to the Console: 6
Logging to the Console: 7
Logging to the Console: 8
Logging to the Console: 9
Logging to the Console: 10
Emit 17 element before broadcasting
Emit 18 element before broadcasting
Emit 19 element before broadcasting
Emit 20 element before broadcasting
Logging to the Console: 11
Logging to the Console: 12
Logging to the Console: 13
Logging to the Console: 14
Logging to the Console: 15
Maximum: 20
Logging to the Console: 16
Logging to the Console: 17
Logging to the Console: 18
Logging to the Console: 19
Logging to the Console: 20
{ _id: 'Chunk', values: [ undefined ] }
*/
```

## Buffering

Effect streams use a pull-based model, allowing downstream consumers to control the rate at which they request elements. However, when there's a mismatch in the speed between the producer and the consumer, buffering can help balance their interaction. The `Stream.buffer` operator is designed to manage this, allowing the producer to keep working even if the consumer is slower. You can set a maximum buffer capacity using the `capacity` option.

### buffer

The `Stream.buffer` operator queues elements to allow the producer to work independently from the consumer, up to a specified capacity. This helps when a faster producer and a slower consumer need to operate smoothly without blocking each other.

**Example** (Using a Buffer to Handle Speed Mismatch)

```ts

const stream = Stream.range(1, 10).pipe(
  // Log each element before buffering
  Stream.tap((n) => Console.log(`before buffering: ${n}`)),
  // Buffer with a capacity of 4 elements
  Stream.buffer({ capacity: 4 }),
  // Log each element after buffering
  Stream.tap((n) => Console.log(`after buffering: ${n}`)),
  // Add a 5-second delay between each emission
  Stream.schedule(Schedule.spaced("5 seconds"))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
before buffering: 1
before buffering: 2
before buffering: 3
before buffering: 4
before buffering: 5
before buffering: 6
after buffering: 1
after buffering: 2
before buffering: 7
after buffering: 3
before buffering: 8
after buffering: 4
before buffering: 9
after buffering: 5
before buffering: 10
...
*/
```

Different buffering options let you tailor the buffering strategy based on your use case:

| **Buffering Type**  | **Configuration**                            | **Description**                                               |
| ------------------- | -------------------------------------------- | ------------------------------------------------------------- |
| **Bounded Queue**   | `{ capacity: number }`                       | Limits the queue to a fixed size.                             |
| **Unbounded Queue** | `{ capacity: "unbounded" }`                  | Allows an unlimited number of buffered items.                 |
| **Sliding Queue**   | `{ capacity: number, strategy: "sliding" }`  | Keeps the most recent items, discarding older ones when full. |
| **Dropping Queue**  | `{ capacity: number, strategy: "dropping" }` | Keeps the earliest items, discarding new ones when full.      |

## Debouncing

Debouncing is a technique used to prevent a function from firing too frequently, which is particularly useful when a stream emits values rapidly but only the last value after a pause is needed.

The `Stream.debounce` function achieves this by delaying the emission of values until a specified time period has passed without any new values. If a new value arrives during the waiting period, the timer resets, and only the latest value will eventually be emitted after a pause.

**Example** (Debouncing a Stream of Rapidly Emitted Values)

```ts

// Helper function to log with elapsed time since the last log
let last = Date.now()
const log = (message: string) =>
  Effect.sync(() => {
    const end = Date.now()
    console.log(`${message} after ${end - last}ms`)
    last = end
  })

const stream = Stream.make(1, 2, 3).pipe(
  // Emit the value 4 after 200 ms
  Stream.concat(
    Stream.fromEffect(Effect.sleep("200 millis").pipe(Effect.as(4)))
  ),
  // Continue with more rapid values
  Stream.concat(Stream.make(5, 6)),
  // Emit 7 after 150 ms
  Stream.concat(
    Stream.fromEffect(Effect.sleep("150 millis").pipe(Effect.as(7)))
  ),
  Stream.concat(Stream.make(8)),
  Stream.tap((n) => log(`Received ${n}`)),
  // Only emit values after a pause of at least 100 milliseconds
  Stream.debounce("100 millis"),
  Stream.tap((n) => log(`> Emitted ${n}`))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Example Output:
Received 1 after 5ms
Received 2 after 2ms
Received 3 after 0ms
> Emitted 3 after 104ms
Received 4 after 99ms
Received 5 after 1ms
Received 6 after 0ms
> Emitted 6 after 101ms
Received 7 after 50ms
Received 8 after 1ms
> Emitted 8 after 101ms
{ _id: 'Chunk', values: [ 3, 6, 8 ] }
*/
```

## Throttling

Throttling is a technique for regulating the rate at which elements are emitted from a stream. It helps maintain a steady data output pace, which is valuable in situations where data processing needs to occur at a consistent rate.

The `Stream.throttle` function uses the [token bucket algorithm](https://en.wikipedia.org/wiki/Token_bucket) to control the rate of stream emissions.

**Example** (Throttle Configuration)

```ts
Stream.throttle({
  cost: () => 1,
  duration: "100 millis",
  units: 1
})
```

In this configuration:

- Each chunk processed uses one token (`cost = () => 1`).
- Tokens are replenished at a rate of one token (`units: 1`) every 100 milliseconds (`duration: "100 millis"`).

> **Caution: Throttling Applies to Chunks, Not Elements**
  Note that throttling operates on chunks rather than individual elements.
  The `cost` function sets the token cost for each chunk.


### Shape Strategy (Default)

The "shape" strategy moderates data flow by delaying chunk emissions until they comply with specified bandwidth constraints.
This strategy ensures that data throughput does not exceed defined limits, allowing for steady and controlled data emission.

**Example** (Applying Throttling with the Shape Strategy)

```ts

// Helper function to log with elapsed time since last log
let last = Date.now()
const log = (message: string) =>
  Effect.sync(() => {
    const end = Date.now()
    console.log(`${message} after ${end - last}ms`)
    last = end
  })

const stream = Stream.fromSchedule(Schedule.spaced("50 millis")).pipe(
  Stream.take(6),
  Stream.tap((n) => log(`Received ${n}`)),
  Stream.throttle({
    cost: Chunk.size,
    duration: "100 millis",
    units: 1
  }),
  Stream.tap((n) => log(`> Emitted ${n}`))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Example Output:
Received 0 after 56ms
> Emitted 0 after 0ms
Received 1 after 52ms
> Emitted 1 after 48ms
Received 2 after 52ms
> Emitted 2 after 49ms
Received 3 after 52ms
> Emitted 3 after 48ms
Received 4 after 52ms
> Emitted 4 after 47ms
Received 5 after 52ms
> Emitted 5 after 49ms
{ _id: 'Chunk', values: [ 0, 1, 2, 3, 4, 5 ] }
*/
```

### Enforce Strategy

The "enforce" strategy strictly regulates data flow by discarding chunks that exceed bandwidth constraints.

**Example** (Throttling with the Enforce Strategy)

```ts

// Helper function to log with elapsed time since last log
let last = Date.now()
const log = (message: string) =>
  Effect.sync(() => {
    const end = Date.now()
    console.log(`${message} after ${end - last}ms`)
    last = end
  })

const stream = Stream.make(1, 2, 3, 4, 5, 6).pipe(
  Stream.schedule(Schedule.exponential("100 millis")),
  Stream.tap((n) => log(`Received ${n}`)),
  Stream.throttle({
    cost: Chunk.size,
    duration: "1 second",
    units: 1,
    strategy: "enforce"
  }),
  Stream.tap((n) => log(`> Emitted ${n}`))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Example Output:
Received 1 after 106ms
> Emitted 1 after 1ms
Received 2 after 200ms
Received 3 after 402ms
Received 4 after 801ms
> Emitted 4 after 1ms
Received 5 after 1601ms
> Emitted 5 after 1ms
Received 6 after 3201ms
> Emitted 6 after 0ms
{ _id: 'Chunk', values: [ 1, 4, 5, 6 ] }
*/
```

### burst option

The `Stream.throttle` function offers a burst option that allows for temporary increases in data throughput beyond the set rate limits.
This option is set to greater than 0 to activate burst capability (default is 0, indicating no burst support).
The burst capacity provides additional tokens in the token bucket, enabling the stream to momentarily exceed its configured rate when bursts of data occur.

**Example** (Throttling with Burst Capacity)

```ts

// Helper function to log with elapsed time since last log
let last = Date.now()
const log = (message: string) =>
  Effect.sync(() => {
    const end = Date.now()
    console.log(`${message} after ${end - last}ms`)
    last = end
  })

const stream = Stream.fromSchedule(Schedule.spaced("10 millis")).pipe(
  Stream.take(20),
  Stream.tap((n) => log(`Received ${n}`)),
  Stream.throttle({
    cost: Chunk.size,
    duration: "200 millis",
    units: 5,
    strategy: "enforce",
    burst: 2
  }),
  Stream.tap((n) => log(`> Emitted ${n}`))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Example Output:
Received 0 after 16ms
> Emitted 0 after 0ms
Received 1 after 12ms
> Emitted 1 after 0ms
Received 2 after 11ms
> Emitted 2 after 0ms
Received 3 after 11ms
> Emitted 3 after 0ms
Received 4 after 11ms
> Emitted 4 after 1ms
Received 5 after 11ms
> Emitted 5 after 0ms
Received 6 after 12ms
> Emitted 6 after 0ms
Received 7 after 11ms
Received 8 after 12ms
Received 9 after 11ms
Received 10 after 11ms
> Emitted 10 after 0ms
Received 11 after 11ms
Received 12 after 11ms
Received 13 after 12ms
> Emitted 13 after 0ms
Received 14 after 11ms
Received 15 after 12ms
Received 16 after 11ms
Received 17 after 11ms
> Emitted 17 after 0ms
Received 18 after 12ms
Received 19 after 10ms
{
  _id: 'Chunk',
  values: [
    0, 1,  2,  3,  4,
    5, 6, 10, 13, 17
  ]
}
*/
```

In this setup, the stream starts with a bucket containing 5 tokens, allowing the first five chunks to be emitted instantly.
The additional burst capacity of 2 accommodates further emissions momentarily, allowing for handling of subsequent data more flexibly.
Over time, as the bucket refills according to the throttle configuration, additional elements are emitted, demonstrating how the burst capability can manage uneven data flows effectively.

## Scheduling

When working with streams, you may need to introduce specific time intervals between each element's emission. The `Stream.schedule` combinator allows you to set these intervals.

**Example** (Adding a Delay Between Stream Emissions)

```ts

// Create a stream that emits values with a 1-second delay between each
const stream = Stream.make(1, 2, 3, 4, 5).pipe(
  Stream.schedule(Schedule.spaced("1 second")),
  Stream.tap(Console.log)
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
1
2
3
4
5
{
  _id: "Chunk",
  values: [ 1, 2, 3, 4, 5 ]
}
*/
```

In this example, we've used the `Schedule.spaced("1 second")` schedule to introduce a one-second gap between each emission in the stream.


---

# [Error Handling in Streams](https://effect.website/docs/stream/error-handling/)

## Overview

## Recovering from Failure

When working with streams that may encounter errors, it's crucial to know how to handle these errors gracefully. The `Stream.orElse` function is a powerful tool for recovering from failures and switching to an alternative stream in case of an error.

**Example**

```ts

const s1 = Stream.make(1, 2, 3).pipe(
  Stream.concat(Stream.fail("Oh! Error!")),
  Stream.concat(Stream.make(4, 5))
)

const s2 = Stream.make("a", "b", "c")

const stream = Stream.orElse(s1, () => s2)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [ 1, 2, 3, "a", "b", "c" ]
}
*/
```

In this example, `s1` encounters an error, but instead of terminating the stream, we gracefully switch to `s2` using `Stream.orElse`. This ensures that we can continue processing data even if one stream fails.

There's also a variant called `Stream.orElseEither` that uses the [Either](/docs/data-types/either/) data type to distinguish elements from the two streams based on success or failure:

```ts

const s1 = Stream.make(1, 2, 3).pipe(
  Stream.concat(Stream.fail("Oh! Error!")),
  Stream.concat(Stream.make(4, 5))
)

const s2 = Stream.make("a", "b", "c")

const stream = Stream.orElseEither(s1, () => s2)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [
    {
      _id: "Either",
      _tag: "Left",
      left: 1
    }, {
      _id: "Either",
      _tag: "Left",
      left: 2
    }, {
      _id: "Either",
      _tag: "Left",
      left: 3
    }, {
      _id: "Either",
      _tag: "Right",
      right: "a"
    }, {
      _id: "Either",
      _tag: "Right",
      right: "b"
    }, {
      _id: "Either",
      _tag: "Right",
      right: "c"
    }
  ]
}
*/
```

The `Stream.catchAll` function provides advanced error handling capabilities compared to `Stream.orElse`. With `Stream.catchAll`, you can make decisions based on both the type and value of the encountered failure.

```ts

const s1 = Stream.make(1, 2, 3).pipe(
  Stream.concat(Stream.fail("Uh Oh!" as const)),
  Stream.concat(Stream.make(4, 5)),
  Stream.concat(Stream.fail("Ouch" as const))
)

const s2 = Stream.make("a", "b", "c")

const s3 = Stream.make(true, false, false)

const stream = Stream.catchAll(
  s1,
  (error): Stream.Stream<string | boolean> => {
    switch (error) {
      case "Uh Oh!":
        return s2
      case "Ouch":
        return s3
    }
  }
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [ 1, 2, 3, "a", "b", "c" ]
}
*/
```

In this example, we have a stream, `s1`, which may encounter two different types of errors. Instead of a straightforward switch to an alternative stream, as done with `Stream.orElse`, we employ `Stream.catchAll` to precisely determine how to handle each type of error. This level of control over error recovery enables you to choose different streams or actions based on the specific error conditions.

## Recovering from Defects

When working with streams, it's essential to be prepared for various failure scenarios, including defects that might occur during stream processing. To address this, the `Stream.catchAllCause` function provides a robust solution. It enables you to gracefully handle and recover from any type of failure that may arise.

**Example**

```ts

const s1 = Stream.make(1, 2, 3).pipe(
  Stream.concat(Stream.dieMessage("Boom!")),
  Stream.concat(Stream.make(4, 5))
)

const s2 = Stream.make("a", "b", "c")

const stream = Stream.catchAllCause(s1, () => s2)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [ 1, 2, 3, "a", "b", "c" ]
}
*/
```

In this example, `s1` may encounter a defect, but instead of crashing the application, we use `Stream.catchAllCause` to gracefully switch to an alternative stream, `s2`. This ensures that your application remains robust and continues processing data even in the face of unexpected issues.

## Recovery from Some Errors

In stream processing, there may be situations where you need to recover from specific types of failures. The `Stream.catchSome` and `Stream.catchSomeCause` functions come to the rescue, allowing you to handle and mitigate errors selectively.

If you want to recover from a particular error, you can use `Stream.catchSome`:

```ts

const s1 = Stream.make(1, 2, 3).pipe(
  Stream.concat(Stream.fail("Oh! Error!")),
  Stream.concat(Stream.make(4, 5))
)

const s2 = Stream.make("a", "b", "c")

const stream = Stream.catchSome(s1, (error) => {
  if (error === "Oh! Error!") {
    return Option.some(s2)
  }
  return Option.none()
})

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [ 1, 2, 3, "a", "b", "c" ]
}
*/
```

To recover from a specific cause, you can use the `Stream.catchSomeCause` function:

```ts

const s1 = Stream.make(1, 2, 3).pipe(
  Stream.concat(Stream.dieMessage("Oh! Error!")),
  Stream.concat(Stream.make(4, 5))
)

const s2 = Stream.make("a", "b", "c")

const stream = Stream.catchSomeCause(s1, (cause) => {
  if (Cause.isDie(cause)) {
    return Option.some(s2)
  }
  return Option.none()
})

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [ 1, 2, 3, "a", "b", "c" ]
}
*/
```

## Recovering to Effect

In stream processing, it's crucial to handle errors gracefully and perform cleanup tasks when needed. The `Stream.onError` function allows us to do just that. If our stream encounters an error, we can specify a cleanup task to be executed.

```ts

const stream = Stream.make(1, 2, 3).pipe(
  Stream.concat(Stream.dieMessage("Oh! Boom!")),
  Stream.concat(Stream.make(4, 5)),
  Stream.onError(() =>
    Console.log(
      "Stream application closed! We are doing some cleanup jobs."
    ).pipe(Effect.orDie)
  )
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
Stream application closed! We are doing some cleanup jobs.
error: RuntimeException: Oh! Boom!
*/
```

## Retry a Failing Stream

Sometimes, streams may encounter failures that are temporary or recoverable. In such cases, the `Stream.retry` operator comes in handy. It allows you to specify a retry schedule, and the stream will be retried according to that schedule.

**Example**

```ts
import * as NodeReadLine from "node:readline"

const stream = Stream.make(1, 2, 3).pipe(
  Stream.concat(
    Stream.fromEffect(
      Effect.gen(function* () {
        const s = yield* readLine("Enter a number: ")
        const n = parseInt(s)
        if (Number.isNaN(n)) {
          return yield* Effect.fail("NaN")
        }
        return n
      })
    ).pipe(Stream.retry(Schedule.exponential("1 second")))
  )
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
Enter a number: a
Enter a number: b
Enter a number: c
Enter a number: 4
{
  _id: "Chunk",
  values: [ 1, 2, 3, 4 ]
}
*/

const readLine = (message: string): Effect.Effect<string> =>
  Effect.promise(
    () =>
      new Promise((resolve) => {
        const rl = NodeReadLine.createInterface({
          input: process.stdin,
          output: process.stdout
        })
        rl.question(message, (answer) => {
          rl.close()
          resolve(answer)
        })
      })
  )
```

In this example, the stream asks the user to input a number, but if an invalid value is entered (e.g., "a," "b," "c"), it fails with "NaN." However, we use `Stream.retry` with an exponential backoff schedule, which means it will retry after a delay of increasing duration. This allows us to handle temporary errors and eventually collect valid input.

## Refining Errors

When working with streams, there might be situations where you want to selectively keep certain errors and terminate the stream with the remaining errors. You can achieve this using the `Stream.refineOrDie` function.

**Example**

```ts

const stream = Stream.fail(new Error())

const res = Stream.refineOrDie(stream, (error) => {
  if (error instanceof SyntaxError) {
    return Option.some(error)
  }
  return Option.none()
})
```

In this example, `stream` initially fails with a generic `Error`. However, we use `Stream.refineOrDie` to filter and keep only errors of type `SyntaxError`. Any other errors will be terminated, while `SyntaxErrors` will be retained in `refinedStream`.

## Timing Out

When working with streams, there are scenarios where you may want to handle timeouts, such as terminating a stream if it doesn't produce a value within a certain duration. In this section, we'll explore how to manage timeouts using various operators.

### timeout

The `Stream.timeout` operator allows you to set a timeout on a stream. If the stream does not produce a value within the specified duration, it terminates.

```ts

const stream = Stream.fromEffect(Effect.never).pipe(
  Stream.timeout("2 seconds")
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
{
  _id: "Chunk",
  values: []
}
*/
```

### timeoutFail

The `Stream.timeoutFail` operator combines a timeout with a custom failure message. If the stream times out, it fails with the specified error message.

```ts

const stream = Stream.fromEffect(Effect.never).pipe(
  Stream.timeoutFail(() => "timeout", "2 seconds")
)

Effect.runPromiseExit(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'timeout' }
}
*/
```

### timeoutFailCause

Similar to `Stream.timeoutFail`, `Stream.timeoutFailCause` combines a timeout with a custom failure cause. If the stream times out, it fails with the specified cause.

```ts

const stream = Stream.fromEffect(Effect.never).pipe(
  Stream.timeoutFailCause(() => Cause.die("timeout"), "2 seconds")
)

Effect.runPromiseExit(Stream.runCollect(stream)).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Die', defect: 'timeout' }
}
*/
```

### timeoutTo

The `Stream.timeoutTo` operator allows you to switch to another stream if the first stream does not produce a value within the specified duration.

```ts

const stream = Stream.fromEffect(Effect.never).pipe(
  Stream.timeoutTo("2 seconds", Stream.make(1, 2, 3))
)

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
{
  _id: "Chunk",
  values: [ 1, 2, 3 ]
}
*/
```


---

# [Resourceful Streams](https://effect.website/docs/stream/resourceful-streams/)

## Overview

In the Stream module, you'll find that most of the constructors offer a special variant designed for lifting a scoped resource into a `Stream`. When you use these specific constructors, you're essentially creating streams that are inherently safe with regards to resource management. These constructors, before creating the stream, handle the resource acquisition, and after the stream's usage, they ensure its proper closure.

Stream also provides us with `Stream.acquireRelease` and `Stream.finalizer` constructors that share similarities with `Effect.acquireRelease` and `Effect.addFinalizer`. These tools empower us to perform cleanup or finalization tasks before the stream concludes its operation.

## Acquire Release

In this section, we'll explore an example that demonstrates the use of `Stream.acquireRelease` when working with file operations.

```ts

// Simulating File operations
const open = (filename: string) =>
  Effect.gen(function* () {
    yield* Console.log(`Opening ${filename}`)
    return {
      getLines: Effect.succeed(["Line 1", "Line 2", "Line 3"]),
      close: Console.log(`Closing ${filename}`)
    }
  })

const stream = Stream.acquireRelease(
  open("file.txt"),
  (file) => file.close
).pipe(Stream.flatMap((file) => file.getLines))

Effect.runPromise(Stream.runCollect(stream)).then(console.log)
/*
Output:
Opening file.txt
Closing file.txt
{
  _id: "Chunk",
  values: [
    [ "Line 1", "Line 2", "Line 3" ]
  ]
}
*/
```

In this code snippet, we're simulating file operations using the `open` function. The `Stream.acquireRelease` function is employed to ensure that the file is correctly opened and closed, and we then process the lines of the file using the acquired resource.

## Finalization

In this section, we'll explore the concept of finalization in streams. Finalization allows us to execute a specific action before a stream ends. This can be particularly useful when we want to perform cleanup tasks or add final touches to a stream.

Imagine a scenario where our streaming application needs to clean up a temporary directory when it completes its execution. We can achieve this using the `Stream.finalizer` function:

```ts

const application = Stream.fromEffect(Console.log("Application Logic."))

const deleteDir = (dir: string) => Console.log(`Deleting dir: ${dir}`)

const program = application.pipe(
  Stream.concat(
    Stream.finalizer(
      deleteDir("tmp").pipe(
        Effect.andThen(Console.log("Temporary directory was deleted."))
      )
    )
  )
)

Effect.runPromise(Stream.runCollect(program)).then(console.log)
/*
Output:
Application Logic.
Deleting dir: tmp
Temporary directory was deleted.
{
  _id: "Chunk",
  values: [ undefined, undefined ]
}
*/
```

In this code example, we start with our application logic represented by the `application` stream. We then use `Stream.finalizer` to define a finalization step, which deletes a temporary directory and logs a message. This ensures that the temporary directory is cleaned up properly when the application completes its execution.

## Ensuring

In this section, we'll explore a scenario where we need to perform actions after the finalization of a stream. To achieve this, we can utilize the `Stream.ensuring` operator.

Consider a situation where our application has completed its primary logic and finalized some resources, but we also need to perform additional actions afterward. We can use `Stream.ensuring` for this purpose:

```ts

const program = Stream.fromEffect(Console.log("Application Logic.")).pipe(
  Stream.concat(Stream.finalizer(Console.log("Finalizing the stream"))),
  Stream.ensuring(
    Console.log("Doing some other works after stream's finalization")
  )
)

Effect.runPromise(Stream.runCollect(program)).then(console.log)
/*
Output:
Application Logic.
Finalizing the stream
Doing some other works after stream's finalization
{
  _id: "Chunk",
  values: [ undefined, undefined ]
}
*/
```

In this code example, we start with our application logic represented by the `Application Logic.` message. We then use `Stream.finalizer` to specify the finalization step, which logs `Finalizing the stream`. After that, we use `Stream.ensuring` to indicate that we want to perform additional tasks after the stream's finalization, resulting in the message `Performing additional tasks after stream's finalization`. This ensures that our post-finalization actions are executed as expected.


---

# [Introduction](https://effect.website/docs/sink/introduction/)

## Overview

In stream processing, a `Sink` is a construct designed to consume elements generated by a `Stream`.

```text
     ┌─── Type of the result produced by the Sink
     |  ┌─── Type of elements consumed by the Sink
     |  |   ┌─── Type of any leftover elements
     │  |   |  ┌─── Type of possible errors
     │  │   |  |  ┌─── Type of required dependencies
     ▼  ▼   ▼  ▼  ▼
Sink<A, In, L, E, R>
```

Here's an overview of what a `Sink` does:

- It consumes a varying number of `In` elements, which may include zero, one, or multiple elements.
- It can encounter errors of type `E` during processing.
- It produces a result of type `A` once processing completes.
- It can also return a remainder of type `L`, representing any leftover elements.

To process a stream using a `Sink`, you can pass it directly to the `Stream.run` function:

**Example** (Using a Sink to Collect Stream Elements)

```ts

//      ┌─── Stream<number, never, never>
//      ▼
const stream = Stream.make(1, 2, 3)

// Create a sink to take the first 2 elements of the stream
//
//      ┌─── Sink<Chunk<number>, number, number, never, never>
//      ▼
const sink = Sink.take<number>(2)

// Run the stream through the sink to collect the elements
//
//      ┌─── Effect<number, never, never>
//      ▼
const sum = Stream.run(stream, sink)

Effect.runPromise(sum).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2 ] }
*/
```

The type of `sink` is as follows:

```text
       ┌─── result
       |              ┌─── consumed elements
       |              |       ┌─── leftover elements
       │              |       |       ┌─── no errors
       │              │       |       |      ┌─── no dependencies
       ▼              ▼       ▼       ▼      ▼
Sink<Chunk<number>, number, number, never, never>
```

Here's the breakdown:

- `Chunk<number>`: The final result produced by the sink after processing elements (in this case, a [Chunk](/docs/data-types/chunk/) of numbers).
- `number` (first occurrence): The type of elements that the sink will consume from the stream.
- `number` (second occurrence): The type of leftover elements, if any, that are not consumed.
- `never` (first occurrence): Indicates that this sink does not produce any errors.
- `never` (second occurrence): Shows that no dependencies are required to operate this sink.


---

# [Creating Sinks](https://effect.website/docs/sink/creating/)

## Overview

In stream processing, sinks are used to consume and handle elements from a stream. Here, we'll explore various sink constructors that allow you to create sinks for specific tasks.

## Common Constructors

### head

The `Sink.head` sink retrieves only the first element from a stream, wrapping it in `Some`. If the stream has no elements, it returns `None`.

**Example** (Retrieving the First Element)

```ts

const nonEmptyStream = Stream.make(1, 2, 3, 4)

Effect.runPromise(Stream.run(nonEmptyStream, Sink.head())).then(
  console.log
)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: 1 }
*/

const emptyStream = Stream.empty

Effect.runPromise(Stream.run(emptyStream, Sink.head())).then(console.log)
/*
Output:
{ _id: 'Option', _tag: 'None' }
*/
```

### last

The `Sink.last` sink retrieves only the last element from a stream, wrapping it in `Some`. If the stream has no elements, it returns `None`.

**Example** (Retrieving the Last Element)

```ts

const nonEmptyStream = Stream.make(1, 2, 3, 4)

Effect.runPromise(Stream.run(nonEmptyStream, Sink.last())).then(
  console.log
)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: 4 }
*/

const emptyStream = Stream.empty

Effect.runPromise(Stream.run(emptyStream, Sink.last())).then(console.log)
/*
Output:
{ _id: 'Option', _tag: 'None' }
*/
```

### count

The `Sink.count` sink consumes all elements of the stream and counts the number of elements fed to it.

```ts

const stream = Stream.make(1, 2, 3, 4)

Effect.runPromise(Stream.run(stream, Sink.count)).then(console.log)
// Output: 4
```

### sum

The `Sink.sum` sink consumes all elements of the stream and sums incoming numeric values.

```ts

const stream = Stream.make(1, 2, 3, 4)

Effect.runPromise(Stream.run(stream, Sink.sum)).then(console.log)
// Output: 10
```

### take

The `Sink.take` sink takes the specified number of values from the stream and results in a [Chunk](/docs/data-types/chunk/) data type.

```ts

const stream = Stream.make(1, 2, 3, 4)

Effect.runPromise(Stream.run(stream, Sink.take(3))).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2, 3 ] }
*/
```

### drain

The `Sink.drain` sink ignores its inputs, effectively discarding them.

```ts

const stream = Stream.make(1, 2, 3, 4).pipe(Stream.tap(Console.log))

Effect.runPromise(Stream.run(stream, Sink.drain)).then(console.log)
/*
Output:
1
2
3
4
undefined
*/
```

### timed

The `Sink.timed` sink executes the stream and measures its execution time, providing the [Duration](/docs/data-types/duration/).

```ts

const stream = Stream.make(1, 2, 3, 4).pipe(
  Stream.schedule(Schedule.spaced("100 millis"))
)

Effect.runPromise(Stream.run(stream, Sink.timed)).then(console.log)
/*
Output:
{ _id: 'Duration', _tag: 'Millis', millis: 408 }
*/
```

### forEach

The `Sink.forEach` sink executes the provided effectful function for every element fed to it.

```ts

const stream = Stream.make(1, 2, 3, 4)

Effect.runPromise(Stream.run(stream, Sink.forEach(Console.log))).then(
  console.log
)
/*
Output:
1
2
3
4
undefined
*/
```

## Creating Sinks from Success and Failure

Just as you can define streams to hold or manipulate data, you can also create sinks with specific success or failure outcomes using the `Sink.fail` and `Sink.succeed` functions.

### Succeeding Sink

This example creates a sink that doesn’t consume any elements from its upstream source but instead immediately succeeds with a specified numeric value:

**Example** (Sink that Always Succeeds with a Value)

```ts

const stream = Stream.make(1, 2, 3, 4)

Effect.runPromise(Stream.run(stream, Sink.succeed(0))).then(console.log)
// Output: 0
```

### Failing Sink

In this example, the sink also doesn’t consume any elements from its upstream source. Instead, it fails with a specified error message of type `string`:

**Example** (Sink that Always Fails with an Error Message)

```ts

const stream = Stream.make(1, 2, 3, 4)

Effect.runPromiseExit(Stream.run(stream, Sink.fail("fail!"))).then(
  console.log
)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'fail!' }
}
*/
```

## Collecting

### Collecting All Elements

To gather all elements from a data stream into a [Chunk](/docs/data-types/chunk/), use the `Sink.collectAll` sink.

The final output is a chunk containing all elements from the stream, in the order they were emitted.

**Example** (Collecting All Stream Elements)

```ts

const stream = Stream.make(1, 2, 3, 4)

Effect.runPromise(Stream.run(stream, Sink.collectAll())).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2, 3, 4 ] }
*/
```

### Collecting a Specified Number

To collect a fixed number of elements from a stream into a [Chunk](/docs/data-types/chunk/), use `Sink.collectAllN`. This sink stops collecting once it reaches the specified limit.

**Example** (Collecting a Limited Number of Elements)

```ts

const stream = Stream.make(1, 2, 3, 4, 5)

Effect.runPromise(
  Stream.run(
    stream,
    // Collect the first 3 elements into a Chunk
    Sink.collectAllN(3)
  )
).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2, 3 ] }
*/
```

### Collecting While Meeting a Condition

To gather elements from a stream while they satisfy a specific condition, use `Sink.collectAllWhile`. This sink collects elements until the provided predicate returns `false`.

**Example** (Collecting Elements Until a Condition Fails)

```ts

const stream = Stream.make(1, 2, 0, 4, 0, 6, 7)

Effect.runPromise(
  Stream.run(
    stream,
    // Collect elements while they are not equal to 0
    Sink.collectAllWhile((n) => n !== 0)
  )
).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2 ] }
*/
```

### Collecting into a HashSet

To accumulate stream elements into a `HashSet`, use `Sink.collectAllToSet()`. This ensures that each element appears only once in the final set.

**Example** (Collecting Unique Elements into a HashSet)

```ts

const stream = Stream.make(1, 2, 2, 3, 4, 4)

Effect.runPromise(Stream.run(stream, Sink.collectAllToSet())).then(
  console.log
)
/*
Output:
{ _id: 'HashSet', values: [ 1, 2, 3, 4 ] }
*/
```

### Collecting into HashSets of a Specific Size

For controlled collection into a `HashSet` with a specified maximum size, use `Sink.collectAllToSetN`. This sink gathers unique elements up to the given limit.

**Example** (Collecting Unique Elements with a Set Size Limit)

```ts

const stream = Stream.make(1, 2, 2, 3, 4, 4)

Effect.runPromise(
  Stream.run(
    stream,
    // Collect unique elements, limiting the set size to 3
    Sink.collectAllToSetN(3)
  )
).then(console.log)
/*
Output:
{ _id: 'HashSet', values: [ 1, 2, 3 ] }
*/
```

### Collecting into a HashMap

For more complex collection scenarios, `Sink.collectAllToMap` lets you gather elements into a `HashMap<K, A>` with a specified keying and merging strategy.
This sink requires both a key function to define each element's grouping and a merge function to combine values sharing the same key.

**Example** (Grouping and Merging Stream Elements in a HashMap)

In this example, we use `(n) => n % 3` to determine map keys and `(a, b) => a + b` to merge elements with the same key:

```ts

const stream = Stream.make(1, 3, 2, 3, 1, 5, 1)

Effect.runPromise(
  Stream.run(
    stream,
    Sink.collectAllToMap(
      (n) => n % 3, // Key function to group by element value
      (a, b) => a + b // Merge function to sum values with the same key
    )
  )
).then(console.log)
/*
Output:
{ _id: 'HashMap', values: [ [ 0, 6 ], [ 1, 3 ], [ 2, 7 ] ] }
*/
```

### Collecting into a HashMap with Limited Keys

To accumulate elements into a `HashMap` with a maximum number of keys, use `Sink.collectAllToMapN`. This sink collects elements until it reaches the specified key limit, requiring a key function to define the grouping of each element and a merge function to combine values with the same key.

**Example** (Limiting Collected Keys in a HashMap)

```ts

const stream = Stream.make(1, 3, 2, 3, 1, 5, 1)

Effect.runPromise(
  Stream.run(
    stream,
    Sink.collectAllToMapN(
      3, // Maximum of 3 keys
      (n) => n, // Key function to group by element value
      (a, b) => a + b // Merge function to sum values with the same key
    )
  )
).then(console.log)
/*
Output:
{ _id: 'HashMap', values: [ [ 1, 2 ], [ 2, 2 ], [ 3, 6 ] ] }
*/
```

## Folding

### Folding Left

If you want to reduce a stream into a single cumulative value by applying an operation to each element in sequence, you can use the `Sink.foldLeft` function.

**Example** (Summing Elements in a Stream Using Fold Left)

```ts

const stream = Stream.make(1, 2, 3, 4)

Effect.runPromise(
  Stream.run(
    stream,
    // Use foldLeft to sequentially add each element, starting with 0
    Sink.foldLeft(0, (a, b) => a + b)
  )
).then(console.log)
// Output: 10
```

### Folding with Termination

Sometimes, you may want to fold elements in a stream but stop the process once a specific condition is met. This is known as "short-circuiting." You can accomplish this with the `Sink.fold` function, which lets you define a termination condition.

**Example** (Folding with a Condition to Stop Early)

```ts

const stream = Stream.iterate(0, (n) => n + 1)

Effect.runPromise(
  Stream.run(
    stream,
    Sink.fold(
      0, // Initial value
      (sum) => sum <= 10, // Termination condition
      (a, b) => a + b // Folding operation
    )
  )
).then(console.log)
// Output: 15
```

### Folding Until a Limit

To accumulate elements until a specific count is reached, use `Sink.foldUntil`. This sink folds elements up to the specified limit and then stops.

**Example** (Accumulating a Set Number of Elements)

```ts

const stream = Stream.make(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

Effect.runPromise(
  Stream.run(
    stream,
    // Fold elements, stopping after accumulating 3 values
    Sink.foldUntil(0, 3, (a, b) => a + b)
  )
).then(console.log)
// Output: 6
```

### Folding with Weighted Elements

In some scenarios, you may want to fold elements based on a defined "weight" or "cost," accumulating elements until a specified maximum cost is reached. You can accomplish this with `Sink.foldWeighted`.

**Example** (Accumulating Elements Based on Weight)

In the example below, each element has a weight of `1`, and the folding resets when the accumulated weight hits `3`.

```ts

const stream = Stream.make(3, 2, 4, 1, 5, 6, 2, 1, 3, 5, 6).pipe(
  Stream.transduce(
    Sink.foldWeighted({
      initial: Chunk.empty<number>(), // Initial empty Chunk
      maxCost: 3, // Maximum accumulated cost
      cost: () => 1, // Each element has a weight of 1
      body: (acc, el) => Chunk.append(acc, el) // Append element to the Chunk
    })
  )
)

Effect.runPromise(Stream.runCollect(stream)).then((chunk) =>
  console.log("%o", chunk)
)
/*
Output:
{
  _id: 'Chunk',
  values: [
    { _id: 'Chunk', values: [ 3, 2, 4, [length]: 3 ] },
    { _id: 'Chunk', values: [ 1, 5, 6, [length]: 3 ] },
    { _id: 'Chunk', values: [ 2, 1, 3, [length]: 3 ] },
    { _id: 'Chunk', values: [ 5, 6, [length]: 2 ] },
    [length]: 4
  ]
}
*/
```


---

# [Sink Operations](https://effect.website/docs/sink/operations/)

## Overview

In previous sections, we learned how to create and use sinks. Now, let's explore some operations that let you transform or filter sink behavior.

## Adapting Sink Input

At times, you may have a sink that works with one type of input, but your current stream uses a different type. The `Sink.mapInput` function helps you adapt your sink to a new input type by transforming the input values. While `Sink.map` changes the sink's output, `Sink.mapInput` changes the input it accepts.

**Example** (Converting String Input to Numeric for Summing)

Suppose you have a `Sink.sum` that calculates the sum of numbers. If your stream contains strings rather than numbers, `Sink.mapInput` can convert those strings into numbers, allowing `Sink.sum` to work with your stream:

```ts

// A stream of numeric strings
const stream = Stream.make("1", "2", "3", "4", "5")

// Define a sink for summing numeric values
const numericSum = Sink.sum

// Use mapInput to adapt the sink, converting strings to numbers
const stringSum = numericSum.pipe(
  Sink.mapInput((s: string) => Number.parseFloat(s))
)

Effect.runPromise(Stream.run(stream, stringSum)).then(console.log)
// Output: 15
```

## Transforming Both Input and Output

When you need to transform both the input and output of a sink, `Sink.dimap` provides a flexible solution. It extends `mapInput` by allowing you to transform the input type, perform the operation, and then transform the output to a new type. This can be useful for complete conversions between input and output types.

**Example** (Converting Input to Integer, Summing, and Converting Output to String)

```ts

// A stream of numeric strings
const stream = Stream.make("1", "2", "3", "4", "5")

// Convert string inputs to numbers, sum them,
// then convert the result to a string
const sumSink = Sink.dimap(Sink.sum, {
  // Transform input: string to number
  onInput: (s: string) => Number.parseFloat(s),
  // Transform output: number to string
  onDone: (n) => String(n)
})

Effect.runPromise(Stream.run(stream, sumSink)).then(console.log)
// Output: "15"
```

## Filtering Input

Sinks can also filter incoming elements based on specific conditions with `Sink.filterInput`. This operation allows the sink to process only elements that meet certain criteria.

**Example** (Filtering Negative Numbers in Chunks of Three)

In the example below, elements are collected in chunks of three, but only positive numbers are included:

```ts

// Define a stream with positive, negative, and zero values
const stream = Stream.fromIterable([
  1, -2, 0, 1, 3, -3, 4, 2, 0, 1, -3, 1, 1, 6
]).pipe(
  Stream.transduce(
    // Collect chunks of 3, filtering out non-positive numbers
    Sink.collectAllN<number>(3).pipe(Sink.filterInput((n) => n > 0))
  )
)

Effect.runPromise(Stream.runCollect(stream)).then((chunk) =>
  console.log("%o", chunk)
)
/*
Output:
{
  _id: 'Chunk',
  values: [
    { _id: 'Chunk', values: [ 1, 1, 3, [length]: 3 ] },
    { _id: 'Chunk', values: [ 4, 2, 1, [length]: 3 ] },
    { _id: 'Chunk', values: [ 1, 1, 6, [length]: 3 ] },
    { _id: 'Chunk', values: [ [length]: 0 ] },
    [length]: 4
  ]
}
*/
```


---

# [Leftovers](https://effect.website/docs/sink/leftovers/)

## Overview

In this section, we'll look at handling elements left unconsumed by sinks. Sinks may process only a portion of the elements from an upstream source, leaving some elements as "leftovers." Here's how to collect or ignore these remaining elements.

## Collecting Leftovers

If a sink doesn't consume all elements from the upstream source, the remaining elements are called leftovers. To capture these leftovers, use `Sink.collectLeftover`, which returns a tuple containing the result of the sink operation and any unconsumed elements.

**Example** (Collecting Leftover Elements)

```ts

const stream = Stream.make(1, 2, 3, 4, 5)

// Take the first 3 elements and collect any leftovers
const sink1 = Sink.take<number>(3).pipe(Sink.collectLeftover)

Effect.runPromise(Stream.run(stream, sink1)).then(console.log)
/*
Output:
[
  { _id: 'Chunk', values: [ 1, 2, 3 ] },
  { _id: 'Chunk', values: [ 4, 5 ] }
]
*/

// Take only the first element and collect the rest as leftovers
const sink2 = Sink.head<number>().pipe(Sink.collectLeftover)

Effect.runPromise(Stream.run(stream, sink2)).then(console.log)
/*
Output:
[
  { _id: 'Option', _tag: 'Some', value: 1 },
  { _id: 'Chunk', values: [ 2, 3, 4, 5 ] }
]
*/
```

## Ignoring Leftovers

If leftover elements are not needed, you can ignore them using `Sink.ignoreLeftover`. This approach discards any unconsumed elements, so the sink operation focuses only on the elements it needs.

**Example** (Ignoring Leftover Elements)

```ts

const stream = Stream.make(1, 2, 3, 4, 5)

// Take the first 3 elements and ignore any remaining elements
const sink = Sink.take<number>(3).pipe(
  Sink.ignoreLeftover,
  Sink.collectLeftover
)

Effect.runPromise(Stream.run(stream, sink)).then(console.log)
/*
Output:
[ { _id: 'Chunk', values: [ 1, 2, 3 ] }, { _id: 'Chunk', values: [] } ]
*/
```


---

# [Sink Concurrency](https://effect.website/docs/sink/concurrency/)

## Overview

This section covers concurrent operations that allow multiple sinks to run simultaneously. These can be valuable for enhancing task performance when concurrent execution is desired.

## Combining Results with Concurrent Zipping

To run two sinks concurrently and combine their results, use `Sink.zip`. This operation executes both sinks concurrently and combines their outcomes into a tuple.

**Example** (Running Two Sinks Concurrently and Combining Results)

```ts

const stream = Stream.make("1", "2", "3", "4", "5").pipe(
  Stream.schedule(Schedule.spaced("10 millis"))
)

const sink1 = Sink.forEach((s: string) =>
  Console.log(`sink 1: ${s}`)
).pipe(Sink.as(1))

const sink2 = Sink.forEach((s: string) =>
  Console.log(`sink 2: ${s}`)
).pipe(Sink.as(2))

// Combine the two sinks to run concurrently and collect results in a tuple
const sink = Sink.zip(sink1, sink2, { concurrent: true })

Effect.runPromise(Stream.run(stream, sink)).then(console.log)
/*
Output:
sink 1: 1
sink 2: 1
sink 1: 2
sink 2: 2
sink 1: 3
sink 2: 3
sink 1: 4
sink 2: 4
sink 1: 5
sink 2: 5
[ 1, 2 ]
*/
```

## Racing Sinks: First Completion Wins

The `Sink.race` operation allows multiple sinks to compete for completion. The first sink to finish provides the result.

**Example** (Racing Two Sinks to Capture the First Result)

```ts

const stream = Stream.make("1", "2", "3", "4", "5").pipe(
  Stream.schedule(Schedule.spaced("10 millis"))
)

const sink1 = Sink.forEach((s: string) =>
  Console.log(`sink 1: ${s}`)
).pipe(Sink.as(1))

const sink2 = Sink.forEach((s: string) =>
  Console.log(`sink 2: ${s}`)
).pipe(Sink.as(2))

// Race the two sinks, the result will be from the first to complete
const sink = Sink.race(sink1, sink2)

Effect.runPromise(Stream.run(stream, sink)).then(console.log)
/*
Output:
sink 1: 1
sink 2: 1
sink 1: 2
sink 2: 2
sink 1: 3
sink 2: 3
sink 1: 4
sink 2: 4
sink 1: 5
sink 2: 5
1
*/
```


---


## Common Mistakes

**Incorrect (loading entire dataset into memory):**

```ts
const allRows = await db.query("SELECT * FROM large_table")
const processed = allRows.map(transform)
```

**Correct (streaming with back-pressure):**

```ts
const processed = Stream.fromAsyncIterable(
  db.queryStream("SELECT * FROM large_table"),
  (e) => new DbError({ cause: e })
).pipe(Stream.map(transform))
```
