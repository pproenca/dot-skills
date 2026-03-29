---
title: "Core Concepts"
impact: MEDIUM
impactDescription: "Optimizes Effect application architecture — covers request batching, configuration, runtime"
tags: core, batching, configuration, runtime
---
# [Batching](https://effect.website/docs/batching/)

## Overview


In typical application development, when interacting with external APIs, databases, or other data sources, we often define functions that perform requests and handle their results or failures accordingly.

### Simple Model Setup

Here's a basic model that outlines the structure of our data and possible errors:

```ts

// ------------------------------
// Model
// ------------------------------

interface User {
  readonly _tag: "User"
  readonly id: number
  readonly name: string
  readonly email: string
}

class GetUserError extends Data.TaggedError("GetUserError")<{}> {}

interface Todo {
  readonly _tag: "Todo"
  readonly id: number
  readonly message: string
  readonly ownerId: number
}

class GetTodosError extends Data.TaggedError("GetTodosError")<{}> {}

class SendEmailError extends Data.TaggedError("SendEmailError")<{}> {}
```

> **Tip: Use Precise Types and Detailed Errors**
  In a real world scenario we may want to use a more precise types instead
  of directly using primitives for identifiers (see [Branded
  Types](/docs/code-style/branded-types/)). Additionally, you may want to
  include more detailed information in the errors.


### Defining API Functions

Let's define functions that interact with an external API, handling common operations such as fetching todos, retrieving user details, and sending emails.

```ts

// ------------------------------
// Model
// ------------------------------

interface User {
  readonly _tag: "User"
  readonly id: number
  readonly name: string
  readonly email: string
}

class GetUserError extends Data.TaggedError("GetUserError")<{}> {}

interface Todo {
  readonly _tag: "Todo"
  readonly id: number
  readonly message: string
  readonly ownerId: number
}

class GetTodosError extends Data.TaggedError("GetTodosError")<{}> {}

class SendEmailError extends Data.TaggedError("SendEmailError")<{}> {}

// ------------------------------
// API
// ------------------------------

// Fetches a list of todos from an external API
const getTodos = Effect.tryPromise({
  try: () =>
    fetch("https://api.example.demo/todos").then(
      (res) => res.json() as Promise<Array<Todo>>
    ),
  catch: () => new GetTodosError()
})

// Retrieves a user by their ID from an external API
const getUserById = (id: number) =>
  Effect.tryPromise({
    try: () =>
      fetch(`https://api.example.demo/getUserById?id=${id}`).then(
        (res) => res.json() as Promise<User>
      ),
    catch: () => new GetUserError()
  })

// Sends an email via an external API
const sendEmail = (address: string, text: string) =>
  Effect.tryPromise({
    try: () =>
      fetch("https://api.example.demo/sendEmail", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ address, text })
      }).then((res) => res.json() as Promise<void>),
    catch: () => new SendEmailError()
  })

// Sends an email to a user by fetching their details first
const sendEmailToUser = (id: number, message: string) =>
  getUserById(id).pipe(
    Effect.andThen((user) => sendEmail(user.email, message))
  )

// Notifies the owner of a todo by sending them an email
const notifyOwner = (todo: Todo) =>
  getUserById(todo.ownerId).pipe(
    Effect.andThen((user) =>
      sendEmailToUser(user.id, `hey ${user.name} you got a todo!`)
    )
  )
```

> **Tip: Validating API Responses**
  In a real-world scenario, you might not want to trust your APIs to
  always return the expected data - for this, you can use
  [`effect/Schema`](/docs/schema/introduction/) or similar alternatives
  such as `zod`.


While this approach is straightforward and readable, it may not be the most efficient. Repeated API calls, especially when many todos share the same owner, can significantly increase network overhead and slow down your application.

### Using the API Functions

While these functions are clear and easy to understand, their use may not be the most efficient. For example, notifying todo owners involves repeated API calls which can be optimized.

```ts

// ------------------------------
// Model
// ------------------------------

interface User {
  readonly _tag: "User"
  readonly id: number
  readonly name: string
  readonly email: string
}

class GetUserError extends Data.TaggedError("GetUserError")<{}> {}

interface Todo {
  readonly _tag: "Todo"
  readonly id: number
  readonly message: string
  readonly ownerId: number
}

class GetTodosError extends Data.TaggedError("GetTodosError")<{}> {}

class SendEmailError extends Data.TaggedError("SendEmailError")<{}> {}

// ------------------------------
// API
// ------------------------------

// Fetches a list of todos from an external API
const getTodos = Effect.tryPromise({
  try: () =>
    fetch("https://api.example.demo/todos").then(
      (res) => res.json() as Promise<Array<Todo>>
    ),
  catch: () => new GetTodosError()
})

// Retrieves a user by their ID from an external API
const getUserById = (id: number) =>
  Effect.tryPromise({
    try: () =>
      fetch(`https://api.example.demo/getUserById?id=${id}`).then(
        (res) => res.json() as Promise<User>
      ),
    catch: () => new GetUserError()
  })

// Sends an email via an external API
const sendEmail = (address: string, text: string) =>
  Effect.tryPromise({
    try: () =>
      fetch("https://api.example.demo/sendEmail", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ address, text })
      }).then((res) => res.json() as Promise<void>),
    catch: () => new SendEmailError()
  })

// Sends an email to a user by fetching their details first
const sendEmailToUser = (id: number, message: string) =>
  getUserById(id).pipe(
    Effect.andThen((user) => sendEmail(user.email, message))
  )

// Notifies the owner of a todo by sending them an email
const notifyOwner = (todo: Todo) =>
  getUserById(todo.ownerId).pipe(
    Effect.andThen((user) =>
      sendEmailToUser(user.id, `hey ${user.name} you got a todo!`)
    )
  )

// Orchestrates operations on todos, notifying their owners
const program = Effect.gen(function* () {
  const todos = yield* getTodos
  yield* Effect.forEach(todos, (todo) => notifyOwner(todo), {
    concurrency: "unbounded"
  })
})
```

This implementation performs an API call for each todo to fetch the owner's details and send an email. If multiple todos have the same owner, this results in redundant API calls.

> **Tip: Improving Efficiency with Batch Calls**
  To optimize, consider implementing batch API calls if your backend
  supports them. This reduces the number of HTTP requests by grouping
  multiple operations into a single request, thereby enhancing performance
  and reducing load.


## Batching

Let's assume that `getUserById` and `sendEmail` can be batched. This means that we can send multiple requests in a single HTTP call, reducing the number of API requests and improving performance.

**Step-by-Step Guide to Batching**

1. **Declaring Requests:** We'll start by transforming our requests into structured data models. This involves detailing input parameters, expected outputs, and possible errors. Structuring requests this way not only helps in efficiently managing data but also in comparing different requests to understand if they refer to the same input parameters.

2. **Declaring Resolvers:** Resolvers are designed to handle multiple requests simultaneously. By leveraging the ability to compare requests (ensuring they refer to the same input parameters), resolvers can execute several requests in one go, maximizing the utility of batching.

3. **Defining Queries:** Finally, we'll define queries that utilize these batch-resolvers to perform operations. This step ties together the structured requests and their corresponding resolvers into functional components of the application.

> **Caution: Ensuring Request Comparability**
  It's crucial for the requests to be modeled in a way that allows them to
  be comparable. This means implementing comparability (using methods like
  [Equals.equals](/docs/trait/equal/)) to identify and batch identical
  requests effectively.


### Declaring Requests

We'll design a model using the concept of a `Request` that a data source might support:

```ts
Request<Value, Error>
```

A `Request` is a construct representing a request for a value of type `Value`, which might fail with an error of type `Error`.

Let's start by defining a structured model for the types of requests our data sources can handle.

```ts

// ------------------------------
// Model
// ------------------------------

interface User {
  readonly _tag: "User"
  readonly id: number
  readonly name: string
  readonly email: string
}

class GetUserError extends Data.TaggedError("GetUserError")<{}> {}

interface Todo {
  readonly _tag: "Todo"
  readonly id: number
  readonly message: string
  readonly ownerId: number
}

class GetTodosError extends Data.TaggedError("GetTodosError")<{}> {}

class SendEmailError extends Data.TaggedError("SendEmailError")<{}> {}

// ------------------------------
// Requests
// ------------------------------

// Define a request to get multiple Todo items which might
// fail with a GetTodosError
interface GetTodos extends Request.Request<Array<Todo>, GetTodosError> {
  readonly _tag: "GetTodos"
}

// Create a tagged constructor for GetTodos requests
const GetTodos = Request.tagged<GetTodos>("GetTodos")

// Define a request to fetch a User by ID which might
// fail with a GetUserError
interface GetUserById extends Request.Request<User, GetUserError> {
  readonly _tag: "GetUserById"
  readonly id: number
}

// Create a tagged constructor for GetUserById requests
const GetUserById = Request.tagged<GetUserById>("GetUserById")

// Define a request to send an email which might
// fail with a SendEmailError
interface SendEmail extends Request.Request<void, SendEmailError> {
  readonly _tag: "SendEmail"
  readonly address: string
  readonly text: string
}

// Create a tagged constructor for SendEmail requests
const SendEmail = Request.tagged<SendEmail>("SendEmail")
```

Each request is defined with a specific data structure that extends from a generic `Request` type, ensuring that each request carries its unique data requirements along with a specific error type.

By using tagged constructors like `Request.tagged`, we can easily instantiate request objects that are recognizable and manageable throughout the application.

### Declaring Resolvers

After defining our requests, the next step is configuring how Effect resolves these requests using `RequestResolver`:

```ts
RequestResolver<A, R>
```

A `RequestResolver` requires an environment `R` and is capable of executing requests of type `A`.

In this section, we'll create individual resolvers for each type of request. The granularity of your resolvers can vary, but typically, they are divided based on the batching capabilities of the corresponding API calls.

```ts

// ------------------------------
// Model
// ------------------------------

interface User {
  readonly _tag: "User"
  readonly id: number
  readonly name: string
  readonly email: string
}

class GetUserError extends Data.TaggedError("GetUserError")<{}> {}

interface Todo {
  readonly _tag: "Todo"
  readonly id: number
  readonly message: string
  readonly ownerId: number
}

class GetTodosError extends Data.TaggedError("GetTodosError")<{}> {}

class SendEmailError extends Data.TaggedError("SendEmailError")<{}> {}

// ------------------------------
// Requests
// ------------------------------

// Define a request to get multiple Todo items which might
// fail with a GetTodosError
interface GetTodos extends Request.Request<Array<Todo>, GetTodosError> {
  readonly _tag: "GetTodos"
}

// Create a tagged constructor for GetTodos requests
const GetTodos = Request.tagged<GetTodos>("GetTodos")

// Define a request to fetch a User by ID which might
// fail with a GetUserError
interface GetUserById extends Request.Request<User, GetUserError> {
  readonly _tag: "GetUserById"
  readonly id: number
}

// Create a tagged constructor for GetUserById requests
const GetUserById = Request.tagged<GetUserById>("GetUserById")

// Define a request to send an email which might
// fail with a SendEmailError
interface SendEmail extends Request.Request<void, SendEmailError> {
  readonly _tag: "SendEmail"
  readonly address: string
  readonly text: string
}

// Create a tagged constructor for SendEmail requests
const SendEmail = Request.tagged<SendEmail>("SendEmail")

// ------------------------------
// Resolvers
// ------------------------------

// Assuming GetTodos cannot be batched, we create a standard resolver
const GetTodosResolver = RequestResolver.fromEffect(
  (_: GetTodos): Effect.Effect<Todo[], GetTodosError> =>
    Effect.tryPromise({
      try: () =>
        fetch("https://api.example.demo/todos").then(
          (res) => res.json() as Promise<Array<Todo>>
        ),
      catch: () => new GetTodosError()
    })
)

// Assuming GetUserById can be batched, we create a batched resolver
const GetUserByIdResolver = RequestResolver.makeBatched(
  (requests: ReadonlyArray<GetUserById>) =>
    Effect.tryPromise({
      try: () =>
        fetch("https://api.example.demo/getUserByIdBatch", {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            users: requests.map(({ id }) => ({ id }))
          })
        }).then((res) => res.json()) as Promise<Array<User>>,
      catch: () => new GetUserError()
    }).pipe(
      Effect.andThen((users) =>
        Effect.forEach(requests, (request, index) =>
          Request.completeEffect(request, Effect.succeed(users[index]!))
        )
      ),
      Effect.catchAll((error) =>
        Effect.forEach(requests, (request) =>
          Request.completeEffect(request, Effect.fail(error))
        )
      )
    )
)

// Assuming SendEmail can be batched, we create a batched resolver
const SendEmailResolver = RequestResolver.makeBatched(
  (requests: ReadonlyArray<SendEmail>) =>
    Effect.tryPromise({
      try: () =>
        fetch("https://api.example.demo/sendEmailBatch", {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            emails: requests.map(({ address, text }) => ({
              address,
              text
            }))
          })
        }).then((res) => res.json() as Promise<void>),
      catch: () => new SendEmailError()
    }).pipe(
      Effect.andThen(
        Effect.forEach(requests, (request) =>
          Request.completeEffect(request, Effect.void)
        )
      ),
      Effect.catchAll((error) =>
        Effect.forEach(requests, (request) =>
          Request.completeEffect(request, Effect.fail(error))
        )
      )
    )
)
```

> **Tip: Accessing Context in Resolvers**
  Resolvers can also access the context like any other effect, and there
  are many different ways to create resolvers. For further details,
  consider exploring the reference documentation for the
  [RequestResolver](https://effect-ts.github.io/effect/effect/RequestResolver.ts.html)
  module.


In this configuration:

- **GetTodosResolver** handles the fetching of multiple `Todo` items. It's set up as a standard resolver since we assume it cannot be batched.
- **GetUserByIdResolver** and **SendEmailResolver** are configured as batched resolvers. This setup is based on the assumption that these requests can be processed in batches, enhancing performance and reducing the number of API calls.

### Defining Queries

Now that we've set up our resolvers, we're ready to tie all the pieces together to define our queries. This step will enable us to perform data operations effectively within our application.

```ts

// ------------------------------
// Model
// ------------------------------

interface User {
  readonly _tag: "User"
  readonly id: number
  readonly name: string
  readonly email: string
}

class GetUserError extends Data.TaggedError("GetUserError")<{}> {}

interface Todo {
  readonly _tag: "Todo"
  readonly id: number
  readonly message: string
  readonly ownerId: number
}

class GetTodosError extends Data.TaggedError("GetTodosError")<{}> {}

class SendEmailError extends Data.TaggedError("SendEmailError")<{}> {}

// ------------------------------
// Requests
// ------------------------------

// Define a request to get multiple Todo items which might
// fail with a GetTodosError
interface GetTodos extends Request.Request<Array<Todo>, GetTodosError> {
  readonly _tag: "GetTodos"
}

// Create a tagged constructor for GetTodos requests
const GetTodos = Request.tagged<GetTodos>("GetTodos")

// Define a request to fetch a User by ID which might
// fail with a GetUserError
interface GetUserById extends Request.Request<User, GetUserError> {
  readonly _tag: "GetUserById"
  readonly id: number
}

// Create a tagged constructor for GetUserById requests
const GetUserById = Request.tagged<GetUserById>("GetUserById")

// Define a request to send an email which might
// fail with a SendEmailError
interface SendEmail extends Request.Request<void, SendEmailError> {
  readonly _tag: "SendEmail"
  readonly address: string
  readonly text: string
}

// Create a tagged constructor for SendEmail requests
const SendEmail = Request.tagged<SendEmail>("SendEmail")

// ------------------------------
// Resolvers
// ------------------------------

// Assuming GetTodos cannot be batched, we create a standard resolver
const GetTodosResolver = RequestResolver.fromEffect(
  (_: GetTodos): Effect.Effect<Todo[], GetTodosError> =>
    Effect.tryPromise({
      try: () =>
        fetch("https://api.example.demo/todos").then(
          (res) => res.json() as Promise<Array<Todo>>
        ),
      catch: () => new GetTodosError()
    })
)

// Assuming GetUserById can be batched, we create a batched resolver
const GetUserByIdResolver = RequestResolver.makeBatched(
  (requests: ReadonlyArray<GetUserById>) =>
    Effect.tryPromise({
      try: () =>
        fetch("https://api.example.demo/getUserByIdBatch", {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            users: requests.map(({ id }) => ({ id }))
          })
        }).then((res) => res.json()) as Promise<Array<User>>,
      catch: () => new GetUserError()
    }).pipe(
      Effect.andThen((users) =>
        Effect.forEach(requests, (request, index) =>
          Request.completeEffect(request, Effect.succeed(users[index]!))
        )
      ),
      Effect.catchAll((error) =>
        Effect.forEach(requests, (request) =>
          Request.completeEffect(request, Effect.fail(error))
        )
      )
    )
)

// Assuming SendEmail can be batched, we create a batched resolver
const SendEmailResolver = RequestResolver.makeBatched(
  (requests: ReadonlyArray<SendEmail>) =>
    Effect.tryPromise({
      try: () =>
        fetch("https://api.example.demo/sendEmailBatch", {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            emails: requests.map(({ address, text }) => ({
              address,
              text
            }))
          })
        }).then((res) => res.json() as Promise<void>),
      catch: () => new SendEmailError()
    }).pipe(
      Effect.andThen(
        Effect.forEach(requests, (request) =>
          Request.completeEffect(request, Effect.void)
        )
      ),
      Effect.catchAll((error) =>
        Effect.forEach(requests, (request) =>
          Request.completeEffect(request, Effect.fail(error))
        )
      )
    )
)

// ------------------------------
// Queries
// ------------------------------

// Defines a query to fetch all Todo items
const getTodos: Effect.Effect<
  Array<Todo>,
  GetTodosError
> = Effect.request(GetTodos({}), GetTodosResolver)

// Defines a query to fetch a user by their ID
const getUserById = (id: number) =>
  Effect.request(GetUserById({ id }), GetUserByIdResolver)

// Defines a query to send an email to a specific address
const sendEmail = (address: string, text: string) =>
  Effect.request(SendEmail({ address, text }), SendEmailResolver)

// Composes getUserById and sendEmail to send an email to a specific user
const sendEmailToUser = (id: number, message: string) =>
  getUserById(id).pipe(
    Effect.andThen((user) => sendEmail(user.email, message))
  )

// Uses getUserById to fetch the owner of a Todo and then sends them an email notification
const notifyOwner = (todo: Todo) =>
  getUserById(todo.ownerId).pipe(
    Effect.andThen((user) =>
      sendEmailToUser(user.id, `hey ${user.name} you got a todo!`)
    )
  )
```

By using the `Effect.request` function, we integrate the resolvers with the request model effectively. This approach ensures that each query is optimally resolved using the appropriate resolver.

Although the code structure looks similar to earlier examples, employing resolvers significantly enhances efficiency by optimizing how requests are handled and reducing unnecessary API calls.

```ts {4}
const program = Effect.gen(function* () {
  const todos = yield* getTodos
  yield* Effect.forEach(todos, (todo) => notifyOwner(todo), {
    batching: true
  })
})
```

In the final setup, this program will execute only **3** queries to the APIs, regardless of the number of todos. This contrasts sharply with the traditional approach, which would potentially execute **1 + 2n** queries, where **n** is the number of todos. This represents a significant improvement in efficiency, especially for applications with a high volume of data interactions.

### Disabling Batching

Batching can be locally disabled using the `Effect.withRequestBatching` utility in the following way:

```ts {6}
const program = Effect.gen(function* () {
  const todos = yield* getTodos
  yield* Effect.forEach(todos, (todo) => notifyOwner(todo), {
    concurrency: "unbounded"
  })
}).pipe(Effect.withRequestBatching(false))
```

### Resolvers with Context

In complex applications, resolvers often need access to shared services or configurations to handle requests effectively. However, maintaining the ability to batch requests while providing the necessary context can be challenging. Here, we'll explore how to manage context in resolvers to ensure that batching capabilities are not compromised.

When creating request resolvers, it's crucial to manage the context carefully. Providing too much context or providing varying services to resolvers can make them incompatible for batching. To prevent such issues, the context for the resolver used in `Effect.request` is explicitly set to `never`. This forces developers to clearly define how the context is accessed and used within resolvers.

Consider the following example where we set up an HTTP service that the resolvers can use to execute API calls:

```ts

// ------------------------------
// Model
// ------------------------------

interface User {
  readonly _tag: "User"
  readonly id: number
  readonly name: string
  readonly email: string
}

class GetUserError extends Data.TaggedError("GetUserError")<{}> {}

interface Todo {
  readonly _tag: "Todo"
  readonly id: number
  readonly message: string
  readonly ownerId: number
}

class GetTodosError extends Data.TaggedError("GetTodosError")<{}> {}

class SendEmailError extends Data.TaggedError("SendEmailError")<{}> {}

// ------------------------------
// Requests
// ------------------------------

// Define a request to get multiple Todo items which might
// fail with a GetTodosError
interface GetTodos extends Request.Request<Array<Todo>, GetTodosError> {
  readonly _tag: "GetTodos"
}

// Create a tagged constructor for GetTodos requests
const GetTodos = Request.tagged<GetTodos>("GetTodos")

// Define a request to fetch a User by ID which might
// fail with a GetUserError
interface GetUserById extends Request.Request<User, GetUserError> {
  readonly _tag: "GetUserById"
  readonly id: number
}

// Create a tagged constructor for GetUserById requests
const GetUserById = Request.tagged<GetUserById>("GetUserById")

// Define a request to send an email which might
// fail with a SendEmailError
interface SendEmail extends Request.Request<void, SendEmailError> {
  readonly _tag: "SendEmail"
  readonly address: string
  readonly text: string
}

// Create a tagged constructor for SendEmail requests
const SendEmail = Request.tagged<SendEmail>("SendEmail")

// ------------------------------
// Resolvers With Context
// ------------------------------

class HttpService extends Context.Tag("HttpService")<
  HttpService,
  { fetch: typeof fetch }
>() {}

const GetTodosResolver =
  // we create a normal resolver like we did before
  RequestResolver.fromEffect((_: GetTodos) =>
    Effect.andThen(HttpService, (http) =>
      Effect.tryPromise({
        try: () =>
          http
            .fetch("https://api.example.demo/todos")
            .then((res) => res.json() as Promise<Array<Todo>>),
        catch: () => new GetTodosError()
      })
    )
  ).pipe(
    // we list the tags that the resolver can access
    RequestResolver.contextFromServices(HttpService)
  )
```

We can see now that the type of `GetTodosResolver` is no longer a `RequestResolver` but instead it is:

```ts
const GetTodosResolver: Effect<
  RequestResolver<GetTodos, never>,
  never,
  HttpService
>
```

which is an effect that access the `HttpService` and returns a composed resolver that has the minimal context ready to use.

Once we have such effect we can directly use it in our query definition:

```ts
const getTodos: Effect.Effect<Todo[], GetTodosError, HttpService> =
  Effect.request(GetTodos({}), GetTodosResolver)
```

We can see that the Effect correctly requires `HttpService` to be provided.

Alternatively you can create `RequestResolver`s as part of layers direcly accessing or closing over context from construction.

**Example**

```ts
import {
  Effect,
  Context,
  RequestResolver,
  Request,
  Layer,
  Data
} from "effect"

// ------------------------------
// Model
// ------------------------------

interface User {
  readonly _tag: "User"
  readonly id: number
  readonly name: string
  readonly email: string
}

class GetUserError extends Data.TaggedError("GetUserError")<{}> {}

interface Todo {
  readonly _tag: "Todo"
  readonly id: number
  readonly message: string
  readonly ownerId: number
}

class GetTodosError extends Data.TaggedError("GetTodosError")<{}> {}

class SendEmailError extends Data.TaggedError("SendEmailError")<{}> {}

// ------------------------------
// Requests
// ------------------------------

// Define a request to get multiple Todo items which might
// fail with a GetTodosError
interface GetTodos extends Request.Request<Array<Todo>, GetTodosError> {
  readonly _tag: "GetTodos"
}

// Create a tagged constructor for GetTodos requests
const GetTodos = Request.tagged<GetTodos>("GetTodos")

// Define a request to fetch a User by ID which might
// fail with a GetUserError
interface GetUserById extends Request.Request<User, GetUserError> {
  readonly _tag: "GetUserById"
  readonly id: number
}

// Create a tagged constructor for GetUserById requests
const GetUserById = Request.tagged<GetUserById>("GetUserById")

// Define a request to send an email which might
// fail with a SendEmailError
interface SendEmail extends Request.Request<void, SendEmailError> {
  readonly _tag: "SendEmail"
  readonly address: string
  readonly text: string
}

// Create a tagged constructor for SendEmail requests
const SendEmail = Request.tagged<SendEmail>("SendEmail")

// ------------------------------
// Resolvers With Context
// ------------------------------

class HttpService extends Context.Tag("HttpService")<
  HttpService,
  { fetch: typeof fetch }
>() {}

const GetTodosResolver =
  // we create a normal resolver like we did before
  RequestResolver.fromEffect((_: GetTodos) =>
    Effect.andThen(HttpService, (http) =>
      Effect.tryPromise({
        try: () =>
          http
            .fetch("https://api.example.demo/todos")
            .then((res) => res.json() as Promise<Array<Todo>>),
        catch: () => new GetTodosError()
      })
    )
  ).pipe(
    // we list the tags that the resolver can access
    RequestResolver.contextFromServices(HttpService)
  )

// ------------------------------
// Layers
// ------------------------------

class TodosService extends Context.Tag("TodosService")<
  TodosService,
  {
    getTodos: Effect.Effect<Array<Todo>, GetTodosError>
  }
>() {}

const TodosServiceLive = Layer.effect(
  TodosService,
  Effect.gen(function* () {
    const http = yield* HttpService
    const resolver = RequestResolver.fromEffect((_: GetTodos) =>
      Effect.tryPromise({
        try: () =>
          http
            .fetch("https://api.example.demo/todos")
            .then<any, Todo[]>((res) => res.json()),
        catch: () => new GetTodosError()
      })
    )
    return {
      getTodos: Effect.request(GetTodos({}), resolver)
    }
  })
)

const getTodos: Effect.Effect<
  Array<Todo>,
  GetTodosError,
  TodosService
> = Effect.andThen(TodosService, (service) => service.getTodos)
```

This way is probably the best for most of the cases given that layers are the natural primitive where to wire services together.

## Caching

While we have significantly optimized request batching, there's another area that can enhance our application's efficiency: caching. Without caching, even with optimized batch processing, the same requests could be executed multiple times, leading to unnecessary data fetching.

In the Effect library, caching is handled through built-in utilities that allow requests to be stored temporarily, preventing the need to re-fetch data that hasn't changed. This feature is crucial for reducing the load on both the server and the network, especially in applications that make frequent similar requests.

Here's how you can implement caching for the `getUserById` query:

```ts {3}
const getUserById = (id: number) =>
  Effect.request(GetUserById({ id }), GetUserByIdResolver).pipe(
    Effect.withRequestCaching(true)
  )
```

## Final Program

Assuming you've wired everything up correctly:

```ts
const program = Effect.gen(function* () {
  const todos = yield* getTodos
  yield* Effect.forEach(todos, (todo) => notifyOwner(todo), {
    concurrency: "unbounded"
  })
}).pipe(Effect.repeat(Schedule.fixed("10 seconds")))
```

With this program, the `getTodos` operation retrieves the todos for each user. Then, the `Effect.forEach` function is used to notify the owner of each todo concurrently, without waiting for the notifications to complete.

The `repeat` function is applied to the entire chain of operations, and it ensures that the program repeats every 10 seconds using a fixed schedule. This means that the entire process, including fetching todos and sending notifications, will be executed repeatedly with a 10-second interval.

The program incorporates a caching mechanism, which prevents the same `GetUserById` operation from being executed more than once within a span of 1 minute. This default caching behavior helps optimize the program's execution and reduces unnecessary requests to fetch user data.

Furthermore, the program is designed to send emails in batches, allowing for efficient processing and better utilization of resources.

## Customizing Request Caching

In real-world applications, effective caching strategies can significantly improve performance by reducing redundant data fetching. The Effect library provides flexible caching mechanisms that can be tailored for specific parts of your application or applied globally.

There may be scenarios where different parts of your application have unique caching requirements—some might benefit from a localized cache, while others might need a global cache setup. Let’s explore how you can configure a custom cache to meet these varied needs.

### Creating a Custom Cache

Here's how you can create a custom cache and apply it to part of your application. This example demonstrates setting up a cache that repeats a task every 10 seconds, caching requests with specific parameters like capacity and TTL (time-to-live).

```ts
const program = Effect.gen(function* () {
  const todos = yield* getTodos
  yield* Effect.forEach(todos, (todo) => notifyOwner(todo), {
    concurrency: "unbounded"
  })
}).pipe(
  Effect.repeat(Schedule.fixed("10 seconds")),
  Effect.provide(
    Layer.setRequestCache(
      Request.makeCache({ capacity: 256, timeToLive: "60 minutes" })
    )
  )
)
```

### Direct Cache Application

You can also construct a cache using `Request.makeCache` and apply it directly to a specific program using `Effect.withRequestCache`. This method ensures that all requests originating from the specified program are managed through the custom cache, provided that caching is enabled.

# [Configuration](https://effect.website/docs/configuration/)

## Overview


Configuration is an essential aspect of any cloud-native application. Effect simplifies the process of managing configuration by offering a convenient interface for configuration providers.

The configuration front-end in Effect enables ecosystem libraries and applications to specify their configuration requirements in a declarative manner. It offloads the complex tasks to a `ConfigProvider`, which can be supplied by third-party libraries.

Effect comes bundled with a straightforward default `ConfigProvider` that retrieves configuration data from environment variables. This default provider can be used during development or as a starting point before transitioning to more advanced configuration providers.

To make our application configurable, we need to understand three essential elements:

- **Config Description**: We describe the configuration data using an instance of `Config<A>`. If the configuration data is simple, such as a `string`, `number`, or `boolean`, we can use the built-in functions provided by the `Config` module. For more complex data types like [HostPort](#custom-configuration-types), we can combine primitive configs to create a custom configuration description.

- **Config Frontend**: We utilize the instance of `Config<A>` to load the configuration data described by the instance (a `Config` is, in itself, an effect). This process leverages the current `ConfigProvider` to retrieve the configuration.

- **Config Backend**: The `ConfigProvider` serves as the underlying engine that manages the configuration loading process. Effect comes with a default config provider as part of its default services. This default provider reads the configuration data from environment variables. If we want to use a custom config provider, we can utilize the `Effect.withConfigProvider` API to configure the Effect runtime accordingly.

## Basic Configuration Types

Effect provides several built-in types for configuration values, which you can use right out of the box:

| Type       | Description                                                             |
| ---------- | ----------------------------------------------------------------------- |
| `string`   | Reads a configuration value as a string.                                |
| `number`   | Reads a value as a floating-point number.                               |
| `boolean`  | Reads a value as a boolean (`true` or `false`).                         |
| `integer`  | Reads a value as an integer.                                            |
| `date`     | Parses a value into a `Date` object.                                    |
| `literal`  | Reads a fixed literal (\*).                                             |
| `logLevel` | Reads a value as a [LogLevel](/docs/observability/logging/#log-levels). |
| `duration` | Parses a value as a time duration.                                      |
| `redacted` | Reads a **sensitive value**, ensuring it is protected when logged.      |
| `url`      | Parses a value as a valid URL.                                          |

(\*) `string | number | boolean | null | bigint`

**Example** (Loading Environment Variables)

Here's an example of loading a basic configuration using environment variables for `HOST` and `PORT`:

```ts

// Define a program that loads HOST and PORT configuration
const program = Effect.gen(function* () {
  const host = yield* Config.string("HOST") // Read as a string
  const port = yield* Config.number("PORT") // Read as a number

  console.log(`Application started: ${host}:${port}`)
})

Effect.runPromise(program)
```

If you run this without setting the required environment variables:

```sh
npx tsx primitives.ts
```

you'll see an error indicating the missing configuration:

```ansi
[Error: (Missing data at HOST: "Expected HOST to exist in the process context")] {
  name: '(FiberFailure) Error',
  [Symbol(effect/Runtime/FiberFailure)]: Symbol(effect/Runtime/FiberFailure),
  [Symbol(effect/Runtime/FiberFailure/Cause)]: {
    _tag: 'Fail',
    error: {
      _op: 'MissingData',
      path: [ 'HOST' ],
      message: 'Expected HOST to exist in the process context'
    }
  }
}
```

To run the program successfully, set the environment variables as shown below:

```sh
HOST=localhost PORT=8080 npx tsx primitives.ts
```

Output:

```ansi
Application started: localhost:8080
```

## Using Config with Schema

You can define and decode configuration values using a schema.

**Example** (Decoding a Configuration Value)

```ts

// Define a config that expects a string with at least 4 characters
const myConfig = Schema.Config(
  "Foo",
  Schema.String.pipe(Schema.minLength(4))
)
```

For more information, see the [Schema.Config](/docs/schema/effect-data-types/#config) documentation.

## Providing Default Values

Sometimes, you may encounter situations where an environment variable is missing, leading to an incomplete configuration. To address this, Effect provides the `Config.withDefault` function, which allows you to specify a default value. This fallback ensures that your application continues to function even if a required environment variable is not set.

**Example** (Using Default Values)

```ts

const program = Effect.gen(function* () {
  const host = yield* Config.string("HOST")
  // Use default 8080 if PORT is not set
  const port = yield* Config.number("PORT").pipe(Config.withDefault(8080))
  console.log(`Application started: ${host}:${port}`)
})

Effect.runPromise(program)
```

Running this program with only the `HOST` environment variable set:

```sh
HOST=localhost npx tsx defaults.ts
```

produces the following output:

```ansi
Application started: localhost:8080
```

In this case, even though the `PORT` environment variable is not set, the program continues to run, using the default value of `8080` for the port. This ensures that the application remains functional without requiring every configuration to be explicitly provided.

## Handling Sensitive Values

Some configuration values, like API keys, should not be printed in logs.

The `Config.redacted` function is used to handle sensitive information safely.
It parses the configuration value and wraps it in a `Redacted<string>`, a specialized [data type](/docs/data-types/redacted/) designed to protect secrets.

When you log a `Redacted` value using `console.log`, the actual content remains hidden, providing an extra layer of security. To access the real value, you must explicitly use `Redacted.value`.

**Example** (Protecting Sensitive Data)

```ts

const program = Effect.gen(function* () {
  //      ┌─── Redacted<string>
  //      ▼
  const redacted = yield* Config.redacted("API_KEY")

  // Log the redacted value, which won't reveal the actual secret
  console.log(`Console output: ${redacted}`)

  // Access the real value using Redacted.value and log it
  console.log(`Actual value: ${Redacted.value(redacted)}`)
})

Effect.runPromise(program)
```

When this program is executed:

```sh
API_KEY=my-api-key tsx redacted.ts
```

The output will look like this:

```ansi
Console output: <redacted>
Actual value: my-api-key
```

As shown, when logging the `Redacted` value using `console.log`, the output is `<redacted>`, ensuring that sensitive data remains concealed. However, by using `Redacted.value`, the true value (`"my-api-key"`) can be accessed and displayed, providing controlled access to the secret.

### Wrapping a Config with Redacted

By default, when you pass a string to `Config.redacted`, it returns a `Redacted<string>`. You can also pass a `Config` (such as `Config.number`) to ensure that only validated values are accepted. This adds an extra layer of security by ensuring that sensitive data is properly validated before being redacted.

**Example** (Redacting and Validating a Number)

```ts

const program = Effect.gen(function* () {
  // Wrap the validated number configuration with redaction
  //
  //      ┌─── Redacted<number>
  //      ▼
  const redacted = yield* Config.redacted(Config.number("SECRET"))

  console.log(`Console output: ${redacted}`)
  console.log(`Actual value: ${Redacted.value(redacted)}`)
})

Effect.runPromise(program)
```

## Combining Configurations

Effect provides several built-in combinators that allow you to define and manipulate configurations.
These combinators take a `Config` as input and produce another `Config`, enabling more complex configuration structures.

| Combinator | Description                                                                                                         |
| ---------- | ------------------------------------------------------------------------------------------------------------------- |
| `array`    | Constructs a configuration for an array of values.                                                                  |
| `chunk`    | Constructs a configuration for a sequence of values.                                                                |
| `option`   | Returns an optional configuration. If the data is missing, the result will be `None`; otherwise, it will be `Some`. |
| `repeat`   | Describes a sequence of values, each following the structure of the given config.                                   |
| `hashSet`  | Constructs a configuration for a set of values.                                                                     |
| `hashMap`  | Constructs a configuration for a key-value map.                                                                     |

Additionally, there are three special combinators for specific use cases:

| Combinator | Description                                                              |
| ---------- | ------------------------------------------------------------------------ |
| `succeed`  | Constructs a config that contains a predefined value.                    |
| `fail`     | Constructs a config that fails with the specified error message.         |
| `all`      | Combines multiple configurations into a tuple, struct, or argument list. |

**Example** (Using the `array` combinator)

The following example demonstrates how to load an environment variable as an array of strings using the `Config.array` constructor.

```ts

const program = Effect.gen(function* () {
  const config = yield* Config.array(Config.string(), "MYARRAY")
  console.log(config)
})

Effect.runPromise(program)
// Run:
// MYARRAY=a,b,c,a npx tsx index.ts
// Output:
// [ 'a', 'b', 'c', 'a' ]
```

**Example** (Using the `hashSet` combinator)

```ts

const program = Effect.gen(function* () {
  const config = yield* Config.hashSet(Config.string(), "MYSET")
  console.log(config)
})

Effect.runPromise(program)
// Run:
// MYSET=a,"b c",d,a npx tsx index.ts
// Output:
// { _id: 'HashSet', values: [ 'd', 'a', 'b c' ] }
```

**Example** (Using the `hashMap` combinator)

```ts

const program = Effect.gen(function* () {
  const config = yield* Config.hashMap(Config.string(), "MYMAP")
  console.log(config)
})

Effect.runPromise(program)
// Run:
// MYMAP_A=a MYMAP_B=b npx tsx index.ts
// Output:
// { _id: 'HashMap', values: [ [ 'A', 'a' ], [ 'B', 'b' ] ] }
```

## Operators

Effect provides several built-in operators to work with configurations, allowing you to manipulate and transform them according to your needs.

### Transforming Operators

These operators enable you to modify configurations or validate their values:

| Operator     | Description                                                                                               |
| ------------ | --------------------------------------------------------------------------------------------------------- |
| `validate`   | Ensures that a configuration meets certain criteria, returning a validation error if it does not.         |
| `map`        | Transforms the values of a configuration using a provided function.                                       |
| `mapAttempt` | Similar to `map`, but catches any errors thrown by the function and converts them into validation errors. |
| `mapOrFail`  | Like `map`, but the function can fail. If it does, the result is a validation error.                      |

**Example** (Using `validate` Operator)

```ts

const program = Effect.gen(function* () {
  // Load the NAME environment variable and validate its length
  const config = yield* Config.string("NAME").pipe(
    Config.validate({
      message: "Expected a string at least 4 characters long",
      validation: (s) => s.length >= 4
    })
  )
  console.log(config)
})

Effect.runPromise(program)
```

If we run this program with an invalid `NAME` value:

```sh
NAME=foo npx tsx validate.ts
```

The output will be:

```ansi
[Error: (Invalid data at NAME: "Expected a string at least 4 characters long")] {
  name: '(FiberFailure) Error',
  [Symbol(effect/Runtime/FiberFailure)]: Symbol(effect/Runtime/FiberFailure),
  [Symbol(effect/Runtime/FiberFailure/Cause)]: {
    _tag: 'Fail',
    error: {
      _op: 'InvalidData',
      path: [ 'NAME' ],
      message: 'Expected a string at least 4 characters long'
    }
  }
}
```

### Fallback Operators

Fallback operators are useful when you want to provide alternative configurations in case of errors or missing data. These operators ensure that your program can still run even if some configuration values are unavailable.

| Operator   | Description                                                                                           |
| ---------- | ----------------------------------------------------------------------------------------------------- |
| `orElse`   | Attempts to use the primary config first. If it fails or is missing, it falls back to another config. |
| `orElseIf` | Similar to `orElse`, but it switches to the fallback config only if the error matches a condition.    |

**Example** (Using `orElse` for Fallback)

In this example, the program requires two configuration values: `A` and `B`. We set up two configuration providers, each containing only one of the required values. Using the `orElse` operator, we combine these providers so the program can retrieve both `A` and `B`.

```ts

// A program that requires two configurations: A and B
const program = Effect.gen(function* () {
  const A = yield* Config.string("A") // Retrieve config A
  const B = yield* Config.string("B") // Retrieve config B
  console.log(`A: ${A}, B: ${B}`)
})

// First provider has A but is missing B
const provider1 = ConfigProvider.fromMap(new Map([["A", "A"]]))

// Second provider has B but is missing A
const provider2 = ConfigProvider.fromMap(new Map([["B", "B"]]))

// Use `orElse` to fall back from provider1 to provider2
const provider = provider1.pipe(ConfigProvider.orElse(() => provider2))

Effect.runPromise(Effect.withConfigProvider(program, provider))
```

If we run this program:

```sh
npx tsx orElse.ts
```

The output will be:

```ansi
A: A, B: B
```

> **Tip**
  In this example, we use `ConfigProvider.fromMap` to create a
  configuration provider from a simple JavaScript `Map`. This is
  particularly useful for testing, as described in the [Mocking
  Configurations in Tests](#mocking-configurations-in-tests) section.


## Custom Configuration Types

Effect allows you to define configurations for custom types by combining primitive configurations using [combinators](#combining-configurations) and [operators](#operators).

For example, let's create a `HostPort` class, which has two fields: `host` and `port`.

```ts
class HostPort {
  constructor(readonly host: string, readonly port: number) {}
  get url() {
    return `${this.host}:${this.port}`
  }
}
```

To define a configuration for this custom type, we can combine primitive configs for `string` and `number`:

**Example** (Defining a Custom Configuration)

```ts

class HostPort {
  constructor(readonly host: string, readonly port: number) {}
  get url() {
    return `${this.host}:${this.port}`
  }
}

// Combine the configuration for 'HOST' and 'PORT'
const both = Config.all([Config.string("HOST"), Config.number("PORT")])

// Map the configuration values into a HostPort instance
const config = Config.map(
  both,
  ([host, port]) => new HostPort(host, port)
)
```

In this example, `Config.all(configs)` combines two primitive configurations, `Config<string>` and `Config<number>`, into a `Config<[string, number]>`. The `Config.map` operator is then used to transform these values into an instance of the `HostPort` class.

**Example** (Using Custom Configuration)

```ts

class HostPort {
  constructor(readonly host: string, readonly port: number) {}
  get url() {
    return `${this.host}:${this.port}`
  }
}

// Combine the configuration for 'HOST' and 'PORT'
const both = Config.all([Config.string("HOST"), Config.number("PORT")])

// Map the configuration values into a HostPort instance
const config = Config.map(
  both,
  ([host, port]) => new HostPort(host, port)
)

// Main program that reads configuration and starts the application
const program = Effect.gen(function* () {
  const hostPort = yield* config
  console.log(`Application started: ${hostPort.url}`)
})

Effect.runPromise(program)
```

When you run this program, it will try to retrieve the values for `HOST` and `PORT` from your environment variables:

```sh
HOST=localhost PORT=8080 npx tsx App.ts
```

If successful, it will print:

```ansi
Application started: localhost:8080
```

## Nested Configurations

We've seen how to define configurations at the top level, whether for primitive or custom types. In some cases, though, you might want to structure your configurations in a more nested way, organizing them under common namespaces for clarity and manageability.

For instance, consider the following `ServiceConfig` type:

```ts
class ServiceConfig {
  constructor(
    readonly host: string,
    readonly port: number,
    readonly timeout: number
  ) {}
  get url() {
    return `${this.host}:${this.port}`
  }
}
```

If you were to use this configuration in your application, it would expect the `HOST`, `PORT`, and `TIMEOUT` environment variables at the top level. But in many cases, you may want to organize configurations under a shared namespace—for example, grouping `HOST` and `PORT` under a `SERVER` namespace, while keeping `TIMEOUT` at the root.

To do this, you can use the `Config.nested` operator, which allows you to nest configuration values under a specific namespace. Let's update the previous example to reflect this:

```ts

class ServiceConfig {
  constructor(
    readonly host: string,
    readonly port: number,
    readonly timeout: number
  ) {}
  get url() {
    return `${this.host}:${this.port}`
  }
}

const serverConfig = Config.all([
  Config.string("HOST"),
  Config.number("PORT")
])

const serviceConfig = Config.map(
  Config.all([
    // Read 'HOST' and 'PORT' from 'SERVER' namespace
    Config.nested(serverConfig, "SERVER"),
    // Read 'TIMEOUT' from the root namespace
    Config.number("TIMEOUT")
  ]),
  ([[host, port], timeout]) => new ServiceConfig(host, port, timeout)
)
```

Now, if you run your application with this configuration setup, it will look for the following environment variables:

- `SERVER_HOST` for the host value
- `SERVER_PORT` for the port value
- `TIMEOUT` for the timeout value

This structured approach keeps your configuration more organized, especially when dealing with multiple services or complex applications.

## Mocking Configurations in Tests

When testing services, there are times when you need to provide specific configurations for your tests. To simulate this, it's useful to mock the configuration backend that reads these values.

You can achieve this using the `ConfigProvider.fromMap` constructor.
This method allows you to create a configuration provider from a `Map<string, string>`, where the map represents the configuration data.
You can then use this mock provider in place of the default one by calling `Effect.withConfigProvider`.

**Example** (Mocking a Config Provider for Testing)

```ts

class HostPort {
  constructor(readonly host: string, readonly port: number) {}
  get url() {
    return `${this.host}:${this.port}`
  }
}

const config = Config.map(
  Config.all([Config.string("HOST"), Config.number("PORT")]),
  ([host, port]) => new HostPort(host, port)
)

const program = Effect.gen(function* () {
  const hostPort = yield* config
  console.log(`Application started: ${hostPort.url}`)
})

// Create a mock config provider using a map with test data
const mockConfigProvider = ConfigProvider.fromMap(
  new Map([
    ["HOST", "localhost"],
    ["PORT", "8080"]
  ])
)

// Run the program using the mock config provider
Effect.runPromise(Effect.withConfigProvider(program, mockConfigProvider))
// Output: Application started: localhost:8080
```

This approach helps you create isolated tests that don't rely on external environment variables, ensuring your tests run consistently with mock configurations.

### Handling Nested Configuration Values

For more complex setups, configurations often include nested keys. By default, `ConfigProvider.fromMap` uses `.` as the separator for nested keys.

**Example** (Providing Nested Configuration Values)

```ts

const config = Config.nested(Config.number("PORT"), "SERVER")

const program = Effect.gen(function* () {
  const port = yield* config
  console.log(`Server is running on port ${port}`)
})

// Mock configuration using '.' as the separator for nested keys
const mockConfigProvider = ConfigProvider.fromMap(
  new Map([["SERVER.PORT", "8080"]])
)

Effect.runPromise(Effect.withConfigProvider(program, mockConfigProvider))
// Output: Server is running on port 8080
```

### Customizing the Path Delimiter

If your configuration data uses a different separator (such as `_`), you can change the delimiter using the `pathDelim` option in `ConfigProvider.fromMap`.

**Example** (Using a Custom Path Delimiter)

```ts

const config = Config.nested(Config.number("PORT"), "SERVER")

const program = Effect.gen(function* () {
  const port = yield* config
  console.log(`Server is running on port ${port}`)
})

// Mock configuration using '_' as the separator
const mockConfigProvider = ConfigProvider.fromMap(
  new Map([["SERVER_PORT", "8080"]]),
  { pathDelim: "_" }
)

Effect.runPromise(Effect.withConfigProvider(program, mockConfigProvider))
// Output: Server is running on port 8080
```

## ConfigProvider

The `ConfigProvider` module in Effect allows applications to load configuration values from different sources.
The default provider reads from environment variables, but you can customize its behavior when needed.

### Loading Configuration from Environment Variables

The `ConfigProvider.fromEnv` function creates a `ConfigProvider` that loads values from environment variables. This is the default provider used by Effect unless another is specified.

If your application requires a custom delimiter for nested configuration keys, you can configure `ConfigProvider.fromEnv` accordingly.

**Example** (Changing the Path Delimiter)

The following example modifies the path delimiter (`"__"`) and sequence delimiter (`"|"`) for environment variables.

```ts

const program = Effect.gen(function* () {
  // Read SERVER_HOST and SERVER_PORT as nested configuration values
  const port = yield* Config.nested(Config.number("PORT"), "SERVER")
  const host = yield* Config.nested(Config.string("HOST"), "SERVER")
  console.log(`Application started: ${host}:${port}`)
})

Effect.runPromise(
  Effect.withConfigProvider(
    program,
    // Custom delimiters
    ConfigProvider.fromEnv({ pathDelim: "__", seqDelim: "|" })
  )
)
```

To match the custom delimiter (`"__"`), set environment variables like this:

```sh
SERVER__HOST=localhost SERVER__PORT=8080 npx tsx index.ts
```

Output:

```ansi
Application started: localhost:8080
```

### Loading Configuration from JSON

The `ConfigProvider.fromJson` function creates a `ConfigProvider` that loads values from a JSON object.

**Example** (Reading Nested Configuration from JSON)

```ts

const program = Effect.gen(function* () {
  // Read SERVER_HOST and SERVER_PORT as nested configuration values
  const port = yield* Config.nested(Config.number("PORT"), "SERVER")
  const host = yield* Config.nested(Config.string("HOST"), "SERVER")
  console.log(`Application started: ${host}:${port}`)
})

Effect.runPromise(
  Effect.withConfigProvider(
    program,
    ConfigProvider.fromJson(
      JSON.parse(`{"SERVER":{"PORT":8080,"HOST":"localhost"}}`)
    )
  )
)
// Output: Application started: localhost:8080
```

### Using Nested Configuration Namespaces

The `ConfigProvider.nested` function allows **grouping configuration values** under a namespace.
This is helpful when structuring settings logically, such as grouping `SERVER`-related values.

**Example** (Using a Nested Namespace)

```ts

const program = Effect.gen(function* () {
  const port = yield* Config.number("PORT") // Reads SERVER_PORT
  const host = yield* Config.string("HOST") // Reads SERVER_HOST
  console.log(`Application started: ${host}:${port}`)
})

Effect.runPromise(
  Effect.withConfigProvider(
    program,
    ConfigProvider.fromEnv().pipe(
      // Uses SERVER as a namespace
      ConfigProvider.nested("SERVER")
    )
  )
)
```

Since we defined `"SERVER"` as the namespace, the environment variables must follow this pattern:

```sh
SERVER_HOST=localhost SERVER_PORT=8080 npx tsx index.ts
```

Output:

```ansi
Application started: localhost:8080
```

### Converting Configuration Keys to Constant Case

The `ConfigProvider.constantCase` function transforms all configuration keys into constant case (uppercase with underscores).
This is useful when adapting environment variables to match different naming conventions.

**Example** (Using `constantCase` for Environment Variables)

```ts

const program = Effect.gen(function* () {
  const port = yield* Config.number("Port") // Reads PORT
  const host = yield* Config.string("Host") // Reads HOST
  console.log(`Application started: ${host}:${port}`)
})

Effect.runPromise(
  Effect.withConfigProvider(
    program,
    // Convert keys to constant case
    ConfigProvider.fromEnv().pipe(ConfigProvider.constantCase)
  )
)
```

Since `constantCase` converts `"Port"` → `"PORT"` and `"Host"` → `"HOST"`, the environment variables must be set as follows:

```sh
HOST=localhost PORT=8080 npx tsx index.ts
```

Output:

```ansi
Application started: localhost:8080
```

## Deprecations

### Secret <Badge text="Deprecated" variant="caution" />

_Deprecated since version 3.3.0: Please use [Config.redacted](#handling-sensitive-values) for handling sensitive information going forward._

The `Config.secret` function was previously used to secure sensitive information in a similar way to `Config.redacted`. It wraps configuration values in a `Secret` type, which also conceals details when logged but allows access via `Secret.value`.

**Example** (Using Deprecated `Config.secret`)

```ts

const program = Effect.gen(function* () {
  const secret = yield* Config.secret("API_KEY")

  // Log the secret value, which won't reveal the actual secret
  console.log(`Console output: ${secret}`)

  // Access the real value using Secret.value and log it
  console.log(`Actual value: ${Secret.value(secret)}`)
})

Effect.runPromise(program)
```

When this program is executed:

```sh
API_KEY=my-api-key tsx secret.ts
```

The output will look like this:

```ansi
Console output: Secret(<redacted>)
Actual value: my-api-key
```

# [Introduction to Runtime](https://effect.website/docs/runtime/)

## Overview

The `Runtime<R>` data type represents a runtime system that can **execute effects**. To run an effect, `Effect<A, E, R>`, we need a `Runtime<R>` that contains the required resources, denoted by the `R` type parameter.

A `Runtime<R>` consists of three main components:

- A value of type `Context<R>`
- A value of type `FiberRefs`
- A value of type `RuntimeFlags`

## What is a Runtime System?

When we write an Effect program, we construct an `Effect` using constructors and combinators.
Essentially, we are creating a blueprint of a program.
An `Effect` is merely a data structure that describes the execution of a concurrent program.
It represents a tree-like structure that combines various primitives to define what the effect should do.

However, this data structure itself does not perform any actions, it is solely a description of a concurrent program.

To execute this program, the Effect runtime system comes into play. The `Runtime.run*` functions (e.g., `Runtime.runPromise`, `Runtime.runFork`) are responsible for taking this blueprint and executing it.

When the runtime system runs an effect, it creates a root fiber, initializing it with:

- The initial [context](/docs/requirements-management/services/#how-it-works)
- The initial `FiberRefs`
- The initial effect

It then starts a loop, executing the instructions described by the `Effect` step by step.

You can think of the runtime as a system that takes an [`Effect<A, E, R>`](/docs/getting-started/the-effect-type/) and its associated context `Context<R>` and produces an [`Exit<A, E>`](/docs/data-types/exit/) result.

```text
┌────────────────────────────────┐
│  Context<R> + Effect<A, E, R>  │
└────────────────────────────────┘
               │
               ▼
┌────────────────────────────────┐
│      Effect Runtime System     │
└────────────────────────────────┘
               │
               ▼
┌────────────────────────────────┐
│          Exit<A, E>            │
└────────────────────────────────┘
```

Runtime Systems have a lot of responsibilities:

| Responsibility                | Description                                                                                                        |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Executing the program**     | The runtime must execute every step of the effect in a loop until the program completes.                           |
| **Handling errors**           | It handles both expected and unexpected errors that occur during execution.                                        |
| **Managing concurrency**      | The runtime spawns new fibers when `Effect.fork` is called to handle concurrent operations.                        |
| **Cooperative yielding**      | It ensures fibers don't monopolize resources, yielding control when necessary.                                     |
| **Ensuring resource cleanup** | The runtime guarantees finalizers run properly to clean up resources when needed.                                  |
| **Handling async callbacks**  | The runtime deals with asynchronous operations transparently, allowing you to write async and sync code uniformly. |

## The Default Runtime

When we use [functions that run effects](/docs/getting-started/running-effects/) like `Effect.runPromise` or `Effect.runFork`, we are actually using the **default runtime** without explicitly mentioning it. These functions are designed as convenient shortcuts for executing our effects using the default runtime.

Each of the `Effect.run*` functions internally calls the corresponding `Runtime.run*` function, passing in the default runtime. For example, `Effect.runPromise` is just an alias for `Runtime.runPromise(defaultRuntime)`.

Both of the following executions are functionally equivalent:

**Example** (Running an Effect Using the Default Runtime)

```ts

const program = Effect.log("Application started!")

Effect.runPromise(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message="Application started!"
*/

Runtime.runPromise(Runtime.defaultRuntime)(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message="Application started!"
*/
```

In both cases, the program runs using the default runtime, producing the same output.

The default runtime includes:

- An empty [context](/docs/requirements-management/services/#how-it-works)
- A set of `FiberRefs` that include the [default services](/docs/requirements-management/default-services/)
- A default configuration for `RuntimeFlags` that enables `Interruption` and `CooperativeYielding`

In most scenarios, using the default runtime is sufficient for effect execution.
However, there are cases where it's helpful to create a custom runtime, particularly when you need to reuse specific configurations or contexts.

For example, in a React app or when executing operations on a server in response to API requests, you might create a `Runtime<R>` by initializing a [layer](/docs/requirements-management/layers/) `Layer<R, Err, RIn>`. This allows you to maintain a consistent context across different execution boundaries.

## Locally Scoped Runtime Configuration

In Effect, runtime configurations are typically **inherited** from their parent workflows.
This means that when we access a runtime configuration or obtain a runtime inside a workflow, we are essentially using the configuration of the parent workflow.

However, there are cases where we want to temporarily **override the runtime configuration for a specific part** of our code.
This concept is known as locally scoped runtime configuration.
Once the execution of that code region is completed, the runtime configuration **reverts** to its original settings.

To achieve this, we make use of the `Effect.provide` function, which allow us to provide a new runtime configuration to a specific section of our code.

**Example** (Overriding the Logger Configuration)

In this example, we create a simple logger using `Logger.replace`, which replaces the default logger with a custom one that logs messages without timestamps or levels. We then use `Effect.provide` to apply this custom logger to the program.

```ts

const addSimpleLogger = Logger.replace(
  Logger.defaultLogger,
  // Custom logger implementation
  Logger.make(({ message }) => console.log(message))
)

const program = Effect.gen(function* () {
  yield* Effect.log("Application started!")
  yield* Effect.log("Application is about to exit!")
})

// Running with the default logger
Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message="Application started!"
timestamp=... level=INFO fiber=#0 message="Application is about to exit!"
*/

// Overriding the default logger with a custom one
Effect.runFork(program.pipe(Effect.provide(addSimpleLogger)))
/*
Output:
[ 'Application started!' ]
[ 'Application is about to exit!' ]
*/
```

To ensure that the runtime configuration is only applied to a specific part of an Effect application, we should provide the configuration layer exclusively to that particular section.

**Example** (Providing a configuration layer to a nested workflow)

In this example, we demonstrate how to apply a custom logger configuration only to a specific section of the program. The default logger is used for most of the program, but when we apply the `Effect.provide(addSimpleLogger)` call, it overrides the logger within that specific nested block. After that, the configuration reverts to its original state.

```ts

const addSimpleLogger = Logger.replace(
  Logger.defaultLogger,
  // Custom logger implementation
  Logger.make(({ message }) => console.log(message))
)

const removeDefaultLogger = Logger.remove(Logger.defaultLogger)

const program = Effect.gen(function* () {
  // Logs with default logger
  yield* Effect.log("Application started!")

  yield* Effect.gen(function* () {
    // This log is suppressed
    yield* Effect.log("I'm not going to be logged!")

    // Custom logger applied here
    yield* Effect.log("I will be logged by the simple logger.").pipe(
      Effect.provide(addSimpleLogger)
    )

    // This log is suppressed
    yield* Effect.log(
      "Reset back to the previous configuration, so I won't be logged."
    )
  }).pipe(
    // Remove the default logger temporarily
    Effect.provide(removeDefaultLogger)
  )

  // Logs with default logger again
  yield* Effect.log("Application is about to exit!")
})

Effect.runSync(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message="Application started!"
[ 'I will be logged by the simple logger.' ]
timestamp=... level=INFO fiber=#0 message="Application is about to exit!"
*/
```

## ManagedRuntime

When developing an Effect application and using `Effect.run*` functions to execute it, the application is automatically run using the default runtime behind the scenes. While it’s possible to adjust specific parts of the application by providing locally scoped configuration layers using `Effect.provide`, there are scenarios where you might want to **customize the runtime configuration for the entire application** from the top level.

In these cases, you can create a top-level runtime by converting a configuration layer into a runtime using the `ManagedRuntime.make` constructor.

**Example** (Creating and Using a Custom Managed Runtime)

In this example, we first create a custom configuration layer called `appLayer`, which replaces the default logger with a simple one that logs messages to the console. Next, we use `ManagedRuntime.make` to turn this configuration layer into a runtime.

```ts

// Define a configuration layer that replaces the default logger
const appLayer = Logger.replace(
  Logger.defaultLogger,
  // Custom logger implementation
  Logger.make(({ message }) => console.log(message))
)

// Create a custom runtime from the configuration layer
const runtime = ManagedRuntime.make(appLayer)

const program = Effect.log("Application started!")

// Execute the program using the custom runtime
runtime.runSync(program)

// Clean up resources associated with the custom runtime
Effect.runFork(runtime.disposeEffect)
/*
Output:
[ 'Application started!' ]
*/
```

### Effect.Tag

When working with runtimes that you pass around, `Effect.Tag` can help simplify the access to services. It lets you define a new tag and embed the service shape directly into the static properties of the tag class.

**Example** (Defining a Tag for Notifications)

```ts

class Notifications extends Effect.Tag("Notifications")<
  Notifications,
  { readonly notify: (message: string) => Effect.Effect<void> }
>() {}
```

In this setup, the fields of the service (in this case, the `notify` method) are turned into static properties of the `Notifications` class, making it easier to access them.

This allows you to interact with the service directly:

**Example** (Using the Notifications Tag)

```ts

class Notifications extends Effect.Tag("Notifications")<
  Notifications,
  { readonly notify: (message: string) => Effect.Effect<void> }
>() {}

// Create an effect that depends on the Notifications service
//
//      ┌─── Effect<void, never, Notifications>
//      ▼
const action = Notifications.notify("Hello, world!")
```

In this example, the `action` effect depends on the `Notifications` service. This approach allows you to reference services without manually passing them around. Later, you can create a `Layer` that provides the `Notifications` service and build a `ManagedRuntime` with that layer to ensure the service is available where needed.

### Integrations

The `ManagedRuntime` simplifies the integration of services and layers with other frameworks or tools, particularly in environments where Effect is not the primary framework and access to the main entry point is restricted.

For example, in environments like React or other frameworks where you have limited control over the main application entry point, `ManagedRuntime` helps manage the lifecycle of services.

Here's how to manage a service's lifecycle within an external framework:

**Example** (Using `ManagedRuntime` in an External Framework)

```ts

// Define the Notifications service using Effect.Tag
class Notifications extends Effect.Tag("Notifications")<
  Notifications,
  { readonly notify: (message: string) => Effect.Effect<void> }
>() {
  // Provide a live implementation of the Notifications service
  static Live = Layer.succeed(this, {
    notify: (message) => Console.log(message)
  })
}

// Example entry point for an external framework
async function main() {
  // Create a custom runtime using the Notifications layer
  const runtime = ManagedRuntime.make(Notifications.Live)

  // Run the effect
  await runtime.runPromise(Notifications.notify("Hello, world!"))

  // Dispose of the runtime, cleaning up resources
  await runtime.dispose()
}
```


## Common Mistakes

**Incorrect (N+1 queries without batching):**

```ts
const users = yield* Effect.forEach(userIds, (id) =>
  getUserById(id) // Each call is a separate query
)
```

**Correct (using RequestResolver for automatic batching):**

```ts
const GetUserById = Request.tagged("GetUserById")<{ id: string }, User, Error>

const UserResolver = RequestResolver.makeBatched(
  (requests: Request.Request<GetUserById>[]) =>
    db.users.findMany({ where: { id: { in: requests.map(r => r.id) } } })
)
```
