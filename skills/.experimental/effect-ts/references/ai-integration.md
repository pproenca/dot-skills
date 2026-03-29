---
title: "AI Integration"
impact: LOW
impactDescription: "Enables LLM tool use with Effect — covers Effect AI packages, execution planning, tool definitions"
tags: ai, llm, tool-use, planning
---
# [Introduction to Effect AI](https://effect.website/docs/ai/introduction/)

## Overview


> **Caution: Experimental Module**
  The Effect AI integration packages are currently in the experimental / alpha stage. We encourage your feedback to further improve their features.


Welcome to the documentation for Effect's AI integration packages — a set of libraries designed to make working with large language models (LLMs) seamless, flexible, and provider-agnostic.

These packages enable you to write programs that describe *what* you want to do with an LLM — generating completions, handling chat interactions, running function calls — without having to commit to *how* or *where* those operations are executed. 

The core package, [`@effect/ai`](https://www.npmjs.com/package/@effect/ai), provides a high-level, unified interface for modeling LLM interactions, independent of any specific provider. Once you're ready to run your program, you can plug in the services your program requires from our LLM provider integration packages. 

This separation of concerns allows you to:
- Write clean, declarative business logic without worrying about provider-specific quirks
- Easily swap between or combine providers at runtime or during testing
- Take advantage of Effect’s features when building AI-driven workflows

Whether you're building an intelligent agent, an interactive chat app, or a system that leverages LLMs for background tasks, Effect's AI packages offer the flexibility and control you need!

Let’s dive in!

## Why Effect for AI?

Integrating LLMs isn’t just about sending API requests — it’s handling streaming output, retries, rate limits, timeouts, and user-driven side effects, all while keeping your system stable and responsive. Effect provides simple, composable building blocks to model these workflows in a **safe**, **declarative**, and **composable** manner.

By using Effect for your LLM interactions you'll benefit from:

- 🧩 **Provider-Agnostic Architecture**  
  Write your business logic once, and defer choosing the underlying provider (OpenAI, Anthropic, local models, mocks, etc.) until runtime

- 🧪 **Fully Testable**  
  Because LLM interactions are modeled via Effect services, you can mock, simulate, or snapshot responses just by providing an alternative implementation

- 🧵 **Structured Concurrency**  
  Run concurrent LLM calls, cancel stale requests, stream partial results, or race multiple providers — all safely managed by Effect’s structured concurrency model

- 🔍 **Observability**  
  Leverage Effect's built-in tracing, logging, and metrics to instrument your LLM interactions to gain deep insight into  performance bottlenecks or failures in production

...and much more!

## Core Concepts

Effect’s AI integrations are built around the idea of **provider-agnostic programming**. Instead of hardcoding calls to a specific LLM provider's API, you describe your interaction using the services provided by the base `@effect/ai` package.

These services expose capabilities such as:
- **Generating Text** – single-shot text generation
- **Generating Embeddings** – vector representations of text for search or retrieval
- **Tool Calling** – structured outputs and tool usage 
- **Streaming** – incremental output for memory efficiency and responsiveness 

Each of these services is defined as an *Effect service* — meaning they can be injected, composed, and tested just like any other dependency in the Effect ecosystem.

This decoupling lets you write your AI code as a pure description of what you want to happen, and resolve *how* it happens later — whether by wiring up OpenAI, Anthropic, a mock service for tests, or even your own custom LLM backend.

---

## Packages

Effect’s AI ecosystem is composed of several focused packages:

### `@effect/ai`

Defines the core abstractions for interacting with LLM provider services. This package defines the generic services and helper utilities needed to build AI-powered applications in a provider-agnostic way.

Use this package to:
- Define your application's interaction with an LLM
- Structure chat or completion flows using Effect
- Build type-safe, declarative AI logic

For detailed API documentation, see the [API Reference](https://effect-ts.github.io/effect/docs/ai/ai).

### `@effect/ai-openai`

Concrete implementations of services from `@effect/ai` backed by the [OpenAI API](https://platform.openai.com). 

Supported services include:
- `LanguageModel` (via OpenAI's [Chat Completions API](https://platform.openai.com/docs/api-reference/chat))
- `EmbeddingsModel` (via OpenAI's [Embeddings API](https://platform.openai.com/docs/api-reference/embeddings))

For detailed API documentation, see the [API Reference](https://effect-ts.github.io/effect/docs/ai/openai).

### `@effect/ai-anthropic`

Concrete implementations of services from `@effect/ai` backed by the [Anthropic API](https://docs.anthropic.com/en/api/getting-started).

Supported services include:
- `LanguageModel` (via Anthropic's [Messages API](https://docs.anthropic.com/en/api/messages))

For detailed API documentation, see the [API Reference](https://effect-ts.github.io/effect/docs/ai/anthropic).

### `@effect/ai-amazon-bedrock`

Concrete implementations of services from `@effect/ai` backed by [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html).

Supported services include:
- `LanguageModel` (via Amazon Bedrock's [Converse API](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html)

For detailed API documentation, see the [API Reference](https://effect-ts.github.io/effect/docs/ai/amazon-bedrock).

### `@effect/ai-google`

Concrete implementations of services from `@effect/ai` backed by [Google Generative AI](https://ai.google.dev/gemini-api/docs).

Supported services include:
- `LanguageModel` (via Google's [Gemini API](https://ai.google.dev/api)

For detailed API documentation, see the [API Reference](https://effect-ts.github.io/effect/docs/ai/google).


---

# [Getting Started](https://effect.website/docs/ai/getting-started/)

## Overview


In this getting started guide, we will demonstrate how to generate a simple text completion using an LLM provider (OpenAi) using the Effect AI integration packages.

We’ll walk through:
- Writing provider-agnostic logic to interact with an LLM
- Declaring the specific LLM model to use for the interaction
- Using a provider integration to make the program executable

## Installation

First, we will need to install the base `@effect/ai` package to gain access to the core AI abstractions. In addition, we will need to install at least one provider integration package (in this case `@effect/ai-openai`):



```sh
# Install the base package for the core abstractions (always required)
npm install @effect/ai

# Install one (or more) provider integrations
npm install @effect/ai-openai

# Also add the core Effect package (if not already installed)
npm install effect
```



```sh
# Install the base package for the core abstractions (always required)
pnpm add @effect/ai

# Install one (or more) provider integrations
pnpm add @effect/ai-openai

# Also add the core Effect package (if not already installed)
pnpm add effect
```



```sh
# Install the base package for the core abstractions (always required)
yarn add @effect/ai

# Install one (or more) provider integrations
yarn add @effect/ai-openai

# Also add the core Effect package (if not already installed)
yarn add effect
```



```sh
# Install the base package for the core abstractions (always required)
bun add @effect/ai

# Install one (or more) provider integrations
bun add @effect/ai-openai

# Also add the core Effect package (if not already installed)
bun add effect
```



## Define an Interaction with a Language Model

First let's define a simple interaction with a large language model (LLM):

**Example** (Using the `LanguageModel` Service to Generate a Dad Joke)

```ts

// Using `LanguageModel` will add it to your program's requirements
//
//          ┌─── Effect<GenerateTextResponse<{}>, AiError, LanguageModel>
//          ▼
const generateDadJoke = Effect.gen(function*() {
  // Use the `LanguageModel` to generate some text
  const response = yield* LanguageModel.generateText({
    prompt: "Generate a dad joke"
  })
  // Log the generated text to the console
  console.log(response.text)
  // Return the response
  return response
})
```

> **Note: Declarative LLM Interactions**
  Notice that the above code does not know or care which LLM provider (OpenAi, Anthropic, etc.) will be used. Instead, we focus on _what_ we want to accomplish (i.e. our business logic), not _how_ to accomplish it.


## Select a Provider

Next, we need to select which model provider we want to use:

**Example** (Using a Model Provider to Satisfy the `LanguageModel` Requirement)

```ts

const generateDadJoke = Effect.gen(function*() {
  const response = yield* LanguageModel.generateText({
    prompt: "Generate a dad joke"
  })
  console.log(response.text)
  return response
})

// Create a `Model` which provides a concrete implementation of
// `LanguageModel` and requires an `OpenAiClient`
//
//      ┌─── Model<"openai", LanguageModel | ProviderName, OpenAiClient>
//      ▼
const Gpt4o = OpenAiLanguageModel.model("gpt-4o")

// Provide the `Model` to the program
//
//     ┌─── Effect<GenerateTextResponse<{}>, AiError, OpenAiClient>
//     ▼
const main = generateDadJoke.pipe(
  Effect.provide(Gpt4o)
)
```

Before moving on, it is important that we understand the purpose of the `Model` data type.

## Understanding `Model`

The `Model` data type represents a **provider-specific implementation** of one or more services, such as `LanguageModel` or `EmbeddingsModel`. It is the primary way that you can plug a real large language model into your program.

```ts
export interface Model<ProviderName, Provides, Requires> {}
```

An `Model` has three generic type parameters:

- **ProviderName** - the name of the large language model provider that will be used 
- **Provides** - the services this model will provide when built
- **Requires** - the services this model will require to be built

This allows Effect to track which services the `Model` requires as well as which services the `Model` will provide.

### Creating n `Model`

To create a `Model`, you can use the model-specific factory from one of Effect's provider integration packages. 

**Example** (Defining a `Model` to Interact with OpenAI)

```ts

//      ┌─── Model<"openai", LanguageModel | ProviderName, OpenAiClient>
//      ▼
const Gpt4o = OpenAiLanguageModel.model("gpt-4o")
```

This creates a `Model` that:

- **Provides** the `ProviderName` service, which allows introspection of the current provider in use by the program 
- **Provides** an OpenAI-specific implementation of the `LanguageModel` service using `"gpt-4o"`
- **Requires** an `OpenAiClient` to be built

### Providing a `Model`

Once you've created a `Model`, you can directly `Effect.provide` it to your Effect programs just like any other service: 

```ts

//      ┌─── Model<"openai", LanguageModel | ProviderName, OpenAiClient>
//      ▼
const Gpt4o = OpenAiLanguageModel.model("gpt-4o")

//       ┌─── Effect<GenerateTextResponse<{}>, AiError, OpenAiClient>
//       ▼
const program = LanguageModel.generateText({
  prompt: "Generate a dad joke"
}).pipe(Effect.provide(Gpt4o))
```

### Benefits of `Model`

There are several benefits to this approach:

**Reusability**

You can provide the same `Model` to as many programs as you like.

**Example** (Providing a `Model` to Multiple Programs)

```ts

const generateDadJoke = Effect.gen(function*() {
  const response = yield* LanguageModel.generateText({
    prompt: "Generate a dad joke"
  })
  console.log(response.text)
  return response
})

const Gpt4o = OpenAiLanguageModel.model("gpt-4o")

const main = Effect.gen(function*() {
  // You can provide the `Model` individually to each
  // program, or to all of them at once (as we do here)
  const res1 = yield* generateDadJoke
  const res2 = yield* generateDadJoke
  const res3 = yield* generateDadJoke
}).pipe(Effect.provide(Gpt4o))
```

**Flexibility**

If we know that one model or provider performs better at a given task than another, we can freely mix and match models and providers together. 

For example, if we know Anthropic's Claude generates some really great dad jokes, we can mix it into our existing program with just a few lines of code:

**Example** (Mixing Multiple Providers and Models)

```ts

const generateDadJoke = Effect.gen(function*() {
  const response = yield* LanguageModel.generateText({
    prompt: "Generate a dad joke"
  })
  console.log(response.text)
  return response
})

const Gpt4o = OpenAiLanguageModel.model("gpt-4o")
const Claude37 = AnthropicLanguageModel.model("claude-3-7-sonnet-latest")

//      ┌─── Effect<void, AiError, AnthropicClient | OpenAiClient>
//      ▼
const main = Effect.gen(function*() {
  const res1 = yield* generateDadJoke
  const res2 = yield* generateDadJoke
  const res3 = yield* Effect.provide(generateDadJoke, Claude37)
}).pipe(Effect.provide(Gpt4o))
```

Because Effect performs type-level dependency tracking, we can see that an `AnthropicClient` is now required to make our program runnable.

**Abstractability**

An `Model` can also be `yield*`'ed to lift its dependencies into the calling Effect. This is particularly useful when creating services that depend on AI interactions, where you want to avoid leaking service-level dependencies into the service interface.

For example, in the code below the `main` program is only dependent upon the `DadJokes` service. All AI requirements are abstracted away into `Layer` composition.

**Example** (Abstracting LLM Interactions into a Service)

```ts

const Gpt4o = OpenAiLanguageModel.model("gpt-4o")
const Claude37 = AnthropicLanguageModel.model("claude-3-7-sonnet-latest")

class DadJokes extends Effect.Service<DadJokes>()("app/DadJokes", {
  effect: Effect.gen(function*() {
    // Yielding the model will return a layer with no requirements
    // 
    //     ┌─── Layer<LanguageModel | ProviderName>
    //     ▼
    const gpt = yield* Gpt4o
    const claude = yield* Claude37

    const generateDadJoke = Effect.gen(function*() {
      const response = yield* LanguageModel.generateText({
        prompt: "Generate a dad joke"
      })
      console.log(response.text)
      return response
    })

    return {
      generateDadJoke: Effect.provide(generateDadJoke, gpt),
      generateBetterDadJoke: Effect.provide(generateDadJoke, claude)
    }
  })
}) {}

// Programs which utilize the `DadJokes` service have no knowledge of 
// any AI requirements
//
//     ┌─── Effect<void, AiError, DadJokes>
//     ▼
const main = Effect.gen(function*() {
  const dadJokes = yield* DadJokes
  const res1 = yield* dadJokes.generateDadJoke
  const res2 = yield* dadJokes.generateBetterDadJoke
})

// The AI requirements are abstracted away into `Layer` composition
//
//         ┌─── Layer<DadJokes, never, AnthropicClient | OpenAiClient>
//         ▼
DadJokes.Default
```

## Create a Provider Client

To make our code executable, we must finish satisfying our program's requirements. 

Let's take another look at our program from earlier:

```ts

const generateDadJoke = Effect.gen(function*() {
  const response = yield* LanguageModel.generateText({
    prompt: "Generate a dad joke"
  })
  console.log(response.text)
  return response
})

const Gpt4o = OpenAiLanguageModel.model("gpt-4o")

//     ┌─── Effect<GenerateTextResponse<{}>, AiError, OpenAiClient>
//     ▼
const main = generateDadJoke.pipe(
  Effect.provide(Gpt4o)
)
```

We can see that our `main` program still requires us to provide an `OpenAiClient`. 

Each of our provider integration packages exports a client module that can be used to construct a client for that provider.

**Example** (Creating a Client Layer for a Model Provider)

```ts

const generateDadJoke = Effect.gen(function*() {
  const response = yield* LanguageModel.generateText({
    prompt: "Generate a dad joke"
  })
  console.log(response.text)
  return response
})

const Gpt4o = OpenAiLanguageModel.model("gpt-4o")

const main = generateDadJoke.pipe(
  Effect.provide(Gpt4o)
)

// Create a `Layer` which produces an `OpenAiClient` and requires
// an `HttpClient`
//
//      ┌─── Layer<OpenAiClient, ConfigError, HttpClient>
//      ▼
const OpenAi = OpenAiClient.layerConfig({
  apiKey: Config.redacted("OPENAI_API_KEY")
})
```

In the code above, we use the `layerConfig` constructor from the `OpenAiClient` module to create a `Layer` which will produce an `OpenAiClient`. The `layerConfig` constructor allows us to read in configuration variables using Effect's [configuration system](/docs/configuration/).

The provider clients also have a dependency on an `HttpClient` implementation to avoid any platform dependencies. This way, you can provide whichever `HttpClient` implementation is most appropriate for the platform your code is running upon.

For example, if we know we are going to run this code in NodeJS, we can utilize the `NodeHttpClient` module from `@effect/platform-node` to provide an `HttpClient` implementation:

```ts

const generateDadJoke = Effect.gen(function*() {
  const response = yield* LanguageModel.generateText({
    prompt: "Generate a dad joke"
  })
  console.log(response.text)
  return response
})

const Gpt4o = OpenAiLanguageModel.model("gpt-4o")

const main = generateDadJoke.pipe(
  Effect.provide(Gpt4o)
)

// Create a `Layer` which produces an `OpenAiClient` and requires
// an `HttpClient`
//
//      ┌─── Layer<OpenAiClient, ConfigError, HttpClient>
//      ▼
const OpenAi = OpenAiClient.layerConfig({
  apiKey: Config.redacted("OPENAI_API_KEY")
})

// Provide a platform-specific implementation of `HttpClient` to our 
// OpenAi layer
//
//        ┌─── Layer<OpenAiClient, ConfigError, never>
//        ▼
const OpenAiWithHttp = Layer.provide(OpenAi, NodeHttpClient.layerUndici)
```

## Running the Program

Now that we have a `Layer` which provides us with an `OpenAiClient`, we're ready to make our `main` program runnable. 

Our final program looks like the following:

```ts

const generateDadJoke = Effect.gen(function*() {
  const response = yield* LanguageModel.generateText({
    prompt: "Generate a dad joke"
  })
  console.log(response.text)
  return response
})

const Gpt4o = OpenAiLanguageModel.model("gpt-4o")

const main = generateDadJoke.pipe(
  Effect.provide(Gpt4o)
)

const OpenAi = OpenAiClient.layerConfig({
  apiKey: Config.redacted("OPENAI_API_KEY")
})

const OpenAiWithHttp = Layer.provide(OpenAi, NodeHttpClient.layerUndici)

main.pipe(
  Effect.provide(OpenAiWithHttp),
  Effect.runPromise
)
```


---

# [Tool Use](https://effect.website/docs/ai/tool-use/)

## Overview

Language models are great at generating text, but often we need them to take **real-world actions**, such as querying an API, accessing a database, or calling a service. Most LLM providers support this through **tool use** (also known as *function calling*), where you expose specific operations in your application that the model can invoke. 

Based on the input it receives, a model may choose to **invoke (or call)** one or more tools to augment its response. Your application then runs the corresponding logic for the tool using the parameters provided by the model. You then return the result to the model, allowing it to include the output in its final response.

The `Toolkit` simplifies tool integration by offering a structured, type-safe approach to defining tools. It takes care of all the wiring between the model and your application - all you have to do is define the tool and implement its behavior.

## Defining a Tool 

Let’s walk through a complete example of how to define, implement, and use a tool that fetches a dad joke from the [icanhazdadjoke.com](https://icanhazdadjoke.com) API.

### 1. Define the Tool 

We start by defining a tool that the language model will have access to using the `Tool.make` constructor. 

This constructor accepts several parameters that allow us to fully describe the tool to the language model:

- `description`: Provides an optional description of the tool
- `success`: The type of value the tool will return if it succeeds
- `failure`: The type of value the tool will return if it fails
- `parameters`: The parameters that the tool should be called with

**Example** (Defining a Tool)

```ts

const GetDadJoke = Tool.make("GetDadJoke", {
  description: "Get a hilarious dad joke from the ICanHazDadJoke API",
  success: Schema.String,
  failure: Schema.Never,
  parameters: {
    searchTerm: Schema.String.annotations({
      description: "The search term to use to find dad jokes"
    })
  }
})
```

Based on the above, a request to call the `GetDadJoke` tool:
- Takes a single `searchTerm` parameter
- Will return a string if it succeeds (i.e. the joke)
- Does not have any expected failure scenarios

### 2. Create a Toolkit

Once we have a tool request defined, we can create a `Toolkit`, which is a collection of tools that the model will have access to. 

**Example** (Creating a `Toolkit`)

```ts

const GetDadJoke = Tool.make("GetDadJoke", {
  description: "Get a hilarious dad joke from the ICanHazDadJoke API",
  success: Schema.String,
  failure: Schema.Never,
  parameters: {
    searchTerm: Schema.String.annotations({
      description: "The search term to use to find dad jokes"
    })
  }
})

const DadJokeTools = Toolkit.make(GetDadJoke)
```

### 3. Implement the Logic

The `.toLayer(...)` method on a `Toolkit` allows you to define the handlers for each tool in the toolkit. Because `.toLayer(...)` takes an `Effect`, we can access services from our application to implement the tool call handlers. 

**Example** (Implementing a `Toolkit`)

```ts
import { 
  HttpClient, 
  HttpClientRequest, 
  HttpClientResponse 
} from "@effect/platform"

class DadJoke extends Schema.Class<DadJoke>("DadJoke")({
  id: Schema.String,
  joke: Schema.String
}) {}

class SearchResponse extends Schema.Class<SearchResponse>("SearchResponse")({
  results: Schema.Array(DadJoke)
}) {}

class ICanHazDadJoke extends Effect.Service<ICanHazDadJoke>()("ICanHazDadJoke", {
  dependencies: [NodeHttpClient.layerUndici],
  effect: Effect.gen(function*() {
    const httpClient = yield* HttpClient.HttpClient
    const httpClientOk = httpClient.pipe(
      HttpClient.filterStatusOk,
      HttpClient.mapRequest(HttpClientRequest.prependUrl("https://icanhazdadjoke.com"))
    )

    const search = Effect.fn("ICanHazDadJoke.search")(
      function*(searchTerm: string) {
        return yield* httpClientOk.get("/search", {
          acceptJson: true,
          urlParams: { searchTerm }
        }).pipe(
          Effect.flatMap(HttpClientResponse.schemaBodyJson(SearchResponse)),
          Effect.flatMap(({ results }) => Array.head(results)),
          Effect.map((joke) => joke.joke),
          Effect.orDie
        )
      }
    )

    return {
      search
    } as const
  })
}) {}

const GetDadJoke = Tool.make("GetDadJoke", {
  description: "Get a hilarious dad joke from the ICanHazDadJoke API",
  success: Schema.String,
  failure: Schema.Never,
  parameters: {
    searchTerm: Schema.String.annotations({
      description: "The search term to use to find dad jokes"
    })
  }
})

const DadJokeTools = Toolkit.make(GetDadJoke)

const DadJokeToolHandlers = DadJokeTools.toLayer(
  Effect.gen(function*() {
    // Access the `ICanHazDadJoke` service 
    const icanhazdadjoke = yield* ICanHazDadJoke
    return {
      // Implement the handler for the `GetDadJoke` tool call request
      GetDadJoke: ({ searchTerm }) => icanhazdadjoke.search(searchTerm)
    }
  })
)
```

In the code above:
- We access the `ICanHazDadJoke` service from our application
- Register a handler for the `GetDadJoke` tool using `.handle("GetDadJoke", ...)`
- Use the `.search` method on our `ICanHazDadJoke` service to search for a dad joke based on the tool call parameters

The result of calling `.toLayer` on a `Toolkit` is a `Layer` that contains the handlers for all the tools in our toolkit. 

Because of this, it is quite simple to test a `Toolkit` by using `.toLayer` to create a separate `Layer` specifically for testing.

### 4. Give the Tools to the Model

Once the tools are defined and implemented, you can pass them along to the model at request time. Behind the scenes, the model is given a structured description of each tool and can choose to call one or more of them when responding to input.

**Example** (Using a `Toolkit`)

```ts

const GetDadJoke = Tool.make("GetDadJoke", {
  description: "Get a hilarious dad joke from the ICanHazDadJoke API",
  success: Schema.String,
  failure: Schema.Never,
  parameters: {
    searchTerm: Schema.String.annotations({
      description: "The search term to use to find dad jokes"
    })
  }
})

const DadJokeTools = Toolkit.make(GetDadJoke)

const generateDadJoke = LanguageModel.generateText({
  prompt: "Generate a dad joke about pirates",
  toolkit: DadJokeTools
})
```

### 5. Bring It All Together

To make the program executable, we must provide the implementation of our tool call handlers:

**Example** (Providing the Tool Call Handlers to a Program)

```ts
import { 
  HttpClient, 
  HttpClientRequest, 
  HttpClientResponse 
} from "@effect/platform"

class DadJoke extends Schema.Class<DadJoke>("DadJoke")({
  id: Schema.String,
  joke: Schema.String
}) {}

class SearchResponse extends Schema.Class<SearchResponse>("SearchResponse")({
  results: Schema.Array(DadJoke)
}) {}

class ICanHazDadJoke extends Effect.Service<ICanHazDadJoke>()("ICanHazDadJoke", {
  dependencies: [NodeHttpClient.layerUndici],
  effect: Effect.gen(function*() {
    const httpClient = yield* HttpClient.HttpClient
    const httpClientOk = httpClient.pipe(
      HttpClient.filterStatusOk,
      HttpClient.mapRequest(HttpClientRequest.prependUrl("https://icanhazdadjoke.com"))
    )

    const search = Effect.fn("ICanHazDadJoke.search")(
      function*(searchTerm: string) {
        return yield* httpClientOk.get("/search", {
          acceptJson: true,
          urlParams: { searchTerm }
        }).pipe(
          Effect.flatMap(HttpClientResponse.schemaBodyJson(SearchResponse)),
          Effect.flatMap(({ results }) => Array.head(results)),
          Effect.map((joke) => joke.joke),
          Effect.scoped,
          Effect.orDie
        )
      }
    )

    return {
      search
    } as const
  })
}) {}

const GetDadJoke = Tool.make("GetDadJoke", {
  description: "Get a hilarious dad joke from the ICanHazDadJoke API",
  success: Schema.String,
  failure: Schema.Never,
  parameters: {
    searchTerm: Schema.String.annotations({
      description: "The search term to use to find dad jokes"
    })
  }
})

const DadJokeTools = Toolkit.make(GetDadJoke)

const DadJokeToolHandlers = DadJokeTools.toLayer(
  Effect.gen(function*() {
    const icanhazdadjoke = yield* ICanHazDadJoke
    return {
      GetDadJoke: ({ searchTerm }) => icanhazdadjoke.search(searchTerm)
    }
  })
).pipe(Layer.provide(ICanHazDadJoke.Default))

const program = LanguageModel.generateText({
  prompt: "Generate a dad joke about pirates",
  toolkit: DadJokeTools
}).pipe(
  Effect.flatMap((response) => Console.log(response.text)),
  Effect.provide(OpenAiLanguageModel.model("gpt-4o"))
)

const OpenAi = OpenAiClient.layerConfig({
  apiKey: Config.redacted("OPENAI_API_KEY")
}).pipe(Layer.provide(NodeHttpClient.layerUndici))

program.pipe(
  Effect.provide([OpenAi, DadJokeToolHandlers]),
  Effect.runPromise
)
```

## Benefits 

**Type Safe**

Every tool is fully described using Effect's `Schema`, including inputs, outputs, and descriptions.

**Effect Native** 

Tool call behavior is defined using Effect, so they can leverage all the power of Effect. This is especially useful when you need to access other services to support the implementation of your tool call handlers.

**Injectable**

Because implementing the handlers for an `Toolkit` results in a `Layer`, providing alternate implementation of tool call handlers in different environments is as simple as providing a different `Layer` to your program.

**Separation of Concerns**

The definition of a tool call request is cleanly separated from both the implementation of the tool behavior, as well as the business logic that calls the model.


---

# [Execution Planning](https://effect.website/docs/ai/planning-llm-interactions/)

## Overview

Imagine that we've refactored our `generateDadJoke` program from our [Getting Started](/docs/ai/getting-started/) guide. Now, instead of handling all errors internally, the code can **fail with domain-specific issues** like network interruptions or provider outages:

```ts
import type { LanguageModel } from "@effect/ai"

class NetworkError extends Data.TaggedError("NetworkError") {}

class ProviderOutage extends Data.TaggedError("ProviderOutage") {}

declare const generateDadJoke: Effect.Effect<
  LanguageModel.GenerateTextResponse<{}>,
  NetworkError | ProviderOutage,
  LanguageModel.LanguageModel
>

const main = Effect.gen(function*() {
  const response = yield* generateDadJoke
  console.log(response.text)
}).pipe(Effect.provide(OpenAiLanguageModel.model("gpt-4o")))
```

This is fine, but what if we want to:
- Retry the program a fixed number of times on `NetworkError`s
- Add some backoff delay between retries
- Fallback to a different model provider if OpenAi is down

How can we accomplish such logic?

## Planning LLM Interactions 

The `ExecutionPlan` module from Effect provides a robust method for creating **structured execution plans** for your Effect programs. Rather than making a single model call and hoping that it succeeds, you can use `ExecutionPlan` to describe how to handle errors, retries, and fallbacks in a clear, declarative way.

This is especially useful when:
- You want to fall back to a secondary model if the primary one is unavailable
- You want to retry on transient errors (e.g. network failures)
- You want to control timing between retry attempts

## Creating Execution Plans 

To create an `ExecutionPlan`, we can use the `ExecutionPlan.make` constructor.

**Example** (Creating an `ExecutionPlan` for LLM Interactions)

```ts
import type { LanguageModel } from "@effect/ai"

class NetworkError extends Data.TaggedError("NetworkError") {}

class ProviderOutage extends Data.TaggedError("ProviderOutage") {}

declare const generateDadJoke: Effect.Effect<
  LanguageModel.GenerateTextResponse<{}>,
  NetworkError | ProviderOutage,
  LanguageModel.LanguageModel
>

const DadJokePlan = ExecutionPlan.make({
  provide: OpenAiLanguageModel.model("gpt-4o"),
  attempts: 3,
  schedule: Schedule.exponential("100 millis", 1.5),
  while: (error: NetworkError | ProviderOutage) => 
    error._tag === "NetworkError"
})

//     ┌─── Effect<void, NetworkError | ProviderOutage, OpenAiClient>
//     ▼
const main = Effect.gen(function*() {
  const response = yield* generateDadJoke
  console.log(response.text)
}).pipe(Effect.withExecutionPlan(DadJokePlan))
```

This plan contains a single step which will:
- Provide OpenAi's `"gpt-4o"` model as a `LanguageModel` for the program 
- Attempt to call OpenAi up to 3 times
- Wait with an exponential backoff between attempts (starting at `100ms`)
- Only re-attempt the call to OpenAi if the error is a `NetworkError`

## Adding Fallback Models

To make your interactions with large language models resilient to provider outages, you can define a **fallback** models to use. This will allow the plan to automatically fallback to another model if the previous step in the execution plan fails.

Use this when:
- You want to make your model interactions resilient to provider outages
- You want to potentially have multiple fallback models 

**Example** (Adding a Fallback to Anthropic from OpenAi)

```ts
import type { LanguageModel } from "@effect/ai"

class NetworkError extends Data.TaggedError("NetworkError") {}

class ProviderOutage extends Data.TaggedError("ProviderOutage") {}

declare const generateDadJoke: Effect.Effect<
  LanguageModel.GenerateTextResponse<{}>,
  NetworkError | ProviderOutage,
  LanguageModel.LanguageModel
>

const DadJokePlan = ExecutionPlan.make({
  provide: OpenAiLanguageModel.model("gpt-4o"),
  attempts: 3,
  schedule: Schedule.exponential("100 millis", 1.5),
  while: (error: NetworkError | ProviderOutage) => 
    error._tag === "NetworkError"
}, {
  provide: AnthropicLanguageModel.model("claude-4-sonnet-20250514"),
  attempts: 2,
  schedule: Schedule.exponential("100 millis", 1.5),
  while: (error: NetworkError | ProviderOutage) => 
    error._tag === "ProviderOutage"
})

//     ┌─── Effect<..., ..., AnthropicClient | OpenAiClient>
//     ▼
const main = Effect.gen(function*() {
  const response = yield* generateDadJoke
  console.log(response.text)
}).pipe(Effect.withExecutionPlan(DadJokePlan))
```

This plan contains two steps. 

**Step 1**

The first step will:
- Provide OpenAi's `"gpt-4o"` model as a `LanguageModel` for the program 
- Attempt to call OpenAi up to 3 times
- Wait with an exponential backoff between attempts (starting at `100ms`)
- Only attempt the call to OpenAi if the error is a `NetworkError`

If all of the above logic fails to run the program successfully, the plan will 
try to run the program using the second step. 

**Step 2**

The second step will:
- Provide Anthropic's `"claude-4-sonnet-20250514"` model as a `LanguageModel` for the program 
- Attempt to call Anthropic up to 2 times
- Wait with an exponential backoff between attempts (starting at `100ms`)
- Only attempt the fallback if the error is a `ProviderOutage` 

## End-to-End Usage

The following is the complete program with the desired execution plan fully implemented:

```ts
import type { LanguageModel } from "@effect/ai"

class NetworkError extends Data.TaggedError("NetworkError") {}

class ProviderOutage extends Data.TaggedError("ProviderOutage") {}

declare const generateDadJoke: Effect.Effect<
  LanguageModel.GenerateTextResponse<{}>,
  NetworkError | ProviderOutage,
  LanguageModel.LanguageModel
>

const DadJokePlan = ExecutionPlan.make({
  provide: OpenAiLanguageModel.model("gpt-4o"),
  attempts: 3,
  schedule: Schedule.exponential("100 millis", 1.5),
  while: (error: NetworkError | ProviderOutage) => 
    error._tag === "NetworkError"
}, {
  provide: AnthropicLanguageModel.model("claude-4-sonnet-20250514"),
  attempts: 2,
  schedule: Schedule.exponential("100 millis", 1.5),
  while: (error: NetworkError | ProviderOutage) => 
    error._tag === "ProviderOutage"
})

const main = Effect.gen(function*() {
  const response = yield* generateDadJoke
  console.log(response.text)
}).pipe(Effect.withExecutionPlan(DadJokePlan))

const Anthropic = AnthropicClient.layerConfig({
  apiKey: Config.redacted("ANTHROPIC_API_KEY")
}).pipe(Layer.provide(NodeHttpClient.layerUndici))

const OpenAi = OpenAiClient.layerConfig({
  apiKey: Config.redacted("OPENAI_API_KEY")
}).pipe(Layer.provide(NodeHttpClient.layerUndici))

main.pipe(
  Effect.provide([Anthropic, OpenAi]),
  Effect.runPromise
)
```


---


## Common Mistakes

**Incorrect (unstructured LLM tool definitions):**

```ts
const tools = [{
  name: "search",
  description: "Search the web",
  parameters: { query: "string" } // No validation
}]
```

**Correct (using AiToolkit for typed tool definitions):**

```ts
import { AiToolkit } from "@effect/ai"
import { Schema } from "effect"

const tools = AiToolkit.empty.pipe(
  AiToolkit.addTool("search", {
    description: "Search the web",
    parameters: Schema.Struct({ query: Schema.String }),
    handler: ({ query }) => Effect.succeed(`Results for: ${query}`)
  })
)
```
