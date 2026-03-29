---
title: "Observability"
impact: MEDIUM
impactDescription: "Enables production monitoring and debugging — covers logging, metrics, tracing, Supervisor"
tags: obs, observability, logging, metrics, tracing
---
# [Logging](https://effect.website/docs/observability/logging/)

## Overview


Logging is an important aspect of software development, especially for debugging and monitoring the behavior of your applications. In this section, we'll explore Effect's logging utilities and see how they compare to traditional logging methods.

## Advantages Over Traditional Logging

Effect's logging utilities provide several benefits over conventional logging approaches:

1. **Dynamic Log Level Control**: With Effect's logging, you have the ability to change the log level dynamically. This means you can control which log messages get displayed based on their severity. For example, you can configure your application to log only warnings or errors, which can be extremely helpful in production environments to reduce noise.

2. **Custom Logging Output**: Effect's logging utilities allow you to change how logs are handled. You can direct log messages to various destinations, such as a service or a file, using a [custom logger](#custom-loggers). This flexibility ensures that logs are stored and processed in a way that best suits your application's requirements.

3. **Fine-Grained Logging**: Effect enables fine-grained control over logging on a per-part basis of your program. You can set different log levels for different parts of your application, tailoring the level of detail to each specific component. This can be invaluable for debugging and troubleshooting, as you can focus on the information that matters most.

4. **Environment-Based Logging**: Effect's logging utilities can be combined with deployment environments to achieve granular logging strategies. For instance, during development, you might choose to log everything at a trace level and above for detailed debugging. In contrast, your production version could be configured to log only errors or critical issues, minimizing the impact on performance and noise in production logs.

5. **Additional Features**: Effect's logging utilities come with additional features such as the ability to measure time spans, alter log levels on a per-effect basis, and integrate spans for performance monitoring.

## log

The `Effect.log` function allows you to log a message at the default `INFO` level.

**Example** (Logging a Simple Message)

```ts

const program = Effect.log("Application started")

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message="Application started"
*/
```

The default logger in Effect adds several useful details to each log entry:

| Annotation  | Description                                                                                         |
| ----------- | --------------------------------------------------------------------------------------------------- |
| `timestamp` | The timestamp when the log message was generated.                                                   |
| `level`     | The log level at which the message is logged (e.g., `INFO`, `ERROR`).                               |
| `fiber`     | The identifier of the [fiber](/docs/concurrency/fibers/) executing the program.                     |
| `message`   | The log message content, which can include multiple strings or values.                              |
| `span`      | (Optional) The duration of a span in milliseconds, providing insight into the timing of operations. |

> **Tip: Customizing Loggers**
  For information on how to tailor the logging setup to meet specific
  needs, such as integrating a custom logging framework or adjusting log
  formats, please consult the section on [Custom
  Loggers](#custom-loggers).


You can also log multiple messages at once.

**Example** (Logging Multiple Messages)

```ts

const program = Effect.log("message1", "message2", "message3")

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message=message1 message=message2 message=message3
*/
```

For added context, you can also include one or more [Cause](/docs/data-types/cause/) instances in your logs,
which provide detailed error information under an additional `cause` annotation:

**Example** (Logging with Causes)

```ts

const program = Effect.log(
  "message1",
  "message2",
  Cause.die("Oh no!"),
  Cause.die("Oh uh!")
)

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message=message1 message=message2 cause="Error: Oh no!
Error: Oh uh!"
*/
```

## Log Levels

### logDebug

By default, `DEBUG` messages **are not displayed**. To enable `DEBUG` logs, you can adjust the logging configuration using `Logger.withMinimumLogLevel`, setting the minimum level to `LogLevel.Debug`.

**Example** (Enabling Debug Logs)

```ts

const task1 = Effect.gen(function* () {
  yield* Effect.sleep("2 seconds")
  yield* Effect.logDebug("task1 done") // Log a debug message
}).pipe(Logger.withMinimumLogLevel(LogLevel.Debug)) // Enable DEBUG level

const task2 = Effect.gen(function* () {
  yield* Effect.sleep("1 second")
  yield* Effect.logDebug("task2 done") // This message won't be logged
})

const program = Effect.gen(function* () {
  yield* Effect.log("start")
  yield* task1
  yield* task2
  yield* Effect.log("done")
})

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO message=start
timestamp=... level=DEBUG message="task1 done" <-- 2 seconds later
timestamp=... level=INFO message=done <-- 1 second later
*/
```

> **Tip: Controlling Log Levels Per Effect**
  By using `Logger.withMinimumLogLevel(effect, level)`, you can enable
  different log levels for specific parts of your program, providing
  fine-grained control over logging behavior.


### logInfo

The `INFO` log level is displayed by default. This level is typically used for general application events or progress updates.

**Example** (Logging at the Info Level)

```ts

const program = Effect.gen(function* () {
  yield* Effect.logInfo("start")
  yield* Effect.sleep("2 seconds")
  yield* Effect.sleep("1 second")
  yield* Effect.logInfo("done")
})

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO message=start
timestamp=... level=INFO message=done <-- 3 seconds later
*/
```

### logWarning

The `WARN` log level is displayed by default. This level is intended for potential issues or warnings that do not immediately disrupt the flow of the program but should be monitored.

**Example** (Logging at the Warning Level)

```ts

const task = Effect.fail("Oh uh!").pipe(Effect.as(2))

const program = Effect.gen(function* () {
  const failureOrSuccess = yield* Effect.either(task)
  if (Either.isLeft(failureOrSuccess)) {
    yield* Effect.logWarning(failureOrSuccess.left)
    return 0
  } else {
    return failureOrSuccess.right
  }
})

Effect.runFork(program)
/*
Output:
timestamp=... level=WARN fiber=#0 message="Oh uh!"
*/
```

### logError

The `ERROR` log level is displayed by default. These messages represent issues that need to be addressed.

**Example** (Logging at the Error Level)

```ts

const task = Effect.fail("Oh uh!").pipe(Effect.as(2))

const program = Effect.gen(function* () {
  const failureOrSuccess = yield* Effect.either(task)
  if (Either.isLeft(failureOrSuccess)) {
    yield* Effect.logError(failureOrSuccess.left)
    return 0
  } else {
    return failureOrSuccess.right
  }
})

Effect.runFork(program)
/*
Output:
timestamp=... level=ERROR fiber=#0 message="Oh uh!"
*/
```

### logFatal

The `FATAL` log level is displayed by default. This log level is typically reserved for unrecoverable errors.

**Example** (Logging at the Fatal Level)

```ts

const task = Effect.fail("Oh uh!").pipe(Effect.as(2))

const program = Effect.gen(function* () {
  const failureOrSuccess = yield* Effect.either(task)
  if (Either.isLeft(failureOrSuccess)) {
    yield* Effect.logFatal(failureOrSuccess.left)
    return 0
  } else {
    return failureOrSuccess.right
  }
})

Effect.runFork(program)
/*
Output:
timestamp=... level=FATAL fiber=#0 message="Oh uh!"
*/
```

## Custom Annotations

You can enhance your log outputs by adding custom annotations using the `Effect.annotateLogs` function.
This allows you to attach extra metadata to each log entry, improving traceability and providing additional context.

### Adding a Single Annotation

You can apply a single annotation as a key/value pair to all log entries within an effect.

**Example** (Single Key/Value Annotation)

```ts

const program = Effect.gen(function* () {
  yield* Effect.log("message1")
  yield* Effect.log("message2")
}).pipe(
  // Annotation as key/value pair
  Effect.annotateLogs("key", "value")
)

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message=message1 key=value
timestamp=... level=INFO fiber=#0 message=message2 key=value
*/
```

In this example, all logs generated within the `program` will include the annotation `key=value`.

> **Tip: Scope of Annotations**
  Annotations applied with `Effect.annotateLogs` are automatically added
  to all logs generated within the annotated effect's scope, including
  logs from nested effects.


### Annotations with Nested Effects

Annotations propagate to all logs generated within nested or downstream effects. This ensures that logs from any child effects inherit the parent effect's annotations.

**Example** (Propagating Annotations to Nested Effects)

In this example, the annotation `key=value` is included in all logs, even those from the nested `anotherProgram` effect.

```ts

// Define a child program that logs an error
const anotherProgram = Effect.gen(function* () {
  yield* Effect.logError("error1")
})

// Define the main program
const program = Effect.gen(function* () {
  yield* Effect.log("message1")
  yield* Effect.log("message2")
  yield* anotherProgram // Call the nested program
}).pipe(
  // Attach an annotation to all logs in the scope
  Effect.annotateLogs("key", "value")
)

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message=message1 key=value
timestamp=... level=INFO fiber=#0 message=message2 key=value
timestamp=... level=ERROR fiber=#0 message=error1 key=value
*/
```

### Adding Multiple Annotations

You can also apply multiple annotations at once by passing an object with key/value pairs. Each key/value pair will be added to every log entry within the effect.

**Example** (Multiple Annotations)

```ts

const program = Effect.gen(function* () {
  yield* Effect.log("message1")
  yield* Effect.log("message2")
}).pipe(
  // Add multiple annotations
  Effect.annotateLogs({ key1: "value1", key2: "value2" })
)

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message=message1 key2=value2 key1=value1
timestamp=... level=INFO fiber=#0 message=message2 key2=value2 key1=value1
*/
```

In this case, each log will contain both `key1=value1` and `key2=value2`.

### Scoped Annotations

If you want to limit the scope of your annotations so that they only apply to certain log entries, you can use `Effect.annotateLogsScoped`. This function confines the annotations to logs produced within a specific scope.

**Example** (Scoped Annotations)

```ts

const program = Effect.gen(function* () {
  yield* Effect.log("no annotations") // No annotations
  yield* Effect.annotateLogsScoped({ key: "value" }) // Scoped annotation
  yield* Effect.log("message1") // Annotation applied
  yield* Effect.log("message2") // Annotation applied
}).pipe(
  Effect.scoped,
  // Outside scope, no annotations
  Effect.andThen(Effect.log("no annotations again"))
)

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message="no annotations"
timestamp=... level=INFO fiber=#0 message=message1 key=value
timestamp=... level=INFO fiber=#0 message=message2 key=value
timestamp=... level=INFO fiber=#0 message="no annotations again"
*/
```

## Log Spans

Effect provides built-in support for log spans, which allow you to measure and log the duration of specific tasks or sections of your code. This feature is helpful for tracking how long certain operations take, giving you better insights into the performance of your application.

**Example** (Measuring Task Duration with a Log Span)

```ts

const program = Effect.gen(function* () {
  // Simulate a delay to represent a task taking time
  yield* Effect.sleep("1 second")
  // Log a message indicating the job is done
  yield* Effect.log("The job is finished!")
}).pipe(
  // Apply a log span labeled "myspan" to measure
  // the duration of this operation
  Effect.withLogSpan("myspan")
)

Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message="The job is finished!" myspan=1011ms
*/
```

## Disabling Default Logging

Sometimes, perhaps during test execution, you might want to disable default logging in your application. Effect provides several ways to turn off logging when needed. In this section, we'll look at different methods to disable logging in the Effect framework.

**Example** (Using `Logger.withMinimumLogLevel`)

One convenient way to disable logging is by using the `Logger.withMinimumLogLevel` function. This allows you to set the minimum log level to `None`, effectively turning off all log output.

```ts

const program = Effect.gen(function* () {
  yield* Effect.log("Executing task...")
  yield* Effect.sleep("100 millis")
  console.log("task done")
})

// Default behavior: logging enabled
Effect.runFork(program)
/*
Output:
timestamp=... level=INFO fiber=#0 message="Executing task..."
task done
*/

// Disable logging by setting minimum log level to 'None'
Effect.runFork(program.pipe(Logger.withMinimumLogLevel(LogLevel.None)))
/*
Output:
task done
*/
```

**Example** (Using a Layer)

Another approach to disable logging is by creating a layer that sets the minimum log level to `LogLevel.None`, effectively turning off all log output.

```ts

const program = Effect.gen(function* () {
  yield* Effect.log("Executing task...")
  yield* Effect.sleep("100 millis")
  console.log("task done")
})

// Create a layer that disables logging
const layer = Logger.minimumLogLevel(LogLevel.None)

// Apply the layer to disable logging
Effect.runFork(program.pipe(Effect.provide(layer)))
/*
Output:
task done
*/
```

**Example** (Using a Custom Runtime)

You can also disable logging by creating a custom runtime that includes the configuration to turn off logging:

```ts

const program = Effect.gen(function* () {
  yield* Effect.log("Executing task...")
  yield* Effect.sleep("100 millis")
  console.log("task done")
})

// Create a custom runtime that disables logging
const customRuntime = ManagedRuntime.make(
  Logger.minimumLogLevel(LogLevel.None)
)

// Run the program using the custom runtime
customRuntime.runFork(program)
/*
Output:
task done
*/
```

## Loading the Log Level from Configuration

To dynamically load the log level from a [configuration](/docs/configuration/) and apply it to your program, you can use the `Logger.minimumLogLevel` layer. This allows your application to adjust its logging behavior based on external configuration.

**Example** (Loading Log Level from Configuration)

```ts
import {
  Effect,
  Config,
  Logger,
  Layer,
  ConfigProvider,
  LogLevel
} from "effect"

// Simulate a program with logs
const program = Effect.gen(function* () {
  yield* Effect.logError("ERROR!")
  yield* Effect.logWarning("WARNING!")
  yield* Effect.logInfo("INFO!")
  yield* Effect.logDebug("DEBUG!")
})

// Load the log level from the configuration and apply it as a layer
const LogLevelLive = Config.logLevel("LOG_LEVEL").pipe(
  Effect.andThen((level) =>
    // Set the minimum log level
    Logger.minimumLogLevel(level)
  ),
  Layer.unwrapEffect // Convert the effect into a layer
)

// Provide the loaded log level to the program
const configured = Effect.provide(program, LogLevelLive)

// Test the program using a mock configuration provider
const test = Effect.provide(
  configured,
  Layer.setConfigProvider(
    ConfigProvider.fromMap(
      new Map([["LOG_LEVEL", LogLevel.Warning.label]])
    )
  )
)

Effect.runFork(test)
/*
Output:
... level=ERROR fiber=#0 message=ERROR!
... level=WARN fiber=#0 message=WARNING!
*/
```

> **Tip: Using ConfigProvider for Testing**
  The `ConfigProvider.fromMap` function is useful for testing by
  simulating configuration values. You can also refer to [Mocking
  Configurations in
  Tests](/docs/configuration/#mocking-configurations-in-tests) for more
  details on using mock configuration during tests.


## Custom loggers

In this section, you'll learn how to define a custom logger and set it as the default logger in your application. Custom loggers give you control over how log messages are handled, such as routing them to external services, writing to files, or formatting logs in a specific way.

### Defining a Custom Logger

You can define your own logger using the `Logger.make` function. This function allows you to specify how log messages should be processed.

**Example** (Defining a Simple Custom Logger)

```ts

// Custom logger that outputs log messages to the console
const logger = Logger.make(({ logLevel, message }) => {
  globalThis.console.log(`[${logLevel.label}] ${message}`)
})
```

In this example, the custom logger logs messages to the console with the log level and message formatted as `[LogLevel] Message`.

### Using a Custom Logger in a Program

Let's assume you have the following tasks and a program where you log some messages:

```ts

// Custom logger that outputs log messages to the console
const logger = Logger.make(({ logLevel, message }) => {
  globalThis.console.log(`[${logLevel.label}] ${message}`)
})

const task1 = Effect.gen(function* () {
  yield* Effect.sleep("2 seconds")
  yield* Effect.logDebug("task1 done")
})

const task2 = Effect.gen(function* () {
  yield* Effect.sleep("1 second")
  yield* Effect.logDebug("task2 done")
})

const program = Effect.gen(function* () {
  yield* Effect.log("start")
  yield* task1
  yield* task2
  yield* Effect.log("done")
})
```

To replace the default logger with your custom logger, you can use the `Logger.replace` function. After creating a layer that replaces the default logger, you provide it to your program using `Effect.provide`.

**Example** (Replacing the Default Logger with a Custom Logger)

```ts

// Custom logger that outputs log messages to the console
const logger = Logger.make(({ logLevel, message }) => {
  globalThis.console.log(`[${logLevel.label}] ${message}`)
})

const task1 = Effect.gen(function* () {
  yield* Effect.sleep("2 seconds")
  yield* Effect.logDebug("task1 done")
})

const task2 = Effect.gen(function* () {
  yield* Effect.sleep("1 second")
  yield* Effect.logDebug("task2 done")
})

const program = Effect.gen(function* () {
  yield* Effect.log("start")
  yield* task1
  yield* task2
  yield* Effect.log("done")
})

// Replace the default logger with the custom logger
const layer = Logger.replace(Logger.defaultLogger, logger)

Effect.runFork(
  program.pipe(
    Logger.withMinimumLogLevel(LogLevel.Debug),
    Effect.provide(layer)
  )
)
```

When you run the above program, the following log messages are printed to the console:

```ansi
[INFO] start
[DEBUG] task1 done
[DEBUG] task2 done
[INFO] done
```

## Built-in Loggers

Effect provides several built-in loggers that you can use depending on your logging needs. These loggers offer different formats, each suited for different environments or purposes, such as development, production, or integration with external logging services.

Each logger is available in two forms: the logger itself, and a layer that uses the logger and sends its output to the `Console` [default service](/docs/requirements-management/default-services/). For example, the `structuredLogger` logger generates logs in a detailed object-based format, while the `structured` layer uses the same logger and writes the output to the `Console` service.

### stringLogger (default)

The `stringLogger` logger produces logs in a human-readable key-value style. This format is commonly used in development and production because it is simple and easy to read in the console.

This logger does not have a corresponding layer because it is the default logger.

```ts

const program = Effect.log("msg1", "msg2", ["msg3", "msg4"]).pipe(
  Effect.delay("100 millis"),
  Effect.annotateLogs({ key1: "value1", key2: "value2" }),
  Effect.withLogSpan("myspan")
)

Effect.runFork(program)
```

Output:

```ansi
timestamp=2024-12-28T10:44:31.281Z level=INFO fiber=#0 message=msg1 message=msg2 message="[
  \"msg3\",
  \"msg4\"
]" myspan=102ms key2=value2 key1=value1
```

### logfmtLogger

The `logfmtLogger` logger produces logs in a human-readable key-value format, similar to the [stringLogger](#stringlogger-default) logger. The main difference is that `logfmtLogger` removes extra spaces to make logs more compact.

```ts

const program = Effect.log("msg1", "msg2", ["msg3", "msg4"]).pipe(
  Effect.delay("100 millis"),
  Effect.annotateLogs({ key1: "value1", key2: "value2" }),
  Effect.withLogSpan("myspan")
)

Effect.runFork(program.pipe(Effect.provide(Logger.logFmt)))
```

Output:

```ansi
timestamp=2024-12-28T10:44:31.281Z level=INFO fiber=#0 message=msg1 message=msg2 message="[\"msg3\",\"msg4\"]" myspan=102ms key2=value2 key1=value1
```

### prettyLogger

The `prettyLogger` logger enhances log output by using color and indentation for better readability, making it particularly useful during development when visually scanning logs in the console.

```ts

const program = Effect.log("msg1", "msg2", ["msg3", "msg4"]).pipe(
  Effect.delay("100 millis"),
  Effect.annotateLogs({ key1: "value1", key2: "value2" }),
  Effect.withLogSpan("myspan")
)

Effect.runFork(program.pipe(Effect.provide(Logger.pretty)))
```

Output:

```ansi
[11:37:14.265] [32mINFO[0m (#0) myspan=101ms: [1;36mmsg1[0m
  msg2
  [ [32m'msg3'[0m, [32m'msg4'[0m ]
  key2: value2
  key1: value1
```

### structuredLogger

The `structuredLogger` logger produces logs in a detailed object-based format. This format is helpful when you need more traceable logs, especially if other systems analyze them or store them for later review.

```ts

const program = Effect.log("msg1", "msg2", ["msg3", "msg4"]).pipe(
  Effect.delay("100 millis"),
  Effect.annotateLogs({ key1: "value1", key2: "value2" }),
  Effect.withLogSpan("myspan")
)

Effect.runFork(program.pipe(Effect.provide(Logger.structured)))
```

Output:

```ansi
{
  message: [ 'msg1', 'msg2', [ 'msg3', 'msg4' ] ],
  logLevel: 'INFO',
  timestamp: '2024-12-28T10:44:31.281Z',
  cause: undefined,
  annotations: { key2: 'value2', key1: 'value1' },
  spans: { myspan: 102 },
  fiberId: '#0'
}
```

| Field         | Description                                                                                                                                                              |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `message`     | Either a single processed value or an array of processed values, depending on how many messages are logged.                                                              |
| `logLevel`    | A string that indicates the log level label (for example, "INFO" or "DEBUG").                                                                                            |
| `timestamp`   | An ISO 8601 timestamp for when the log was generated (for example, "2024-01-01T00:00:00.000Z").                                                                          |
| `cause`       | A string that shows detailed error information, or `undefined` if no cause was provided.                                                                                 |
| `annotations` | An object where each key is an annotation label and the corresponding value is parsed into a structured format (for instance, `{"key": "value"}`).                       |
| `spans`       | An object mapping each span label to its duration in milliseconds, measured from its start time until the moment the logger was called (for example, `{"myspan": 102}`). |
| `fiberId`     | The identifier of the fiber that generated this log (for example, "#0").                                                                                                 |

### jsonLogger

The `jsonLogger` logger produces logs in JSON format. This can be useful for tools or services that parse and store JSON logs.
It calls `JSON.stringify` on the object created by the [structuredLogger](#structuredlogger) logger.

```ts

const program = Effect.log("msg1", "msg2", ["msg3", "msg4"]).pipe(
  Effect.delay("100 millis"),
  Effect.annotateLogs({ key1: "value1", key2: "value2" }),
  Effect.withLogSpan("myspan")
)

Effect.runFork(program.pipe(Effect.provide(Logger.json)))
```

Output:

```ansi
{"message":["msg1","msg2",["msg3","msg4"]],"logLevel":"INFO","timestamp":"2024-12-28T10:44:31.281Z","annotations":{"key2":"value2","key1":"value1"},"spans":{"myspan":102},"fiberId":"#0"}
```

## Combine Loggers

### zip

The `Logger.zip` function combines two loggers into a new logger. This new logger forwards log messages to both the original loggers.

**Example** (Combining Two Loggers)

```ts

// Define a custom logger that logs to the console
const logger = Logger.make(({ logLevel, message }) => {
  globalThis.console.log(`[${logLevel.label}] ${message}`)
})

// Combine the default logger and the custom logger
//
//      ┌─── Logger<unknown, [void, void]>
//      ▼
const combined = Logger.zip(Logger.defaultLogger, logger)

const program = Effect.log("something")

Effect.runFork(
  program.pipe(
    // Replace the default logger with the combined logger
    Effect.provide(Logger.replace(Logger.defaultLogger, combined))
  )
)
/*
Output:
timestamp=2025-01-09T13:50:58.655Z level=INFO fiber=#0 message=something
[INFO] something
*/
```


---

# [Metrics in Effect](https://effect.website/docs/observability/metrics/)

## Overview


In complex and highly concurrent applications, managing various interconnected components can be quite challenging. Ensuring that everything runs smoothly and avoiding application downtime becomes crucial in such setups.

Now, let's imagine we have a sophisticated infrastructure with numerous services. These services are replicated and distributed across our servers. However, we often lack insight into what's happening across these services, including error rates, response times, and service uptime. This lack of visibility can make it challenging to identify and address issues effectively. This is where Effect Metrics comes into play; it allows us to capture and analyze various metrics, providing valuable data for later investigation.

Effect Metrics offers support for five different types of metrics:

| Metric        | Description                                                                                                                                                                                                                                                             |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Counter**   | Counters are used to track values that increase over time, such as request counts. They help us keep tabs on how many times a specific event or action has occurred.                                                                                                    |
| **Gauge**     | Gauges represent a single numerical value that can fluctuate up and down over time. They are often used to monitor metrics like memory usage, which can vary continuously.                                                                                              |
| **Histogram** | Histograms are useful for tracking the distribution of observed values across different buckets. They are commonly used for metrics like request latencies, allowing us to understand how response times are distributed.                                               |
| **Summary**   | Summaries provide insight into a sliding window of a time series and offer metrics for specific percentiles of the time series, often referred to as quantiles. This is particularly helpful for understanding latency-related metrics, such as request response times. |
| **Frequency** | Frequency metrics count the occurrences of distinct string values. They are useful when you want to keep track of how often different events or conditions are happening in your application.                                                                           |

## Counter

In the world of metrics, a Counter is a metric that represents a single numerical value that can be both incremented and decremented over time. Think of it like a tally that keeps track of changes, such as the number of a particular type of request received by your application, whether it's increasing or decreasing.

Unlike some other types of metrics (like [gauges](#gauge)), where we're interested in the value at a specific moment, with counters, we care about the cumulative value over time. This means it provides a running total of changes, which can go up and down, reflecting the dynamic nature of certain metrics.

Some typical use cases for counters include:

- **Request Counts**: Monitoring the number of incoming requests to your server.
- **Completed Tasks**: Keeping track of how many tasks or processes have been successfully completed.
- **Error Counts**: Counting the occurrences of errors in your application.

### How to Create a Counter

To create a counter, you can use the `Metric.counter` constructor.

**Example** (Creating a Counter)

```ts

const requestCount = Metric.counter("request_count", {
  // Optional
  description: "A counter for tracking requests"
})
```

Once created, the counter can accept an effect that returns a `number`, which will increment or decrement the counter.

**Example** (Using a Counter)

```ts

const requestCount = Metric.counter("request_count")

const program = Effect.gen(function* () {
  // Increment the counter by 1
  const a = yield* requestCount(Effect.succeed(1))
  // Increment the counter by 2
  const b = yield* requestCount(Effect.succeed(2))
  // Decrement the counter by 4
  const c = yield* requestCount(Effect.succeed(-4))

  // Get the current state of the counter
  const state = yield* Metric.value(requestCount)
  console.log(state)

  return a * b * c
})

Effect.runPromise(program).then(console.log)
/*
Output:
CounterState {
  count: -1,
  ...
}
-8
*/
```

> **Note: Type Preservation**
  Applying a counter to an effect doesn't change its original type. The
  metric simply adds tracking without affecting the effect's output type.


### Counter Types

You can specify whether the counter tracks a `number` or `bigint`.

```ts

const numberCounter = Metric.counter("request_count", {
  description: "A counter for tracking requests"
  // bigint: false // default
})

const bigintCounter = Metric.counter("error_count", {
  description: "A counter for tracking errors",
  bigint: true
})
```

### Increment-Only Counters

If you need a counter that only increments, you can use the `incremental: true` option.

**Example** (Using an Increment-Only Counter)

```ts

const incrementalCounter = Metric.counter("count", {
  description: "a counter that only increases its value",
  incremental: true
})

const program = Effect.gen(function* () {
  const a = yield* incrementalCounter(Effect.succeed(1))
  const b = yield* incrementalCounter(Effect.succeed(2))
  // This will have no effect on the counter
  const c = yield* incrementalCounter(Effect.succeed(-4))

  const state = yield* Metric.value(incrementalCounter)
  console.log(state)

  return a * b * c
})

Effect.runPromise(program).then(console.log)
/*
Output:
CounterState {
  count: 3,
  ...
}
-8
*/
```

In this configuration, the counter only accepts positive values. Any attempts to decrement will have no effect, ensuring the counter strictly counts upwards.

### Counters With Constant Input

You can configure a counter to always increment by a fixed value each time it is invoked.

**Example** (Constant Input)

```ts

const taskCount = Metric.counter("task_count").pipe(
  Metric.withConstantInput(1) // Automatically increments by 1
)

const task1 = Effect.succeed(1).pipe(Effect.delay("100 millis"))
const task2 = Effect.succeed(2).pipe(Effect.delay("200 millis"))
const task3 = Effect.succeed(-4).pipe(Effect.delay("300 millis"))

const program = Effect.gen(function* () {
  const a = yield* taskCount(task1)
  const b = yield* taskCount(task2)
  const c = yield* taskCount(task3)

  const state = yield* Metric.value(taskCount)
  console.log(state)

  return a * b * c
})

Effect.runPromise(program).then(console.log)
/*
Output:
CounterState {
  count: 3,
  ...
}
-8
*/
```

## Gauge

In the world of metrics, a Gauge is a metric that represents a single numerical value that can be set or adjusted. Think of it as a dynamic variable that can change over time. One common use case for a gauge is to monitor something like the current memory usage of your application.

Unlike counters, where we're interested in cumulative values over time, with gauges, our focus is on the current value at a specific point in time.

Gauges are the best choice when you want to monitor values that can both increase and decrease, and you're not interested in tracking their rates of change. In other words, gauges help us measure things that have a specific value at a particular moment.

Some typical use cases for gauges include:

- **Memory Usage**: Keeping an eye on how much memory your application is using right now.
- **Queue Size**: Monitoring the current size of a queue where tasks are waiting to be processed.
- **In-Progress Request Counts**: Tracking the number of requests currently being handled by your server.
- **Temperature**: Measuring the current temperature, which can fluctuate up and down.

### How to Create a Gauge

To create a gauge, you can use the `Metric.gauge` constructor.

**Example** (Creating a Gauge)

```ts

const memory = Metric.gauge("memory_usage", {
  // Optional
  description: "A gauge for memory usage"
})
```

Once created, a gauge can be updated by passing an effect that produces the value you want to set for the gauge.

**Example** (Using a Gauge)

```ts

// Create a gauge to track temperature
const temperature = Metric.gauge("temperature")

// Simulate fetching a random temperature
const getTemperature = Effect.gen(function* () {
  // Get a random temperature between -10 and 10
  const t = yield* Random.nextIntBetween(-10, 10)
  console.log(`new temperature: ${t}`)
  return t
})

// Program that updates the gauge multiple times
const program = Effect.gen(function* () {
  const series: Array<number> = []
  // Update the gauge with new temperature readings
  series.push(yield* temperature(getTemperature))
  series.push(yield* temperature(getTemperature))
  series.push(yield* temperature(getTemperature))

  // Retrieve the current state of the gauge
  const state = yield* Metric.value(temperature)
  console.log(state)

  return series
})

Effect.runPromise(program).then(console.log)
/*
Example Output:
new temperature: 9
new temperature: -9
new temperature: 2
GaugeState {
  value: 2, // the most recent value set in the gauge
  ...
}
[ 9, -9, 2 ]
*/
```

> **Note: Gauge Behavior**
  Gauges capture the most recent value set, so if you're tracking a
  sequence of updates, the final state will show only the last recorded
  value, not the entire series.


### Gauge Types

You can specify whether the gauge tracks a `number` or `bigint`.

```ts

const numberGauge = Metric.gauge("memory_usage", {
  description: "A gauge for memory usage"
  // bigint: false // default
})

const bigintGauge = Metric.gauge("cpu_load", {
  description: "A gauge for CPU load",
  bigint: true
})
```

## Histogram

A Histogram is a metric used to analyze how numerical values are distributed over time. Instead of focusing on individual data points, a histogram groups values into predefined ranges, called **buckets**, and tracks how many values fall into each range.

When a value is recorded, it gets assigned to one of the histogram's buckets based on its range. Each bucket has an upper boundary, and the count for that bucket is increased if the value is less than or equal to its boundary. Once recorded, the individual value is discarded, and the focus shifts to how many values have fallen into each bucket.

Histograms also track:

- **Total Count**: The number of values that have been observed.
- **Sum**: The sum of all the observed values.
- **Min**: The smallest observed value.
- **Max**: The largest observed value.

Histograms are especially useful for calculating percentiles, which can help you estimate specific points in a dataset by analyzing how many values are in each bucket.

This concept is inspired by [Prometheus](https://prometheus.io/docs/concepts/metric_types#histogram), a well-known monitoring and alerting toolkit.

Histograms are particularly useful in performance analysis and system monitoring. By examining how response times, latencies, or other metrics are distributed, you can gain valuable insights into your system's behavior. This data helps you identify outliers, performance bottlenecks, or trends that may require optimization.

Common use cases for histograms include:

- **Percentile Estimation**: Histograms allow you to approximate percentiles of observed values, like the 95th percentile of response times.
- **Known Ranges**: If you can estimate the range of values in advance, histograms can organize the data into predefined buckets for better analysis.
- **Performance Metrics**: Use histograms to track metrics like request latencies, memory usage, or throughput over time.
- **Aggregation**: Histograms can be aggregated across multiple instances, making them ideal for distributed systems where you need to collect data from different sources.

> **Note: Histogram Buckets and Precision**
  Keep in mind that histograms don't retain exact values. Instead, they
  group values into buckets, so the precision of your data depends on how
  you define these buckets.


**Example** (Histogram With Linear Buckets)

In this example, we define a histogram with linear buckets, where the values range from `0` to `100` in increments of `10`. Additionally, we include a final bucket for values greater than `100`, referred to as the "Infinity" bucket. This configuration is useful for tracking numeric values, like request latencies, within specific ranges.

The program generates random numbers between `1` and `120`, records them in the histogram, and then prints the histogram's state, showing the count of values that fall into each bucket.

```ts

// Define a histogram to track request latencies, with linear buckets
const latency = Metric.histogram(
  "request_latency",
  // Buckets from 0-100, with an extra Infinity bucket
  MetricBoundaries.linear({ start: 0, width: 10, count: 11 }),
  // Optional
  "Measures the distribution of request latency."
)

const program = Effect.gen(function* () {
  // Generate 100 random values and record them in the histogram
  yield* latency(Random.nextIntBetween(1, 120)).pipe(Effect.repeatN(99))

  // Fetch and display the histogram's state
  const state = yield* Metric.value(latency)
  console.log(state)
})

Effect.runPromise(program)
/*
Example Output:
HistogramState {
  buckets: [
    [ 0, 0 ],    // No values in the 0-10 range
    [ 10, 7 ],   // 7 values in the 10-20 range
    [ 20, 11 ],  // 4 values in the 20-30 range
    [ 30, 20 ],  // 9 values in the 30-40 range
    [ 40, 27 ],  // and so on...
    [ 50, 38 ],
    [ 60, 53 ],
    [ 70, 64 ],
    [ 80, 73 ],
    [ 90, 84 ],
    [ Infinity, 100 ] // All 100 values have been recorded
  ],
  count: 100,  // Total count of observed values
  min: 1,      // Smallest observed value
  max: 119,    // Largest observed value
  sum: 5980,   // Sum of all observed values
  ...
}
*/
```

### Timer Metric

In this example, we demonstrate how to use a timer metric to track the duration of specific workflows. The timer captures how long certain tasks take to execute, storing this information in a histogram, which provides insights into the distribution of these durations.

We generate random values to simulate varying wait times, record the durations in the timer, and then print out the histogram's state.

**Example** (Tracking Workflow Durations with a Timer Metric)

```ts

// Create a timer metric with predefined boundaries from 1 to 10
const timer = Metric.timerWithBoundaries("timer", Array.range(1, 10))

// Define a task that simulates random wait times
const task = Effect.gen(function* () {
  // Generate a random value between 1 and 10
  const n = yield* Random.nextIntBetween(1, 10)
  // Simulate a delay based on the random value
  yield* Effect.sleep(`${n} millis`)
})

const program = Effect.gen(function* () {
  // Track the duration of the task and repeat it 100 times
  yield* Metric.trackDuration(task, timer).pipe(Effect.repeatN(99))

  // Retrieve and print the current state of the timer histogram
  const state = yield* Metric.value(timer)
  console.log(state)
})

Effect.runPromise(program)
/*
Example Output:
HistogramState {
  buckets: [
    [ 1, 3 ],   // 3 tasks completed in <= 1 ms
    [ 2, 13 ],  // 10 tasks completed in <= 2 ms
    [ 3, 17 ],  // and so on...
    [ 4, 26 ],
    [ 5, 35 ],
    [ 6, 43 ],
    [ 7, 53 ],
    [ 8, 56 ],
    [ 9, 65 ],
    [ 10, 72 ],
    [ Infinity, 100 ]      // All 100 tasks have completed
  ],
  count: 100,              // Total number of tasks observed
  min: 0.25797,            // Shortest task duration in milliseconds
  max: 12.25421,           // Longest task duration in milliseconds
  sum: 683.0266810000002,  // Total time spent across all tasks
  ...
}
*/
```

## Summary

A Summary is a metric that gives insights into a series of data points by calculating specific percentiles. Percentiles help us understand how data is distributed. For instance, if you're tracking response times for requests over the past hour, you may want to examine key percentiles such as the 50th, 90th, 95th, or 99th to better understand your system's performance.

Summaries are similar to histograms in that they observe `number` values, but with a different approach. Instead of immediately sorting values into buckets and discarding them, a summary holds onto the observed values in memory. However, to avoid storing too much data, summaries use two parameters:

- **maxAge**: The maximum age a value can have before it's discarded.
- **maxSize**: The maximum number of values stored in the summary.

This creates a sliding window of recent values, so the summary always represents a fixed number of the most recent observations.

Summaries are commonly used to calculate **quantiles** over this sliding window. A **quantile** is a number between `0` and `1` that represents the percentage of values less than or equal to a certain threshold. For example, a quantile of `0.5` (or 50th percentile) is the **median** value, while `0.95` (or 95th percentile) would represent the value below which 95% of the observed data falls.

Quantiles are helpful for monitoring important performance metrics, such as latency, and for ensuring that your system meets performance goals (like Service Level Agreements, or SLAs).

The Effect Metrics API also allows you to configure summaries with an **error margin**. This margin introduces a range of acceptable values for quantiles, improving the accuracy of the result.

Summaries are particularly useful in cases where:

- The range of values you're observing is not known or estimated in advance, making histograms less practical.
- You don't need to aggregate data across multiple instances or average results. Summaries calculate their results on the application side, meaning they focus on the specific instance where they are used.

**Example** (Creating and Using a Summary)

In this example, we will create a summary to track response times. The summary will:

- Hold up to `100` samples.
- Discard samples older than `1 day`.
- Have a `3%` error margin when calculating quantiles.
- Report the `10%`, `50%`, and `90%` quantiles, which help track response time distributions.

We'll apply the summary to an effect that generates random integers, simulating response times.

```ts

// Define the summary for response times
const responseTimeSummary = Metric.summary({
  name: "response_time_summary", // Name of the summary metric
  maxAge: "1 day", // Maximum sample age
  maxSize: 100, // Maximum number of samples to retain
  error: 0.03, // Error margin for quantile calculation
  quantiles: [0.1, 0.5, 0.9], // Quantiles to observe (10%, 50%, 90%)
  // Optional
  description: "Measures the distribution of response times"
})

const program = Effect.gen(function* () {
  // Record 100 random response times between 1 and 120 ms
  yield* responseTimeSummary(Random.nextIntBetween(1, 120)).pipe(
    Effect.repeatN(99)
  )

  // Retrieve and log the current state of the summary
  const state = yield* Metric.value(responseTimeSummary)
  console.log("%o", state)
})

Effect.runPromise(program)
/*
Example Output:
SummaryState {
  error: 0.03,    // Error margin used for quantile calculation
  quantiles: [
    [ 0.1, { _id: 'Option', _tag: 'Some', value: 17 } ],   // 10th percentile: 17 ms
    [ 0.5, { _id: 'Option', _tag: 'Some', value: 62 } ],   // 50th percentile (median): 62 ms
    [ 0.9, { _id: 'Option', _tag: 'Some', value: 109 } ]   // 90th percentile: 109 ms
  ],
  count: 100,    // Total number of samples recorded
  min: 4,        // Minimum observed value
  max: 119,      // Maximum observed value
  sum: 6058,     // Sum of all recorded values
  ...
}
*/
```

## Frequency

Frequencies are metrics that help count the occurrences of specific values. Think of them as a set of counters, each associated with a unique value. When new values are observed, the frequency metric automatically creates new counters for those values.

Frequencies are particularly useful for tracking how often distinct string values occur. Some example use cases include:

- Counting the number of invocations for each service in an application, where each service has a logical name.
- Monitoring how frequently different types of failures occur.

**Example** (Tracking Error Occurrences)

In this example, we'll create a `Frequency` to observe how often different error codes occur. This can be applied to effects that return a `string` value:

```ts

// Define a frequency metric to track errors
const errorFrequency = Metric.frequency("error_frequency", {
  // Optional
  description: "Counts the occurrences of errors."
})

const task = Effect.gen(function* () {
  const n = yield* Random.nextIntBetween(1, 10)
  return `Error-${n}`
})

// Program that simulates random errors and tracks their occurrences
const program = Effect.gen(function* () {
  yield* errorFrequency(task).pipe(Effect.repeatN(99))

  // Retrieve and log the current state of the summary
  const state = yield* Metric.value(errorFrequency)
  console.log("%o", state)
})

Effect.runPromise(program)
/*
Example Output:
FrequencyState {
  occurrences: Map(9) {
    'Error-7' => 12,
    'Error-2' => 12,
    'Error-4' => 14,
    'Error-1' => 14,
    'Error-9' => 8,
    'Error-6' => 11,
    'Error-5' => 9,
    'Error-3' => 14,
    'Error-8' => 6
  },
  ...
}
*/
```

## Tagging Metrics

Tags are key-value pairs you can add to metrics to provide additional context. They help categorize and filter metrics, making it easier to analyze specific aspects of your application's performance or behavior.

When creating metrics, you can add tags to them. Tags are key-value pairs that provide additional context, helping in categorizing and filtering metrics. This makes it easier to analyze and monitor specific aspects of your application.

### Tagging a Specific Metric

You can tag individual metrics using the `Metric.tagged` function.
This allows you to add specific tags to a single metric, providing detailed context without applying tags globally.

**Example** (Tagging an Individual Metric)

```ts

// Create a counter metric for request count
// and tag it with "environment: production"
const counter = Metric.counter("request_count").pipe(
  Metric.tagged("environment", "production")
)
```

Here, the `request_count` metric is tagged with `"environment": "production"`, allowing you to filter or analyze metrics by this tag later.

### Tagging Multiple Metrics

You can use `Effect.tagMetrics` to apply tags to all metrics within the same context. This is useful when you want to apply common tags, like the environment (e.g., "production" or "development"), across multiple metrics.

**Example** (Tagging Multiple Metrics)

```ts

// Create two separate counters
const counter1 = Metric.counter("counter1")
const counter2 = Metric.counter("counter2")

// Define a task that simulates some work with a slight delay
const task = Effect.succeed(1).pipe(Effect.delay("100 millis"))

// Apply the environment tag to both counters in the same context
Effect.gen(function* () {
  yield* counter1(task)
  yield* counter2(task)
}).pipe(Effect.tagMetrics("environment", "production"))
```

If you only want to apply tags within a specific [scope](/docs/resource-management/scope/), you can use `Effect.tagMetricsScoped`. This limits the tag application to metrics within that scope, allowing for more precise tagging control.


---

# [Tracing in Effect](https://effect.website/docs/observability/tracing/)

## Overview

import {
  Tabs,
  TabItem,
  Steps,
  Aside
} from "@astrojs/starlight/components"

Although logs and metrics are useful to understand the behavior of individual services, they are not enough to provide a complete overview of the lifetime of a request in a distributed system.

In a distributed system, a request can span multiple services and each service can make multiple requests to other services to fulfill the request. In such a scenario, we need to have a way to track the lifetime of a request across multiple services to diagnose what services are the bottlenecks and where the request is spending most of its time.

## Spans

A **span** represents a single unit of work or operation within a request. It provides a detailed view of what happened during the execution of that specific operation.

Each span typically contains the following information:

| Span Component   | Description                                                        |
| ---------------- | ------------------------------------------------------------------ |
| **Name**         | Describes the specific operation being tracked.                    |
| **Timing Data**  | Timestamps indicating when the operation started and its duration. |
| **Log Messages** | Structured logs capturing important events during the operation.   |
| **Attributes**   | Metadata providing additional context about the operation.         |

Spans are key building blocks in tracing, helping you visualize and understand the flow of requests through various services.

## Traces

A trace records the paths taken by requests (made by an application or end-user) as they propagate through multi-service architectures, like microservice and serverless applications.

Without tracing, it is challenging to pinpoint the cause of performance problems in a distributed system.

A trace is made of one or more spans. The first span represents the root span. Each root span represents a request from start to finish. The spans underneath the parent provide a more in-depth context of what occurs during a request (or what steps make up a request).

Many Observability back-ends visualize traces as waterfall diagrams that may look something like this:

![Trace Waterfall Diagram](../_assets/waterfall-trace.svg "An image displaying an application trace visualized as a waterfall diagram")

Waterfall diagrams show the parent-child relationship between a root span and its child spans. When a span encapsulates another span, this also represents a nested relationship.

## Creating Spans

You can add tracing to an effect by creating a span using the `Effect.withSpan` API. This helps you track specific operations within the effect.

**Example** (Adding a Span to an Effect)

```ts

// Define an effect that delays for 100 milliseconds
const program = Effect.void.pipe(Effect.delay("100 millis"))

// Instrument the effect with a span for tracing
const instrumented = program.pipe(Effect.withSpan("myspan"))
```

Instrumenting an effect with a span does not change its type. If you start with an `Effect<A, E, R>`, the result remains an `Effect<A, E, R>`.

## Printing Spans

To print spans for debugging or analysis, you'll need to install the required tracing tools. Here’s how to set them up for your project.

### Installing Dependencies

Choose your package manager and install the necessary libraries:

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

```sh
# Install the main library for integrating OpenTelemetry with Effect
npm install @effect/opentelemetry

# Install the required OpenTelemetry SDKs for tracing and metrics
npm install @opentelemetry/sdk-trace-base
npm install @opentelemetry/sdk-trace-node
npm install @opentelemetry/sdk-trace-web
npm install @opentelemetry/sdk-metrics
```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

```sh
# Install the main library for integrating OpenTelemetry with Effect
pnpm add @effect/opentelemetry

# Install the required OpenTelemetry SDKs for tracing and metrics
pnpm add @opentelemetry/sdk-trace-base
pnpm add @opentelemetry/sdk-trace-node
pnpm add @opentelemetry/sdk-trace-web
pnpm add @opentelemetry/sdk-metrics
```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

```sh
# Install the main library for integrating OpenTelemetry with Effect
yarn add @effect/opentelemetry

# Install the required OpenTelemetry SDKs for tracing and metrics
yarn add @opentelemetry/sdk-trace-base
yarn add @opentelemetry/sdk-trace-node
yarn add @opentelemetry/sdk-trace-web
yarn add @opentelemetry/sdk-metrics
```

   </TabItem>

   <TabItem label="Bun" icon="bun">

```sh
# Install the main library for integrating OpenTelemetry with Effect
bun add @effect/opentelemetry

# Install the required OpenTelemetry SDKs for tracing and metrics
bun add @opentelemetry/sdk-trace-base
bun add @opentelemetry/sdk-trace-node
bun add @opentelemetry/sdk-trace-web
bun add @opentelemetry/sdk-metrics
```

   </TabItem>

   </Tabs>

> **Note: Peer Dependency**
  The `@opentelemetry/api` package is a peer dependency of
  `@effect/opentelemetry`. If your package manager does not automatically
  install peer dependencies, you must add it manually.


### Printing a Span to the Console

Once the dependencies are installed, you can set up span printing using OpenTelemetry. Here's an example showing how to print a span for an effect.

**Example** (Setting Up and Printing a Span)

```ts
import {
  ConsoleSpanExporter,
  BatchSpanProcessor
} from "@opentelemetry/sdk-trace-base"

// Define an effect that delays for 100 milliseconds
const program = Effect.void.pipe(Effect.delay("100 millis"))

// Instrument the effect with a span for tracing
const instrumented = program.pipe(Effect.withSpan("myspan"))

// Set up tracing with the OpenTelemetry SDK
const NodeSdkLive = NodeSdk.layer(() => ({
  resource: { serviceName: "example" },
  // Export span data to the console
  spanProcessor: new BatchSpanProcessor(new ConsoleSpanExporter())
}))

// Run the effect, providing the tracing layer
Effect.runPromise(instrumented.pipe(Effect.provide(NodeSdkLive)))
/*
Example Output:
{
  resource: {
    attributes: {
      'service.name': 'example',
      'telemetry.sdk.language': 'nodejs',
      'telemetry.sdk.name': '@effect/opentelemetry',
      'telemetry.sdk.version': '1.28.0'
    }
  },
  instrumentationScope: { name: 'example', version: undefined, schemaUrl: undefined },
  traceId: '673c06608bd815f7a75bf897ef87e186',
  parentId: undefined,
  traceState: undefined,
  name: 'myspan',
  id: '401b2846170cd17b',
  kind: 0,
  timestamp: 1733220735529855.5,
  duration: 102079.958,
  attributes: {},
  status: { code: 1 },
  events: [],
  links: []
}
*/
```

### Understanding the Span Output

The output provides detailed information about the span:

| Field        | Description                                                                                                                                                                                                    |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `traceId`    | A unique identifier for the entire trace, helping trace requests or operations as they move through an application.                                                                                            |
| `parentId`   | Identifies the parent span of the current span, marked as `undefined` in the output when there is no parent span, making it a root span.                                                                       |
| `name`       | Describes the name of the span, indicating the operation being tracked (e.g., "myspan").                                                                                                                       |
| `id`         | A unique identifier for the current span, distinguishing it from other spans within a trace.                                                                                                                   |
| `timestamp`  | A timestamp representing when the span started, measured in microseconds since the Unix epoch.                                                                                                                 |
| `duration`   | Specifies the duration of the span, representing the time taken to complete the operation (e.g., `2895.769` microseconds).                                                                                     |
| `attributes` | Spans may contain attributes, which are key-value pairs providing additional context or information about the operation. In this output, it's an empty object, indicating no specific attributes in this span. |
| `status`     | The status field provides information about the span's status. In this case, it has a code of 1, which typically indicates an OK status (whereas a code of 2 signifies an ERROR status)                        |
| `events`     | Spans can include events, which are records of specific moments during the span's lifecycle. In this output, it's an empty array, suggesting no specific events recorded.                                      |
| `links`      | Links can be used to associate this span with other spans in different traces. In the output, it's an empty array, indicating no specific links for this span.                                                 |

### Span Capturing an Error

Here's how a span looks when the effect encounters an error:

**Example** (Span for an Effect that Fails)

```ts
import {
  ConsoleSpanExporter,
  BatchSpanProcessor
} from "@opentelemetry/sdk-trace-base"

const program = Effect.fail("Oh no!").pipe(
  Effect.delay("100 millis"),
  Effect.withSpan("myspan")
)

const NodeSdkLive = NodeSdk.layer(() => ({
  resource: { serviceName: "example" },
  spanProcessor: new BatchSpanProcessor(new ConsoleSpanExporter())
}))

Effect.runPromiseExit(program.pipe(Effect.provide(NodeSdkLive))).then(
  console.log
)
/*
Example Output:
{
  resource: {
    attributes: {
      'service.name': 'example',
      'telemetry.sdk.language': 'nodejs',
      'telemetry.sdk.name': '@effect/opentelemetry',
      'telemetry.sdk.version': '1.28.0'
    }
  },
  instrumentationScope: { name: 'example', version: undefined, schemaUrl: undefined },
  traceId: 'eee9619866179f209b7aae277283e71f',
  parentId: undefined,
  traceState: undefined,
  name: 'myspan',
  id: '3a5725c91884c9e1',
  kind: 0,
  timestamp: 1733220830575626,
  duration: 106578.042,
  attributes: {
    'code.stacktrace': 'at <anonymous> (/Users/giuliocanti/Documents/GitHub/website/content/dev/index.ts:10:10)'
  },
  status: { code: 2, message: 'Oh no!' },
  events: [
    {
      name: 'exception',
      attributes: {
        'exception.type': 'Error',
        'exception.message': 'Oh no!',
        'exception.stacktrace': 'Error: Oh no!'
      },
      time: [ 1733220830, 682204083 ],
      droppedAttributesCount: 0
    }
  ],
  links: []
}
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Oh no!' }
}
*/
```

In this example, the span's status code is `2`, indicating an error. The message in the status provides more details about the failure.

## Adding Annotations

You can provide extra information to a span by utilizing the `Effect.annotateCurrentSpan` function.
This function allows you to attach key-value pairs, offering more context about the execution of the span.

**Example** (Annotating a Span)

```ts
import {
  ConsoleSpanExporter,
  BatchSpanProcessor
} from "@opentelemetry/sdk-trace-base"

const program = Effect.void.pipe(
  Effect.delay("100 millis"),
  // Annotate the span with a key-value pair
  Effect.tap(() => Effect.annotateCurrentSpan("key", "value")),
  // Wrap the effect in a span named 'myspan'
  Effect.withSpan("myspan")
)

// Set up tracing with the OpenTelemetry SDK
const NodeSdkLive = NodeSdk.layer(() => ({
  resource: { serviceName: "example" },
  spanProcessor: new BatchSpanProcessor(new ConsoleSpanExporter())
}))

// Run the effect, providing the tracing layer
Effect.runPromise(program.pipe(Effect.provide(NodeSdkLive)))
/*
Example Output:
{
  resource: {
    attributes: {
      'service.name': 'example',
      'telemetry.sdk.language': 'nodejs',
      'telemetry.sdk.name': '@effect/opentelemetry',
      'telemetry.sdk.version': '1.28.0'
    }
  },
  instrumentationScope: { name: 'example', version: undefined, schemaUrl: undefined },
  traceId: 'c8120e01c0f1ea83ccc1d388e5cdebd3',
  parentId: undefined,
  traceState: undefined,
  name: 'myspan',
  id: '81c430ba4979f1db',
  kind: 0,
  timestamp: 1733220874356084,
  duration: 102821.417,
  attributes: { key: 'value' },
  status: { code: 1 },
  events: [],
  links: []
}
*/
```

## Logs as events

In the context of tracing, logs are converted into "Span Events." These events offer structured insights into your application's activities and provide a timeline of when specific operations occurred.

```ts
import {
  ConsoleSpanExporter,
  BatchSpanProcessor
} from "@opentelemetry/sdk-trace-base"

// Define a program that logs a message and delays for 100 milliseconds
const program = Effect.log("Hello").pipe(
  Effect.delay("100 millis"),
  Effect.withSpan("myspan")
)

// Set up tracing with the OpenTelemetry SDK
const NodeSdkLive = NodeSdk.layer(() => ({
  resource: { serviceName: "example" },
  spanProcessor: new BatchSpanProcessor(new ConsoleSpanExporter())
}))

// Run the effect, providing the tracing layer
Effect.runPromise(program.pipe(Effect.provide(NodeSdkLive)))
/*
Example Output:
{
  resource: {
    attributes: {
      'service.name': 'example',
      'telemetry.sdk.language': 'nodejs',
      'telemetry.sdk.name': '@effect/opentelemetry',
      'telemetry.sdk.version': '1.28.0'
    }
  },
  instrumentationScope: { name: 'example', version: undefined, schemaUrl: undefined },
  traceId: 'b0f4f012b5b13c0a040f7002a1d7b020',
  parentId: undefined,
  traceState: undefined,
  name: 'myspan',
  id: 'b9ba8472002715a8',
  kind: 0,
  timestamp: 1733220905504162.2,
  duration: 103790,
  attributes: {},
  status: { code: 1 },
  events: [
    {
      name: 'Hello',
      attributes: { 'effect.fiberId': '#0', 'effect.logLevel': 'INFO' }, // Log attributes
      time: [ 1733220905, 607761042 ], // Event timestamp
      droppedAttributesCount: 0
    }
  ],
  links: []
}
*/
```

Each span can include events, which capture specific moments during the execution of a span. In this example, a log message `"Hello"` is recorded as an event within the span. Key details of the event include:

| Field                    | Description                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------- |
| `name`                   | The name of the event, which corresponds to the logged message (e.g., `'Hello'`).                 |
| `attributes`             | Key-value pairs that provide additional context about the event, such as `fiberId` and log level. |
| `time`                   | The timestamp of when the event occurred, shown in a high-precision format.                       |
| `droppedAttributesCount` | Indicates how many attributes were discarded, if any. In this case, no attributes were dropped.   |

## Nesting Spans

Spans can be nested to represent a hierarchy of operations. This allows you to track how different parts of your application relate to one another during execution. The following example demonstrates how to create and manage nested spans.

**Example** (Nesting Spans in a Trace)

```ts
import {
  ConsoleSpanExporter,
  BatchSpanProcessor
} from "@opentelemetry/sdk-trace-base"

const child = Effect.void.pipe(
  Effect.delay("100 millis"),
  Effect.withSpan("child")
)

const parent = Effect.gen(function* () {
  yield* Effect.sleep("20 millis")
  yield* child
  yield* Effect.sleep("10 millis")
}).pipe(Effect.withSpan("parent"))

// Set up tracing with the OpenTelemetry SDK
const NodeSdkLive = NodeSdk.layer(() => ({
  resource: { serviceName: "example" },
  spanProcessor: new BatchSpanProcessor(new ConsoleSpanExporter())
}))

// Run the effect, providing the tracing layer
Effect.runPromise(parent.pipe(Effect.provide(NodeSdkLive)))
/*
Example Output:
{
  resource: {
    attributes: {
      'service.name': 'example',
      'telemetry.sdk.language': 'nodejs',
      'telemetry.sdk.name': '@effect/opentelemetry',
      'telemetry.sdk.version': '1.28.0'
    }
  },
  instrumentationScope: { name: 'example', version: undefined, schemaUrl: undefined },
  traceId: 'a9cd69ad70698a0c7b7b774597c77d39',
  parentId: 'a09e5c3fdfdbbc1d', // This indicates the span is a child of 'parent'
  traceState: undefined,
  name: 'child',
  id: '210d2f9b648389a4', // Unique ID for the child span
  kind: 0,
  timestamp: 1733220970590126.2,
  duration: 101579.875,
  attributes: {},
  status: { code: 1 },
  events: [],
  links: []
}
{
  resource: {
    attributes: {
      'service.name': 'example',
      'telemetry.sdk.language': 'nodejs',
      'telemetry.sdk.name': '@effect/opentelemetry',
      'telemetry.sdk.version': '1.28.0'
    }
  },
  instrumentationScope: { name: 'example', version: undefined, schemaUrl: undefined },
  traceId: 'a9cd69ad70698a0c7b7b774597c77d39',
  parentId: undefined, // Indicates this is the root span
  traceState: undefined,
  name: 'parent',
  id: 'a09e5c3fdfdbbc1d', // Unique ID for the parent span
  kind: 0,
  timestamp: 1733220970569015.2,
  duration: 132612.208,
  attributes: {},
  status: { code: 1 },
  events: [],
  links: []
}
*/
```

The parent-child relationship is evident in the span output, where the `parentId` of the `child` span matches the `id` of the `parent` span. This structure helps track how operations are related within a single trace.

## Tutorial: Visualizing Traces

In this tutorial, we will guide you through visualizing traces generated by a sample Effect application. The sample application has also been configured to export traces and/or metrics via HTTP using [OTLP format](https://github.com/open-telemetry/opentelemetry-proto/blob/main/docs/specification.md).

To visualize the traces being exported by our application, we will use a Docker image that contains a preconfigured OpenTelemetry backend based on the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector), [Prometheus](https://github.com/prometheus/prometheus), [Loki](https://github.com/grafana/loki), [Tempo](https://github.com/grafana/tempo), and [Grafana](https://github.com/grafana/grafana). 

### Tools Explained

Let's understand the tools we'll be using in simple terms:

- **Docker**: Docker allows us to run applications in containers. Think of a container as a lightweight and isolated environment where your application can run consistently, regardless of the host system. It's a bit like a virtual machine but more efficient.

- **Prometheus**: Prometheus is a monitoring and alerting toolkit. It collects metrics and data about your applications and stores them for further analysis. This helps in identifying performance issues and understanding the behavior of your applications.

- **Loki**: Loki is a log aggregation system inspired by Prometheus. It does not index the contents of the logs, but rather a set of labels for each log stream.

- **Grafana**: Grafana is a visualization and analytics platform. It helps in creating beautiful and interactive dashboards to visualize your application's data. You can use it to graphically represent metrics collected by Prometheus.

- **Tempo**: Tempo is a distributed tracing system that allows you to trace the journey of a request as it flows through your application. It provides insights into how requests are processed and helps in debugging and optimizing your applications.

### Getting Docker

To get Docker, follow these steps:

1. Visit the Docker website at [https://www.docker.com/](https://www.docker.com/).

2. Download Docker Desktop for your operating system (Windows or macOS) and install it.

3. After installation, open Docker Desktop, and it will run in the background.

### Simulating Traces


1. **Start the OpenTelemetry Backend**

   Before we begin generating and exporting traces from our sample application, we will need to get our OpenTelemetry backend running in Docker. 

   This can be done using the following command:

   ```sh
   docker run -p 3000:3000 -p 4317:4317 -p 4318:4318 --rm -it docker.io/grafana/otel-lgtm
   ```

2. **Install Dependencies**

   We also need to install a few additional dependencies, as well as the latest version of `effect`:

   <Tabs syncKey="package-manager">

   <TabItem label="npm" icon="seti:npm">

   ```sh
   # If not already installed
   npm install effect
   # Required to integrate Effect with OpenTelemetry
   npm install @effect/opentelemetry
   # Required to export traces over HTTP in OTLP format
   npm install @opentelemetry/exporter-trace-otlp-http
   # Required by all applications
   npm install @opentelemetry/sdk-trace-base
   # For NodeJS applications
   npm install @opentelemetry/sdk-trace-node
   # For browser applications
   npm install @opentelemetry/sdk-trace-web
   # If you also need to export metrics
   npm install @opentelemetry/sdk-metrics
   ```

   </TabItem>

   <TabItem label="pnpm" icon="pnpm">

   ```sh
   # If not already installed
   pnpm add effect
   # Required to integrate Effect with OpenTelemetry
   pnpm add @effect/opentelemetry
   # Required to export traces over HTTP in OTLP format
   pnpm add @opentelemetry/exporter-trace-otlp-http
   # Required by all applications
   pnpm add @opentelemetry/sdk-trace-base
   # For NodeJS applications
   pnpm add @opentelemetry/sdk-trace-node
   # For browser applications
   pnpm add @opentelemetry/sdk-trace-web
   # If you also need to export metrics
   pnpm add @opentelemetry/sdk-metrics
   ```

   </TabItem>

   <TabItem label="Yarn" icon="seti:yarn">

   ```sh
   # If not already installed
   yarn add effect
   # Required to integrate Effect with OpenTelemetry
   yarn add @effect/opentelemetry
   # Required to export traces over HTTP in OTLP format
   yarn add @opentelemetry/exporter-trace-otlp-http
   # Required by all applications
   yarn add @opentelemetry/sdk-trace-base
   # For NodeJS applications
   yarn add @opentelemetry/sdk-trace-node
   # For browser applications
   yarn add @opentelemetry/sdk-trace-web
   # If you also need to export metrics
   yarn add @opentelemetry/sdk-metrics
   ```

   </TabItem>

   <TabItem label="Bun" icon="bun">

   ```sh
   # If not already installed
   bun add effect
   # Required to integrate Effect with OpenTelemetry
   bun add @effect/opentelemetry
   # Required to export traces over HTTP in OTLP format
   bun add @opentelemetry/exporter-trace-otlp-http
   # Required by all applications
   bun add @opentelemetry/sdk-trace-base
   # For NodeJS applications
   bun add @opentelemetry/sdk-trace-node
   # For browser applications
   bun add @opentelemetry/sdk-trace-web
   # If you also need to export metrics
   bun add @opentelemetry/sdk-metrics
   ```

   </TabItem>

   </Tabs>

3. **Simulate Traces**

   Now, let's simulate traces using a sample Node.js application. 

   The following code simulates a set of tasks and generates traces for each task. It also sets up a `Layer` which will export traces from our application to our OpenTelemetry backend over HTTP in OTLP format.

   ```ts
   import { Effect } from "effect"
   import { NodeSdk } from "@effect/opentelemetry"
   import { BatchSpanProcessor } from "@opentelemetry/sdk-trace-base"
   import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http"

   // Function to simulate a task with possible subtasks
   const task = (
     name: string,
     delay: number,
     children: ReadonlyArray<Effect.Effect<void>> = []
   ) =>
     Effect.gen(function* () {
       yield* Effect.log(name)
       yield* Effect.sleep(`${delay} millis`)
       for (const child of children) {
         yield* child
       }
       yield* Effect.sleep(`${delay} millis`)
     }).pipe(Effect.withSpan(name))

   const poll = task("/poll", 1)

   // Create a program with tasks and subtasks
   const program = task("client", 2, [
     task("/api", 3, [
       task("/authN", 4, [task("/authZ", 5)]),
       task("/payment Gateway", 6, [
         task("DB", 7),
         task("Ext. Merchant", 8)
       ]),
       task("/dispatch", 9, [
         task("/dispatch/search", 10),
         Effect.all([poll, poll, poll], { concurrency: "inherit" }),
         task("/pollDriver/{id}", 11)
       ])
     ])
   ])

   const NodeSdkLive = NodeSdk.layer(() => ({
     resource: { serviceName: "example" },
     spanProcessor: new BatchSpanProcessor(new OTLPTraceExporter())
   }))

   Effect.runPromise(
     program.pipe(
       Effect.provide(NodeSdkLive),
       Effect.catchAllCause(Effect.logError)
     )
   )
   /*
   Output:
   timestamp=... level=INFO fiber=#0 message=client
   timestamp=... level=INFO fiber=#0 message=/api
   timestamp=... level=INFO fiber=#0 message=/authN
   timestamp=... level=INFO fiber=#0 message=/authZ
   timestamp=... level=INFO fiber=#0 message="/payment Gateway"
   timestamp=... level=INFO fiber=#0 message=DB
   timestamp=... level=INFO fiber=#0 message="Ext. Merchant"
   timestamp=... level=INFO fiber=#0 message=/dispatch
   timestamp=... level=INFO fiber=#0 message=/dispatch/search
   timestamp=... level=INFO fiber=#3 message=/poll
   timestamp=... level=INFO fiber=#4 message=/poll
   timestamp=... level=INFO fiber=#5 message=/poll
   timestamp=... level=INFO fiber=#0 message=/pollDriver/{id}
   */
   ```
4. **Visualize Traces**
  
   Open your web browser and go to `http://localhost:3000/explore`. You should see the Grafana Tempo TraceQL interface.

   ![Tempo TraceQL Interface](../_assets/tempo-traceql-interface.png "The Grafana Tempo TraceQL interface without a TraceQL query specified")

   To get a list of all available traces, we can select the `"Search"` query type to get a list of all available traces.

   ![Tempo Search Selector](../_assets/tempo-trace-list.png "The Grafana Tempo TraceQL interface with the Search selector outlined by a red box")

   Clicking the generated Trace ID will allow us to inspect the details of the trace.

   ![Traces in Grafana Tempo](../_assets/trace.png "The details of an Effect application trace visualized as a waterfall diagram in Grafana Tempo")


## Integrations

### Sentry

To send span data directly to Sentry for analysis, replace the default span processor with Sentry's implementation. This allows you to use Sentry as a backend for tracing and debugging.

**Example** (Configuring Sentry for Tracing)

```ts

const NodeSdkLive = NodeSdk.layer(() => ({
  resource: { serviceName: "example" },
  spanProcessor: new SentrySpanProcessor()
}))
```


---

# [Supervisor](https://effect.website/docs/observability/supervisor/)

## Overview

A `Supervisor<A>` is a utility for managing fibers in Effect, allowing you to track their lifecycle (creation and termination) and producing a value of type `A` that reflects this supervision. Supervisors are useful when you need insight into or control over the behavior of fibers within your application.

To create a supervisor, you can use the `Supervisor.track` function. This generates a new supervisor that keeps track of its child fibers, maintaining them in a set. This allows you to observe and monitor their status during execution.

You can supervise an effect by using the `Effect.supervised` function. This function takes a supervisor as an argument and returns an effect where all child fibers forked within it are supervised by the provided supervisor. This enables you to capture detailed information about these child fibers, such as their status, through the supervisor.

**Example** (Monitoring Fiber Count)

In this example, we'll periodically monitor the number of fibers running in the application using a supervisor. The program calculates a Fibonacci number, spawning multiple fibers in the process, while a separate monitor tracks the fiber count.

```ts

// Main program that monitors fibers while calculating a Fibonacci number
const program = Effect.gen(function* () {
  // Create a supervisor to track child fibers
  const supervisor = yield* Supervisor.track

  // Start a Fibonacci calculation, supervised by the supervisor
  const fibFiber = yield* fib(20).pipe(
    Effect.supervised(supervisor),
    // Fork the Fibonacci effect into a fiber
    Effect.fork
  )

  // Define a schedule to periodically monitor the fiber count every 500ms
  const policy = Schedule.spaced("500 millis").pipe(
    Schedule.whileInputEffect((_) =>
      Fiber.status(fibFiber).pipe(
        // Continue while the Fibonacci fiber is not done
        Effect.andThen((status) => status !== FiberStatus.done)
      )
    )
  )

  // Start monitoring the fibers, using the supervisor to track the count
  const monitorFiber = yield* monitorFibers(supervisor).pipe(
    // Repeat the monitoring according to the schedule
    Effect.repeat(policy),
    // Fork the monitoring into its own fiber
    Effect.fork
  )

  // Join the monitor and Fibonacci fibers to ensure they complete
  yield* Fiber.join(monitorFiber)
  const result = yield* Fiber.join(fibFiber)

  console.log(`fibonacci result: ${result}`)
})

// Function to monitor and log the number of active fibers
const monitorFibers = (
  supervisor: Supervisor.Supervisor<Array<Fiber.RuntimeFiber<any, any>>>
): Effect.Effect<void> =>
  Effect.gen(function* () {
    const fibers = yield* supervisor.value // Get the current set of fibers
    console.log(`number of fibers: ${fibers.length}`)
  })

// Recursive Fibonacci calculation, spawning fibers for each recursive step
const fib = (n: number): Effect.Effect<number> =>
  Effect.gen(function* () {
    if (n <= 1) {
      return 1
    }
    yield* Effect.sleep("500 millis") // Simulate work by delaying

    // Fork two fibers for the recursive Fibonacci calls
    const fiber1 = yield* Effect.fork(fib(n - 2))
    const fiber2 = yield* Effect.fork(fib(n - 1))

    // Join the fibers to retrieve their results
    const v1 = yield* Fiber.join(fiber1)
    const v2 = yield* Fiber.join(fiber2)

    return v1 + v2 // Combine the results
  })

Effect.runPromise(program)
/*
Output:
number of fibers: 0
number of fibers: 2
number of fibers: 6
number of fibers: 14
number of fibers: 30
number of fibers: 62
number of fibers: 126
number of fibers: 254
number of fibers: 510
number of fibers: 1022
number of fibers: 2034
number of fibers: 3795
number of fibers: 5810
number of fibers: 6474
number of fibers: 4942
number of fibers: 2515
number of fibers: 832
number of fibers: 170
number of fibers: 18
number of fibers: 0
fibonacci result: 10946
*/
```


---


## Common Mistakes

**Incorrect (console.log scattered through code):**

```ts
console.log("Processing user", userId)
console.log("ERROR:", error.message)
```

**Correct (using Effect's structured logging):**

```ts
Effect.log("Processing user").pipe(
  Effect.annotateLogs({ userId })
)
Effect.logError("Processing failed").pipe(
  Effect.annotateLogs({ error: error.message })
)
```
