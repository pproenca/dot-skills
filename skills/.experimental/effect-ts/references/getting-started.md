---
title: "Getting Started with Effect"
impact: CRITICAL
impactDescription: "Foundation for all Effect development — covers Effect type, pipelines, generators, and execution"
tags: getting, getting-started, effect-type, generators, pipelines
---
# [Introduction](https://effect.website/docs/getting-started/introduction/)

## Overview

Welcome to the Effect documentation!

Effect is a powerful TypeScript library designed to help developers
easily create complex, synchronous, and asynchronous programs.

Some of the main Effect features include:

| Feature             | Description                                                                                                        |
| ------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Concurrency**     | Achieve highly-scalable, ultra low-latency applications through Effect's fiber-based concurrency model.            |
| **Composability**   | Construct highly maintainable, readable, and flexible software through the use of small, reusable building blocks. |
| **Resource Safety** | Safely manage acquisition and release of resources, even when your program fails.                                  |
| **Type Safety**     | Leverage the TypeScript type system to the fullest with Effect's focus on type inference and type safety.          |
| **Error Handling**  | Handle errors in a structured and reliable manner using Effect's built-in error handling capabilities.             |
| **Asynchronicity**  | Write code that looks the same, whether it is synchronous or asynchronous.                                         |
| **Observability**   | With full tracing capabilities, you can easily debug and monitor the execution of your Effect program.             |

## How to Use These Docs

The documentation is structured in a sequential manner, starting from the basics and progressing to more advanced topics. This allows you to follow along step-by-step as you build your Effect application. However, you have the flexibility to read the documentation in any order or jump directly to the pages that are relevant to your specific use case.

To facilitate navigation within a page, you will find a table of contents on the right side of the screen. This allows you to easily jump between different sections of the page.

### Docs for LLMs

We support the [llms.txt](https://llmstxt.org/) convention for making documentation available to large language models and the applications that make use of them.

Currently, we have the following root-level files:

- [/llms.txt](https://effect.website/llms.txt) — a listing of the available files
- [/llms-full.txt](https://effect.website/llms-full.txt) — complete documentation for Effect
- [/llms-small.txt](https://effect.website/llms-small.txt) — compressed documentation for use with smaller context windows

## Join our Community

If you have questions about anything related to Effect,
you're always welcome to ask our community on [Discord](https://discord.gg/effect-ts).


---

# [Installation](https://effect.website/docs/getting-started/installation/)

## Overview


Requirements:

- TypeScript 5.4 or newer.
- Node.js, Deno, and Bun are supported.

## Manual Installation

### Node.js

Follow these steps to create a new Effect project for [Node.js](https://nodejs.org/):


1. Create a project directory and navigate into it:

   ```sh
   mkdir hello-effect
   cd hello-effect
   ```

2. Initialize a TypeScript project:

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

   ```sh
   npm init -y
   npm install --save-dev typescript
   ```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

   ```sh
   pnpm init
   pnpm add --save-dev typescript
   ```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

   ```sh
   yarn init -y
   yarn add --dev typescript
   ```

   </TabItem>

   </Tabs>

   This creates a `package.json` file with an initial setup for your TypeScript project.

3. Initialize TypeScript:

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

   ```sh
   npx tsc --init
   ```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

   ```sh
   pnpm tsc --init
   ```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

   ```sh
   yarn tsc --init
   ```

   </TabItem>

   </Tabs>

   When running this command, it will generate a `tsconfig.json` file that contains configuration options for TypeScript. One of the most important options to consider is the `strict` flag.

   Make sure to open the `tsconfig.json` file and verify that the value of the `strict` option is set to `true`.

   ```json
   {
     "compilerOptions": {
       "strict": true
     }
   }
   ```

4. Install the necessary package as dependency:

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

   ```sh
   npm install effect
   ```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

   ```sh
   pnpm add effect
   ```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

   ```sh
   yarn add effect
   ```

   </TabItem>

   </Tabs>

   This package will provide the foundational functionality for your Effect project.


Let's write and run a simple program to ensure that everything is set up correctly.

In your terminal, execute the following commands:

```sh
mkdir src
touch src/index.ts
```

Open the `index.ts` file and add the following code:

```ts title="src/index.ts"

const program = Console.log("Hello, World!")

Effect.runSync(program)
```

Run the `index.ts` file. Here we are using [tsx](https://github.com/privatenumber/tsx) to run the `index.ts` file in the terminal:

```sh
npx tsx src/index.ts
```

You should see the message `"Hello, World!"` printed. This confirms that the program is working correctly.

### Deno

Follow these steps to create a new Effect project for [Deno](https://deno.com/):


1. Create a project directory and navigate into it:

   ```sh
   mkdir hello-effect
   cd hello-effect
   ```

2. Initialize Deno:

   ```sh
   deno init
   ```

3. Install the necessary package as dependency:

   ```sh
   deno add npm:effect
   ```

   This package will provide the foundational functionality for your Effect project.


Let's write and run a simple program to ensure that everything is set up correctly.

Open the `main.ts` file and replace the content with the following code:

```ts title="main.ts"

const program = Console.log("Hello, World!")

Effect.runSync(program)
```

Run the `main.ts` file:

```sh
deno run main.ts
```

You should see the message `"Hello, World!"` printed. This confirms that the program is working correctly.

### Bun

Follow these steps to create a new Effect project for [Bun](https://bun.sh/):


1. Create a project directory and navigate into it:

   ```sh
   mkdir hello-effect
   cd hello-effect
   ```

2. Initialize Bun:

   ```sh
   bun init
   ```

   When running this command, it will generate a `tsconfig.json` file that contains configuration options for TypeScript. One of the most important options to consider is the `strict` flag.

   Make sure to open the `tsconfig.json` file and verify that the value of the `strict` option is set to `true`.

   ```json
   {
     "compilerOptions": {
       "strict": true
     }
   }
   ```

3. Install the necessary package as dependency:

   ```sh
   bun add effect
   ```

   This package will provide the foundational functionality for your Effect project.


Let's write and run a simple program to ensure that everything is set up correctly.

Open the `index.ts` file and replace the content with the following code:

```ts title="index.ts"

const program = Console.log("Hello, World!")

Effect.runSync(program)
```

Run the `index.ts` file:

```sh
bun index.ts
```

You should see the message `"Hello, World!"` printed. This confirms that the program is working correctly.

### Vite + React

Follow these steps to create a new Effect project for [Vite](https://vitejs.dev/guide/) + [React](https://react.dev/):


1. Scaffold your Vite project, open your terminal and run the following command:

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

   ```sh
   # npm 6.x
   npm create vite@latest hello-effect --template react-ts
   # npm 7+, extra double-dash is needed
   npm create vite@latest hello-effect -- --template react-ts
   ```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

   ```sh
   pnpm create vite@latest hello-effect -- --template react-ts
   ```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

   ```sh
   yarn create vite@latest hello-effect -- --template react-ts
   ```

   </TabItem>

   <TabItem label="Bun" icon="bun">

   ```sh
   bun create vite@latest hello-effect -- --template react-ts
   ```

   </TabItem>

   <TabItem label="Deno" icon="deno">

   ```sh
   deno init --npm vite@latest hello-effect -- --template react-ts
   ```

   </TabItem>

   </Tabs>

   This command will create a new Vite project with React and TypeScript template.

2. Navigate into the newly created project directory and install the required packages:

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

   ```sh
   cd hello-effect
   npm install
   ```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

   ```sh
   cd hello-effect
   pnpm install
   ```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

   ```sh
   cd hello-effect
   yarn install
   ```

   </TabItem>

   <TabItem label="Bun" icon="bun">

   ```sh
   cd hello-effect
   bun install
   ```

   </TabItem>

   <TabItem label="Deno" icon="deno">

   ```sh
   cd hello-effect
   deno install
   ```

   </TabItem>

   </Tabs>

   Once the packages are installed, open the `tsconfig.json` file and ensure that the value of the `strict` option is set to true.

   ```json
   {
     "compilerOptions": {
       "strict": true
     }
   }
   ```

3. Install the necessary package as dependency:

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

   ```sh
   npm install effect
   ```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

   ```sh
   pnpm add effect
   ```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

   ```sh
   yarn add effect
   ```

   </TabItem>

   <TabItem label="Bun" icon="bun">

   ```sh
   bun add effect
   ```

   </TabItem>

   <TabItem label="Deno" icon="deno">

   ```sh
   deno add npm:effect
   ```

   </TabItem>

   </Tabs>

   This package will provide the foundational functionality for your Effect project.


Now, let's write and run a simple program to ensure that everything is set up correctly.

Open the `src/App.tsx` file and replace its content with the following code:

```diff lang="tsx" title="src/App.tsx"
+import { useState, useMemo, useCallback } from "react"
import reactLogo from "./assets/react.svg"
import viteLogo from "/vite.svg"
import "./App.css"
+import { Effect } from "effect"

function App() {
  const [count, setCount] = useState(0)

+  const task = useMemo(
+    () => Effect.sync(() => setCount((current) => current + 1)),
+    [setCount]
+  )
+
+  const increment = useCallback(() => Effect.runSync(task), [task])

  return (
    <>
      <div>
        <a href="https://vitejs.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="card">
+        <button onClick={increment}>count is {count}</button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  )
}

export default App
```

After making these changes, start the development server by running the following command:



```sh
npm run dev
```



```sh
pnpm run dev
```



```sh
yarn run dev
```



```sh
bun run dev
```



```sh
deno run dev
```



Then, press **o** to open the application in your browser.

When you click the button, you should see the counter increment. This confirms that the program is working correctly.


---

# [Importing Effect](https://effect.website/docs/getting-started/importing-effect/)

## Overview


If you're just getting started, you might feel overwhelmed by the variety of modules and functions that Effect offers.

However, rest assured that you don't need to worry about all of them right away.

This page will provide a simple introduction on how to import modules and functions, and explain that installing the `effect` package is generally all you need to begin.

## Installing Effect

If you haven't already installed the `effect` package, you can do so by running the following command in your terminal:



```sh
npm install effect
```



```sh
pnpm add effect
```



```sh
yarn add effect
```



```sh
bun add effect
```



```sh
deno add npm:effect
```



By installing this package, you get access to the core functionality of Effect.

For detailed installation instructions for platforms like Deno or Bun, refer to the [Installation](/docs/getting-started/installation/) guide, which provides step-by-step guidance.

## Importing Modules and Functions

Once you have installed the `effect` package, you can start using its modules and functions in your projects.
Importing modules and functions is straightforward and follows the standard JavaScript/TypeScript import syntax.

To import a module or a function from the `effect` package, simply use the `import` statement at the top of your file. Here's how you can import the `Effect` module:

```ts
```

Now, you have access to the Effect module, which is the heart of the Effect library. It provides various functions to create, compose, and manipulate effectful computations.

## Namespace imports

In addition to importing the `Effect` module with a named import, as shown previously:

```ts
```

You can also import it using a namespace import like this:

```ts
import * as Effect from "effect/Effect"
```

Both forms of import allow you to access the functionalities provided by the `Effect` module.

However an important consideration is **tree shaking**, which refers to a process that eliminates unused code during the bundling of your application.
Named imports may generate tree shaking issues when a bundler doesn't support deep scope analysis.

Here are some bundlers that support deep scope analysis and thus don't have issues with named imports:

- Rollup
- Webpack 5+

## Functions vs Methods

In the Effect ecosystem, libraries often expose functions rather than methods. This design choice is important for two key reasons: tree shakeability and extendibility.

### Tree Shakeability

Tree shakeability refers to the ability of a build system to eliminate unused code during the bundling process. Functions are tree shakeable, while methods are not.

When functions are used in the Effect ecosystem, only the functions that are actually imported and used in your application will be included in the final bundled code. Unused functions are automatically removed, resulting in a smaller bundle size and improved performance.

On the other hand, methods are attached to objects or prototypes, and they cannot be easily tree shaken. Even if you only use a subset of methods, all methods associated with an object or prototype will be included in the bundle, leading to unnecessary code bloat.

### Extendibility

Another important advantage of using functions in the Effect ecosystem is the ease of extendibility. With methods, extending the functionality of an existing API often requires modifying the prototype of the object, which can be complex and error-prone.

In contrast, with functions, extending the functionality is much simpler. You can define your own "extension methods" as plain old functions without the need to modify the prototypes of objects. This promotes cleaner and more modular code, and it also allows for better compatibility with other libraries and modules.

## Commonly Used Functions

As you start your adventure with Effect, you don't need to dive into every function in the `effect` package right away. Instead, focus on some commonly used functions that will provide a solid foundation for your journey into the world of Effect.

In the upcoming guides, we will explore some of these essential functions, specifically those for creating and running `Effect`s and building pipelines.

But before we dive into those, let's start from the very heart of Effect: understanding the `Effect` type. This will lay the groundwork for your understanding of how Effect brings composability, type safety, and error handling into your applications.

So, let's take the first step and explore the fundamental concepts of the [The Effect Type](/docs/getting-started/the-effect-type/).


---

# [The Effect Type](https://effect.website/docs/getting-started/the-effect-type/)

## Overview


The `Effect` type is a description of a workflow or operation that is **lazily** executed. This means that when you create an `Effect`, it doesn't run immediately, but instead defines a program that can succeed, fail, or require some additional context to complete.

Here is the general form of an `Effect`:

```text
         ┌─── Represents the success type
         │        ┌─── Represents the error type
         │        │      ┌─── Represents required dependencies
         ▼        ▼      ▼
Effect<Success, Error, Requirements>
```

This type indicates that an effect:

- Succeeds and returns a value of type `Success`
- Fails with an error of type `Error`
- May need certain contextual dependencies of type `Requirements` to execute

Conceptually, you can think of `Effect` as an effectful version of the following function type:

```ts
type Effect<Success, Error, Requirements> = (
  context: Context<Requirements>
) => Error | Success
```

However, effects are not actually functions. They can model synchronous, asynchronous, concurrent, and resourceful computations.

**Immutability**. `Effect` values are immutable, and every function in the Effect library produces a new `Effect` value.

**Modeling Interactions**. These values do not perform any actions themselves, they simply model or describe effectful interactions.

**Execution**. An `Effect` can be executed by the [Effect Runtime System](/docs/runtime/), which interprets it into actual interactions with the external world.
Ideally, this execution happens at a single entry point in your application, such as the main function where effectful operations are initiated.

## Type Parameters

The `Effect` type has three type parameters with the following meanings:

| Parameter        | Description                                                                                                                                                                                                                                    |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Success**      | Represents the type of value that an effect can succeed with when executed. If this type parameter is `void`, it means the effect produces no useful information, while if it is `never`, it means the effect runs forever (or until failure). |
| **Error**        | Represents the expected errors that can occur when executing an effect. If this type parameter is `never`, it means the effect cannot fail, because there are no values of type `never`.                                                       |
| **Requirements** | Represents the contextual data required by the effect to be executed. This data is stored in a collection named `Context`. If this type parameter is `never`, it means the effect has no requirements and the `Context` collection is empty.   |

> **Note: Type Parameter Abbreviations**
  In the Effect ecosystem, you may often encounter the type parameters of
  `Effect` abbreviated as `A`, `E`, and `R` respectively. This is just
  shorthand for the success value of type **A**, **E**rror, and
  **R**equirements.


## Extracting Inferred Types

By using the utility types `Effect.Success`, `Effect.Error`, and `Effect.Context`, you can extract the corresponding types from an effect.

**Example** (Extracting Success, Error, and Context Types)

```ts

class SomeContext extends Context.Tag("SomeContext")<SomeContext, {}>() {}

// Assume we have an effect that succeeds with a number,
// fails with an Error, and requires SomeContext
declare const program: Effect.Effect<number, Error, SomeContext>

// Extract the success type, which is number
type A = Effect.Effect.Success<typeof program>

// Extract the error type, which is Error
type E = Effect.Effect.Error<typeof program>

// Extract the context type, which is SomeContext
type R = Effect.Effect.Context<typeof program>
```


---

# [Creating Effects](https://effect.website/docs/getting-started/creating-effects/)

## Overview


Effect provides different ways to create effects, which are units of computation that encapsulate side effects.
In this guide, we will cover some of the common methods that you can use to create effects.

## Why Not Throw Errors?

In traditional programming, when an error occurs, it is often handled by throwing an exception:

```ts
// Type signature doesn't show possible exceptions
const divide = (a: number, b: number): number => {
  if (b === 0) {
    throw new Error("Cannot divide by zero")
  }
  return a / b
}
```

However, throwing errors can be problematic. The type signatures of functions do not indicate that they can throw exceptions, making it difficult to reason about potential errors.

To address this issue, Effect introduces dedicated constructors for creating effects that represent both success and failure: `Effect.succeed` and `Effect.fail`. These constructors allow you to explicitly handle success and failure cases while **leveraging the type system to track errors**.

### succeed

Creates an `Effect` that always succeeds with a given value.

Use this function when you need an effect that completes successfully with a specific value
without any errors or external dependencies.

**Example** (Creating a Successful Effect)

```ts

//      ┌─── Effect<number, never, never>
//      ▼
const success = Effect.succeed(42)
```

The type of `success` is `Effect<number, never, never>`, which means:

- It produces a value of type `number`.
- It does not generate any errors (`never` indicates no errors).
- It requires no additional data or dependencies (`never` indicates no requirements).

```text
         ┌─── Produces a value of type number
         │       ┌─── Does not generate any errors
         │       │      ┌─── Requires no dependencies
         ▼       ▼      ▼
Effect<number, never, never>
```

### fail

Creates an `Effect` that represents an error that can be recovered from.

Use this function to explicitly signal an error in an `Effect`. The error
will keep propagating unless it is handled. You can handle the error with
functions like [Effect.catchAll](/docs/error-management/expected-errors/#catchall) or
[Effect.catchTag](/docs/error-management/expected-errors/#catchtag).

**Example** (Creating a Failed Effect)

```ts

//      ┌─── Effect<never, Error, never>
//      ▼
const failure = Effect.fail(
  new Error("Operation failed due to network error")
)
```

The type of `failure` is `Effect<never, Error, never>`, which means:

- It never produces a value (`never` indicates that no successful result will be produced).
- It fails with an error, specifically an `Error`.
- It requires no additional data or dependencies (`never` indicates no requirements).

```text
         ┌─── Never produces a value
         │      ┌─── Fails with an Error
         │      │      ┌─── Requires no dependencies
         ▼      ▼      ▼
Effect<never, Error, never>
```

Although you can use `Error` objects with `Effect.fail`, you can also pass strings, numbers, or more complex objects depending on your error management strategy.

Using "tagged" errors (objects with a `_tag` field) can help identify error types and works well with standard Effect functions, like [Effect.catchTag](/docs/error-management/expected-errors/#catchtag).

**Example** (Using Tagged Errors)

```ts

class HttpError extends Data.TaggedError("HttpError")<{}> {}

//      ┌─── Effect<never, HttpError, never>
//      ▼
const program = Effect.fail(new HttpError())
```

## Error Tracking

With `Effect.succeed` and `Effect.fail`, you can explicitly handle success and failure cases and the type system will ensure that errors are tracked and accounted for.

**Example** (Rewriting a Division Function)

Here's how you can rewrite the [`divide`](#why-not-throw-errors) function using Effect, making error handling explicit.

```ts

const divide = (a: number, b: number): Effect.Effect<number, Error> =>
  b === 0
    ? Effect.fail(new Error("Cannot divide by zero"))
    : Effect.succeed(a / b)
```

In this example, the `divide` function indicates in its return type `Effect<number, Error>` that the operation can either succeed with a `number` or fail with an `Error`.

```text
         ┌─── Produces a value of type number
         │       ┌─── Fails with an Error
         ▼       ▼
Effect<number, Error>
```

This clear type signature helps ensure that errors are handled properly and that anyone calling the function is aware of the possible outcomes.

**Example** (Simulating a User Retrieval Operation)

Let's imagine another scenario where we use `Effect.succeed` and `Effect.fail` to model a simple user retrieval operation where the user data is hardcoded, which could be useful in testing scenarios or when mocking data:

```ts

// Define a User type
interface User {
  readonly id: number
  readonly name: string
}

// A mocked function to simulate fetching a user from a database
const getUser = (userId: number): Effect.Effect<User, Error> => {
  // Normally, you would access a database or API here, but we'll mock it
  const userDatabase: Record<number, User> = {
    1: { id: 1, name: "John Doe" },
    2: { id: 2, name: "Jane Smith" }
  }

  // Check if the user exists in our "database" and return appropriately
  const user = userDatabase[userId]
  if (user) {
    return Effect.succeed(user)
  } else {
    return Effect.fail(new Error("User not found"))
  }
}

// When executed, this will successfully return the user with id 1
const exampleUserEffect = getUser(1)
```

In this example, `exampleUserEffect`, which has the type `Effect<User, Error>`, will either produce a `User` object or an `Error`, depending on whether the user exists in the mocked database.

For a deeper dive into managing errors in your applications, refer to the [Error Management Guide](/docs/error-management/expected-errors/).

## Modeling Synchronous Effects

In JavaScript, you can delay the execution of synchronous computations using "thunks".

> **Note: Thunks**
  A "thunk" is a function that takes no arguments and may return some
  value.


Thunks are useful for delaying the computation of a value until it is needed.

To model synchronous side effects, Effect provides the `Effect.sync` and `Effect.try` constructors, which accept a thunk.

### sync

Creates an `Effect` that represents a synchronous side-effectful computation.

Use `Effect.sync` when you are sure the operation will not fail.

The provided function (`thunk`) must not throw errors; if it does, the error will be treated as a ["defect"](/docs/error-management/unexpected-errors/).

This defect is not a standard error but indicates a flaw in the logic that was expected to be error-free.
You can think of it similar to an unexpected crash in the program, which can be further managed or logged using tools like [Effect.catchAllDefect](/docs/error-management/unexpected-errors/#catchalldefect).
This feature ensures that even unexpected failures in your application are not lost and can be handled appropriately.

**Example** (Logging a Message)

In the example below, `Effect.sync` is used to defer the side-effect of writing to the console.

```ts

const log = (message: string) =>
  Effect.sync(() => {
    console.log(message) // side effect
  })

//      ┌─── Effect<void, never, never>
//      ▼
const program = log("Hello, World!")
```

The side effect (logging to the console) encapsulated within `program` won't occur until the effect is explicitly run (see the [Running Effects](/docs/getting-started/running-effects/) section for more details). This allows you to define side effects at one point in your code and control when they are activated, improving manageability and predictability of side effects in larger applications.

### try

Creates an `Effect` that represents a synchronous computation that might fail.

In situations where you need to perform synchronous operations that might fail, such as parsing JSON, you can use the `Effect.try` constructor.
This constructor is designed to handle operations that could throw exceptions by capturing those exceptions and transforming them into manageable errors.

**Example** (Safe JSON Parsing)

Suppose you have a function that attempts to parse a JSON string. This operation can fail and throw an error if the input string is not properly formatted as JSON:

```ts

const parse = (input: string) =>
  // This might throw an error if input is not valid JSON
  Effect.try(() => JSON.parse(input))

//      ┌─── Effect<any, UnknownException, never>
//      ▼
const program = parse("")
```

In this example:

- `parse` is a function that creates an effect encapsulating the JSON parsing operation.
- If `JSON.parse(input)` throws an error due to invalid input, `Effect.try` catches this error and the effect represented by `program` will fail with an `UnknownException`. This ensures that errors are not silently ignored but are instead handled within the structured flow of effects.

#### Customizing Error Handling

You might want to transform the caught exception into a more specific error or perform additional operations when catching an error. `Effect.try` supports an overload that allows you to specify how caught exceptions should be transformed:

**Example** (Custom Error Handling)

```ts

const parse = (input: string) =>
  Effect.try({
    // JSON.parse may throw for bad input
    try: () => JSON.parse(input),
    // remap the error
    catch: (unknown) => new Error(`something went wrong ${unknown}`)
  })

//      ┌─── Effect<any, Error, never>
//      ▼
const program = parse("")
```

You can think of this as a similar pattern to the traditional try-catch block in JavaScript:

```ts
try {
  return JSON.parse(input)
} catch (unknown) {
  throw new Error(`something went wrong ${unknown}`)
}
```

## Modeling Asynchronous Effects

In traditional programming, we often use `Promise`s to handle asynchronous computations. However, dealing with errors in promises can be problematic. By default, `Promise<Value>` only provides the type `Value` for the resolved value, which means errors are not reflected in the type system. This limits the expressiveness and makes it challenging to handle and track errors effectively.

To overcome these limitations, Effect introduces dedicated constructors for creating effects that represent both success and failure in an asynchronous context: `Effect.promise` and `Effect.tryPromise`. These constructors allow you to explicitly handle success and failure cases while **leveraging the type system to track errors**.

### promise

Creates an `Effect` that represents an asynchronous computation guaranteed to succeed.

Use `Effect.promise` when you are sure the operation will not reject.

The provided function (`thunk`) returns a `Promise` that should never reject; if it does, the error will be treated as a ["defect"](/docs/error-management/unexpected-errors/).

This defect is not a standard error but indicates a flaw in the logic that was expected to be error-free.
You can think of it similar to an unexpected crash in the program, which can be further managed or logged using tools like [Effect.catchAllDefect](/docs/error-management/unexpected-errors/#catchalldefect).
This feature ensures that even unexpected failures in your application are not lost and can be handled appropriately.

**Example** (Delayed Message)

```ts

const delay = (message: string) =>
  Effect.promise<string>(
    () =>
      new Promise((resolve) => {
        setTimeout(() => {
          resolve(message)
        }, 2000)
      })
  )

//      ┌─── Effect<string, never, never>
//      ▼
const program = delay("Async operation completed successfully!")
```

The `program` value has the type `Effect<string, never, never>` and can be interpreted as an effect that:

- succeeds with a value of type `string`
- does not produce any expected error (`never`)
- does not require any context (`never`)

### tryPromise

Creates an `Effect` that represents an asynchronous computation that might fail.

Unlike `Effect.promise`, this constructor is suitable when the underlying `Promise` might reject.
It provides a way to catch errors and handle them appropriately.
By default if an error occurs, it will be caught and propagated to the error channel as an `UnknownException`.

**Example** (Fetching a TODO Item)

```ts

const getTodo = (id: number) =>
  // Will catch any errors and propagate them as UnknownException
  Effect.tryPromise(() =>
    fetch(`https://jsonplaceholder.typicode.com/todos/${id}`)
  )

//      ┌─── Effect<Response, UnknownException, never>
//      ▼
const program = getTodo(1)
```

The `program` value has the type `Effect<Response, UnknownException, never>` and can be interpreted as an effect that:

- succeeds with a value of type `Response`
- might produce an error (`UnknownException`)
- does not require any context (`never`)

#### Customizing Error Handling

If you want more control over what gets propagated to the error channel, you can use an overload of `Effect.tryPromise` that takes a remapping function:

**Example** (Custom Error Handling)

```ts

const getTodo = (id: number) =>
  Effect.tryPromise({
    try: () => fetch(`https://jsonplaceholder.typicode.com/todos/${id}`),
    // remap the error
    catch: (unknown) => new Error(`something went wrong ${unknown}`)
  })

//      ┌─── Effect<Response, Error, never>
//      ▼
const program = getTodo(1)
```

## From a Callback

Creates an `Effect` from a callback-based asynchronous function.

Sometimes you have to work with APIs that don't support `async/await` or `Promise` and instead use the callback style.
To handle callback-based APIs, Effect provides the `Effect.async` constructor.

**Example** (Wrapping a Callback API)

Let's wrap the `readFile` function from Node.js's `fs` module into an Effect-based API (make sure `@types/node` is installed):

```ts
import * as NodeFS from "node:fs"

const readFile = (filename: string) =>
  Effect.async<Buffer, Error>((resume) => {
    NodeFS.readFile(filename, (error, data) => {
      if (error) {
        // Resume with a failed Effect if an error occurs
        resume(Effect.fail(error))
      } else {
        // Resume with a succeeded Effect if successful
        resume(Effect.succeed(data))
      }
    })
  })

//      ┌─── Effect<Buffer, Error, never>
//      ▼
const program = readFile("example.txt")
```

In the above example, we manually annotate the types when calling `Effect.async`:

```ts
Effect.async<Buffer, Error>((resume) => {
  // ...
})
```

because TypeScript cannot infer the type parameters for a callback
based on the return value inside the callback body. Annotating the types ensures that the values provided to `resume` match the expected types.

The `resume` function inside `Effect.async` should be called exactly once. Calling it more than once will result in the extra calls being ignored.

**Example** (Ignoring Subsequent `resume` Calls)

```ts

const program = Effect.async<number>((resume) => {
  resume(Effect.succeed(1))
  resume(Effect.succeed(2)) // This line will be ignored
})

// Run the program
Effect.runPromise(program).then(console.log) // Output: 1
```

### Advanced Usage

For more advanced use cases, the callback passed to Effect.async may return an Effect that will be executed if the fiber running this effect is interrupted. This can be used to perform cleanup when the operation is cancelled.

**Example** (Handling Interruption with Cleanup)

In this example:

- The `writeFileWithCleanup` function writes data to a file.
- If the fiber running this effect is interrupted, the cleanup effect (which deletes the file) is executed.
- This ensures that resources like open file handles are cleaned up properly when the operation is canceled.

```ts
import * as NodeFS from "node:fs"

// Simulates a long-running operation to write to a file
const writeFileWithCleanup = (filename: string, data: string) =>
  Effect.async<void, Error>((resume) => {
    const writeStream = NodeFS.createWriteStream(filename)

    // Start writing data to the file
    writeStream.write(data)

    // When the stream is finished, resume with success
    writeStream.on("finish", () => resume(Effect.void))

    // In case of an error during writing, resume with failure
    writeStream.on("error", (err) => resume(Effect.fail(err)))

    // Handle interruption by returning a cleanup effect
    return Effect.sync(() => {
      console.log(`Cleaning up ${filename}`)
      NodeFS.unlinkSync(filename)
    })
  })

const program = Effect.gen(function* () {
  const fiber = yield* Effect.fork(
    writeFileWithCleanup("example.txt", "Some long data...")
  )
  // Simulate interrupting the fiber after 1 second
  yield* Effect.sleep("1 second")
  yield* Fiber.interrupt(fiber) // This will trigger the cleanup
})

// Run the program
Effect.runPromise(program)
/*
Output:
Cleaning up example.txt
*/
```

If the operation you're wrapping supports interruption, the `resume` function can receive an `AbortSignal` to handle interruption requests directly.

**Example** (Handling Interruption with `AbortSignal`)

```ts

// A task that supports interruption using AbortSignal
const interruptibleTask = Effect.async<void, Error>((resume, signal) => {
  // Simulate a long-running task
  const timeoutId = setTimeout(() => {
    console.log("Operation completed")
    resume(Effect.void)
  }, 2000)

  // Handle interruption
  signal.addEventListener("abort", () => {
    console.log("Abort signal received")
    clearTimeout(timeoutId)
  })
})

const program = Effect.gen(function* () {
  const fiber = yield* Effect.fork(interruptibleTask)
  // Simulate interrupting the fiber after 1 second
  yield* Effect.sleep("1 second")
  yield* Fiber.interrupt(fiber)
})

// Run the program
Effect.runPromise(program)
/*
Output:
Abort signal received
*/
```

## Suspended Effects

`Effect.suspend` is used to delay the creation of an effect.
It allows you to defer the evaluation of an effect until it is actually needed.
The `Effect.suspend` function takes a thunk that represents the effect, and it wraps it in a suspended effect.

**Syntax**

```ts
const suspendedEffect = Effect.suspend(() => effect)
```

Let's explore some common scenarios where `Effect.suspend` proves useful.

### Lazy Evaluation

When you want to defer the evaluation of an effect until it is required. This can be useful for optimizing the execution of effects, especially when they are not always needed or when their computation is expensive.

Also, when effects with side effects or scoped captures are created, use `Effect.suspend` to re-execute on each invocation.

**Example** (Lazy Evaluation with Side Effects)

```ts

let i = 0

const bad = Effect.succeed(i++)

const good = Effect.suspend(() => Effect.succeed(i++))

console.log(Effect.runSync(bad)) // Output: 0
console.log(Effect.runSync(bad)) // Output: 0

console.log(Effect.runSync(good)) // Output: 1
console.log(Effect.runSync(good)) // Output: 2
```

> **Note: Running Effects**
  This example utilizes `Effect.runSync` to execute effects and display
  their results (refer to [Running
  Effects](/docs/getting-started/running-effects/#runsync) for more
  details).


In this example, `bad` is the result of calling `Effect.succeed(i++)` a single time, which increments the scoped variable but [returns its original value](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Increment#postfix_increment). `Effect.runSync(bad)` does not result in any new computation, because `Effect.succeed(i++)` has already been called. On the other hand, each time `Effect.runSync(good)` is called, the thunk passed to `Effect.suspend()` will be executed, outputting the scoped variable's most recent value.

### Handling Circular Dependencies

`Effect.suspend` is helpful in managing circular dependencies between effects, where one effect depends on another, and vice versa.
For example it's fairly common for `Effect.suspend` to be used in recursive functions to escape an eager call.

**Example** (Recursive Fibonacci)

```ts

const blowsUp = (n: number): Effect.Effect<number> =>
  n < 2
    ? Effect.succeed(1)
    : Effect.zipWith(blowsUp(n - 1), blowsUp(n - 2), (a, b) => a + b)

// console.log(Effect.runSync(blowsUp(32)))
// crash: JavaScript heap out of memory

const allGood = (n: number): Effect.Effect<number> =>
  n < 2
    ? Effect.succeed(1)
    : Effect.zipWith(
        Effect.suspend(() => allGood(n - 1)),
        Effect.suspend(() => allGood(n - 2)),
        (a, b) => a + b
      )

console.log(Effect.runSync(allGood(32))) // Output: 3524578
```

> **Note: Running Effects**
  This example utilizes `Effect.zipWith` to combine the results of two
  effects (refer to the documentation on
  [zipping](/docs/getting-started/control-flow/#zipwith) for more
  details).


The `blowsUp` function creates a recursive Fibonacci sequence without deferring execution. Each call to `blowsUp` triggers further immediate recursive calls, rapidly increasing the JavaScript call stack size.

Conversely, `allGood` avoids stack overflow by using `Effect.suspend` to defer the recursive calls. This mechanism doesn't immediately execute the recursive effects but schedules them to be run later, thus keeping the call stack shallow and preventing a crash.

### Unifying Return Type

In situations where TypeScript struggles to unify the returned effect type, `Effect.suspend` can be employed to resolve this issue.

**Example** (Using `Effect.suspend` to Help TypeScript Infer Types)

```ts

/*
  Without suspend, TypeScript may struggle with type inference.

  Inferred type:
    (a: number, b: number) =>
      Effect<never, Error, never> | Effect<number, never, never>
*/
const withoutSuspend = (a: number, b: number) =>
  b === 0
    ? Effect.fail(new Error("Cannot divide by zero"))
    : Effect.succeed(a / b)

/*
  Using suspend to unify return types.

  Inferred type:
    (a: number, b: number) => Effect<number, Error, never>
*/
const withSuspend = (a: number, b: number) =>
  Effect.suspend(() =>
    b === 0
      ? Effect.fail(new Error("Cannot divide by zero"))
      : Effect.succeed(a / b)
  )
```

## Cheatsheet

The table provides a summary of the available constructors, along with their input and output types, allowing you to choose the appropriate function based on your needs.

| API                     | Given                              | Result                        |
| ----------------------- | ---------------------------------- | ----------------------------- |
| `succeed`               | `A`                                | `Effect<A>`                   |
| `fail`                  | `E`                                | `Effect<never, E>`            |
| `sync`                  | `() => A`                          | `Effect<A>`                   |
| `try`                   | `() => A`                          | `Effect<A, UnknownException>` |
| `try` (overload)        | `() => A`, `unknown => E`          | `Effect<A, E>`                |
| `promise`               | `() => Promise<A>`                 | `Effect<A>`                   |
| `tryPromise`            | `() => Promise<A>`                 | `Effect<A, UnknownException>` |
| `tryPromise` (overload) | `() => Promise<A>`, `unknown => E` | `Effect<A, E>`                |
| `async`                 | `(Effect<A, E> => void) => void`   | `Effect<A, E>`                |
| `suspend`               | `() => Effect<A, E, R>`            | `Effect<A, E, R>`             |

For the complete list of constructors, visit the [Effect Constructors Documentation](https://effect-ts.github.io/effect/effect/Effect.ts.html#constructors).


---

# [Building Pipelines](https://effect.website/docs/getting-started/building-pipelines/)

## Overview


Effect pipelines allow for the composition and sequencing of operations on values, enabling the transformation and manipulation of data in a concise and modular manner.

## Why Pipelines are Good for Structuring Your Application

Pipelines are an excellent way to structure your application and handle data transformations in a concise and modular manner. They offer several benefits:

1. **Readability**: Pipelines allow you to compose functions in a readable and sequential manner. You can clearly see the flow of data and the operations applied to it, making it easier to understand and maintain the code.

2. **Code Organization**: With pipelines, you can break down complex operations into smaller, manageable functions. Each function performs a specific task, making your code more modular and easier to reason about.

3. **Reusability**: Pipelines promote the reuse of functions. By breaking down operations into smaller functions, you can reuse them in different pipelines or contexts, improving code reuse and reducing duplication.

4. **Type Safety**: By leveraging the type system, pipelines help catch errors at compile-time. Functions in a pipeline have well-defined input and output types, ensuring that the data flows correctly through the pipeline and minimizing runtime errors.

## Functions vs Methods

The use of functions in the Effect ecosystem libraries is important for
achieving **tree shakeability** and ensuring **extensibility**.
Functions enable efficient bundling by eliminating unused code, and they
provide a flexible and modular approach to extending the libraries'
functionality.

### Tree Shakeability

Tree shakeability refers to the ability of a build system to eliminate unused code during the bundling process. Functions are tree shakeable, while methods are not.

When functions are used in the Effect ecosystem, only the functions that are actually imported and used in your application will be included in the final bundled code. Unused functions are automatically removed, resulting in a smaller bundle size and improved performance.

On the other hand, methods are attached to objects or prototypes, and they cannot be easily tree shaken. Even if you only use a subset of methods, all methods associated with an object or prototype will be included in the bundle, leading to unnecessary code bloat.

### Extensibility

Another important advantage of using functions in the Effect ecosystem is the ease of extensibility. With methods, extending the functionality of an existing API often requires modifying the prototype of the object, which can be complex and error-prone.

In contrast, with functions, extending the functionality is much simpler. You can define your own "extension methods" as plain old functions without the need to modify the prototypes of objects. This promotes cleaner and more modular code, and it also allows for better compatibility with other libraries and modules.

## pipe

The `pipe` function is a utility that allows us to compose functions in a readable and sequential manner. It takes the output of one function and passes it as the input to the next function in the pipeline. This enables us to build complex transformations by chaining multiple functions together.

**Syntax**

```ts

const result = pipe(input, func1, func2, ..., funcN)
```

In this syntax, `input` is the initial value, and `func1`, `func2`, ..., `funcN` are the functions to be applied in sequence. The result of each function becomes the input for the next function, and the final result is returned.

Here's an illustration of how `pipe` works:

```text
┌───────┐    ┌───────┐    ┌───────┐    ┌───────┐    ┌───────┐    ┌────────┐
│ input │───►│ func1 │───►│ func2 │───►│  ...  │───►│ funcN │───►│ result │
└───────┘    └───────┘    └───────┘    └───────┘    └───────┘    └────────┘
```

It's important to note that functions passed to `pipe` must have a **single argument** because they are only called with a single argument.

Let's see an example to better understand how `pipe` works:

**Example** (Chaining Arithmetic Operations)

```ts

// Define simple arithmetic operations
const increment = (x: number) => x + 1
const double = (x: number) => x * 2
const subtractTen = (x: number) => x - 10

// Sequentially apply these operations using `pipe`
const result = pipe(5, increment, double, subtractTen)

console.log(result)
// Output: 2
```

In the above example, we start with an input value of `5`. The `increment` function adds `1` to the initial value, resulting in `6`. Then, the `double` function doubles the value, giving us `12`. Finally, the `subtractTen` function subtracts `10` from `12`, resulting in the final output of `2`.

The result is equivalent to `subtractTen(double(increment(5)))`, but using `pipe` makes the code more readable because the operations are sequenced from left to right, rather than nesting them inside out.

## map

Transforms the value inside an effect by applying a function to it.

**Syntax**

```ts
const mappedEffect = pipe(myEffect, Effect.map(transformation))
// or
const mappedEffect = Effect.map(myEffect, transformation)
// or
const mappedEffect = myEffect.pipe(Effect.map(transformation))
```

`Effect.map` takes a function and applies it to the value contained within an
effect, creating a new effect with the transformed value.

> **Note: Effects are Immutable**
  It's important to note that effects are immutable, meaning that the
  original effect is not modified. Instead, a new effect is returned with
  the updated value.


**Example** (Adding a Service Charge)

Here's a practical example where we apply a service charge to a transaction amount:

```ts

// Function to add a small service charge to a transaction amount
const addServiceCharge = (amount: number) => amount + 1

// Simulated asynchronous task to fetch a transaction amount from database
const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

// Apply service charge to the transaction amount
const finalAmount = pipe(
  fetchTransactionAmount,
  Effect.map(addServiceCharge)
)

Effect.runPromise(finalAmount).then(console.log) // Output: 101
```

## as

Replaces the value inside an effect with a constant value.

`Effect.as` allows you to ignore the original value inside an effect and replace it with a new constant value.

> **Note: Effects are Immutable**
  It's important to note that effects are immutable, meaning that the
  original effect is not modified. Instead, a new effect is returned with
  the updated value.


**Example** (Replacing a Value)

```ts

// Replace the value 5 with the constant "new value"
const program = pipe(Effect.succeed(5), Effect.as("new value"))

Effect.runPromise(program).then(console.log) // Output: "new value"
```

## flatMap

Chains effects to produce new `Effect` instances, useful for combining operations that depend on previous results.

**Syntax**

```ts
const flatMappedEffect = pipe(myEffect, Effect.flatMap(transformation))
// or
const flatMappedEffect = Effect.flatMap(myEffect, transformation)
// or
const flatMappedEffect = myEffect.pipe(Effect.flatMap(transformation))
```

In the code above, `transformation` is the function that takes a value and returns an `Effect`, and `myEffect` is the initial `Effect` being transformed.

Use `Effect.flatMap` when you need to chain multiple effects, ensuring that each
step produces a new `Effect` while flattening any nested effects that may
occur.

It is similar to `flatMap` used with arrays but works
specifically with `Effect` instances, allowing you to avoid deeply nested
effect structures.

> **Note: Effects are Immutable**
  It's important to note that effects are immutable, meaning that the
  original effect is not modified. Instead, a new effect is returned with
  the updated value.


**Example** (Applying a Discount)

```ts

// Function to apply a discount safely to a transaction amount
const applyDiscount = (
  total: number,
  discountRate: number
): Effect.Effect<number, Error> =>
  discountRate === 0
    ? Effect.fail(new Error("Discount rate cannot be zero"))
    : Effect.succeed(total - (total * discountRate) / 100)

// Simulated asynchronous task to fetch a transaction amount from database
const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

// Chaining the fetch and discount application using `flatMap`
const finalAmount = pipe(
  fetchTransactionAmount,
  Effect.flatMap((amount) => applyDiscount(amount, 5))
)

Effect.runPromise(finalAmount).then(console.log)
// Output: 95
```

### Ensure All Effects Are Considered

Make sure that all effects within `Effect.flatMap` contribute to the final computation. If you ignore an effect, it can lead to unexpected behavior:

```ts {3}
Effect.flatMap((amount) => {
  // This effect will be ignored
  Effect.sync(() => console.log(`Apply a discount to: ${amount}`))
  return applyDiscount(amount, 5)
})
```

In this case, the `Effect.sync` call is ignored and does not affect the result of `applyDiscount(amount, 5)`. To handle effects correctly, make sure to explicitly chain them using functions like `Effect.map`, `Effect.flatMap`, `Effect.andThen`, or `Effect.tap`.

## andThen

Chains two actions, where the second action can depend on the result of the first.

**Syntax**

```ts
const transformedEffect = pipe(myEffect, Effect.andThen(anotherEffect))
// or
const transformedEffect = Effect.andThen(myEffect, anotherEffect)
// or
const transformedEffect = myEffect.pipe(Effect.andThen(anotherEffect))
```

Use `andThen` when you need to run multiple actions in sequence, with the
second action depending on the result of the first. This is useful for
combining effects or handling computations that must happen in order.

The second action can be:

1. A value (similar to `Effect.as`)
2. A function returning a value (similar to `Effect.map`)
3. A `Promise`
4. A function returning a `Promise`
5. An `Effect`
6. A function returning an `Effect` (similar to `Effect.flatMap`)

**Example** (Applying a Discount Based on Fetched Amount)

Let's look at an example comparing `Effect.andThen` with `Effect.map` and `Effect.flatMap`:

```ts

// Function to apply a discount safely to a transaction amount
const applyDiscount = (
  total: number,
  discountRate: number
): Effect.Effect<number, Error> =>
  discountRate === 0
    ? Effect.fail(new Error("Discount rate cannot be zero"))
    : Effect.succeed(total - (total * discountRate) / 100)

// Simulated asynchronous task to fetch a transaction amount from database
const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

// Using Effect.map and Effect.flatMap
const result1 = pipe(
  fetchTransactionAmount,
  Effect.map((amount) => amount * 2),
  Effect.flatMap((amount) => applyDiscount(amount, 5))
)

Effect.runPromise(result1).then(console.log) // Output: 190

// Using Effect.andThen
const result2 = pipe(
  fetchTransactionAmount,
  Effect.andThen((amount) => amount * 2),
  Effect.andThen((amount) => applyDiscount(amount, 5))
)

Effect.runPromise(result2).then(console.log) // Output: 190
```

### Option and Either with andThen

Both [Option](/docs/data-types/option/#interop-with-effect) and [Either](/docs/data-types/either/#interop-with-effect) are commonly used for handling optional or missing values or simple error cases. These types integrate well with `Effect.andThen`. When used with `Effect.andThen`, the operations are categorized as scenarios 5 and 6 (as discussed earlier) because both `Option` and `Either` are treated as effects in this context.

**Example** (with Option)

```ts

// Simulated asynchronous task fetching a number from a database
const fetchNumberValue = Effect.tryPromise(() => Promise.resolve(42))

//      ┌─── Effect<number, UnknownException | NoSuchElementException, never>
//      ▼
const program = pipe(
  fetchNumberValue,
  Effect.andThen((x) => (x > 0 ? Option.some(x) : Option.none()))
)
```

You might expect the type of `program` to be `Effect<Option<number>, UnknownException, never>`, but it is actually `Effect<number, UnknownException | NoSuchElementException, never>`.

This is because `Option<A>` is treated as an effect of type `Effect<A, NoSuchElementException>`, and as a result, the possible errors are combined into a union type.

> **Tip: Option As Effect**
A value of type `Option<A>` is interpreted as an effect of type `Effect<A, NoSuchElementException>`.


**Example** (with Either)

```ts

// Function to parse an integer from a string that can fail
const parseInteger = (input: string): Either.Either<number, string> =>
  isNaN(parseInt(input))
    ? Either.left("Invalid integer")
    : Either.right(parseInt(input))

// Simulated asynchronous task fetching a string from database
const fetchStringValue = Effect.tryPromise(() => Promise.resolve("42"))

//      ┌─── Effect<number, string | UnknownException, never>
//      ▼
const program = pipe(
  fetchStringValue,
  Effect.andThen((str) => parseInteger(str))
)
```

Although one might expect the type of `program` to be `Effect<Either<number, string>, UnknownException, never>`, it is actually `Effect<number, string | UnknownException, never>`.

This is because `Either<A, E>` is treated as an effect of type `Effect<A, E>`, meaning the errors are combined into a union type.

> **Tip: Either As Effect**
A value of type `Either<A, E>` is interpreted as an effect of type `Effect<A, E>`.


## tap

Runs a side effect with the result of an effect without changing the original value.

Use `Effect.tap` when you want to perform a side effect, like logging or tracking,
without modifying the main value. This is useful when you need to observe or
record an action but want the original value to be passed to the next step.

`Effect.tap` works similarly to `Effect.flatMap`, but it ignores the result of the function
passed to it. The value from the previous effect remains available for the
next part of the chain. Note that if the side effect fails, the entire chain
will fail too.

**Example** (Logging a step in a pipeline)

```ts

// Function to apply a discount safely to a transaction amount
const applyDiscount = (
  total: number,
  discountRate: number
): Effect.Effect<number, Error> =>
  discountRate === 0
    ? Effect.fail(new Error("Discount rate cannot be zero"))
    : Effect.succeed(total - (total * discountRate) / 100)

// Simulated asynchronous task to fetch a transaction amount from database
const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

const finalAmount = pipe(
  fetchTransactionAmount,
  // Log the fetched transaction amount
  Effect.tap((amount) => Console.log(`Apply a discount to: ${amount}`)),
  // `amount` is still available!
  Effect.flatMap((amount) => applyDiscount(amount, 5))
)

Effect.runPromise(finalAmount).then(console.log)
/*
Output:
Apply a discount to: 100
95
*/
```

In this example, `Effect.tap` is used to log the transaction amount before applying the discount, without modifying the value itself. The original value (`amount`) remains available for the next operation (`applyDiscount`).

Using `Effect.tap` allows us to execute side effects during the computation without altering the result.
This can be useful for logging, performing additional actions, or observing the intermediate values without interfering with the main computation flow.

## all

Combines multiple effects into one, returning results based on the input structure.

Use `Effect.all` when you need to run multiple effects and combine their results
into a single output. It supports tuples, iterables, structs, and records,
making it flexible for different input types.

For instance, if the input is a tuple:

```ts
//         ┌─── a tuple of effects
//         ▼
Effect.all([effect1, effect2, ...])
```

the effects are executed in order, and the result is a new effect containing the results as a tuple. The results in the tuple match the order of the effects passed to `Effect.all`.

By default, `Effect.all` runs effects sequentially and produces a tuple or object
with the results. If any effect fails, it stops execution (short-circuiting)
and propagates the error.

See [Collecting](/docs/getting-started/control-flow/#all) for more information on how to use `Effect.all`.

**Example** (Combining Configuration and Database Checks)

```ts

// Simulated function to read configuration from a file
const webConfig = Effect.promise(() =>
  Promise.resolve({ dbConnection: "localhost", port: 8080 })
)

// Simulated function to test database connectivity
const checkDatabaseConnectivity = Effect.promise(() =>
  Promise.resolve("Connected to Database")
)

// Combine both effects to perform startup checks
const startupChecks = Effect.all([webConfig, checkDatabaseConnectivity])

Effect.runPromise(startupChecks).then(([config, dbStatus]) => {
  console.log(
    `Configuration: ${JSON.stringify(config)}\nDB Status: ${dbStatus}`
  )
})
/*
Output:
Configuration: {"dbConnection":"localhost","port":8080}
DB Status: Connected to Database
*/
```

## Build your first pipeline

Let's now combine the `pipe` function, `Effect.all`, and `Effect.andThen` to create a pipeline that performs a sequence of transformations.

**Example** (Building a Transaction Pipeline)

```ts

// Function to add a small service charge to a transaction amount
const addServiceCharge = (amount: number) => amount + 1

// Function to apply a discount safely to a transaction amount
const applyDiscount = (
  total: number,
  discountRate: number
): Effect.Effect<number, Error> =>
  discountRate === 0
    ? Effect.fail(new Error("Discount rate cannot be zero"))
    : Effect.succeed(total - (total * discountRate) / 100)

// Simulated asynchronous task to fetch a transaction amount from database
const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

// Simulated asynchronous task to fetch a discount rate
// from a configuration file
const fetchDiscountRate = Effect.promise(() => Promise.resolve(5))

// Assembling the program using a pipeline of effects
const program = pipe(
  // Combine both fetch effects to get the transaction amount
  // and discount rate
  Effect.all([fetchTransactionAmount, fetchDiscountRate]),

  // Apply the discount to the transaction amount
  Effect.andThen(([transactionAmount, discountRate]) =>
    applyDiscount(transactionAmount, discountRate)
  ),

  // Add the service charge to the discounted amount
  Effect.andThen(addServiceCharge),

  // Format the final result for display
  Effect.andThen(
    (finalAmount) => `Final amount to charge: ${finalAmount}`
  )
)

// Execute the program and log the result
Effect.runPromise(program).then(console.log)
// Output: "Final amount to charge: 96"
```

This pipeline demonstrates how you can structure your code by combining different effects into a clear, readable flow.

## The pipe method

Effect provides a `pipe` method that works similarly to the `pipe` method found in [rxjs](https://rxjs.dev/api/index/function/pipe). This method allows you to chain multiple operations together, making your code more concise and readable.

**Syntax**

```ts
const result = effect.pipe(func1, func2, ..., funcN)
```

This is equivalent to using the `pipe` **function** like this:

```ts
const result = pipe(effect, func1, func2, ..., funcN)
```

The `pipe` method is available on all effects and many other data types, eliminating the need to import the `pipe` function and saving you some keystrokes.

**Example** (Using the `pipe` Method)

Let's rewrite an [earlier example](#build-your-first-pipeline), this time using the `pipe` method.

```ts

const addServiceCharge = (amount: number) => amount + 1

const applyDiscount = (
  total: number,
  discountRate: number
): Effect.Effect<number, Error> =>
  discountRate === 0
    ? Effect.fail(new Error("Discount rate cannot be zero"))
    : Effect.succeed(total - (total * discountRate) / 100)

const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

const fetchDiscountRate = Effect.promise(() => Promise.resolve(5))

const program = Effect.all([
  fetchTransactionAmount,
  fetchDiscountRate
]).pipe(
  Effect.andThen(([transactionAmount, discountRate]) =>
    applyDiscount(transactionAmount, discountRate)
  ),
  Effect.andThen(addServiceCharge),
  Effect.andThen(
    (finalAmount) => `Final amount to charge: ${finalAmount}`
  )
)
```

## Cheatsheet

Let's summarize the transformation functions we have seen so far:

| API       | Input                                     | Output                      |
| --------- | ----------------------------------------- | --------------------------- |
| `map`     | `Effect<A, E, R>`, `A => B`               | `Effect<B, E, R>`           |
| `flatMap` | `Effect<A, E, R>`, `A => Effect<B, E, R>` | `Effect<B, E, R>`           |
| `andThen` | `Effect<A, E, R>`, \*                     | `Effect<B, E, R>`           |
| `tap`     | `Effect<A, E, R>`, `A => Effect<B, E, R>` | `Effect<A, E, R>`           |
| `all`     | `[Effect<A, E, R>, Effect<B, E, R>, ...]` | `Effect<[A, B, ...], E, R>` |


---

# [Control Flow Operators](https://effect.website/docs/getting-started/control-flow/)

## Overview

Even though JavaScript provides built-in control flow structures, Effect offers additional control flow functions that are useful in Effect applications. In this section, we will introduce different ways to control the flow of execution.

## if Expression

When working with Effect values, we can use standard JavaScript if-then-else statements:

**Example** (Returning None for Invalid Weight)

Here we are using the [Option](/docs/data-types/option/) data type to represent the absence of a valid value.

```ts

// Function to validate weight and return an Option
const validateWeightOption = (
  weight: number
): Effect.Effect<Option.Option<number>> => {
  if (weight >= 0) {
    // Return Some if the weight is valid
    return Effect.succeed(Option.some(weight))
  } else {
    // Return None if the weight is invalid
    return Effect.succeed(Option.none())
  }
}
```

**Example** (Returning Error for Invalid Weight)

You can also handle invalid inputs by using the error channel, which allows you to return an error when the input is invalid:

```ts

// Function to validate weight or fail with an error
const validateWeightOrFail = (
  weight: number
): Effect.Effect<number, string> => {
  if (weight >= 0) {
    // Return the weight if valid
    return Effect.succeed(weight)
  } else {
    // Fail with an error if invalid
    return Effect.fail(`negative input: ${weight}`)
  }
}
```

## Conditional Operators

### if

Executes one of two effects based on a condition evaluated by an effectful predicate.

Use `Effect.if` to run one of two effects depending on whether the predicate effect
evaluates to `true` or `false`. If the predicate is `true`, the `onTrue` effect
is executed. If it is `false`, the `onFalse` effect is executed instead.

**Example** (Simulating a Coin Flip)

In this example, we simulate a virtual coin flip using `Random.nextBoolean` to generate a random boolean value. If the value is `true`, the `onTrue` effect logs "Head". If the value is `false`, the `onFalse` effect logs "Tail".

```ts

const flipTheCoin = Effect.if(Random.nextBoolean, {
  onTrue: () => Console.log("Head"), // Runs if the predicate is true
  onFalse: () => Console.log("Tail") // Runs if the predicate is false
})

Effect.runFork(flipTheCoin)
```

### when

Conditionally executes an effect based on a boolean condition.

`Effect.when` allows you to conditionally execute an effect, similar to using
an `if (condition)` expression, but with the added benefit of handling
effects. If the condition is `true`, the effect is executed; otherwise, it
does nothing.

The result of the effect is wrapped in an `Option<A>` to indicate whether the
effect was executed. If the condition is `true`, the result of the effect is
wrapped in a `Some`. If the condition is `false`, the result is `None`,
representing that the effect was skipped.

**Example** (Conditional Effect Execution)

```ts

const validateWeightOption = (
  weight: number
): Effect.Effect<Option.Option<number>> =>
  // Conditionally execute the effect if the weight is non-negative
  Effect.succeed(weight).pipe(Effect.when(() => weight >= 0))

// Run with a valid weight
Effect.runPromise(validateWeightOption(100)).then(console.log)
/*
Output:
{
  _id: "Option",
  _tag: "Some",
  value: 100
}
*/

// Run with an invalid weight
Effect.runPromise(validateWeightOption(-5)).then(console.log)
/*
Output:
{
  _id: "Option",
  _tag: "None"
}
*/
```

In this example, the [Option](/docs/data-types/option/) data type is used to represent the presence or absence of a valid value. If the condition evaluates to `true` (in this case, if the weight is non-negative), the effect is executed and wrapped in a `Some`. Otherwise, the result is `None`.

### whenEffect

Executes an effect conditionally, based on the result of another effect.

Use `Effect.whenEffect` when the condition to determine whether to execute the effect
depends on the outcome of another effect that produces a boolean value.
If the condition effect evaluates to `true`, the specified effect is executed.
If it evaluates to `false`, no effect is executed.

The result of the effect is wrapped in an `Option<A>` to indicate whether the
effect was executed. If the condition is `true`, the result of the effect is
wrapped in a `Some`. If the condition is `false`, the result is `None`,
representing that the effect was skipped.

**Example** (Using an Effect as a Condition)

The following function creates a random integer, but only if a randomly generated boolean is `true`.

```ts

const randomIntOption = Random.nextInt.pipe(
  Effect.whenEffect(Random.nextBoolean)
)

console.log(Effect.runSync(randomIntOption))
/*
Example Output:
{ _id: 'Option', _tag: 'Some', value: 8609104974198840 }
*/
```

### unless / unlessEffect

The `Effect.unless` and `Effect.unlessEffect` functions are similar to the `when*` functions, but they are equivalent to the `if (!condition) expression` construct.

## Zipping

### zip

Combines two effects into a single effect, producing a tuple with the results of both effects.

The `Effect.zip` function executes the first effect (left) and then the second effect (right).
Once both effects succeed, their results are combined into a tuple.

**Example** (Combining Two Effects Sequentially)

```ts

const task1 = Effect.succeed(1).pipe(
  Effect.delay("200 millis"),
  Effect.tap(Effect.log("task1 done"))
)

const task2 = Effect.succeed("hello").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Effect.log("task2 done"))
)

// Combine the two effects together
//
//      ┌─── Effect<[number, string], never, never>
//      ▼
const program = Effect.zip(task1, task2)

Effect.runPromise(program).then(console.log)
/*
Output:
timestamp=... level=INFO fiber=#0 message="task1 done"
timestamp=... level=INFO fiber=#0 message="task2 done"
[ 1, 'hello' ]
*/
```

By default, the effects are run sequentially. To run them concurrently, use the `{ concurrent: true }` option.

**Example** (Combining Two Effects Concurrently)

```ts "task2 done"

const task1 = Effect.succeed(1).pipe(
  Effect.delay("200 millis"),
  Effect.tap(Effect.log("task1 done"))
)

const task2 = Effect.succeed("hello").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Effect.log("task2 done"))
)

// Run both effects concurrently using the concurrent option
const program = Effect.zip(task1, task2, { concurrent: true })

Effect.runPromise(program).then(console.log)
/*
Output:
timestamp=... level=INFO fiber=#3 message="task2 done"
timestamp=... level=INFO fiber=#2 message="task1 done"
[ 1, 'hello' ]
*/
```

In this concurrent version, both effects run in parallel. `task2` completes first, but both tasks can be logged and processed as soon as they're done.

### zipWith

Combines two effects sequentially and applies a function to their results to produce a single value.

The `Effect.zipWith` function is similar to [Effect.zip](#zip), but instead of returning a tuple of results,
it applies a provided function to the results of the two effects, combining them into a single value.

By default, the effects are run sequentially. To run them concurrently, use the `{ concurrent: true }` option.

**Example** (Combining Effects with a Custom Function)

```ts

const task1 = Effect.succeed(1).pipe(
  Effect.delay("200 millis"),
  Effect.tap(Effect.log("task1 done"))
)
const task2 = Effect.succeed("hello").pipe(
  Effect.delay("100 millis"),
  Effect.tap(Effect.log("task2 done"))
)

//      ┌─── Effect<number, never, never>
//      ▼
const task3 = Effect.zipWith(
  task1,
  task2,
  // Combines results into a single value
  (number, string) => number + string.length
)

Effect.runPromise(task3).then(console.log)
/*
Output:
timestamp=... level=INFO fiber=#3 message="task1 done"
timestamp=... level=INFO fiber=#2 message="task2 done"
6
*/
```

## Looping

### loop

The `Effect.loop` function allows you to repeatedly update a state using a `step` function until a condition defined by the `while` function becomes `false`. It collects the intermediate states in an array and returns them as the final result.

**Syntax**

```ts
Effect.loop(initial, {
  while: (state) => boolean,
  step: (state) => state,
  body: (state) => Effect
})
```

This function is similar to a `while` loop in JavaScript, with the addition of effectful computations:

```ts
let state = initial
const result = []

while (options.while(state)) {
  result.push(options.body(state)) // Perform the effectful operation
  state = options.step(state) // Update the state
}

return result
```

**Example** (Looping with Collected Results)

```ts

// A loop that runs 5 times, collecting each iteration's result
const result = Effect.loop(
  // Initial state
  1,
  {
    // Condition to continue looping
    while: (state) => state <= 5,
    // State update function
    step: (state) => state + 1,
    // Effect to be performed on each iteration
    body: (state) => Effect.succeed(state)
  }
)

Effect.runPromise(result).then(console.log)
// Output: [1, 2, 3, 4, 5]
```

In this example, the loop starts with the state `1` and continues until the state exceeds `5`. Each state is incremented by `1` and is collected into an array, which becomes the final result.

#### Discarding Intermediate Results

The `discard` option, when set to `true`, will discard the results of each effectful operation, returning `void` instead of an array.

**Example** (Loop with Discarded Results)

```ts

const result = Effect.loop(
  // Initial state
  1,
  {
    // Condition to continue looping
    while: (state) => state <= 5,
    // State update function
    step: (state) => state + 1,
    // Effect to be performed on each iteration
    body: (state) => Console.log(`Currently at state ${state}`),
    // Discard intermediate results
    discard: true
  }
)

Effect.runPromise(result).then(console.log)
/*
Output:
Currently at state 1
Currently at state 2
Currently at state 3
Currently at state 4
Currently at state 5
undefined
*/
```

In this example, the loop performs a side effect of logging the current index on each iteration, but it discards all intermediate results. The final result is `undefined`.

### iterate

The `Effect.iterate` function lets you repeatedly update a state through an effectful operation. It runs the `body` effect to update the state in each iteration and continues as long as the `while` condition evaluates to `true`.

**Syntax**

```ts
Effect.iterate(initial, {
  while: (result) => boolean,
  body: (result) => Effect
})
```

This function is similar to a `while` loop in JavaScript, with the addition of effectful computations:

```ts
let result = initial

while (options.while(result)) {
  result = options.body(result)
}

return result
```

**Example** (Effectful Iteration)

```ts

const result = Effect.iterate(
  // Initial result
  1,
  {
    // Condition to continue iterating
    while: (result) => result <= 5,
    // Operation to change the result
    body: (result) => Effect.succeed(result + 1)
  }
)

Effect.runPromise(result).then(console.log)
// Output: 6
```

### forEach

Executes an effectful operation for each element in an `Iterable`.

The `Effect.forEach` function applies a provided operation to each element in the
iterable, producing a new effect that returns an array of results.
If any effect fails, the iteration stops immediately (short-circuiting), and
the error is propagated.

The `concurrency` option controls how many operations are performed
concurrently. By default, the operations are performed sequentially.

**Example** (Applying Effects to Iterable Elements)

```ts

const result = Effect.forEach([1, 2, 3, 4, 5], (n, index) =>
  Console.log(`Currently at index ${index}`).pipe(Effect.as(n * 2))
)

Effect.runPromise(result).then(console.log)
/*
Output:
Currently at index 0
Currently at index 1
Currently at index 2
Currently at index 3
Currently at index 4
[ 2, 4, 6, 8, 10 ]
*/
```

In this example, we iterate over the array `[1, 2, 3, 4, 5]`, applying an effect that logs the current index. The `Effect.as(n * 2)` operation transforms each value, resulting in an array `[2, 4, 6, 8, 10]`. The final output is the result of collecting all the transformed values.

#### Discarding Results

The `discard` option, when set to `true`, will discard the results of each effectful operation, returning `void` instead of an array.

**Example** (Using `discard` to Ignore Results)

```ts

// Apply effects but discard the results
const result = Effect.forEach(
  [1, 2, 3, 4, 5],
  (n, index) =>
    Console.log(`Currently at index ${index}`).pipe(Effect.as(n * 2)),
  { discard: true }
)

Effect.runPromise(result).then(console.log)
/*
Output:
Currently at index 0
Currently at index 1
Currently at index 2
Currently at index 3
Currently at index 4
undefined
*/
```

In this case, the effects still run for each element, but the results are discarded, so the final output is `undefined`.

## Collecting

### all

Combines multiple effects into one, returning results based on the input structure.

Use `Effect.all` when you need to run multiple effects and combine their results into a single output. It supports tuples, iterables, structs, and records, making it flexible for different input types.

If any effect fails, it stops execution (short-circuiting) and propagates the error. To change this behavior, you can use the [`mode`](#the-mode-option) option, which allows all effects to run and collect results as [Either](/docs/data-types/either/) or [Option](/docs/data-types/option/).

You can control the execution order (e.g., sequential vs. concurrent) using the [Concurrency Options](/docs/concurrency/basic-concurrency/#concurrency-options).

For instance, if the input is a tuple:

```ts
//         ┌─── a tuple of effects
//         ▼
Effect.all([effect1, effect2, ...])
```

the effects are executed sequentially, and the result is a new effect containing the results as a tuple. The results in the tuple match the order of the effects passed to `Effect.all`.

Let's explore examples for different types of structures: tuples, iterables, objects, and records.

**Example** (Combining Effects in Tuples)

```ts

const tupleOfEffects = [
  Effect.succeed(42).pipe(Effect.tap(Console.log)),
  Effect.succeed("Hello").pipe(Effect.tap(Console.log))
] as const

//      ┌─── Effect<[number, string], never, never>
//      ▼
const resultsAsTuple = Effect.all(tupleOfEffects)

Effect.runPromise(resultsAsTuple).then(console.log)
/*
Output:
42
Hello
[ 42, 'Hello' ]
*/
```

**Example** (Combining Effects in Iterables)

```ts

const iterableOfEffects: Iterable<Effect.Effect<number>> = [1, 2, 3].map(
  (n) => Effect.succeed(n).pipe(Effect.tap(Console.log))
)

//      ┌─── Effect<number[], never, never>
//      ▼
const resultsAsArray = Effect.all(iterableOfEffects)

Effect.runPromise(resultsAsArray).then(console.log)
/*
Output:
1
2
3
[ 1, 2, 3 ]
*/
```

**Example** (Combining Effects in Structs)

```ts

const structOfEffects = {
  a: Effect.succeed(42).pipe(Effect.tap(Console.log)),
  b: Effect.succeed("Hello").pipe(Effect.tap(Console.log))
}

//      ┌─── Effect<{ a: number; b: string; }, never, never>
//      ▼
const resultsAsStruct = Effect.all(structOfEffects)

Effect.runPromise(resultsAsStruct).then(console.log)
/*
Output:
42
Hello
{ a: 42, b: 'Hello' }
*/
```

**Example** (Combining Effects in Records)

```ts

const recordOfEffects: Record<string, Effect.Effect<number>> = {
  key1: Effect.succeed(1).pipe(Effect.tap(Console.log)),
  key2: Effect.succeed(2).pipe(Effect.tap(Console.log))
}

//      ┌─── Effect<{ [x: string]: number; }, never, never>
//      ▼
const resultsAsRecord = Effect.all(recordOfEffects)

Effect.runPromise(resultsAsRecord).then(console.log)
/*
Output:
1
2
{ key1: 1, key2: 2 }
*/
```

#### Short-Circuiting Behavior

The `Effect.all` function stops execution on the first error it encounters, this is called "short-circuiting".
If any effect in the collection fails, the remaining effects will not run, and the error will be propagated.

**Example** (Bail Out on First Failure)

```ts

const program = Effect.all([
  Effect.succeed("Task1").pipe(Effect.tap(Console.log)),
  Effect.fail("Task2: Oh no!").pipe(Effect.tap(Console.log)),
  // Won't execute due to earlier failure
  Effect.succeed("Task3").pipe(Effect.tap(Console.log))
])

Effect.runPromiseExit(program).then(console.log)
/*
Output:
Task1
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Task2: Oh no!' }
}
*/
```

You can override this behavior by using the `mode` option.

#### The `mode` option

The `{ mode: "either" }` option changes the behavior of `Effect.all` to ensure all effects run, even if some fail. Instead of stopping on the first failure, this mode collects both successes and failures, returning an array of `Either` instances where each result is either a `Right` (success) or a `Left` (failure).

**Example** (Collecting Results with `mode: "either"`)

```ts

const effects = [
  Effect.succeed("Task1").pipe(Effect.tap(Console.log)),
  Effect.fail("Task2: Oh no!").pipe(Effect.tap(Console.log)),
  Effect.succeed("Task3").pipe(Effect.tap(Console.log))
]

const program = Effect.all(effects, { mode: "either" })

Effect.runPromiseExit(program).then(console.log)
/*
Output:
Task1
Task3
{
  _id: 'Exit',
  _tag: 'Success',
  value: [
    { _id: 'Either', _tag: 'Right', right: 'Task1' },
    { _id: 'Either', _tag: 'Left', left: 'Task2: Oh no!' },
    { _id: 'Either', _tag: 'Right', right: 'Task3' }
  ]
}
*/
```

Similarly, the `{ mode: "validate" }` option uses `Option` to indicate success or failure. Each effect returns `None` for success and `Some` with the error for failure.

**Example** (Collecting Results with `mode: "validate"`)

```ts

const effects = [
  Effect.succeed("Task1").pipe(Effect.tap(Console.log)),
  Effect.fail("Task2: Oh no!").pipe(Effect.tap(Console.log)),
  Effect.succeed("Task3").pipe(Effect.tap(Console.log))
]

const program = Effect.all(effects, { mode: "validate" })

Effect.runPromiseExit(program).then((result) => console.log("%o", result))
/*
Output:
Task1
Task3
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: [
      { _id: 'Option', _tag: 'None' },
      { _id: 'Option', _tag: 'Some', value: 'Task2: Oh no!' },
      { _id: 'Option', _tag: 'None' }
    ]
  }
}
*/
```


---

# [Running Effects](https://effect.website/docs/getting-started/running-effects/)

## Overview


To execute an effect, you can use one of the many `run` functions provided by the `Effect` module.

> **Tip: Running Effects at the Program's Edge**
  The recommended approach is to design your program with the majority of
  its logic as Effects. It's advisable to use the `run*` functions closer
  to the "edge" of your program. This approach allows for greater
  flexibility in executing your program and building sophisticated
  effects.


## runSync

Executes an effect synchronously, running it immediately and returning the result.

**Example** (Synchronous Logging)

```ts

const program = Effect.sync(() => {
  console.log("Hello, World!")
  return 1
})

const result = Effect.runSync(program)
// Output: Hello, World!

console.log(result)
// Output: 1
```

Use `Effect.runSync` to run an effect that does not fail and does not include any asynchronous operations. If the effect fails or involves asynchronous work, it will throw an error, and execution will stop where the failure or async operation occurs.

**Example** (Incorrect Usage with Failing or Async Effects)

```ts

try {
  // Attempt to run an effect that fails
  Effect.runSync(Effect.fail("my error"))
} catch (e) {
  console.error(e)
}
/*
Output:
(FiberFailure) Error: my error
*/

try {
  // Attempt to run an effect that involves async work
  Effect.runSync(Effect.promise(() => Promise.resolve(1)))
} catch (e) {
  console.error(e)
}
/*
Output:
(FiberFailure) AsyncFiberException: Fiber #0 cannot be resolved synchronously. This is caused by using runSync on an effect that performs async work
*/
```

## runSyncExit

Runs an effect synchronously and returns the result as an [Exit](/docs/data-types/exit/) type, which represents the outcome (success or failure) of the effect.

Use `Effect.runSyncExit` to find out whether an effect succeeded or failed,
including any defects, without dealing with asynchronous operations.

The `Exit` type represents the result of the effect:

- If the effect succeeds, the result is wrapped in a `Success`.
- If it fails, the failure information is provided as a `Failure` containing
  a [Cause](/docs/data-types/cause/) type.

**Example** (Handling Results as Exit)

```ts

console.log(Effect.runSyncExit(Effect.succeed(1)))
/*
Output:
{
  _id: "Exit",
  _tag: "Success",
  value: 1
}
*/

console.log(Effect.runSyncExit(Effect.fail("my error")))
/*
Output:
{
  _id: "Exit",
  _tag: "Failure",
  cause: {
    _id: "Cause",
    _tag: "Fail",
    failure: "my error"
  }
}
*/
```

If the effect contains asynchronous operations, `Effect.runSyncExit` will
return an `Failure` with a `Die` cause, indicating that the effect cannot be
resolved synchronously.

**Example** (Asynchronous Operation Resulting in Die)

```ts

console.log(Effect.runSyncExit(Effect.promise(() => Promise.resolve(1))))
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Die',
    defect: [Fiber #0 cannot be resolved synchronously. This is caused by using runSync on an effect that performs async work] {
      fiber: [FiberRuntime],
      _tag: 'AsyncFiberException',
      name: 'AsyncFiberException'
    }
  }
}
*/
```

## runPromise

Executes an effect and returns the result as a `Promise`.

Use `Effect.runPromise` when you need to execute an effect and work with the
result using `Promise` syntax, typically for compatibility with other
promise-based code.

**Example** (Running a Successful Effect as a Promise)

```ts

Effect.runPromise(Effect.succeed(1)).then(console.log)
// Output: 1
```

If the effect succeeds, the promise will resolve with the result. If the
effect fails, the promise will reject with an error.

**Example** (Handling a Failing Effect as a Rejected Promise)

```ts

Effect.runPromise(Effect.fail("my error")).catch(console.error)
/*
Output:
(FiberFailure) Error: my error
*/
```

## runPromiseExit

Runs an effect and returns a `Promise` that resolves to an [Exit](/docs/data-types/exit/), which
represents the outcome (success or failure) of the effect.

Use `Effect.runPromiseExit` when you need to determine if an effect succeeded
or failed, including any defects, and you want to work with a `Promise`.

The `Exit` type represents the result of the effect:

- If the effect succeeds, the result is wrapped in a `Success`.
- If it fails, the failure information is provided as a `Failure` containing
  a [Cause](/docs/data-types/cause/) type.

**Example** (Handling Results as Exit)

```ts

Effect.runPromiseExit(Effect.succeed(1)).then(console.log)
/*
Output:
{
  _id: "Exit",
  _tag: "Success",
  value: 1
}
*/

Effect.runPromiseExit(Effect.fail("my error")).then(console.log)
/*
Output:
{
  _id: "Exit",
  _tag: "Failure",
  cause: {
    _id: "Cause",
    _tag: "Fail",
    failure: "my error"
  }
}
*/
```

## runFork

The foundational function for running effects, returning a "fiber" that can be observed or interrupted.

`Effect.runFork` is used to run an effect in the background by creating a fiber. It is the base function
for all other run functions. It starts a fiber that can be observed or interrupted.

> **Tip: The Default for Effect Execution**
  Unless you specifically need a `Promise` or synchronous operation,
  `Effect.runFork` is a good default choice.


**Example** (Running an Effect in the Background)

```ts

//      ┌─── Effect<number, never, never>
//      ▼
const program = Effect.repeat(
  Console.log("running..."),
  Schedule.spaced("200 millis")
)

//      ┌─── RuntimeFiber<number, never>
//      ▼
const fiber = Effect.runFork(program)

setTimeout(() => {
  Effect.runFork(Fiber.interrupt(fiber))
}, 500)
```

In this example, the `program` continuously logs "running..." with each repetition spaced 200 milliseconds apart. You can learn more about repetitions and scheduling in our [Introduction to Scheduling](/docs/scheduling/introduction/) guide.

To stop the execution of the program, we use `Fiber.interrupt` on the fiber returned by `Effect.runFork`. This allows you to control the execution flow and terminate it when necessary.

For a deeper understanding of how fibers work and how to handle interruptions, check out our guides on [Fibers](/docs/concurrency/fibers/) and [Interruptions](/docs/concurrency/basic-concurrency/#interruptions).

## Synchronous vs. Asynchronous Effects

In the Effect library, there is no built-in way to determine in advance whether an effect will execute synchronously or asynchronously. While this idea was considered in earlier versions of Effect, it was ultimately not implemented for a few important reasons:

1. **Complexity:** Introducing this feature to track sync/async behavior in the type system would make Effect more complex to use and limit its composability.

2. **Safety Concerns:** We experimented with different approaches to track asynchronous Effects, but they all resulted in a worse developer experience without significantly improving safety. Even with fully synchronous types, we needed to support a `fromCallback` combinator to work with APIs using Continuation-Passing Style (CPS). However, at the type level, it's impossible to guarantee that such a function is always called immediately and not deferred.

### Best Practices for Running Effects

In most cases, effects are run at the outermost parts of your application. Typically, an application built around Effect will involve a single call to the main effect. Here’s how you should approach effect execution:

- Use `runPromise` or `runFork`: For most cases, asynchronous execution should be the default. These methods provide the best way to handle Effect-based workflows.

- Use `runSync` only when necessary: Synchronous execution should be considered an edge case, used only in scenarios where asynchronous execution is not feasible. For example, when you are sure the effect is purely synchronous and need immediate results.

## Cheatsheet

The table provides a summary of the available `run*` functions, along with their input and output types, allowing you to choose the appropriate function based on your needs.

| API              | Given          | Result                |
| ---------------- | -------------- | --------------------- |
| `runSync`        | `Effect<A, E>` | `A`                   |
| `runSyncExit`    | `Effect<A, E>` | `Exit<A, E>`          |
| `runPromise`     | `Effect<A, E>` | `Promise<A>`          |
| `runPromiseExit` | `Effect<A, E>` | `Promise<Exit<A, E>>` |
| `runFork`        | `Effect<A, E>` | `RuntimeFiber<A, E>`  |

You can find the complete list of `run*` functions [here](https://effect-ts.github.io/effect/effect/Effect.ts.html#running-effects).


---

# [Using Generators](https://effect.website/docs/getting-started/using-generators/)

## Overview

import {
  Aside,
  Tabs,
  TabItem,
  Badge
} from "@astrojs/starlight/components"

Effect offers a convenient syntax, similar to `async`/`await`, to write effectful code using [generators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Generator).

> **Note: Optional Feature**
  The use of generators is an optional feature in Effect. If you find
  generators unfamiliar or prefer a different coding style, you can
  explore the documentation about [Building
  Pipelines](/docs/getting-started/building-pipelines/) in Effect.


## Understanding Effect.gen

The `Effect.gen` utility simplifies the task of writing effectful code by utilizing JavaScript's generator functions. This method helps your code appear and behave more like traditional synchronous code, which enhances both readability and error management.

**Example** (Performing Transactions with Discounts)

Let's explore a practical program that performs a series of data transformations commonly found in application logic:

```ts

// Function to add a small service charge to a transaction amount
const addServiceCharge = (amount: number) => amount + 1

// Function to apply a discount safely to a transaction amount
const applyDiscount = (
  total: number,
  discountRate: number
): Effect.Effect<number, Error> =>
  discountRate === 0
    ? Effect.fail(new Error("Discount rate cannot be zero"))
    : Effect.succeed(total - (total * discountRate) / 100)

// Simulated asynchronous task to fetch a transaction amount from a
// database
const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

// Simulated asynchronous task to fetch a discount rate from a
// configuration file
const fetchDiscountRate = Effect.promise(() => Promise.resolve(5))

// Assembling the program using a generator function
const program = Effect.gen(function* () {
  // Retrieve the transaction amount
  const transactionAmount = yield* fetchTransactionAmount

  // Retrieve the discount rate
  const discountRate = yield* fetchDiscountRate

  // Calculate discounted amount
  const discountedAmount = yield* applyDiscount(
    transactionAmount,
    discountRate
  )

  // Apply service charge
  const finalAmount = addServiceCharge(discountedAmount)

  // Return the total amount after applying the charge
  return `Final amount to charge: ${finalAmount}`
})

// Execute the program and log the result
Effect.runPromise(program).then(console.log)
// Output: Final amount to charge: 96
```

Key steps to follow when using `Effect.gen`:

- Wrap your logic in `Effect.gen`
- Use `yield*` to handle effects
- Return the final result

If any of the effects that you handle inside of the generator with `yield*`
fail, then the generator will stop and exit with that failure.

> **Caution: Required TypeScript Configuration**
  The generator API is only available when using the `downlevelIteration`
  flag or with a `target` of `"es2015"` or higher in your `tsconfig.json`
  file.


## Comparing Effect.gen with async/await

If you are familiar with `async`/`await`, you may notice that the flow of writing code is similar.

Let's compare the two approaches:



```ts

const addServiceCharge = (amount: number) => amount + 1

const applyDiscount = (
  total: number,
  discountRate: number
): Effect.Effect<number, Error> =>
  discountRate === 0
    ? Effect.fail(new Error("Discount rate cannot be zero"))
    : Effect.succeed(total - (total * discountRate) / 100)

const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

const fetchDiscountRate = Effect.promise(() => Promise.resolve(5))

export const program = Effect.gen(function* () {
  const transactionAmount = yield* fetchTransactionAmount
  const discountRate = yield* fetchDiscountRate
  const discountedAmount = yield* applyDiscount(
    transactionAmount,
    discountRate
  )
  const finalAmount = addServiceCharge(discountedAmount)
  return `Final amount to charge: ${finalAmount}`
})
```



```ts
const addServiceCharge = (amount: number) => amount + 1

const applyDiscount = (
  total: number,
  discountRate: number
): Promise<number> =>
  discountRate === 0
    ? Promise.reject(new Error("Discount rate cannot be zero"))
    : Promise.resolve(total - (total * discountRate) / 100)

const fetchTransactionAmount = Promise.resolve(100)

const fetchDiscountRate = Promise.resolve(5)

export const program = async function () {
  const transactionAmount = await fetchTransactionAmount
  const discountRate = await fetchDiscountRate
  const discountedAmount = await applyDiscount(
    transactionAmount,
    discountRate
  )
  const finalAmount = addServiceCharge(discountedAmount)
  return `Final amount to charge: ${finalAmount}`
}
```



It's important to note that although the code appears similar, the two programs are not identical. The purpose of comparing them side by side is just to highlight the resemblance in how they are written.

## Embracing Control Flow

One significant advantage of using `Effect.gen` in conjunction with generators is its capability to employ standard control flow constructs within the generator function. These constructs include `if`/`else`, `for`, `while`, and other branching and looping mechanisms, enhancing your ability to express complex control flow logic in your code.

**Example** (Using Control Flow)

```ts

const calculateTax = (
  amount: number,
  taxRate: number
): Effect.Effect<number, Error> =>
  taxRate > 0
    ? Effect.succeed((amount * taxRate) / 100)
    : Effect.fail(new Error("Invalid tax rate"))

const program = Effect.gen(function* () {
  let i = 1

  while (true) {
    if (i === 10) {
      break // Break the loop when counter reaches 10
    } else {
      if (i % 2 === 0) {
        // Calculate tax for even numbers
        console.log(yield* calculateTax(100, i))
      }
      i++
      continue
    }
  }
})

Effect.runPromise(program)
/*
Output:
2
4
6
8
*/
```

## How to Raise Errors

The `Effect.gen` API lets you integrate error handling directly into your workflow by yielding failed effects.
You can introduce errors with `Effect.fail`, as shown in the example below.

**Example** (Introducing an Error into the Flow)

```ts

const task1 = Console.log("task1...")
const task2 = Console.log("task2...")

const program = Effect.gen(function* () {
  // Perform some tasks
  yield* task1
  yield* task2
  // Introduce an error
  yield* Effect.fail("Something went wrong!")
})

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
task1...
task2...
(FiberFailure) Error: Something went wrong!
*/
```

## The Role of Short-Circuiting

When working with `Effect.gen`, it is important to understand how it handles errors.
This API will stop execution at the **first error** it encounters and return that error.

How does this affect your code? If you have several operations in sequence, once any one of them fails, the remaining operations will not run, and the error will be returned.

In simpler terms, if something fails at any point, the program will stop right there and deliver the error to you.

If you don't want to stop on an error, you can use the `Effect.either` method to encapsulate the error in the [Either](/docs/data-types/either/) data type: see the [examples of managing expected errors](/docs/error-management/expected-errors/#either).

**Example** (Halting Execution at the First Error)

```ts

const task1 = Console.log("task1...")
const task2 = Console.log("task2...")
const failure = Effect.fail("Something went wrong!")
const task4 = Console.log("task4...")

const program = Effect.gen(function* () {
  yield* task1
  yield* task2
  // The program stops here due to the error
  yield* failure
  // The following lines never run
  yield* task4
  return "some result"
})

Effect.runPromise(program).then(console.log, console.error)
/*
Output:
task1...
task2...
(FiberFailure) Error: Something went wrong!
*/
```

Even though execution never reaches code after a failure, TypeScript may still assume that the code below the error is reachable unless you explicitly return after the failure.

For example, consider the following scenario where you want to narrow the type of a variable:

**Example** (Type Narrowing without Explicit Return)

```ts

type User = {
  readonly name: string
}

// Imagine this function checks a database or an external service
declare function getUserById(id: string): Effect.Effect<User | undefined>

function greetUser(id: string) {
  return Effect.gen(function* () {
    const user = yield* getUserById(id)

    if (user === undefined) {
      // Even though we fail here, TypeScript still thinks
      // 'user' might be undefined later
      yield* Effect.fail(`User with id ${id} not found`)
    }

// @errors: 18048
    return `Hello, ${user.name}!`
  })
}
```

In this example, TypeScript still considers `user` possibly `undefined` because there is no explicit return after the failure.

To fix this, explicitly return right after calling `Effect.fail`:

**Example** (Type Narrowing with Explicit Return)

```ts

type User = {
  readonly name: string
}

declare function getUserById(id: string): Effect.Effect<User | undefined>

function greetUser(id: string) {
  return Effect.gen(function* () {
    const user = yield* getUserById(id)

    if (user === undefined) {
      // Explicitly return after failing
      return yield* Effect.fail(`User with id ${id} not found`)
    }

    // Now TypeScript knows that 'user' is not undefined
    return `Hello, ${user.name}!`
  })
}
```

> **Note: Further Learning**
  To learn more about error handling in Effect, refer to the [Error
  Management](/docs/error-management/two-error-types/) section.


## Passing `this`

In some cases, you might need to pass a reference to the current object (`this`) into the body of your generator function.
You can achieve this by utilizing an overload that accepts the reference as the first argument:

**Example** (Passing `this` to Generator)

```ts

class MyClass {
  readonly local = 1
  compute = Effect.gen(this, function* () {
    const n = this.local + 1

    yield* Effect.log(`Computed value: ${n}`)

    return n
  })
}

Effect.runPromise(new MyClass().compute).then(console.log)
/*
Output:
timestamp=... level=INFO fiber=#0 message="Computed value: 2"
2
*/
```

## Adapter <Badge text="Deprecated" variant="caution" />

You may still come across some code snippets that use an adapter, typically indicated by `_` or `$` symbols.

In earlier versions of TypeScript, the generator "adapter" function was necessary to ensure correct type inference within generators. This adapter was used to facilitate the interaction between TypeScript's type system and generator functions.

**Example** (Adapter in Older Code)

```ts

const fetchTransactionAmount = Effect.promise(() => Promise.resolve(100))

// Older usage with an adapter for proper type inference
const programWithAdapter = Effect.gen(function* ($) {
  const transactionAmount = yield* $(fetchTransactionAmount)
})

// Current usage without an adapter
const program = Effect.gen(function* () {
  const transactionAmount = yield* fetchTransactionAmount
})
```

With advances in TypeScript (v5.5+), the adapter is no longer necessary for type inference. While it remains in the codebase for backward compatibility, it is anticipated to be removed in the upcoming major release of Effect.


---

# [Why Effect?](https://effect.website/docs/getting-started/why-effect/)

## Overview

Programming is challenging. When we build libraries and apps, we look to many tools to handle the complexity and make our day-to-day more manageable. Effect presents a new way of thinking about programming in TypeScript.

Effect is an ecosystem of tools that help you build better applications and libraries. As a result, you will also learn more about the TypeScript language and how to use the type system to make your programs more reliable and easier to maintain.

In "typical" TypeScript, without Effect, we write code that assumes that a function is either successful or throws an exception. For example:

```ts
const divide = (a: number, b: number): number => {
  if (b === 0) {
    throw new Error("Cannot divide by zero")
  }
  return a / b
}
```

Based on the types, we have no idea that this function can throw an exception. We can only find out by reading the code. This may not seem like much of a problem when you only have one function in your codebase, but when you have hundreds or thousands, it really starts to add up. It's easy to forget that a function can throw an exception, and it's easy to forget to handle that exception.

Often, we will do the "easiest" thing and just wrap the function in a `try/catch` block. This is a good first step to prevent your program from crashing, but it doesn't make it any easier to manage or understand our complex application/library. We can do better.

One of the most important tools we have in TypeScript is the compiler. It is the first line of defense against bugs, domain errors, and general complexity.

## The Effect Pattern

While Effect is a vast ecosystem of many different tools, if it had to be reduced down to just one idea, it would be the following:

Effect's major unique insight is that we can use the type system to track **errors** and **context**, not only **success** values as shown in the divide example above.

Here's the same divide function from above, but with the Effect pattern:

```ts

const divide = (
  a: number,
  b: number
): Effect.Effect<number, Error, never> =>
  b === 0
    ? Effect.fail(new Error("Cannot divide by zero"))
    : Effect.succeed(a / b)
```

With this approach, the function no longer throws exceptions. Instead, errors are handled as values, which can be passed along like success values. The type signature also makes it clear:

- What success value the function returns (`number`).
- What error can occur (`Error`).
- What additional context or dependencies are required (`never` indicates none).

```text
         ┌─── Produces a value of type number
         │       ┌─── Fails with an Error
         │       │      ┌─── Requires no dependencies
         ▼       ▼      ▼
Effect<number, Error, never>
```

Additionally, tracking context allows you to provide additional information to your functions without having to pass in everything as an argument. For example, you can swap out implementations of live external services with mocks during your tests without changing any core business logic.

## Don't Re-Invent the Wheel

Application code in TypeScript often solves the same problems over and over again. Interacting with external services, filesystems, databases, etc. are common problems for all application developers. Effect provides a rich ecosystem of libraries that provide standardized solutions to many of these problems. You can use these libraries to build your application, or you can use them to build your own libraries.

Managing challenges like error handling, debugging, tracing, async/promises, retries, streaming, concurrency, caching, resource management, and a lot more are made manageable with Effect. You don't have to re-invent the solutions to these problems, or install tons of dependencies. Effect, under one umbrella, solves many of the problems that you would usually install many different dependencies with different APIs to solve.

## Solving Practical Problems

Effect is heavily inspired by great work done in other languages, like Scala and Haskell. However, it's important to understand that Effect's goal is to be a practical toolkit, and it goes to great lengths to solve real, everyday problems that developers face when building applications and libraries in TypeScript.

## Enjoy Building and Learning

Learning Effect is a lot of fun. Many developers in the Effect ecosystem are using Effect to solve real problems in their day-to-day work, and also experiment with cutting edge ideas for pushing TypeScript to be the most useful language it can be.

You don't have to use all aspects of Effect at once, and can start with the pieces of the ecosystem that make the most sense for the problems you are solving. Effect is a toolkit, and you can pick and choose the pieces that make the most sense for your use case. However, as more and more of your codebase is using Effect, you will probably find yourself wanting to utilize more of the ecosystem!

Effect's concepts may be new to you, and might not completely make sense at first. This is totally normal. Take your time with reading the docs and try to understand the core concepts - this will really pay off later on as you get into the more advanced tooling in the Effect ecosystem. The Effect community is always happy to help you learn and grow. Feel free to hop into our [Discord](https://discord.gg/effect-ts) or discuss on [GitHub](https://github.com/Effect-TS)! We are open to feedback and contributions, and are always looking for ways to improve Effect.


---

# [Devtools](https://effect.website/docs/getting-started/devtools/)

## Overview


Effect provides powerful development tools to enhance your coding experience and help you write safer, more maintainable code. These tools integrate directly into your editor, providing real-time feedback, intelligent refactors, and helpful diagnostics.

## Effect LSP

The Effect LSP extends your editor with Effect-specific features. It analyzes your Effect code and provides intelligent assistance through diagnostics, quick info, completions, and automated refactors.

It works in editors that supports the standard TypeScript LSP, such as Code, Cursor, Zed, NVim, etc.

### Installation

To install the Effect Language Service in your project:


1. Install the package as a development dependency:

   For monorepos, we suggest to install the language service at the root level. For single-package projects, install it in the package directory.

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

   ```sh
   npm install @effect/language-service --save-dev
   ```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

   ```sh
   pnpm add -D @effect/language-service
   ```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

   ```sh
   yarn add --dev @effect/language-service
   ```

   </TabItem>

   <TabItem label="Bun" icon="bun">

   ```sh
   bun add --dev @effect/language-service
   ```

   </TabItem>

   </Tabs>

2. Add the plugin to your `tsconfig.json`:

   ```json title="tsconfig.json"
   {
     "compilerOptions": {
       "plugins": [
         {
           "name": "@effect/language-service"
         }
       ]
     }
   }
   ```

3. Ensure your editor uses the workspace TypeScript version:

   This step is critical for the language service to function properly. The plugin must run on the TypeScript version installed in your project, not the one bundled with your editor.

   > **Tip**
   In VS Code or Cursor, you can select the workspace TypeScript version by opening a TypeScript file, clicking on the TypeScript version number in the status bar, and selecting "Use Workspace Version".
   

4. You're ready to play!

   Writing the following code in a file.ts inside your project, should result in an error diagnostic appearing, saying that Effect's must be yielded or assigned to a variable:

   ```ts
   import { Effect } from "effect"

   Effect.log("Hello world!")
   // ^- should be run or assigned to a variable!
   ```



### Features

The Effect Language Service provides a comprehensive set of features to enhance your development workflow:

#### Intelligent Quick Info

Hover over Effect values to see extended type information and detailed insights:

- **Effect Types**: See comprehensive type information for Effect values
- **Generator Parameters**: When hovering over `yield*` in `Effect.gen`, view detailed information about the yielded value
- **Layer Composition**: Visualize layer dependencies with interactive graphs showing how layers compose together
- **Service Dependencies**: Understand service requirements and their relationships at a glance

#### Real-time Diagnostics

Catch common mistakes and potential issues as you write code:

- **Floating Effects**: Detect Effect values that aren't assigned or yielded, preventing silent bugs
- **Layer Issues**: Catch layer requirement leaks and scope violations before runtime
- **Unnecessary Code**: Identify redundant `Effect.gen` or `pipe()` calls
- **Error Handling**: Detect misuse of catch functions on Effects that cannot fail
- **Version Conflicts**: Detect when multiple Effect versions are present in your project

#### Smart Completions

Speed up your coding with context-aware suggestions:

- **Generator Boilerplate**: Quickly scaffold `Effect.gen` functions
- **Scaffolds**: For `Effect.Service`, `Data.TaggedError` and friends.
- **Self Parameters**: Auto-complete for `Self` parameters in service declarations

#### Powerful Refactors

Transform your code with intelligent automated refactors:

- **Async to Effect**: Convert async functions to Effect using `gen` or `fn` syntax
- **Error Generation**: Generate tagged errors from promise-based code
- **Service Accessors**: Automatically implement service accessor functions
- **Pipe Conversion**: Transform function calls to pipe syntax
- **Pipe Styles**: Toggle between different pipe style formats
- **Layer Magic**: Automatically compose layers with correct dependencies

### Configuration

The Effect LSP provides also lots of configuration options such as changing severity or disabling diagnostic messages.

To see the full list of options and features, please visit the [README from the LSP repository](https://github.com/Effect-TS/language-service).

### Build-Time Diagnostics

While LSPs only activate during editing sessions, you may want to catch diagnostics during your build process.

Usually that's done through linting rules, but since almost all of the Effect diagnostics relies on types, that would mean enabling type-aware linting, which means performing type checking again on the project files.

To solve this, the Effect Language Service allows you to patch your local TypeScript installation, so diagnostics are emitted while performing type checking.

To enable it run the following command to modify your local TypeScript installation:

```sh
effect-language-service patch
```

To make this automatic for all developers, add it to your `package.json`:

```json title="package.json"
{
  "scripts": {
    "prepare": "effect-language-service patch"
  }
}
```

This ensures the language service runs during compilation with the standard `tsc` command.


## VS Code / Cursor Extension

> **Caution**
The editor extension does not include the Effect LSP! Installation of that should be performed per-project, this allows fine grained control on when to load it, for which projects and with a version pinned with your repository lockfile.


The editor extension provides utilities in helping you debug your Effect applications.

At the moment only Code and Code forks like Cursor are supported.

### Installation

The extension can be installed by searching directly in your editor extension page or from the [Code Marketplace](https://marketplace.visualstudio.com/items?itemName=effectful-tech.effect-vscode) or the [Open VSX Marketplace](https://open-vsx.org/extension/effectful-tech/effect-vscode).

### Debugger Features

With the Effect Extension, you'll find couple of new sections inside the Debug section of your editor that, once you pause execution, will .

- **Context**: Allows you to inspect the context of the currently paused Effect Fiber.
- **Span Stack**: Shows you the stack of telemetry spans that lead you into the execution of the currently paused Effect.
- **Fibers**: List all the Effect Fibers running in your application, allows you to inspect informations such as interrupt-ability and allows to request interruption of them.
- **Breakpoints**: Allows to enable "pause on defect"; letting your debugger pause when a Effect Fiber fails with a defect.

### Built-in Tracer and Metrics

The built-in tracer and metrics view allows to quickly see Effect Spans and Metrics of your app without spinning up an entire telemetry service.

To enable it, you need to install the following dependency in your project:



```sh
npm install @effect/experimental
```



```sh
pnpm install @effect/experimental
```



```sh
yarn add @effect/experimental
```



```sh
bun add @effect/experimental
```



You can then import and use the DevTools module in your Effect app:

```ts

const program = Effect.log("Hello!").pipe(
  Effect.delay(2000),
  Effect.withSpan("Hi", { attributes: { foo: "bar" } }),
  Effect.forever,
)
const DevToolsLive = DevTools.layer()

program.pipe(Effect.provide(DevToolsLive), NodeRuntime.runMain)
```

If you are using `@effect/opentelemetry` in your project, then it is important that you provide the DevTools layer before your tracing layers, so the tracer is patched correctly.

Now start both your editor and your app. Inside the Effect panel, in the clients section you'll see a newly connected client.

In the bottom of your editor, near your terminal, a new tab "Effect Tracer" will appear as well, showing visually your spans as they happen in real time.


---


## Common Mistakes

**Incorrect (using yield instead of yield*):**

```ts
const program = Effect.gen(function* () {
  const user = yield getUser(id) // Wrong: plain yield
})
```

**Correct (using yield* to unwrap effects):**

```ts
const program = Effect.gen(function* () {
  const user = yield* getUser(id) // Correct: delegating yield
})
```
