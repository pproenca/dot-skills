---
title: "Data Types"
impact: HIGH
impactDescription: "Enables type-safe data modeling — covers Option, Either, Cause, Chunk, DateTime, Duration, Data"
tags: data, data-types, option, either, chunk
---
# [Option](https://effect.website/docs/data-types/option/)

## Overview


The `Option` data type represents optional values. An `Option<A>` can either be `Some<A>`, containing a value of type `A`, or `None`, representing the absence of a value.

You can use `Option` in scenarios like:

- Using it for initial values
- Returning values from functions that are not defined for all possible inputs (referred to as "partial functions")
- Managing optional fields in data structures
- Handling optional function arguments

## Creating Options

### some

Use the `Option.some` constructor to create an `Option` that holds a value of type `A`.

**Example** (Creating an Option with a Value)

```ts

// An Option holding the number 1
const value = Option.some(1)

console.log(value)
// Output: { _id: 'Option', _tag: 'Some', value: 1 }
```

### none

Use the `Option.none` constructor to create an `Option` representing the absence of a value.

**Example** (Creating an Option with No Value)

```ts

// An Option holding no value
const noValue = Option.none()

console.log(noValue)
// Output: { _id: 'Option', _tag: 'None' }
```

### liftPredicate

You can create an `Option` based on a predicate, for example, to check if a value is positive.

**Example** (Using Explicit Option Creation)

Here's how you can achieve this using `Option.none` and `Option.some`:

```ts

const isPositive = (n: number) => n > 0

const parsePositive = (n: number): Option.Option<number> =>
  isPositive(n) ? Option.some(n) : Option.none()
```

**Example** (Using `Option.liftPredicate` for Conciseness)

Alternatively, you can simplify the above logic with `Option.liftPredicate`:

```ts

const isPositive = (n: number) => n > 0

//      ┌─── (b: number) => Option<number>
//      ▼
const parsePositive = Option.liftPredicate(isPositive)
```

## Modeling Optional Properties

Consider a `User` model where the `"email"` property is optional and can hold a `string` value. We use the `Option<string>` type to represent this optional property:

```ts {6} twoslash

interface User {
  readonly id: number
  readonly username: string
  readonly email: Option.Option<string>
}
```

> **Note: Property Key Always Present**
  Optionality only applies to the value of the property. The key `"email"`
  will always be present in the object, regardless of whether it has a
  value or not.


Here are examples of how to create `User` instances with and without an email:

**Example** (Creating Users with and without Email)

```ts

interface User {
  readonly id: number
  readonly username: string
  readonly email: Option.Option<string>
}

const withEmail: User = {
  id: 1,
  username: "john_doe",
  email: Option.some("john.doe@example.com")
}

const withoutEmail: User = {
  id: 2,
  username: "jane_doe",
  email: Option.none()
}
```

## Guards

You can check whether an `Option` is a `Some` or a `None` using the `Option.isSome` and `Option.isNone` guards.

**Example** (Using Guards to Check Option Values)

```ts

const foo = Option.some(1)

console.log(Option.isSome(foo))
// Output: true

if (Option.isNone(foo)) {
  console.log("Option is empty")
} else {
  console.log(`Option has a value: ${foo.value}`)
}
// Output: "Option has a value: 1"
```

## Pattern Matching

Use `Option.match` to handle both cases of an `Option` by specifying separate callbacks for `None` and `Some`.

**Example** (Pattern Matching with Option)

```ts

const foo = Option.some(1)

const message = Option.match(foo, {
  onNone: () => "Option is empty",
  onSome: (value) => `Option has a value: ${value}`
})

console.log(message)
// Output: "Option has a value: 1"
```

## Working with Option

### map

The `Option.map` function lets you transform the value inside an `Option` without manually unwrapping and re-wrapping it. If the `Option` holds a value (`Some`), the transformation function is applied. If the `Option` is `None`, the function is ignored, and the `Option` remains unchanged.

**Example** (Mapping a Value in Some)

```ts

// Transform the value inside Some
console.log(Option.map(Option.some(1), (n) => n + 1))
// Output: { _id: 'Option', _tag: 'Some', value: 2 }
```

When dealing with `None`, the mapping function is not executed, and the `Option` remains `None`:

**Example** (Mapping over None)

```ts

// Mapping over None results in None
console.log(Option.map(Option.none(), (n) => n + 1))
// Output: { _id: 'Option', _tag: 'None' }
```

### flatMap

The `Option.flatMap` function is similar to `Option.map`, but it is designed to handle cases where the transformation might return another `Option`. This allows us to chain computations that depend on whether or not a value is present in an `Option`.

Consider a `User` model that includes a nested optional `Address`, which itself contains an optional `street` property:

```ts

interface User {
  readonly id: number
  readonly username: string
  readonly email: Option.Option<string>
  readonly address: Option.Option<Address>
}

interface Address {
  readonly city: string
  readonly street: Option.Option<string>
}
```

In this model, the `address` field is an `Option<Address>`, and the `street` field within `Address` is an `Option<string>`.

We can use `Option.flatMap` to extract the `street` property from `address`:

**Example** (Extracting a Nested Optional Property)

```ts

interface Address {
  readonly city: string
  readonly street: Option.Option<string>
}

interface User {
  readonly id: number
  readonly username: string
  readonly email: Option.Option<string>
  readonly address: Option.Option<Address>
}

const user: User = {
  id: 1,
  username: "john_doe",
  email: Option.some("john.doe@example.com"),
  address: Option.some({
    city: "New York",
    street: Option.some("123 Main St")
  })
}

// Use flatMap to extract the street value
const street = user.address.pipe(
  Option.flatMap((address) => address.street)
)

console.log(street)
// Output: { _id: 'Option', _tag: 'Some', value: '123 Main St' }
```

If `user.address` is `Some`, `Option.flatMap` applies the function `(address) => address.street` to retrieve the `street` value.

If `user.address` is `None`, the function is not executed, and `street` remains `None`.

This approach lets us handle nested optional values concisely, avoiding manual checks and making the code cleaner and easier to read.

### filter

The `Option.filter` function allows you to filter an `Option` based on a given predicate. If the predicate is not met or if the `Option` is `None`, the result will be `None`.

**Example** (Filtering an Option Value)

Here's how you can simplify some code using `Option.filter` for a more idiomatic approach:

Original Code

```ts

// Function to remove empty strings from an Option
const removeEmptyString = (input: Option.Option<string>) => {
  if (Option.isSome(input) && input.value === "") {
    return Option.none() // Return None if the value is an empty string
  }
  return input // Otherwise, return the original Option
}

console.log(removeEmptyString(Option.none()))
// Output: { _id: 'Option', _tag: 'None' }

console.log(removeEmptyString(Option.some("")))
// Output: { _id: 'Option', _tag: 'None' }

console.log(removeEmptyString(Option.some("a")))
// Output: { _id: 'Option', _tag: 'Some', value: 'a' }
```

Refactored Idiomatic Code

Using `Option.filter`, we can write the same logic more concisely:

```ts

const removeEmptyString = (input: Option.Option<string>) =>
  Option.filter(input, (value) => value !== "")

console.log(removeEmptyString(Option.none()))
// Output: { _id: 'Option', _tag: 'None' }

console.log(removeEmptyString(Option.some("")))
// Output: { _id: 'Option', _tag: 'None' }

console.log(removeEmptyString(Option.some("a")))
// Output: { _id: 'Option', _tag: 'Some', value: 'a' }
```

## Getting the Value from an Option

To retrieve the value stored inside an `Option`, you can use several helper functions provided by the `Option` module. Here's an overview of the available methods:

### getOrThrow

This function extracts the value from a `Some`. If the `Option` is `None`, it throws an error.

**Example** (Retrieving Value or Throwing an Error)

```ts

console.log(Option.getOrThrow(Option.some(10)))
// Output: 10

console.log(Option.getOrThrow(Option.none()))
// throws: Error: getOrThrow called on a None
```

### getOrNull / getOrUndefined

These functions convert a `None` to either `null` or `undefined`, which is useful when working with non-`Option`-based code.

**Example** (Converting `None` to `null` or `undefined`)

```ts

console.log(Option.getOrNull(Option.some(5)))
// Output: 5

console.log(Option.getOrNull(Option.none()))
// Output: null

console.log(Option.getOrUndefined(Option.some(5)))
// Output: 5

console.log(Option.getOrUndefined(Option.none()))
// Output: undefined
```

### getOrElse

This function allows you to specify a default value to return when the `Option` is `None`.

**Example** (Providing a Default Value When `None`)

```ts

console.log(Option.getOrElse(Option.some(5), () => 0))
// Output: 5

console.log(Option.getOrElse(Option.none(), () => 0))
// Output: 0
```

## Fallback

### orElse

When a computation returns `None`, you might want to try an alternative computation that yields an `Option`. The `Option.orElse` function is helpful in such cases. It lets you chain multiple computations, moving on to the next if the current one results in `None`. This approach is often used in retry logic, attempting computations until one succeeds or all possibilities are exhausted.

**Example** (Attempting Alternative Computations)

```ts

// Simulating a computation that may or may not produce a result
const computation = (): Option.Option<number> =>
  Math.random() < 0.5 ? Option.some(10) : Option.none()

// Simulates an alternative computation
const alternativeComputation = (): Option.Option<number> =>
  Math.random() < 0.5 ? Option.some(20) : Option.none()

// Attempt the first computation, then try an alternative if needed
const program = computation().pipe(
  Option.orElse(() => alternativeComputation())
)

const result = Option.match(program, {
  onNone: () => "Both computations resulted in None",
  // At least one computation succeeded
  onSome: (value) => `Computed value: ${value}`
})

console.log(result)
// Output: Computed value: 10
```

### firstSomeOf

You can also use `Option.firstSomeOf` to get the first `Some` value from an iterable of `Option` values:

**Example** (Retrieving the First `Some` Value)

```ts

const first = Option.firstSomeOf([
  Option.none(),
  Option.some(2),
  Option.none(),
  Option.some(3)
])

console.log(first)
// Output: { _id: 'Option', _tag: 'Some', value: 2 }
```

## Interop with Nullable Types

When dealing with the `Option` data type, you may encounter code that uses `undefined` or `null` to represent optional values. The `Option` module provides several APIs to make interaction with these nullable types straightforward.

### fromNullable

`Option.fromNullable` converts a nullable value (`null` or `undefined`) into an `Option`. If the value is `null` or `undefined`, it returns `Option.none()`. Otherwise, it wraps the value in `Option.some()`.

**Example** (Creating Option from Nullable Values)

```ts

console.log(Option.fromNullable(null))
// Output: { _id: 'Option', _tag: 'None' }

console.log(Option.fromNullable(undefined))
// Output: { _id: 'Option', _tag: 'None' }

console.log(Option.fromNullable(1))
// Output: { _id: 'Option', _tag: 'Some', value: 1 }
```

If you need to convert an `Option` back to a nullable value, there are two helper methods:

- `Option.getOrNull`: Converts `None` to `null`.
- `Option.getOrUndefined`: Converts `None` to `undefined`.

## Interop with Effect

The `Option` type works as a subtype of the `Effect` type, allowing you to use it with functions from the `Effect` module. While these functions are built to handle `Effect` values, they can also manage `Option` values correctly.

### How Option Maps to Effect

| Option Variant | Mapped to Effect                        | Description                        |
| -------------- | --------------------------------------- | ---------------------------------- |
| `None`         | `Effect<never, NoSuchElementException>` | Represents the absence of a value  |
| `Some<A>`      | `Effect<A>`                             | Represents the presence of a value |

**Example** (Combining `Option` with `Effect`)

```ts

// Function to get the head of an array, returning Option
const head = <A>(array: ReadonlyArray<A>): Option.Option<A> =>
  array.length > 0 ? Option.some(array[0]) : Option.none()

// Simulated fetch function that returns Effect
const fetchData = (): Effect.Effect<string, string> => {
  const success = Math.random() > 0.5
  return success
    ? Effect.succeed("some data")
    : Effect.fail("Failed to fetch data")
}

// Mixing Either and Effect
const program = Effect.all([head([1, 2, 3]), fetchData()])

Effect.runPromise(program).then(console.log)
/*
Example Output:
[ 1, 'some data' ]
*/
```

## Combining Two or More Options

### zipWith

The `Option.zipWith` function lets you combine two `Option` values using a provided function. It creates a new `Option` that holds the combined value of both original `Option` values.

**Example** (Combining Two Options into an Object)

```ts

const maybeName: Option.Option<string> = Option.some("John")
const maybeAge: Option.Option<number> = Option.some(25)

// Combine the name and age into a person object
const person = Option.zipWith(maybeName, maybeAge, (name, age) => ({
  name: name.toUpperCase(),
  age
}))

console.log(person)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: { name: 'JOHN', age: 25 } }
*/
```

If either of the `Option` values is `None`, the result will be `None`:

**Example** (Handling None Values)

```ts {4} twoslash

const maybeName: Option.Option<string> = Option.some("John")
const maybeAge: Option.Option<number> = Option.none()

// Since maybeAge is a None, the result will also be None
const person = Option.zipWith(maybeName, maybeAge, (name, age) => ({
  name: name.toUpperCase(),
  age
}))

console.log(person)
// Output: { _id: 'Option', _tag: 'None' }
```

### all

To combine multiple `Option` values without transforming their contents, you can use `Option.all`. This function returns an `Option` with a structure matching the input:

- If you pass a tuple, the result will be a tuple of the same length.
- If you pass a struct, the result will be a struct with the same keys.
- If you pass an `Iterable`, the result will be an array.

**Example** (Combining Multiple Options into a Tuple and Struct)

```ts

const maybeName: Option.Option<string> = Option.some("John")
const maybeAge: Option.Option<number> = Option.some(25)

//      ┌─── Option<[string, number]>
//      ▼
const tuple = Option.all([maybeName, maybeAge])
console.log(tuple)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: [ 'John', 25 ] }
*/

//      ┌─── Option<{ name: string; age: number; }>
//      ▼
const struct = Option.all({ name: maybeName, age: maybeAge })
console.log(struct)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: { name: 'John', age: 25 } }
*/
```

If any of the `Option` values are `None`, the result will be `None`:

**Example**

```ts

const maybeName: Option.Option<string> = Option.some("John")
const maybeAge: Option.Option<number> = Option.none()

console.log(Option.all([maybeName, maybeAge]))
// Output: { _id: 'Option', _tag: 'None' }
```

## gen

Similar to [Effect.gen](/docs/getting-started/using-generators/), `Option.gen` provides a more readable, generator-based syntax for working with `Option` values, making code that involves `Option` easier to write and understand. This approach is similar to using `async/await` but tailored for `Option`.

**Example** (Using `Option.gen` to Create a Combined Value)

```ts

const maybeName: Option.Option<string> = Option.some("John")
const maybeAge: Option.Option<number> = Option.some(25)

const person = Option.gen(function* () {
  const name = (yield* maybeName).toUpperCase()
  const age = yield* maybeAge
  return { name, age }
})

console.log(person)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: { name: 'JOHN', age: 25 } }
*/
```

When any of the `Option` values in the sequence is `None`, the generator immediately returns the `None` value, skipping further operations:

**Example** (Handling a `None` Value with `Option.gen`)

In this example, `Option.gen` halts execution as soon as it encounters the `None` value, effectively propagating the missing value without performing further operations.

```ts

const maybeName: Option.Option<string> = Option.none()
const maybeAge: Option.Option<number> = Option.some(25)

const program = Option.gen(function* () {
  console.log("Retrieving name...")
  const name = (yield* maybeName).toUpperCase()
  console.log("Retrieving age...")
  const age = yield* maybeAge
  return { name, age }
})

console.log(program)
/*
Output:
Retrieving name...
{ _id: 'Option', _tag: 'None' }
*/
```

The use of `console.log` in these example is for demonstration purposes only. When using `Option.gen`, avoid including side effects in your generator functions, as `Option` should remain a pure data structure.

## Equivalence

You can compare `Option` values using the `Option.getEquivalence` function. This function allows you to specify how to compare the contents of `Option` types by providing an [Equivalence](/docs/behaviour/equivalence/) for the type of value they may contain.

**Example** (Comparing Optional Numbers for Equivalence)

Suppose you have optional numbers and want to check if they are equivalent. Here's how you can use `Option.getEquivalence`:

```ts

const myEquivalence = Option.getEquivalence(Equivalence.number)

console.log(myEquivalence(Option.some(1), Option.some(1)))
// Output: true, both options contain the number 1

console.log(myEquivalence(Option.some(1), Option.some(2)))
// Output: false, the numbers are different

console.log(myEquivalence(Option.some(1), Option.none()))
// Output: false, one is a number and the other is empty
```

## Sorting

You can sort a collection of `Option` values using the `Option.getOrder` function. This function helps specify a custom sorting rule for the type of value contained within the `Option`.

**Example** (Sorting Optional Numbers)

Suppose you have a list of optional numbers and want to sort them in ascending order, with empty values (`Option.none()`) treated as the lowest:

```ts

const items = [Option.some(1), Option.none(), Option.some(2)]

// Create an order for sorting Option values containing numbers
const myOrder = Option.getOrder(Order.number)

console.log(Array.sort(myOrder)(items))
/*
Output:
[
  { _id: 'Option', _tag: 'None' },           // None appears first because it's considered the lowest
  { _id: 'Option', _tag: 'Some', value: 1 }, // Sorted in ascending order
  { _id: 'Option', _tag: 'Some', value: 2 }
]
*/
```

**Example** (Sorting Optional Dates in Reverse Order)

Consider a more complex case where you have a list of objects containing optional dates, and you want to sort them in descending order, with `Option.none()` values at the end:

```ts

const items = [
  { data: Option.some(new Date(10)) },
  { data: Option.some(new Date(20)) },
  { data: Option.none() }
]

// Define the order to sort dates within Option values in reverse
const sorted = Array.sortWith(
  items,
  (item) => item.data,
  Order.reverse(Option.getOrder(Order.Date))
)

console.log(sorted)
/*
Output:
[
  { data: { _id: 'Option', _tag: 'Some', value: '1970-01-01T00:00:00.020Z' } },
  { data: { _id: 'Option', _tag: 'Some', value: '1970-01-01T00:00:00.010Z' } },
  { data: { _id: 'Option', _tag: 'None' } } // None placed last
]
*/
```


---

# [Either](https://effect.website/docs/data-types/either/)

## Overview


The `Either` data type represents two exclusive values: an `Either<R, L>` can be a `Right` value or a `Left` value, where `R` is the type of the `Right` value, and `L` is the type of the `Left` value.

## Understanding Either and Exit

Either is primarily used as a **simple discriminated union** and is not recommended as the main result type for operations requiring detailed error information.

[Exit](/docs/data-types/exit/) is the preferred **result type** within Effect for capturing comprehensive details about failures.
It encapsulates the outcomes of effectful computations, distinguishing between success and various failure modes, such as errors, defects and interruptions.

## Creating Eithers

You can create an `Either` using the `Either.right` and `Either.left` constructors.

Use `Either.right` to create a `Right` value of type `R`.

**Example** (Creating a Right Value)

```ts

const rightValue = Either.right(42)

console.log(rightValue)
/*
Output:
{ _id: 'Either', _tag: 'Right', right: 42 }
*/
```

Use `Either.left` to create a `Left` value of type `L`.

**Example** (Creating a Left Value)

```ts

const leftValue = Either.left("not a number")

console.log(leftValue)
/*
Output:
{ _id: 'Either', _tag: 'Left', left: 'not a number' }
*/
```

## Guards

Use `Either.isLeft` and `Either.isRight` to check whether an `Either` is a `Left` or `Right` value.

**Example** (Using Guards to Check the Type of Either)

```ts

const foo = Either.right(42)

if (Either.isLeft(foo)) {
  console.log(`The left value is: ${foo.left}`)
} else {
  console.log(`The Right value is: ${foo.right}`)
}
// Output: "The Right value is: 42"
```

## Pattern Matching

Use `Either.match` to handle both cases of an `Either` by specifying separate callbacks for `Left` and `Right`.

**Example** (Pattern Matching with Either)

```ts

const foo = Either.right(42)

const message = Either.match(foo, {
  onLeft: (left) => `The left value is: ${left}`,
  onRight: (right) => `The Right value is: ${right}`
})

console.log(message)
// Output: "The Right value is: 42"
```

## Mapping

### Mapping over the Right Value

Use `Either.map` to transform the `Right` value of an `Either`. The function you provide will only apply to the `Right` value, leaving any `Left` value unchanged.

**Example** (Transforming the Right Value)

```ts

// Transform the Right value by adding 1
const rightResult = Either.map(Either.right(1), (n) => n + 1)
console.log(rightResult)
/*
Output:
{ _id: 'Either', _tag: 'Right', right: 2 }
*/

// The transformation is ignored for Left values
const leftResult = Either.map(Either.left("not a number"), (n) => n + 1)
console.log(leftResult)
/*
Output:
{ _id: 'Either', _tag: 'Left', left: 'not a number' }
*/
```

### Mapping over the Left Value

Use `Either.mapLeft` to transform the `Left` value of an `Either`. The provided function only applies to the `Left` value, leaving any `Right` value unchanged.

**Example** (Transforming the Left Value)

```ts

// The transformation is ignored for Right values
const rightResult = Either.mapLeft(Either.right(1), (s) => s + "!")
console.log(rightResult)
/*
Output:
{ _id: 'Either', _tag: 'Right', right: 1 }
*/

// Transform the Left value by appending "!"
const leftResult = Either.mapLeft(
  Either.left("not a number"),
  (s) => s + "!"
)
console.log(leftResult)
/*
Output:
{ _id: 'Either', _tag: 'Left', left: 'not a number!' }
*/
```

### Mapping over Both Values

Use `Either.mapBoth` to transform both the `Left` and `Right` values of an `Either`. This function takes two separate transformation functions: one for the `Left` value and another for the `Right` value.

**Example** (Transforming Both Left and Right Values)

```ts

const transformedRight = Either.mapBoth(Either.right(1), {
  onLeft: (s) => s + "!",
  onRight: (n) => n + 1
})
console.log(transformedRight)
/*
Output:
{ _id: 'Either', _tag: 'Right', right: 2 }
*/

const transformedLeft = Either.mapBoth(Either.left("not a number"), {
  onLeft: (s) => s + "!",
  onRight: (n) => n + 1
})
console.log(transformedLeft)
/*
Output:
{ _id: 'Either', _tag: 'Left', left: 'not a number!' }
*/
```

## Interop with Effect

The `Either` type works as a subtype of the `Effect` type, allowing you to use it with functions from the `Effect` module. While these functions are built to handle `Effect` values, they can also manage `Either` values correctly.

### How Either Maps to Effect

| Either Variant | Mapped to Effect   | Description          |
| -------------- | ------------------ | -------------------- |
| `Left<L>`      | `Effect<never, L>` | Represents a failure |
| `Right<R>`     | `Effect<R>`        | Represents a success |

**Example** (Combining `Either` with `Effect`)

```ts

// Function to get the head of an array, returning Either
const head = <A>(array: ReadonlyArray<A>): Either.Either<A, string> =>
  array.length > 0 ? Either.right(array[0]) : Either.left("empty array")

// Simulated fetch function that returns Effect
const fetchData = (): Effect.Effect<string, string> => {
  const success = Math.random() > 0.5
  return success
    ? Effect.succeed("some data")
    : Effect.fail("Failed to fetch data")
}

// Mixing Either and Effect
const program = Effect.all([head([1, 2, 3]), fetchData()])

Effect.runPromise(program).then(console.log)
/*
Example Output:
[ 1, 'some data' ]
*/
```

## Combining Two or More Eithers

### zipWith

The `Either.zipWith` function lets you combine two `Either` values using a provided function. It creates a new `Either` that holds the combined value of both original `Either` values.

**Example** (Combining Two Eithers into an Object)

```ts

const maybeName: Either.Either<string, string> = Either.right("John")
const maybeAge: Either.Either<number, string> = Either.right(25)

// Combine the name and age into a person object
const person = Either.zipWith(maybeName, maybeAge, (name, age) => ({
  name: name.toUpperCase(),
  age
}))

console.log(person)
/*
Output:
{ _id: 'Either', _tag: 'Right', right: { name: 'JOHN', age: 25 } }
*/
```

If either of the `Either` values is `Left`, the result will be `Left`, holding the first encountered `Left` value:

**Example** (Combining Eithers with a Left Value)

```ts

const maybeName: Either.Either<string, string> = Either.right("John")
const maybeAge: Either.Either<number, string> = Either.left("Oh no!")

// Since maybeAge is a Left, the result will also be Left
const person = Either.zipWith(maybeName, maybeAge, (name, age) => ({
  name: name.toUpperCase(),
  age
}))

console.log(person)
/*
Output:
{ _id: 'Either', _tag: 'Left', left: 'Oh no!' }
*/
```

### all

To combine multiple `Either` values without transforming their contents, you can use `Either.all`. This function returns an `Either` with a structure matching the input:

- If you pass a tuple, the result will be a tuple of the same length.
- If you pass a struct, the result will be a struct with the same keys.
- If you pass an `Iterable`, the result will be an array.

**Example** (Combining Multiple Eithers into a Tuple and Struct)

```ts

const maybeName: Either.Either<string, string> = Either.right("John")
const maybeAge: Either.Either<number, string> = Either.right(25)

//      ┌─── Either<[string, number], string>
//      ▼
const tuple = Either.all([maybeName, maybeAge])
console.log(tuple)
/*
Output:
{ _id: 'Either', _tag: 'Right', right: [ 'John', 25 ] }
*/

//      ┌─── Either<{ name: string; age: number; }, string>
//      ▼
const struct = Either.all({ name: maybeName, age: maybeAge })
console.log(struct)
/*
Output:
{ _id: 'Either', _tag: 'Right', right: { name: 'John', age: 25 } }
*/
```

If one or more `Either` values are `Left`, the first `Left` encountered is returned:

**Example** (Handling Multiple Left Values)

```ts

const maybeName: Either.Either<string, string> =
  Either.left("name not found")
const maybeAge: Either.Either<number, string> =
  Either.left("age not found")

// The first Left value will be returned
console.log(Either.all([maybeName, maybeAge]))
/*
Output:
{ _id: 'Either', _tag: 'Left', left: 'name not found' }
*/
```

## gen

Similar to [Effect.gen](/docs/getting-started/using-generators/), `Either.gen` provides a more readable, generator-based syntax for working with `Either` values, making code that involves `Either` easier to write and understand. This approach is similar to using `async/await` but tailored for `Either`.

**Example** (Using `Either.gen` to Create a Combined Value)

```ts

const maybeName: Either.Either<string, string> = Either.right("John")
const maybeAge: Either.Either<number, string> = Either.right(25)

const program = Either.gen(function* () {
  const name = (yield* maybeName).toUpperCase()
  const age = yield* maybeAge
  return { name, age }
})

console.log(program)
/*
Output:
{ _id: 'Either', _tag: 'Right', right: { name: 'JOHN', age: 25 } }
*/
```

When any of the `Either` values in the sequence is `Left`, the generator immediately returns the `Left` value, skipping further operations:

**Example** (Handling a `Left` Value with `Either.gen`)

In this example, `Either.gen` halts execution as soon as it encounters the `Left` value, effectively propagating the error without performing further operations.

```ts

const maybeName: Either.Either<string, string> = Either.left("Oh no!")
const maybeAge: Either.Either<number, string> = Either.right(25)

const program = Either.gen(function* () {
  console.log("Retrieving name...")
  const name = (yield* maybeName).toUpperCase()
  console.log("Retrieving age...")
  const age = yield* maybeAge
  return { name, age }
})

console.log(program)
/*
Output:
Retrieving name...
{ _id: 'Either', _tag: 'Left', left: 'Oh no!' }
*/
```

The use of `console.log` in these example is for demonstration purposes only. When using `Either.gen`, avoid including side effects in your generator functions, as `Either` should remain a pure data structure.


---

# [Cause](https://effect.website/docs/data-types/cause/)

## Overview

The [`Effect<A, E, R>`](/docs/getting-started/the-effect-type/) type is polymorphic in error type `E`, allowing flexibility in handling any desired error type. However, there is often additional information about failures that the error type `E` alone does not capture.

To address this, Effect uses the `Cause<E>` data type to store various details such as:

- Unexpected errors or defects
- Stack and execution traces
- Reasons for fiber interruptions

Effect strictly preserves all failure-related information, storing a full picture of the error context in the `Cause` type. This comprehensive approach enables precise analysis and handling of failures, ensuring no data is lost.

Though `Cause` values aren't typically manipulated directly, they underlie errors within Effect workflows, providing access to both concurrent and sequential error details. This allows for thorough error analysis when needed.

## Creating Causes

You can intentionally create an effect with a specific cause using `Effect.failCause`.

**Example** (Defining Effects with Different Causes)

```ts

// Define an effect that dies with an unexpected error
//
//      ┌─── Effect<never, never, never>
//      ▼
const die = Effect.failCause(Cause.die("Boom!"))

// Define an effect that fails with an expected error
//
//      ┌─── Effect<never, string, never>
//      ▼
const fail = Effect.failCause(Cause.fail("Oh no!"))
```

Some causes do not influence the error type of the effect, leading to `never` in the error channel:

```text
                ┌─── no error information
                ▼
Effect<never, never, never>
```

For instance, `Cause.die` does not specify an error type for the effect, while `Cause.fail` does, setting the error channel type accordingly.

## Cause Variations

There are several causes for various errors, in this section, we will describe each of these causes.

### Empty

The `Empty` cause signifies the absence of any errors.

### Fail

The `Fail<E>` cause represents a failure due to an expected error of type `E`.

### Die

The `Die` cause indicates a failure resulting from a defect, which is an unexpected or unintended error.

### Interrupt

The `Interrupt` cause represents a failure due to `Fiber` interruption and contains the `FiberId` of the interrupted `Fiber`.

### Sequential

The `Sequential` cause combines two causes that occurred one after the other.

For example, in an `Effect.ensuring` operation (analogous to `try-finally`), if both the `try` and `finally` sections fail, the two errors are represented in sequence by a `Sequential` cause.

**Example** (Capturing Sequential Failures with a `Sequential` Cause)

```ts

const program = Effect.failCause(Cause.fail("Oh no!")).pipe(
  Effect.ensuring(Effect.failCause(Cause.die("Boom!")))
)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Sequential',
    left: { _id: 'Cause', _tag: 'Fail', failure: 'Oh no!' },
    right: { _id: 'Cause', _tag: 'Die', defect: 'Boom!' }
  }
}
*/
```

### Parallel

The `Parallel` cause combines two causes that occurred concurrently.

In Effect programs, two operations may run in parallel, potentially leading to multiple failures. When both computations fail simultaneously, a `Parallel` cause represents the concurrent errors within the effect workflow.

**Example** (Capturing Concurrent Failures with a `Parallel` Cause)

```ts

const program = Effect.all(
  [
    Effect.failCause(Cause.fail("Oh no!")),
    Effect.failCause(Cause.die("Boom!"))
  ],
  { concurrency: 2 }
)

Effect.runPromiseExit(program).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Parallel',
    left: { _id: 'Cause', _tag: 'Fail', failure: 'Oh no!' },
    right: { _id: 'Cause', _tag: 'Die', defect: 'Boom!' }
  }
}
*/
```

## Retrieving the Cause of an Effect

To retrieve the cause of a failed effect, use `Effect.cause`. This allows you to inspect or handle the exact reason behind the failure.

**Example** (Retrieving and Inspecting a Failure Cause)

```ts

const program = Effect.gen(function* () {
  const cause = yield* Effect.cause(Effect.fail("Oh no!"))
  console.log(cause)
})

Effect.runPromise(program)
/*
Output:
{ _id: 'Cause', _tag: 'Fail', failure: 'Oh no!' }
*/
```

## Guards

To determine the specific type of a `Cause`, use the guards provided in the Cause module:

- `Cause.isEmpty`: Checks if the cause is empty, indicating no error.
- `Cause.isFailType`: Identifies causes that represent an expected failure.
- `Cause.isDie`: Identifies causes that represent an unexpected defect.
- `Cause.isInterruptType`: Identifies causes related to fiber interruptions.
- `Cause.isSequentialType`: Checks if the cause consists of sequential errors.
- `Cause.isParallelType`: Checks if the cause contains parallel errors.

**Example** (Using Guards to Identify Cause Types)

```ts

const cause = Cause.fail(new Error("my message"))

if (Cause.isFailType(cause)) {
  console.log(cause.error.message) // Output: my message
}
```

These guards allow you to accurately identify the type of a `Cause`, making it easier to handle various error cases in your code. Whether dealing with expected failures, unexpected defects, interruptions, or composite errors, these guards provide a clear method for assessing and managing error scenarios.

## Pattern Matching

The `Cause.match` function provides a straightforward way to handle each case of a `Cause`. By defining callbacks for each possible cause type, you can respond to specific error scenarios with custom behavior.

**Example** (Pattern Matching on Different Causes)

```ts

const cause = Cause.parallel(
  Cause.fail(new Error("my fail message")),
  Cause.die("my die message")
)

console.log(
  Cause.match(cause, {
    onEmpty: "(empty)",
    onFail: (error) => `(error: ${error.message})`,
    onDie: (defect) => `(defect: ${defect})`,
    onInterrupt: (fiberId) => `(fiberId: ${fiberId})`,
    onSequential: (left, right) =>
      `(onSequential (left: ${left}) (right: ${right}))`,
    onParallel: (left, right) =>
      `(onParallel (left: ${left}) (right: ${right})`
  })
)
/*
Output:
(onParallel (left: (error: my fail message)) (right: (defect: my die message))
*/
```

## Pretty Printing

Clear and readable error messages are key for effective debugging. The `Cause.pretty` function helps by formatting error messages in a structured way, making it easier to understand failure details.

**Example** (Using `Cause.pretty` for Readable Error Messages)

```ts

console.log(Cause.pretty(Cause.empty))
/*
Output:
All fibers interrupted without errors.
*/

console.log(Cause.pretty(Cause.fail(new Error("my fail message"))))
/*
Output:
Error: my fail message
    ...stack trace...
*/

console.log(Cause.pretty(Cause.die("my die message")))
/*
Output:
Error: my die message
*/

console.log(Cause.pretty(Cause.interrupt(FiberId.make(1, 0))))
/*
Output:
All fibers interrupted without errors.
*/

console.log(
  Cause.pretty(Cause.sequential(Cause.fail("fail1"), Cause.fail("fail2")))
)
/*
Output:
Error: fail1
Error: fail2
*/
```

## Retrieval of Failures and Defects

To specifically collect failures or defects from a `Cause`, you can use `Cause.failures` and `Cause.defects`. These functions allow you to inspect only the errors or unexpected defects that occurred.

**Example** (Extracting Failures and Defects from a Cause)

```ts

const program = Effect.gen(function* () {
  const cause = yield* Effect.cause(
    Effect.all([
      Effect.fail("error 1"),
      Effect.die("defect"),
      Effect.fail("error 2")
    ])
  )
  console.log(Cause.failures(cause))
  console.log(Cause.defects(cause))
})

Effect.runPromise(program)
/*
Output:
{ _id: 'Chunk', values: [ 'error 1' ] }
{ _id: 'Chunk', values: [] }
*/
```


---

# [Chunk](https://effect.website/docs/data-types/chunk/)

## Overview


A `Chunk<A>` represents an ordered, immutable collection of values of type `A`. While similar to an array, `Chunk` provides a functional interface, optimizing certain operations that can be costly with regular arrays, like repeated concatenation.

> **Caution: Use Chunk Only for Repeated Concatenation**
  `Chunk` is optimized to manage the performance cost of repeated array
  concatenation. For cases that do not involve repeated concatenation,
  using `Chunk` may introduce unnecessary overhead, resulting in slower
  performance.


## Why Use Chunk?

- **Immutability**: Unlike standard JavaScript arrays, which are mutable, `Chunk` provides a truly immutable collection, preventing data from being modified after creation. This is especially useful in concurrent programming contexts where immutability can enhance data consistency.

- **High Performance**: `Chunk` supports specialized operations for efficient array manipulation, such as appending single elements or concatenating chunks, making these operations faster than their regular JavaScript array equivalents.

## Creating a Chunk

### empty

Create an empty `Chunk` with `Chunk.empty`.

**Example** (Creating an Empty Chunk)

```ts

//      ┌─── Chunk<number>
//      ▼
const chunk = Chunk.empty<number>()
```

### make

To create a `Chunk` with specific values, use `Chunk.make(...values)`. Note that the resulting chunk is typed as non-empty.

**Example** (Creating a Non-Empty Chunk)

```ts

//      ┌─── NonEmptyChunk<number>
//      ▼
const chunk = Chunk.make(1, 2, 3)
```

### fromIterable

You can create a `Chunk` by providing a collection, either from an iterable or directly from an array.

**Example** (Creating a Chunk from an Iterable)

```ts

const fromArray = Chunk.fromIterable([1, 2, 3])

const fromList = Chunk.fromIterable(List.make(1, 2, 3))
```

> **Caution: Performance Consideration**
  `Chunk.fromIterable` creates a new copy of the iterable's elements. For
  large data sets or repeated use, this cloning process can impact
  performance.


### unsafeFromArray

`Chunk.unsafeFromArray` creates a `Chunk` directly from an array without cloning. This approach can improve performance by avoiding the overhead of copying data but requires caution, as it bypasses the usual immutability guarantees.

**Example** (Directly Creating a Chunk from an Array)

```ts

const chunk = Chunk.unsafeFromArray([1, 2, 3])
```

> **Caution: Risk of Mutable Data**
  Using `Chunk.unsafeFromArray` can lead to unexpected behavior if the
  original array is modified after the chunk is created. For safer,
  immutable behavior, use `Chunk.fromIterable` instead.


## Concatenating

To combine two `Chunk` instances into one, use `Chunk.appendAll`.

**Example** (Combining Two Chunks into One)

```ts

// Concatenate two chunks with different types of elements
//
//      ┌─── NonEmptyChunk<string | number>
//      ▼
const chunk = Chunk.appendAll(Chunk.make(1, 2), Chunk.make("a", "b"))

console.log(chunk)
/*
Output:
{ _id: 'Chunk', values: [ 1, 2, 'a', 'b' ] }
*/
```

## Dropping

To remove elements from the beginning of a `Chunk`, use `Chunk.drop`, specifying the number of elements to discard.

**Example** (Dropping Elements from the Start)

```ts

// Drops the first 2 elements from the Chunk
const chunk = Chunk.drop(Chunk.make(1, 2, 3, 4), 2)
```

## Comparing

To check if two `Chunk` instances are equal, use [`Equal.equals`](/docs/trait/equal/). This function compares the contents of each `Chunk` for structural equality.

**Example** (Comparing Two Chunks)

```ts

const chunk1 = Chunk.make(1, 2)
const chunk2 = Chunk.make(1, 2, 3)

console.log(Equal.equals(chunk1, chunk1))
// Output: true

console.log(Equal.equals(chunk1, chunk2))
// Output: false

console.log(Equal.equals(chunk1, Chunk.make(1, 2)))
// Output: true
```

## Converting

Convert a `Chunk` to a `ReadonlyArray` using `Chunk.toReadonlyArray`. The resulting type varies based on the `Chunk`'s contents, distinguishing between empty, non-empty, and generic chunks.

**Example** (Converting a Chunk to a ReadonlyArray)

```ts

//      ┌─── readonly [number, ...number[]]
//      ▼
const nonEmptyArray = Chunk.toReadonlyArray(Chunk.make(1, 2, 3))

//      ┌─── readonly never[]
//      ▼
const emptyArray = Chunk.toReadonlyArray(Chunk.empty())

declare const chunk: Chunk.Chunk<number>

//      ┌─── readonly number[]
//      ▼
const array = Chunk.toReadonlyArray(chunk)
```


---

# [Data](https://effect.website/docs/data-types/data/)

## Overview


The Data module simplifies creating and handling data structures in TypeScript. It provides tools for **defining data types**, ensuring **equality** between objects, and **hashing** data for efficient comparisons.

## Value Equality

The Data module provides constructors for creating data types with built-in support for equality and hashing, eliminating the need for custom implementations.

This means that two values created using these constructors are considered equal if they have the same structure and values.

### struct

In plain JavaScript, objects are considered equal only if they refer to the exact same instance.

**Example** (Comparing Two Objects in Plain JavaScript)

```ts
const alice = { name: "Alice", age: 30 }

// This comparison is false because they are different instances
// @errors: 2839
console.log(alice === { name: "Alice", age: 30 }) // Output: false
```

However, the `Data.struct` constructor allows you to compare values based on their structure and content.

**Example** (Creating and Checking Equality of Structs)

```ts

//      ┌─── { readonly name: string; readonly age: number; }
//      ▼
const alice = Data.struct({ name: "Alice", age: 30 })

// Check if Alice is equal to a new object
// with the same structure and values
console.log(Equal.equals(alice, Data.struct({ name: "Alice", age: 30 })))
// Output: true

// Check if Alice is equal to a plain JavaScript object
// with the same content
console.log(Equal.equals(alice, { name: "Alice", age: 30 }))
// Output: false
```

The comparison performed by `Equal.equals` is **shallow**, meaning nested objects are not compared recursively unless they are also created using `Data.struct`.

**Example** (Shallow Comparison with Nested Objects)

```ts

const nested = Data.struct({ name: "Alice", nested_field: { value: 42 } })

// This will be false because the nested objects are compared by reference
console.log(
  Equal.equals(
    nested,
    Data.struct({ name: "Alice", nested_field: { value: 42 } })
  )
)
// Output: false
```

To ensure nested objects are compared by structure, use `Data.struct` for them as well.

**Example** (Correctly Comparing Nested Objects)

```ts

const nested = Data.struct({
  name: "Alice",
  nested_field: Data.struct({ value: 42 })
})

// Now, the comparison returns true
console.log(
  Equal.equals(
    nested,
    Data.struct({
      name: "Alice",
      nested_field: Data.struct({ value: 42 })
    })
  )
)
// Output: true
```

### tuple

To represent your data using tuples, you can use the `Data.tuple` constructor. This ensures that your tuples can be compared structurally.

**Example** (Creating and Checking Equality of Tuples)

```ts

//      ┌─── readonly [string, number]
//      ▼
const alice = Data.tuple("Alice", 30)

// Check if Alice is equal to a new tuple
// with the same structure and values
console.log(Equal.equals(alice, Data.tuple("Alice", 30)))
// Output: true

// Check if Alice is equal to a plain JavaScript tuple
// with the same content
console.log(Equal.equals(alice, ["Alice", 30]))
// Output: false
```

> **Caution: Shallow Comparison**
  `Equal.equals` only checks the top-level structure. Use `Data`
  constructors for nested objects if you need deep comparisons.


### array

You can use `Data.array` to create an array-like data structure that supports structural equality.

**Example** (Creating and Checking Equality of Arrays)

```ts

//      ┌─── readonly number[]
//      ▼
const numbers = Data.array([1, 2, 3, 4, 5])

// Check if the array is equal to a new array
// with the same values
console.log(Equal.equals(numbers, Data.array([1, 2, 3, 4, 5])))
// Output: true

// Check if the array is equal to a plain JavaScript array
// with the same content
console.log(Equal.equals(numbers, [1, 2, 3, 4, 5]))
// Output: false
```

> **Caution: Shallow Comparison**
  `Equal.equals` only checks the top-level structure. Use `Data`
  constructors for nested objects if you need deep comparisons.


## Constructors

The module introduces a concept known as "Case classes", which automate various essential operations when defining data types.
These operations include generating **constructors**, handling **equality** checks, and managing **hashing**.

Case classes can be defined in two primary ways:

- as plain objects using `case` or `tagged`
- as TypeScript classes using `Class` or `TaggedClass`

### case

The `Data.case` helper generates constructors and built-in support for equality checks and hashing for your data type.

**Example** (Defining a Case Class and Checking Equality)

In this example, `Data.case` is used to create a constructor for `Person`. The resulting instances have built-in support for equality checks, allowing you to compare them directly using `Equal.equals`.

```ts

interface Person {
  readonly name: string
}

// Create a constructor for `Person`
//
//      ┌─── (args: { readonly name: string; }) => Person
//      ▼
const make = Data.case<Person>()

const alice = make({ name: "Alice" })

console.log(Equal.equals(alice, make({ name: "Alice" })))
// Output: true

console.log(Equal.equals(alice, make({ name: "John" })))
// Output: false
```

**Example** (Defining and Comparing Nested Case Classes)

This example demonstrates using `Data.case` to create nested data structures, such as a `Person` type containing an `Address`. Both `Person` and `Address` constructors support equality checks.

```ts

interface Address {
  readonly street: string
  readonly city: string
}

// Create a constructor for `Address`
const Address = Data.case<Address>()

interface Person {
  readonly name: string
  readonly address: Address
}

// Create a constructor for `Person`
const Person = Data.case<Person>()

const alice = Person({
  name: "Alice",
  address: Address({ street: "123 Main St", city: "Wonderland" })
})

const anotherAlice = Person({
  name: "Alice",
  address: Address({ street: "123 Main St", city: "Wonderland" })
})

console.log(Equal.equals(alice, anotherAlice))
// Output: true
```

Alternatively, you can use `Data.struct` to create nested data structures without defining a separate `Address` constructor.

**Example** (Using `Data.struct` for Nested Objects)

```ts

interface Person {
  readonly name: string
  readonly address: {
    readonly street: string
    readonly city: string
  }
}

// Create a constructor for `Person`
const Person = Data.case<Person>()

const alice = Person({
  name: "Alice",
  address: Data.struct({ street: "123 Main St", city: "Wonderland" })
})

const anotherAlice = Person({
  name: "Alice",
  address: Data.struct({ street: "123 Main St", city: "Wonderland" })
})

console.log(Equal.equals(alice, anotherAlice))
// Output: true
```

**Example** (Defining and Comparing Recursive Case Classes)

This example demonstrates a recursive structure using `Data.case` to define a binary tree where each node can contain other nodes.

```ts

interface BinaryTree<T> {
  readonly value: T
  readonly left: BinaryTree<T> | null
  readonly right: BinaryTree<T> | null
}

// Create a constructor for `BinaryTree`
const BinaryTree = Data.case<BinaryTree<number>>()

const tree1 = BinaryTree({
  value: 0,
  left: BinaryTree({ value: 1, left: null, right: null }),
  right: null
})

const tree2 = BinaryTree({
  value: 0,
  left: BinaryTree({ value: 1, left: null, right: null }),
  right: null
})

console.log(Equal.equals(tree1, tree2))
// Output: true
```

### tagged

When you're working with a data type that includes a tag field, like in disjoint union types, defining the tag manually for each instance can get repetitive. Using the `case` approach requires you to specify the tag field every time, which can be cumbersome.

**Example** (Defining a Tagged Case Class Manually)

Here, we create a `Person` type with a `_tag` field using `Data.case`. Notice that the `_tag` needs to be specified for every new instance.

```ts

interface Person {
  readonly _tag: "Person" // the tag
  readonly name: string
}

const Person = Data.case<Person>()

// Repeating `_tag: 'Person'` for each instance
const alice = Person({ _tag: "Person", name: "Alice" })
const bob = Person({ _tag: "Person", name: "Bob" })
```

To streamline this process, the `Data.tagged` helper automatically adds the tag. It follows the convention in the Effect ecosystem of naming the tag field as `"_tag"`.

**Example** (Using Data.tagged to Simplify Tagging)

The `Data.tagged` helper allows you to define the tag just once, making instance creation simpler.

```ts

interface Person {
  readonly _tag: "Person" // the tag
  readonly name: string
}

const Person = Data.tagged<Person>("Person")

// The `_tag` field is automatically added
const alice = Person({ name: "Alice" })
const bob = Person({ name: "Bob" })

console.log(alice)
// Output: { name: 'Alice', _tag: 'Person' }
```

### Class

If you prefer working with classes instead of plain objects, you can use `Data.Class` as an alternative to `Data.case`. This approach may feel more natural in scenarios where you want a class-oriented structure, complete with methods and custom logic.

**Example** (Using Data.Class for a Class-Oriented Structure)

Here's how to define a `Person` class using `Data.Class`:

```ts

// Define a Person class extending Data.Class
class Person extends Data.Class<{ name: string }> {}

// Create an instance of Person
const alice = new Person({ name: "Alice" })

// Check for equality between two instances
console.log(Equal.equals(alice, new Person({ name: "Alice" })))
// Output: true
```

One of the benefits of using classes is that you can easily add custom methods and getters. This allows you to extend the functionality of your data types.

**Example** (Adding Custom Getters to a Class)

In this example, we add a `upperName` getter to the `Person` class to return the name in uppercase:

```ts

// Extend Person class with a custom getter
class Person extends Data.Class<{ name: string }> {
  get upperName() {
    return this.name.toUpperCase()
  }
}

// Create an instance and use the custom getter
const alice = new Person({ name: "Alice" })

console.log(alice.upperName)
// Output: ALICE
```

### TaggedClass

If you prefer a class-based approach but also want the benefits of tagging for disjoint unions, `Data.TaggedClass` can be a helpful option. It works similarly to `tagged` but is tailored for class definitions.

**Example** (Defining a Tagged Class with Built-In Tagging)

Here's how to define a `Person` class using `Data.TaggedClass`. Notice that the tag `"Person"` is automatically added:

```ts

// Define a tagged class Person with the _tag "Person"
class Person extends Data.TaggedClass("Person")<{ name: string }> {}

// Create an instance of Person
const alice = new Person({ name: "Alice" })

console.log(alice)
// Output: Person { name: 'Alice', _tag: 'Person' }

// Check equality between two instances
console.log(Equal.equals(alice, new Person({ name: "Alice" })))
// Output: true
```

One benefit of using tagged classes is the ability to easily add custom methods and getters, extending the class's functionality as needed.

**Example** (Adding Custom Getters to a Tagged Class)

In this example, we add a `upperName` getter to the `Person` class, which returns the name in uppercase:

```ts

// Extend the Person class with a custom getter
class Person extends Data.TaggedClass("Person")<{ name: string }> {
  get upperName() {
    return this.name.toUpperCase()
  }
}

// Create an instance and use the custom getter
const alice = new Person({ name: "Alice" })

console.log(alice.upperName)
// Output: ALICE
```

## Union of Tagged Structs

To create a disjoint union of tagged structs, you can use `Data.TaggedEnum` and `Data.taggedEnum`. These utilities make it straightforward to define and work with unions of plain objects.

### Definition

The type passed to `Data.TaggedEnum` must be an object where the keys represent the tags,
and the values define the structure of the corresponding data types.

**Example** (Defining a Tagged Union and Checking Equality)

```ts

// Define a union type using TaggedEnum
type RemoteData = Data.TaggedEnum<{
  Loading: {}
  Success: { readonly data: string }
  Failure: { readonly reason: string }
}>

// Create constructors for each case in the union
const { Loading, Success, Failure } = Data.taggedEnum<RemoteData>()

// Instantiate different states
const state1 = Loading()
const state2 = Success({ data: "test" })
const state3 = Success({ data: "test" })
const state4 = Failure({ reason: "not found" })

// Check equality between states
console.log(Equal.equals(state2, state3)) // Output: true
console.log(Equal.equals(state2, state4)) // Output: false

// Display the states
console.log(state1) // Output: { _tag: 'Loading' }
console.log(state2) // Output: { data: 'test', _tag: 'Success' }
console.log(state4) // Output: { reason: 'not found', _tag: 'Failure' }
```

> **Note: Tag Field Naming Convention**
  The tag field `"_tag"` is used to identify the type of each state,
  following Effect's naming convention.


### $is and $match

The `Data.taggedEnum` provides `$is` and `$match` functions for convenient type guarding and pattern matching.

**Example** (Using Type Guards and Pattern Matching)

```ts

type RemoteData = Data.TaggedEnum<{
  Loading: {}
  Success: { readonly data: string }
  Failure: { readonly reason: string }
}>

const { $is, $match, Loading, Success } = Data.taggedEnum<RemoteData>()

// Use `$is` to create a type guard for "Loading"
const isLoading = $is("Loading")

console.log(isLoading(Loading()))
// Output: true
console.log(isLoading(Success({ data: "test" })))
// Output: false

// Use `$match` for pattern matching
const matcher = $match({
  Loading: () => "this is a Loading",
  Success: ({ data }) => `this is a Success: ${data}`,
  Failure: ({ reason }) => `this is a Failure: ${reason}`
})

console.log(matcher(Success({ data: "test" })))
// Output: "this is a Success: test"
```

### Adding Generics

You can create more flexible and reusable tagged unions by using `TaggedEnum.WithGenerics`. This approach allows you to define tagged unions that can handle different types dynamically.

**Example** (Using Generics with TaggedEnum)

```ts

// Define a generic TaggedEnum for RemoteData
type RemoteData<Success, Failure> = Data.TaggedEnum<{
  Loading: {}
  Success: { data: Success }
  Failure: { reason: Failure }
}>

// Extend TaggedEnum.WithGenerics to add generics
interface RemoteDataDefinition extends Data.TaggedEnum.WithGenerics<2> {
  readonly taggedEnum: RemoteData<this["A"], this["B"]>
}

// Create constructors for the generic RemoteData
const { Loading, Failure, Success } =
  Data.taggedEnum<RemoteDataDefinition>()

// Instantiate each case with specific types
const loading = Loading()
const failure = Failure({ reason: "not found" })
const success = Success({ data: 1 })
```

## Errors

In Effect, handling errors is simplified using specialized constructors:

- `Error`
- `TaggedError`

These constructors make defining custom error types straightforward, while also providing useful integrations like equality checks and structured error handling.

### Error

`Data.Error` lets you create an `Error` type with extra fields beyond the typical `message` property.

**Example** (Creating a Custom Error with Additional Fields)

```ts

// Define a custom error with additional fields
class NotFound extends Data.Error<{ message: string; file: string }> {}

// Create an instance of the custom error
const err = new NotFound({
  message: "Cannot find this file",
  file: "foo.txt"
})

console.log(err instanceof Error)
// Output: true

console.log(err.file)
// Output: foo.txt
console.log(err)
/*
Output:
NotFound [Error]: Cannot find this file
  file: 'foo.txt'
  ... stack trace ...
*/
```

You can yield an instance of `NotFound` directly in an [Effect.gen](/docs/getting-started/using-generators/), without needing to use `Effect.fail`.

**Example** (Yielding a Custom Error in `Effect.gen`)

```ts

class NotFound extends Data.Error<{ message: string; file: string }> {}

const program = Effect.gen(function* () {
  yield* new NotFound({
    message: "Cannot find this file",
    file: "foo.txt"
  })
})

Effect.runPromise(program)
/*
throws:
Error: Cannot find this file
    at ... {
  name: '(FiberFailure) Error',
  [Symbol(effect/Runtime/FiberFailure/Cause)]: {
    _tag: 'Fail',
    error: NotFound [Error]: Cannot find this file
        at ...stack trace...
      file: 'foo.txt'
    }
  }
}
*/
```

### TaggedError

Effect provides a `TaggedError` API to add a `_tag` field automatically to your custom errors. This simplifies error handling with APIs like [Effect.catchTag](/docs/error-management/expected-errors/#catchtag) or [Effect.catchTags](/docs/error-management/expected-errors/#catchtags).

```ts

// Define a custom tagged error
class NotFound extends Data.TaggedError("NotFound")<{
  message: string
  file: string
}> {}

const program = Effect.gen(function* () {
  yield* new NotFound({
    message: "Cannot find this file",
    file: "foo.txt"
  })
}).pipe(
  // Catch and handle the tagged error
  Effect.catchTag("NotFound", (err) =>
    Console.error(`${err.message} (${err.file})`)
  )
)

Effect.runPromise(program)
// Output: Cannot find this file (foo.txt)
```

### Native Cause Support

Errors created using `Data.Error` or `Data.TaggedError` can include a `cause` property, integrating with the native `cause` feature of JavaScript's `Error` for more detailed error tracing.

**Example** (Using the `cause` Property)

```ts

// Define an error with a cause property
class MyError extends Data.Error<{ cause: Error }> {}

const program = Effect.gen(function* () {
  yield* new MyError({
    cause: new Error("Something went wrong")
  })
})

Effect.runPromise(program)
/*
throws:
Error: An error has occurred
    at ... {
  name: '(FiberFailure) Error',
  [Symbol(effect/Runtime/FiberFailure/Cause)]: {
    _tag: 'Fail',
    error: MyError
        at ...
      [cause]: Error: Something went wrong
          at ...
*/
```


---

# [DateTime](https://effect.website/docs/data-types/datetime/)

## Overview


Working with dates and times in JavaScript can be challenging. The built-in `Date` object mutates its internal state, and time zone handling can be confusing. These design choices can lead to errors when working on applications that rely on date-time accuracy, such as scheduling systems, timestamping services, or logging utilities.

The DateTime module aims to address these limitations by offering:

- **Immutable Data**: Each `DateTime` is an immutable structure, reducing mistakes related to in-place mutations.
- **Time Zone Support**: `DateTime` provides robust support for time zones, including automatic daylight saving time adjustments.
- **Arithmetic Operations**: You can perform arithmetic operations on `DateTime` instances, such as adding or subtracting durations.

## The DateTime Type

A `DateTime` represents a moment in time. It can be stored as either a simple UTC value or as a value with an associated time zone. Storing time this way helps you manage both precise timestamps and the context for how that time should be displayed or interpreted.

There are two main variants of `DateTime`:

1. **Utc**: An immutable structure that uses `epochMillis` (milliseconds since the Unix epoch) to represent a point in time in Coordinated Universal Time (UTC).

2. **Zoned**: Includes `epochMillis` along with a `TimeZone`, allowing you to attach an offset or a named region (like "America/New_York") to the timestamp.

### Why Have Two Variants?

- **Utc** is straightforward if you only need a universal reference without relying on local time zones.
- **Zoned** is helpful when you need to keep track of time zone information for tasks such as converting to local times or adjusting for daylight saving time.

### TimeZone Variants

A `TimeZone` can be either:

- **Offset**: Represents a fixed offset from UTC (for example, UTC+2 or UTC-5).
- **Named**: Uses a named region (e.g., "Europe/London" or "America/New_York") that automatically accounts for region-specific rules like daylight saving time changes.

### TypeScript Definition

Below is the TypeScript definition for the `DateTime` type:

```ts
type DateTime = Utc | Zoned

interface Utc {
  readonly _tag: "Utc"
  readonly epochMillis: number
}

interface Zoned {
  readonly _tag: "Zoned"
  readonly epochMillis: number
  readonly zone: TimeZone
}

type TimeZone = TimeZone.Offset | TimeZone.Named

declare namespace TimeZone {
  interface Offset {
    readonly _tag: "Offset"
    readonly offset: number
  }

  interface Named {
    readonly _tag: "Named"
    readonly id: string
  }
}
```

## The DateTime.Parts Type

The `DateTime.Parts` type defines the main components of a date, such as the year, month, day, hours, minutes, and seconds.

```ts
namespace DateTime {
  interface Parts {
    readonly millis: number
    readonly seconds: number
    readonly minutes: number
    readonly hours: number
    readonly day: number
    readonly month: number
    readonly year: number
  }

  interface PartsWithWeekday extends Parts {
    readonly weekDay: number
  }
}
```

## The DateTime.Input Type

The `DateTime.Input` type is a flexible input type that can be used to create a `DateTime` instance. It can be one of the following:

- A `DateTime` instance
- A JavaScript `Date` object
- A numeric value representing milliseconds since the Unix epoch
- An object with partial date [parts](#the-datetimeparts-type) (e.g., `{ year: 2024, month: 1, day: 1 }`)
- A string that can be parsed by JavaScript's [Date.parse](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse)

```ts
namespace DateTime {
  type Input = DateTime | Partial<Parts> | Date | number | string
}
```

## Utc Constructors

`Utc` is an immutable structure that uses `epochMillis` (milliseconds since the Unix epoch) to represent a point in time in Coordinated Universal Time (UTC).

### unsafeFromDate

Creates a `Utc` from a JavaScript `Date`.
Throws an `IllegalArgumentException` if the provided `Date` is invalid.

When a `Date` object is passed, it is converted to a `Utc` instance. The time is interpreted as the local time of the system executing the code and then adjusted to UTC. This ensures a consistent, timezone-independent representation of the date and time.

**Example** (Converting Local Time to UTC in Italy)

The following example assumes the code is executed on a system in Italy (CET timezone):

```ts

// Create a Utc instance from a local JavaScript Date
//
//     ┌─── Utc
//     ▼
const utc = DateTime.unsafeFromDate(new Date("2025-01-01 04:00:00"))

console.log(utc)
// Output: DateTime.Utc(2025-01-01T03:00:00.000Z)

console.log(utc.epochMillis)
// Output: 1735700400000
```

**Explanation**:

- The local time **2025-01-01 04:00:00** (in Italy, CET) is converted to **UTC** by subtracting the timezone offset (UTC+1 in January).
- As a result, the UTC time becomes **2025-01-01 03:00:00.000Z**.
- `epochMillis` provides the same time as milliseconds since the Unix Epoch, ensuring a precise numeric representation of the UTC timestamp.

### unsafeMake

Creates a `Utc` from a [DateTime.Input](#the-datetimeinput-type).

**Example** (Creating a DateTime with unsafeMake)

The following example assumes the code is executed on a system in Italy (CET timezone):

```ts

// From a JavaScript Date
const utc1 = DateTime.unsafeMake(new Date("2025-01-01 04:00:00"))
console.log(utc1)
// Output: DateTime.Utc(2025-01-01T03:00:00.000Z)

// From partial date parts
const utc2 = DateTime.unsafeMake({ year: 2025 })
console.log(utc2)
// Output: DateTime.Utc(2025-01-01T00:00:00.000Z)

// From a string
const utc3 = DateTime.unsafeMake("2025-01-01")
console.log(utc3)
// Output: DateTime.Utc(2025-01-01T00:00:00.000Z)
```

**Explanation**:

- The local time **2025-01-01 04:00:00** (in Italy, CET) is converted to **UTC** by subtracting the timezone offset (UTC+1 in January).
- As a result, the UTC time becomes **2025-01-01 03:00:00.000Z**.

### make

Similar to [unsafeMake](#unsafemake), but returns an [Option](/docs/data-types/option/) instead of throwing an error if the input is invalid.
If the input is invalid, it returns `None`. If valid, it returns `Some` containing the `Utc`.

**Example** (Creating a DateTime Safely)

The following example assumes the code is executed on a system in Italy (CET timezone):

```ts

// From a JavaScript Date
const maybeUtc1 = DateTime.make(new Date("2025-01-01 04:00:00"))
console.log(maybeUtc1)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: '2025-01-01T03:00:00.000Z' }
*/

// From partial date parts
const maybeUtc2 = DateTime.make({ year: 2025 })
console.log(maybeUtc2)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: '2025-01-01T00:00:00.000Z' }
*/

// From a string
const maybeUtc3 = DateTime.make("2025-01-01")
console.log(maybeUtc3)
/*
Output:
{ _id: 'Option', _tag: 'Some', value: '2025-01-01T00:00:00.000Z' }
*/
```

**Explanation**:

- The local time **2025-01-01 04:00:00** (in Italy, CET) is converted to **UTC** by subtracting the timezone offset (UTC+1 in January).
- As a result, the UTC time becomes **2025-01-01 03:00:00.000Z**.

## Zoned Constructors

A `Zoned` includes `epochMillis` along with a `TimeZone`, allowing you to attach an offset or a named region (like "America/New_York") to the timestamp.

### unsafeMakeZoned

Creates a `Zoned` by combining a [DateTime.Input](#the-datetimeinput-type) with an optional `TimeZone`.
This allows you to represent a specific point in time with an associated time zone.

The time zone can be provided in several ways:

- As a `TimeZone` object
- A string identifier (e.g., `"Europe/London"`)
- A numeric offset in milliseconds

If the input or time zone is invalid, an `IllegalArgumentException` is thrown.

**Example** (Creating a Zoned DateTime Without Specifying a Time Zone)

The following example assumes the code is executed on a system in Italy (CET timezone):

```ts

// Create a Zoned DateTime based on the system's local time zone
const zoned = DateTime.unsafeMakeZoned(new Date("2025-01-01 04:00:00"))

console.log(zoned)
// Output: DateTime.Zoned(2025-01-01T04:00:00.000+01:00)

console.log(zoned.zone)
// Output: TimeZone.Offset(+01:00)
```

Here, the system's time zone (CET, which is UTC+1 in January) is used to create the `Zoned` instance.

**Example** (Specifying a Named Time Zone)

The following example assumes the code is executed on a system in Italy (CET timezone):

```ts

// Create a Zoned DateTime with a specified named time zone
const zoned = DateTime.unsafeMakeZoned(new Date("2025-01-01 04:00:00"), {
  timeZone: "Europe/Rome"
})

console.log(zoned)
// Output: DateTime.Zoned(2025-01-01T04:00:00.000+01:00[Europe/Rome])

console.log(zoned.zone)
// Output: TimeZone.Named(Europe/Rome)
```

In this case, the `"Europe/Rome"` time zone is explicitly provided, resulting in the `Zoned` instance being tied to this named time zone.

By default, the input date is treated as a UTC value and then adjusted for the specified time zone. To interpret the input date as being in the specified time zone, you can use the `adjustForTimeZone` option.

**Example** (Adjusting for Time Zone Interpretation)

The following example assumes the code is executed on a system in Italy (CET timezone):

```ts

// Interpret the input date as being in the specified time zone
const zoned = DateTime.unsafeMakeZoned(new Date("2025-01-01 04:00:00"), {
  timeZone: "Europe/Rome",
  adjustForTimeZone: true
})

console.log(zoned)
// Output: DateTime.Zoned(2025-01-01T03:00:00.000+01:00[Europe/Rome])

console.log(zoned.zone)
// Output: TimeZone.Named(Europe/Rome)
```

**Explanation**

- **Without `adjustForTimeZone`**: The input date is interpreted as UTC and then adjusted to the specified time zone. For instance, `2025-01-01 04:00:00` in UTC becomes `2025-01-01T04:00:00.000+01:00` in CET (UTC+1).
- **With `adjustForTimeZone: true`**: The input date is interpreted as being in the specified time zone. For example, `2025-01-01 04:00:00` in "Europe/Rome" (CET) is adjusted to its corresponding UTC time, resulting in `2025-01-01T03:00:00.000+01:00`.

### makeZoned

The `makeZoned` function works similarly to [unsafeMakeZoned](#unsafemakezoned) but provides a safer approach. Instead of throwing an error when the input is invalid, it returns an `Option<Zoned>`.
If the input is invalid, it returns `None`. If valid, it returns `Some` containing the `Zoned`.

**Example** (Safely Creating a Zoned DateTime)

```ts

//      ┌─── Option<Zoned>
//      ▼
const zoned = DateTime.makeZoned(new Date("2025-01-01 04:00:00"), {
  timeZone: "Europe/Rome"
})

if (Option.isSome(zoned)) {
  console.log("The DateTime is valid")
}
```

### makeZonedFromString

Creates a `Zoned` by parsing a string in the format `YYYY-MM-DDTHH:mm:ss.sss+HH:MM[IANA timezone identifier]`.

If the input string is valid, the function returns a `Some` containing the `Zoned`. If the input is invalid, it returns `None`.

**Example** (Parsing a Zoned DateTime from a String)

```ts

//      ┌─── Option<Zoned>
//      ▼
const zoned = DateTime.makeZonedFromString(
  "2025-01-01T03:00:00.000+01:00[Europe/Rome]"
)

if (Option.isSome(zoned)) {
  console.log("The DateTime is valid")
}
```

## Current Time

### now

Provides the current UTC time as a `Effect<Utc>`, using the [Clock](/docs/requirements-management/default-services/) service.

**Example** (Retrieving the Current UTC Time)

```ts

const program = Effect.gen(function* () {
  //      ┌─── Utc
  //      ▼
  const currentTime = yield* DateTime.now
})
```

> **Tip: Why Use the Clock Service?**
  Using the `Clock` service ensures that time is consistent across your
  application, which is particularly useful in testing environments where
  you may need to control or mock the current time.


### unsafeNow

Retrieves the current UTC time immediately using `Date.now()`, without the [Clock](/docs/requirements-management/default-services/) service.

**Example** (Getting the Current UTC Time Immediately)

```ts

//      ┌─── Utc
//      ▼
const currentTime = DateTime.unsafeNow()
```

## Guards

| Function           | Description                                    |
| ------------------ | ---------------------------------------------- |
| `isDateTime`       | Checks if a value is a `DateTime`.             |
| `isTimeZone`       | Checks if a value is a `TimeZone`.             |
| `isTimeZoneOffset` | Checks if a value is a `TimeZone.Offset`.      |
| `isTimeZoneNamed`  | Checks if a value is a `TimeZone.Named`.       |
| `isUtc`            | Checks if a `DateTime` is the `Utc` variant.   |
| `isZoned`          | Checks if a `DateTime` is the `Zoned` variant. |

**Example** (Validating a DateTime)

```ts

function printDateTimeInfo(x: unknown) {
  if (DateTime.isDateTime(x)) {
    console.log("This is a valid DateTime")
  } else {
    console.log("Not a DateTime")
  }
}
```

## Time Zone Management

| Function              | Description                                                                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `setZone`             | Creates a `Zoned` from `DateTime` by applying the given `TimeZone`.                                                                              |
| `setZoneOffset`       | Creates a `Zoned` from `DateTime` using a fixed offset (in ms).                                                                                  |
| `setZoneNamed`        | Creates a `Zoned` from `DateTime` from an IANA time zone identifier or returns `None` if invalid.                                                |
| `unsafeSetZoneNamed`  | Creates a `Zoned` from `DateTime` from an IANA time zone identifier or throws if invalid.                                                        |
| `zoneUnsafeMakeNamed` | Creates a `TimeZone.Named` from a IANA time zone identifier or throws if the identifier is invalid.                                              |
| `zoneMakeNamed`       | Creates a `TimeZone.Named` from a IANA time zone identifier or returns `None` if invalid.                                                        |
| `zoneMakeNamedEffect` | Creates a `Effect<TimeZone.Named, IllegalArgumentException>` from a IANA time zone identifier failing with `IllegalArgumentException` if invalid |
| `zoneMakeOffset`      | Creates a `TimeZone.Offset` from a numeric offset in milliseconds.                                                                               |
| `zoneMakeLocal`       | Creates a `TimeZone.Named` from the system's local time zone.                                                                                    |
| `zoneFromString`      | Attempts to parse a time zone from a string, returning `None` if invalid.                                                                        |
| `zoneToString`        | Returns a string representation of a `TimeZone`.                                                                                                 |

**Example** (Applying a Time Zone to a DateTime)

```ts

// Create a UTC DateTime
//
//     ┌─── Utc
//     ▼
const utc = DateTime.unsafeMake("2024-01-01")

// Create a named time zone for New York
//
//      ┌─── TimeZone.Named
//      ▼
const zoneNY = DateTime.zoneUnsafeMakeNamed("America/New_York")

// Apply it to the DateTime
//
//      ┌─── Zoned
//      ▼
const zoned = DateTime.setZone(utc, zoneNY)

console.log(zoned)
// Output: DateTime.Zoned(2023-12-31T19:00:00.000-05:00[America/New_York])
```

### zoneFromString

Parses a string to create a `DateTime.TimeZone`.

This function attempts to interpret the input string as either:

- A numeric time zone offset (e.g., "GMT", "+01:00")
- An IANA time zone identifier (e.g., "Europe/London")

If the string matches an offset format, it is converted into a `TimeZone.Offset`.
Otherwise, it attempts to create a `TimeZone.Named` using the input.

If the input string is invalid, `Option.none()` is returned.

**Example** (Parsing a Time Zone from a String)

```ts

// Attempt to parse a numeric offset
const offsetZone = DateTime.zoneFromString("+01:00")
console.log(Option.isSome(offsetZone))
// Output: true

// Attempt to parse an IANA time zone
const namedZone = DateTime.zoneFromString("Europe/London")
console.log(Option.isSome(namedZone))
// Output: true

// Invalid input
const invalidZone = DateTime.zoneFromString("Invalid/Zone")
console.log(Option.isSome(invalidZone))
// Output: false
```

## Comparisons

| Function                                     | Description                                                  |
| -------------------------------------------- | ------------------------------------------------------------ |
| `distance`                                   | Returns the difference (in ms) between two `DateTime`s.      |
| `distanceDurationEither`                     | Returns a `Left` or `Right` `Duration` depending on order.   |
| `distanceDuration`                           | Returns a `Duration` indicating how far apart two times are. |
| `min`                                        | Returns the earlier of two `DateTime` values.                |
| `max`                                        | Returns the later of two `DateTime` values.                  |
| `greaterThan`, `greaterThanOrEqualTo`, etc.  | Checks ordering between two `DateTime` values.               |
| `between`                                    | Checks if a `DateTime` lies within the given bounds.         |
| `isFuture`, `isPast`, `unsafeIsFuture`, etc. | Checks if a `DateTime` is in the future or past.             |

**Example** (Finding the Distance Between Two DateTimes)

```ts

const utc1 = DateTime.unsafeMake("2025-01-01T00:00:00Z")
const utc2 = DateTime.add(utc1, { days: 1 })

console.log(DateTime.distance(utc1, utc2))
// Output: 86400000 (one day)

console.log(DateTime.distanceDurationEither(utc1, utc2))
/*
Output:
{
  _id: 'Either',
  _tag: 'Right',
  right: { _id: 'Duration', _tag: 'Millis', millis: 86400000 }
}
*/

console.log(DateTime.distanceDuration(utc1, utc2))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 86400000 }
```

## Conversions

| Function         | Description                                                             |
| ---------------- | ----------------------------------------------------------------------- |
| `toDateUtc`      | Returns a JavaScript `Date` in UTC.                                     |
| `toDate`         | Applies the time zone (if present) and converts to a JavaScript `Date`. |
| `zonedOffset`    | For a `Zoned` DateTime, returns the time zone offset in ms.             |
| `zonedOffsetIso` | For a `Zoned` DateTime, returns an ISO offset string like "+01:00".     |
| `toEpochMillis`  | Returns the Unix epoch time in milliseconds.                            |
| `removeTime`     | Returns a `Utc` with the time cleared (only date remains).              |

## Parts

| Function                   | Description                                                            |
| -------------------------- | ---------------------------------------------------------------------- |
| `toParts`                  | Returns time zone adjusted date parts (including weekday).             |
| `toPartsUtc`               | Returns UTC date parts (including weekday).                            |
| `getPart` / `getPartUtc`   | Retrieves a specific part (e.g., `"year"` or `"month"`) from the date. |
| `setParts` / `setPartsUtc` | Updates certain parts of a date, preserving or ignoring the time zone. |

**Example** (Extracting Parts from a DateTime)

```ts

const zoned = DateTime.setZone(
  DateTime.unsafeMake("2024-01-01"),
  DateTime.zoneUnsafeMakeNamed("Europe/Rome")
)

console.log(DateTime.getPart(zoned, "month"))
// Output: 1
```

## Math

| Function           | Description                                                                                |
| ------------------ | ------------------------------------------------------------------------------------------ |
| `addDuration`      | Adds the given `Duration` to a `DateTime`.                                                 |
| `subtractDuration` | Subtracts the given `Duration` from a `DateTime`.                                          |
| `add`              | Adds numeric parts (e.g., `{ hours: 2 }`) to a `DateTime`.                                 |
| `subtract`         | Subtracts numeric parts.                                                                   |
| `startOf`          | Moves a `DateTime` to the start of the given unit (e.g., the beginning of a day or month). |
| `endOf`            | Moves a `DateTime` to the end of the given unit.                                           |
| `nearest`          | Rounds a `DateTime` to the nearest specified unit.                                         |

## Formatting

| Function           | Description                                                          |
| ------------------ | -------------------------------------------------------------------- |
| `format`           | Formats a `DateTime` as a string using the `DateTimeFormat` API.     |
| `formatLocal`      | Uses the system's local time zone and locale for formatting.         |
| `formatUtc`        | Forces UTC formatting.                                               |
| `formatIntl`       | Uses a provided `Intl.DateTimeFormat`.                               |
| `formatIso`        | Returns an ISO 8601 string in UTC.                                   |
| `formatIsoDate`    | Returns an ISO date string, adjusted for the time zone.              |
| `formatIsoDateUtc` | Returns an ISO date string in UTC.                                   |
| `formatIsoOffset`  | Formats a `Zoned` as a string with an offset like "+01:00".          |
| `formatIsoZoned`   | Formats a `Zoned` in the form `YYYY-MM-DDTHH:mm:ss.sss+HH:MM[Zone]`. |

## Layers for Current Time Zone

| Function                 | Description                                                          |
| ------------------------ | -------------------------------------------------------------------- |
| `CurrentTimeZone`        | A service tag for the current time zone.                             |
| `setZoneCurrent`         | Sets a `DateTime` to use the current time zone.                      |
| `withCurrentZone`        | Provides an effect with a specified time zone.                       |
| `withCurrentZoneLocal`   | Uses the system's local time zone for the effect.                    |
| `withCurrentZoneOffset`  | Uses a fixed offset (in ms) for the effect.                          |
| `withCurrentZoneNamed`   | Uses a named time zone identifier (e.g., "Europe/London").           |
| `nowInCurrentZone`       | Retrieves the current time as a `Zoned` in the configured time zone. |
| `layerCurrentZone`       | Creates a Layer providing the `CurrentTimeZone` service.             |
| `layerCurrentZoneOffset` | Creates a Layer from a fixed offset.                                 |
| `layerCurrentZoneNamed`  | Creates a Layer from a named time zone, failing if invalid.          |
| `layerCurrentZoneLocal`  | Creates a Layer from the system's local time zone.                   |

**Example** (Using the Current Time Zone in an Effect)

```ts

// Retrieve the current time in the "Europe/London" time zone
const program = Effect.gen(function* () {
  const zonedNow = yield* DateTime.nowInCurrentZone
  console.log(zonedNow)
}).pipe(DateTime.withCurrentZoneNamed("Europe/London"))

Effect.runFork(program)
/*
Example Output:
DateTime.Zoned(2025-01-06T18:36:38.573+00:00[Europe/London])
*/
```


---

# [Duration](https://effect.website/docs/data-types/duration/)

## Overview

The `Duration` data type data type is used to represent specific non-negative spans of time. It is commonly used to represent time intervals or durations in various operations, such as timeouts, delays, or scheduling. The `Duration` type provides a convenient way to work with time units and perform calculations on durations.

## Creating Durations

The Duration module includes several constructors to create durations in different units.

**Example** (Creating Durations in Various Units)

```ts

// Create a duration of 100 milliseconds
const duration1 = Duration.millis(100)

// Create a duration of 2 seconds
const duration2 = Duration.seconds(2)

// Create a duration of 5 minutes
const duration3 = Duration.minutes(5)
```

You can create durations using units such as nanoseconds, microsecond, milliseconds, seconds, minutes, hours, days, and weeks.

For an infinite duration, use `Duration.infinity`.

**Example** (Creating an Infinite Duration)

```ts

console.log(String(Duration.infinity))
/*
Output:
Duration(Infinity)
*/
```

Another option for creating durations is using the `Duration.decode` helper:

- `number` values are treated as milliseconds.
- `bigint` values are treated as nanoseconds.
- Strings must follow the format `"${number} ${unit}"`.

**Example** (Decoding Values into Durations)

```ts

Duration.decode(10n) // same as Duration.nanos(10)
Duration.decode(100) // same as Duration.millis(100)
Duration.decode(Infinity) // same as Duration.infinity

Duration.decode("10 nanos") // same as Duration.nanos(10)
Duration.decode("20 micros") // same as Duration.micros(20)
Duration.decode("100 millis") // same as Duration.millis(100)
Duration.decode("2 seconds") // same as Duration.seconds(2)
Duration.decode("5 minutes") // same as Duration.minutes(5)
Duration.decode("7 hours") // same as Duration.hours(7)
Duration.decode("3 weeks") // same as Duration.weeks(3)
```

## Getting the Duration Value

You can retrieve the value of a duration in milliseconds using `Duration.toMillis`.

**Example** (Getting Duration in Milliseconds)

```ts

console.log(Duration.toMillis(Duration.seconds(30)))
// Output: 30000
```

To get the value of a duration in nanoseconds, use `Duration.toNanos`. Note that `toNanos` returns an `Option<bigint>` because the duration might be infinite.

**Example** (Getting Duration in Nanoseconds)

```ts

console.log(Duration.toNanos(Duration.millis(100)))
/*
Output:
{ _id: 'Option', _tag: 'Some', value: 100000000n }
*/
```

To get a `bigint` value without `Option`, use `Duration.unsafeToNanos`. However, it will throw an error for infinite durations.

**Example** (Retrieving Nanoseconds Unsafely)

```ts

console.log(Duration.unsafeToNanos(Duration.millis(100)))
// Output: 100000000n

console.log(Duration.unsafeToNanos(Duration.infinity))
/*
throws:
Error: Cannot convert infinite duration to nanos
  ...stack trace...
*/
```

## Comparing Durations

Use the following functions to compare two durations:

| API                    | Description                                                                  |
| ---------------------- | ---------------------------------------------------------------------------- |
| `lessThan`             | Returns `true` if the first duration is less than the second.                |
| `lessThanOrEqualTo`    | Returns `true` if the first duration is less than or equal to the second.    |
| `greaterThan`          | Returns `true` if the first duration is greater than the second.             |
| `greaterThanOrEqualTo` | Returns `true` if the first duration is greater than or equal to the second. |

**Example** (Comparing Two Durations)

```ts

const duration1 = Duration.seconds(30)
const duration2 = Duration.minutes(1)

console.log(Duration.lessThan(duration1, duration2))
// Output: true

console.log(Duration.lessThanOrEqualTo(duration1, duration2))
// Output: true

console.log(Duration.greaterThan(duration1, duration2))
// Output: false

console.log(Duration.greaterThanOrEqualTo(duration1, duration2))
// Output: false
```

## Performing Arithmetic Operations

You can perform arithmetic operations on durations, like addition and multiplication.

**Example** (Adding and Multiplying Durations)

```ts

const duration1 = Duration.seconds(30)
const duration2 = Duration.minutes(1)

// Add two durations
console.log(String(Duration.sum(duration1, duration2)))
/*
Output:
Duration(1m 30s)
*/

// Multiply a duration by a factor
console.log(String(Duration.times(duration1, 2)))
/*
Output:
Duration(1m)
*/
```

## Conversions

Converts a `Duration` to a human readable string.

**Example** 

```ts

Duration.format(Duration.millis(1000)) // "1s"
Duration.format(Duration.millis(1001)) // "1s 1ms"
```


---

# [Exit](https://effect.website/docs/data-types/exit/)

## Overview

An `Exit<A, E>` describes the result of running an `Effect` workflow.

There are two possible states for an `Exit<A, E>`:

- `Exit.Success`: Contains a success value of type `A`.
- `Exit.Failure`: Contains a failure [Cause](/docs/data-types/cause/) of type `E`.

## Creating Exits

The Exit module provides two primary functions for constructing exit values: `Exit.succeed` and `Exit.failCause`.
These functions represent the outcomes of an effectful computation in terms of success or failure.

### succeed

`Exit.succeed` creates an `Exit` value that represents a successful outcome.
You use this function when you want to indicate that a computation completed successfully and to provide the resulting value.

**Example** (Creating a Successful Exit)

```ts

// Create an Exit representing a successful outcome with the value 42
//
//      ┌─── Exit<number, never>
//      ▼
const successExit = Exit.succeed(42)

console.log(successExit)
// Output: { _id: 'Exit', _tag: 'Success', value: 42 }
```

### failCause

`Exit.failCause` creates an `Exit` value that represents a failure.
The failure is described using a [Cause](/docs/data-types/cause/) object, which can encapsulate expected errors, defects, interruptions, or even composite errors.

**Example** (Creating a Failed Exit)

```ts

// Create an Exit representing a failure with an error message
//
//      ┌─── Exit<never, string>
//      ▼
const failureExit = Exit.failCause(Cause.fail("Something went wrong"))

console.log(failureExit)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'Something went wrong' }
}
*/
```

## Pattern Matching

You can handle different outcomes of an `Exit` using the `Exit.match` function.
This function lets you provide two separate callbacks to handle both success and failure cases of an `Effect` execution.

**Example** (Matching Success and Failure States)

```ts

//      ┌─── Exit<number, never>
//      ▼
const simulatedSuccess = Effect.runSyncExit(Effect.succeed(1))

console.log(
  Exit.match(simulatedSuccess, {
    onFailure: (cause) =>
      `Exited with failure state: ${Cause.pretty(cause)}`,
    onSuccess: (value) => `Exited with success value: ${value}`
  })
)
// Output: "Exited with success value: 1"

//      ┌─── Exit<never, string>
//      ▼
const simulatedFailure = Effect.runSyncExit(
  Effect.failCause(Cause.fail("error"))
)

console.log(
  Exit.match(simulatedFailure, {
    onFailure: (cause) =>
      `Exited with failure state: ${Cause.pretty(cause)}`,
    onSuccess: (value) => `Exited with success value: ${value}`
  })
)
// Output: "Exited with failure state: Error: error"
```

## Exit vs Either

Conceptually, `Exit<A, E>` can be thought of as `Either<A, Cause<E>>`. However, the [Cause](/docs/data-types/cause/) type represents more than just expected errors of type `E`. It includes:

- Interruption causes
- Defects (unexpected errors)
- The combination of multiple causes

This allows `Cause` to capture richer and more complex error states compared to a simple `Either`.

## Exit vs Effect

`Exit` is actually a subtype of `Effect`. This means that `Exit` values can also be considered as `Effect` values.

- An `Exit`, in essence, is a "constant computation".
- `Effect.succeed` is essentially the same as `Exit.succeed`.
- `Effect.failCause` is the same as `Exit.failCause`.


---

# [HashSet](https://effect.website/docs/data-types/hash-set/)

## Overview


A HashSet represents an **unordered** collection of **unique** values with efficient lookup, insertion and removal operations.

The Effect library provides two versions of this structure:

- [HashSet](/docs/data-types/hash-set/#hashset) - Immutable
- [MutableHashSet](/docs/data-types/hash-set/#mutablehashset) - Mutable

Both versions provide constant-time operations on average. The main difference is how they handle changes: one returns new sets, the other modifies the original.

### Why use HashSet?

HashSet solves the problem of maintaining an **unsorted collection where each value appears exactly once**, with fast operations for checking membership and adding/removing values.

Some common use cases include:

- Tracking unique items (e.g., users who have completed an action)
- Efficiently testing for membership in a collection
- Performing set operations like union, intersection, and difference
- Eliminating duplicates from a collection

### When to use HashSet Instead of other collections

Choose HashSet (either variant) over other collections when:

- You need to ensure elements are unique
- You frequently need to check if an element exists in the collection
- You need to perform set operations like union, intersection, and difference
- The order of elements doesn't matter to your use case

Choose other collections when:

- You need to maintain insertion order (use `List` or `Array`)
- You need key-value associations (use `HashMap` or `MutableHashMap`)
- You need to frequently access elements by index (use `Array`)

### Choosing between immutable and mutable variants

Effect offers both immutable and mutable versions to support different coding styles and performance needs.

**HashSet**

This version never modifies the original set. Instead, it returns a new set for every change.

Characteristics:

- Operations return new instances instead of modifying the original
- Previous states are preserved
- Thread-safe by design
- Ideal for functional programming patterns
- Suitable for sharing across different parts of your application

**MutableHashSet**

This version allows direct updates: adding and removing values changes the set in place.

Characteristics:

- Operations modify the original set directly
- More efficient when building sets incrementally
- Requires careful handling to avoid unexpected side effects
- Better performance in scenarios with many modifications
- Ideal for localized use where mutations won't cause issues elsewhere

### When to use each variant

Use **HashSet** when:

- You need predictable behavior with no side effects
- You want to preserve previous states of your data
- You're sharing sets across different parts of your application
- You prefer functional programming patterns
- You need fiber safety in concurrent environments

Use **MutableHashSet** when:

- Performance is critical, and you need to avoid creating new instances
- You're building a collection incrementally with many additions/removals
- You're working in a controlled scope where mutation is safe
- You need to optimize memory usage in performance-critical code

### Hybrid approach

You can apply multiple updates to a `HashSet` in a temporary mutable context using `HashSet.mutate`. This allows you to perform several changes at once without modifying the original set.

**Example** (Batching changes without mutating the original)

```ts

// Create an immutable HashSet
const original = HashSet.make(1, 2, 3)

// Apply several updates inside a temporary mutable draft
const modified = HashSet.mutate(original, (draft) => {
  HashSet.add(draft, 4)
  HashSet.add(draft, 5)
  HashSet.remove(draft, 1)
})

console.log(HashSet.toValues(original))
// Output: [1, 2, 3] - original remains unchanged

console.log(HashSet.toValues(modified))
// Output: [2, 3, 4, 5] - changes applied to a new version
```

## Performance characteristics

Both `HashSet` and `MutableHashSet` offer similar average-time performance for core operations:

| Operation      | HashSet      | MutableHashSet | Description                     |
| -------------- | ------------ | -------------- | ------------------------------- |
| Lookup         | O(1) average | O(1) average   | Check if a value exists         |
| Insertion      | O(1) average | O(1) average   | Add a value                     |
| Removal        | O(1) average | O(1) average   | Remove a value                  |
| Iteration      | O(n)         | O(n)           | Iterate over all values         |
| Set operations | O(n)         | O(n)           | Union, intersection, difference |

The main difference is how updates are handled:

- **HashSet** returns a new set for each change. This can be slower if many changes are made in a row.
- **MutableHashSet** updates the same set in place. This is usually faster when performing many changes.

## Equality and uniqueness

Both `HashSet` and `MutableHashSet` use Effect's [`Equal`](/docs/trait/equal/) trait to determine if two elements are the same. This ensures that each value appears only once in the set.

- **Primitive values** (like numbers or strings) are compared by value, similar to the `===` operator.
- **Objects and custom types** must implement the `Equal` interface to define what it means for two instances to be equal. If no implementation is provided, equality falls back to reference comparison.

**Example** (Using custom equality and hashing)

```ts

// Define a custom class that implements the Equal interface
class Person implements Equal.Equal {
  constructor(
    readonly id: number,
    readonly name: string,
    readonly age: number
  ) {}

  // Two Person instances are equal if their id, name, and age match
  [Equal.symbol](that: Equal.Equal): boolean {
    if (that instanceof Person) {
      return (
        Equal.equals(this.id, that.id) &&
        Equal.equals(this.name, that.name) &&
        Equal.equals(this.age, that.age)
      )
    }
    return false
  }

  // Hash code is based on the id (must match the equality logic)
  [Hash.symbol](): number {
    return Hash.hash(this.id)
  }
}

// Add two different instances with the same content
const set = HashSet.empty().pipe(
  HashSet.add(new Person(1, "Alice", 30)),
  HashSet.add(new Person(1, "Alice", 30))
)

// Only one instance is kept
console.log(HashSet.size(set))
// Output: 1
```

### Simplifying Equality with Data and Schema

Effect's [`Data`](/docs/data-types/data/) and [`Schema.Data`](/docs/schema/effect-data-types/#interop-with-data) modules implement `Equal` for you automatically, based on structural equality.

**Example** (Using `Data.struct`)

```ts

// Define two records with the same content
const person1 = Data.struct({ id: 1, name: "Alice", age: 30 })
const person2 = Data.struct({ id: 1, name: "Alice", age: 30 })

// They are different object references
console.log(Object.is(person1, person2))
// Output: false

// But they are equal in value (based on content)
console.log(Equal.equals(person1, person2))
// Output: true

// Add both to a HashSet — only one will be stored
const set = pipe(
  HashSet.empty(),
  HashSet.add(person1),
  HashSet.add(person2)
)

console.log(HashSet.size(set))
// Output: 1
```

**Example** (Using `Schema.Data`)

```ts

// Define a schema that describes the structure of a Person
const PersonSchema = Schema.Data(
  Schema.Struct({
    id: Schema.Number,
    name: Schema.String,
    age: Schema.Number
  })
)

// Decode values from plain objects
const Person = Schema.decodeSync(PersonSchema)

const person1 = Person({ id: 1, name: "Alice", age: 30 })
const person2 = Person({ id: 1, name: "Alice", age: 30 })

// person1 and person2 are different instances but equal in value
console.log(Equal.equals(person1, person2))
// Output: true

// Add both to a MutableHashSet — only one will be stored
const set = MutableHashSet.empty().pipe(
  MutableHashSet.add(person1),
  MutableHashSet.add(person2)
)

console.log(MutableHashSet.size(set))
// Output: 1
```

## HashSet

A `HashSet<A>` is an **immutable**, **unordered** collection of **unique** values.
It guarantees that each value appears only once and supports fast operations like lookup, insertion, and removal.

Any operation that would modify the set (like adding or removing a value) returns a new `HashSet`, leaving the original unchanged.

### Operations

| Category     | Operation                                                                              | Description                                 | Time Complexity |
| ------------ | -------------------------------------------------------------------------------------- | ------------------------------------------- | --------------- |
| constructors | [empty](https://effect-ts.github.io/effect/effect/HashSet.ts.html#empty)               | Creates an empty HashSet                    | O(1)            |
| constructors | [fromIterable](https://effect-ts.github.io/effect/effect/HashSet.ts.html#fromiterable) | Creates a HashSet from an iterable          | O(n)            |
| constructors | [make](https://effect-ts.github.io/effect/effect/HashSet.ts.html#make)                 | Creates a HashSet from multiple values      | O(n)            |
| elements     | [has](https://effect-ts.github.io/effect/effect/HashSet.ts.html#has)                   | Checks if a value exists in the set         | O(1) avg        |
| elements     | [some](https://effect-ts.github.io/effect/effect/HashSet.ts.html#some)                 | Checks if any element satisfies a predicate | O(n)            |
| elements     | [every](https://effect-ts.github.io/effect/effect/HashSet.ts.html#every)               | Checks if all elements satisfy a predicate  | O(n)            |
| elements     | [isSubset](https://effect-ts.github.io/effect/effect/HashSet.ts.html#issubset)         | Checks if a set is a subset of another      | O(n)            |
| getters      | [values](https://effect-ts.github.io/effect/effect/HashSet.ts.html#values)             | Gets an `Iterator` of all values            | O(1)            |
| getters      | [toValues](https://effect-ts.github.io/effect/effect/HashSet.ts.html#tovalues)         | Gets an `Array` of all values               | O(n)            |
| getters      | [size](https://effect-ts.github.io/effect/effect/HashSet.ts.html#size)                 | Gets the number of elements                 | O(1)            |
| mutations    | [add](https://effect-ts.github.io/effect/effect/HashSet.ts.html#add)                   | Adds a value to the set                     | O(1) avg        |
| mutations    | [remove](https://effect-ts.github.io/effect/effect/HashSet.ts.html#remove)             | Removes a value from the set                | O(1) avg        |
| mutations    | [toggle](https://effect-ts.github.io/effect/effect/HashSet.ts.html#toggle)             | Toggles a value's presence                  | O(1) avg        |
| operations   | [difference](https://effect-ts.github.io/effect/effect/HashSet.ts.html#difference)     | Computes set difference (A - B)             | O(n)            |
| operations   | [intersection](https://effect-ts.github.io/effect/effect/HashSet.ts.html#intersection) | Computes set intersection (A ∩ B)           | O(n)            |
| operations   | [union](https://effect-ts.github.io/effect/effect/HashSet.ts.html#union)               | Computes set union (A ∪ B)                  | O(n)            |
| mapping      | [map](https://effect-ts.github.io/effect/effect/HashSet.ts.html#map)                   | Transforms each element                     | O(n)            |
| sequencing   | [flatMap](https://effect-ts.github.io/effect/effect/HashSet.ts.html#flatmap)           | Transforms and flattens elements            | O(n)            |
| traversing   | [forEach](https://effect-ts.github.io/effect/effect/HashSet.ts.html#foreach)           | Applies a function to each element          | O(n)            |
| folding      | [reduce](https://effect-ts.github.io/effect/effect/HashSet.ts.html#reduce)             | Reduces the set to a single value           | O(n)            |
| filtering    | [filter](https://effect-ts.github.io/effect/effect/HashSet.ts.html#filter)             | Keeps elements that satisfy a predicate     | O(n)            |
| partitioning | [partition](https://effect-ts.github.io/effect/effect/HashSet.ts.html#partition)       | Splits into two sets by a predicate         | O(n)            |

**Example** (Basic creation and operations)

```ts

// Create an initial set with 3 values
const set1 = HashSet.make(1, 2, 3)

// Add a value (returns a new set)
const set2 = HashSet.add(set1, 4)

// The original set is unchanged
console.log(HashSet.toValues(set1))
// Output: [1, 2, 3]

console.log(HashSet.toValues(set2))
// Output: [1, 2, 3, 4]

// Perform set operations with another set
const set3 = HashSet.make(3, 4, 5)

// Combine both sets
const union = HashSet.union(set2, set3)

console.log(HashSet.toValues(union))
// Output: [1, 2, 3, 4, 5]

// Shared values
const intersection = HashSet.intersection(set2, set3)

console.log(HashSet.toValues(intersection))
// Output: [3, 4]

// Values only in set2
const difference = HashSet.difference(set2, set3)

console.log(HashSet.toValues(difference))
// Output: [1, 2]
```

**Example** (Chaining with `pipe`)

```ts

const result = pipe(
  // Duplicates are ignored
  HashSet.make(1, 2, 2, 3, 4, 5, 5),
  // Keep even numbers
  HashSet.filter((n) => n % 2 === 0),
  // Double each value
  HashSet.map((n) => n * 2),
  // Convert to array
  HashSet.toValues
)

console.log(result)
// Output: [4, 8]
```

## MutableHashSet

A `MutableHashSet<A>` is a **mutable**, **unordered** collection of **unique** values.
Unlike `HashSet`, it allows direct modifications, operations like `add`, `remove`, and `clear` update the original set instead of returning a new one.

This mutability can improve performance when you need to build or update a set repeatedly, especially within a local or isolated scope.

### Operations

| Category     | Operation                                                                                     | Description                         | Complexity |
| ------------ | --------------------------------------------------------------------------------------------- | ----------------------------------- | ---------- |
| constructors | [empty](https://effect-ts.github.io/effect/effect/MutableHashSet.ts.html#empty)               | Creates an empty MutableHashSet     | O(1)       |
| constructors | [fromIterable](https://effect-ts.github.io/effect/effect/MutableHashSet.ts.html#fromiterable) | Creates a set from an iterable      | O(n)       |
| constructors | [make](https://effect-ts.github.io/effect/effect/MutableHashSet.ts.html#make)                 | Creates a set from multiple values  | O(n)       |
| elements     | [has](https://effect-ts.github.io/effect/effect/MutableHashSet.ts.html#has)                   | Checks if a value exists in the set | O(1) avg   |
| elements     | [add](https://effect-ts.github.io/effect/effect/MutableHashSet.ts.html#add)                   | Adds a value to the set             | O(1) avg   |
| elements     | [remove](https://effect-ts.github.io/effect/effect/MutableHashSet.ts.html#remove)             | Removes a value from the set        | O(1) avg   |
| getters      | [size](https://effect-ts.github.io/effect/effect/MutableHashSet.ts.html#size)                 | Gets the number of elements         | O(1)       |
| mutations    | [clear](https://effect-ts.github.io/effect/effect/MutableHashSet.ts.html#clear)               | Removes all values from the set     | O(1)       |

**Example** (Working with a mutable set)

```ts

// Create a mutable set with initial values
const set = MutableHashSet.make(1, 2, 3)

// Add a new element (updates the set in place)
MutableHashSet.add(set, 4)

// Check current contents
console.log([...set])
// Output: [1, 2, 3, 4]

// Remove an element (modifies in place)
MutableHashSet.remove(set, 1)

console.log([...set])
// Output: [2, 3, 4]

// Clear the set entirely
MutableHashSet.clear(set)

console.log(MutableHashSet.size(set))
// Output: 0
```

## Interoperability with JavaScript

Both `HashSet` and `MutableHashSet` implement the `Iterable` interface, so you can use them with JavaScript features like:

- the spread operator (`...`)
- `for...of` loops
- `Array.from`

You can also extract values as an array using `.toValues`.

**Example** (Using HashSet values in JS-native ways)

```ts

// Immutable HashSet
const hashSet = HashSet.make(1, 2, 3)

// Mutable variant
const mutableSet = MutableHashSet.make(4, 5, 6)

// Convert HashSet to an iterator
//
//      ┌─── IterableIterator<number>
//      ▼
const iterable = HashSet.values(hashSet)

// Spread into console.log
console.log(...iterable)
// Output: 1 2 3

// Use in a for...of loop
for (const value of mutableSet) {
  console.log(value)
}
// Output: 4 5 6

// Convert to array with Array.from
console.log(Array.from(mutableSet))
// Output: [ 4, 5, 6 ]

// Convert immutable HashSet to array using toValues
//
//      ┌─── Array<number>
//      ▼
const array = HashSet.toValues(hashSet)

console.log(array)
// Output: [ 1, 2, 3 ]
```

> **Caution: Performance considerations**
  Avoid repeatedly converting between `HashSet` and JavaScript arrays in
  hot paths or large collections. These operations involve copying data
  and can impact memory and speed.



---

# [BigDecimal](https://effect.website/docs/data-types/bigdecimal/)

## Overview


In JavaScript, numbers are typically stored as 64-bit floating-point values. While floating-point numbers are fast and versatile, they can introduce small rounding errors. These are often hard to notice in everyday usage but can become problematic in areas like finance or statistics, where small inaccuracies may lead to larger discrepancies over time.

By using the BigDecimal module, you can avoid these issues and perform calculations with a higher degree of precision.

The `BigDecimal` data type can represent real numbers with a large number of decimal places, preventing the common errors of floating-point math (for example, 0.1 + 0.2 ≠ 0.3).

## How BigDecimal Works

A `BigDecimal` represents a number using two components:

1. `value`: A `BigInt` that stores the digits of the number.
2. `scale`: A 64-bit integer that determines the position of the decimal point.

The number represented by a `BigDecimal` is calculated as: value x 10<sup>-scale</sup>.

- If `scale` is zero or positive, it specifies the number of digits to the right of the decimal point.
- If `scale` is negative, the `value` is multiplied by 10 raised to the power of the negated scale.

For example:

- A `BigDecimal` with `value = 12345n` and `scale = 2` represents `123.45`.
- A `BigDecimal` with `value = 12345n` and `scale = -2` represents `1234500`.

The maximum precision is large but not infinite, limited to 2<sup>63</sup> decimal places.

## Creating a BigDecimal

### make

The `make` function creates a `BigDecimal` by specifying a `BigInt` value and a scale. The `scale` determines the number of digits to the right of the decimal point.

**Example** (Creating a BigDecimal with a Specified Scale)

```ts

// Create a BigDecimal from a BigInt (1n) with a scale of 2
const decimal = BigDecimal.make(1n, 2)

console.log(decimal)
// Output: { _id: 'BigDecimal', value: '1', scale: 2 }

// Convert the BigDecimal to a string
console.log(String(decimal))
// Output: BigDecimal(0.01)

// Format the BigDecimal as a standard decimal string
console.log(BigDecimal.format(decimal))
// Output: 0.01

// Convert the BigDecimal to exponential notation
console.log(BigDecimal.toExponential(decimal))
// Output: 1e-2
```

### fromBigInt

The `fromBigInt` function creates a `BigDecimal` from a `bigint`. The `scale` defaults to `0`, meaning the number has no fractional part.

**Example** (Creating a BigDecimal from a BigInt)

```ts

const decimal = BigDecimal.fromBigInt(10n)

console.log(decimal)
// Output: { _id: 'BigDecimal', value: '10', scale: 0 }
```

### fromString

Parses a numerical string into a `BigDecimal`. Returns an `Option<BigDecimal>`:

- `Some(BigDecimal)` if the string is valid.
- `None` if the string is invalid.

**Example** (Parsing a String into a BigDecimal)

```ts

const decimal = BigDecimal.fromString("0.02")

console.log(decimal)
/*
Output:
{
  _id: 'Option',
  _tag: 'Some',
  value: { _id: 'BigDecimal', value: '2', scale: 2 }
}
*/
```

### unsafeFromString

The `unsafeFromString` function is a variant of `fromString` that throws an error if the input string is invalid. Use this only when you are confident that the input will always be valid.

**Example** (Unsafe Parsing of a String)

```ts

const decimal = BigDecimal.unsafeFromString("0.02")

console.log(decimal)
// Output: { _id: 'BigDecimal', value: '2', scale: 2 }
```

### unsafeFromNumber

Creates a `BigDecimal` from a JavaScript `number`. Throws a `RangeError` for non-finite numbers (`NaN`, `+Infinity`, or `-Infinity`).

**Example** (Unsafe Parsing of a Number)

```ts

console.log(BigDecimal.unsafeFromNumber(123.456))
// Output: { _id: 'BigDecimal', value: '123456', scale: 3 }
```

> **Caution: Avoid Direct Conversion**
  Avoid converting floating-point numbers directly to `BigDecimal`, as
  their representation may already introduce precision issues.


## Basic Arithmetic Operations

The BigDecimal module supports a variety of arithmetic operations that provide precision and avoid the rounding errors common in standard JavaScript arithmetic. Below is a list of supported operations:

| Function          | Description                                                                                                    |
| ----------------- | -------------------------------------------------------------------------------------------------------------- |
| `sum`             | Adds two `BigDecimal` values.                                                                                  |
| `subtract`        | Subtracts one `BigDecimal` value from another.                                                                 |
| `multiply`        | Multiplies two `BigDecimal` values.                                                                            |
| `divide`          | Divides one `BigDecimal` value by another, returning an `Option<BigDecimal>`.                                  |
| `unsafeDivide`    | Divides one `BigDecimal` value by another, throwing an error if the divisor is zero.                           |
| `negate`          | Negates a `BigDecimal` value (i.e., changes its sign).                                                         |
| `remainder`       | Returns the remainder of dividing one `BigDecimal` value by another, returning an `Option<BigDecimal>`.        |
| `unsafeRemainder` | Returns the remainder of dividing one `BigDecimal` value by another, throwing an error if the divisor is zero. |
| `sign`            | Returns the sign of a `BigDecimal` value (`-1`, `0`, or `1`).                                                  |
| `abs`             | Returns the absolute value of a `BigDecimal`.                                                                  |

**Example** (Performing Basic Arithmetic with BigDecimal)

```ts

const dec1 = BigDecimal.unsafeFromString("1.05")
const dec2 = BigDecimal.unsafeFromString("2.10")

// Addition
console.log(String(BigDecimal.sum(dec1, dec2)))
// Output: BigDecimal(3.15)

// Multiplication
console.log(String(BigDecimal.multiply(dec1, dec2)))
// Output: BigDecimal(2.205)

// Subtraction
console.log(String(BigDecimal.subtract(dec2, dec1)))
// Output: BigDecimal(1.05)

// Division (safe, returns Option<BigDecimal>)
console.log(BigDecimal.divide(dec2, dec1))
/*
Output:
{
  _id: 'Option',
  _tag: 'Some',
  value: { _id: 'BigDecimal', value: '2', scale: 0 }
}
*/

// Division (unsafe, throws if divisor is zero)
console.log(String(BigDecimal.unsafeDivide(dec2, dec1)))
// Output: BigDecimal(2)

// Negation
console.log(String(BigDecimal.negate(dec1)))
// Output: BigDecimal(-1.05)

// Modulus (unsafe, throws if divisor is zero)
console.log(
  String(
    BigDecimal.unsafeRemainder(dec2, BigDecimal.unsafeFromString("0.6"))
  )
)
// Output: BigDecimal(0.3)
```

Using `BigDecimal` for arithmetic operations helps to avoid the inaccuracies commonly encountered with floating-point numbers in JavaScript. For example:

**Example** (Avoiding Floating-Point Errors)

```ts
const dec1 = 1.05
const dec2 = 2.1

console.log(String(dec1 + dec2))
// Output: 3.1500000000000004
```

## Comparison Operations

The `BigDecimal` module provides several functions for comparing decimal values. These allow you to determine the relative order of two values, find the minimum or maximum, and check specific properties like positivity or integer status.

### Comparison Functions

| Function               | Description                                                              |
| ---------------------- | ------------------------------------------------------------------------ |
| `lessThan`             | Checks if the first `BigDecimal` is smaller than the second.             |
| `lessThanOrEqualTo`    | Checks if the first `BigDecimal` is smaller than or equal to the second. |
| `greaterThan`          | Checks if the first `BigDecimal` is larger than the second.              |
| `greaterThanOrEqualTo` | Checks if the first `BigDecimal` is larger than or equal to the second.  |
| `min`                  | Returns the smaller of two `BigDecimal` values.                          |
| `max`                  | Returns the larger of two `BigDecimal` values.                           |

**Example** (Comparing Two BigDecimal Values)

```ts

const dec1 = BigDecimal.unsafeFromString("1.05")
const dec2 = BigDecimal.unsafeFromString("2.10")

console.log(BigDecimal.lessThan(dec1, dec2))
// Output: true

console.log(BigDecimal.lessThanOrEqualTo(dec1, dec2))
// Output: true

console.log(BigDecimal.greaterThan(dec1, dec2))
// Output: false

console.log(BigDecimal.greaterThanOrEqualTo(dec1, dec2))
// Output: false

console.log(BigDecimal.min(dec1, dec2))
// Output: { _id: 'BigDecimal', value: '105', scale: 2 }

console.log(BigDecimal.max(dec1, dec2))
// Output: { _id: 'BigDecimal', value: '210', scale: 2 }
```

### Predicates for Comparison

The module also includes predicates to check specific properties of a `BigDecimal`:

| Predicate    | Description                                                    |
| ------------ | -------------------------------------------------------------- |
| `isZero`     | Checks if the value is exactly zero.                           |
| `isPositive` | Checks if the value is positive.                               |
| `isNegative` | Checks if the value is negative.                               |
| `between`    | Checks if the value lies within a specified range (inclusive). |
| `isInteger`  | Checks if the value is an integer (i.e., no fractional part).  |

**Example** (Checking the Sign and Properties of BigDecimal Values)

```ts

const dec1 = BigDecimal.unsafeFromString("1.05")
const dec2 = BigDecimal.unsafeFromString("-2.10")

console.log(BigDecimal.isZero(BigDecimal.unsafeFromString("0")))
// Output: true

console.log(BigDecimal.isPositive(dec1))
// Output: true

console.log(BigDecimal.isNegative(dec2))
// Output: true

console.log(
  BigDecimal.between({
    minimum: BigDecimal.unsafeFromString("1"),
    maximum: BigDecimal.unsafeFromString("2")
  })(dec1)
)
// Output: true

console.log(
  BigDecimal.isInteger(dec2),
  BigDecimal.isInteger(BigDecimal.fromBigInt(3n))
)
// Output: false true
```

## Normalization and Equality

In some cases, two `BigDecimal` values can have different internal representations but still represent the same number.

For example, `1.05` could be internally represented with different scales, such as:

- `105n` with a scale of `2`
- `1050n` with a scale of `3`

To ensure consistency, you can normalize a `BigDecimal` to adjust the scale and remove trailing zeros.

### Normalization

The `BigDecimal.normalize` function adjusts the scale of a `BigDecimal` and eliminates any unnecessary trailing zeros in its internal representation.

**Example** (Normalizing a BigDecimal)

```ts

const dec = BigDecimal.make(1050n, 3)

console.log(BigDecimal.normalize(dec))
// Output: { _id: 'BigDecimal', value: '105', scale: 2 }
```

### Equality

To check if two `BigDecimal` values are numerically equal, regardless of their internal representation, use the `BigDecimal.equals` function.

**Example** (Checking Equality)

```ts

const dec1 = BigDecimal.make(105n, 2)
const dec2 = BigDecimal.make(1050n, 3)

console.log(BigDecimal.equals(dec1, dec2))
// Output: true
```


---

# [Redacted](https://effect.website/docs/data-types/redacted/)

## Overview

The Redacted module provides functionality for handling sensitive information securely within your application.
By using the `Redacted` data type, you can ensure that sensitive values are not accidentally exposed in logs or error messages.

## make

The `Redacted.make` function creates a `Redacted<A>` instance from a given value `A`, ensuring the content is securely hidden.

**Example** (Hiding Sensitive Information from Logs)

Using `Redacted.make` helps prevent sensitive information, such as API keys, from being accidentally exposed in logs or error messages.

```ts

// Create a redacted API key
const API_KEY = Redacted.make("1234567890")

console.log(API_KEY)
// Output: {}

console.log(String(API_KEY))
// Output: <redacted>

Effect.runSync(Effect.log(API_KEY))
// Output: timestamp=... level=INFO fiber=#0 message="\"<redacted>\""
```

## value

The `Redacted.value` function retrieves the original value from a `Redacted` instance. Use this function carefully, as it exposes the sensitive data, potentially making it visible in logs or accessible in unintended ways.

**Example** (Accessing the Underlying Sensitive Value)

```ts

const API_KEY = Redacted.make("1234567890")

// Expose the redacted value
console.log(Redacted.value(API_KEY))
// Output: "1234567890"
```

## unsafeWipe

The `Redacted.unsafeWipe` function erases the underlying value of a `Redacted` instance, making it inaccessible. This helps ensure that sensitive data does not remain in memory longer than needed.

**Example** (Wiping Sensitive Data from Memory)

```ts

const API_KEY = Redacted.make("1234567890")

console.log(Redacted.value(API_KEY))
// Output: "1234567890"

Redacted.unsafeWipe(API_KEY)

console.log(Redacted.value(API_KEY))
/*
throws:
Error: Unable to get redacted value
*/
```

## getEquivalence

The `Redacted.getEquivalence` function generates an [Equivalence](/docs/behaviour/equivalence/) for `Redacted<A>` values using an Equivalence for the underlying values of type `A`. This allows you to compare `Redacted` values securely without revealing their content.

**Example** (Comparing Redacted Values)

```ts

const API_KEY1 = Redacted.make("1234567890")
const API_KEY2 = Redacted.make("1-34567890")
const API_KEY3 = Redacted.make("1234567890")

const equivalence = Redacted.getEquivalence(Equivalence.string)

console.log(equivalence(API_KEY1, API_KEY2))
// Output: false

console.log(equivalence(API_KEY1, API_KEY3))
// Output: true
```


---


## Common Mistakes

**Incorrect (null checks instead of Option):**

```ts
const user = getUser(id)
if (user !== null && user !== undefined) {
  console.log(user.name)
}
```

**Correct (using Option for absence):**

```ts
import { Option } from "effect"

const user = getUser(id) // Returns Option<User>
Option.map(user, (u) => console.log(u.name))
```
