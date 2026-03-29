---
title: "State Management"
impact: MEDIUM
impactDescription: "Enables safe concurrent state — covers Ref, SubscriptionRef, SynchronizedRef"
tags: state, ref, concurrent-state
---
# [Ref](https://effect.website/docs/state-management/ref/)

## Overview


When we write programs, it is common to need to keep track of some form of state during the execution of the program. State refers to any data that can change as the program runs. For example, in a counter application, the count value changes as the user increments or decrements it. Similarly, in a banking application, the account balance changes as deposits and withdrawals are made. State management is crucial to building interactive and dynamic applications.

In traditional imperative programming, one common way to store state is using variables. However, this approach can introduce bugs, especially when the state is shared between multiple components or functions. As the program becomes more complex, managing shared state can become challenging.

To overcome these issues, Effect introduces a powerful data type called `Ref`, which represents a mutable reference. With `Ref`, we can share state between different parts of our program without relying on mutable variables directly. Instead, `Ref` provides a controlled way to handle mutable state and safely update it in a concurrent environment.

Effect's `Ref` data type enables communication between different fibers in your program. This capability is crucial in concurrent programming, where multiple tasks may need to access and update shared state simultaneously.

In this guide, we will explore how to use the `Ref` data type to manage state in your programs effectively. We will cover simple examples like counting, as well as more complex scenarios where state is shared between different parts of the program. Additionally, we will show how to use `Ref` in a concurrent environment, allowing multiple tasks to interact with shared state safely.

Let's dive in and see how we can leverage `Ref` for effective state management in your Effect programs.

## Using Ref

Here is a simple example using `Ref` to create a counter:

**Example** (Basic Counter with `Ref`)

```ts

class Counter {
  inc: Effect.Effect<void>
  dec: Effect.Effect<void>
  get: Effect.Effect<number>

  constructor(private value: Ref.Ref<number>) {
    this.inc = Ref.update(this.value, (n) => n + 1)
    this.dec = Ref.update(this.value, (n) => n - 1)
    this.get = Ref.get(this.value)
  }
}

const make = Effect.andThen(Ref.make(0), (value) => new Counter(value))
```

**Example** (Using the Counter)

```ts

class Counter {
  inc: Effect.Effect<void>
  dec: Effect.Effect<void>
  get: Effect.Effect<number>

  constructor(private value: Ref.Ref<number>) {
    this.inc = Ref.update(this.value, (n) => n + 1)
    this.dec = Ref.update(this.value, (n) => n - 1)
    this.get = Ref.get(this.value)
  }
}

const make = Effect.andThen(Ref.make(0), (value) => new Counter(value))

const program = Effect.gen(function* () {
  const counter = yield* make
  yield* counter.inc
  yield* counter.inc
  yield* counter.dec
  yield* counter.inc
  const value = yield* counter.get
  console.log(`This counter has a value of ${value}.`)
})

Effect.runPromise(program)
/*
Output:
This counter has a value of 2.
*/
```

> **Note: Ref Operations Are Effectful**
  All the operations on the `Ref` data type are effectful. So when we are
  reading from or writing to a `Ref`, we are performing an effectful
  operation.


## Using Ref in a Concurrent Environment

We can also use `Ref` in concurrent scenarios, where multiple tasks might be updating shared state at the same time.

**Example** (Concurrent Updates to Shared Counter)

For this example, let's update the counter concurrently:

```ts

class Counter {
  inc: Effect.Effect<void>
  dec: Effect.Effect<void>
  get: Effect.Effect<number>

  constructor(private value: Ref.Ref<number>) {
    this.inc = Ref.update(this.value, (n) => n + 1)
    this.dec = Ref.update(this.value, (n) => n - 1)
    this.get = Ref.get(this.value)
  }
}

const make = Effect.andThen(Ref.make(0), (value) => new Counter(value))

const program = Effect.gen(function* () {
  const counter = yield* make

  // Helper to log the counter's value before running an effect
  const logCounter = <R, E, A>(
    label: string,
    effect: Effect.Effect<A, E, R>
  ) =>
    Effect.gen(function* () {
      const value = yield* counter.get
      yield* Effect.log(`${label} get: ${value}`)
      return yield* effect
    })

  yield* logCounter("task 1", counter.inc).pipe(
    Effect.zip(logCounter("task 2", counter.inc), { concurrent: true }),
    Effect.zip(logCounter("task 3", counter.dec), { concurrent: true }),
    Effect.zip(logCounter("task 4", counter.inc), { concurrent: true })
  )
  const value = yield* counter.get
  yield* Effect.log(`This counter has a value of ${value}.`)
})

Effect.runPromise(program)
/*
Output:
timestamp=... fiber=#3 message="task 4 get: 0"
timestamp=... fiber=#6 message="task 3 get: 1"
timestamp=... fiber=#8 message="task 1 get: 0"
timestamp=... fiber=#9 message="task 2 get: 1"
timestamp=... fiber=#0 message="This counter has a value of 2."
*/
```

## Using Ref as a Service

You can pass a `Ref` as a [service](/docs/requirements-management/services/) to share state across different parts of your program.

**Example** (Using `Ref` as a Service)

```ts

// Create a Tag for our state
class MyState extends Context.Tag("MyState")<
  MyState,
  Ref.Ref<number>
>() {}

// Subprogram 1: Increment the state value twice
const subprogram1 = Effect.gen(function* () {
  const state = yield* MyState
  yield* Ref.update(state, (n) => n + 1)
  yield* Ref.update(state, (n) => n + 1)
})

// Subprogram 2: Decrement the state value and then increment it
const subprogram2 = Effect.gen(function* () {
  const state = yield* MyState
  yield* Ref.update(state, (n) => n - 1)
  yield* Ref.update(state, (n) => n + 1)
})

// Subprogram 3: Read and log the current value of the state
const subprogram3 = Effect.gen(function* () {
  const state = yield* MyState
  const value = yield* Ref.get(state)
  console.log(`MyState has a value of ${value}.`)
})

// Compose subprograms 1, 2, and 3 to create the main program
const program = Effect.gen(function* () {
  yield* subprogram1
  yield* subprogram2
  yield* subprogram3
})

// Create a Ref instance with an initial value of 0
const initialState = Ref.make(0)

// Provide the Ref as a service
const runnable = program.pipe(
  Effect.provideServiceEffect(MyState, initialState)
)

// Run the program and observe the output
Effect.runPromise(runnable)
/*
Output:
MyState has a value of 2.
*/
```

Note that we use `Effect.provideServiceEffect` instead of `Effect.provideService` to provide an actual implementation of the `MyState` service because all the operations on the `Ref` data type are effectful, including the creation `Ref.make(0)`.

## Sharing State Between Fibers

You can use `Ref` to manage shared state between multiple fibers in a concurrent environment.

**Example** (Managing Shared State Across Fibers)

Let's look at an example where we continuously read names from user input until the user enters `"q"` to exit.

First, let's introduce a `readLine` utility to read user input (ensure you have `@types/node` installed):

```ts
import * as NodeReadLine from "node:readline"

// Utility to read user input
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

Next, we implement the main program to collect names:

```ts
import * as NodeReadLine from "node:readline"

// Utility to read user input
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

const getNames = Effect.gen(function* () {
  const ref = yield* Ref.make(Chunk.empty<string>())
  while (true) {
    const name = yield* readLine("Please enter a name or `q` to exit: ")
    if (name === "q") {
      break
    }
    yield* Ref.update(ref, (state) => Chunk.append(state, name))
  }
  return yield* Ref.get(ref)
})

Effect.runPromise(getNames).then(console.log)
/*
Output:
Please enter a name or `q` to exit: Alice
Please enter a name or `q` to exit: Bob
Please enter a name or `q` to exit: q
{
  _id: "Chunk",
  values: [ "Alice", "Bob" ]
}
*/
```

Now that we have learned how to use the `Ref` data type, we can use it to manage the state concurrently.

For example, assume while we are reading from the console, we have another fiber that is trying to update the state from a different source.

Here, one fiber reads names from user input, while another fiber concurrently adds preset names at regular intervals:

```ts
import * as NodeReadLine from "node:readline"

// Utility to read user input
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

const getNames = Effect.gen(function* () {
  const ref = yield* Ref.make(Chunk.empty<string>())

  // Fiber 1: Reading names from user input
  const fiber1 = yield* Effect.fork(
    Effect.gen(function* () {
      while (true) {
        const name = yield* readLine(
          "Please enter a name or `q` to exit: "
        )
        if (name === "q") {
          break
        }
        yield* Ref.update(ref, (state) => Chunk.append(state, name))
      }
    })
  )

  // Fiber 2: Updating the state with predefined names
  const fiber2 = yield* Effect.fork(
    Effect.gen(function* () {
      for (const name of ["John", "Jane", "Joe", "Tom"]) {
        yield* Ref.update(ref, (state) => Chunk.append(state, name))
        yield* Effect.sleep("1 second")
      }
    })
  )
  yield* Fiber.join(fiber1)
  yield* Fiber.join(fiber2)
  return yield* Ref.get(ref)
})

Effect.runPromise(getNames).then(console.log)
/*
Output:
Please enter a name or `q` to exit: Alice
Please enter a name or `q` to exit: Bob
Please enter a name or `q` to exit: q
{
  _id: "Chunk",
  // Note: the following result may vary
  // depending on the speed of user input
  values: [ 'John', 'Jane', 'Joe', 'Tom', 'Alice', 'Bob' ]
}
*/
```


---

# [SubscriptionRef](https://effect.website/docs/state-management/subscriptionref/)

## Overview

A `SubscriptionRef<A>` is a specialized form of a [SynchronizedRef](/docs/state-management/synchronizedref/). It allows us to subscribe and receive updates on the current value and any changes made to that value.

```ts
interface SubscriptionRef<A> extends SynchronizedRef<A> {
  /**
   * A stream containing the current value of the `Ref` as well as all changes
   * to that value.
   */
  readonly changes: Stream<A>
}
```

You can perform all standard operations on a `SubscriptionRef`, such as `get`, `set`, or `modify` to interact with the current value.

The key feature of `SubscriptionRef` is its `changes` stream. This stream allows you to observe the current value at the moment of subscription and receive all subsequent changes. Every time the stream is run, it emits the current value and tracks future updates.

To create a `SubscriptionRef`, you can use the `SubscriptionRef.make` constructor, specifying the initial value:

**Example** (Creating a `SubscriptionRef`)

```ts

const ref = SubscriptionRef.make(0)
```

`SubscriptionRef` is particularly useful for modeling shared state when multiple observers need to react to changes. For example, in functional reactive programming, the `SubscriptionRef` could represent a portion of the application state, and various observers (like UI components) would update in response to state changes.

**Example** (Server-Client Model with `SubscriptionRef`)

In the following example, a "server" continually updates a shared value, while multiple "clients" observe the changes:

```ts

// Server function that increments a shared value forever
const server = (ref: Ref.Ref<number>) =>
  Ref.update(ref, (n) => n + 1).pipe(Effect.forever)
```

The `server` function operates on a regular `Ref` and continuously updates the value. It doesn't need to know about `SubscriptionRef` directly.

Next, let's define a `client` that subscribes to changes and collects a specified number of values:

```ts

// Server function that increments a shared value forever
const server = (ref: Ref.Ref<number>) =>
  Ref.update(ref, (n) => n + 1).pipe(Effect.forever)

// Client function that observes the stream of changes
const client = (changes: Stream.Stream<number>) =>
  Effect.gen(function* () {
    const n = yield* Random.nextIntBetween(1, 10)
    const chunk = yield* Stream.runCollect(Stream.take(changes, n))
    return chunk
  })
```

Similarly, the `client` function only works with a `Stream` of values and doesn't concern itself with the source of these values.

To tie everything together, we start the server, launch multiple client instances in parallel, and then shut down the server when we're finished. We also create the `SubscriptionRef` in this process.

```ts
import {
  Ref,
  Effect,
  Stream,
  Random,
  SubscriptionRef,
  Fiber
} from "effect"

// Server function that increments a shared value forever
const server = (ref: Ref.Ref<number>) =>
  Ref.update(ref, (n) => n + 1).pipe(Effect.forever)

// Client function that observes the stream of changes
const client = (changes: Stream.Stream<number>) =>
  Effect.gen(function* () {
    const n = yield* Random.nextIntBetween(1, 10)
    const chunk = yield* Stream.runCollect(Stream.take(changes, n))
    return chunk
  })

const program = Effect.gen(function* () {
  // Create a SubscriptionRef with an initial value of 0
  const ref = yield* SubscriptionRef.make(0)

  // Fork the server to run concurrently
  const serverFiber = yield* Effect.fork(server(ref))

  // Create 5 clients that subscribe to the changes stream
  const clients = new Array(5).fill(null).map(() => client(ref.changes))

  // Run all clients in concurrently and collect their results
  const chunks = yield* Effect.all(clients, { concurrency: "unbounded" })

  // Interrupt the server when clients are done
  yield* Fiber.interrupt(serverFiber)

  // Output the results collected by each client
  for (const chunk of chunks) {
    console.log(chunk)
  }
})

Effect.runPromise(program)
/*
Example Output:
{ _id: 'Chunk', values: [ 4, 5, 6, 7, 8, 9 ] }
{ _id: 'Chunk', values: [ 4 ] }
{ _id: 'Chunk', values: [ 4, 5, 6, 7, 8, 9 ] }
{ _id: 'Chunk', values: [ 4, 5 ] }
{ _id: 'Chunk', values: [ 4, 5, 6, 7, 8, 9 ] }
*/
```

This setup ensures that each client observes the current value when it starts and receives all subsequent changes to the value.

Since the changes are represented as streams, you can easily build more complex programs using familiar stream operators. You can transform, filter, or merge these streams with other streams to achieve more sophisticated behavior.


---

# [SynchronizedRef](https://effect.website/docs/state-management/synchronizedref/)

## Overview


`SynchronizedRef<A>` serves as a mutable reference to a value of type `A`.
With it, we can store **immutable** data and perform updates **atomically** and effectfully.

> **Tip: Learn Ref First**
  Most of the operations for `SynchronizedRef` are similar to those of
  `Ref`. If you're not already familiar with `Ref`, it's recommended to
  read about [the Ref concept](/docs/state-management/ref/) first.


The distinctive function in `SynchronizedRef` is `updateEffect`.
This function takes an effectful operation and executes it to modify the shared state.
This is the key feature setting `SynchronizedRef` apart from `Ref`.

In real-world applications, `SynchronizedRef` is useful when you need to execute effects, such as querying a database, and then update shared state based on the result. It ensures that updates happen sequentially, preserving consistency in concurrent environments.

**Example** (Concurrent Updates with `SynchronizedRef`)

In this example, we simulate fetching user ages concurrently and updating a shared state that stores the ages:

```ts

// Simulated API to get user age
const getUserAge = (userId: number) =>
  Effect.succeed(userId * 10).pipe(Effect.delay(10 - userId))

const meanAge = Effect.gen(function* () {
  // Initialize a SynchronizedRef to hold an array of ages
  const ref = yield* SynchronizedRef.make<number[]>([])

  // Helper function to log state before each effect
  const log = <R, E, A>(label: string, effect: Effect.Effect<A, E, R>) =>
    Effect.gen(function* () {
      const value = yield* SynchronizedRef.get(ref)
      yield* Effect.log(label, value)
      return yield* effect
    })

  const task = (id: number) =>
    log(
      `task ${id}`,
      SynchronizedRef.updateEffect(ref, (sumOfAges) =>
        Effect.gen(function* () {
          const age = yield* getUserAge(id)
          return sumOfAges.concat(age)
        })
      )
    )

  // Run tasks concurrently with a limit of 2 concurrent tasks
  yield* Effect.all([task(1), task(2), task(3), task(4)], {
    concurrency: 2
  })

  // Retrieve the updated value
  const value = yield* SynchronizedRef.get(ref)
  return value
})

Effect.runPromise(meanAge).then(console.log)
/*
Output:
timestamp=... level=INFO fiber=#2 message="task 1" message=[]
timestamp=... level=INFO fiber=#3 message="task 2" message=[]
timestamp=... level=INFO fiber=#2 message="task 3" message="[
  10
]"
timestamp=... level=INFO fiber=#3 message="task 4" message="[
  10,
  20
]"
[ 10, 20, 30, 40 ]
*/
```


---


## Common Mistakes

**Incorrect (shared mutable state without synchronization):**

```ts
let counter = 0
await Promise.all([
  Promise.resolve().then(() => counter++),
  Promise.resolve().then(() => counter++)
])
// counter may not be 2 due to race conditions
```

**Correct (using Ref for atomic concurrent state):**

```ts
const program = Effect.gen(function* () {
  const counter = yield* Ref.make(0)
  yield* Effect.all([
    Ref.update(counter, (n) => n + 1),
    Ref.update(counter, (n) => n + 1)
  ], { concurrency: "unbounded" })
  return yield* Ref.get(counter) // Always 2
})
```
