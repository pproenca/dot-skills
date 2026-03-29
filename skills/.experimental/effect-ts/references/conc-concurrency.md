---
title: "Concurrency"
impact: HIGH
impactDescription: "Prevents race conditions and deadlocks — covers fibers, deferred, queues, semaphores, PubSub"
tags: conc, concurrency, fibers, queues, semaphores
---
# [Basic Concurrency](https://effect.website/docs/concurrency/basic-concurrency/)

## Overview


## Concurrency Options

Effect provides options to manage how effects are executed, particularly focusing on controlling how many effects run concurrently.

```ts
type Options = {
  readonly concurrency?: Concurrency
}
```

The `concurrency` option is used to determine the level of concurrency, with the following values:

```ts
type Concurrency = number | "unbounded" | "inherit"
```

Let's explore each configuration in detail.

> **Tip: Applicability of Concurrency Options**
  The examples here use the `Effect.all` function, but these options apply
  to many other Effect APIs.


### Sequential Execution (Default)

By default, if you don't specify any concurrency option, effects will run sequentially, one after the other. This means each effect starts only after the previous one completes.

**Example** (Sequential Execution)

```ts

// Helper function to simulate a task with a delay
const makeTask = (n: number, delay: Duration.DurationInput) =>
  Effect.promise(
    () =>
      new Promise<void>((resolve) => {
        console.log(`start task${n}`) // Logs when the task starts
        setTimeout(() => {
          console.log(`task${n} done`) // Logs when the task finishes
          resolve()
        }, Duration.toMillis(delay))
      })
  )

const task1 = makeTask(1, "200 millis")
const task2 = makeTask(2, "100 millis")

const sequential = Effect.all([task1, task2])

Effect.runPromise(sequential)
/*
Output:
start task1
task1 done
start task2 <-- task2 starts only after task1 completes
task2 done
*/
```

### Numbered Concurrency

You can control how many effects run concurrently by setting a `number` for `concurrency`. For example, `concurrency: 2` allows up to two effects to run at the same time.

**Example** (Limiting to 2 Concurrent Tasks)

```ts

// Helper function to simulate a task with a delay
const makeTask = (n: number, delay: Duration.DurationInput) =>
  Effect.promise(
    () =>
      new Promise<void>((resolve) => {
        console.log(`start task${n}`) // Logs when the task starts
        setTimeout(() => {
          console.log(`task${n} done`) // Logs when the task finishes
          resolve()
        }, Duration.toMillis(delay))
      })
  )

const task1 = makeTask(1, "200 millis")
const task2 = makeTask(2, "100 millis")
const task3 = makeTask(3, "210 millis")
const task4 = makeTask(4, "110 millis")
const task5 = makeTask(5, "150 millis")

const numbered = Effect.all([task1, task2, task3, task4, task5], {
  concurrency: 2
})

Effect.runPromise(numbered)
/*
Output:
start task1
start task2 <-- active tasks: task1, task2
task2 done
start task3 <-- active tasks: task1, task3
task1 done
start task4 <-- active tasks: task3, task4
task4 done
start task5 <-- active tasks: task3, task5
task3 done
task5 done
*/
```

### Unbounded Concurrency

When `concurrency: "unbounded"` is used, there's no limit to the number of effects running concurrently.

**Example** (Unbounded Concurrency)

```ts

// Helper function to simulate a task with a delay
const makeTask = (n: number, delay: Duration.DurationInput) =>
  Effect.promise(
    () =>
      new Promise<void>((resolve) => {
        console.log(`start task${n}`) // Logs when the task starts
        setTimeout(() => {
          console.log(`task${n} done`) // Logs when the task finishes
          resolve()
        }, Duration.toMillis(delay))
      })
  )

const task1 = makeTask(1, "200 millis")
const task2 = makeTask(2, "100 millis")
const task3 = makeTask(3, "210 millis")
const task4 = makeTask(4, "110 millis")
const task5 = makeTask(5, "150 millis")

const unbounded = Effect.all([task1, task2, task3, task4, task5], {
  concurrency: "unbounded"
})

Effect.runPromise(unbounded)
/*
Output:
start task1
start task2
start task3
start task4
start task5
task2 done
task4 done
task5 done
task1 done
task3 done
*/
```

### Inherit Concurrency

When using `concurrency: "inherit"`, the concurrency level is inherited from the surrounding context. This context can be set using `Effect.withConcurrency(number | "unbounded")`. If no context is provided, the default is `"unbounded"`.

**Example** (Inheriting Concurrency from Context)

```ts

// Helper function to simulate a task with a delay
const makeTask = (n: number, delay: Duration.DurationInput) =>
  Effect.promise(
    () =>
      new Promise<void>((resolve) => {
        console.log(`start task${n}`) // Logs when the task starts
        setTimeout(() => {
          console.log(`task${n} done`) // Logs when the task finishes
          resolve()
        }, Duration.toMillis(delay))
      })
  )

const task1 = makeTask(1, "200 millis")
const task2 = makeTask(2, "100 millis")
const task3 = makeTask(3, "210 millis")
const task4 = makeTask(4, "110 millis")
const task5 = makeTask(5, "150 millis")

// Running all tasks with concurrency: "inherit",
// which defaults to "unbounded"
const inherit = Effect.all([task1, task2, task3, task4, task5], {
  concurrency: "inherit"
})

Effect.runPromise(inherit)
/*
Output:
start task1
start task2
start task3
start task4
start task5
task2 done
task4 done
task5 done
task1 done
task3 done
*/
```

If you use `Effect.withConcurrency`, the concurrency configuration will adjust to the specified option.

**Example** (Setting Concurrency Option)

```ts

// Helper function to simulate a task with a delay
const makeTask = (n: number, delay: Duration.DurationInput) =>
  Effect.promise(
    () =>
      new Promise<void>((resolve) => {
        console.log(`start task${n}`) // Logs when the task starts
        setTimeout(() => {
          console.log(`task${n} done`) // Logs when the task finishes
          resolve()
        }, Duration.toMillis(delay))
      })
  )

const task1 = makeTask(1, "200 millis")
const task2 = makeTask(2, "100 millis")
const task3 = makeTask(3, "210 millis")
const task4 = makeTask(4, "110 millis")
const task5 = makeTask(5, "150 millis")

// Running tasks with concurrency: "inherit",
// which will inherit the surrounding context
const inherit = Effect.all([task1, task2, task3, task4, task5], {
  concurrency: "inherit"
})

// Setting a concurrency limit of 2
const withConcurrency = inherit.pipe(Effect.withConcurrency(2))

Effect.runPromise(withConcurrency)
/*
Output:
start task1
start task2 <-- active tasks: task1, task2
task2 done
start task3 <-- active tasks: task1, task3
task1 done
start task4 <-- active tasks: task3, task4
task4 done
start task5 <-- active tasks: task3, task5
task3 done
task5 done
*/
```

## Interruptions

All effects in Effect are executed by [fibers](/docs/concurrency/fibers/). If you didn't create the fiber yourself, it was created by an operation you're using (if it's concurrent) or by the Effect [runtime](/docs/runtime/) system.

A fiber is created any time an effect is run. When running effects concurrently, a fiber is created for each concurrent effect.

To summarize:

- An `Effect` is a higher-level concept that describes an effectful computation. It is lazy and immutable, meaning it represents a computation that may produce a value or fail but does not immediately execute.
- A fiber, on the other hand, represents the running execution of an `Effect`. It can be interrupted or awaited to retrieve its result. Think of it as a way to control and interact with the ongoing computation.

Fibers can be interrupted in various ways. Let's explore some of these scenarios and see examples of how to interrupt fibers in Effect.

### interrupt

A fiber can be interrupted using the `Effect.interrupt` effect on that particular fiber.

This effect models the explicit interruption of the fiber in which it runs.
When executed, it causes the fiber to stop its operation immediately, capturing the interruption details such as the fiber's ID and its start time.
The resulting interruption can be observed in the [Exit](/docs/data-types/exit/) type if the effect is run with functions like [runPromiseExit](/docs/getting-started/running-effects/#runpromiseexit).

**Example** (Without Interruption)

In this case, the program runs without any interruption, logging the start and completion of the task.

```ts

const program = Effect.gen(function* () {
  console.log("start")
  yield* Effect.sleep("2 seconds")
  console.log("done")
  return "some result"
})

Effect.runPromiseExit(program).then(console.log)
/*
Output:
start
done
{ _id: 'Exit', _tag: 'Success', value: 'some result' }
*/
```

**Example** (With Interruption)

Here, the fiber is interrupted after the log `"start"` but before the `"done"` log. The `Effect.interrupt` stops the fiber, and it never reaches the final log.

```ts {6} twoslash

const program = Effect.gen(function* () {
  console.log("start")
  yield* Effect.sleep("2 seconds")
  yield* Effect.interrupt
  console.log("done")
  return "some result"
})

Effect.runPromiseExit(program).then(console.log)
/*
Output:
start
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Interrupt',
    fiberId: {
      _id: 'FiberId',
      _tag: 'Runtime',
      id: 0,
      startTimeMillis: ...
    }
  }
}
*/
```

### onInterrupt

Registers a cleanup effect to run when an effect is interrupted.

This function allows you to specify an effect to run when the fiber is interrupted. This effect will be executed
when the fiber is interrupted, allowing you to perform cleanup or other actions.

**Example** (Running a Cleanup Action on Interruption)

In this example, we set up a handler that logs "Cleanup completed" whenever the fiber is interrupted. We then show three cases: a successful effect, a failing effect, and an interrupted effect, demonstrating how the handler is triggered depending on how the effect ends.

```ts

// This handler is executed when the fiber is interrupted
const handler = Effect.onInterrupt((_fibers) =>
  Console.log("Cleanup completed")
)

const success = Console.log("Task completed").pipe(
  Effect.as("some result"),
  handler
)

Effect.runFork(success)
/*
Output:
Task completed
*/

const failure = Console.log("Task failed").pipe(
  Effect.andThen(Effect.fail("some error")),
  handler
)

Effect.runFork(failure)
/*
Output:
Task failed
*/

const interruption = Console.log("Task interrupted").pipe(
  Effect.andThen(Effect.interrupt),
  handler
)

Effect.runFork(interruption)
/*
Output:
Task interrupted
Cleanup completed
*/
```

### Interruption of Concurrent Effects

When running multiple effects concurrently, such as with `Effect.forEach`, if one of the effects is interrupted, it causes all concurrent effects to be interrupted as well.

The resulting [cause](/docs/data-types/cause/) includes information about which fibers were interrupted.

**Example** (Interrupting Concurrent Effects)

```ts

const program = Effect.forEach(
  [1, 2, 3],
  (n) =>
    Effect.gen(function* () {
      console.log(`start #${n}`)
      yield* Effect.sleep(`${n} seconds`)
      if (n > 1) {
        yield* Effect.interrupt
      }
      console.log(`done #${n}`)
    }).pipe(Effect.onInterrupt(() => Console.log(`interrupted #${n}`))),
  { concurrency: "unbounded" }
)

Effect.runPromiseExit(program).then((exit) =>
  console.log(JSON.stringify(exit, null, 2))
)
/*
Output:
start #1
start #2
start #3
done #1
interrupted #2
interrupted #3
{
  "_id": "Exit",
  "_tag": "Failure",
  "cause": {
    "_id": "Cause",
    "_tag": "Parallel",
    "left": {
      "_id": "Cause",
      "_tag": "Interrupt",
      "fiberId": {
        "_id": "FiberId",
        "_tag": "Runtime",
        "id": 3,
        "startTimeMillis": ...
      }
    },
    "right": {
      "_id": "Cause",
      "_tag": "Sequential",
      "left": {
        "_id": "Cause",
        "_tag": "Empty"
      },
      "right": {
        "_id": "Cause",
        "_tag": "Interrupt",
        "fiberId": {
          "_id": "FiberId",
          "_tag": "Runtime",
          "id": 0,
          "startTimeMillis": ...
        }
      }
    }
  }
}
*/
```

## Racing

### race

This function takes two effects and runs them concurrently. The first effect
that successfully completes will determine the result of the race, and the
other effect will be interrupted.

If neither effect succeeds, the function will fail with a [cause](/docs/data-types/cause/) containing all the errors.

This is useful when you want to run two effects concurrently, but only care
about the first one to succeed. It is commonly used in cases like timeouts,
retries, or when you want to optimize for the faster response without
worrying about the other effect.

**Example** (Both Tasks Succeed)

```ts

const task1 = Effect.succeed("task1").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() => Console.log("task1 interrupted"))
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() => Console.log("task2 interrupted"))
)

const program = Effect.race(task1, task2)

Effect.runFork(program)
/*
Output:
task2 done
task1 interrupted
*/
```

**Example** (One Task Fails, One Succeeds)

```ts

const task1 = Effect.fail("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() => Console.log("task1 interrupted"))
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() => Console.log("task2 interrupted"))
)

const program = Effect.race(task1, task2)

Effect.runFork(program)
/*
Output:
task2 done
*/
```

**Example** (Both Tasks Fail)

```ts

const task1 = Effect.fail("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() => Console.log("task1 interrupted"))
)
const task2 = Effect.fail("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() => Console.log("task2 interrupted"))
)

const program = Effect.race(task1, task2)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Parallel',
    left: { _id: 'Cause', _tag: 'Fail', failure: 'task1' },
    right: { _id: 'Cause', _tag: 'Fail', failure: 'task2' }
  }
}
*/
```

If you want to handle the result of whichever task completes first, whether it succeeds or fails, you can use the `Effect.either` function. This function wraps the result in an [Either](/docs/data-types/either/) type, allowing you to see if the result was a success (`Right`) or a failure (`Left`):

**Example** (Handling Success or Failure with Either)

```ts

const task1 = Effect.fail("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() => Console.log("task1 interrupted"))
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() => Console.log("task2 interrupted"))
)

// Run both tasks concurrently, wrapping the result
// in Either to capture success or failure
const program = Effect.race(Effect.either(task1), Effect.either(task2))

Effect.runPromise(program).then(console.log)
/*
Output:
task2 interrupted
{ _id: 'Either', _tag: 'Left', left: 'task1' }
*/
```

### raceAll

This function runs multiple effects concurrently and returns the result of the first one to succeed. If one effect succeeds, the others will be interrupted.

If none of the effects succeed, the function will fail with the last error encountered.

This is useful when you want to race multiple effects, but only care
about the first one to succeed. It is commonly used in cases like timeouts,
retries, or when you want to optimize for the faster response without
worrying about the other effects.

**Example** (All Tasks Succeed)

```ts

const task1 = Effect.succeed("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() => Console.log("task1 interrupted"))
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() => Console.log("task2 interrupted"))
)

const task3 = Effect.succeed("task3").pipe(
  Effect.delay("150 millis"),
  Effect.tap(Console.log("task3 done")),
  Effect.onInterrupt(() => Console.log("task3 interrupted"))
)

const program = Effect.raceAll([task1, task2, task3])

Effect.runFork(program)
/*
Output:
task1 done
task2 interrupted
task3 interrupted
*/
```

**Example** (One Task Fails, Two Tasks Succeed)

```ts

const task1 = Effect.fail("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() => Console.log("task1 interrupted"))
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() => Console.log("task2 interrupted"))
)

const task3 = Effect.succeed("task3").pipe(
  Effect.delay("150 millis"),
  Effect.tap(Console.log("task3 done")),
  Effect.onInterrupt(() => Console.log("task3 interrupted"))
)

const program = Effect.raceAll([task1, task2, task3])

Effect.runFork(program)
/*
Output:
task3 done
task2 interrupted
*/
```

**Example** (All Tasks Fail)

```ts

const task1 = Effect.fail("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() => Console.log("task1 interrupted"))
)
const task2 = Effect.fail("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() => Console.log("task2 interrupted"))
)

const task3 = Effect.fail("task3").pipe(
  Effect.delay("150 millis"),
  Effect.tap(Console.log("task3 done")),
  Effect.onInterrupt(() => Console.log("task3 interrupted"))
)

const program = Effect.raceAll([task1, task2, task3])

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'task2' }
}
*/
```

### raceFirst

This function takes two effects and runs them concurrently, returning the
result of the first one that completes, regardless of whether it succeeds or
fails.

This function is useful when you want to race two operations, and you want to
proceed with whichever one finishes first, regardless of whether it succeeds
or fails.

**Example** (Both Tasks Succeed)

```ts

const task1 = Effect.succeed("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() =>
    Console.log("task1 interrupted").pipe(Effect.delay("100 millis"))
  )
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() =>
    Console.log("task2 interrupted").pipe(Effect.delay("100 millis"))
  )
)

const program = Effect.raceFirst(task1, task2).pipe(
  Effect.tap(Console.log("more work..."))
)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
task1 done
task2 interrupted
more work...
{ _id: 'Exit', _tag: 'Success', value: 'task1' }
*/
```

**Example** (One Task Fails, One Succeeds)

```ts

const task1 = Effect.fail("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() =>
    Console.log("task1 interrupted").pipe(Effect.delay("100 millis"))
  )
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() =>
    Console.log("task2 interrupted").pipe(Effect.delay("100 millis"))
  )
)

const program = Effect.raceFirst(task1, task2).pipe(
  Effect.tap(Console.log("more work..."))
)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
task2 interrupted
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'task1' }
}
*/
```

#### Disconnecting Effects

The `Effect.raceFirst` function safely interrupts the "loser" effect once the other completes, but it will not resume until the loser is cleanly terminated.

If you want a quicker return, you can disconnect the interrupt signal for both effects. Instead of calling:

```ts
Effect.raceFirst(task1, task2)
```

You can use:

```ts
Effect.raceFirst(Effect.disconnect(task1), Effect.disconnect(task2))
```

This allows both effects to complete independently while still terminating the losing effect in the background.

**Example** (Using `Effect.disconnect` for Quicker Return)

```ts

const task1 = Effect.succeed("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() =>
    Console.log("task1 interrupted").pipe(Effect.delay("100 millis"))
  )
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() =>
    Console.log("task2 interrupted").pipe(Effect.delay("100 millis"))
  )
)

// Race the two tasks with disconnect to allow quicker return
const program = Effect.raceFirst(
  Effect.disconnect(task1),
  Effect.disconnect(task2)
).pipe(Effect.tap(Console.log("more work...")))

Effect.runPromiseExit(program).then(console.log)
/*
Output:
task1 done
more work...
{ _id: 'Exit', _tag: 'Success', value: 'task1' }
task2 interrupted
*/
```

### raceWith

This function runs two effects concurrently and calls a specified "finisher" function once one of the effects completes, regardless of whether it succeeds or fails.

The finisher functions for each effect allow you to handle the results of each effect as soon as they complete.

The function takes two finisher callbacks, one for each effect, and allows you to specify how to handle the result of the race.

This function is useful when you need to react to the completion of either effect without waiting for both to finish. It can be used whenever you want to take action based on the first available result.

**Example** (Handling Results of Concurrent Tasks)

```ts

const task1 = Effect.succeed("task1").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Console.log("task1 done")),
  Effect.onInterrupt(() =>
    Console.log("task1 interrupted").pipe(Effect.delay("100 millis"))
  )
)
const task2 = Effect.succeed("task2").pipe(
  Effect.delay("200 millis"),
  Effect.tap(Console.log("task2 done")),
  Effect.onInterrupt(() =>
    Console.log("task2 interrupted").pipe(Effect.delay("100 millis"))
  )
)

const program = Effect.raceWith(task1, task2, {
  onSelfDone: (exit) => Console.log(`task1 exited with ${exit}`),
  onOtherDone: (exit) => Console.log(`task2 exited with ${exit}`)
})

Effect.runFork(program)
/*
Output:
task1 done
task1 exited with {
  "_id": "Exit",
  "_tag": "Success",
  "value": "task1"
}
task2 interrupted
*/
```


---

# [Fibers](https://effect.website/docs/concurrency/fibers/)

## Overview


Effect is a highly concurrent framework powered by fibers. Fibers are lightweight virtual threads with resource-safe cancellation capabilities, enabling many features in Effect.

In this section, you will learn the basics of fibers and get familiar with some of the powerful low-level operators that utilize fibers.

## What Are Virtual Threads?

JavaScript is inherently single-threaded, meaning it executes code in a single sequence of instructions. However, modern JavaScript environments use an event loop to manage asynchronous operations, creating the illusion of multitasking. In this context, virtual threads, or fibers, are logical threads simulated by the Effect runtime. They allow concurrent execution without relying on true multi-threading, which is not natively supported in JavaScript.

## How Fibers work

All effects in Effect are executed by fibers. If you didn't create the fiber yourself, it was created by an operation you're using (if it's concurrent) or by the Effect runtime system.

A fiber is created any time an effect is run. When running effects concurrently, a fiber is created for each concurrent effect.

Even if you write "single-threaded" code with no concurrent operations, there will always be at least one fiber: the "main" fiber that executes your effect.

Effect fibers have a well-defined lifecycle based on the effect they are executing.

Every fiber exits with either a failure or success, depending on whether the effect it is executing fails or succeeds.

Effect fibers have unique identities, local state, and a status (such as done, running, or suspended).

To summarize:

- An `Effect` is a higher-level concept that describes an effectful computation. It is lazy and immutable, meaning it represents a computation that may produce a value or fail but does not immediately execute.
- A fiber, on the other hand, represents the running execution of an `Effect`. It can be interrupted or awaited to retrieve its result. Think of it as a way to control and interact with the ongoing computation.

## The Fiber Data Type

The `Fiber` data type in Effect represents a "handle" on the execution of an effect.

Here is the general form of a `Fiber`:

```text
        ┌─── Represents the success type
        │        ┌─── Represents the error type
        │        │
        ▼        ▼
Fiber<Success, Error>
```

This type indicates that a fiber:

- Succeeds and returns a value of type `Success`
- Fails with an error of type `Error`

Fibers do not have an `Requirements` type parameter because they only execute effects that have already had their requirements provided to them.

## Forking Effects

You can create a new fiber by **forking** an effect. This starts the effect in a new fiber, and you receive a reference to that fiber.

**Example** (Forking a Fiber)

In this example, the Fibonacci calculation is forked into its own fiber, allowing it to run independently of the main fiber. The reference to the `fib10Fiber` can be used later to join or interrupt the fiber.

```ts

const fib = (n: number): Effect.Effect<number> =>
  n < 2
    ? Effect.succeed(n)
    : Effect.zipWith(fib(n - 1), fib(n - 2), (a, b) => a + b)

//      ┌─── Effect<RuntimeFiber<number, never>, never, never>
//      ▼
const fib10Fiber = Effect.fork(fib(10))
```

## Joining Fibers

One common operation with fibers is **joining** them. By using the `Fiber.join` function, you can wait for a fiber to complete and retrieve its result. The joined fiber will either succeed or fail, and the `Effect` returned by `join` reflects the outcome of the fiber.

**Example** (Joining a Fiber)

```ts

const fib = (n: number): Effect.Effect<number> =>
  n < 2
    ? Effect.succeed(n)
    : Effect.zipWith(fib(n - 1), fib(n - 2), (a, b) => a + b)

//      ┌─── Effect<RuntimeFiber<number, never>, never, never>
//      ▼
const fib10Fiber = Effect.fork(fib(10))

const program = Effect.gen(function* () {
  // Retrieve the fiber
  const fiber = yield* fib10Fiber
  // Join the fiber and get the result
  const n = yield* Fiber.join(fiber)
  console.log(n)
})

Effect.runFork(program) // Output: 55
```

## Awaiting Fibers

The `Fiber.await` function is a helpful tool when working with fibers. It allows you to wait for a fiber to complete and retrieve detailed information about how it finished. The result is encapsulated in an [Exit](/docs/data-types/exit/) value, which gives you insight into whether the fiber succeeded, failed, or was interrupted.

**Example** (Awaiting Fiber Completion)

```ts

const fib = (n: number): Effect.Effect<number> =>
  n < 2
    ? Effect.succeed(n)
    : Effect.zipWith(fib(n - 1), fib(n - 2), (a, b) => a + b)

//      ┌─── Effect<RuntimeFiber<number, never>, never, never>
//      ▼
const fib10Fiber = Effect.fork(fib(10))

const program = Effect.gen(function* () {
  // Retrieve the fiber
  const fiber = yield* fib10Fiber
  // Await its completion and get the Exit result
  const exit = yield* Fiber.await(fiber)
  console.log(exit)
})

Effect.runFork(program)
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: 55 }
*/
```

## Interruption Model

While developing concurrent applications, there are several cases that we need to interrupt the execution of other fibers, for example:

1. A parent fiber might start some child fibers to perform a task, and later the parent might decide that, it doesn't need the result of some or all of the child fibers.

2. Two or more fibers start race with each other. The fiber whose result is computed first wins, and all other fibers are no longer needed, and should be interrupted.

3. In interactive applications, a user may want to stop some already running tasks, such as clicking on the "stop" button to prevent downloading more files.

4. Computations that run longer than expected should be aborted by using timeout operations.

5. When we have an application that perform compute-intensive tasks based on the user inputs, if the user changes the input we should cancel the current task and perform another one.

### Polling vs. Asynchronous Interruption

When it comes to interrupting fibers, a naive approach is to allow one fiber to forcefully terminate another fiber. However, this approach is not ideal because it can leave shared state in an inconsistent and unreliable state if the target fiber is in the middle of modifying that state. Therefore, it does not guarantee internal consistency of the shared mutable state.

Instead, there are two popular and valid solutions to tackle this problem:

1. **Semi-asynchronous Interruption (Polling for Interruption)**: Imperative languages often employ polling as a semi-asynchronous signaling mechanism, such as Java. In this model, a fiber sends an interruption request to another fiber. The target fiber continuously polls the interrupt status and checks whether it has received any interruption requests from other fibers. If an interruption request is detected, the target fiber terminates itself as soon as possible.

   With this solution, the fiber itself handles critical sections. So, if a fiber is in the middle of a critical section and receives an interruption request, it ignores the interruption and defers its handling until after the critical section.

   However, one drawback of this approach is that if the programmer forgets to poll regularly, the target fiber can become unresponsive, leading to deadlocks. Additionally, polling a global flag is not aligned with the functional paradigm followed by Effect.

2. **Asynchronous Interruption**: In asynchronous interruption, a fiber is allowed to terminate another fiber. The target fiber is not responsible for polling the interrupt status. Instead, during critical sections, the target fiber disables the interruptibility of those regions. This is a purely functional solution that doesn't require polling a global state. Effect adopts this solution for its interruption model, which is a fully asynchronous signaling mechanism.

   This mechanism overcomes the drawback of forgetting to poll regularly. It is also fully compatible with the functional paradigm because in a purely functional computation, we can abort the computation at any point, except during critical sections where interruption is disabled.

### Interrupting Fibers

Fibers can be interrupted if their result is no longer needed. This action immediately stops the fiber and safely runs all finalizers to release any resources.

Like `Fiber.await`, the `Fiber.interrupt` function returns an [Exit](/docs/data-types/exit/) value that provides detailed information about how the fiber ended.

**Example** (Interrupting a Fiber)

```ts

const program = Effect.gen(function* () {
  // Fork a fiber that runs indefinitely, printing "Hi!"
  const fiber = yield* Effect.fork(
    Effect.forever(Effect.log("Hi!").pipe(Effect.delay("10 millis")))
  )
  yield* Effect.sleep("30 millis")
  // Interrupt the fiber and get an Exit value detailing how it finished
  const exit = yield* Fiber.interrupt(fiber)
  console.log(exit)
})

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#1 message=Hi!
timestamp=... level=INFO fiber=#1 message=Hi!
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Interrupt',
    fiberId: {
      _id: 'FiberId',
      _tag: 'Runtime',
      id: 0,
      startTimeMillis: ...
    }
  }
}
*/
```

By default, the effect returned by `Fiber.interrupt` waits until the fiber has fully terminated before resuming. This ensures that no new fibers are started before the previous ones have finished, a behavior known as "back-pressuring."

If you do not require this waiting behavior, you can fork the interruption itself, allowing the main program to proceed without waiting for the fiber to terminate:

**Example** (Forking an Interruption)

```ts

const program = Effect.gen(function* () {
  const fiber = yield* Effect.fork(
    Effect.forever(Effect.log("Hi!").pipe(Effect.delay("10 millis")))
  )
  yield* Effect.sleep("30 millis")
  const _ = yield* Effect.fork(Fiber.interrupt(fiber))
  console.log("Do something else...")
})

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#1 message=Hi!
timestamp=... level=INFO fiber=#1 message=Hi!
Do something else...
*/
```

There is also a shorthand for background interruption called `Fiber.interruptFork`.

```ts

const program = Effect.gen(function* () {
  const fiber = yield* Effect.fork(
    Effect.forever(Effect.log("Hi!").pipe(Effect.delay("10 millis")))
  )
  yield* Effect.sleep("30 millis")
  // const _ = yield* Effect.fork(Fiber.interrupt(fiber))
  const _ = yield* Fiber.interruptFork(fiber)
  console.log("Do something else...")
})

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#1 message=Hi!
timestamp=... level=INFO fiber=#1 message=Hi!
Do something else...
*/
```

> **Tip: Interrupting via Effect.interrupt**
  You can also interrupt fibers using the high-level API
  `Effect.interrupt`. For more details, refer to the [Effect.interrupt
  documentation](/docs/concurrency/basic-concurrency/#interruptions).


## Composing Fibers

The `Fiber.zip` and `Fiber.zipWith` functions allow you to combine two fibers into one. The resulting fiber will produce the results of both input fibers. If either fiber fails, the combined fiber will also fail.

**Example** (Combining Fibers with `Fiber.zip`)

In this example, both fibers run concurrently, and the results are combined into a tuple.

```ts

const program = Effect.gen(function* () {
  // Fork two fibers that each produce a string
  const fiber1 = yield* Effect.fork(Effect.succeed("Hi!"))
  const fiber2 = yield* Effect.fork(Effect.succeed("Bye!"))

  // Combine the two fibers using Fiber.zip
  const fiber = Fiber.zip(fiber1, fiber2)

  // Join the combined fiber and get the result as a tuple
  const tuple = yield* Fiber.join(fiber)
  console.log(tuple)
})

Effect.runFork(program)
/*
Output:
[ 'Hi!', 'Bye!' ]
*/
```

Another way to compose fibers is by using `Fiber.orElse`. This function allows you to provide an alternative fiber that will execute if the first one fails. If the first fiber succeeds, its result will be returned. If it fails, the second fiber will run instead, and its result will be returned regardless of its outcome.

**Example** (Providing a Fallback Fiber with `Fiber.orElse`)

```ts

const program = Effect.gen(function* () {
  // Fork a fiber that will fail
  const fiber1 = yield* Effect.fork(Effect.fail("Uh oh!"))
  // Fork another fiber that will succeed
  const fiber2 = yield* Effect.fork(Effect.succeed("Hurray!"))
  // If fiber1 fails, fiber2 will be used as a fallback
  const fiber = Fiber.orElse(fiber1, fiber2)
  const message = yield* Fiber.join(fiber)
  console.log(message)
})

Effect.runFork(program)
/*
Output:
Hurray!
*/
```

## Lifetime of Child Fibers

When we fork fibers, depending on how we fork them we can have four different lifetime strategies for the child fibers:

1. **Fork With Automatic Supervision**. If we use the ordinary `Effect.fork` operation, the child fiber will be automatically supervised by the parent fiber. The lifetime child fibers are tied to the lifetime of their parent fiber. This means that these fibers will be terminated either when they end naturally, or when their parent fiber is terminated.

2. **Fork in Global Scope (Daemon)**. Sometimes we want to run long-running background fibers that aren't tied to their parent fiber, and also we want to fork them in a global scope. Any fiber that is forked in global scope will become daemon fiber. This can be achieved by using the `Effect.forkDaemon` operator. As these fibers have no parent, they are not supervised, and they will be terminated when they end naturally, or when our application is terminated.

3. **Fork in Local Scope**. Sometimes, we want to run a background fiber that isn't tied to its parent fiber, but we want that fiber to live in the local scope. We can fork fibers in the local scope by using `Effect.forkScoped`. Such fibers can outlive their parent fiber (so they are not supervised by their parents), and they will be terminated when their life end or their local scope is closed.

4. **Fork in Specific Scope**. This is similar to the previous strategy, but we can have more fine-grained control over the lifetime of the child fiber by forking it in a specific scope. We can do this by using the `Effect.forkIn` operator.

### Fork with Automatic Supervision

Effect follows a **structured concurrency** model, where child fibers' lifetimes are tied to their parent. Simply put, the lifespan of a fiber depends on the lifespan of its parent fiber.

**Example** (Automatically Supervised Child Fiber)

In this scenario, the `parent` fiber spawns a `child` fiber that repeatedly prints a message every second.
The `child` fiber will be terminated when the `parent` fiber completes.

```ts

// Child fiber that logs a message repeatedly every second
const child = Effect.repeat(
  Console.log("child: still running!"),
  Schedule.fixed("1 second")
)

const parent = Effect.gen(function* () {
  console.log("parent: started!")
  // Child fiber is supervised by the parent
  yield* Effect.fork(child)
  yield* Effect.sleep("3 seconds")
  console.log("parent: finished!")
})

Effect.runFork(parent)
/*
Output:
parent: started!
child: still running!
child: still running!
child: still running!
parent: finished!
*/
```

This behavior can be extended to any level of nested fibers, ensuring a predictable and controlled fiber lifecycle.

### Fork in Global Scope (Daemon)

You can create a long-running background fiber using `Effect.forkDaemon`. This type of fiber, known as a daemon fiber, is not tied to the lifecycle of its parent fiber. Instead, its lifetime is linked to the global scope. A daemon fiber continues running even if its parent fiber is terminated and will only stop when the global scope is closed or the fiber completes naturally.

**Example** (Creating a Daemon Fiber)

This example shows how daemon fibers can continue running in the background even after the parent fiber has finished.

```ts

// Daemon fiber that logs a message repeatedly every second
const daemon = Effect.repeat(
  Console.log("daemon: still running!"),
  Schedule.fixed("1 second")
)

const parent = Effect.gen(function* () {
  console.log("parent: started!")
  // Daemon fiber running independently
  yield* Effect.forkDaemon(daemon)
  yield* Effect.sleep("3 seconds")
  console.log("parent: finished!")
})

Effect.runFork(parent)
/*
Output:
parent: started!
daemon: still running!
daemon: still running!
daemon: still running!
parent: finished!
daemon: still running!
daemon: still running!
daemon: still running!
daemon: still running!
daemon: still running!
...etc...
*/
```

Even if the parent fiber is interrupted, the daemon fiber will continue running independently.

**Example** (Interrupting the Parent Fiber)

In this example, interrupting the parent fiber doesn't affect the daemon fiber, which continues to run in the background.

```ts

// Daemon fiber that logs a message repeatedly every second
const daemon = Effect.repeat(
  Console.log("daemon: still running!"),
  Schedule.fixed("1 second")
)

const parent = Effect.gen(function* () {
  console.log("parent: started!")
  // Daemon fiber running independently
  yield* Effect.forkDaemon(daemon)
  yield* Effect.sleep("3 seconds")
  console.log("parent: finished!")
}).pipe(Effect.onInterrupt(() => Console.log("parent: interrupted!")))

// Program that interrupts the parent fiber after 2 seconds
const program = Effect.gen(function* () {
  const fiber = yield* Effect.fork(parent)
  yield* Effect.sleep("2 seconds")
  yield* Fiber.interrupt(fiber) // Interrupt the parent fiber
})

Effect.runFork(program)
/*
Output:
parent: started!
daemon: still running!
daemon: still running!
parent: interrupted!
daemon: still running!
daemon: still running!
daemon: still running!
daemon: still running!
daemon: still running!
...etc...
*/
```

### Fork in Local Scope

Sometimes we want to create a fiber that is tied to a local [scope](/docs/resource-management/scope/), meaning its lifetime is not dependent on its parent fiber but is bound to the local scope in which it was forked. This can be done using the `Effect.forkScoped` operator.

Fibers created with `Effect.forkScoped` can outlive their parent fibers and will only be terminated when the local scope itself is closed.

**Example** (Forking a Fiber in a Local Scope)

In this example, the `child` fiber continues to run beyond the lifetime of the `parent` fiber. The `child` fiber is tied to the local scope and will be terminated only when the scope ends.

```ts

// Child fiber that logs a message repeatedly every second
const child = Effect.repeat(
  Console.log("child: still running!"),
  Schedule.fixed("1 second")
)

//      ┌─── Effect<void, never, Scope>
//      ▼
const parent = Effect.gen(function* () {
  console.log("parent: started!")
  // Child fiber attached to local scope
  yield* Effect.forkScoped(child)
  yield* Effect.sleep("3 seconds")
  console.log("parent: finished!")
})

// Program runs within a local scope
const program = Effect.scoped(
  Effect.gen(function* () {
    console.log("Local scope started!")
    yield* Effect.fork(parent)
    // Scope lasts for 5 seconds
    yield* Effect.sleep("5 seconds")
    console.log("Leaving the local scope!")
  })
)

Effect.runFork(program)
/*
Output:
Local scope started!
parent: started!
child: still running!
child: still running!
child: still running!
parent: finished!
child: still running!
child: still running!
Leaving the local scope!
*/
```

### Fork in Specific Scope

There are some cases where we need more fine-grained control, so we want to fork a fiber in a specific scope.
We can use the `Effect.forkIn` operator which takes the target scope as an argument.

**Example** (Forking a Fiber in a Specific Scope)

In this example, the `child` fiber is forked into the `outerScope`, allowing it to outlive the inner scope but still be terminated when the `outerScope` is closed.

```ts

// Child fiber that logs a message repeatedly every second
const child = Effect.repeat(
  Console.log("child: still running!"),
  Schedule.fixed("1 second")
)

const program = Effect.scoped(
  Effect.gen(function* () {
    yield* Effect.addFinalizer(() =>
      Console.log("The outer scope is about to be closed!")
    )

    // Capture the outer scope
    const outerScope = yield* Effect.scope

    // Create an inner scope
    yield* Effect.scoped(
      Effect.gen(function* () {
        yield* Effect.addFinalizer(() =>
          Console.log("The inner scope is about to be closed!")
        )
        // Fork the child fiber in the outer scope
        yield* Effect.forkIn(child, outerScope)
        yield* Effect.sleep("3 seconds")
      })
    )

    yield* Effect.sleep("5 seconds")
  })
)

Effect.runFork(program)
/*
Output:
child: still running!
child: still running!
child: still running!
The inner scope is about to be closed!
child: still running!
child: still running!
child: still running!
child: still running!
child: still running!
child: still running!
The outer scope is about to be closed!
*/
```

## When do Fibers run?

Forked fibers begin execution after the current fiber completes or yields.

**Example** (Late Fiber Start Captures Only One Value)

In the following example, the `changes` stream only captures a single value, `2`.
This happens because the fiber created by `Effect.fork` starts **after** the value is updated.

```ts

const program = Effect.gen(function* () {
  const ref = yield* SubscriptionRef.make(0)
  yield* ref.changes.pipe(
    // Log each change in SubscriptionRef
    Stream.tap((n) => Console.log(`SubscriptionRef changed to ${n}`)),
    Stream.runDrain,
    // Fork a fiber to run the stream
    Effect.fork
  )
  yield* SubscriptionRef.set(ref, 1)
  yield* SubscriptionRef.set(ref, 2)
})

Effect.runFork(program)
/*
Output:
SubscriptionRef changed to 2
*/
```

If you add a short delay with `Effect.sleep()` or call `Effect.yieldNow()`, you allow the current fiber to yield. This gives the forked fiber enough time to start and collect all values before they are updated.

> **Caution: Fiber Execution is Non-Deterministic**
  Keep in mind that the timing of fiber execution is not deterministic,
  and many factors can affect when a fiber starts. Do not rely on the idea
  that a single yield always ensures your fiber begins at a particular
  time.


**Example** (Delay Allows Fiber to Capture All Values)

```ts

const program = Effect.gen(function* () {
  const ref = yield* SubscriptionRef.make(0)
  yield* ref.changes.pipe(
    // Log each change in SubscriptionRef
    Stream.tap((n) => Console.log(`SubscriptionRef changed to ${n}`)),
    Stream.runDrain,
    // Fork a fiber to run the stream
    Effect.fork
  )

  // Allow the fiber a chance to start
  yield* Effect.sleep("100 millis")

  yield* SubscriptionRef.set(ref, 1)
  yield* SubscriptionRef.set(ref, 2)
})

Effect.runFork(program)
/*
Output:
SubscriptionRef changed to 0
SubscriptionRef changed to 1
SubscriptionRef changed to 2
*/
```


---

# [Deferred](https://effect.website/docs/concurrency/deferred/)

## Overview

A `Deferred<Success, Error>` is a specialized subtype of `Effect` that acts like a one-time variable with some unique characteristics. It can only be completed once, making it a useful tool for managing asynchronous operations and synchronization between different parts of your program.

A deferred is essentially a synchronization primitive that represents a value that may not be available right away. When you create a deferred, it starts out empty. Later, it can be completed with either a success value `Success` or an error value `Error`:

```text
           ┌─── Represents the success type
           │        ┌─── Represents the error type
           │        │
           ▼        ▼
Deferred<Success, Error>
```

Once completed, it cannot be changed again.

When a fiber calls `Deferred.await`, it will pause until the deferred is completed. While the fiber is waiting, it doesn't block the thread, it only blocks semantically. This means other fibers can still run, ensuring efficient concurrency.

A deferred is conceptually similar to JavaScript's `Promise`.
The key difference is that it supports both success and error types, giving more type safety.

## Creating a Deferred

A deferred can be created using the `Deferred.make` constructor. This returns an effect that represents the creation of the deferred. Since the creation of a deferred involves memory allocation, it must be done within an effect to ensure safe management of resources.

**Example** (Creating a Deferred)

```ts

//      ┌─── Effect<Deferred<string, Error>>
//      ▼
const deferred = Deferred.make<string, Error>()
```

## Awaiting

To retrieve a value from a deferred, you can use `Deferred.await`. This operation suspends the calling fiber until the deferred is completed with a value or an error.

```ts

//      ┌─── Effect<Deferred<string, Error>, never, never>
//      ▼
const deferred = Deferred.make<string, Error>()

//      ┌─── Effect<string, Error, never>
//      ▼
const value = deferred.pipe(Effect.andThen(Deferred.await))
```

## Completing

You can complete a deferred in several ways, depending on whether you want to succeed, fail, or interrupt the waiting fibers:

| API                     | Description                                                                                                     |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- |
| `Deferred.succeed`      | Completes the deferred successfully with a value.                                                               |
| `Deferred.done`         | Completes the deferred with an [Exit](/docs/data-types/exit/) value.                                            |
| `Deferred.complete`     | Completes the deferred with the result of an effect.                                                            |
| `Deferred.completeWith` | Completes the deferred with an effect. This effect will be executed by each waiting fiber, so use it carefully. |
| `Deferred.fail`         | Fails the deferred with an error.                                                                               |
| `Deferred.die`          | Defects the deferred with a user-defined error.                                                                 |
| `Deferred.failCause`    | Fails or defects the deferred with a [Cause](/docs/data-types/cause/).                                          |
| `Deferred.interrupt`    | Interrupts the deferred, forcefully stopping or interrupting the waiting fibers.                                |

**Example** (Completing a Deferred with Success)

```ts

const program = Effect.gen(function* () {
  const deferred = yield* Deferred.make<number, string>()

  // Complete the Deferred successfully
  yield* Deferred.succeed(deferred, 1)

  // Awaiting the Deferred to get its value
  const value = yield* Deferred.await(deferred)

  console.log(value)
})

Effect.runFork(program)
// Output: 1
```

Completing a deferred produces an `Effect<boolean>`. This effect returns `true` if the deferred was successfully completed, and `false` if it had already been completed previously. This can be useful for tracking the state of the deferred.

**Example** (Checking Completion Status)

```ts

const program = Effect.gen(function* () {
  const deferred = yield* Deferred.make<number, string>()

  // Attempt to fail the Deferred
  const firstAttempt = yield* Deferred.fail(deferred, "oh no!")

  // Attempt to succeed after it has already been completed
  const secondAttempt = yield* Deferred.succeed(deferred, 1)

  console.log([firstAttempt, secondAttempt])
})

Effect.runFork(program)
// Output: [ true, false ]
```

## Checking Completion Status

Sometimes, you might need to check if a deferred has been completed without suspending the fiber. This can be done using the `Deferred.poll` method. Here's how it works:

- `Deferred.poll` returns an `Option<Effect<A, E>>`:
  - If the `Deferred` is incomplete, it returns `None`.
  - If the `Deferred` is complete, it returns `Some`, which contains the result or error.

Additionally, you can use the `Deferred.isDone` function to check if a deferred has been completed. This method returns an `Effect<boolean>`, which evaluates to `true` if the `Deferred` is completed, allowing you to quickly check its state.

**Example** (Polling and Checking Completion Status)

```ts

const program = Effect.gen(function* () {
  const deferred = yield* Deferred.make<number, string>()

  // Polling the Deferred to check if it's completed
  const done1 = yield* Deferred.poll(deferred)

  // Checking if the Deferred has been completed
  const done2 = yield* Deferred.isDone(deferred)

  console.log([done1, done2])
})

Effect.runFork(program)
/*
Output:
[ { _id: 'Option', _tag: 'None' }, false ]
*/
```

## Common Use Cases

`Deferred` becomes useful when you need to wait for something specific to happen in your program.
It's ideal for scenarios where you want one part of your code to signal another part when it's ready.

Here are a few common use cases:

| **Use Case**             | **Description**                                                                                                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Coordinating Fibers**  | When you have multiple concurrent tasks and need to coordinate their actions, `Deferred` can help one fiber signal to another when it has completed its task.             |
| **Synchronization**      | Anytime you want to ensure that one piece of code doesn't proceed until another piece of code has finished its work, `Deferred` can provide the synchronization you need. |
| **Handing Over Work**    | You can use `Deferred` to hand over work from one fiber to another. For example, one fiber can prepare some data, and then a second fiber can continue processing it.     |
| **Suspending Execution** | When you want a fiber to pause its execution until some condition is met, a `Deferred` can be used to block it until the condition is satisfied.                          |

**Example** (Using Deferred to Coordinate Two Fibers)

In this example, a deferred is used to pass a value between two fibers.

By running both fibers concurrently and using the deferred as a synchronization point, we can ensure that `fiberB` only proceeds after `fiberA` has completed its task.

```ts

const program = Effect.gen(function* () {
  const deferred = yield* Deferred.make<string, string>()

  // Completes the Deferred with a value after a delay
  const taskA = Effect.gen(function* () {
    console.log("Starting task to complete the Deferred")
    yield* Effect.sleep("1 second")
    console.log("Completing the Deferred")
    return yield* Deferred.succeed(deferred, "hello world")
  })

  // Waits for the Deferred and prints the value
  const taskB = Effect.gen(function* () {
    console.log("Starting task to get the value from the Deferred")
    const value = yield* Deferred.await(deferred)
    console.log("Got the value from the Deferred")
    return value
  })

  // Run both fibers concurrently
  const fiberA = yield* Effect.fork(taskA)
  const fiberB = yield* Effect.fork(taskB)

  // Wait for both fibers to complete
  const both = yield* Fiber.join(Fiber.zip(fiberA, fiberB))

  console.log(both)
})

Effect.runFork(program)
/*
Starting task to complete the Deferred
Starting task to get the value from the Deferred
Completing the Deferred
Got the value from the Deferred
[ true, 'hello world' ]
*/
```


---

# [Latch](https://effect.website/docs/concurrency/latch/)

## Overview

A Latch is a synchronization tool that works like a gate, letting fibers wait until the latch is opened before they continue. The latch can be either open or closed:

- When closed, fibers that reach the latch wait until it opens.
- When open, fibers pass through immediately.

Once opened, a latch typically stays open, although you can close it again if needed

Imagine an application that processes requests only after completing an initial setup (like loading configuration data or establishing a database connection).
You can create a latch in a closed state while the setup is happening.
Any incoming requests, represented as fibers, would wait at the latch until it opens.
Once the setup is finished, you call `latch.open` so the requests can proceed.

## The Latch Interface

A `Latch` includes several operations that let you control and observe its state:

| Operation  | Description                                                                                              |
| ---------- | -------------------------------------------------------------------------------------------------------- |
| `whenOpen` | Runs a given effect only if the latch is open, otherwise, waits until it opens.                          |
| `open`     | Opens the latch so that any waiting fibers can proceed.                                                  |
| `close`    | Closes the latch, causing fibers to wait when they reach this latch in the future.                       |
| `await`    | Suspends the current fiber until the latch is opened. If the latch is already open, returns immediately. |
| `release`  | Allows waiting fibers to continue without permanently opening the latch.                                 |

## Creating a Latch

Use the `Effect.makeLatch` function to create a latch in an open or closed state by passing a boolean. The default is `false`, which means it starts closed.

**Example** (Creating and Using a Latch)

In this example, the latch starts closed. A fiber logs "open sesame" only when the latch is open. After waiting for one second, the latch is opened, releasing the fiber:

```ts

// A generator function that demonstrates latch usage
const program = Effect.gen(function* () {
  // Create a latch, starting in the closed state
  const latch = yield* Effect.makeLatch()

  // Fork a fiber that logs "open sesame" only when the latch is open
  const fiber = yield* Console.log("open sesame").pipe(
    latch.whenOpen, // Waits for the latch to open
    Effect.fork // Fork the effect into a new fiber
  )

  // Wait for 1 second
  yield* Effect.sleep("1 second")

  // Open the latch, releasing the fiber
  yield* latch.open

  // Wait for the forked fiber to finish
  yield* fiber.await
})

Effect.runFork(program)
// Output: open sesame (after 1 second)
```

## Latch vs Semaphore

A latch is good when you have a one-time event or condition that determines whether fibers can proceed. For example, you might use a latch to block all fibers until a setup step is finished, and then open the latch so everyone can continue.

A [semaphore](/docs/concurrency/semaphore/) with one lock (often called a binary semaphore or a mutex) is usually for mutual exclusion: it ensures that only one fiber at a time accesses a shared resource or section of code. Once a fiber acquires the lock, no other fiber can enter the protected area until the lock is released.

In short:

- Use a **latch** if you're gating a set of fibers on a specific event ("Wait here until this becomes true").
- Use a **semaphore (with one lock)** if you need to ensure only one fiber at a time is in a critical section or using a shared resource.


---

# [PubSub](https://effect.website/docs/concurrency/pubsub/)

## Overview


A `PubSub` serves as an asynchronous message hub, allowing publishers to send messages that can be received by all current subscribers.

Unlike a [Queue](/docs/concurrency/queue/), where each value is delivered to only one consumer, a `PubSub` broadcasts each published message to all subscribers. This makes `PubSub` ideal for scenarios requiring message broadcasting rather than load distribution.

## Basic Operations

A `PubSub<A>` stores messages of type `A` and provides two fundamental operations:

| API                | Description                                                                                                                                                                                                                           |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PubSub.publish`   | Sends a message of type `A` to the `PubSub`, returning an effect indicating if the message was successfully published.                                                                                                                |
| `PubSub.subscribe` | Creates a scoped effect that allows subscription to the `PubSub`, automatically unsubscribing when the scope ends. Subscribers receive messages through a [Dequeue](/docs/concurrency/queue/#dequeue) which holds published messages. |

**Example** (Publishing a Message to Multiple Subscribers)

```ts

const program = Effect.scoped(
  Effect.gen(function* () {
    const pubsub = yield* PubSub.bounded<string>(2)

    // Two subscribers
    const dequeue1 = yield* PubSub.subscribe(pubsub)
    const dequeue2 = yield* PubSub.subscribe(pubsub)

    // Publish a message to the pubsub
    yield* PubSub.publish(pubsub, "Hello from a PubSub!")

    // Each subscriber receives the message
    console.log("Subscriber 1: " + (yield* Queue.take(dequeue1)))
    console.log("Subscriber 2: " + (yield* Queue.take(dequeue2)))
  })
)

Effect.runFork(program)
/*
Output:
Subscriber 1: Hello from a PubSub!
Subscriber 2: Hello from a PubSub!
*/
```

> **Caution: Subscribe Before Publishing**
  A subscriber only receives messages published while it is actively
  subscribed. To ensure a subscriber receives a particular message,
  establish the subscription before publishing the message.


## Creating a PubSub

### Bounded PubSub

A bounded `PubSub` applies back pressure to publishers when it reaches capacity, suspending additional publishing until space becomes available.

Back pressure ensures that all subscribers receive all messages while they are subscribed. However, it can lead to slower message delivery if a subscriber is slow.

**Example** (Bounded PubSub Creation)

```ts

// Creates a bounded PubSub with a capacity of 2
const boundedPubSub = PubSub.bounded<string>(2)
```

### Dropping PubSub

A dropping `PubSub` discards new values when full. The `PubSub.publish` operation returns `false` if the message is dropped.

In a dropping pubsub, publishers can continue to publish new values, but subscribers are not guaranteed to receive all messages.

**Example** (Dropping PubSub Creation)

```ts

// Creates a dropping PubSub with a capacity of 2
const droppingPubSub = PubSub.dropping<string>(2)
```

### Sliding PubSub

A sliding `PubSub` removes the oldest message to make space for new ones, ensuring that publishing never blocks.

A sliding pubsub prevents slow subscribers from impacting the message delivery rate. However, there's still a risk that slow subscribers may miss some messages.

**Example** (Sliding PubSub Creation)

```ts

// Creates a sliding PubSub with a capacity of 2
const slidingPubSub = PubSub.sliding<string>(2)
```

### Unbounded PubSub

An unbounded `PubSub` has no capacity limit, so publishing always succeeds immediately.

Unbounded pubsubs guarantee that all subscribers receive all messages without slowing down message delivery. However, they can grow indefinitely if messages are published faster than they are consumed.

Generally, it's recommended to use bounded, dropping, or sliding pubsubs unless you have specific use cases for unbounded pubsubs.

**Example**

```ts

// Creates an unbounded PubSub with unlimited capacity
const unboundedPubSub = PubSub.unbounded<string>()
```

## Operators On PubSubs

### publishAll

The `PubSub.publishAll` function lets you publish multiple values to the pubsub at once.

**Example** (Publishing Multiple Messages)

```ts

const program = Effect.scoped(
  Effect.gen(function* () {
    const pubsub = yield* PubSub.bounded<string>(2)
    const dequeue = yield* PubSub.subscribe(pubsub)
    yield* PubSub.publishAll(pubsub, ["Message 1", "Message 2"])
    console.log(yield* Queue.takeAll(dequeue))
  })
)

Effect.runFork(program)
/*
Output:
{ _id: 'Chunk', values: [ 'Message 1', 'Message 2' ] }
*/
```

### capacity / size

You can check the capacity and current size of a pubsub using `PubSub.capacity` and `PubSub.size`, respectively.

Note that `PubSub.capacity` returns a `number` because the capacity is set at pubsub creation and never changes.
In contrast, `PubSub.size` returns an effect that determines the current size of the pubsub since the number of messages in the pubsub can change over time.

**Example** (Retrieving PubSub Capacity and Size)

```ts

const program = Effect.gen(function* () {
  const pubsub = yield* PubSub.bounded<number>(2)
  console.log(`capacity: ${PubSub.capacity(pubsub)}`)
  console.log(`size: ${yield* PubSub.size(pubsub)}`)
})

Effect.runFork(program)
/*
Output:
capacity: 2
size: 0
*/
```

### Shutting Down a PubSub

To shut down a pubsub, use `PubSub.shutdown`. You can also verify if it has been shut down with `PubSub.isShutdown`, or wait for the shutdown to complete with `PubSub.awaitShutdown`. Shutting down a pubsub also terminates all associated queues, ensuring that the shutdown signal is effectively communicated.

## PubSub as an Enqueue

`PubSub` operators mirror those of [Queue](/docs/concurrency/queue/) with the main difference being that `PubSub.publish` and `PubSub.subscribe` are used in place of `Queue.offer` and `Queue.take`. If you're already familiar with using a `Queue`, you’ll find `PubSub` straightforward.

Essentially, a `PubSub` can be seen as a `Enqueue` that only allows writes:

```ts
import type { Queue } from "effect"

interface PubSub<A> extends Queue.Enqueue<A> {}
```

Here, the `Enqueue` type refers to a queue that only accepts enqueues (or writes). Any value enqueued here is published to the pubsub, and operations like shutdown will also affect the pubsub.

This design makes `PubSub` highly flexible, letting you use it anywhere you need a `Enqueue` that only accepts published values.


---

# [Queue](https://effect.website/docs/concurrency/queue/)

## Overview

A `Queue` is a lightweight in-memory queue with built-in back-pressure, enabling asynchronous, purely-functional, and type-safe handling of data.

## Basic Operations

A `Queue<A>` stores values of type `A` and provides two fundamental operations:

| API           | Description                                          |
| ------------- | ---------------------------------------------------- |
| `Queue.offer` | Adds a value of type `A` to the queue.               |
| `Queue.take`  | Removes and returns the oldest value from the queue. |

**Example** (Adding and Retrieving an Item)

```ts

const program = Effect.gen(function* () {
  // Creates a bounded queue with capacity 100
  const queue = yield* Queue.bounded<number>(100)
  // Adds 1 to the queue
  yield* Queue.offer(queue, 1)
  // Retrieves and removes the oldest value
  const value = yield* Queue.take(queue)
  return value
})

Effect.runPromise(program).then(console.log)
// Output: 1
```

## Creating a Queue

Queues can be **bounded** (with a specified capacity) or **unbounded** (without a limit). Different types of queues handle new values differently when they reach capacity.

### Bounded Queue

A bounded queue applies back-pressure when full, meaning any `Queue.offer` operation will suspend until there is space.

**Example** (Creating a Bounded Queue)

```ts

// Creating a bounded queue with a capacity of 100
const boundedQueue = Queue.bounded<number>(100)
```

### Dropping Queue

A dropping queue discards new values if the queue is full.

**Example** (Creating a Dropping Queue)

```ts

// Creating a dropping queue with a capacity of 100
const droppingQueue = Queue.dropping<number>(100)
```

### Sliding Queue

A sliding queue removes old values to make space for new ones when it reaches capacity.

**Example** (Creating a Sliding Queue)

```ts

// Creating a sliding queue with a capacity of 100
const slidingQueue = Queue.sliding<number>(100)
```

### Unbounded Queue

An unbounded queue has no capacity limit, allowing unrestricted additions.

**Example** (Creating an Unbounded Queue)

```ts

// Creates an unbounded queue without a capacity limit
const unboundedQueue = Queue.unbounded<number>()
```

## Adding Items to a Queue

### offer

Use `Queue.offer` to add values to the queue.

**Example** (Adding a Single Item)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<number>(100)
  // Adds 1 to the queue
  yield* Queue.offer(queue, 1)
})
```

When using a back-pressured queue, `Queue.offer` suspends if the queue is full. To avoid blocking the main fiber, you can fork the `Queue.offer` operation.

**Example** (Handling a Full Queue with `Effect.fork`)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<number>(1)
  // Fill the queue with one item
  yield* Queue.offer(queue, 1)
  // Attempting to add a second item will suspend as the queue is full
  const fiber = yield* Effect.fork(Queue.offer(queue, 2))
  // Empties the queue to make space
  yield* Queue.take(queue)
  // Joins the fiber, completing the suspended offer
  yield* Fiber.join(fiber)
  // Returns the size of the queue after additions
  return yield* Queue.size(queue)
})

Effect.runPromise(program).then(console.log)
// Output: 1
```

### offerAll

You can also add multiple items at once using `Queue.offerAll`.

**Example** (Adding Multiple Items)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<number>(100)
  const items = Array.range(1, 10)
  // Adds all items to the queue at once
  yield* Queue.offerAll(queue, items)
  // Returns the size of the queue after additions
  return yield* Queue.size(queue)
})

Effect.runPromise(program).then(console.log)
// Output: 10
```

## Consuming Items from a Queue

### take

The `Queue.take` operation removes and returns the oldest item from the queue. If the queue is empty, `Queue.take` will suspend and only resume when an item is added. To prevent blocking, you can fork the `Queue.take` operation into a new fiber.

**Example** (Waiting for an Item in a Fiber)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<string>(100)
  // This take operation will suspend because the queue is empty
  const fiber = yield* Effect.fork(Queue.take(queue))
  // Adds an item to the queue
  yield* Queue.offer(queue, "something")
  // Joins the fiber to get the result of the take operation
  const value = yield* Fiber.join(fiber)
  return value
})

Effect.runPromise(program).then(console.log)
// Output: something
```

### poll

To retrieve the queue's first item without suspending, use `Queue.poll`. If the queue is empty, `Queue.poll` returns `None`; if it has an item, it wraps it in `Some`.

**Example** (Polling an Item)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<number>(100)
  // Adds items to the queue
  yield* Queue.offer(queue, 10)
  yield* Queue.offer(queue, 20)
  // Retrieves the first item if available
  const head = yield* Queue.poll(queue)
  return head
})

Effect.runPromise(program).then(console.log)
/*
Output:
{
  _id: "Option",
  _tag: "Some",
  value: 10
}
*/
```

### takeUpTo

To retrieve multiple items, use `Queue.takeUpTo`, which returns up to the specified number of items.
If there aren't enough items, it returns all available items without waiting for more.

This function is particularly useful for batch processing when an exact number of items is not required. It ensures the program continues working with whatever data is currently available.

If you need to wait for an exact number of items before proceeding, consider using [takeN](#taken).

**Example** (Taking Up to N Items)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<number>(100)

  // Adds items to the queue
  yield* Queue.offer(queue, 1)
  yield* Queue.offer(queue, 2)
  yield* Queue.offer(queue, 3)

  // Retrieves up to 2 items
  const chunk = yield* Queue.takeUpTo(queue, 2)
  console.log(chunk)

  return "some result"
})

Effect.runPromise(program).then(console.log)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2 ] }
some result
*/
```

### takeN

Takes a specified number of elements from a queue. If the queue does not contain enough elements, the operation suspends until the required number of elements become available.

This function is useful for scenarios where processing requires an exact number of items at a time, ensuring that the operation does not proceed until the batch is complete.

**Example** (Taking a Fixed Number of Items)

```ts

const program = Effect.gen(function* () {
  // Create a queue that can hold up to 100 elements
  const queue = yield* Queue.bounded<number>(100)

  // Fork a fiber that attempts to take 3 items from the queue
  const fiber = yield* Effect.fork(
    Effect.gen(function* () {
      console.log("Attempting to take 3 items from the queue...")
      const chunk = yield* Queue.takeN(queue, 3)
      console.log(`Successfully took 3 items: ${chunk}`)
    })
  )

  // Offer only 2 items initially
  yield* Queue.offer(queue, 1)
  yield* Queue.offer(queue, 2)
  console.log(
    "Offered 2 items. The fiber is now waiting for the 3rd item..."
  )

  // Simulate some delay
  yield* Effect.sleep("2 seconds")

  // Offer the 3rd item, which will unblock the takeN call
  yield* Queue.offer(queue, 3)
  console.log("Offered the 3rd item, which should unblock the fiber.")

  // Wait for the fiber to finish
  yield* Fiber.join(fiber)
  return "some result"
})

Effect.runPromise(program).then(console.log)
/*
Output:
Offered 2 items. The fiber is now waiting for the 3rd item...
Attempting to take 3 items from the queue...
Offered the 3rd item, which should unblock the fiber.
Successfully took 3 items: {
  "_id": "Chunk",
  "values": [
    1,
    2,
    3
  ]
}
some result
*/
```

### takeAll

To retrieve all items from the queue at once, use `Queue.takeAll`. This operation completes immediately, returning an empty collection if the queue is empty.

**Example** (Taking All Items)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<number>(100)
  // Adds items to the queue
  yield* Queue.offer(queue, 10)
  yield* Queue.offer(queue, 20)
  yield* Queue.offer(queue, 30)
  // Retrieves all items from the queue
  const chunk = yield* Queue.takeAll(queue)
  return chunk
})

Effect.runPromise(program).then(console.log)
/*
Output:
{
  _id: "Chunk",
  values: [ 10, 20, 30 ]
}
*/
```

## Shutting Down a Queue

### shutdown

The `Queue.shutdown` operation allows you to interrupt all fibers that are currently suspended on `offer*` or `take*` operations. This action also empties the queue and makes any future `offer*` and `take*` calls terminate immediately.

**Example** (Interrupting Fibers on Queue Shutdown)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<number>(3)
  // Forks a fiber that waits to take an item from the queue
  const fiber = yield* Effect.fork(Queue.take(queue))
  // Shuts down the queue, interrupting the fiber
  yield* Queue.shutdown(queue)
  // Joins the interrupted fiber
  yield* Fiber.join(fiber)
})
```

### awaitShutdown

The `Queue.awaitShutdown` operation can be used to run an effect when the queue shuts down. It waits until the queue is closed and resumes immediately if the queue is already shut down.

**Example** (Waiting for Queue Shutdown)

```ts

const program = Effect.gen(function* () {
  const queue = yield* Queue.bounded<number>(3)
  // Forks a fiber to await queue shutdown and log a message
  const fiber = yield* Effect.fork(
    Queue.awaitShutdown(queue).pipe(
      Effect.andThen(Console.log("shutting down"))
    )
  )
  // Shuts down the queue, triggering the await in the fiber
  yield* Queue.shutdown(queue)
  yield* Fiber.join(fiber)
})

Effect.runPromise(program)
// Output: shutting down
```

## Offer-only / Take-only Queues

Sometimes, you might want certain parts of your code to only add values to a queue (`Enqueue`) or only retrieve values from a queue (`Dequeue`). Effect provides interfaces to enforce these specific capabilities.

### Enqueue

All methods for adding values to a queue are defined by the `Enqueue` interface. This restricts the queue to only offer operations.

**Example** (Restricting Queue to Offer-only Operations)

```ts

const send = (offerOnlyQueue: Queue.Enqueue<number>, value: number) => {
  // This queue is restricted to offer operations only

  // Error: cannot use take on an offer-only queue
// @errors: 2345
  Queue.take(offerOnlyQueue)

  // Valid offer operation
  return Queue.offer(offerOnlyQueue, value)
}
```

### Dequeue

Similarly, all methods for retrieving values from a queue are defined by the `Dequeue` interface, which restricts the queue to only take operations.

**Example** (Restricting Queue to Take-only Operations)

```ts

const receive = (takeOnlyQueue: Queue.Dequeue<number>) => {
  // This queue is restricted to take operations only

  // Error: cannot use offer on a take-only queue
// @errors: 2345
  Queue.offer(takeOnlyQueue, 1)

  // Valid take operation
  return Queue.take(takeOnlyQueue)
}
```

The `Queue` type combines both `Enqueue` and `Dequeue`, so you can easily pass it to different parts of your code, enforcing only `Enqueue` or `Dequeue` behaviors as needed.

**Example** (Using Offer-only and Take-only Queues Together)

```ts

const send = (offerOnlyQueue: Queue.Enqueue<number>, value: number) => {
  return Queue.offer(offerOnlyQueue, value)
}

const receive = (takeOnlyQueue: Queue.Dequeue<number>) => {
  return Queue.take(takeOnlyQueue)
}

const program = Effect.gen(function* () {
  const queue = yield* Queue.unbounded<number>()

  // Add values to the queue
  yield* send(queue, 1)
  yield* send(queue, 2)

  // Retrieve values from the queue
  console.log(yield* receive(queue))
  console.log(yield* receive(queue))
})

Effect.runFork(program)
/*
Output:
1
2
*/
```


---

# [Semaphore](https://effect.website/docs/concurrency/semaphore/)

## Overview


A semaphore is a synchronization mechanism used to manage access to a shared resource. In Effect, semaphores help control resource access or coordinate tasks within asynchronous, concurrent operations.

A semaphore acts as a generalized mutex, allowing a set number of **permits** to be held and released concurrently. Permits act like tickets, giving tasks or fibers controlled access to a shared resource. When no permits are available, tasks trying to acquire one will wait until a permit is released.

## Creating a Semaphore

The `Effect.makeSemaphore` function initializes a semaphore with a specified number of permits.
Each permit allows one task to access a resource or perform an operation concurrently, and multiple permits enable a configurable level of concurrency.

**Example** (Creating a Semaphore with 3 Permits)

```ts

// Create a semaphore with 3 permits
const mutex = Effect.makeSemaphore(3)
```

## withPermits

The `withPermits` method lets you specify the number of permits required to run an effect. Once the specified permits are available, it runs the effect, automatically releasing the permits when the task completes.

**Example** (Forcing Sequential Task Execution with a One-Permit Semaphore)

In this example, three tasks are started concurrently, but they run sequentially because the one-permit semaphore only allows one task to proceed at a time.

```ts

const task = Effect.gen(function* () {
  yield* Effect.log("start")
  yield* Effect.sleep("2 seconds")
  yield* Effect.log("end")
})

const program = Effect.gen(function* () {
  const mutex = yield* Effect.makeSemaphore(1)

  // Wrap the task to require one permit, forcing sequential execution
  const semTask = mutex
    .withPermits(1)(task)
    .pipe(Effect.withLogSpan("elapsed"))

  // Run 3 tasks concurrently, but they execute sequentially
  // due to the one-permit semaphore
  yield* Effect.all([semTask, semTask, semTask], {
    concurrency: "unbounded"
  })
})

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#1 message=start elapsed=3ms
timestamp=... level=INFO fiber=#1 message=end elapsed=2010ms
timestamp=... level=INFO fiber=#2 message=start elapsed=2012ms
timestamp=... level=INFO fiber=#2 message=end elapsed=4017ms
timestamp=... level=INFO fiber=#3 message=start elapsed=4018ms
timestamp=... level=INFO fiber=#3 message=end elapsed=6026ms
*/
```

**Example** (Using Multiple Permits to Control Concurrent Task Execution)

In this example, we create a semaphore with five permits and use `withPermits(n)` to allocate a different number of permits for each task:

```ts

const program = Effect.gen(function* () {
  const mutex = yield* Effect.makeSemaphore(5)

  const tasks = [1, 2, 3, 4, 5].map((n) =>
    mutex
      .withPermits(n)(
        Effect.delay(Effect.log(`process: ${n}`), "2 seconds")
      )
      .pipe(Effect.withLogSpan("elapsed"))
  )

  yield* Effect.all(tasks, { concurrency: "unbounded" })
})

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#1 message="process: 1" elapsed=2011ms
timestamp=... level=INFO fiber=#2 message="process: 2" elapsed=2017ms
timestamp=... level=INFO fiber=#3 message="process: 3" elapsed=4020ms
timestamp=... level=INFO fiber=#4 message="process: 4" elapsed=6025ms
timestamp=... level=INFO fiber=#5 message="process: 5" elapsed=8034ms
*/
```

> **Note: Permit Release Guarantee**
  The `withPermits` method guarantees that permits are released after each
  task, even if the task fails or is interrupted.



---


## Common Mistakes

**Incorrect (Promise.all without cancellation):**

```ts
const results = await Promise.all([fetchA(), fetchB()])
// If fetchA fails, fetchB continues running wastefully
```

**Correct (Effect.all with structured concurrency):**

```ts
const results = yield* Effect.all([fetchA, fetchB], {
  concurrency: "unbounded"
})
// If fetchA fails, fetchB is automatically interrupted
```
