---
title: "Platform"
impact: MEDIUM
impactDescription: "Enables cross-platform I/O — covers FileSystem, Command, Terminal, KeyValueStore"
tags: plat, platform, filesystem, terminal, command
---
# [Introduction to Effect Platform](https://effect.website/docs/platform/introduction/)

## Overview

import {
  Aside,
  Tabs,
  TabItem,
  Badge
} from "@astrojs/starlight/components"

`@effect/platform` is a library for building platform-independent abstractions in environments such as Node.js, Deno, Bun, and browsers.

With `@effect/platform`, you can integrate abstract services like [FileSystem](/docs/platform/file-system/) or [Terminal](/docs/platform/terminal/) into your program.
When assembling your final application, you can provide specific [layers](/docs/requirements-management/layers/) for the target platform using the corresponding packages:

- `@effect/platform-node` for Node.js or Deno
- `@effect/platform-bun` for Bun
- `@effect/platform-browser` for browsers

### Stable Modules

The following modules are stable and their documentation is available on this website:

| Module                                           | Description                                                | Status                                    |
| ------------------------------------------------ | ---------------------------------------------------------- | ----------------------------------------- |
| [Command](/docs/platform/command/)               | Provides a way to interact with the command line.          | <Badge text="Stable" variant="success" /> |
| [FileSystem](/docs/platform/file-system/)        | A module for file system operations.                       | <Badge text="Stable" variant="success" /> |
| [KeyValueStore](/docs/platform/key-value-store/) | Manages key-value pairs for data storage.                  | <Badge text="Stable" variant="success" /> |
| [Path](/docs/platform/path/)                     | Utilities for working with file paths.                     | <Badge text="Stable" variant="success" /> |
| [PlatformLogger](/docs/platform/platformlogger/) | Log messages to a file using the FileSystem APIs.          | <Badge text="Stable" variant="success" /> |
| [Runtime](/docs/platform/runtime/)               | Run your program with built-in error handling and logging. | <Badge text="Stable" variant="success" /> |
| [Terminal](/docs/platform/terminal/)             | Tools for terminal interaction.                            | <Badge text="Stable" variant="success" /> |

### Unstable Modules

Some modules in `@effect/platform` are still in development or marked as experimental.
These features are subject to change.

| Module                                                                                               | Description                                     | Status                                      |
| ---------------------------------------------------------------------------------------------------- | ----------------------------------------------- | ------------------------------------------- |
| [Http API](https://github.com/Effect-TS/effect/blob/main/packages/platform/README.md#http-api)       | Provide a declarative way to define HTTP APIs.  | <Badge text="Unstable" variant="caution" /> |
| [Http Client](https://github.com/Effect-TS/effect/blob/main/packages/platform/README.md#http-client) | A client for making HTTP requests.              | <Badge text="Unstable" variant="caution" /> |
| [Http Server](https://github.com/Effect-TS/effect/blob/main/packages/platform/README.md#http-server) | A server for handling HTTP requests.            | <Badge text="Unstable" variant="caution" /> |
| [Socket](https://effect-ts.github.io/effect/platform/Socket.ts.html)                                 | A module for socket-based communication.        | <Badge text="Unstable" variant="caution" /> |
| [Worker](https://effect-ts.github.io/effect/platform/Worker.ts.html)                                 | A module for running tasks in separate workers. | <Badge text="Unstable" variant="caution" /> |

For the most up-to-date documentation and details, please refer to the official [README](https://github.com/Effect-TS/effect/blob/main/packages/platform/README.md) of the package.

## Installation

To install the **beta** version:



```sh
npm install @effect/platform
```



```sh
pnpm add @effect/platform
```



```sh
yarn add @effect/platform
```



```sh
bun add @effect/platform
```



```sh
deno add npm:@effect/platform
```



## Getting Started with Cross-Platform Programming

Here's a basic example using the `Path` module to create a file path, which can run across different environments:

**Example** (Cross-Platform Path Handling)

```ts

const program = Effect.gen(function* () {
  // Access the Path service
  const path = yield* Path.Path

  // Join parts of a path to create a complete file path
  const mypath = path.join("tmp", "file.txt")

  console.log(mypath)
})
```

### Running the Program in Node.js or Deno

First, install the Node.js-specific package:



```sh
npm install @effect/platform-node
```



```sh
pnpm add @effect/platform-node
```



```sh
yarn add @effect/platform-node
```



```sh
deno add npm:@effect/platform-node
```



Update the program to load the Node.js-specific context:

**Example** (Providing Node.js Context)

```ts

const program = Effect.gen(function* () {
  // Access the Path service
  const path = yield* Path.Path

  // Join parts of a path to create a complete file path
  const mypath = path.join("tmp", "file.txt")

  console.log(mypath)
})

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)))
```

Finally, run the program in Node.js using `tsx`, or directly in Deno:



```sh
npx tsx index.ts
# Output: tmp/file.txt
```



```sh
pnpm dlx tsx index.ts
# Output: tmp/file.txt
```



```sh
yarn dlx tsx index.ts
# Output: tmp/file.txt
```



```sh
deno run index.ts
# Output: tmp/file.txt

# or

deno run -RE index.ts
# Output: tmp/file.txt
# (granting required Read and Environment permissions without being prompted)
```



### Running the Program in Bun

To run the same program in Bun, first install the Bun-specific package:

```sh
bun add @effect/platform-bun
```

Update the program to use the Bun-specific context:

**Example** (Providing Bun Context)

```ts

const program = Effect.gen(function* () {
  // Access the Path service
  const path = yield* Path.Path

  // Join parts of a path to create a complete file path
  const mypath = path.join("tmp", "file.txt")

  console.log(mypath)
})

BunRuntime.runMain(program.pipe(Effect.provide(BunContext.layer)))
```

Run the program in Bun:

```sh
bun index.ts
tmp/file.txt
```


---

# [FileSystem](https://effect.website/docs/platform/file-system/)

## Overview

The `@effect/platform/FileSystem` module provides a set of operations for reading and writing from/to the file system.

## Basic Usage

The module provides a single `FileSystem` [tag](/docs/requirements-management/services/), which acts as the gateway for interacting with the filesystem.

**Example** (Accessing File System Operations)

```ts

const program = Effect.gen(function* () {
  const fs = yield* FileSystem.FileSystem

  // Use `fs` to perform file system operations
})
```

The `FileSystem` interface includes the following operations:

| Operation                   | Description                                                                                                                                                            |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **access**                  | Check if a file can be accessed. You can optionally specify the level of access to check for.                                                                          |
| **copy**                    | Copy a file or directory from `fromPath` to `toPath`. Equivalent to `cp -r`.                                                                                           |
| **copyFile**                | Copy a file from `fromPath` to `toPath`.                                                                                                                               |
| **chmod**                   | Change the permissions of a file.                                                                                                                                      |
| **chown**                   | Change the owner and group of a file.                                                                                                                                  |
| **exists**                  | Check if a path exists.                                                                                                                                                |
| **link**                    | Create a hard link from `fromPath` to `toPath`.                                                                                                                        |
| **makeDirectory**           | Create a directory at `path`. You can optionally specify the mode and whether to recursively create nested directories.                                                |
| **makeTempDirectory**       | Create a temporary directory. By default, the directory will be created inside the system's default temporary directory.                                               |
| **makeTempDirectoryScoped** | Create a temporary directory inside a scope. Functionally equivalent to `makeTempDirectory`, but the directory will be automatically deleted when the scope is closed. |
| **makeTempFile**            | Create a temporary file. The directory creation is functionally equivalent to `makeTempDirectory`. The file name will be a randomly generated string.                  |
| **makeTempFileScoped**      | Create a temporary file inside a scope. Functionally equivalent to `makeTempFile`, but the file will be automatically deleted when the scope is closed.                |
| **open**                    | Open a file at `path` with the specified `options`. The file handle will be automatically closed when the scope is closed.                                             |
| **readDirectory**           | List the contents of a directory. You can recursively list the contents of nested directories by setting the `recursive` option.                                       |
| **readFile**                | Read the contents of a file.                                                                                                                                           |
| **readFileString**          | Read the contents of a file as a string.                                                                                                                               |
| **readLink**                | Read the destination of a symbolic link.                                                                                                                               |
| **realPath**                | Resolve a path to its canonicalized absolute pathname.                                                                                                                 |
| **remove**                  | Remove a file or directory. By setting the `recursive` option to `true`, you can recursively remove nested directories.                                                |
| **rename**                  | Rename a file or directory.                                                                                                                                            |
| **sink**                    | Create a writable `Sink` for the specified `path`.                                                                                                                     |
| **stat**                    | Get information about a file at `path`.                                                                                                                                |
| **stream**                  | Create a readable `Stream` for the specified `path`.                                                                                                                   |
| **symlink**                 | Create a symbolic link from `fromPath` to `toPath`.                                                                                                                    |
| **truncate**                | Truncate a file to a specified length. If the `length` is not specified, the file will be truncated to length `0`.                                                     |
| **utimes**                  | Change the file system timestamps of the file at `path`.                                                                                                               |
| **watch**                   | Watch a directory or file for changes.                                                                                                                                 |
| **writeFile**               | Write data to a file at `path`.                                                                                                                                        |
| **writeFileString**         | Write a string to a file at `path`.                                                                                                                                    |

**Example** (Reading a File as a String)

```ts

//      ┌─── Effect<void, PlatformError, FileSystem>
//      ▼
const program = Effect.gen(function* () {
  const fs = yield* FileSystem.FileSystem

  // Reading the content of the same file where this code is written
  const content = yield* fs.readFileString("./index.ts", "utf8")
  console.log(content)
})

// Provide the necessary context and run the program
NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)))
```

## Mocking the File System

In testing environments, you may want to mock the file system to avoid performing actual disk operations. The `FileSystem.layerNoop` provides a no-operation implementation of the `FileSystem` service.

Most operations in `FileSystem.layerNoop` return a **failure** (e.g., `Effect.fail` for missing files) or a **defect** (e.g., `Effect.die` for unimplemented features).
However, you can override specific behaviors by passing an object to `FileSystem.layerNoop` to define custom return values for selected methods.

**Example** (Mocking File System with Custom Behavior)

```ts

const program = Effect.gen(function* () {
  const fs = yield* FileSystem.FileSystem

  const exists = yield* fs.exists("/some/path")
  console.log(exists)

  const content = yield* fs.readFileString("/some/path")
  console.log(content)
})

//      ┌─── Layer<FileSystem.FileSystem, never, never>
//      ▼
const customMock = FileSystem.layerNoop({
  readFileString: () => Effect.succeed("mocked content"),
  exists: (path) => Effect.succeed(path === "/some/path")
})

// Provide the customized FileSystem mock implementation
Effect.runPromise(program.pipe(Effect.provide(customMock)))
/*
Output:
true
mocked content
*/
```


---

# [Command](https://effect.website/docs/platform/command/)

## Overview

The `@effect/platform/Command` module provides a way to create and run commands with the specified process name and an optional list of arguments.

## Creating Commands

The `Command.make` function generates a command object, which includes details such as the process name, arguments, and environment.

**Example** (Defining a Command for Directory Listing)

```ts

const command = Command.make("ls", "-al")
console.log(command)
/*
{
  _id: '@effect/platform/Command',
  _tag: 'StandardCommand',
  command: 'ls',
  args: [ '-al' ],
  env: {},
  cwd: { _id: 'Option', _tag: 'None' },
  shell: false,
  gid: { _id: 'Option', _tag: 'None' },
  uid: { _id: 'Option', _tag: 'None' }
}
*/
```

This command object does not execute until run by an executor.

## Running Commands

You need a `CommandExecutor` to run the command, which can capture output in various formats such as strings, lines, or streams.

**Example** (Running a Command and Printing Output)

```ts

const command = Command.make("ls", "-al")

// The program depends on a CommandExecutor
const program = Effect.gen(function* () {
  // Runs the command returning the output as a string
  const output = yield* Command.string(command)
  console.log(output)
})

// Provide the necessary CommandExecutor
NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)))
```

### Output Formats

You can choose different methods to handle command output:

| Method        | Description                                                                              |
| ------------- | ---------------------------------------------------------------------------------------- |
| `string`      | Runs the command returning the output as a string (with the specified encoding)          |
| `lines`       | Runs the command returning the output as an array of lines (with the specified encoding) |
| `stream`      | Runs the command returning the output as a stream of `Uint8Array` chunks                 |
| `streamLines` | Runs the command returning the output as a stream of lines (with the specified encoding) |

### exitCode

If you only need the exit code of a command, use `Command.exitCode`.

**Example** (Getting the Exit Code)

```ts

const command = Command.make("ls", "-al")

const program = Effect.gen(function* () {
  const exitCode = yield* Command.exitCode(command)
  console.log(exitCode)
})

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)))
// Output: 0
```

## Custom Environment Variables

You can customize environment variables in a command by using `Command.env`. This is useful when you need specific variables for the command's execution.

**Example** (Setting Environment Variables)

In this example, the command runs in a shell to ensure environment variables are correctly processed.

```ts

const command = Command.make("echo", "-n", "$MY_CUSTOM_VAR").pipe(
  Command.env({
    MY_CUSTOM_VAR: "Hello, this is a custom environment variable!"
  }),
  // Use shell to interpret variables correctly
  // on Windows and Unix-like systems
  Command.runInShell(true)
)

const program = Effect.gen(function* () {
  const output = yield* Command.string(command)
  console.log(output)
})

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)))
// Output: Hello, this is a custom environment variable!
```

## Feeding Input to a Command

You can send input directly to a command's standard input using the `Command.feed` function.

**Example** (Sending Input to a Command's Standard Input)

```ts

const command = Command.make("cat").pipe(Command.feed("Hello"))

const program = Effect.gen(function* () {
  console.log(yield* Command.string(command))
})

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)))
// Output: Hello
```

## Fetching Process Details

You can access details about a running process, such as `exitCode`, `stdout`, and `stderr`.

**Example** (Accessing Exit Code and Streams from a Running Process)

```ts

// Helper function to collect stream output as a string
const runString = <E, R>(
  stream: Stream.Stream<Uint8Array, E, R>
): Effect.Effect<string, E, R> =>
  stream.pipe(
    Stream.decodeText(),
    Stream.runFold(String.empty, String.concat)
  )

const program = Effect.gen(function* () {
  const command = Command.make("ls")

  const [exitCode, stdout, stderr] = yield* pipe(
    // Start running the command and return a handle to the running process
    Command.start(command),
    Effect.flatMap((process) =>
      Effect.all(
        [
          // Waits for the process to exit and returns
          // the ExitCode of the command that was run
          process.exitCode,
          // The standard output stream of the process
          runString(process.stdout),
          // The standard error stream of the process
          runString(process.stderr)
        ],
        { concurrency: 3 }
      )
    )
  )
  console.log({ exitCode, stdout, stderr })
})

NodeRuntime.runMain(
  Effect.scoped(program).pipe(Effect.provide(NodeContext.layer))
)
```

## Streaming stdout to process.stdout

To stream a command's `stdout` directly to `process.stdout`, you can use the following approach:

**Example** (Streaming Command Output Directly to Standard Output)

```ts

// Create a command to run `cat` on a file and inherit stdout
const program = Command.make("cat", "./some-file.txt").pipe(
  Command.stdout("inherit"), // Stream stdout to process.stdout
  Command.exitCode // Get the exit code
)

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)))
```


---

# [Terminal](https://effect.website/docs/platform/terminal/)

## Overview

The `@effect/platform/Terminal` module provides an abstraction for interacting with standard input and output, including reading user input and displaying messages on the terminal.

## Basic Usage

The module provides a single `Terminal` [tag](/docs/requirements-management/services/), which serves as the entry point to reading from and writing to standard input and standard output.

**Example** (Using the Terminal Service)

```ts

const program = Effect.gen(function* () {
  const terminal = yield* Terminal.Terminal

  // Use `terminal` to interact with standard input and output
})
```

## Writing to standard output

**Example** (Displaying a Message on the Terminal)

```ts

const program = Effect.gen(function* () {
  const terminal = yield* Terminal.Terminal
  yield* terminal.display("a message\n")
})

NodeRuntime.runMain(program.pipe(Effect.provide(NodeTerminal.layer)))
// Output: "a message"
```

## Reading from standard input

**Example** (Reading a Line from Standard Input)

```ts

const program = Effect.gen(function* () {
  const terminal = yield* Terminal.Terminal
  const input = yield* terminal.readLine
  console.log(`input: ${input}`)
})

NodeRuntime.runMain(program.pipe(Effect.provide(NodeTerminal.layer)))
// Input: "hello"
// Output: "input: hello"
```

## Example: Number guessing game

This example demonstrates how to create a complete number-guessing game by reading input from the terminal and providing feedback to the user. The game continues until the user guesses the correct number.

**Example** (Interactive Number Guessing Game)

```ts
import type { PlatformError } from "@effect/platform/Error"

// Generate a secret random number between 1 and 100
const secret = Random.nextIntBetween(1, 100)

// Parse the user's input into a valid number
const parseGuess = (input: string) => {
  const n = parseInt(input, 10)
  return isNaN(n) || n < 1 || n > 100 ? Option.none() : Option.some(n)
}

// Display a message on the terminal
const display = (message: string) =>
  Effect.gen(function* () {
    const terminal = yield* Terminal.Terminal
    yield* terminal.display(`${message}\n`)
  })

// Prompt the user for a guess
const prompt = Effect.gen(function* () {
  const terminal = yield* Terminal.Terminal
  yield* terminal.display("Enter a guess: ")
  return yield* terminal.readLine
})

// Get the user's guess, validating it as an integer between 1 and 100
const answer: Effect.Effect<
  number,
  Terminal.QuitException | PlatformError,
  Terminal.Terminal
> = Effect.gen(function* () {
  const input = yield* prompt
  const guess = parseGuess(input)
  if (Option.isNone(guess)) {
    yield* display("You must enter an integer from 1 to 100")
    return yield* answer
  }
  return guess.value
})

// Check if the guess is too high, too low, or correct
const check = <A, E, R>(
  secret: number,
  guess: number,
  ok: Effect.Effect<A, E, R>,
  ko: Effect.Effect<A, E, R>
) =>
  Effect.gen(function* () {
    if (guess > secret) {
      yield* display("Too high")
      return yield* ko
    } else if (guess < secret) {
      yield* display("Too low")
      return yield* ko
    } else {
      return yield* ok
    }
  })

// End the game with a success message
const end = display("You guessed it!")

// Main game loop
const loop = (
  secret: number
): Effect.Effect<
  void,
  Terminal.QuitException | PlatformError,
  Terminal.Terminal
> =>
  Effect.gen(function* () {
    const guess = yield* answer
    return yield* check(
      secret,
      guess,
      end,
      Effect.suspend(() => loop(secret))
    )
  })

// Full game setup and execution
const game = Effect.gen(function* () {
  yield* display(
    `We have selected a random number between 1 and 100.
See if you can guess it in 10 turns or fewer.
We'll tell you if your guess was too high or too low.`
  )
  yield* loop(yield* secret)
})

// Run the game
NodeRuntime.runMain(game.pipe(Effect.provide(NodeTerminal.layer)))
```


---

# [KeyValueStore](https://effect.website/docs/platform/key-value-store/)

## Overview

The `@effect/platform/KeyValueStore` module provides a robust and effectful interface for managing key-value pairs.
It supports asynchronous operations, ensuring data integrity and consistency, and includes built-in implementations for in-memory, file system-based, and schema-validated stores.

## Basic Usage

The module exposes a single [service](/docs/requirements-management/services/), `KeyValueStore`, which acts as the gateway for interacting with the store.

**Example** (Accessing the KeyValueStore Service)

```ts

const program = Effect.gen(function* () {
  const kv = yield* KeyValueStore.KeyValueStore

  // Use `kv` to perform operations on the store
})
```

The `KeyValueStore` interface includes the following operations:

| Operation            | Description                                                          |
| -------------------- | -------------------------------------------------------------------- |
| **get**              | Returns the value as `string` of the specified key if it exists.     |
| **getUint8Array**    | Returns the value as `Uint8Array` of the specified key if it exists. |
| **set**              | Sets the value of the specified key.                                 |
| **remove**           | Removes the specified key.                                           |
| **clear**            | Removes all entries.                                                 |
| **size**             | Returns the number of entries.                                       |
| **modify**           | Updates the value of the specified key if it exists.                 |
| **modifyUint8Array** | Updates the value of the specified key if it exists.                 |
| **has**              | Check if a key exists.                                               |
| **isEmpty**          | Check if the store is empty.                                         |
| **forSchema**        | Create a `SchemaStore` for the specified schema.                     |

**Example** (Basic Operations with a Key-Value Store)

```ts
import {
  KeyValueStore,
  layerMemory
} from "@effect/platform/KeyValueStore"

const program = Effect.gen(function* () {
  const kv = yield* KeyValueStore

  // Store is initially empty
  console.log(yield* kv.size)

  // Set a key-value pair
  yield* kv.set("key", "value")
  console.log(yield* kv.size)

  // Retrieve the value
  const value = yield* kv.get("key")
  console.log(value)

  // Remove the key
  yield* kv.remove("key")
  console.log(yield* kv.size)
})

// Run the program using the in-memory store implementation
Effect.runPromise(program.pipe(Effect.provide(layerMemory)))
/*
Output:
0
1
{ _id: 'Option', _tag: 'Some', value: 'value' }
0
*/
```

## Built-in Implementations

The module includes two built-in implementations of the `KeyValueStore` interface. Both are provided as [layers](/docs/requirements-management/layers/) that you can inject into your effectful programs.

| Implementation        | Description                                                                                             |
| --------------------- | ------------------------------------------------------------------------------------------------------- |
| **In-Memory Store**   | `layerMemory` provides a simple, in-memory key-value store, ideal for lightweight or testing scenarios. |
| **File System Store** | `layerFileSystem` offers a file-based store for persistent storage needs.                               |

## Working with Non-String Values

By default, `KeyValueStore` works with `string` and `Uint8Array` values. To store other types such as objects, numbers, or booleans, use the `forSchema` method to create a `SchemaStore`.

A `SchemaStore` uses a [schema](/docs/schema/introduction/) to validate and convert values. Internally, it serializes data using `JSON.stringify` and deserializes it with `JSON.parse`.

**Example** (Storing a Typed Object Using a Schema)

```ts
import {
  KeyValueStore,
  layerMemory
} from "@effect/platform/KeyValueStore"

// Define a JSON-compatible schema
const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

const program = Effect.gen(function* () {
  // Create a typed store based on the schema
  const kv = (yield* KeyValueStore).forSchema(Person)

  // Store a typed value
  const value = { name: "Alice", age: 30 }
  yield* kv.set("user1", value)
  console.log(yield* kv.size)

  // Retrieve the value
  console.log(yield* kv.get("user1"))
})

// Use the in-memory store for this example
Effect.runPromise(program.pipe(Effect.provide(layerMemory)))
/*
Output:
1
{ _id: 'Option', _tag: 'Some', value: { name: 'Alice', age: 30 } }
*/
```


---

# [Path](https://effect.website/docs/platform/path/)

## Overview

The `@effect/platform/Path` module provides a set of operations for working with file paths.

## Basic Usage

The module provides a single `Path` [tag](/docs/requirements-management/services/), which acts as the gateway for interacting with paths.

**Example** (Accessing the Path Service)

```ts

const program = Effect.gen(function* () {
  const path = yield* Path.Path

  // Use `path` to perform various path operations
})
```

The `Path` interface includes the following operations:

| Operation            | Description                                                                |
| -------------------- | -------------------------------------------------------------------------- |
| **basename**         | Returns the last part of a path, optionally removing a given suffix.       |
| **dirname**          | Returns the directory part of a path.                                      |
| **extname**          | Returns the file extension from a path.                                    |
| **format**           | Formats a path object into a path string.                                  |
| **fromFileUrl**      | Converts a file URL to a path.                                             |
| **isAbsolute**       | Checks if a path is absolute.                                              |
| **join**             | Joins multiple path segments into one.                                     |
| **normalize**        | Normalizes a path by resolving `.` and `..` segments.                      |
| **parse**            | Parses a path string into an object with its segments.                     |
| **relative**         | Computes the relative path from one path to another.                       |
| **resolve**          | Resolves a sequence of paths to an absolute path.                          |
| **sep**              | Returns the platform-specific path segment separator (e.g., `/` on POSIX). |
| **toFileUrl**        | Converts a path to a file URL.                                             |
| **toNamespacedPath** | Converts a path to a namespaced path (specific to Windows).                |

**Example** (Joining Path Segments)

```ts

const program = Effect.gen(function* () {
  const path = yield* Path.Path

  const mypath = path.join("tmp", "file.txt")
  console.log(mypath)
})

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)))
// Output: "tmp/file.txt"
```


---

# [PlatformLogger](https://effect.website/docs/platform/platformlogger/)

## Overview

Effect's logging system generally writes messages to the console by default. However, you might prefer to store logs in a file for easier debugging or archiving. The `PlatformLogger.toFile` function creates a logger that sends log messages to a file on disk.

### toFile

Creates a new logger from an existing string-based logger, writing its output to the specified file.

If you include a `batchWindow` duration when calling `toFile`, logs are batched for that period before being written. This can reduce overhead if your application produces many log entries. Without a `batchWindow`, logs are written as they arrive.

Note that `toFile` returns an `Effect` that may fail with a `PlatformError` if the file cannot be opened or written to. Be sure to handle this possibility if you need to react to file I/O issues.

**Example** (Directing Logs to a File)

This logger requires a `FileSystem` implementation to open and write to the file. For Node.js, you can use `NodeFileSystem.layer`.

```ts

// Create a string-based logger (logfmtLogger in this case)
const myStringLogger = Logger.logfmtLogger

// Apply toFile to write logs to "/tmp/log.txt"
const fileLogger = myStringLogger.pipe(
  PlatformLogger.toFile("/tmp/log.txt")
)

// Replace the default logger, providing NodeFileSystem
// to access the file system
const LoggerLive = Logger.replaceScoped(
  Logger.defaultLogger,
  fileLogger
).pipe(Layer.provide(NodeFileSystem.layer))

const program = Effect.log("Hello")

// Run the program, writing logs to /tmp/log.txt
Effect.runFork(program.pipe(Effect.provide(LoggerLive)))
/*
Logs will be written to "/tmp/log.txt" in the logfmt format,
and won't appear on the console.
*/
```

In the following example, logs are written to both the console and a file. The console uses the pretty logger, while the file uses the logfmt format.

**Example** (Directing Logs to Both a File and the Console)

```ts

const fileLogger = Logger.logfmtLogger.pipe(
  PlatformLogger.toFile("/tmp/log.txt")
)

// Combine the pretty logger for console output with the file logger
const bothLoggers = Effect.map(fileLogger, (fileLogger) =>
  Logger.zip(Logger.prettyLoggerDefault, fileLogger)
)

const LoggerLive = Logger.replaceScoped(
  Logger.defaultLogger,
  bothLoggers
).pipe(Layer.provide(NodeFileSystem.layer))

const program = Effect.log("Hello")

// Run the program, writing logs to both the console (pretty format)
// and "/tmp/log.txt" (logfmt)
Effect.runFork(program.pipe(Effect.provide(LoggerLive)))
```


---

# [Runtime](https://effect.website/docs/platform/runtime/)

## Overview

## Running Your Main Program with runMain

`runMain` helps you execute a main effect with built-in error handling, logging, and signal management. You can concentrate on your effect while `runMain` looks after finalizing resources, logging errors, and setting exit codes.

- **Exit Codes**
  If your effect fails or is interrupted, `runMain` assigns a suitable exit code (for example, `1` for errors and `0` for success).
- **Logs**
  By default, it records errors. This can be turned off if needed.
- **Pretty Logging**
  By default, error messages are recorded using a "pretty" format. You can switch this off when required.
- **Interrupt Handling**
  If the application receives `SIGINT` (Ctrl+C) or a similar signal, `runMain` will interrupt the effect and still run any necessary teardown steps.
- **Teardown Logic**
  You can rely on the default teardown or define your own. The default sets an exit code of `1` for a non-interrupted failure.

### Usage Options

When calling `runMain`, pass in a configuration object with these fields (all optional):

- `disableErrorReporting`: If `true`, errors are not automatically logged.
- `disablePrettyLogger`: If `true`, it avoids adding the "pretty" logger.
- `teardown`: Provide a custom function for finalizing the program. If missing, the default sets exit code `1` for a non-interrupted failure.

**Example** (Running a Successful Program)

```ts

const success = Effect.succeed("Hello, World!")

NodeRuntime.runMain(success)
// No Output
```

**Example** (Running a Failing Program)

```ts

const failure = Effect.fail("Uh oh!")

NodeRuntime.runMain(failure)
/*
Output:
[12:43:07.186] ERROR (#0):
  Error: Uh oh!
*/
```

**Example** (Running a Failing Program Without Pretty Logger)

```ts

const failure = Effect.fail("Uh oh!")

NodeRuntime.runMain(failure, { disablePrettyLogger: true })
/*
Output:
timestamp=2025-01-14T11:43:46.276Z level=ERROR fiber=#0 cause="Error: Uh oh!"
*/
```

**Example** (Running a Failing Program Without Error Reporting)

```ts

const failure = Effect.fail("Uh oh!")

NodeRuntime.runMain(failure, { disableErrorReporting: true })
// No Output
```

**Example** (Running a Failing Program With Custom Teardown)

```ts

const failure = Effect.fail("Uh oh!")

NodeRuntime.runMain(failure, {
  teardown: function customTeardown(exit, onExit) {
    if (exit._tag === "Failure") {
      console.error("Program ended with an error.")
      onExit(1)
    } else {
      console.log("Program finished successfully.")
      onExit(0)
    }
  }
})
/*
Output:
[12:46:39.871] ERROR (#0):
  Error: Uh oh!
Program ended with an error.
*/
```


---


## Common Mistakes

**Incorrect (direct fs module usage):**

```ts
import fs from "fs/promises"
const content = await fs.readFile("config.json", "utf-8")
```

**Correct (using Effect Platform FileSystem):**

```ts
const program = Effect.gen(function* () {
  const fs = yield* FileSystem.FileSystem
  const content = yield* fs.readFileString("config.json")
  return content
})
```
