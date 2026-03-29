---
title: "Scheduling"
impact: MEDIUM
impactDescription: "Enables precise timing control — covers schedules, cron, combinators, repetition"
tags: sched, scheduling, cron, repetition, timing
---
# [Introduction](https://effect.website/docs/scheduling/introduction/)

## Overview

# Scheduling

Scheduling is an important concept in Effect that allows you to define recurring effectful operations. It involves the use of the `Schedule` type, which is an immutable value that describes a scheduled pattern for executing effects.

The `Schedule` type is structured as follows:

```text
          ┌─── The type of output produced by the schedule
          │   ┌─── The type of input consumed by the schedule
          │   │     ┌─── Additional requirements for the schedule
          ▼   ▼     ▼
Schedule<Out, In, Requirements>
```

A schedule operates by consuming values of type `In` (such as errors in the case of `retry`, or values in the case of `repeat`) and producing values of type `Out`. It determines when to halt or continue the execution based on input values and its internal state.

The inclusion of a `Requirements` parameter allows the schedule to leverage additional services or resources as needed.

Schedules are defined as a collection of intervals spread out over time. Each interval represents a window during which the recurrence of an effect is possible.

## Retrying and Repetition

In the realm of scheduling, there are two related concepts: [Retrying](/docs/error-management/retrying/) and [Repetition](/docs/scheduling/repetition/). While they share the same underlying idea, they differ in their focus. Retrying aims to handle failures by executing an effect again, while repetition focuses on executing an effect repeatedly to achieve a desired outcome.

When using schedules for retrying or repetition, each interval's starting boundary determines when the effect will be executed again. For example, in retrying, if an error occurs, the schedule defines when the effect should be retried.

## Composability of Schedules

Schedules are composable, meaning you can combine simple schedules to create more complex recurrence patterns. Operators like `Schedule.union` or `Schedule.intersect` allow you to build sophisticated schedules by combining and modifying existing ones. This flexibility enables you to tailor the scheduling behavior to meet specific requirements.


---

# [Built-In Schedules](https://effect.website/docs/scheduling/built-in-schedules/)

## Overview


To demonstrate the functionality of different schedules, we will use the following helper function
that logs each repetition along with the corresponding delay in milliseconds, formatted as:

```text
#<repetition>: <delay in ms>
```

**Helper** (Logging Execution Delays)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10 // Limit the number of executions
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..." // Indicate truncation if there are more executions
        : i === delays.length - 1
        ? "(end)" // Mark the last execution
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}
```

## Infinite and Fixed Repeats

### forever

A schedule that repeats indefinitely, producing the number of recurrences each time it runs.

**Example** (Indefinitely Recurring Schedule)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.forever

log(schedule)
/*
Output:
#1: 0ms < forever
#2: 0ms
#3: 0ms
#4: 0ms
#5: 0ms
#6: 0ms
#7: 0ms
#8: 0ms
#9: 0ms
#10: 0ms
...
*/
```

### once

A schedule that recurs only once.

**Example** (Single Recurrence Schedule)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.once

log(schedule)
/*
Output:
#1: 0ms < once
(end)
*/
```

### recurs

A schedule that repeats a specified number of times, producing the number of recurrences each time it runs.

**Example** (Fixed Number of Recurrences)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.recurs(5)

log(schedule)
/*
Output:
#1: 0ms < recurs
#2: 0ms
#3: 0ms
#4: 0ms
#5: 0ms
(end)
*/
```

## Recurring at specific intervals

You can define schedules that control the time between executions. The difference between `spaced` and `fixed` schedules lies in how the interval is measured:

- `spaced` delays each repetition from the **end** of the previous one.
- `fixed` ensures repetitions occur at **regular intervals**, regardless of execution time.

### spaced

A schedule that repeats indefinitely, each repetition spaced the specified duration from the last run.
It returns the number of recurrences each time it runs.

**Example** (Recurring with Delay Between Executions)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.spaced("200 millis")

//               ┌─── Simulating an effect that takes
//               │    100 milliseconds to complete
//               ▼
log(schedule, "100 millis")
/*
Output:
#1: 300ms < spaced
#2: 300ms
#3: 300ms
#4: 300ms
#5: 300ms
#6: 300ms
#7: 300ms
#8: 300ms
#9: 300ms
#10: 300ms
...
*/
```

The first delay is approximately 100 milliseconds, as the initial execution is not affected by the schedule. Subsequent delays are approximately 200 milliseconds apart, demonstrating the effect of the `spaced` schedule.

### fixed

A schedule that recurs at fixed intervals. It returns the number of recurrences each time it runs.
If the action run between updates takes longer than the interval, then the action will be run immediately, but re-runs will not "pile up".

```text
|-----interval-----|-----interval-----|-----interval-----|
|---------action--------|action-------|action------------|
```

**Example** (Fixed Interval Recurrence)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.fixed("200 millis")

//               ┌─── Simulating an effect that takes
//               │    100 milliseconds to complete
//               ▼
log(schedule, "100 millis")
/*
Output:
#1: 300ms < fixed
#2: 200ms
#3: 200ms
#4: 200ms
#5: 200ms
#6: 200ms
#7: 200ms
#8: 200ms
#9: 200ms
#10: 200ms
...
*/
```

## Increasing Delays Between Executions

### exponential

A schedule that recurs using exponential backoff, with each delay increasing exponentially.
Returns the current duration between recurrences.

**Example** (Exponential Backoff Schedule)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.exponential("10 millis")

log(schedule)
/*
Output:
#1: 10ms < exponential
#2: 20ms
#3: 40ms
#4: 80ms
#5: 160ms
#6: 320ms
#7: 640ms
#8: 1280ms
#9: 2560ms
#10: 5120ms
...
*/
```

### fibonacci

A schedule that always recurs, increasing delays by summing the preceding two delays (similar to the fibonacci sequence). Returns the current duration between recurrences.

**Example** (Fibonacci Delay Schedule)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.fibonacci("10 millis")

log(schedule)
/*
Output:
#1: 10ms < fibonacci
#2: 10ms
#3: 20ms
#4: 30ms
#5: 50ms
#6: 80ms
#7: 130ms
#8: 210ms
#9: 340ms
#10: 550ms
...
*/
```


---

# [Schedule Combinators](https://effect.website/docs/scheduling/schedule-combinators/)

## Overview


Schedules define stateful, possibly effectful, recurring schedules of events, and compose in a variety of ways. Combinators allow us to take schedules and combine them together to get other schedules.

To demonstrate the functionality of different schedules, we will use the following helper function
that logs each repetition along with the corresponding delay in milliseconds, formatted as:

```text
#<repetition>: <delay in ms>
```

**Helper** (Logging Execution Delays)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10 // Limit the number of executions
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..." // Indicate truncation if there are more executions
        : i === delays.length - 1
        ? "(end)" // Mark the last execution
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}
```

## Composition

Schedules can be composed in different ways:

| Mode             | Description                                                                                        |
| ---------------- | -------------------------------------------------------------------------------------------------- |
| **Union**        | Combines two schedules and recurs if either schedule wants to continue, using the shorter delay.   |
| **Intersection** | Combines two schedules and recurs only if both schedules want to continue, using the longer delay. |
| **Sequencing**   | Combines two schedules by running the first one fully, then switching to the second.               |

### Union

Combines two schedules and recurs if either schedule wants to continue, using the shorter delay.

**Example** (Combining Exponential and Spaced Intervals)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.union(
  Schedule.exponential("100 millis"),
  Schedule.spaced("1 second")
)

log(schedule)
/*
Output:
#1: 100ms  < exponential
#2: 200ms
#3: 400ms
#4: 800ms
#5: 1000ms < spaced
#6: 1000ms
#7: 1000ms
#8: 1000ms
#9: 1000ms
#10: 1000ms
...
*/
```

The `Schedule.union` operator selects the shortest delay at each step, so when combining an exponential schedule with a spaced interval, the initial recurrences will follow the exponential backoff, then settle into the spaced interval once the delays exceed that value.

### Intersection

Combines two schedules and recurs only if both schedules want to continue, using the longer delay.

**Example** (Limiting Exponential Backoff with a Fixed Number of Retries)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.intersect(
  Schedule.exponential("10 millis"),
  Schedule.recurs(5)
)

log(schedule)
/*
Output:
#1: 10ms  < exponential
#2: 20ms
#3: 40ms
#4: 80ms
#5: 160ms
(end)     < recurs
*/
```

The `Schedule.intersect` operator enforces both schedules' constraints. In this example, the schedule follows an exponential backoff but stops after 5 recurrences due to the `Schedule.recurs(5)` limit.

### Sequencing

Combines two schedules by running the first one fully, then switching to the second.

**Example** (Switching from Fixed Retries to Periodic Execution)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.andThen(
  Schedule.recurs(5),
  Schedule.spaced("1 second")
)

log(schedule)
/*
Output:
#1: 0ms    < recurs
#2: 0ms
#3: 0ms
#4: 0ms
#5: 0ms
#6: 1000ms < spaced
#7: 1000ms
#8: 1000ms
#9: 1000ms
#10: 1000ms
...
*/
```

The first schedule runs until completion, after which the second schedule takes over. In this example, the effect initially executes 5 times with no delay, then continues every 1 second.

## Adding Randomness to Retry Delays

The `Schedule.jittered` combinator modifies a schedule by applying a random delay within a specified range.

When a resource is out of service due to overload or contention, retrying and backing off doesn't help us. If all failed API calls are backed off to the same point of time, they cause another overload or contention. Jitter adds some amount of randomness to the delay of the schedule. This helps us to avoid ending up accidentally synchronizing and taking the service down by accident.

[Research](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/) suggests that `Schedule.jittered(0.0, 1.0)` is an effective way to introduce randomness in retries.

**Example** (Jittered Exponential Backoff)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.jittered(Schedule.exponential("10 millis"))

log(schedule)
/*
Output:
#1: 10.448486ms
#2: 21.134521ms
#3: 47.245117ms
#4: 88.263184ms
#5: 163.651367ms
#6: 335.818848ms
#7: 719.126709ms
#8: 1266.18457ms
#9: 2931.252441ms
#10: 6121.593018ms
...
*/
```

The `Schedule.jittered` combinator introduces randomness to delays within a range. For example, applying jitter to an exponential backoff ensures that each retry occurs at a slightly different time, reducing the risk of overwhelming the system.

## Controlling Repetitions with Filters

You can use `Schedule.whileInput` or `Schedule.whileOutput` to limit how long a schedule continues based on conditions applied to its input or output.

**Example** (Stopping Based on Output)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.whileOutput(Schedule.recurs(5), (n) => n <= 2)

log(schedule)
/*
Output:
#1: 0ms < recurs
#2: 0ms
#3: 0ms
(end)   < whileOutput
*/
```

`Schedule.whileOutput` filters repetitions based on the output of the schedule. In this example, the schedule stops once the output exceeds `2`, even though `Schedule.recurs(5)` allows up to 5 repetitions.

## Adjusting Delays Based on Output

The `Schedule.modifyDelay` combinator allows you to dynamically change the delay of a schedule based on the number of repetitions or other output conditions.

**Example** (Reducing Delay After a Certain Number of Repetitions)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.modifyDelay(
  Schedule.spaced("1 second"),
  (out, duration) => (out > 2 ? "100 millis" : duration)
)

log(schedule)
/*
Output:
#1: 1000ms
#2: 1000ms
#3: 1000ms
#4: 100ms  < modifyDelay
#5: 100ms
#6: 100ms
#7: 100ms
#8: 100ms
#9: 100ms
#10: 100ms
...
*/
```

The delay modification applies dynamically during execution. In this example, the first three repetitions follow the original `1-second` spacing. After that, the delay drops to `100 milliseconds`, making subsequent repetitions occur more frequently.

## Tapping

`Schedule.tapInput` and `Schedule.tapOutput` allow you to perform additional effectful operations on a schedule's input or output without modifying its behavior.

**Example** (Logging Schedule Outputs)

```ts

const log = (
  schedule: Schedule.Schedule<unknown>,
  delay: Duration.DurationInput = 0
): void => {
  const maxRecurs = 10
  const delays = Chunk.toArray(
    Effect.runSync(
      Schedule.run(
        Schedule.delays(Schedule.addDelay(schedule, () => delay)),
        Date.now(),
        Array.range(0, maxRecurs)
      )
    )
  )
  delays.forEach((duration, i) => {
    console.log(
      i === maxRecurs
        ? "..."
        : i === delays.length - 1
        ? "(end)"
        : `#${i + 1}: ${Duration.toMillis(duration)}ms`
    )
  })
}

const schedule = Schedule.tapOutput(Schedule.recurs(2), (n) =>
  Console.log(`Schedule Output: ${n}`)
)

log(schedule)
/*
Output:
Schedule Output: 0
Schedule Output: 1
Schedule Output: 2
#1: 0ms
#2: 0ms
(end)
*/
```

`Schedule.tapOutput` runs an effect before each recurrence, using the schedule's current output as input. This can be useful for logging, debugging, or triggering side effects.


---

# [Cron](https://effect.website/docs/scheduling/cron/)

## Overview


The Cron module lets you define schedules in a style similar to [UNIX cron expressions](https://en.wikipedia.org/wiki/Cron).
It also supports partial constraints (e.g., certain months or weekdays), time zone awareness through the [DateTime](/docs/data-types/datetime/) module, and robust error handling.

This module helps you:

- **Create** a `Cron` instance from individual parts.
- **Parse and validate** cron expressions.
- **Match** existing dates to see if they satisfy a given cron schedule.
- **Find** the next occurrence of a schedule after a given date.
- **Iterate** over future dates that match a schedule.
- **Convert** a `Cron` instance to a `Schedule` for use in effectful programs.

## Creating a Cron

You can define a cron schedule by specifying numeric constraints for seconds, minutes, hours, days, months, and weekdays. The `make` function requires you to define all fields representing the schedule's constraints.

**Example** (Creating a Cron)

```ts

// Build a cron that triggers at 4:00 AM
// on the 8th to the 14th of each month
const cron = Cron.make({
  seconds: [0], // Trigger at the start of a minute
  minutes: [0], // Trigger at the start of an hour
  hours: [4], // Trigger at 4:00 AM
  days: [8, 9, 10, 11, 12, 13, 14], // Specific days of the month
  months: [], // No restrictions on the month
  weekdays: [], // No restrictions on the weekday
  tz: DateTime.zoneUnsafeMakeNamed("Europe/Rome") // Optional time zone
})
```

- `seconds`, `minutes`, and `hours`: Define the time of day.
- `days` and `months`: Specify which calendar days and months are valid.
- `weekdays`: Restrict the schedule to specific days of the week.
- `tz`: Optionally define the time zone for the schedule.

If any field is left empty (e.g., `months`), it is treated as having "no constraints," allowing any valid value for that part of the date.

## Parsing Cron Expressions

Instead of manually constructing a `Cron`, you can use UNIX-like cron strings and parse them with `parse` or `unsafeParse`.

### parse

The `parse(cronExpression, tz?)` function safely parses a cron string into a `Cron` instance. It returns an [Either](/docs/data-types/either/), which will contain either the parsed `Cron` or a parsing error.

**Example** (Safely Parsing a Cron Expression)

```ts

// Define a cron expression for 4:00 AM
// on the 8th to the 14th of every month
const expression = "0 0 4 8-14 * *"

// Parse the cron expression
const eitherCron = Cron.parse(expression)

if (Either.isRight(eitherCron)) {
  // Successfully parsed
  console.log("Parsed cron:", eitherCron.right)
} else {
  // Parsing failed
  console.error("Failed to parse cron:", eitherCron.left.message)
}
```

### unsafeParse

The `unsafeParse(cronExpression, tz?)` function works like [parse](#parse), but instead of returning an [Either](/docs/data-types/either/), it throws an exception if the input is invalid.

**Example** (Parsing a Cron Expression)

```ts

// Parse a cron expression for 4:00 AM
// on the 8th to the 14th of every month
// Throws if the expression is invalid
const cron = Cron.unsafeParse("0 0 4 8-14 * *")
```

## Checking Dates with match

The `match` function allows you to determine if a given `Date` (or any [DateTime.Input](/docs/data-types/datetime/#the-datetimeinput-type)) satisfies the constraints of a cron schedule.

If the date meets the schedule's conditions, `match` returns `true`. Otherwise, it returns `false`.

**Example** (Checking if a Date Matches a Cron Schedule)

```ts

// Suppose we have a cron that triggers at 4:00 AM
// on the 8th to the 14th of each month
const cron = Cron.unsafeParse("0 0 4 8-14 * *")

const checkDate = new Date("2025-01-08 04:00:00")

console.log(Cron.match(cron, checkDate))
// Output: true
```

## Finding the Next Run

The `next` function determines the next date that satisfies a given cron schedule, starting from a specified date. If no starting date is provided, the current time is used as the starting point.

If `next` cannot find a matching date within a predefined number of iterations, it throws an error to prevent infinite loops.

**Example** (Determining the Next Matching Date)

```ts

// Define a cron expression for 4:00 AM
// on the 8th to the 14th of every month
const cron = Cron.unsafeParse("0 0 4 8-14 * *", "UTC")

// Specify the starting point for the search
const after = new Date("2025-01-08")

// Find the next matching date
const nextDate = Cron.next(cron, after)

console.log(nextDate)
// Output: 2025-01-08T04:00:00.000Z
```

## Iterating Over Future Dates

To generate multiple future dates that match a cron schedule, you can use the `sequence` function. This function provides an infinite iterator of matching dates, starting from a specified date.

**Example** (Generating Future Dates with an Iterator)

```ts

// Define a cron expression for 4:00 AM
// on the 8th to the 14th of every month
const cron = Cron.unsafeParse("0 0 4 8-14 * *", "UTC")

// Specify the starting date
const start = new Date("2021-01-08")

// Create an iterator for the schedule
const iterator = Cron.sequence(cron, start)

// Get the first matching date after the start date
console.log(iterator.next().value)
// Output: 2021-01-08T04:00:00.000Z

// Get the second matching date after the start date
console.log(iterator.next().value)
// Output: 2021-01-09T04:00:00.000Z
```

## Converting to Schedule

The Schedule module allows you to define recurring behaviors, such as retries or periodic events. The `cron` function bridges the `Cron` module with the Schedule module, enabling you to create schedules based on cron expressions or `Cron` instances.

### cron

The `Schedule.cron` function generates a [Schedule](/docs/scheduling/introduction/) that triggers at the start of each interval defined by the provided cron expression or `Cron` instance. When triggered, the schedule produces a tuple `[start, end]` representing the timestamps (in milliseconds) of the cron interval window.

**Example** (Creating a Schedule from a Cron)

```ts
import {
  Effect,
  Schedule,
  TestClock,
  Fiber,
  TestContext,
  Cron,
  Console
} from "effect"

// A helper function to log output at each interval of the schedule
const log = <A>(
  action: Effect.Effect<A>,
  schedule: Schedule.Schedule<[number, number], void>
): void => {
  let i = 0

  Effect.gen(function* () {
    const fiber: Fiber.RuntimeFiber<[[number, number], number]> =
      yield* Effect.gen(function* () {
        yield* action
        i++
      }).pipe(
        Effect.repeat(
          schedule.pipe(
            // Limit the number of iterations for the example
            Schedule.intersect(Schedule.recurs(10)),
            Schedule.tapOutput(([Out]) =>
              Console.log(
                i === 11 ? "..." : [new Date(Out[0]), new Date(Out[1])]
              )
            )
          )
        ),
        Effect.fork
      )
    yield* TestClock.adjust(Infinity)
    yield* Fiber.join(fiber)
  }).pipe(Effect.provide(TestContext.TestContext), Effect.runPromise)
}

// Build a cron that triggers at 4:00 AM
// on the 8th to the 14th of each month
const cron = Cron.unsafeParse("0 0 4 8-14 * *", "UTC")

// Convert the Cron into a Schedule
const schedule = Schedule.cron(cron)

// Define a dummy action to repeat
const action = Effect.void

// Log the schedule intervals
log(action, schedule)
/*
Output:
[ 1970-01-08T04:00:00.000Z, 1970-01-08T04:00:01.000Z ]
[ 1970-01-09T04:00:00.000Z, 1970-01-09T04:00:01.000Z ]
[ 1970-01-10T04:00:00.000Z, 1970-01-10T04:00:01.000Z ]
[ 1970-01-11T04:00:00.000Z, 1970-01-11T04:00:01.000Z ]
[ 1970-01-12T04:00:00.000Z, 1970-01-12T04:00:01.000Z ]
[ 1970-01-13T04:00:00.000Z, 1970-01-13T04:00:01.000Z ]
[ 1970-01-14T04:00:00.000Z, 1970-01-14T04:00:01.000Z ]
[ 1970-02-08T04:00:00.000Z, 1970-02-08T04:00:01.000Z ]
[ 1970-02-09T04:00:00.000Z, 1970-02-09T04:00:01.000Z ]
[ 1970-02-10T04:00:00.000Z, 1970-02-10T04:00:01.000Z ]
...
*/
```

> **Note: Using a Real Clock**
  In a real application, you do not need to use the `TestClock` or
  `TestContext`. These are only necessary for simulating time and
  controlling the execution in test environments.



---

# [Repetition](https://effect.website/docs/scheduling/repetition/)

## Overview


Repetition is a common requirement when working with effects in software development. It allows us to perform an effect multiple times according to a specific repetition policy.

## repeat

The `Effect.repeat` function returns a new effect that repeats the given effect according to a specified schedule or until the first failure.

> **Note: Initial Execution Included**
  The scheduled recurrences are in addition to the initial execution, so
  `Effect.repeat(action, Schedule.once)` executes `action` once initially,
  and if it succeeds, repeats it an additional time.


**Example** (Repeating a Successful Effect)

```ts

// Define an effect that logs a message to the console
const action = Console.log("success")

// Define a schedule that repeats the action 2 more times with a delay
const policy = Schedule.addDelay(Schedule.recurs(2), () => "100 millis")

// Repeat the action according to the schedule
const program = Effect.repeat(action, policy)

// Run the program and log the number of repetitions
Effect.runPromise(program).then((n) => console.log(`repetitions: ${n}`))
/*
Output:
success
success
success
repetitions: 2
*/
```

**Example** (Handling Failures in Repetition)

```ts

let count = 0

// Define an async effect that simulates an action with potential failure
const action = Effect.async<string, string>((resume) => {
  if (count > 1) {
    console.log("failure")
    resume(Effect.fail("Uh oh!"))
  } else {
    count++
    console.log("success")
    resume(Effect.succeed("yay!"))
  }
})

// Define a schedule that repeats the action 2 more times with a delay
const policy = Schedule.addDelay(Schedule.recurs(2), () => "100 millis")

// Repeat the action according to the schedule
const program = Effect.repeat(action, policy)

// Run the program and observe the result on failure
Effect.runPromiseExit(program).then(console.log)
/*
Output:
success
success
failure
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Uh oh!' }
}
*/
```

### Skipping First Execution

If you want to avoid the first execution and only run the action according to a schedule, you can use `Effect.schedule`. This allows the effect to skip the initial run and follow the defined repeat policy.

**Example** (Skipping First Execution)

```ts

const action = Console.log("success")

const policy = Schedule.addDelay(Schedule.recurs(2), () => "100 millis")

const program = Effect.schedule(action, policy)

Effect.runPromise(program).then((n) => console.log(`repetitions: ${n}`))
/*
Output:
success
success
repetitions: 2
*/
```

## repeatN

The `repeatN` function returns a new effect that repeats the specified effect a given number of times or until the first failure. The repeats are in addition to the initial execution, so `Effect.repeatN(action, 1)` executes `action` once initially and then repeats it one additional time if it succeeds.

**Example** (Repeating an Action Multiple Times)

```ts

const action = Console.log("success")

// Repeat the action 2 additional times after the first execution
const program = Effect.repeatN(action, 2)

Effect.runPromise(program)
/*
Output:
success
success
success
*/
```

## repeatOrElse

The `repeatOrElse` function returns a new effect that repeats the specified effect according to the given schedule or until the first failure.
When a failure occurs, the failure value and schedule output are passed to a specified handler.
Scheduled recurrences are in addition to the initial execution, so `Effect.repeat(action, Schedule.once)` executes `action` once initially and then repeats it an additional time if it succeeds.

**Example** (Handling Failure During Repeats)

```ts

let count = 0

// Define an async effect that simulates an action with possible failures
const action = Effect.async<string, string>((resume) => {
  if (count > 1) {
    console.log("failure")
    resume(Effect.fail("Uh oh!"))
  } else {
    count++
    console.log("success")
    resume(Effect.succeed("yay!"))
  }
})

// Define a schedule that repeats up to 2 times
// with a 100ms delay between attempts
const policy = Schedule.addDelay(Schedule.recurs(2), () => "100 millis")

// Provide a handler to run when failure occurs after the retries
const program = Effect.repeatOrElse(action, policy, () =>
  Effect.sync(() => {
    console.log("orElse")
    return count - 1
  })
)

Effect.runPromise(program).then((n) => console.log(`repetitions: ${n}`))
/*
Output:
success
success
failure
orElse
repetitions: 1
*/
```

## Repeating Based on a Condition

You can control the repetition of an effect by a condition using either a `while` or `until` option, allowing for dynamic control based on runtime outcomes.

**Example** (Repeating Until a Condition is Met)

```ts

let count = 0

// Define an effect that simulates varying outcomes on each invocation
const action = Effect.sync(() => {
  console.log(`Action called ${++count} time(s)`)
  return count
})

// Repeat the action until the count reaches 3
const program = Effect.repeat(action, { until: (n) => n === 3 })

Effect.runFork(program)
/*
Output:
Action called 1 time(s)
Action called 2 time(s)
Action called 3 time(s)
*/
```

> **Tip: Retrying on Errors**
  You can use
  [Effect.retry](/docs/error-management/retrying/#retrying-based-on-a-condition)
  if you need to set conditions based on error occurrences rather than
  success outcomes.



---

# [Examples](https://effect.website/docs/scheduling/examples/)

## Overview

These examples demonstrate different approaches to handling timeouts, retries, and periodic execution using Effect. Each scenario ensures that the application remains responsive and resilient to failures while adapting dynamically to various conditions.

## Handling Timeouts and Retries for API Calls

When calling third-party APIs, it is often necessary to enforce timeouts and implement retry mechanisms to handle transient failures. In this example, the API call retries up to two times in case of failure and will be interrupted if it takes longer than 4 seconds.

**Example** (Retrying an API Call with a Timeout)

```ts

// Function to make the API call
const getJson = (url: string) =>
  Effect.tryPromise(() =>
    fetch(url).then((res) => {
      if (!res.ok) {
        console.log("error")
        throw new Error(res.statusText)
      }
      console.log("ok")
      return res.json() as unknown
    })
  )

// Program that retries the API call twice, times out after 4 seconds,
// and logs errors
const program = (url: string) =>
  getJson(url).pipe(
    Effect.retry({ times: 2 }),
    Effect.timeout("4 seconds"),
    Effect.catchAll(Console.error)
  )

// Test case: successful API response
Effect.runFork(program("https://dummyjson.com/products/1?delay=1000"))
/*
Output:
ok
*/

// Test case: API call exceeding timeout limit
Effect.runFork(program("https://dummyjson.com/products/1?delay=5000"))
/*
Output:
TimeoutException: Operation timed out before the specified duration of '4s' elapsed
*/

// Test case: API returning an error response
Effect.runFork(program("https://dummyjson.com/auth/products/1?delay=500"))
/*
Output:
error
error
error
UnknownException: An unknown error occurred
*/
```

## Retrying API Calls Based on Specific Errors

Sometimes, retries should only happen for certain error conditions. For example, if an API call fails with a `401 Unauthorized` response, retrying might make sense, while a `404 Not Found` error should not trigger a retry.

**Example** (Retrying Only on Specific Error Codes)

```ts

// Custom error class for handling status codes
class Err extends Data.TaggedError("Err")<{
  readonly message: string
  readonly status: number
}> {}

// Function to make the API call
const getJson = (url: string) =>
  Effect.tryPromise({
    try: () =>
      fetch(url).then((res) => {
        if (!res.ok) {
          console.log(res.status)
          throw new Err({ message: res.statusText, status: res.status })
        }
        return res.json() as unknown
      }),
    catch: (e) => e as Err
  })

// Program that retries only when the error status is 401 (Unauthorized)
const program = (url: string) =>
  getJson(url).pipe(
    Effect.retry({ while: (err) => err.status === 401 }),
    Effect.catchAll(Console.error)
  )

// Test case: API returns 401 (triggers multiple retries)
Effect.runFork(
  program("https://dummyjson.com/auth/products/1?delay=1000")
)
/*
Output:
401
401
401
401
...
*/

// Test case: API returns 404 (no retries)
Effect.runFork(program("https://dummyjson.com/-"))
/*
Output:
404
Err [Error]: Not Found
*/
```

## Retrying with Dynamic Delays Based on Error Information

Some API errors, such as `429 Too Many Requests`, include a `Retry-After` header that specifies how long to wait before retrying. Instead of using a fixed delay, we can dynamically adjust the retry interval based on this value.

**Example** (Using the `Retry-After` Header for Retry Delays)

This approach ensures that the retry delay adapts dynamically to the server's response, preventing unnecessary retries while respecting the provided `Retry-After` value.

```ts

// Custom error class representing a "Too Many Requests" response
class TooManyRequestsError extends Data.TaggedError(
  "TooManyRequestsError"
)<{ readonly retryAfter: number }> {}

let n = 1
const request = Effect.gen(function* () {
  // Simulate failing a particular number of times
  if (n < 3) {
    const retryAfter = n * 500
    console.log(`Attempt #${n++}, retry after ${retryAfter} millis...`)
    // Simulate retrieving the retry-after header
    return yield* Effect.fail(new TooManyRequestsError({ retryAfter }))
  }
  console.log("Done")
  return "some result"
})

// Retry policy that extracts the retry delay from the error
const policy = Schedule.identity<TooManyRequestsError>().pipe(
  Schedule.addDelay((error) =>
    error._tag === "TooManyRequestsError"
      ? // Wait for the specified retry-after duration
        Duration.millis(error.retryAfter)
      : Duration.zero
  ),
  // Limit retries to 5 attempts
  Schedule.intersect(Schedule.recurs(5))
)

const program = request.pipe(Effect.retry(policy))

Effect.runFork(program)
/*
Output:
Attempt #1, retry after 500 millis...
Attempt #2, retry after 1000 millis...
Done
*/
```

## Running Periodic Tasks Until Another Task Completes

There are cases where we need to repeatedly perform an action at fixed intervals until another longer-running task finishes. This pattern is common in polling mechanisms or periodic logging.

**Example** (Running a Scheduled Task Until Completion)

```ts

// Define a long-running effect
// (e.g., a task that takes 5 seconds to complete)
const longRunningEffect = Console.log("done").pipe(
  Effect.delay("5 seconds")
)

// Define an action to run periodically
const action = Console.log("action...")

// Define a fixed interval schedule
const schedule = Schedule.fixed("1.5 seconds")

// Run the action repeatedly until the long-running task completes
const program = Effect.race(
  Effect.repeat(action, schedule),
  longRunningEffect
)

Effect.runPromise(program)
/*
Output:
action...
action...
action...
action...
done
*/
```


---


## Common Mistakes

**Incorrect (manual retry with setTimeout):**

```ts
async function retryFetch(url: string, attempts = 3): Promise<Response> {
  try { return await fetch(url) }
  catch (e) {
    if (attempts <= 0) throw e
    await new Promise((r) => setTimeout(r, 1000))
    return retryFetch(url, attempts - 1)
  }
}
```

**Correct (using Schedule for composable retry):**

```ts
const fetchWithRetry = Effect.retry(fetchUrl, {
  schedule: Schedule.exponential("100 millis").pipe(
    Schedule.compose(Schedule.recurs(3))
  )
})
```
