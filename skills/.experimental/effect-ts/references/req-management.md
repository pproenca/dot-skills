---
title: "Requirements Management"
impact: HIGH
impactDescription: "Foundation for Effect dependency injection — covers services, layers, memoization"
tags: req, requirements, services, layers, dependency-injection
---
# [Managing Services](https://effect.website/docs/requirements-management/services/)

## Overview


In the context of programming, a **service** refers to a reusable component or functionality that can be used by different parts of an application.
Services are designed to provide specific capabilities and can be shared across multiple modules or components.

Services often encapsulate common tasks or operations that are needed by different parts of an application.
They can handle complex operations, interact with external systems or APIs, manage data, or perform other specialized tasks.

Services are typically designed to be modular and decoupled from the rest of the application.
This allows them to be easily maintained, tested, and replaced without affecting the overall functionality of the application.

When diving into services and their integration in application development, it helps to start from the basic principles of function management and dependency handling without relying on advanced constructs. Imagine having to manually pass a service around to every function that needs it:

```ts
const processData = (data: Data, databaseService: DatabaseService) => {
  // Operations using the database service
}
```

This approach becomes cumbersome and unmanageable as your application grows, with services needing to be passed through multiple layers of functions.

To streamline this, you might consider using an environment object that bundles various services:

```ts
type Context = {
  databaseService: DatabaseService
  loggingService: LoggingService
}

const processData = (data: Data, context: Context) => {
  // Using multiple services from the context
}
```

However, this introduces a new complexity: you must ensure that the environment is correctly set up with all necessary services before it's used, which can lead to tightly coupled code and makes functional composition and testing more difficult.

## Managing Services with Effect

The Effect library simplifies managing these dependencies by leveraging the type system.
Instead of manually passing services or environment objects around, Effect allows you to declare service dependencies directly in the function's type signature using the `Requirements` parameter in the `Effect` type:

```ts
                         ┌─── Represents required dependencies
                         ▼
Effect<Success, Error, Requirements>
```

This is how it works in practice when using Effect:

**Dependency Declaration**: You specify what services a function needs directly in its type, pushing the complexity of dependency management into the type system.

**Service Provision**: `Effect.provideService` is used to make a service implementation available to the functions that need it. By providing services at the start, you ensure that all parts of your application have consistent access to the required services, thus maintaining a clean and decoupled architecture.

This approach abstracts away manual service handling, letting developers focus on business logic while the compiler ensures all dependencies are correctly managed. It also makes code more maintainable and scalable.

Let's walk through managing services in Effect step by step:

1. **Creating a Service**: Define a service with its unique functionality and interface.
2. **Using the Service**: Access and utilize the service within your application’s functions.
3. **Providing a Service Implementation**: Supply an actual implementation of the service to fulfill the declared requirements.

## How It Works

Up to this point, our examples with the Effect framework have dealt with effects that operate independently of external services.
This means the `Requirements` parameter in our `Effect` type signature has been set to `never`, indicating no dependencies.

However, real-world applications often need effects that rely on specific services to function correctly. These services are managed and accessed through a construct known as `Context`.

The `Context` serves as a repository or container for all services an effect may require.
It acts like a store that maintains these services, allowing various parts of your application to access and use them as needed.

The services stored within the `Context` are directly reflected in the `Requirements` parameter of the `Effect` type.
Each service within the `Context` is identified by a unique "tag," which is essentially a unique identifier for the service.

When an effect needs to use a specific service, the service's tag is included in the `Requirements` type parameter.

## Creating a Service

To create a new service, you need two things:

1. A unique **identifier**.
2. A **type** describing the possible operations of the service.

**Example** (Defining a Random Number Generator Service)

Let's create a service for generating random numbers.

1. **Identifier**. We'll use the string `"MyRandomService"` as the unique identifier.
2. **Type**. The service type will have a single operation called `next` that returns a random number.

```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  { readonly next: Effect.Effect<number> }
>() {}
```

The exported `Random` value is known as a **tag** in Effect. It acts as a representation of the service and allows Effect to locate and use this service at runtime.

The service will be stored in a collection called `Context`, which can be thought of as a `Map` where the keys are tags and the values are services:

```ts
type Context = Map<Tag, Service>
```

> **Note: Why Use Identifiers?**
  You need to specify an identifier to make the tag global. This ensures that two tags with the same identifier refer to the same instance.

Using a unique identifier is particularly useful in scenarios where live reloads can occur, as it helps preserve the instance across reloads. It ensures there is no duplication of instances (although it shouldn't happen, some bundlers and frameworks can behave unpredictably).



Let's summarize the concepts we've covered so far:

| Concept     | Description                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------------------ |
| **service** | A reusable component providing specific functionality, used across different parts of an application.  |
| **tag**     | A unique identifier representing a **service**, allowing Effect to locate and use it.                  |
| **context** | A collection storing service, functioning like a map with **tags** as keys and **services** as values. |

## Using the Service

Now that we have our service tag defined, let's see how we can use it by building a simple program.

**Example** (Using the Random Service)



```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  { readonly next: Effect.Effect<number> }
>() {}

// Using the service
//
//      ┌─── Effect<void, never, Random>
//      ▼
const program = Effect.gen(function* () {
  const random = yield* Random
  const randomNumber = yield* random.next
  console.log(`random number: ${randomNumber}`)
})
```

In the code above, we can observe that we are able to yield the `Random` tag as if it were an effect itself.
This allows us to access the `next` operation of the service.



```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  { readonly next: Effect.Effect<number> }
>() {}

// Using the service
//
//      ┌─── Effect<void, never, Random>
//      ▼
const program = Random.pipe(
  Effect.andThen((random) => random.next),
  Effect.andThen((randomNumber) =>
    Console.log(`random number: ${randomNumber}`)
  )
)
```

In the code above, we can observe that we are able to flat-map over the `Random` tag as if it were an effect itself.
This allows us to access the `next` operation of the service within the `Effect.andThen` callback.



It's worth noting that the type of the `program` variable includes `Random` in the `Requirements` type parameter:

```ts
const program: Effect<void, never, Random>
```

This indicates that our program requires the `Random` service to be provided in order to execute successfully.

If we attempt to execute the effect without providing the necessary service we will encounter a type-checking error:

**Example** (Type Error Without Service Provision)

```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  { readonly next: Effect.Effect<number> }
>() {}

// Using the service
const program = Effect.gen(function* () {
  const random = yield* Random
  const randomNumber = yield* random.next
  console.log(`random number: ${randomNumber}`)
})

// @errors: 2379
Effect.runSync(program)
```

To resolve this error and successfully execute the program, we need to provide an actual implementation of the `Random` service.

In the next section, we will explore how to implement and provide the `Random` service to our program, enabling us to run it successfully.

## Providing a Service Implementation

In order to provide an actual implementation of the `Random` service, we can utilize the `Effect.provideService` function.

**Example** (Providing a Random Number Implementation)

```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  { readonly next: Effect.Effect<number> }
>() {}

// Using the service
const program = Effect.gen(function* () {
  const random = yield* Random
  const randomNumber = yield* random.next
  console.log(`random number: ${randomNumber}`)
})

// Providing the implementation
//
//      ┌─── Effect<void, never, never>
//      ▼
const runnable = Effect.provideService(program, Random, {
  next: Effect.sync(() => Math.random())
})

// Run successfully
Effect.runPromise(runnable)
/*
Example Output:
random number: 0.8241872233134417
*/
```

In the code above, we provide the `program` we defined earlier with an implementation of the `Random` service.

We use the `Effect.provideService` function to associate the `Random` tag with its implementation, an object with a `next` operation that generates a random number.

Notice that the `Requirements` type parameter of the `runnable` effect is now `never`. This indicates that the effect no longer requires any service to be provided.

With the implementation of the `Random` service in place, we are able to run the program without any further requirements.

## Extracting the Service Type

To retrieve the service type from a tag, use the `Context.Tag.Service` utility type.

**Example** (Extracting Service Type)

```ts

// Declaring a tag
class Random extends Context.Tag("MyRandomService")<
  Random,
  { readonly next: Effect.Effect<number> }
>() {}

// Extracting the type
type RandomShape = Context.Tag.Service<Random>
/*
This is equivalent to:
type RandomShape = {
    readonly next: Effect.Effect<number>;
}
*/
```

## Using Multiple Services

When we require the usage of more than one service, the process remains similar to what we've learned in defining a service, repeated for each service needed.

**Example** (Using Random and Logger Services)

Let's examine an example where we need two services, namely `Random` and `Logger`:

```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  {
    readonly next: Effect.Effect<number>
  }
>() {}

// Declaring a tag for the logging service
class Logger extends Context.Tag("MyLoggerService")<
  Logger,
  {
    readonly log: (message: string) => Effect.Effect<void>
  }
>() {}

const program = Effect.gen(function* () {
  // Acquire instances of the 'Random' and 'Logger' services
  const random = yield* Random
  const logger = yield* Logger

  const randomNumber = yield* random.next

  yield* logger.log(String(randomNumber))
})
```

The `program` effect now has a `Requirements` type parameter of `Random | Logger`:

```ts
const program: Effect<void, never, Random | Logger>
```

indicating that it requires both the `Random` and `Logger` services to be provided.

To execute the `program`, we need to provide implementations for both services:

**Example** (Providing Multiple Services)

```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  {
    readonly next: Effect.Effect<number>
  }
>() {}

// Declaring a tag for the logging service
class Logger extends Context.Tag("MyLoggerService")<
  Logger,
  {
    readonly log: (message: string) => Effect.Effect<void>
  }
>() {}

const program = Effect.gen(function* () {
  const random = yield* Random
  const logger = yield* Logger
  const randomNumber = yield* random.next
  return yield* logger.log(String(randomNumber))
})

// Provide service implementations for 'Random' and 'Logger'
const runnable = program.pipe(
  Effect.provideService(Random, {
    next: Effect.sync(() => Math.random())
  }),
  Effect.provideService(Logger, {
    log: (message) => Effect.sync(() => console.log(message))
  })
)
```

Alternatively, instead of calling `provideService` multiple times, we can combine the service implementations into a single `Context` and then provide the entire context using the `Effect.provide` function:

**Example** (Combining Service Implementations)

```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  {
    readonly next: Effect.Effect<number>
  }
>() {}

// Declaring a tag for the logging service
class Logger extends Context.Tag("MyLoggerService")<
  Logger,
  {
    readonly log: (message: string) => Effect.Effect<void>
  }
>() {}

const program = Effect.gen(function* () {
  const random = yield* Random
  const logger = yield* Logger
  const randomNumber = yield* random.next
  return yield* logger.log(String(randomNumber))
})

// Combine service implementations into a single 'Context'
const context = Context.empty().pipe(
  Context.add(Random, { next: Effect.sync(() => Math.random()) }),
  Context.add(Logger, {
    log: (message) => Effect.sync(() => console.log(message))
  })
)

// Provide the entire context
const runnable = Effect.provide(program, context)
```

## Optional Services

There are situations where we may want to access a service implementation only if it is available.
In such cases, we can use the `Effect.serviceOption` function to handle this scenario.

The `Effect.serviceOption` function returns an implementation that is available only if it is actually provided before executing this effect.
To represent this optionality it returns an [Option](/docs/data-types/option/) of the implementation.

**Example** (Handling Optional Services)

To determine what action to take, we can use the `Option.isNone` function provided by the Option module. This function allows us to check if the service is available or not by returning `true` when the service is not available.

```ts

// Declaring a tag for a service that generates random numbers
class Random extends Context.Tag("MyRandomService")<
  Random,
  { readonly next: Effect.Effect<number> }
>() {}

const program = Effect.gen(function* () {
  const maybeRandom = yield* Effect.serviceOption(Random)
  const randomNumber = Option.isNone(maybeRandom)
    ? // the service is not available, return a default value
      -1
    : // the service is available
      yield* maybeRandom.value.next
  console.log(randomNumber)
})
```

In the code above, we can observe that the `Requirements` type parameter of the `program` effect is `never`, even though we are working with a service. This allows us to access something from the context only if it is actually provided before executing this effect.

When we run the `program` effect without providing the `Random` service:

```ts
Effect.runPromise(program).then(console.log)
// Output: -1
```

We see that the log message contains `-1`, which is the default value we provided when the service was not available.

However, if we provide the `Random` service implementation:

```ts
Effect.runPromise(
  Effect.provideService(program, Random, {
    next: Effect.sync(() => Math.random())
  })
).then(console.log)
// Example Output: 0.9957979486841035
```

We can observe that the log message now contains a random number generated by the `next` operation of the `Random` service.

## Handling Services with Dependencies

Sometimes a service in your application may depend on other services. To maintain a clean architecture, it's important to manage these dependencies without making them explicit in the service interface. Instead, you can use **layers** to handle these dependencies during the service construction phase.

**Example** (Defining a Logger Service with a Configuration Dependency)

Consider a scenario where multiple services depend on each other. In this case, the `Logger` service requires access to a configuration service (`Config`).

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<Config, {}>() {}

// Declaring a tag for the logging service
class Logger extends Context.Tag("MyLoggerService")<
  Logger,
  {
    // ❌ Avoid exposing Config as a requirement
    readonly log: (message: string) => Effect.Effect<void, never, Config>
  }
>() {}
```

To handle these dependencies in a structured way and prevent them from leaking into the service interfaces, you can use the `Layer` abstraction. For more details on managing dependencies with layers, refer to the [Managing Layers](/docs/requirements-management/layers/) page.

> **Tip: Use Layers for Dependencies**
  When a service has its own requirements, it's best to separate
  implementation details into layers. Layers act as **constructors for
  creating the service**, allowing us to handle dependencies at the
  construction level rather than the service level.



---

# [Managing Layers](https://effect.website/docs/requirements-management/layers/)

## Overview


In the [Managing Services](/docs/requirements-management/services/) page, you learned how to create effects which depend on some service to be provided in order to execute, as well as how to provide that service to an effect.

However, what if we have a service within our effect program that has dependencies on other services in order to be built? We want to avoid leaking these implementation details into the service interface.

To represent the "dependency graph" of our program and manage these dependencies more effectively, we can utilize a powerful abstraction called "Layer".

Layers act as **constructors for creating services**, allowing us to manage dependencies during construction rather than at the service level. This approach helps to keep our service interfaces clean and focused.

Let's review some key concepts before diving into the details:

| Concept     | Description                                                                                                               |
| ----------- | ------------------------------------------------------------------------------------------------------------------------- |
| **service** | A reusable component providing specific functionality, used across different parts of an application.                     |
| **tag**     | A unique identifier representing a **service**, allowing Effect to locate and use it.                                     |
| **context** | A collection storing services, functioning like a map with **tags** as keys and **services** as values.                   |
| **layer**   | An abstraction for constructing **services**, managing dependencies during construction rather than at the service level. |

## Designing the Dependency Graph

Let's imagine that we are building a web application. We could imagine that the dependency graph for an application where we need to manage configuration, logging, and database access might look something like this:

- The `Config` service provides application configuration.
- The `Logger` service depends on the `Config` service.
- The `Database` service depends on both the `Config` and `Logger` services.

Our goal is to build the `Database` service along with its direct and indirect dependencies. This means we need to ensure that the `Config` service is available for both `Logger` and `Database`, and then provide these dependencies to the `Database` service.

## Avoiding Requirement Leakage

When constructing the `Database` service, it's important to avoid exposing the dependencies on `Config` and `Logger` within the `Database` interface.

You might be tempted to define the `Database` service as follows:

**Example** (Leaking Dependencies in the Service Interface)

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<Config, {}>() {}

// Declaring a tag for the Logger service
class Logger extends Context.Tag("Logger")<Logger, {}>() {}

// Declaring a tag for the Database service
class Database extends Context.Tag("Database")<
  Database,
  {
    // ❌ Avoid exposing Config and Logger as a requirement
    readonly query: (
      sql: string
    ) => Effect.Effect<unknown, never, Config | Logger>
  }
>() {}
```

Here, the `query` function of the `Database` service requires both `Config` and `Logger`. This design leaks implementation details, making the `Database` service aware of its dependencies, which complicates testing and makes it difficult to mock.

> **Tip: Keep Service Interfaces Simple**
  Service functions should avoid requiring dependencies directly. In practice, service operations should have the `Requirements` parameter set to `never`:

```text
                         ┌─── No dependencies required
                         ▼
Effect<Success, Error, never>
```



To demonstrate the problem, let's create a test instance of the `Database` service:

**Example** (Creating a Test Instance with Leaked Dependencies)

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<Config, {}>() {}

// Declaring a tag for the Logger service
class Logger extends Context.Tag("Logger")<Logger, {}>() {}

// Declaring a tag for the Database service
class Database extends Context.Tag("Database")<
  Database,
  {
    readonly query: (
      sql: string
    ) => Effect.Effect<unknown, never, Config | Logger>
  }
>() {}

// Declaring a test instance of the Database service
const DatabaseTest = Database.of({
  // Simulating a simple response
  query: (sql: string) => Effect.succeed([])
})

import * as assert from "node:assert"

// A test that uses the Database service
const test = Effect.gen(function* () {
  const database = yield* Database
  const result = yield* database.query("SELECT * FROM users")
  assert.deepStrictEqual(result, [])
})

//      ┌─── Effect<unknown, never, Config | Logger>
//      ▼
const incompleteTestSetup = test.pipe(
  // Attempt to provide only the Database service without Config and Logger
  Effect.provideService(Database, DatabaseTest)
)
```

Because the `Database` service interface directly includes dependencies on `Config` and `Logger`, it forces any test setup to include these services, even if they're irrelevant to the test. This adds unnecessary complexity and makes it difficult to write simple, isolated unit tests.

Instead of directly tying dependencies to the `Database` service interface, dependencies should be managed at the construction phase.

We can use **layers** to properly construct the `Database` service and manage its dependencies without leaking details into the interface.

> **Tip: Use Layers for Dependencies**
  When a service has its own requirements, it's best to separate
  implementation details into layers. Layers act as **constructors for
  creating the service**, allowing us to handle dependencies at the
  construction level rather than the service level.


## Creating Layers

The `Layer` type is structured as follows:

```text
        ┌─── The service to be created
        │                ┌─── The possible error
        │                │      ┌─── The required dependencies
        ▼                ▼      ▼
Layer<RequirementsOut, Error, RequirementsIn>
```

A `Layer` represents a blueprint for constructing a `RequirementsOut` (the service). It requires a `RequirementsIn` (dependencies) as input and may result in an error of type `Error` during the construction process.

| Parameter         | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| `RequirementsOut` | The service or resource to be created.                                     |
| `Error`           | The type of error that might occur during the construction of the service. |
| `RequirementsIn`  | The dependencies required to construct the service.                        |

By using layers, you can better organize your services, ensuring that their dependencies are clearly defined and separated from their implementation details.

For simplicity, let's assume that we won't encounter any errors during the value construction (meaning `Error = never`).

Now, let's determine how many layers we need to implement our dependency graph:

| Layer          | Dependencies                                               | Type                                       |
| -------------- | ---------------------------------------------------------- | ------------------------------------------ |
| `ConfigLive`   | The `Config` service does not depend on any other services | `Layer<Config>`                            |
| `LoggerLive`   | The `Logger` service depends on the `Config` service       | `Layer<Logger, never, Config>`             |
| `DatabaseLive` | The `Database` service depends on `Config` and `Logger`    | `Layer<Database, never, Config \| Logger>` |

> **Tip: Naming Conventions**
  A common convention when naming the `Layer` for a particular service is
  to add a `Live` suffix for the "live" implementation and a `Test` suffix
  for the "test" implementation. For example, for a `Database` service,
  the `DatabaseLive` would be the layer you provide in your application
  and the `DatabaseTest` would be the layer you provide in your tests.


When a service has multiple dependencies, they are represented as a **union type**. In our case, the `Database` service depends on both the `Config` and `Logger` services. Therefore, the type for the `DatabaseLive` layer will be:

```ts
Layer<Database, never, Config | Logger>
```

### Config

The `Config` service does not depend on any other services, so `ConfigLive` will be the simplest layer to implement. Just like in the [Managing Services](/docs/requirements-management/services/) page, we must create a tag for the service. And because the service has no dependencies, we can create the layer directly using the `Layer.succeed` constructor:

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<
  Config,
  {
    readonly getConfig: Effect.Effect<{
      readonly logLevel: string
      readonly connection: string
    }>
  }
>() {}

// Layer<Config, never, never>
const ConfigLive = Layer.succeed(
  Config,
  Config.of({
    getConfig: Effect.succeed({
      logLevel: "INFO",
      connection: "mysql://username:password@hostname:port/database_name"
    })
  })
)
```

Looking at the type of `ConfigLive` we can observe:

- `RequirementsOut` is `Config`, indicating that constructing the layer will produce a `Config` service
- `Error` is `never`, indicating that layer construction cannot fail
- `RequirementsIn` is `never`, indicating that the layer has no dependencies

Note that, to construct `ConfigLive`, we used the `Config.of`
constructor. However, this is merely a helper to ensure correct type inference
for the implementation. It's possible to skip this helper and construct the
implementation directly as a simple object:

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<
  Config,
  {
    readonly getConfig: Effect.Effect<{
      readonly logLevel: string
      readonly connection: string
    }>
  }
>() {}

// Layer<Config, never, never>
const ConfigLive = Layer.succeed(Config, {
  getConfig: Effect.succeed({
    logLevel: "INFO",
    connection: "mysql://username:password@hostname:port/database_name"
  })
})
```

### Logger

Now we can move on to the implementation of the `Logger` service, which depends on the `Config` service to retrieve some configuration.

Just like we did in the [Managing Services](/docs/requirements-management/services/#using-the-service) page, we can yield the `Config` tag to "extract" the service from the context.

Given that using the `Config` tag is an effectful operation, we use `Layer.effect` to create a layer from the resulting effect.

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<
  Config,
  {
    readonly getConfig: Effect.Effect<{
      readonly logLevel: string
      readonly connection: string
    }>
  }
>() {}

// Layer<Config, never, never>
const ConfigLive = Layer.succeed(Config, {
  getConfig: Effect.succeed({
    logLevel: "INFO",
    connection: "mysql://username:password@hostname:port/database_name"
  })
})

// Declaring a tag for the Logger service
class Logger extends Context.Tag("Logger")<
  Logger,
  { readonly log: (message: string) => Effect.Effect<void> }
>() {}

// Layer<Logger, never, Config>
const LoggerLive = Layer.effect(
  Logger,
  Effect.gen(function* () {
    const config = yield* Config
    return {
      log: (message) =>
        Effect.gen(function* () {
          const { logLevel } = yield* config.getConfig
          console.log(`[${logLevel}] ${message}`)
        })
    }
  })
)
```

Looking at the type of `LoggerLive`:

```ts
Layer<Logger, never, Config>
```

we can observe that:

- `RequirementsOut` is `Logger`
- `Error` is `never`, indicating that layer construction cannot fail
- `RequirementsIn` is `Config`, indicating that the layer has a requirement

### Database

Finally, we can use our `Config` and `Logger` services to implement the `Database` service.

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<
  Config,
  {
    readonly getConfig: Effect.Effect<{
      readonly logLevel: string
      readonly connection: string
    }>
  }
>() {}

// Layer<Config, never, never>
const ConfigLive = Layer.succeed(Config, {
  getConfig: Effect.succeed({
    logLevel: "INFO",
    connection: "mysql://username:password@hostname:port/database_name"
  })
})

// Declaring a tag for the Logger service
class Logger extends Context.Tag("Logger")<
  Logger,
  { readonly log: (message: string) => Effect.Effect<void> }
>() {}

// Layer<Logger, never, Config>
const LoggerLive = Layer.effect(
  Logger,
  Effect.gen(function* () {
    const config = yield* Config
    return {
      log: (message) =>
        Effect.gen(function* () {
          const { logLevel } = yield* config.getConfig
          console.log(`[${logLevel}] ${message}`)
        })
    }
  })
)

// Declaring a tag for the Database service
class Database extends Context.Tag("Database")<
  Database,
  { readonly query: (sql: string) => Effect.Effect<unknown> }
>() {}

// Layer<Database, never, Config | Logger>
const DatabaseLive = Layer.effect(
  Database,
  Effect.gen(function* () {
    const config = yield* Config
    const logger = yield* Logger
    return {
      query: (sql: string) =>
        Effect.gen(function* () {
          yield* logger.log(`Executing query: ${sql}`)
          const { connection } = yield* config.getConfig
          return { result: `Results from ${connection}` }
        })
    }
  })
)
```

Looking at the type of `DatabaseLive`:

```ts
Layer<Database, never, Config | Logger>
```

we can observe that the `RequirementsIn` type is `Config | Logger`, i.e., the `Database` service requires both `Config` and `Logger` services.

## Combining Layers

Layers can be combined in two primary ways: **merging** and **composing**.

### Merging Layers

Layers can be combined through merging using the `Layer.merge` function:

```ts

declare const layer1: Layer.Layer<"Out1", never, "In1">
declare const layer2: Layer.Layer<"Out2", never, "In2">

// Layer<"Out1" | "Out2", never, "In1" | "In2">
const merging = Layer.merge(layer1, layer2)
```

When we merge two layers, the resulting layer:

- requires all the services that both of them require (`"In1" | "In2"`).
- produces all services that both of them produce (`"Out1" | "Out2"`).

For example, in our web application above, we can merge our `ConfigLive` and `LoggerLive` layers into a single `AppConfigLive` layer, which retains the requirements of both layers (`never | Config = Config`) and the outputs of both layers (`Config | Logger`):

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<
  Config,
  {
    readonly getConfig: Effect.Effect<{
      readonly logLevel: string
      readonly connection: string
    }>
  }
>() {}

// Layer<Config, never, never>
const ConfigLive = Layer.succeed(Config, {
  getConfig: Effect.succeed({
    logLevel: "INFO",
    connection: "mysql://username:password@hostname:port/database_name"
  })
})

// Declaring a tag for the Logger service
class Logger extends Context.Tag("Logger")<
  Logger,
  { readonly log: (message: string) => Effect.Effect<void> }
>() {}

// Layer<Logger, never, Config>
const LoggerLive = Layer.effect(
  Logger,
  Effect.gen(function* () {
    const config = yield* Config
    return {
      log: (message) =>
        Effect.gen(function* () {
          const { logLevel } = yield* config.getConfig
          console.log(`[${logLevel}] ${message}`)
        })
    }
  })
)

// Layer<Config | Logger, never, Config>
const AppConfigLive = Layer.merge(ConfigLive, LoggerLive)
```

### Composing Layers

Layers can be composed using the `Layer.provide` function:

```ts

declare const inner: Layer.Layer<"OutInner", never, "InInner">
declare const outer: Layer.Layer<"InInner", never, "InOuter">

// Layer<"OutInner", never, "InOuter">
const composition = Layer.provide(inner, outer)
```

Sequential composition of layers implies that the output of one layer is supplied as the input for the inner layer,
resulting in a single layer with the requirements of the outer layer and the output of the inner.

Now we can compose the `AppConfigLive` layer with the `DatabaseLive` layer:

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<
  Config,
  {
    readonly getConfig: Effect.Effect<{
      readonly logLevel: string
      readonly connection: string
    }>
  }
>() {}

// Layer<Config, never, never>
const ConfigLive = Layer.succeed(Config, {
  getConfig: Effect.succeed({
    logLevel: "INFO",
    connection: "mysql://username:password@hostname:port/database_name"
  })
})

// Declaring a tag for the Logger service
class Logger extends Context.Tag("Logger")<
  Logger,
  { readonly log: (message: string) => Effect.Effect<void> }
>() {}

// Layer<Logger, never, Config>
const LoggerLive = Layer.effect(
  Logger,
  Effect.gen(function* () {
    const config = yield* Config
    return {
      log: (message) =>
        Effect.gen(function* () {
          const { logLevel } = yield* config.getConfig
          console.log(`[${logLevel}] ${message}`)
        })
    }
  })
)

// Declaring a tag for the Database service
class Database extends Context.Tag("Database")<
  Database,
  { readonly query: (sql: string) => Effect.Effect<unknown> }
>() {}

// Layer<Database, never, Config | Logger>
const DatabaseLive = Layer.effect(
  Database,
  Effect.gen(function* () {
    const config = yield* Config
    const logger = yield* Logger
    return {
      query: (sql: string) =>
        Effect.gen(function* () {
          yield* logger.log(`Executing query: ${sql}`)
          const { connection } = yield* config.getConfig
          return { result: `Results from ${connection}` }
        })
    }
  })
)

// Layer<Config | Logger, never, Config>
const AppConfigLive = Layer.merge(ConfigLive, LoggerLive)

// Layer<Database, never, never>
const MainLive = DatabaseLive.pipe(
  // provides the config and logger to the database
  Layer.provide(AppConfigLive),
  // provides the config to AppConfigLive
  Layer.provide(ConfigLive)
)
```

We obtained a `MainLive` layer that produces the `Database` service:

```ts
Layer<Database, never, never>
```

This layer is the fully resolved layer for our application.

### Merging and Composing Layers

Let's say we want our `MainLive` layer to return both the `Config` and `Database` services. We can achieve this with `Layer.provideMerge`:

```ts

// Declaring a tag for the Config service
class Config extends Context.Tag("Config")<
  Config,
  {
    readonly getConfig: Effect.Effect<{
      readonly logLevel: string
      readonly connection: string
    }>
  }
>() {}

const ConfigLive = Layer.succeed(Config, {
  getConfig: Effect.succeed({
    logLevel: "INFO",
    connection: "mysql://username:password@hostname:port/database_name"
  })
})

// Declaring a tag for the Logger service
class Logger extends Context.Tag("Logger")<
  Logger,
  { readonly log: (message: string) => Effect.Effect<void> }
>() {}

const LoggerLive = Layer.effect(
  Logger,
  Effect.gen(function* () {
    const config = yield* Config
    return {
      log: (message) =>
        Effect.gen(function* () {
          const { logLevel } = yield* config.getConfig
          console.log(`[${logLevel}] ${message}`)
        })
    }
  })
)

// Declaring a tag for the Database service
class Database extends Context.Tag("Database")<
  Database,
  { readonly query: (sql: string) => Effect.Effect<unknown> }
>() {}

const DatabaseLive = Layer.effect(
  Database,
  Effect.gen(function* () {
    const config = yield* Config
    const logger = yield* Logger
    return {
      query: (sql: string) =>
        Effect.gen(function* () {
          yield* logger.log(`Executing query: ${sql}`)
          const { connection } = yield* config.getConfig
          return { result: `Results from ${connection}` }
        })
    }
  })
)

// Layer<Config | Logger, never, Config>
const AppConfigLive = Layer.merge(ConfigLive, LoggerLive)

// Layer<Config | Database, never, never>
const MainLive = DatabaseLive.pipe(
  Layer.provide(AppConfigLive),
  Layer.provideMerge(ConfigLive)
)
```

## Providing a Layer to an Effect

Now that we have assembled the fully resolved `MainLive` for our application,
we can provide it to our program to satisfy the program's requirements using `Effect.provide`:

```ts

class Config extends Context.Tag("Config")<
  Config,
  {
    readonly getConfig: Effect.Effect<{
      readonly logLevel: string
      readonly connection: string
    }>
  }
>() {}

const ConfigLive = Layer.succeed(Config, {
  getConfig: Effect.succeed({
    logLevel: "INFO",
    connection: "mysql://username:password@hostname:port/database_name"
  })
})

class Logger extends Context.Tag("Logger")<
  Logger,
  { readonly log: (message: string) => Effect.Effect<void> }
>() {}

const LoggerLive = Layer.effect(
  Logger,
  Effect.gen(function* () {
    const config = yield* Config
    return {
      log: (message) =>
        Effect.gen(function* () {
          const { logLevel } = yield* config.getConfig
          console.log(`[${logLevel}] ${message}`)
        })
    }
  })
)

class Database extends Context.Tag("Database")<
  Database,
  { readonly query: (sql: string) => Effect.Effect<unknown> }
>() {}

const DatabaseLive = Layer.effect(
  Database,
  Effect.gen(function* () {
    const config = yield* Config
    const logger = yield* Logger
    return {
      query: (sql: string) =>
        Effect.gen(function* () {
          yield* logger.log(`Executing query: ${sql}`)
          const { connection } = yield* config.getConfig
          return { result: `Results from ${connection}` }
        })
    }
  })
)

const AppConfigLive = Layer.merge(ConfigLive, LoggerLive)

const MainLive = DatabaseLive.pipe(
  Layer.provide(AppConfigLive),
  Layer.provide(ConfigLive)
)

//      ┌─── Effect<unknown, never, Database>
//      ▼
const program = Effect.gen(function* () {
  const database = yield* Database
  const result = yield* database.query("SELECT * FROM users")
  return result
})

//      ┌─── Effect<unknown, never, never>
//      ▼
const runnable = Effect.provide(program, MainLive)

Effect.runPromise(runnable).then(console.log)
/*
Output:
[INFO] Executing query: SELECT * FROM users
{
  result: 'Results from mysql://username:password@hostname:port/database_name'
}
*/
```

Note that the `runnable` requirements type is `never`, indicating that the program does not require any additional services to run.

## Converting a Layer to an Effect

Sometimes your entire application might be a Layer, for example, an HTTP server. You can convert that layer to an effect with `Layer.launch`. It constructs the layer and keeps it alive until interrupted.

**Example** (Launching an HTTP Server Layer)

```ts

class HTTPServer extends Context.Tag("HTTPServer")<HTTPServer, void>() {}

// Simulating an HTTP server
const server = Layer.effect(
  HTTPServer,
  // Log a message to simulate a server starting
  Console.log("Listening on http://localhost:3000")
)

// Converts the layer to an effect and runs it
Effect.runFork(Layer.launch(server))
/*
Output:
Listening on http://localhost:3000
...
*/
```

## Tapping

The `Layer.tap` and `Layer.tapError` functions allow you to perform additional effects based on the success or failure of a layer. These operations do not modify the layer's signature but are useful for logging or performing side effects during layer construction.

- `Layer.tap`: Executes a specified effect when the layer is successfully acquired.
- `Layer.tapError`: Executes a specified effect when the layer fails to acquire.

**Example** (Logging Success and Failure During Layer Acquisition)

```ts

class HTTPServer extends Context.Tag("HTTPServer")<HTTPServer, void>() {}

// Simulating an HTTP server
const server = Layer.effect(
  HTTPServer,
  Effect.gen(function* () {
    const host = yield* Config.string("HOST")
    console.log(`Listening on http://localhost:${host}`)
  })
).pipe(
  // Log a message if the layer acquisition succeeds
  Layer.tap((ctx) =>
    Console.log(`layer acquisition succeeded with:\n${ctx}`)
  ),
  // Log a message if the layer acquisition fails
  Layer.tapError((err) =>
    Console.log(`layer acquisition failed with:\n${err}`)
  )
)

Effect.runFork(Layer.launch(server))
/*
Output:
layer acquisition failed with:
(Missing data at HOST: "Expected HOST to exist in the process context")
*/
```

## Error Handling

When constructing layers, it is important to handle potential errors. The Effect library provides tools like `Layer.catchAll` and `Layer.orElse` to manage errors and define fallback layers in case of failure.

### catchAll

The `Layer.catchAll` function allows you to recover from errors during layer construction by specifying a fallback layer. This can be useful for handling specific error cases and ensuring the application can continue with an alternative setup.

**Example** (Recovering from Errors During Layer Construction)

```ts

class HTTPServer extends Context.Tag("HTTPServer")<HTTPServer, void>() {}

// Simulating an HTTP server
const server = Layer.effect(
  HTTPServer,
  Effect.gen(function* () {
    const host = yield* Config.string("HOST")
    console.log(`Listening on http://localhost:${host}`)
  })
).pipe(
  // Recover from errors during layer construction
  Layer.catchAll((configError) =>
    Layer.effect(
      HTTPServer,
      Effect.gen(function* () {
        console.log(`Recovering from error:\n${configError}`)
        console.log(`Listening on http://localhost:3000`)
      })
    )
  )
)

Effect.runFork(Layer.launch(server))
/*
Output:
Recovering from error:
(Missing data at HOST: "Expected HOST to exist in the process context")
Listening on http://localhost:3000
...
*/
```

### orElse

The `Layer.orElse` function provides a simpler way to fall back to an alternative layer if the initial layer fails. Unlike `Layer.catchAll`, it does not receive the error as input. Use this when you only need to provide a default layer without reacting to specific errors.

**Example** (Fallback to an Alternative Layer)

```ts

class Database extends Context.Tag("Database")<Database, void>() {}

// Simulating a database connection
const postgresDatabaseLayer = Layer.effect(
  Database,
  Effect.gen(function* () {
    const databaseConnectionString = yield* Config.string(
      "CONNECTION_STRING"
    )
    console.log(
      `Connecting to database with: ${databaseConnectionString}`
    )
  })
)

// Simulating an in-memory database connection
const inMemoryDatabaseLayer = Layer.effect(
  Database,
  Effect.gen(function* () {
    console.log(`Connecting to in-memory database`)
  })
)

// Fallback to in-memory database if PostgreSQL connection fails
const database = postgresDatabaseLayer.pipe(
  Layer.orElse(() => inMemoryDatabaseLayer)
)

Effect.runFork(Layer.launch(database))
/*
Output:
Connecting to in-memory database
...
*/
```

## Simplifying Service Definitions with Effect.Service

The `Effect.Service` API provides a way to define a service in a single step, including its tag and layer.
It also allows specifying dependencies upfront, making service construction more straightforward.

### Defining a Service with Dependencies

The following example defines a `Cache` service that depends on a file system.

**Example** (Defining a Cache Service)

```ts

// Define a Cache service
class Cache extends Effect.Service<Cache>()("app/Cache", {
  // Define how to create the service
  effect: Effect.gen(function* () {
    const fs = yield* FileSystem.FileSystem
    const lookup = (key: string) => fs.readFileString(`cache/${key}`)
    return { lookup } as const
  }),
  // Specify dependencies
  dependencies: [NodeFileSystem.layer]
}) {}
```

### Using the Generated Layers

The `Effect.Service` API automatically generates layers for the service.

| Layer                              | Description                                                                       |
| ---------------------------------- | --------------------------------------------------------------------------------- |
| `Cache.Default`                    | Provides the `Cache` service with its dependencies already included.              |
| `Cache.DefaultWithoutDependencies` | Provides the `Cache` service but requires dependencies to be provided separately. |

```ts

// Define a Cache service
class Cache extends Effect.Service<Cache>()("app/Cache", {
  effect: Effect.gen(function* () {
    const fs = yield* FileSystem.FileSystem
    const lookup = (key: string) => fs.readFileString(`cache/${key}`)
    return { lookup } as const
  }),
  dependencies: [NodeFileSystem.layer]
}) {}

// Layer that includes all required dependencies
//
//      ┌─── Layer<Cache>
//      ▼
const layer = Cache.Default

// Layer without dependencies, requiring them to be provided externally
//
//      ┌─── Layer.Layer<Cache, never, FileSystem>
//      ▼
const layerNoDeps = Cache.DefaultWithoutDependencies
```

### Accessing the Service

A service created with `Effect.Service` can be accessed like any other Effect service.

**Example** (Accessing the Cache Service)

```ts

// Define a Cache service
class Cache extends Effect.Service<Cache>()("app/Cache", {
  effect: Effect.gen(function* () {
    const fs = yield* FileSystem.FileSystem
    const lookup = (key: string) => fs.readFileString(`cache/${key}`)
    return { lookup } as const
  }),
  dependencies: [NodeFileSystem.layer]
}) {}

// Accessing the Cache Service
const program = Effect.gen(function* () {
  const cache = yield* Cache
  const data = yield* cache.lookup("my-key")
  console.log(data)
}).pipe(Effect.catchAllCause((cause) => Console.log(cause)))

const runnable = program.pipe(Effect.provide(Cache.Default))

Effect.runFork(runnable)
/*
{
  _id: 'Cause',
  _tag: 'Fail',
  failure: {
    _tag: 'SystemError',
    reason: 'NotFound',
    module: 'FileSystem',
    method: 'readFile',
    pathOrDescriptor: 'cache/my-key',
    syscall: 'open',
    message: "ENOENT: no such file or directory, open 'cache/my-key'",
    [Symbol(@effect/platform/Error/PlatformErrorTypeId)]: Symbol(@effect/platform/Error/PlatformErrorTypeId)
  }
}
*/
```

Since this example uses `Cache.Default`, it interacts with the real file system. If the file does not exist, it results in an error.

### Injecting Test Dependencies

To test the program without depending on the real file system, we can inject a test file system using the `Cache.DefaultWithoutDependencies` layer.

**Example** (Using a Test File System)

```ts

// Define a Cache service
class Cache extends Effect.Service<Cache>()("app/Cache", {
  effect: Effect.gen(function* () {
    const fs = yield* FileSystem.FileSystem
    const lookup = (key: string) => fs.readFileString(`cache/${key}`)
    return { lookup } as const
  }),
  dependencies: [NodeFileSystem.layer]
}) {}

// Accessing the Cache Service
const program = Effect.gen(function* () {
  const cache = yield* Cache
  const data = yield* cache.lookup("my-key")
  console.log(data)
}).pipe(Effect.catchAllCause((cause) => Console.log(cause)))

// Create a test file system that always returns a fixed value
const FileSystemTest = FileSystem.layerNoop({
  readFileString: () => Effect.succeed("File Content...")
})

const runnable = program.pipe(
  Effect.provide(Cache.DefaultWithoutDependencies),
  // Provide the mock file system
  Effect.provide(FileSystemTest)
)

Effect.runFork(runnable)
// Output: File Content...
```

### Mocking the Service Directly

Alternatively, you can mock the `Cache` service itself instead of replacing its dependencies.

**Example** (Mocking the Cache Service)

```ts

// Define a Cache service
class Cache extends Effect.Service<Cache>()("app/Cache", {
  effect: Effect.gen(function* () {
    const fs = yield* FileSystem.FileSystem
    const lookup = (key: string) => fs.readFileString(`cache/${key}`)
    return { lookup } as const
  }),
  dependencies: [NodeFileSystem.layer]
}) {}

// Accessing the Cache Service
const program = Effect.gen(function* () {
  const cache = yield* Cache
  const data = yield* cache.lookup("my-key")
  console.log(data)
}).pipe(Effect.catchAllCause((cause) => Console.log(cause)))

// Create a mock implementation of Cache
const cache = new Cache({
  lookup: () => Effect.succeed("Cache Content...")
})

// Provide the mock Cache service
const runnable = program.pipe(Effect.provideService(Cache, cache))

Effect.runFork(runnable)
// Output: File Content...
```

### Alternative Ways to Define a Service

The `Effect.Service` API supports multiple ways to define a service:

| Method    | Description                                        |
| --------- | -------------------------------------------------- |
| `succeed` | Provides a static implementation of the service.   |
| `sync`    | Defines a service using a synchronous constructor. |
| `effect`  | Defines a service with an effectful constructor.   |
| `scoped`  | Creates a service with lifecycle management.       |

**Example** (Defining a Service with a Static Implementation)

This is the simplest way to define a service. It is useful when you want to provide a constant value for the service.

```ts

class MagicNumber extends Effect.Service<MagicNumber>()("MagicNumber", {
  succeed: { value: 42 }
}) {}

//      ┌─── Effect<void, never, MagicNumber>
//      ▼
const program = Effect.gen(function* () {
  const magicNumber = yield* MagicNumber
  console.log(`The magic number is ${magicNumber.value}`)
})

Effect.runPromise(program.pipe(Effect.provide(MagicNumber.Default)))
// The magic number is 42
```

**Example** (Defining a Service with a Synchronous Constructor)

```ts

class Sync extends Effect.Service<Sync>()("Sync", {
  sync: () => ({
    next: Random.nextInt
  })
}) {}

//      ┌─── Effect<void, never, Sync>
//      ▼
const program = Effect.gen(function* () {
  const sync = yield* Sync
  const n = yield* sync.next
  console.log(`The number is ${n}`)
})

Effect.runPromise(program.pipe(Effect.provide(Sync.Default)))
// Example Output: The number is 3858843290019673
```

**Example** (Managing a Service with Lifecycle Control)

```ts

class Scoped extends Effect.Service<Scoped>()("Scoped", {
  scoped: Effect.gen(function* () {
    // Acquire the resource and ensure it is properly released
    const resource = yield* Effect.acquireRelease(
      Console.log("Aquiring...").pipe(Effect.as("foo")),
      () => Console.log("Releasing...")
    )
    // Register a finalizer to run when the effect is completed
    yield* Effect.addFinalizer(() => Console.log("Shutting down"))
    return { resource }
  })
}) {}

//      ┌─── Effect<void, never, Scoped>
//      ▼
const program = Effect.gen(function* () {
  const resource = (yield* Scoped).resource
  console.log(`The resource is ${resource}`)
})

Effect.runPromise(
  program.pipe(
    Effect.provide(
      //       ┌─── Layer<Scoped, never, never>
      //       ▼
      Scoped.Default
    )
  )
)
/*
Aquiring...
The resource is foo
Shutting down
Releasing...
*/
```

The `Scoped.Default` layer does not require `Scope` as a dependency, since `Scoped` itself manages its lifecycle.

### Enabling Direct Method Access

By setting `accessors: true`, you can call service methods directly using the service tag instead of first extracting the service.

**Example** (Defining a Service with Direct Method Access)

```ts

class Sync extends Effect.Service<Sync>()("Sync", {
  sync: () => ({
    next: Random.nextInt
  }),
  accessors: true // Enables direct method access via the tag
}) {}

const program = Effect.gen(function* () {
  // const sync = yield* Sync
  // const n = yield* sync.next
  const n = yield* Sync.next // No need to extract the service first
  console.log(`The number is ${n}`)
})

Effect.runPromise(program.pipe(Effect.provide(Sync.Default)))
// Example Output: The number is 3858843290019673
```

> **Caution: Limitation of Direct Method Access**
  Direct method access does not work with generic methods.


### Effect.Service vs Context.Tag

Both `Effect.Service` and `Context.Tag` are ways to model services in the Effect ecosystem. They serve similar purposes but target different use-cases.

| Feature                             | Effect.Service                                          | Context.Tag                               |
| ----------------------------------- | ------------------------------------------------------- | ----------------------------------------- |
| Tag creation                        | Generated for you (the class name acts as the tag)      | You declare the tag manually              |
| Default implementation              | **Required** - supplied inline (`effect`, `sync`, etc.) | **Optional** - can be supplied later      |
| Ready-made layers (`.Default`, ...) | Automatically generated                                 | You build layers yourself                 |
| Best suited for                     | Application code with a clear runtime implementation    | Library code or dynamically-scoped values |
| When no sensible default exists     | Not ideal; you would still have to invent one           | Preferred                                 |

**Key points**

- **Less boilerplate:** `Effect.Service` is syntactic sugar over `Context.Tag` plus the accompanying layer and helpers.
- **Default required:**
  A class that extends `Effect.Service` must declare **one** of the built-in constructors (`effect`, `sync`, `succeed`, or `scoped`). This baseline implementation becomes part of `MyService.Default`, so any code that imports the service can run without providing extra layers.
  That is handy for app-level services where a sensible runtime implementation exists (logging, HTTP clients, real databases, and so on).
  If your service is inherently contextual (for example, a per-request database handle) or you are writing a library that should not assume an implementation, prefer `Context.Tag`: you publish only the tag and let callers supply the layer that makes sense in their environment.
- **The class _is_ the tag:** When you create a class with `extends Effect.Service`, the class constructor itself acts as the tag. You can provide alternate implementations by supplying a value for that class when wiring layers:

  ```ts
  const mock = new MyService({
    /* mocked methods */
  })
  program.pipe(Effect.provideService(MyService, mock))
  ```


---

# [Layer Memoization](https://effect.website/docs/requirements-management/layer-memoization/)

## Overview


Layer memoization allows a layer to be created once and used multiple times in the dependency graph. If we use the same layer twice:

```ts
Layer.merge(Layer.provide(L2, L1), Layer.provide(L3, L1))
```

then the `L1` layer will be allocated only once.

> **Caution: Avoid Duplicate Layer Creation**
  Layers are memoized using **reference equality**. Therefore, if you have
  a layer that is created by calling a function like `f()`, you should
  _only_ call that `f` once and re-use the resulting layer so that you are
  always using the same instance.


## Memoization When Providing Globally

One important feature of an Effect application is that layers are shared by default. This means that if the same layer is used twice, and if we provide the layer globally, the layer will only be allocated a single time. For every layer in our dependency graph, there is only one instance of it that is shared between all the layers that depend on it.

**Example**

For example, assume we have the three services `A`, `B`, and `C`. The implementation of both `B` and `C` is dependent on the `A` service:

```ts

class A extends Context.Tag("A")<A, { readonly a: number }>() {}

class B extends Context.Tag("B")<B, { readonly b: string }>() {}

class C extends Context.Tag("C")<C, { readonly c: boolean }>() {}

const ALive = Layer.effect(
  A,
  Effect.succeed({ a: 5 }).pipe(
    Effect.tap(() => Effect.log("initialized"))
  )
)

const BLive = Layer.effect(
  B,
  Effect.gen(function* () {
    const { a } = yield* A
    return { b: String(a) }
  })
)

const CLive = Layer.effect(
  C,
  Effect.gen(function* () {
    const { a } = yield* A
    return { c: a > 0 }
  })
)

const program = Effect.gen(function* () {
  yield* B
  yield* C
})

const runnable = Effect.provide(
  program,
  Layer.merge(Layer.provide(BLive, ALive), Layer.provide(CLive, ALive))
)

Effect.runPromise(runnable)
/*
Output:
timestamp=... level=INFO fiber=#2 message=initialized
*/
```

Although both `BLive` and `CLive` layers require the `ALive` layer, the `ALive` layer is instantiated only once. It is shared with both `BLive` and `CLive`.

## Acquiring a Fresh Version

If we don't want to share a module, we should create a fresh, non-shared version of it through `Layer.fresh`.

**Example**

```ts

class A extends Context.Tag("A")<A, { readonly a: number }>() {}

class B extends Context.Tag("B")<B, { readonly b: string }>() {}

class C extends Context.Tag("C")<C, { readonly c: boolean }>() {}

const ALive = Layer.effect(
  A,
  Effect.succeed({ a: 5 }).pipe(
    Effect.tap(() => Effect.log("initialized"))
  )
)

const BLive = Layer.effect(
  B,
  Effect.gen(function* () {
    const { a } = yield* A
    return { b: String(a) }
  })
)

const CLive = Layer.effect(
  C,
  Effect.gen(function* () {
    const { a } = yield* A
    return { c: a > 0 }
  })
)

const program = Effect.gen(function* () {
  yield* B
  yield* C
})

const runnable = Effect.provide(
  program,
  Layer.merge(
    Layer.provide(BLive, Layer.fresh(ALive)),
    Layer.provide(CLive, Layer.fresh(ALive))
  )
)

Effect.runPromise(runnable)
/*
Output:
timestamp=... level=INFO fiber=#2 message=initialized
timestamp=... level=INFO fiber=#3 message=initialized
*/
```

## No Memoization When Providing Locally

If we don't provide a layer globally but instead provide them locally, that layer doesn't support memoization by default.

**Example**

In the following example, we provided the `ALive` layer two times locally, and Effect doesn't memoize the construction of the `ALive` layer.
So, it will be initialized two times:

```ts

class A extends Context.Tag("A")<A, { readonly a: number }>() {}

const Alive = Layer.effect(
  A,
  Effect.succeed({ a: 5 }).pipe(
    Effect.tap(() => Effect.log("initialized"))
  )
)

const program = Effect.gen(function* () {
  yield* Effect.provide(A, Alive)
  yield* Effect.provide(A, Alive)
})

Effect.runPromise(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message=initialized
timestamp=... level=INFO fiber=#0 message=initialized
*/
```

## Manual Memoization

We can memoize a layer manually using the `Layer.memoize` function.
It will return a scoped effect that, if evaluated, will return the lazily computed result of this layer.

**Example**

```ts

class A extends Context.Tag("A")<A, { readonly a: number }>() {}

const ALive = Layer.effect(
  A,
  Effect.succeed({ a: 5 }).pipe(
    Effect.tap(() => Effect.log("initialized"))
  )
)

const program = Effect.scoped(
  Layer.memoize(ALive).pipe(
    Effect.andThen((memoized) =>
      Effect.gen(function* () {
        yield* Effect.provide(A, memoized)
        yield* Effect.provide(A, memoized)
      })
    )
  )
)

Effect.runPromise(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message=initialized
*/
```


---

# [Default Services](https://effect.website/docs/requirements-management/default-services/)

## Overview

Effect comes equipped with five pre-built services:

```ts
type DefaultServices = Clock | ConfigProvider | Console | Random | Tracer
```

When we employ these services, there's no need to explicitly provide their implementations. Effect automatically supplies live versions of these services to our effects, sparing us from manual setup.

**Example** (Using Clock and Console)

```ts

//      ┌─── Effect<void, never, never>
//      ▼
const program = Effect.gen(function* () {
  const now = yield* Clock.currentTimeMillis
  yield* Console.log(`Application started at ${new Date(now)}`)
})

Effect.runFork(program)
// Output: Application started at <current time>
```

As you can observe, even if our program utilizes both `Clock` and `Console`, the `Requirements` parameter, representing the services required for the effect to execute, remains set to `never`.
Effect takes care of handling these services seamlessly for us.

## Overriding Default Services

Sometimes, you might need to replace the default services with custom implementations. Effect provides built-in utilities to override these services using `Effect.with<service>` and `Effect.with<service>Scoped`.

- `Effect.with<service>`: Overrides a service for the duration of the effect.
- `Effect.with<service>Scoped`: Overrides a service within a scope and restores the original service afterward.

| Function                          | Description                                                                    |
| --------------------------------- | ------------------------------------------------------------------------------ |
| `Effect.withClock`                | Executes an effect using a specific `Clock` service.                           |
| `Effect.withClockScoped`          | Temporarily overrides the `Clock` service and restores it when the scope ends. |
| `Effect.withConfigProvider`       | Executes an effect using a specific `ConfigProvider` service.                  |
| `Effect.withConfigProviderScoped` | Temporarily overrides the `ConfigProvider` service within a scope.             |
| `Effect.withConsole`              | Executes an effect using a specific `Console` service.                         |
| `Effect.withConsoleScoped`        | Temporarily overrides the `Console` service within a scope.                    |
| `Effect.withRandom`               | Executes an effect using a specific `Random` service.                          |
| `Effect.withRandomScoped`         | Temporarily overrides the `Random` service within a scope.                     |
| `Effect.withTracer`               | Executes an effect using a specific `Tracer` service.                          |
| `Effect.withTracerScoped`         | Temporarily overrides the `Tracer` service within a scope.                     |

**Example** (Overriding Random Service)

```ts

// A program that logs a random number
const program = Effect.gen(function* () {
  console.log(yield* Random.next)
})

Effect.runSync(program)
// Example Output: 0.23208633934454326 (varies each run)

// Override the Random service with a seeded generator
const override = program.pipe(Effect.withRandom(Random.make("myseed")))

Effect.runSync(override)
// Output: 0.6862142528438508 (consistent output with the seed)
```


---


## Common Mistakes

**Incorrect (hardcoded dependencies):**

```ts
import { PrismaClient } from "@prisma/client"
const db = new PrismaClient() // Global, untestable

const getUser = (id: string) => Effect.tryPromise(() => db.user.findUnique({ where: { id } }))
```

**Correct (using services for dependency injection):**

```ts
class Database extends Context.Tag("Database")<
  Database,
  { readonly findUser: (id: string) => Effect.Effect<User, NotFound> }
>() {}

const getUser = (id: string) =>
  Database.pipe(Effect.flatMap((db) => db.findUser(id)))
```
