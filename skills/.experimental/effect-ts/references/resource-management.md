---
title: "Resource Management"
impact: HIGH
impactDescription: "Prevents resource leaks — covers Scope, safe acquisition and release, caching"
tags: resource, resources, scope, caching, cleanup
---
# [Introduction](https://effect.website/docs/resource-management/introduction/)

## Overview

In long-running applications, managing resources efficiently is essential, particularly when building large-scale systems. If resources like socket connections, database connections, or file descriptors are not properly managed, it can lead to resource leaks, which degrade application performance and reliability. Effect provides constructs that help ensure resources are properly managed and released, even in cases where exceptions occur.

By ensuring that every time a resource is acquired, there is a corresponding mechanism to release it, Effect simplifies the process of resource management in your application.

## Finalization

In many programming languages, the `try` / `finally` construct ensures that cleanup code runs regardless of whether an operation succeeds or fails. Effect provides similar functionality through `Effect.ensuring`, `Effect.onExit`, and `Effect.onError`.

### ensuring

The `Effect.ensuring` function guarantees that a finalizer effect runs whether the main effect succeeds, fails, or is interrupted.

This is useful for performing cleanup actions such as closing file handles, logging messages, or releasing locks.

If you need access to the effect's result, consider using [onExit](#onexit).

**Example** (Running a Finalizer in All Outcomes)

```ts

// Define a cleanup effect
const handler = Effect.ensuring(Console.log("Cleanup completed"))

// Define a successful effect
const success = Console.log("Task completed").pipe(
  Effect.as("some result"),
  handler
)

Effect.runFork(success)
/*
Output:
Task completed
Cleanup completed
*/

// Define a failing effect
const failure = Console.log("Task failed").pipe(
  Effect.andThen(Effect.fail("some error")),
  handler
)

Effect.runFork(failure)
/*
Output:
Task failed
Cleanup completed
*/

// Define an interrupted effect
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

### onExit

`Effect.onExit` allows you to run a cleanup effect after the main effect completes, receiving an [Exit](/docs/data-types/exit/) value that describes the outcome.

- If the effect succeeds, the `Exit` holds the success value.
- If it fails, the `Exit` includes the error or failure cause.
- If it is interrupted, the `Exit` reflects that interruption.

The cleanup step itself is uninterruptible, which can help manage resources in complex or high-concurrency cases.

**Example** (Running a Cleanup Function with the Effect's Result)

```ts

// Define a cleanup effect that logs the result
const handler = Effect.onExit((exit) =>
  Console.log(`Cleanup completed: ${Exit.getOrElse(exit, String)}`)
)

// Define a successful effect
const success = Console.log("Task completed").pipe(
  Effect.as("some result"),
  handler
)

Effect.runFork(success)
/*
Output:
Task completed
Cleanup completed: some result
*/

// Define a failing effect
const failure = Console.log("Task failed").pipe(
  Effect.andThen(Effect.fail("some error")),
  handler
)

Effect.runFork(failure)
/*
Output:
Task failed
Cleanup completed: Error: some error
*/

// Define an interrupted effect
const interruption = Console.log("Task interrupted").pipe(
  Effect.andThen(Effect.interrupt),
  handler
)

Effect.runFork(interruption)
/*
Output:
Task interrupted
Cleanup completed: All fibers interrupted without errors.
*/
```

### onError

This function lets you attach a cleanup effect that runs whenever the calling effect fails, passing the cause of the failure to the cleanup effect.

You can use it to perform actions such as logging, releasing resources, or applying additional recovery steps.

The cleanup effect will also run if the failure is caused by interruption, and it is uninterruptible, so it always finishes once it starts.

**Example** (Running Cleanup Only on Failure)

```ts

// This handler logs the failure cause when the effect fails
const handler = Effect.onError((cause) =>
  Console.log(`Cleanup completed: ${cause}`)
)

// Define a successful effect
const success = Console.log("Task completed").pipe(
  Effect.as("some result"),
  handler
)

Effect.runFork(success)
/*
Output:
Task completed
*/

// Define a failing effect
const failure = Console.log("Task failed").pipe(
  Effect.andThen(Effect.fail("some error")),
  handler
)

Effect.runFork(failure)
/*
Output:
Task failed
Cleanup completed: Error: some error
*/

// Define a failing effect
const defect = Console.log("Task failed with defect").pipe(
  Effect.andThen(Effect.die("Boom!")),
  handler
)

Effect.runFork(defect)
/*
Output:
Task failed with defect
Cleanup completed: Error: Boom!
*/

// Define an interrupted effect
const interruption = Console.log("Task interrupted").pipe(
  Effect.andThen(Effect.interrupt),
  handler
)

Effect.runFork(interruption)
/*
Output:
Task interrupted
Cleanup completed: All fibers interrupted without errors.
*/
```

## acquireUseRelease

Many real-world operations involve working with resources that must be released when no longer needed, such as:

- Database connections
- File handles
- Network requests

Effect provides `Effect.acquireUseRelease`, which ensures that a resource is:

1. **Acquired** properly.
2. **Used** for its intended purpose.
3. **Released** even if an error occurs.

**Syntax**

```ts
Effect.acquireUseRelease(acquire, use, release)
```

**Example** (Automatically Managing Resource Lifetime)

```ts

// Define an interface for a resource
interface MyResource {
  readonly contents: string
  readonly close: () => Promise<void>
}

// Simulate resource acquisition
const getMyResource = (): Promise<MyResource> =>
  Promise.resolve({
    contents: "lorem ipsum",
    close: () =>
      new Promise((resolve) => {
        console.log("Resource released")
        resolve()
      })
  })

// Define how the resource is acquired
const acquire = Effect.tryPromise({
  try: () =>
    getMyResource().then((res) => {
      console.log("Resource acquired")
      return res
    }),
  catch: () => new Error("getMyResourceError")
})

// Define how the resource is released
const release = (res: MyResource) => Effect.promise(() => res.close())

const use = (res: MyResource) => Console.log(`content is ${res.contents}`)

//      ┌─── Effect<void, Error, never>
//      ▼
const program = Effect.acquireUseRelease(acquire, use, release)

Effect.runPromise(program)
/*
Output:
Resource acquired
content is lorem ipsum
Resource released
*/
```


---

# [Scope](https://effect.website/docs/resource-management/scope/)

## Overview


The `Scope` data type is a core construct in Effect for managing resources in a safe and composable way.

A scope represents the lifetime of one or more resources. When the scope is closed, all the resources within it are released, ensuring that no resources are leaked. Scopes also allow the addition of **finalizers**, which define how to release resources.

With the `Scope` data type, you can:

- **Add finalizers**: A finalizer specifies the cleanup logic for a resource.
- **Close the scope**: When the scope is closed, all resources are released, and the finalizers are executed.

**Example** (Managing a Scope)

```ts

const program =
  // create a new scope
  Scope.make().pipe(
    // add finalizer 1
    Effect.tap((scope) =>
      Scope.addFinalizer(scope, Console.log("finalizer 1"))
    ),
    // add finalizer 2
    Effect.tap((scope) =>
      Scope.addFinalizer(scope, Console.log("finalizer 2"))
    ),
    // close the scope
    Effect.andThen((scope) =>
      Scope.close(scope, Exit.succeed("scope closed successfully"))
    )
  )

Effect.runPromise(program)
/*
Output:
finalizer 2 <-- finalizers are closed in reverse order
finalizer 1
*/
```

In the above example, finalizers are added to the scope, and when the scope is closed, the finalizers are **executed in the reverse order**.

This reverse order is important because it ensures that resources are released in the correct sequence.

For instance, if you acquire a network connection and then access a file on a remote server, the file must be closed before the network connection to avoid errors.

## addFinalizer

The `Effect.addFinalizer` function is a high-level API that allows you to add finalizers to the scope of an effect. A finalizer is a piece of code that is guaranteed to run when the associated scope is closed. The behavior of the finalizer can vary based on the [Exit](/docs/data-types/exit/) value, which represents how the scope was closed—whether successfully or with an error.

**Example** (Adding a Finalizer on Success)



```ts

//      ┌─── Effect<string, never, Scope>
//      ▼
const program = Effect.gen(function* () {
  yield* Effect.addFinalizer((exit) =>
    Console.log(`Finalizer executed. Exit status: ${exit._tag}`)
  )
  return "some result"
})

// Wrapping the effect in a scope
//
//      ┌─── Effect<string, never, never>
//      ▼
const runnable = Effect.scoped(program)

Effect.runPromiseExit(runnable).then(console.log)
/*
Output:
Finalizer executed. Exit status: Success
{ _id: 'Exit', _tag: 'Success', value: 'some result' }
*/
```



```ts

//      ┌─── Effect<string, never, Scope>
//      ▼
const program = Effect.addFinalizer((exit) =>
  Console.log(`Finalizer executed. Exit status: ${exit._tag}`)
).pipe(Effect.andThen(Effect.succeed("some result")))

// Wrapping the effect in a scope
//
//      ┌─── Effect<string, never, never>
//      ▼
const runnable = Effect.scoped(program)

Effect.runPromiseExit(runnable).then(console.log)
/*
Output:
Finalizer executed. Exit status: Success
{ _id: 'Exit', _tag: 'Success', value: 'some result' }
*/
```



In this example, we use `Effect.addFinalizer` to add a finalizer that logs the exit state after the scope is closed. The finalizer will execute when the effect finishes, and it will log whether the effect completed successfully or failed.

The type signature:

```ts
const program: Effect<string, never, Scope>
```

shows that the workflow requires a `Scope` to run. You can provide this `Scope` using the `Effect.scoped` function, which creates a new scope, runs the effect within it, and ensures the finalizers are executed when the scope is closed.

> **Note: Finalizer Execution Order**
  Finalizers are executed in reverse order of how they were added,
  ensuring that resources are released in the proper sequence, just like
  in stack unwinding.


**Example** (Adding a Finalizer on Failure)



```ts

//      ┌─── Effect<never, string, Scope>
//      ▼
const program = Effect.gen(function* () {
  yield* Effect.addFinalizer((exit) =>
    Console.log(`Finalizer executed. Exit status: ${exit._tag}`)
  )
  return yield* Effect.fail("Uh oh!")
})

// Wrapping the effect in a scope
//
//      ┌─── Effect<never, string, never>
//      ▼
const runnable = Effect.scoped(program)

Effect.runPromiseExit(runnable).then(console.log)
/*
Output:
Finalizer executed. Exit status: Failure
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Uh oh!' }
}
*/
```



```ts

//      ┌─── Effect<never, string, Scope>
//      ▼
const program = Effect.addFinalizer((exit) =>
  Console.log(`Finalizer executed. Exit status: ${exit._tag}`)
).pipe(Effect.andThen(Effect.fail("Uh oh!")))

// Wrapping the effect in a scope
//
//      ┌─── Effect<never, string, never>
//      ▼
const runnable = Effect.scoped(program)

Effect.runPromiseExit(runnable).then(console.log)
/*
Output:
Finalizer executed. Exit status: Failure
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Uh oh!' }
}
*/
```



In this case, the finalizer is executed even when the effect fails. The log output reflects that the finalizer runs after the failure, and it logs the failure details.

**Example** (Adding a Finalizer on [Interruption](/docs/concurrency/basic-concurrency/#interruptions))



```ts

//      ┌─── Effect<never, never, Scope>
//      ▼
const program = Effect.gen(function* () {
  yield* Effect.addFinalizer((exit) =>
    Console.log(`Finalizer executed. Exit status: ${exit._tag}`)
  )
  return yield* Effect.interrupt
})

// Wrapping the effect in a scope
//
//      ┌─── Effect<never, never, never>
//      ▼
const runnable = Effect.scoped(program)

Effect.runPromiseExit(runnable).then(console.log)
/*
Output:
Finalizer executed. Exit status: Failure
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



```ts

//      ┌─── Effect<never, never, Scope>
//      ▼
const program = Effect.addFinalizer((exit) =>
  Console.log(`Finalizer executed. Exit status: ${exit._tag}`)
).pipe(Effect.andThen(Effect.interrupt))

// Wrapping the effect in a scope
//
//      ┌─── Effect<never, never, never>
//      ▼
const runnable = Effect.scoped(program)

Effect.runPromiseExit(runnable).then(console.log)
/*
Output:
Finalizer executed. Exit status: Failure
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



This example shows how a finalizer behaves when the effect is interrupted. The finalizer runs after the interruption, and the exit status reflects that the effect was stopped mid-execution.

## Manually Create and Close Scopes

When you're working with multiple scoped resources within a single operation, it's important to understand how their scopes interact.
By default, these scopes are merged into one, but you can have more fine-grained control over when each scope is closed by manually creating and closing them.

Let's start by looking at how scopes are merged by default:

**Example** (Merging Scopes)

```ts

const task1 = Effect.gen(function* () {
  console.log("task 1")
  yield* Effect.addFinalizer(() => Console.log("finalizer after task 1"))
})

const task2 = Effect.gen(function* () {
  console.log("task 2")
  yield* Effect.addFinalizer(() => Console.log("finalizer after task 2"))
})

const program = Effect.gen(function* () {
  // The scopes of both tasks are merged into one
  yield* task1
  yield* task2
})

Effect.runPromise(Effect.scoped(program))
/*
Output:
task 1
task 2
finalizer after task 2
finalizer after task 1
*/
```

In this case, the scopes of `task1` and `task2` are merged into a single scope, and when the program is run, it outputs the tasks and their finalizers in a specific order.

If you want more control over when each scope is closed, you can manually create and close them:

**Example** (Manually Creating and Closing Scopes)

```ts

const task1 = Effect.gen(function* () {
  console.log("task 1")
  yield* Effect.addFinalizer(() => Console.log("finalizer after task 1"))
})

const task2 = Effect.gen(function* () {
  console.log("task 2")
  yield* Effect.addFinalizer(() => Console.log("finalizer after task 2"))
})

const program = Effect.gen(function* () {
  const scope1 = yield* Scope.make()
  const scope2 = yield* Scope.make()

  // Extend the scope of task1 into scope1
  yield* task1.pipe(Scope.extend(scope1))

  // Extend the scope of task2 into scope2
  yield* task2.pipe(Scope.extend(scope2))

  // Manually close scope1 and scope2
  yield* Scope.close(scope1, Exit.void)
  yield* Console.log("doing something else")
  yield* Scope.close(scope2, Exit.void)
})

Effect.runPromise(program)
/*
Output:
task 1
task 2
finalizer after task 1
doing something else
finalizer after task 2
*/
```

In this example, we create two separate scopes, `scope1` and `scope2`, and extend the scope of each task into its respective scope. When you run the program, it outputs the tasks and their finalizers in a different order.

> **Note: Extending a Scope**
  The `Scope.extend` function allows you to extend the scope of an effect
  workflow that requires a scope into another scope without closing the
  scope when the workflow finishes executing. This allows you to extend a
  scoped value into a larger scope.


You might wonder what happens when a scope is closed, but a task within that scope hasn't completed yet.
The key point to note is that the scope closing doesn't force the task to be interrupted.

**Example** (Closing a Scope with Pending Tasks)

```ts

const task = Effect.gen(function* () {
  yield* Effect.sleep("1 second")
  console.log("Executed")
  yield* Effect.addFinalizer(() => Console.log("Task Finalizer"))
})

const program = Effect.gen(function* () {
  const scope = yield* Scope.make()

  // Close the scope immediately
  yield* Scope.close(scope, Exit.void)
  console.log("Scope closed")

  // This task will be executed even if the scope is closed
  yield* task.pipe(Scope.extend(scope))
})

Effect.runPromise(program)
/*
Output:
Scope closed
Executed <-- after 1 second
Task Finalizer
*/
```

## Defining Resources

### acquireRelease

The `Effect.acquireRelease(acquire, release)` function allows you to define resources that are acquired and safely released when they are no longer needed. This is useful for managing resources such as file handles, database connections, or network sockets.

To use `Effect.acquireRelease`, you need to define two actions:

1. **Acquiring the Resource**: An effect describing the acquisition of the resource, e.g., opening a file or establishing a database connection.
2. **Releasing the Resource**: The clean-up effect that ensures the resource is properly released, e.g., closing the file or the connection.

The acquisition process is **uninterruptible** to ensure that partial resource acquisition doesn't leave your system in an inconsistent state.

The `Effect.acquireRelease` function guarantees that once a resource is successfully acquired, its release step is always executed when the `Scope` is closed.

**Example** (Defining a Simple Resource)

```ts

// Define an interface for a resource
interface MyResource {
  readonly contents: string
  readonly close: () => Promise<void>
}

// Simulate resource acquisition
const getMyResource = (): Promise<MyResource> =>
  Promise.resolve({
    contents: "lorem ipsum",
    close: () =>
      new Promise((resolve) => {
        console.log("Resource released")
        resolve()
      })
  })

// Define how the resource is acquired
const acquire = Effect.tryPromise({
  try: () =>
    getMyResource().then((res) => {
      console.log("Resource acquired")
      return res
    }),
  catch: () => new Error("getMyResourceError")
})

// Define how the resource is released
const release = (res: MyResource) => Effect.promise(() => res.close())

// Create the resource management workflow
//
//      ┌─── Effect<MyResource, Error, Scope>
//      ▼
const resource = Effect.acquireRelease(acquire, release)
```

In the code above, the `Effect.acquireRelease` function creates a resource workflow that requires a `Scope`:

```ts
const resource: Effect<MyResource, Error, Scope>
```

This means that the workflow needs a `Scope` to run, and the resource will automatically be released when the scope is closed.

You can now use the resource by chaining operations using `Effect.andThen` or similar functions.

We can continue working with the resource for as long as we want by using `Effect.andThen` or other Effect operators. For example, here's how we can read the contents:

**Example** (Using the Resource)

```ts

// Define an interface for a resource
interface MyResource {
  readonly contents: string
  readonly close: () => Promise<void>
}

// Simulate resource acquisition
const getMyResource = (): Promise<MyResource> =>
  Promise.resolve({
    contents: "lorem ipsum",
    close: () =>
      new Promise((resolve) => {
        console.log("Resource released")
        resolve()
      })
  })

// Define how the resource is acquired
const acquire = Effect.tryPromise({
  try: () =>
    getMyResource().then((res) => {
      console.log("Resource acquired")
      return res
    }),
  catch: () => new Error("getMyResourceError")
})

// Define how the resource is released
const release = (res: MyResource) => Effect.promise(() => res.close())

// Create the resource management workflow
const resource = Effect.acquireRelease(acquire, release)

//      ┌─── Effect<void, Error, Scope>
//      ▼
const program = Effect.gen(function* () {
  const res = yield* resource
  console.log(`content is ${res.contents}`)
})
```

To ensure proper resource management, the `Scope` should be closed when you're done with the resource. The `Effect.scoped` function handles this for you by creating a `Scope`, running the effect, and then closing the `Scope` when the effect finishes.

**Example** (Providing the `Scope` with `Effect.scoped`)

```ts

// Define an interface for a resource
interface MyResource {
  readonly contents: string
  readonly close: () => Promise<void>
}

// Simulate resource acquisition
const getMyResource = (): Promise<MyResource> =>
  Promise.resolve({
    contents: "lorem ipsum",
    close: () =>
      new Promise((resolve) => {
        console.log("Resource released")
        resolve()
      })
  })

// Define how the resource is acquired
const acquire = Effect.tryPromise({
  try: () =>
    getMyResource().then((res) => {
      console.log("Resource acquired")
      return res
    }),
  catch: () => new Error("getMyResourceError")
})

// Define how the resource is released
const release = (res: MyResource) => Effect.promise(() => res.close())

// Create the resource management workflow
const resource = Effect.acquireRelease(acquire, release)

//      ┌─── Effect<void, Error, never>
//      ▼
const program = Effect.scoped(
  Effect.gen(function* () {
    const res = yield* resource
    console.log(`content is ${res.contents}`)
  })
)

// We now have a workflow that is ready to run
Effect.runPromise(program)
/*
Resource acquired
content is lorem ipsum
Resource released
*/
```

### Example Pattern: Sequencing Operations

In certain scenarios, you might need to perform a sequence of chained operations where the success of each operation depends on the previous one. However, if any of the operations fail, you would want to reverse the effects of all previous successful operations. This pattern is valuable when you need to ensure that either all operations succeed, or none of them have any effect at all.

Let's go through an example of implementing this pattern. Suppose we want to create a "Workspace" in our application, which involves creating an S3 bucket, an ElasticSearch index, and a Database entry that relies on the previous two.

To begin, we define the domain model for the required [services](/docs/requirements-management/services/):

- `S3`
- `ElasticSearch`
- `Database`

```ts

class S3Error extends Data.TaggedError("S3Error")<{}> {}

interface Bucket {
  readonly name: string
}

class S3 extends Context.Tag("S3")<
  S3,
  {
    readonly createBucket: Effect.Effect<Bucket, S3Error>
    readonly deleteBucket: (bucket: Bucket) => Effect.Effect<void>
  }
>() {}

class ElasticSearchError extends Data.TaggedError(
  "ElasticSearchError"
)<{}> {}

interface Index {
  readonly id: string
}

class ElasticSearch extends Context.Tag("ElasticSearch")<
  ElasticSearch,
  {
    readonly createIndex: Effect.Effect<Index, ElasticSearchError>
    readonly deleteIndex: (index: Index) => Effect.Effect<void>
  }
>() {}

class DatabaseError extends Data.TaggedError("DatabaseError")<{}> {}

interface Entry {
  readonly id: string
}

class Database extends Context.Tag("Database")<
  Database,
  {
    readonly createEntry: (
      bucket: Bucket,
      index: Index
    ) => Effect.Effect<Entry, DatabaseError>
    readonly deleteEntry: (entry: Entry) => Effect.Effect<void>
  }
>() {}
```

Next, we define the three create actions and the overall transaction (`make`) for the workspace.

```ts

class S3Error extends Data.TaggedError("S3Error")<{}> {}

interface Bucket {
  readonly name: string
}

class S3 extends Context.Tag("S3")<
  S3,
  {
    readonly createBucket: Effect.Effect<Bucket, S3Error>
    readonly deleteBucket: (bucket: Bucket) => Effect.Effect<void>
  }
>() {}

class ElasticSearchError extends Data.TaggedError(
  "ElasticSearchError"
)<{}> {}

interface Index {
  readonly id: string
}

class ElasticSearch extends Context.Tag("ElasticSearch")<
  ElasticSearch,
  {
    readonly createIndex: Effect.Effect<Index, ElasticSearchError>
    readonly deleteIndex: (index: Index) => Effect.Effect<void>
  }
>() {}

class DatabaseError extends Data.TaggedError("DatabaseError")<{}> {}

interface Entry {
  readonly id: string
}

class Database extends Context.Tag("Database")<
  Database,
  {
    readonly createEntry: (
      bucket: Bucket,
      index: Index
    ) => Effect.Effect<Entry, DatabaseError>
    readonly deleteEntry: (entry: Entry) => Effect.Effect<void>
  }
>() {}

// Create a bucket, and define the release function that deletes the
// bucket if the operation fails.
const createBucket = Effect.gen(function* () {
  const { createBucket, deleteBucket } = yield* S3
  return yield* Effect.acquireRelease(createBucket, (bucket, exit) =>
    // The release function for the Effect.acquireRelease operation is
    // responsible for handling the acquired resource (bucket) after the
    // main effect has completed. It is called regardless of whether the
    // main effect succeeded or failed. If the main effect failed,
    // Exit.isFailure(exit) will be true, and the function will perform
    // a rollback by calling deleteBucket(bucket). If the main effect
    // succeeded, Exit.isFailure(exit) will be false, and the function
    // will return Effect.void, representing a successful, but
    // do-nothing effect.
    Exit.isFailure(exit) ? deleteBucket(bucket) : Effect.void
  )
})

// Create an index, and define the release function that deletes the
// index if the operation fails.
const createIndex = Effect.gen(function* () {
  const { createIndex, deleteIndex } = yield* ElasticSearch
  return yield* Effect.acquireRelease(createIndex, (index, exit) =>
    Exit.isFailure(exit) ? deleteIndex(index) : Effect.void
  )
})

// Create an entry in the database, and define the release function that
// deletes the entry if the operation fails.
const createEntry = (bucket: Bucket, index: Index) =>
  Effect.gen(function* () {
    const { createEntry, deleteEntry } = yield* Database
    return yield* Effect.acquireRelease(
      createEntry(bucket, index),
      (entry, exit) =>
        Exit.isFailure(exit) ? deleteEntry(entry) : Effect.void
    )
  })

const make = Effect.scoped(
  Effect.gen(function* () {
    const bucket = yield* createBucket
    const index = yield* createIndex
    return yield* createEntry(bucket, index)
  })
)
```

We then create simple service implementations to test the behavior of our Workspace code.
To achieve this, we will utilize [layers](/docs/requirements-management/layers/) to construct test
These layers will be able to handle various scenarios, including errors, which we can control using the `FailureCase` type.

```ts

class S3Error extends Data.TaggedError("S3Error")<{}> {}

interface Bucket {
  readonly name: string
}

class S3 extends Context.Tag("S3")<
  S3,
  {
    readonly createBucket: Effect.Effect<Bucket, S3Error>
    readonly deleteBucket: (bucket: Bucket) => Effect.Effect<void>
  }
>() {}

class ElasticSearchError extends Data.TaggedError(
  "ElasticSearchError"
)<{}> {}

interface Index {
  readonly id: string
}

class ElasticSearch extends Context.Tag("ElasticSearch")<
  ElasticSearch,
  {
    readonly createIndex: Effect.Effect<Index, ElasticSearchError>
    readonly deleteIndex: (index: Index) => Effect.Effect<void>
  }
>() {}

class DatabaseError extends Data.TaggedError("DatabaseError")<{}> {}

interface Entry {
  readonly id: string
}

class Database extends Context.Tag("Database")<
  Database,
  {
    readonly createEntry: (
      bucket: Bucket,
      index: Index
    ) => Effect.Effect<Entry, DatabaseError>
    readonly deleteEntry: (entry: Entry) => Effect.Effect<void>
  }
>() {}

// Create a bucket, and define the release function that deletes the
// bucket if the operation fails.
const createBucket = Effect.gen(function* () {
  const { createBucket, deleteBucket } = yield* S3
  return yield* Effect.acquireRelease(createBucket, (bucket, exit) =>
    // The release function for the Effect.acquireRelease operation is
    // responsible for handling the acquired resource (bucket) after the
    // main effect has completed. It is called regardless of whether the
    // main effect succeeded or failed. If the main effect failed,
    // Exit.isFailure(exit) will be true, and the function will perform
    // a rollback by calling deleteBucket(bucket). If the main effect
    // succeeded, Exit.isFailure(exit) will be false, and the function
    // will return Effect.void, representing a successful, but
    // do-nothing effect.
    Exit.isFailure(exit) ? deleteBucket(bucket) : Effect.void
  )
})

// Create an index, and define the release function that deletes the
// index if the operation fails.
const createIndex = Effect.gen(function* () {
  const { createIndex, deleteIndex } = yield* ElasticSearch
  return yield* Effect.acquireRelease(createIndex, (index, exit) =>
    Exit.isFailure(exit) ? deleteIndex(index) : Effect.void
  )
})

// Create an entry in the database, and define the release function that
// deletes the entry if the operation fails.
const createEntry = (bucket: Bucket, index: Index) =>
  Effect.gen(function* () {
    const { createEntry, deleteEntry } = yield* Database
    return yield* Effect.acquireRelease(
      createEntry(bucket, index),
      (entry, exit) =>
        Exit.isFailure(exit) ? deleteEntry(entry) : Effect.void
    )
  })

const make = Effect.scoped(
  Effect.gen(function* () {
    const bucket = yield* createBucket
    const index = yield* createIndex
    return yield* createEntry(bucket, index)
  })
)

// The `FailureCaseLiterals` type allows us to provide different error
// scenarios while testing our
//
// For example, by providing the value "S3", we can simulate an error
// scenario specific to the S3 service. This helps us ensure that our
// program handles errors correctly and behaves as expected in various
// situations.
//
// Similarly, we can provide other values like "ElasticSearch" or
// "Database" to simulate error scenarios for those  In cases
// where we want to test the absence of errors, we can provide
// `undefined`. By using this parameter, we can thoroughly test our
// services and verify their behavior under different error conditions.
type FailureCaseLiterals = "S3" | "ElasticSearch" | "Database" | undefined

class FailureCase extends Context.Tag("FailureCase")<
  FailureCase,
  FailureCaseLiterals
>() {}

// Create a test layer for the S3 service

const S3Test = Layer.effect(
  S3,
  Effect.gen(function* () {
    const failureCase = yield* FailureCase
    return {
      createBucket: Effect.gen(function* () {
        console.log("[S3] creating bucket")
        if (failureCase === "S3") {
          return yield* Effect.fail(new S3Error())
        } else {
          return { name: "<bucket.name>" }
        }
      }),
      deleteBucket: (bucket) =>
        Console.log(`[S3] delete bucket ${bucket.name}`)
    }
  })
)

// Create a test layer for the ElasticSearch service

const ElasticSearchTest = Layer.effect(
  ElasticSearch,
  Effect.gen(function* () {
    const failureCase = yield* FailureCase
    return {
      createIndex: Effect.gen(function* () {
        console.log("[ElasticSearch] creating index")
        if (failureCase === "ElasticSearch") {
          return yield* Effect.fail(new ElasticSearchError())
        } else {
          return { id: "<index.id>" }
        }
      }),
      deleteIndex: (index) =>
        Console.log(`[ElasticSearch] delete index ${index.id}`)
    }
  })
)

// Create a test layer for the Database service

const DatabaseTest = Layer.effect(
  Database,
  Effect.gen(function* () {
    const failureCase = yield* FailureCase
    return {
      createEntry: (bucket, index) =>
        Effect.gen(function* () {
          console.log(
            "[Database] creating entry for bucket" +
              `${bucket.name} and index ${index.id}`
          )
          if (failureCase === "Database") {
            return yield* Effect.fail(new DatabaseError())
          } else {
            return { id: "<entry.id>" }
          }
        }),
      deleteEntry: (entry) =>
        Console.log(`[Database] delete entry ${entry.id}`)
    }
  })
)

// Merge all the test layers for S3, ElasticSearch, and Database
// services into a single layer
const layer = Layer.mergeAll(S3Test, ElasticSearchTest, DatabaseTest)

// Create a runnable effect to test the Workspace code. The effect is
// provided with the test layer and a FailureCase service with undefined
// value (no failure case).
const runnable = make.pipe(
  Effect.provide(layer),
  Effect.provideService(FailureCase, undefined)
)

Effect.runPromise(Effect.either(runnable)).then(console.log)
```

Let's examine the test results for the scenario where `FailureCase` is set to `undefined` (happy path):

```ansi
[S3] creating bucket
[ElasticSearch] creating index
[Database] creating entry for bucket <bucket.name> and index <index.id>
{ _id: 'Either', _tag: 'Right', right: { id: '<entry.id>' } }
```

In this case, all operations succeed, and we see a successful result with `right({ id: '<entry.id>' })`.

Now, let's simulate a failure in the `Database`:

```ts
const runnable = make.pipe(
  Effect.provide(layer),
  Effect.provideService(FailureCase, "Database")
)
```

The console output will be:

```ansi
[S3] creating bucket
[ElasticSearch] creating index
[Database] creating entry for bucket <bucket.name> and index <index.id>
[ElasticSearch] delete index <index.id>
[S3] delete bucket <bucket.name>
{ _id: 'Either', _tag: 'Left', left: { _tag: 'DatabaseError' } }
```

You can observe that once the `Database` error occurs, there is a complete rollback that deletes the `ElasticSearch` index first and then the associated `S3` bucket. The result is a failure with `left(new DatabaseError())`.

Let's now make the index creation fail instead:

```ts
const runnable = make.pipe(
  Effect.provide(layer),
  Effect.provideService(FailureCase, "ElasticSearch")
)
```

In this case, the console output will be:

```ansi
[S3] creating bucket
[ElasticSearch] creating index
[S3] delete bucket <bucket.name>
{ _id: 'Either', _tag: 'Left', left: { _tag: 'ElasticSearchError' } }
```

As expected, once the `ElasticSearch` index creation fails, there is a rollback that deletes the `S3` bucket. The result is a failure with `left(new ElasticSearchError())`.


---

# [Cache](https://effect.website/docs/caching/cache/)

## Overview

In many applications, handling overlapping work is common. For example, in services that process incoming requests, it's important to avoid redundant work like handling the same request multiple times. The Cache module helps improve performance by preventing duplicate work.

Key Features of Cache:

| Feature                           | Description                                                                                                            |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Compositionality**              | Allows overlapping work across different parts of the application while preserving compositional programming.          |
| **Unified Sync and Async Caches** | Integrates both synchronous and asynchronous caches through a unified lookup function that computes values either way. |
| **Effect Integration**            | Works natively with the Effect library, supporting concurrent lookups, failure handling, and interruption.             |
| **Cache Metrics**                 | Tracks key metrics like entries, hits, and misses, providing insights for performance optimization.                    |

## Creating a Cache

A cache is defined by a lookup function that computes the value for a given key if it's not already cached:

```ts
type Lookup<Key, Value, Error, Requirements> = (
  key: Key
) => Effect<Value, Error, Requirements>
```

The lookup function takes a `Key` and returns an `Effect`, which describes how to compute the value (`Value`). This `Effect` may require an environment (`Requirements`), can fail with an `Error`, and succeed with a `Value`. Since it returns an `Effect`, it can handle both synchronous and asynchronous workflows.

You create a cache by providing a lookup function along with a maximum size and a time-to-live (TTL) for cached values.

```ts
declare const make: <Key, Value, Error, Requirements>(options: {
  readonly capacity: number
  readonly timeToLive: Duration.DurationInput
  readonly lookup: Lookup<Key, Value, Error, Requirements>
}) => Effect<Cache<Key, Value, Error>, never, Requirements>
```

Once a cache is created, the most idiomatic way to work with it is the `get` method.
The `get` method returns the current value in the cache if it exists, or computes a new value, puts it in the cache, and returns it.

If multiple concurrent processes request the same value, it will only be computed once. All other processes will receive the computed value as soon as it is available. This is managed using Effect's fiber-based concurrency model without blocking the underlying thread.

**Example** (Concurrent Cache Lookups)

In this example, we call `timeConsumingEffect` three times concurrently with the same key.
The cache runs this effect only once, so concurrent lookups will wait until the value is available:

```ts

// Simulating an expensive lookup with a delay
const expensiveLookup = (key: string) =>
  Effect.sleep("2 seconds").pipe(Effect.as(key.length))

const program = Effect.gen(function* () {
  // Create a cache with a capacity of 100 and an infinite TTL
  const cache = yield* Cache.make({
    capacity: 100,
    timeToLive: Duration.infinity,
    lookup: expensiveLookup
  })

  // Perform concurrent lookups using the same key
  const result = yield* Effect.all(
    [cache.get("key1"), cache.get("key1"), cache.get("key1")],
    { concurrency: "unbounded" }
  )
  console.log(
    "Result of parallel execution of three effects" +
      `with the same key: ${result}`
  )

  // Fetch and display cache stats
  const hits = yield* cache.cacheStats.pipe(
    Effect.map((stats) => stats.hits)
  )
  console.log(`Number of cache hits: ${hits}`)
  const misses = yield* cache.cacheStats.pipe(
    Effect.map((stats) => stats.misses)
  )
  console.log(`Number of cache misses: ${misses}`)
})

Effect.runPromise(program)
/*
Output:
Result of parallel execution of three effects with the same key: 4,4,4
Number of cache hits: 2
Number of cache misses: 1
*/
```

## Concurrent Access

The cache is designed to be safe for concurrent access and efficient under concurrent conditions. If two concurrent processes request the same value and it is not in the cache, the value will be computed once and provided to both processes as soon as it is available. Concurrent processes will wait for the value without blocking the underlying thread.

If the lookup function fails or is interrupted, the error will be propagated to all concurrent processes waiting for the value. Failures are cached to prevent repeated computation of the same failed value. If interrupted, the key will be removed from the cache, so subsequent calls will attempt to compute the value again.

## Capacity

A cache is created with a specified capacity. When the cache reaches capacity, the least recently accessed values will be removed first. The cache size may slightly exceed the specified capacity between operations.

## Time To Live (TTL)

A cache can also have a specified time to live (TTL). Values older than the TTL will not be returned. The age is calculated from when the value was loaded into the cache.

## Methods

In addition to `get`, the cache provides several other methods:

| Method          | Description                                                                                                                                                                |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `refresh`       | Triggers a recomputation of the value for a key without removing the old value, allowing continued access.                                                                 |
| `size`          | Returns the current size of the cache. The size is approximate under concurrent conditions.                                                                                |
| `contains`      | Checks if a value associated with a specified key exists in the cache. Under concurrent access, the result is valid as of the check time but may change immediately after. |
| `invalidate`    | Evicts the value associated with a specific key.                                                                                                                           |
| `invalidateAll` | Evicts all values from the cache.                                                                                                                                          |

# [Caching Effects](https://effect.website/docs/caching/caching-effects/)

## Overview

This section covers several functions from the library that help manage caching and memoization in your application.

## cachedFunction

Memoizes a function with effects, caching results for the same inputs to avoid recomputation.

**Example** (Memoizing a Random Number Generator)

```ts

const program = Effect.gen(function* () {
  const randomNumber = (n: number) => Random.nextIntBetween(1, n)
  console.log("non-memoized version:")
  console.log(yield* randomNumber(10)) // Generates a new random number
  console.log(yield* randomNumber(10)) // Generates a different number

  console.log("memoized version:")
  const memoized = yield* Effect.cachedFunction(randomNumber)
  console.log(yield* memoized(10)) // Generates and caches the result
  console.log(yield* memoized(10)) // Reuses the cached result
})

Effect.runFork(program)
/*
Example Output:
non-memoized version:
2
8
memoized version:
5
5
*/
```

## once

Ensures an effect is executed only once, even if invoked multiple times.

**Example** (Single Execution of an Effect)

```ts

const program = Effect.gen(function* () {
  const task1 = Console.log("task1")

  // Repeats task1 three times
  yield* Effect.repeatN(task1, 2)

  // Ensures task2 is executed only once
  const task2 = yield* Effect.once(Console.log("task2"))

  // Attempts to repeat task2, but it will only execute once
  yield* Effect.repeatN(task2, 2)
})

Effect.runFork(program)
/*
Output:
task1
task1
task1
task2
*/
```

## cached

Returns an effect that computes a result lazily and caches it. Subsequent evaluations of this effect will return the cached result without re-executing the logic.

**Example** (Lazy Caching of an Expensive Task)

```ts

let i = 1

// Simulating an expensive task with a delay
const expensiveTask = Effect.promise<string>(() => {
  console.log("expensive task...")
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(`result ${i++}`)
    }, 100)
  })
})

const program = Effect.gen(function* () {
  // Without caching, the task is executed each time
  console.log("-- non-cached version:")
  yield* expensiveTask.pipe(Effect.andThen(Console.log))
  yield* expensiveTask.pipe(Effect.andThen(Console.log))

  // With caching, the result is reused after the first run
  console.log("-- cached version:")
  const cached = yield* Effect.cached(expensiveTask)
  yield* cached.pipe(Effect.andThen(Console.log))
  yield* cached.pipe(Effect.andThen(Console.log))
})

Effect.runFork(program)
/*
Output:
-- non-cached version:
expensive task...
result 1
expensive task...
result 2
-- cached version:
expensive task...
result 3
result 3
*/
```

## cachedWithTTL

Returns an effect that caches its result for a specified duration, known as the `timeToLive`. When the cache expires after the duration, the effect will be recomputed upon next evaluation.

**Example** (Caching with Time-to-Live)

```ts

let i = 1

// Simulating an expensive task with a delay
const expensiveTask = Effect.promise<string>(() => {
  console.log("expensive task...")
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(`result ${i++}`)
    }, 100)
  })
})

const program = Effect.gen(function* () {
  // Caches the result for 150 milliseconds
  const cached = yield* Effect.cachedWithTTL(expensiveTask, "150 millis")

  // First evaluation triggers the task
  yield* cached.pipe(Effect.andThen(Console.log))

  // Second evaluation returns the cached result
  yield* cached.pipe(Effect.andThen(Console.log))

  // Wait for 100 milliseconds, ensuring the cache expires
  yield* Effect.sleep("100 millis")

  // Recomputes the task after cache expiration
  yield* cached.pipe(Effect.andThen(Console.log))
})

Effect.runFork(program)
/*
Output:
expensive task...
result 1
result 1
expensive task...
result 2
*/
```

## cachedInvalidateWithTTL

Similar to `Effect.cachedWithTTL`, this function caches an effect's result for a specified duration. It also includes an additional effect for manually invalidating the cached value before it naturally expires.

**Example** (Invalidating Cache Manually)

```ts

let i = 1

// Simulating an expensive task with a delay
const expensiveTask = Effect.promise<string>(() => {
  console.log("expensive task...")
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(`result ${i++}`)
    }, 100)
  })
})

const program = Effect.gen(function* () {
  // Caches the result for 150 milliseconds
  const [cached, invalidate] = yield* Effect.cachedInvalidateWithTTL(
    expensiveTask,
    "150 millis"
  )

  // First evaluation triggers the task
  yield* cached.pipe(Effect.andThen(Console.log))

  // Second evaluation returns the cached result
  yield* cached.pipe(Effect.andThen(Console.log))

  // Invalidate the cache before it naturally expires
  yield* invalidate

  // Third evaluation triggers the task again
  // since the cache was invalidated
  yield* cached.pipe(Effect.andThen(Console.log))
})

Effect.runFork(program)
/*
Output:
expensive task...
result 1
result 1
expensive task...
result 2
*/
```


## Common Mistakes

**Incorrect (manual cleanup that may not run):**

```ts
const conn = await pool.connect()
try {
  await doWork(conn)
} finally {
  conn.release() // May not run if process exits
}
```

**Correct (using Scope for guaranteed cleanup):**

```ts
const withConnection = Effect.acquireRelease(
  pool.connect(),
  (conn) => Effect.sync(() => conn.release())
)
```
